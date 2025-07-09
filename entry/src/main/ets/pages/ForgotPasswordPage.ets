import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import { ApiService } from '../common/utils/ApiService'

@Entry
@Component
struct ForgotPasswordPage {
  @State username: string = ''
  @State question: string = ''
  @State answer: string = ''
  @State password: string = ''
  @State message: string = ''
  @State messageType: 'error' | 'success' | 'info' = 'info'
  @State showForm: boolean = false
  @State resetMethod: 'security' | 'contact' = 'security'
  @State contactType: 'phone' | 'email' = 'phone'
  @State contactValue: string = ''
  @State verificationCode: string = ''
  @State codeSent: boolean = false
  @State countdown: number = 60
  @State isSendingCode: boolean = false
  @State newPassword: string = ''
  @State confirmPassword: string = ''
  @State securityVerified: boolean = false
  private countdownTimer: number = -1

  aboutToDisappear() {
    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer)
      this.countdownTimer = -1
    }
  }

  private showMessage(msg: string, type: 'error' | 'success' | 'info') {
    this.message = msg
    this.messageType = type
  }

  async getQuestion() {
    if (!this.username.trim()) {
      this.showMessage('请输入用户名', 'error')
      return
    }

    // 调用 API 服务验证用户是否存在
    try {
      console.log('正在获取用户信息:', this.username)
      const response = await ApiService.verifyUser(this.username)
      console.log('验证用户响应:', JSON.stringify(response))
      
      if (response.success && response.data) {
        console.log('用户数据详情:', JSON.stringify({
          dataExists: !!response.data,
          hasUsername: !!response.data['username'],
          username: response.data['username'] || '未获取到',
          hasQuestion: !!response.data['question'],
          question: response.data['question'] || '未设置',
          questionType: typeof response.data['question'],
          allFields: Object.keys(response.data)
        }))
        
        // 如果用户存在，获取用户的安全问题
        const question = typeof response.data['question'] === 'string' ? 
          response.data['question'] : 
          JSON.stringify(response.data['question'] || '')
          
        console.log('获取到的密保问题:', question, '长度:', question.length, '类型:', typeof question)
        
        if (question && question.length > 0 && question !== 'null' && question !== 'undefined' && question !== '""') {
          this.question = question
      this.showForm = true
      this.showMessage('', 'info')
    } else {
          console.warn('密保问题为空或未设置')
          this.showMessage('该用户未设置密保问题', 'error')
          this.showForm = false
        }
      } else {
        console.warn('API响应失败或没有数据:', response.message)
        this.showMessage(response.message || '未找到该用户', 'error')
      this.showForm = false
      }
    } catch (error) {
      console.error('获取密保问题失败:', JSON.stringify(error))
      this.showMessage('服务器连接失败，请稍后再试', 'error')
    }
  }

  async verifyAnswer() {
    if (!this.answer.trim()) {
      this.showMessage('请输入密保答案', 'error')
      return
    }

    // 调用 API 服务验证密保答案
    try {
      const response = await ApiService.verifySecurityAnswer(this.username, this.answer)
      
      if (response.success) {
      this.securityVerified = true
      this.showMessage('密保问题验证成功，请设置新密码', 'success')
    } else {
        this.showMessage(response.message || '密保答案错误', 'error')
      }
    } catch (error) {
      console.error('验证密保答案失败:', JSON.stringify(error))
      this.showMessage('服务器连接失败，请稍后再试', 'error')
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
    if (!this.username.trim()) {
      this.showMessage('请输入用户名', 'error')
      return
    }

    if (!this.validateContact()) {
      return
    }

    this.isSendingCode = true

    try {
      // 调用API服务发送验证码
      const response = await ApiService.sendVerificationCode(this.username, this.contactType, this.contactValue)

      if (response.success) {
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
        
        // 在开发环境可以打印验证码
        if (response.data && response.data['code']) {
          console.log(`验证码: ${response.data['code']}`)
        }
      } else {
        this.showMessage(response.message || '验证码发送失败，请重试', 'error')
      }
    } catch (error) {
      this.showMessage('验证码发送失败，请重试', 'error')
      console.error('发送验证码失败:', JSON.stringify(error))
    } finally {
      this.isSendingCode = false
    }
  }

  // 通过密保问题重置密码
  async resetPasswordBySecurity() {
    if (!this.newPassword.trim() || !this.confirmPassword.trim()) {
      this.showMessage('请输入新密码和确认密码', 'error')
      return
    }

    if (this.newPassword !== this.confirmPassword) {
      this.showMessage('两次密码输入不一致', 'error')
      return
    }

    if (this.newPassword.length < 6) {
      this.showMessage('密码长度不能少于6位', 'error')
      return
    }

    try {
      // 调用 API 服务重置密码
      const response = await ApiService.forgotPassword(this.username, this.newPassword, 'security')
      
      if (response.success) {
      this.showMessage('密码重置成功，请使用新密码登录', 'success')
      setTimeout(() => {
        router.back()
      }, 2000)
      } else {
        this.showMessage(response.message || '密码重置失败，请重试', 'error')
      }
    } catch (error) {
      this.showMessage('密码重置失败，请重试', 'error')
      console.error('密码重置失败:', JSON.stringify(error))
    }
  }

  // 通过验证码重置密码
  async resetPasswordByCode() {
    if (!this.verificationCode.trim()) {
      this.showMessage('请输入验证码', 'error')
      return
    }

    if (!this.newPassword.trim() || !this.confirmPassword.trim()) {
      this.showMessage('请输入新密码和确认密码', 'error')
      return
    }

    if (this.newPassword !== this.confirmPassword) {
      this.showMessage('两次密码输入不一致', 'error')
      return
    }

    if (this.newPassword.length < 6) {
      this.showMessage('密码长度不能少于6位', 'error')
      return
    }

    try {
      // 首先验证验证码
      const verifyResponse = await ApiService.verifyCode(this.username, this.verificationCode)
      
      if (!verifyResponse.success) {
        this.showMessage(verifyResponse.message || '验证码错误或已过期', 'error')
        return
      }
      
      // 验证码正确，调用 API 服务重置密码
      const response = await ApiService.forgotPassword(this.username, this.newPassword, 'verification')

      if (response.success) {
      this.showMessage('密码重置成功，请使用新密码登录', 'success')
      setTimeout(() => {
        router.back()
      }, 2000)
      } else {
        this.showMessage(response.message || '密码重置失败，请重试', 'error')
      }
    } catch (error) {
      this.showMessage('密码重置失败，请重试', 'error')
      console.error('密码重置失败:', JSON.stringify(error))
    }
  }

  build() {
    Stack() {
      // 背景图层
      Image($r("app.media.registration_3960205_1280"))
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
          Text('找回密码')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 30 })

          // 表单内容放入白色半透明容器中，提高可读性
          Column({ space: 16 }) {
            TextInput({ placeholder: '请输入用户名' })
              .height(45)
              .backgroundColor('rgba(255, 255, 255, 0.8)')
              .borderRadius(8)
              .onChange(v => this.username = v)

            // 找回方式选择
            Row({ space: 20 }) {
              Text('找回方式：').fontSize(16)

              Row() {
                Radio({ value: 'security', group: 'resetMethod' })
                  .checked(this.resetMethod === 'security')
                  .onChange((checked: boolean) => {
                    if (checked) this.resetMethod = 'security'
                  })
                Text('密保问题').fontSize(16).margin({ left: 8 })
              }

              Row() {
                Radio({ value: 'contact', group: 'resetMethod' })
                  .checked(this.resetMethod === 'contact')
                  .onChange((checked: boolean) => {
                    if (checked) this.resetMethod = 'contact'
                  })
                Text('验证码').fontSize(16).margin({ left: 8 })
              }
            }

            // 密保问题找回
            if (this.resetMethod === 'security') {
              Button('获取密保问题')
                .height(40)
                .width('100%')
                .backgroundColor('#1890ff')
                .fontColor(Color.White)
                .borderRadius(8)
                .onClick(() => this.getQuestion())

              if (this.showForm) {
                Text(`密保问题：${this.question}`)
                  .fontSize(16)
                  .fontColor('#333')

                TextInput({ placeholder: '请输入密保答案' })
                  .height(45)
                  .backgroundColor('rgba(255, 255, 255, 0.8)')
                  .borderRadius(8)
                  .onChange(v => this.answer = v)

                Button('验证密保问题')
                  .height(40)
                  .width('100%')
                  .backgroundColor('#1890ff')
                  .fontColor(Color.White)
                  .borderRadius(8)
                  .onClick(() => this.verifyAnswer())
                  
                if (this.securityVerified) {
                  TextInput({ placeholder: '请输入新密码' })
                    .height(45)
                    .backgroundColor('rgba(255, 255, 255, 0.8)')
                    .borderRadius(8)
                    .type(InputType.Password)
                    .onChange(v => this.newPassword = v)
                    .margin({ top: 10 })
                  
                  TextInput({ placeholder: '请再次输入新密码' })
                    .height(45)
                    .backgroundColor('rgba(255, 255, 255, 0.8)')
                    .borderRadius(8)
                    .type(InputType.Password)
                    .onChange(v => this.confirmPassword = v)
                    .margin({ top: 10 })
                    
                  Button('重置密码')
                    .height(40)
                    .width('100%')
                    .backgroundColor('#1890ff')
                    .fontColor(Color.White)
                    .borderRadius(8)
                    .onClick(() => this.resetPasswordBySecurity())
                    .margin({ top: 10 })
                }
              }
            }

            // 验证码找回
            if (this.resetMethod === 'contact') {
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

              TextInput({ placeholder: '请输入新密码' })
                .height(45)
                .backgroundColor('rgba(255, 255, 255, 0.8)')
                .borderRadius(8)
                .type(InputType.Password)
                .onChange(v => this.newPassword = v)

              TextInput({ placeholder: '请再次输入新密码' })
                .height(45)
                .backgroundColor('rgba(255, 255, 255, 0.8)')
                .borderRadius(8)
                .type(InputType.Password)
                .onChange(v => this.confirmPassword = v)

              Button('重置密码')
                .height(40)
                .width('100%')
                .backgroundColor('#1890ff')
                .fontColor(Color.White)
                .borderRadius(8)
                .onClick(() => this.resetPasswordByCode())
            }

            if (this.message) {
              Text(this.message)
                .fontSize(14)
                .fontColor(this.messageType === 'error' ? '#ff4d4f' :
                  this.messageType === 'success' ? '#52c41a' : '#1890ff')
                .margin({ top: 10 })
            }

            Button('返回登录页')
              .height(40)
              .width('100%')
              .backgroundColor('#f0f0f0')
              .fontColor('#333')
              .borderRadius(8)
              .margin({ top: 20 })
              .onClick(() => router.back())
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
