import http from '@ohos.net.http'
import type { BusinessError } from '@ohos.base'
import EnvironmentViewModel from '../viewmodel/EnvironmentViewModel'

interface AIResponse {
  reply: string
}

@Component
export struct AIComponent {
  @Prop item: EnvironmentViewModel
  @State resultString: string = '还未对当前环境进行评估'
  @State isBusy: boolean = false

  private readonly AI_API_URL: string = 'http://192.168.222.1:3000/ai-evaluate'  // ✅ 替换为实际 IP

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
}
