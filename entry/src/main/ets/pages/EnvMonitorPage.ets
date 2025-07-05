import { AIComponent } from '../view/AIComponent';
import { EnvComponent } from '../view/EnvComponent';
import { SwiperComponent } from '../view/SwiperComponent';
import EnvironmentViewModel from '../viewmodel/EnvironmentViewModel';
import router from '@ohos.router';

@Component
export struct EnvMonitorPage {
  @Prop currentIndex: number = 2
  @State item: EnvironmentViewModel = new EnvironmentViewModel()
  @State chartHeight: number = 200
  onTabChange?: (index: number) => void

  aboutToAppear() {
    const LOCATION_ID = '101230201'
    console.info("🟢 页面加载，准备调用天气接口")

    this.item.fetchWeather(LOCATION_ID).then(() => {
      console.info("✅ 天气数据加载完毕：", this.item.temp, this.item.hum, this.item.city)
    }).catch((err: Error) => {
      console.error("❌ 天气数据加载失败", JSON.stringify(err))
    })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.background'))
        .backgroundImageSize(ImageSize.Cover)
        .opacity(0.15)
      
      Column() {
        // 顶部栏
        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.ai_green_128'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .opacity(0.2)
          
          Column({ space: 4 }) {
            Text("环境监测系统")
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)

            Text("城市：" + (this.item.city || "厦门"))
              .fontSize(16)
              .fontColor(Color.White)
              .opacity(0.8)
          }
        }
        .width('100%')
        .height(80)
        .backgroundColor('#009688')
        .clip(true)
        
        // 主体内容
        Scroll() {
          Column({ space: 16 }) {
            // 操作栏
            Row() {
              Button() {
                Row({ space: 8 }) {
                  Image($r('app.media.foreground'))
                    .width(20)
                    .height(20)
                    .fillColor('#009688')
                  
                  Text('返回')
                    .fontSize(16)
                    .fontColor('#009688')
                }
              }
              .backgroundColor('rgba(0, 150, 136, 0.1)')
              .height(40)
              .borderRadius(20)
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                if (this.onTabChange) {
                  this.onTabChange(0); // 返回首页
                } else {
                  router.back(); // 兼容独立页面模式
                }
              })
              
              Blank()
              
              Button('刷新数据')
                .height(40)
                .backgroundColor('#009688')
                .borderRadius(20)
                .fontSize(16)
                .onClick(() => {
                  this.item.fetchWeather('101230201')
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 4 })
            
            // 环境数据卡片 - 直接使用EnvComponent
            Column() {
              Row() {
                Text('环境参数')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333')
                
                Blank()
                
                Row({ space: 6 }) {
                  Text('安全状态：')
                    .fontSize(14)
                    .fontColor('#666')
                  
                  Text(this.item.stat === 0 ? '安全' : this.item.stat === 1 ? '警告' : '危险')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.item.stat === 0 ? '#4CAF50' : this.item.stat === 1 ? '#FFC107' : '#F44336')
                }
              }
              .width('100%')
              .padding({ bottom: 10 })

              EnvComponent({ item: this.item })
            }
            .width('92%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
            .margin({ left: '4%', right: '4%' })
            
            // 轮播图表卡片 - 直接使用SwiperComponent
            Column() {
              Text('环境趋势')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 12 })
              
              SwiperComponent({ item: this.item })
            }
            .width('92%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
            .margin({ left: '4%', right: '4%' })
            
            // AI分析卡片 - 直接使用AIComponent
            Column() {
              Text('AI智能分析')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 12 })
              
              AIComponent({ item: this.item })
            }
            .width('92%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
            .margin({ left: '4%', right: '4%' })
          }
          .width('100%')
          .padding({ bottom: 80 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor('#F5F7FA')
  }
}

@Entry
@Component
struct EnvMonitorPageEntry {
  build() {
    Column() {
      EnvMonitorPage()
    }
  }
}

@Component
struct Card {
  @BuilderParam content: () => void

  build() {
    Column() {
      // 使用传入的构建器参数
      this.content()
    }
    .width('92%')
    .borderRadius(16)
    .backgroundColor(Color.White)
    .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
    .margin({ left: '4%', right: '4%' })
    .padding(16)
  }
}
