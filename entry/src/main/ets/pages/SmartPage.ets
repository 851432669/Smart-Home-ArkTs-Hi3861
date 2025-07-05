import router from '@ohos.router'

@Component
export struct SmartPage {
  @Prop currentIndex: number = 1
  @State currentTab: number = 1 // 默认选中"智能"标签
  onTabChange?: (index: number) => void

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('4612的家')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')

        Blank()

        Image($r('app.media.index1_unused'))
          .width(24)
          .height(24)
          .margin({ left: 10 })

        Image($r('app.media.index2_unused'))
          .width(24)
          .height(24)
          .margin({ left: 10 })
      }
      .padding({ left: 20, right: 20, top: 20 })

      // 分类选择栏
      Row() {
        Text('推荐')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1890ff')
          .padding({ left: 15, right: 15, top: 8, bottom: 8 })
          .border({
            width: 2,
            color: '#1890ff',
            radius: 20,
            style: BorderStyle.Solid
          })
          .margin({ right: 10 })

        Text('我的')
          .fontSize(18)
          .fontWeight(FontWeight.Normal)
          .fontColor('#666')
          .padding({ left: 15, right: 15, top: 8, bottom: 8 })
          .margin({ right: 10 })
      }
      .padding({ left: 20, top: 20 })
      .width('100%')

      // 主要内容区域 - 场景卡片
      Scroll() {
        Column({ space: 20 }) {
          // 离家场景卡片
          Stack() {
            Image($r('app.media.living_room_1835923_1280'))
              .width('100%')
              .height(220)
              .borderRadius(16)
              .objectFit(ImageFit.Cover)
              .brightness(0.7)

            Column({ space: 8 }) {
              Text('离家')
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)

              Text('一键关闭空调、灯具设备，开启扫地机')
                .fontSize(16)
                .fontColor('rgba(255, 255, 255, 0.8)')
                .margin({ top: 5 })
            }
            .position({ x: '5%', y: '70%' })
            .alignItems(HorizontalAlign.Start)
            .width('90%')
          }
          .width('90%')
          .height(220)
          .borderRadius(16)
          .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 5 })
          .margin({ top: 20 })

          // 探索区域
          Column({ space: 10 }) {
            Text('探索')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)

            // 探索内容
            Row() {
              Image($r('app.media.sofa_9181557_1280'))
                .width('100%')
                .height(160)
                .borderRadius(16)
                .objectFit(ImageFit.Cover)
            }
            .width('90%')
            .height(160)
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 10 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ bottom: 80 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      // 底部导航栏
      Row() {
        Column() {
          Image($r('app.media.index1_unused'))
            .width(24)
            .height(24)
          Text('首页')
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 4 })
        }
        .width('25%')
        .height(60)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.back()
        })

        Column() {
          Image($r('app.media.index2_used'))
            .width(24)
            .height(24)
          Text('智能')
            .fontSize(12)
            .fontColor('#1890ff')
            .margin({ top: 4 })
        }
        .width('25%')
        .height(60)
        .justifyContent(FlexAlign.Center)

        Column() {
          Image($r('app.media.index3_unused'))
            .width(24)
            .height(24)
          Text('评估')
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 4 })
        }
        .width('25%')
        .height(60)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.pushUrl({ url: 'pages/EnvMonitorPage' })
        })

        Column() {
          Image($r('app.media.user1_unused'))
            .width(24)
            .height(24)
          Text('我的')
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 4 })
        }
        .width('25%')
        .height(60)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.pushUrl({ url: 'pages/ProfilePage' })
        })
      }
      .width('100%')
      .backgroundColor('#ffffff')
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetY: -2 })
      .padding({ top: 8, bottom: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}

@Entry
@Component
struct SmartPageEntry {
  build() {
    Column() {
      SmartPage()
    }
  }
} 