import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import http from '@ohos.net.http'

// 定义注册请求数据接口
interface RegisterRequestData {
  username: string
  password: string
  contactType: string
  contactValue: string
  question?: string
  answer?: string
}

// 定义API响应接口
interface ApiResponse {
  success: boolean
  message: string
}

@Entry
@Component
struct RegisterPage {
  @State username: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State question: string = ''
  @State answer: string = ''
  @State message: string = ''
  @State messageType: 'error' | 'success' | 'info' = 'info'
  @State passwordStrength: 'weak' | 'medium' | 'strong' | '' = ''
  @State contactType: 'phone' | 'email' = 'phone'
  @State contactValue: string = ''
  @State verificationCode: string = ''
  @State codeSent: boolean = false
  @State countdown: number = 60
  @State isSendingCode: boolean = false
  private countdownTimer: number = -1
  // private readonly apiBaseUrl: string = 'http://192.168.1.100:3001' // 修改为您开发电脑的实际IP地址
  private readonly apiBaseUrl: string = 'http://192.168.12.85:3001' // 修改为您开发电脑的实际IP地址
  private checkPasswordStrength(password: string) {
    if (!password) {
      this.passwordStrength = ''
      return
    }

    const hasNum = /\d/.test(password)
    const hasLetter = /[a-zA-Z]/.test(password)
    const hasSymbol = /[^a-zA-Z0-9]/.test(password)

    if (hasNum && hasLetter && hasSymbol && password.length >= 8) {
      this.passwordStrength = 'strong'
    } else if ((hasNum && hasLetter) || (hasLetter && hasSymbol) || (hasNum && hasSymbol)) {
      this.passwordStrength = 'medium'
    } else {
      this.passwordStrength = 'weak'
    }
  }

  private showMessage(msg: string, type: 'error' | 'success' | 'info') {
    this.message = msg
    this.messageType = type
  }

  aboutToDisappear() {
    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer)
      this.countdownTimer = -1
    }
  }

  // 验证联系方式
  private validateContact(): boolean {
    if (this.contactType === 'phone') {
      // 简单的手机号验证
      const phoneRegex = /^(\+86)?1[3-9]\d{9}$/  // 允许带+86
      if (!phoneRegex.test(this.contactValue)) {
        this.showMessage('请输入正确的手机号码', 'error')
        return false
      }
    } else {
      // 简单的邮箱验证
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailRegex.test(this.contactValue)) {
        this.showMessage('请输入正确的邮箱地址', 'error')
        return false
      }
    }
    return true
  }

  // 发送验证码
  private async sendVerificationCode() {
    if (!this.validateContact()) {
      return
    }

    this.isSendingCode = true

    try {
      // 在实际应用中，这里应该调用后端API发送验证码
      // 这里只是模拟API调用

      // 模拟API延迟
      await new Promise<void>(resolve => setTimeout(resolve, 1000))

      const simulatedCode = '6666' // 模拟验证码
      console.log(`模拟发送验证码: ${simulatedCode}`)  // 输出验证码到控制台

      // 开始倒计时
      this.codeSent = true
      this.countdown = 60
      this.countdownTimer = setInterval(() => {
        if (this.countdown > 1) {
          this.countdown--
        } else {
          clearInterval(this.countdownTimer)
          this.countdownTimer = -1
          this.codeSent = false
        }
      }, 1000)

      this.showMessage(`验证码已发送至${this.contactType === 'phone' ? '手机' : '邮箱'}`, 'success')
      console.log("验证码发送成功")
    } catch (error) {
      this.showMessage('验证码发送失败，请重试', 'error')
      console.error('发送验证码失败:', JSON.stringify(error))
    } finally {
      this.isSendingCode = false
    }
  }

  async saveUser() {
    // 基本验证
    if (!this.username || !this.password || !this.confirmPassword || !this.contactValue || !this.verificationCode) {
      this.showMessage('请填写所有必要信息', 'error')
      return
    }

    if (this.password !== this.confirmPassword) {
      this.showMessage('两次密码输入不一致', 'error')
      return
    }

    if (this.password.length < 6) {
      this.showMessage('密码长度不能少于6位', 'error')
      return
    }

    if (!this.validateContact()) {
      return
    }

    // 验证验证码 - 实际应用中应调用后端API验证
    if (this.verificationCode !== '6666') { // 模拟固定验证码，实际应用中需要从后端验证
      this.showMessage('验证码错误', 'error')
      return
    }

    // 调用后端API注册用户
    try {
      // 创建HTTP请求客户端
      let httpRequest = http.createHttp();
      
      // 构建请求数据
      let requestData: RegisterRequestData = {
        username: this.username,
        password: this.password,
        contactType: this.contactType,
        contactValue: this.contactValue
      };
      
      // 添加密保问题和答案（如果有）
      if (this.question && this.answer) {
        requestData.question = this.question;
        requestData.answer = this.answer;
      }
      
      // 发送注册请求
      let response = await httpRequest.request(
        `${this.apiBaseUrl}/api/register`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify(requestData)
        }
      );
      
      // 释放HTTP客户端资源
      httpRequest.destroy();
      
      // 检查响应状态
      if (response.responseCode === 201) {
        let responseData = JSON.parse(response.result as string) as ApiResponse;
        if (responseData.success) {
          this.showMessage('注册成功', 'success');
          setTimeout(() => {
            router.pushUrl({ url: 'pages/Index' });
          }, 1000);
        } else {
          this.showMessage(responseData.message || '注册失败', 'error');
        }
      } else {
        // 处理非201状态码
        let responseData = JSON.parse(response.result as string) as ApiResponse;
        this.showMessage(responseData.message || '注册失败', 'error');
      }
    } catch (error) {
      this.showMessage('注册失败，请检查网络连接', 'error');
      console.error('注册失败:', JSON.stringify(error));
    }
  }

  build() {
    Stack() {
      // 背景图层
      Image($r("app.media.building_4128307_1280"))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 半透明遮罩层，提高表单可读性
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(255, 255, 255, 0.4)')

      // 内容层
      Scroll() {
        Column({ space: 20 }) {
          Text('用户注册')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 30 })

          Image($r('app.media.app_icon'))
            .width(100)
            .height(100)
            .borderRadius(20)
            .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.15)', offsetX: 0, offsetY: 2 })

          // 表单内容放入白色半透明容器中，提高可读性
          Column({ space: 16 }) {
            // 基本信息
            TextInput({ placeholder: '请输入用户名' })
              .height(45)
              .backgroundColor('rgba(255, 255, 255, 0.8)')
              .borderRadius(8)
              .onChange(v => this.username = v)

            TextInput({ placeholder: '请输入密码' })
              .height(45)
              .type(InputType.Password)
              .backgroundColor('rgba(255, 255, 255, 0.8)')
              .borderRadius(8)
              .onChange(v => {
                this.password = v
                this.checkPasswordStrength(v)
              })

            if (this.passwordStrength) {
              Text(`密码强度：${this.passwordStrength}`)
                .fontColor(this.passwordStrength === 'weak' ? '#ff4d4f' :
                  this.passwordStrength === 'medium' ? '#faad14' : '#52c41a')
            }

            TextInput({ placeholder: '请再次输入密码' })
              .height(45)
              .type(InputType.Password)
              .backgroundColor('rgba(255, 255, 255, 0.8)')
              .borderRadius(8)
              .onChange(v => this.confirmPassword = v)

            // 联系方式选择
            Row({ space: 10 }) {
              Text('联系方式：').fontSize(16)

              Row() {
                Radio({ value: 'phone', group: 'contactType' })
                  .checked(this.contactType === 'phone')
                  .onChange((checked: boolean) => {
                    if (checked) {
                      this.contactType = 'phone'
                      this.contactValue = ''
                    }
                  })
                Text('手机').fontSize(16).margin({ left: 8 })
              }

              Row() {
                Radio({ value: 'email', group: 'contactType' })
                  .checked(this.contactType === 'email')
                  .onChange((checked: boolean) => {
                    if (checked) {
                      this.contactType = 'email'
                      this.contactValue = ''
                    }
                  })
                Text('邮箱').fontSize(16).margin({ left: 8 })
              }
            }

            // 联系方式输入和验证码
            Row({ space: 8 }) {
              // 手机号码时显示+86框，邮箱时隐藏
              if (this.contactType === 'phone') {
                Row() {
                  Text('+86').fontSize(16).margin({ right: 8 }) // 国家代码框
                }
              }

              TextInput({
                placeholder: this.contactType === 'phone' ? '请输入手机号' : '请输入邮箱地址'
              })
                .height(45)
                .backgroundColor('rgba(255, 255, 255, 0.8)')
                .borderRadius(8)
                .layoutWeight(1)
                .onChange(v => this.contactValue = v)

              Button(this.codeSent ? `${this.countdown}秒后重发` : '获取验证码')
                .height(45)
                .backgroundColor(this.codeSent ? '#CCCCCC' : '#1890ff')
                .fontColor(this.codeSent ? '#666666' : Color.White)
                .borderRadius(8)
                .width(110)
                .enabled(!this.codeSent && !this.isSendingCode)
                .onClick(() => this.sendVerificationCode())
            }

            TextInput({ placeholder: '请输入验证码' })
              .height(45)
              .backgroundColor('rgba(255, 255, 255, 0.8)')
              .borderRadius(8)
              .type(InputType.Number)
              .maxLength(6)
              .onChange(v => this.verificationCode = v)

            // 密保问题下拉选择（可选）
            Column({ space: 10 }) {
              Text('密保问题（可选）').fontSize(16)
              
              Select([
                { value: '年龄' },
                { value: '出生地' },
                { value: '母亲名字' }
              ])
              .selected(0)
              .value(this.question)
              .onSelect((index: number, value: string) => {
                this.question = value
              })
              .width('100%')
              .backgroundColor('rgba(255, 255, 255, 0.8)')
              .borderRadius(8)
              .height(45)
            }

            TextInput({ placeholder: '请输入密保答案（可选）' })
              .height(45)
              .backgroundColor('rgba(255, 255, 255, 0.8)')
              .borderRadius(8)
              .onChange(v => this.answer = v)

            Button('注册')
              .height(50)
              .width('100%')
              .backgroundColor('#1890ff')
              .fontColor(Color.White)
              .borderRadius(25)
              .onClick(() => this.saveUser())

            Text('或使用以下方式登录')
              .fontSize(14)
              .margin({ top: 10 })

            Row({ space: 20 }) {
              Column() {
                Image($r('app.media.wx'))
                  .width(50)
                  .height(50)
                  .borderRadius(25) // 圆形图标
                Text('微信').fontSize(12).margin({top: 4})
              }
              .onClick(() => router.pushUrl({ url: 'pages/WebLoginPage', params: { provider: 'wechat' } }))

              Column() {
                Image($r('app.media.qq'))
                  .width(50)
                  .height(50)
                  .borderRadius(25) // 圆形图标
                Text('QQ').fontSize(12).margin({top: 4})
              }
              .onClick(() => router.pushUrl({ url: 'pages/WebLoginPage', params: { provider: 'qq' } }))

              Column() {
                Image($r('app.media.wb'))
                  .width(50)
                  .height(50)
                  .borderRadius(25) // 圆形图标
                Text('微博').fontSize(12).margin({top: 4})
              }
              .onClick(() => router.pushUrl({ url: 'pages/WebLoginPage', params: { provider: 'weibo' } }))
            }

            Row({ space: 5 }) {
              Text('已有账号？')
              Text('返回登录')
                .fontColor('#1890ff')
                .onClick(() => router.pushUrl({ url: 'pages/Index' }))
            }
            .margin({ top: 10 })

            if (this.message) {
              Text(this.message)
                .fontSize(14)
                .fontColor(this.messageType === 'error' ? '#ff4d4f' :
                  this.messageType === 'success' ? '#52c41a' : '#1890ff')
                .margin({ top: 10 })
            }
          }
          .width('90%')
          .padding(20)
          .backgroundColor('rgba(255, 255, 255, 0.8)')
          .borderRadius(16)
          .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 5 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ left: 20, right: 20, bottom: 20 })
      }
      .height('100%')
    }
  }
}



