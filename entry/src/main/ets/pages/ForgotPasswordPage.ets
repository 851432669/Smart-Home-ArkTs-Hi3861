import router from '@ohos.router'
import preferences from '@ohos.data.preferences'

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
  private readonly apiBaseUrl: string = 'http://your-api-server.com/api' // 替换为你的API地址

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

    const context = getContext(this)
    const store = await preferences.getPreferences(context, 'user_data')
    const savedQuestion = await store.get(`${this.username}_question`, '') as string
    if (savedQuestion) {
      this.question = savedQuestion
      this.showForm = true
      this.showMessage('', 'info')
    } else {
      this.showMessage('未找到该用户或该用户未设置密保', 'error')
      this.showForm = false
    }
  }

  async verifyAnswer() {
    if (!this.answer.trim()) {
      this.showMessage('请输入密保答案', 'error')
      return
    }

    const context = getContext(this)
    const store = await preferences.getPreferences(context, 'user_data')
    const savedAnswer = await store.get(`${this.username}_answer`, '') as string
    const savedPassword = await store.get(this.username, '') as string

    if (this.answer === savedAnswer) {
      this.password = savedPassword // 保存旧密码用于后续验证，但不显示
      this.securityVerified = true
      this.showMessage('密保问题验证成功，请设置新密码', 'success')
    } else {
      this.showMessage('密保答案错误', 'error')
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

    // 验证用户名和联系方式是否匹配
    const context = getContext(this)
    const store = await preferences.getPreferences(context, 'user_data')
    const savedContactType = await store.get(`${this.username}_contactType`, '') as string
    const savedContact = await store.get(`${this.username}_contact`, '') as string

    if (!savedContactType || !savedContact) {
      this.showMessage('未找到该用户或该用户未设置联系方式', 'error')
      return
    }

    if (savedContactType !== this.contactType || savedContact !== this.contactValue) {
      this.showMessage('用户名与联系方式不匹配', 'error')
      return
    }

    this.isSendingCode = true

    try {
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

    // 验证新密码不能与旧密码相同
    if (this.newPassword === this.password) {
      this.showMessage('新密码不能与旧密码相同', 'error')
      return
    }

    try {
      const context = getContext(this)
      const store = await preferences.getPreferences(context, 'user_data')
      
      // 更新密码
      await store.put(this.username, this.newPassword)
      await store.flush()

      this.showMessage('密码重置成功，请使用新密码登录', 'success')
      setTimeout(() => {
        router.back()
      }, 2000)
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

    // 验证验证码 - 实际应用中应调用后端API验证
    if (this.verificationCode !== '6666') { // 模拟固定验证码，实际应用中需要从后端验证
      this.showMessage('验证码错误', 'error')
      return
    }

    try {
      const context = getContext(this)
      const store = await preferences.getPreferences(context, 'user_data')
      
      // 获取旧密码进行比较
      const oldPassword = await store.get(this.username, '') as string
      
      // 验证新密码不能与旧密码相同
      if (this.newPassword === oldPassword) {
        this.showMessage('新密码不能与旧密码相同', 'error')
        return
      }
      
      // 更新密码
      await store.put(this.username, this.newPassword)
      await store.flush()

      this.showMessage('密码重置成功，请使用新密码登录', 'success')
      setTimeout(() => {
        router.back()
      }, 2000)
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
