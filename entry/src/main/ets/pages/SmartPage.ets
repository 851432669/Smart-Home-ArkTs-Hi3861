import router from '@ohos.router'

@Component
export struct SmartPage {
  @Prop currentIndex: number = 1
  @State currentTab: number = 1 // 默认选中"智能"标签
  @State selectedCategory: string = '推荐' // 新增：分类选择状态
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

       
      }
      .padding({ left: 20, right: 20, top: 20 })

      // 分类选择栏
      Row() {
        Text('推荐')
          .fontSize(18)
          .fontWeight(this.selectedCategory === '推荐' ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedCategory === '推荐' ? '#1890ff' : '#666')
          .padding({ left: 15, right: 15, top: 8, bottom: 8 })
          .border({
            width: this.selectedCategory === '推荐' ? 2 : 0,
            color: '#1890ff',
            radius: 20,
            style: BorderStyle.Solid
          })
          .backgroundColor(this.selectedCategory === '推荐' ? 'rgba(24, 144, 255, 0.05)' : 'transparent')
          .margin({ right: 10 })
          .onClick(() => {
            this.selectedCategory = '推荐'
          })

        Text('我的')
          .fontSize(18)
          .fontWeight(this.selectedCategory === '我的' ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedCategory === '我的' ? '#1890ff' : '#666')
          .padding({ left: 15, right: 15, top: 8, bottom: 8 })
          .border({
            width: this.selectedCategory === '我的' ? 2 : 0,
            color: '#1890ff',
            radius: 20,
            style: BorderStyle.Solid
          })
          .backgroundColor(this.selectedCategory === '我的' ? 'rgba(24, 144, 255, 0.05)' : 'transparent')
          .margin({ right: 10 })
          .onClick(() => {
            this.selectedCategory = '我的'
          })
      }
      .padding({ left: 20, top: 20 })
      .width('100%')

      // 主要内容区域
      if (this.selectedCategory === '推荐') {
        // 推荐内容区域 - 场景卡片
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
      } else {
        // 我的内容区域 - 两个卡片
        Scroll() {
          Column({ space: 20 }) {
            // 第一个卡片 - 烟雾报警
            Column() {
              // 使用Stack布局使图片占满整个卡片
              Stack() {
                Image($r('app.media.attention'))
                  .width('100%')
                  .height(180)
                  .borderRadius(16)
                  .objectFit(ImageFit.Cover)
                
                // 黑色半透明遮罩层
                Column()
                  .width('100%')
                  .height('100%')
                  .backgroundColor('rgba(0, 0, 0, 0.4)')
                  .borderRadius(16)
                
                // 左侧文字
                Column({ space: 8 }) {
                  Text('烟雾报警')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                  
                  Text('实时监测室内空气，及时发现火灾隐患')
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.8)')
                    .width('90%')
                    
                  Button('查看详情')
                    .fontSize(14)
                    .height(32)
                    .width(90)
                    .fontColor('#FFFFFF')
                    .backgroundColor('rgba(229, 57, 53, 0.8)')
                    .borderRadius(16)
                    .margin({ top: 12 })
                    .onClick(() => {
                      router.pushUrl({ url: 'pages/SmokeAlarmPage' })
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)
                .height('100%')
                .width('90%')
                .padding({ left: '5%' })
              }
              .width('100%')
              .height(180)
              .borderRadius(16)
            }
            .width('90%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
            .margin({ left: '5%', right: '5%', top: 20 })
            
            // 第二个卡片 - 我的场景
            Column() {
              // 使用Stack布局使图片占满整个卡片
              Stack() {
                Image($r('app.media.home_1'))
                  .width('100%')
                  .height(180)
                  .borderRadius(16)
                  .objectFit(ImageFit.Cover)
                
                // 黑色半透明遮罩层
                Column()
                  .width('100%')
                  .height('100%')
                  .backgroundColor('rgba(0, 0, 0, 0.4)')
                  .borderRadius(16)
                
                // 左侧文字
                Column({ space: 8 }) {
                  Text('室内环境监测')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                  
                  Text('实时监测室内温湿度和气体浓度，保障居家安全')
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.8)')
                    .width('90%')
                    
                  Button('进入检测')
                    .fontSize(14)
                    .height(32)
                    .width(90)
                    .fontColor('#FFFFFF')
                    .backgroundColor('rgba(24, 144, 255, 0.8)')
                    .borderRadius(16)
                    .margin({ top: 12 })
                    .onClick(() => {
                      router.pushUrl({ url: 'pages/EnvironmentInfoPage' })
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)
                .height('100%')
                .width('90%')
                .padding({ left: '5%' })
              }
              .width('100%')
              .height(180)
              .borderRadius(16)
            }
            .width('90%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
            .margin({ left: '5%', right: '5%', bottom: 20 })
          }
          .width('100%')
          .padding({ bottom: 80 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }

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