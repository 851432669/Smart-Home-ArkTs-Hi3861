import http from '@ohos.net.http'
import type { BusinessError } from '@ohos.base'
import EnvironmentViewModel from '../viewmodel/EnvironmentViewModel'

interface AIResponse {
  reply: string
}

interface SaveConversationResponse {
  success: boolean
  message: string
}

// 定义环境数据接口
interface EnvironmentData {
  temperature: number
  humidity: number
  co2: number
  pm25: number
}

// 定义对话记录请求数据接口
interface ConversationRequest {
  username: string
  prompt: string
  reply: string
  environmentData: EnvironmentData
}

@Component
export struct AIComponent {
  @Prop item: EnvironmentViewModel
  @State resultString: string = '还未对当前环境进行评估'
  @State isBusy: boolean = false

  private readonly AI_API_URL: string = 'http://192.168.222.1:3000/ai-evaluate'  // AI评估服务
  private readonly SAVE_CONVERSATION_URL: string = 'http://192.168.1.100:3001/api/ai-conversation' // MongoDB存储服务

  build() {
    Column() {
      Row() {
        Image($r('app.media.ai_green_128')).width(40).height(40)

        if (this.isBusy) {
          Row() {
            LoadingProgress().width(40).height(40).color(Color.Green)
            Text('AI评估中...').fontColor(Color.Green)
          }
        }

        Button('AI评估')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .height(34)
          .backgroundColor(Color.Green)
          .enabled(!this.isBusy)
          .onClick(() => this.evaluateByAI())
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Scroll() {
        Text(this.resultString).lineHeight(30).fontSize(16).width('100%')
      }
      .height(150)
      .margin({ top: 10 })
      .padding(5)
      .borderColor($r('app.color.green_128'))
      .borderWidth(1)
      .borderRadius(10)

      Blank()
    }
    .alignItems(HorizontalAlign.End)
    .padding(10)
    .width('94%')
    .height('auto')
    .borderRadius(10)
    .backgroundColor(Color.White)
    .margin({ left: 10, right: 10 })
  }

  evaluateByAI(): void {
    this.isBusy = true
    const prompt = this.item.toPromptString()
    const httpRequest = http.createHttp()

    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' },
      extraData: JSON.stringify({ prompt }),
      readTimeout: 60000,
      connectTimeout: 5000
    }

    httpRequest.request(this.AI_API_URL, options)
      .then((response: http.HttpResponse) => {
        try {
          const resultJson: AIResponse = JSON.parse(response.result as string)
          this.resultString = resultJson.reply ?? 'AI未返回结果'
          
          // 保存对话记录到MongoDB
          this.saveConversation(prompt, resultJson.reply, this.item)
        } catch (parseErr) {
          console.error('解析失败:', JSON.stringify(parseErr))
          this.resultString = '返回数据解析失败'
        }
      })
      .catch((error: BusinessError) => {
        console.error('请求失败:', JSON.stringify(error))
        this.resultString = '网络请求失败，请检查服务是否已启动'
      })
      .finally(() => {
        this.isBusy = false
        httpRequest.destroy()
      })
  }
  
  // 新增：保存对话记录到MongoDB
  private saveConversation(prompt: string, reply: string, environmentData: EnvironmentViewModel): void {
    const httpRequest = http.createHttp()
    
    console.info('准备保存AI对话记录到MongoDB...')
    console.info('服务器地址:', this.SAVE_CONVERSATION_URL)
    
    // 创建符合接口定义的请求数据对象
    const requestData: ConversationRequest = {
      username: 'current_user', // 可以从全局状态或存储中获取实际用户名
      prompt: prompt,
      reply: reply,
      environmentData: {
        temperature: environmentData.temp, // 使用正确的属性名
        humidity: environmentData.hum,     // 使用正确的属性名
        co2: environmentData.gas,          // 使用可燃气体浓度作为co2
        pm25: 0                           // EnvironmentViewModel中没有pm25，设置默认值
      }
    }
    
    console.info('请求数据:', JSON.stringify(requestData))
    
    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' },
      extraData: JSON.stringify(requestData),
      readTimeout: 60000,
      connectTimeout: 5000
    }
    
    console.info('开始发送HTTP请求...')
    httpRequest.request(this.SAVE_CONVERSATION_URL, options)
      .then((response: http.HttpResponse) => {
        console.info('收到HTTP响应, 状态码:', response.responseCode)
        const result: SaveConversationResponse = JSON.parse(response.result as string)
        if (result.success) {
          console.info('AI对话记录保存成功')
        } else {
          console.error('AI对话记录保存失败:', result.message)
        }
      })
      .catch((error: BusinessError) => {
        console.error('保存对话记录请求失败:', JSON.stringify(error))
      })
      .finally(() => {
        httpRequest.destroy()
      })
  }
}
