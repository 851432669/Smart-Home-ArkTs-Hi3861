import router from '@ohos.router'
import promptAction from '@ohos.promptAction' // 导入提示框组件
import { globalDataManager } from '../common/utils/GlobalDataManager'

@Component
export struct SmartPage {
  @Prop currentIndex: number = 1
  @State currentTab: number = 1 // 默认选中"智能"标签
  @State selectedCategory: string = '推荐' // 新增：分类选择状态
  onTabChange?: (index: number) => void

  // 添加离家模式的状态管理
  @State isACOn: boolean = true
  @State isLightOn: boolean = true
  @State isTVOn: boolean = true
  @State isCurtainOn: boolean = true
  @State isAudioOn: boolean = true
  @State isRobotOn: boolean = false
  
  // 添加执行状态提示
  @State executionStatus: string = ''
  @State isExecuting: boolean = false
  
  // 轮播图当前索引
  @State swiperIndex: number = 0

  // 页面显示时从全局状态获取最新数据
  aboutToAppear() {
    const acDevice = globalDataManager.getDeviceById('ac');
    const lightDevice = globalDataManager.getDeviceById('livingRoomLight');
    const tvDevice = globalDataManager.getDeviceById('tv');
    const curtainDevice = globalDataManager.getDeviceById('curtain');
    const audioDevice = globalDataManager.getDeviceById('audio');
    const robotDevice = globalDataManager.getDeviceById('robot');
    
    if(acDevice) this.isACOn = acDevice.isOn;
    if(lightDevice) this.isLightOn = lightDevice.isOn;
    if(tvDevice) this.isTVOn = tvDevice.isOn;
    if(curtainDevice) this.isCurtainOn = curtainDevice.isOn;
    if(audioDevice) this.isAudioOn = audioDevice.isOn;
    if(robotDevice) this.isRobotOn = robotDevice.isOn;
    
    // 检查是否所有设备都是离家模式状态
    if(!this.isACOn && !this.isLightOn && !this.isTVOn && !this.isCurtainOn && !this.isAudioOn && this.isRobotOn) {
      this.executionStatus = '已执行高效离家模式：关闭空调、客厅灯、电视、窗帘和音响，开启扫地机';
    }
  }

  // 离家模式执行函数
  leaveHome() {
    console.info('执行离家模式...');
    this.isExecuting = true;
    this.executionStatus = '正在执行离家模式...';
    
    // 更新全局状态
    globalDataManager.updateDevicesForScene('leaveHome');
    
    // 同步更新本地状态以更新UI
    const acDevice = globalDataManager.getDeviceById('ac');
    const lightDevice = globalDataManager.getDeviceById('livingRoomLight');
    const tvDevice = globalDataManager.getDeviceById('tv');
    const curtainDevice = globalDataManager.getDeviceById('curtain');
    const audioDevice = globalDataManager.getDeviceById('audio');
    const robotDevice = globalDataManager.getDeviceById('robot');
    
    if(acDevice) this.isACOn = acDevice.isOn;
    if(lightDevice) this.isLightOn = lightDevice.isOn;
    if(tvDevice) this.isTVOn = tvDevice.isOn;
    if(curtainDevice) this.isCurtainOn = curtainDevice.isOn;
    if(audioDevice) this.isAudioOn = audioDevice.isOn;
    if(robotDevice) this.isRobotOn = robotDevice.isOn;
    
    // 更新执行状态提示
    this.executionStatus = '已执行高效离家模式：关闭空调、客厅灯、电视、窗帘和音响，开启扫地机';
    
    // 显示操作成功的提示
    promptAction.showToast({
      message: '已执行离家模式：已关闭空调、客厅灯、电视、窗帘和音响，已开启扫地机',
      duration: 2000,
    });
    
    // 执行完成后恢复按钮状态
    setTimeout(() => {
      this.isExecuting = false;
    }, 2000);
  }

  // 获取家庭名称
  getHomeName(): string {
    return globalDataManager.getHomeName();
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text(this.getHomeName())
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
                .height(260)
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
                
                // 添加执行按钮
                Button('一键执行')
                  .fontSize(16)
                  .height(40)
                  .width(120)
                  .fontColor('#FFFFFF')
                  .backgroundColor('rgba(24, 144, 255, 0.9)')
                  .borderRadius(20)
                  .margin({ top: 15 })
                  .onClick(() => {
                    this.leaveHome()
                  })
                  .enabled(!this.isExecuting)
                
                // 显示当前设备状态
                Row({ space: 10 }) {
                  Text(`空调: ${this.isACOn ? '开启' : '关闭'}`)
                    .fontSize(14)
                    .fontColor(Color.White)
                  
                  Text(`客厅灯: ${this.isLightOn ? '开启' : '关闭'}`)
                    .fontSize(14)
                    .fontColor(Color.White)
                }
                .margin({ top: 10 })
                
                Row({ space: 10 }) {
                  Text(`电视: ${this.isTVOn ? '开启' : '关闭'}`)
                    .fontSize(14)
                    .fontColor(Color.White)
                    
                  Text(`窗帘: ${this.isCurtainOn ? '开启' : '关闭'}`)
                    .fontSize(14)
                    .fontColor(Color.White)
                }
                .margin({ top: 5 })
                
                Row({ space: 10 }) {
                  Text(`音响: ${this.isAudioOn ? '开启' : '关闭'}`)
                    .fontSize(14)
                    .fontColor(Color.White)
                    
                  Text(`扫地机: ${this.isRobotOn ? '开启' : '关闭'}`)
                    .fontSize(14)
                    .fontColor(Color.White)
                }
                .margin({ top: 5 })
                
                if(this.executionStatus) {
                  Text(this.executionStatus)
                    .fontSize(14)
                    .fontColor('#FFEB3B')
                    .fontWeight(FontWeight.Bold)
                    .width('90%')
                    .margin({ top: 10 })
                    .textAlign(TextAlign.Center)
                    .backgroundColor('rgba(0, 0, 0, 0.5)')
                    .padding(8)
                    .borderRadius(8)
                }
              }
              .position({ x: '5%', y: '50%' })
              .alignItems(HorizontalAlign.Start)
              .width('90%')
            }
            .width('90%')
            .height(260)
            .borderRadius(16)
            .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 5 })
            .margin({ top: 20 })

            // 探索区域
            Column({ space: 10 }) {
              Text('探索')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .alignSelf(ItemAlign.Start)

              // 探索内容 - 使用Swiper实现图片轮播
              Stack() {
                Swiper() {
                  // 第一张广告图
                  Stack() {
                    Image($r('app.media.ad1'))
                      .width('100%')
                      .height('100%')
                      .borderRadius(16)
                      .objectFit(ImageFit.Cover)
                      
                    // 黑色半透明遮罩层（底部）
                    Column()
                      .width('100%')
                      .height(60)
                      .backgroundColor('rgba(0, 0, 0, 0.3)')
                      .position({ x: 0, y: '100%' })
                      .translate({ y: -60 })
                      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
                      
                    // 文字描述
                    Text('舒适环保的智能家居')
                      .fontSize(16)
                      .fontColor(Color.White)
                      .fontWeight(FontWeight.Bold)
                      .position({ x: '5%', y: '100%' })
                      .translate({ y: -40 })
                  }
                  
                  // 第二张广告图
                  Stack() {
                    Image($r('app.media.ad2'))
                      .width('100%')
                      .height('100%')
                      .borderRadius(16)
                      .objectFit(ImageFit.Cover)
                      
                    // 黑色半透明遮罩层（底部）
                    Column()
                      .width('100%')
                      .height(60)
                      .backgroundColor('rgba(0, 0, 0, 0.3)')
                      .position({ x: 0, y: '100%' })
                      .translate({ y: -60 })
                      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
                      
                    // 文字描述
                    Text('提升家居智能化体验')
                      .fontSize(16)
                      .fontColor(Color.White)
                      .fontWeight(FontWeight.Bold)
                      .position({ x: '5%', y: '100%' })
                      .translate({ y: -40 })
                  }
                  
                  // 第三张广告图
                  Stack() {
                    Image($r('app.media.ad3'))
                      .width('100%')
                      .height('100%')
                      .borderRadius(16)
                      .objectFit(ImageFit.Cover)
                      
                    // 黑色半透明遮罩层（底部）
                    Column()
                      .width('100%')
                      .height(60)
                      .backgroundColor('rgba(0, 0, 0, 0.3)')
                      .position({ x: 0, y: '100%' })
                      .translate({ y: -60 })
                      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
                      
                    // 文字描述
                    Text('节能减排，绿色生活')
                      .fontSize(16)
                      .fontColor(Color.White)
                      .fontWeight(FontWeight.Bold)
                      .position({ x: '5%', y: '100%' })
                      .translate({ y: -40 })
                  }
                }
                .index(this.swiperIndex)
                .autoPlay(true)
                .interval(3000)
                .indicatorStyle({
                  color: '#8F8F8F',
                  selectedColor: '#FFFFFF',
                  size: 8,
                  // 删除不支持的selectedSize属性
                  // 使用官方支持的属性
                  right: 16,
                  bottom: 16
                })
                .indicator(true)
                .loop(true)
                .duration(1000)
                .itemSpace(0)
                .curve(Curve.Linear)
                .onChange((index: number) => {
                  this.swiperIndex = index;
                })
                .width('100%')
                .height('100%')
              }
              .width('90%')
              .height(200)
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