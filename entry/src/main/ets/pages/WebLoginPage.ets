import router from '@ohos.router'

@Entry
@Component
struct WebLoginPage {
  @State provider: string = ''
  @State platformName: string = ''
  @State bgImage: Resource = $r('app.media.default_bg') // 默认背景图

  onPageShow() {
    const params = router.getParams() as Record<string, string>
    this.provider = params?.provider ?? ''

    switch (this.provider) {
      case 'wechat':
        this.platformName = '微信'
        this.bgImage = $r('app.media.wx_earth') // 微信背景图
        break
      case 'qq':
        this.platformName = 'QQ'
        this.bgImage = $r('app.media.qq_back') // QQ背景图
        break
      case 'weibo':
        this.platformName = '微博'
        this.bgImage = $r('app.media.weibo') // 微博背景图
        break
      default:
        this.platformName = '未知平台'
        this.bgImage = $r('app.media.default_bg') // 默认背景图
    }
  }

  build() {
    Stack() {
      // 背景图片层
      Image(this.bgImage)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain) // 使用 Contain 来适应背景图片
        .opacity(0.8) // 添加透明度使文字更清晰

      // 半透明遮罩层，提高文字可读性
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(255, 255, 255, 0.3)')

      // 内容层
      Column({ space: 20 }) {
        Text(`${this.platformName} 登录`)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .shadow({ radius: 2, color: 'rgba(255,255,255,0.8)', offsetX: 0, offsetY: 1 })

        Text('暂未开放，敬请期待')
          .fontSize(18)
          .fontColor('#555555')
          .shadow({ radius: 1, color: 'rgba(255,255,255,0.5)', offsetX: 0, offsetY: 1 })

        Button('返回')
          .width(120)
          .height(40)
          .backgroundColor('#1890ff')
          .fontColor(Color.White)
          .margin({ top: 20 })
          .onClick(() => router.back())
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
  }
}
