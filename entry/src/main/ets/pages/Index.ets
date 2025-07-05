import router from '@ohos.router'
import preferences from '@ohos.data.preferences'
import http from '@ohos.net.http'

@Entry
@Component
struct Index {
  @State username: string = ''
  @State password: string = ''
  @State message: string = ''
  @State isLoading: boolean = false
  @State logoScale: number = 1
  @State showPassword: boolean = false
  @State rememberAccount: boolean = false
  @State agreeToTerms: boolean = true
  @State canvasWidth: number = 300
  @State canvasHeight: number = 500
  private particles: Particle[] = []
  private readonly particleCount: number = 50
  private animationId: number = -1
  private readonly apiBaseUrl: string = 'http://your-api-server.com/api' // 替换为你的API地址
  
  // 使用Canvas特有的drawing上下文
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  aboutToAppear() {
    this.startLogoAnimation()
    this.initParticles()
    this.loadSavedAccount()
  }

  aboutToDisappear() {
    if (this.animationId !== -1) {
      clearInterval(this.animationId)
      this.animationId = -1
    }
  }

  // 加载已保存的账号信息
  async loadSavedAccount() {
    try {
      const context = getContext(this)
      const store = await preferences.getPreferences(context, 'account_cache')
      const savedUsername = await store.get('saved_username', '')
      
      if (savedUsername) {
        this.username = String(savedUsername)
        this.rememberAccount = true
      }
    } catch (error) {
      console.error('加载账号信息失败:', JSON.stringify(error))
    }
  }

  // 保存账号信息
  async saveAccountInfo() {
    if (!this.rememberAccount || !this.username) {
      return
    }

    try {
      const context = getContext(this)
      const store = await preferences.getPreferences(context, 'account_cache')
      await store.put('saved_username', this.username)
      await store.flush()
    } catch (error) {
      console.error('保存账号信息失败:', JSON.stringify(error))
    }
  }

  // 清除保存的账号信息
  async clearSavedAccount() {
    try {
      const context = getContext(this)
      const store = await preferences.getPreferences(context, 'account_cache')
      await store.delete('saved_username')
      await store.flush()
    } catch (error) {
      console.error('清除账号信息失败:', JSON.stringify(error))
    }
  }

  startLogoAnimation() {
    animateTo({
      duration: 800,
      tempo: 1.0,
      curve: Curve.EaseInOut,
      delay: 300,
      iterations: 1,
      playMode: PlayMode.Normal
    }, () => {
      this.logoScale = 1.1
    })

    setTimeout(() => {
      animateTo({
        duration: 600,
        curve: Curve.EaseOut,
      }, () => {
        this.logoScale = 1.0
      })
    }, 1100)
  }

  initParticles() {
    this.particles = []
    for (let i = 0; i < this.particleCount; i++) {
      this.particles.push(new Particle(this.canvasWidth, this.canvasHeight))
    }
  }

  drawParticles() {
    if (!this.context) {
      return
    }

    // 清除画布
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight)

    // 设置粒子样式
    this.context.fillStyle = 'rgba(255, 255, 255, 0.8)'

    // 更新和绘制粒子
    for (const p of this.particles) {
      p.update()

      // 绘制粒子
      this.context.beginPath()
      this.context.arc(p.x, p.y, p.radius, 0, Math.PI * 2)
      this.context.closePath()
      this.context.fill()
    }

    // 绘制连接线
    this.context.strokeStyle = 'rgba(255, 255, 255, 0.3)'
    this.context.lineWidth = 0.5

    for (let i = 0; i < this.particles.length; i++) {
      for (let j = i + 1; j < this.particles.length; j++) {
        const p1 = this.particles[i]
        const p2 = this.particles[j]
        const distance = Math.sqrt(Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2))

        if (distance < 100) {
          this.context.beginPath()
          this.context.moveTo(p1.x, p1.y)
          this.context.lineTo(p2.x, p2.y)
          // 根据距离调整透明度
          this.context.strokeStyle = `rgba(255, 255, 255, ${0.3 - distance / 333})`
          this.context.stroke()
        }
      }
    }
  }

  async login() {
    if (!this.username.trim() || !this.password.trim()) {
      this.message = '请输入用户名和密码'
      return
    }
    
    if (!this.agreeToTerms) {
      this.message = '请阅读并同意用户管理条例'
      return
    }

    this.isLoading = true
    this.message = '登录中...'

    try {
      // 处理账号记忆功能
      if (this.rememberAccount) {
        await this.saveAccountInfo()
      } else {
        await this.clearSavedAccount()
      }

      // 在实际应用中，这里应该调用后端API进行登录验证
      /* 实际调用示例:
      const httpRequest = http.createHttp()
      const response = await httpRequest.request(
        `${this.apiBaseUrl}/login`,
        {
          method: http.RequestMethod.POST,
          extraData: JSON.stringify({
            username: this.username,
            password: this.password
          }),
          header: { 'Content-Type': 'application/json' }
        }
      )
      
      const result = JSON.parse(response.result.toString())
      if (!result.success) {
        throw new Error(result.message)
      }
      */

      // 暂时使用本地存储进行登录验证
      const context = getContext(this)
      const store = await preferences.getPreferences(context, 'user_data')
      const savedPassword = await store.get(this.username, '')

      if (savedPassword === this.password) {
        this.message = '登录成功'
        setTimeout(() => {
          router.pushUrl({ url: 'pages/MainPage' })
          this.isLoading = false
        }, 1000)
      } else {
        setTimeout(() => {
          this.message = '用户名或密码错误'
          this.isLoading = false
        }, 500)
      }
    } catch (error) {
      console.error('登录错误:', JSON.stringify(error))
      this.message = '登录失败，请重试'
      this.isLoading = false
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景层
      Column() {
        Canvas(this.context)
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(10, 18, 32, 0.8)') // 深蓝黑色调背景
          .onReady(() => {
            // 获取canvas的实际尺寸
            this.canvasWidth = this.context.width
            this.canvasHeight = this.context.height
            this.initParticles()

            // 启动动画循环
            this.animationId = setInterval(() => {
              this.drawParticles()
            }, 30)
          })
      }
      .width('100%')
      .height('100%')
      .backgroundImage($r('app.media.starry_sky2'))
      .backgroundImageSize(ImageSize.Cover)
      
      // 内容层
      Column() {
        // 顶部logo区域
        Column({ space: 8 }) {
          Image($r("app.media.app_icon"))
            .height(100)
            .width(100)
            .borderRadius(20)
            .scale({ x: this.logoScale, y: this.logoScale })
            .shadow({ radius: 16, color: 'rgba(0, 0, 0, 0.2)', offsetX: 0, offsetY: 8 })
          
          Text('智慧家居')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ top: 16 })
          
          Text('让生活更智能、更环保')
            .fontSize(16)
            .fontColor('rgba(255, 255, 255, 0.8)')
            .margin({ bottom: 40 })
        }
        .margin({ top: 60 })
        
        // 登录表单
        Column() {
          // 用户名输入
          Column({ space: 6 }) {
            Text('用户名')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .alignSelf(ItemAlign.Start)
            
            TextInput({ placeholder: '请输入用户名', text: this.username })
              .height(50)
              .backgroundColor('rgba(248, 249, 250, 0.7)')
              .placeholderColor('#BDBDBD')
              .borderRadius(12)
              .padding({ left: 16, right: 16 })
              .fontSize(16)
              .width('100%')
              .onChange((value: string) => {
                this.username = value
              })
          }
          .margin({ bottom: 20 })
          
          // 密码输入
          Column({ space: 6 }) {
            Text('密码')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .alignSelf(ItemAlign.Start)
            
            Row() {
              TextInput({ placeholder: '请输入密码' })
                .height(50)
                .backgroundColor('rgba(248, 249, 250, 0.7)')
                .placeholderColor('#BDBDBD')
                .borderRadius(12)
                .padding({ left: 16, right: 16 })
                .fontSize(16)
                .width('100%')
                .type(this.showPassword ? InputType.Normal : InputType.Password)
                .onChange((value: string) => {
                  this.password = value
                })
              
              Image($r('app.media.foreground'))
                .width(24)
                .height(24)
                .fillColor('#BDBDBD')
                .position({ x: '85%', y: '50%' })
                .translate({ x: '-50%', y: '-50%' })
                .onClick(() => {
                  this.showPassword = !this.showPassword
                })
            }
          }
          .margin({ bottom: 12 })
          
          // 记住账号勾选框
          Row() {
            Checkbox()
              .select(this.rememberAccount)
              .onChange((checked: boolean) => {
                this.rememberAccount = checked
              })
              .width(20)
              .height(20)
              
            Text('记住账号')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .margin({ left: 8 })
          }
          .margin({ bottom: 8 })
          .alignSelf(ItemAlign.Start)
          
          // 用户管理条例勾选框
          Row() {
            Checkbox()
              .select(this.agreeToTerms)
              .onChange((checked: boolean) => {
                this.agreeToTerms = checked
              })
              .width(20)
              .height(20)
              
            Text('我已阅读并同意')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .margin({ left: 8 })
            
            Text('《用户管理条例》')
              .fontSize(14)
              .fontColor('#4A90E2')
              .onClick(() => {
                // 跳转到用户条例页面
                router.pushUrl({ url: 'pages/TermsPage' })
              })
          }
          .margin({ bottom: 12 })
          .alignSelf(ItemAlign.Start)
          
          // 错误提示
          if (this.message !== '') {
            Text(this.message)
              .fontColor('#FF5252')
              .fontSize(14)
              .alignSelf(ItemAlign.Center)
              .margin({ top: 8, bottom: 8 })
          }
          
          // 登录按钮
          Button({ type: ButtonType.Normal }) {
            if (this.isLoading) {
              Row({ space: 10 }) {
                LoadingProgress()
                  .width(20)
                  .height(20)
                  .color('#FFFFFF')
                
                Text('登录中...')
                  .fontColor('#FFFFFF')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
              }
            } else {
              Text('登录')
                .fontColor('#FFFFFF')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
            }
          }
          .width('100%')
          .height(50)
          .borderRadius(25)
          .backgroundColor('#4A90E2')
          .margin({ top: 8, bottom: 16 })
          .enabled(!this.isLoading)
          .onClick(() => this.login())
          
          // 底部导航
          Row() {
            Text('没有账号？')
              .fontColor('#FFFFFF')
              .fontSize(14)
            
            Text('注册')
              .fontColor('#4A90E2')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                router.pushUrl({ url: 'pages/RegisterPage' })
              })
            
            Blank()
            
            Text('忘记密码')
              .fontColor('#4A90E2')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                router.pushUrl({ url: 'pages/ForgotPasswordPage' })
              })
          }
          .width('100%')
        }
        .width('90%')
        .padding(24)
        .backgroundColor('rgba(255, 255, 255, 0.6)')
        .borderRadius(20)
        .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 4 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }
}

class Particle {
  x: number
  y: number
  vx: number
  vy: number
  radius: number
  screenWidth: number
  screenHeight: number

  constructor(screenWidth: number, screenHeight: number) {
    this.screenWidth = screenWidth
    this.screenHeight = screenHeight
    this.x = Math.random() * this.screenWidth
    this.y = Math.random() * this.screenHeight
    this.vx = (Math.random() - 0.5) * 1.5
    this.vy = (Math.random() - 0.5) * 1.5
    this.radius = Math.random() * 2 + 1.5
  }

  update() {
    this.x += this.vx
    this.y += this.vy

    if (this.x < 0 || this.x > this.screenWidth) {
      this.vx = -this.vx
    }
    if (this.y < 0 || this.y > this.screenHeight) {
      this.vy = -this.vy
    }
  }
}