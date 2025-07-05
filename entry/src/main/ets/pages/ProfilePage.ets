import router from '@ohos.router'

@Component
export struct ProfilePage {
  @Prop currentIndex: number = 3
  @State currentTab: number = 3 // 默认选中"我的"标签
  onTabChange?: (index: number) => void

  build() {
    Column() {
      // 用户信息区域
      Row() {
        // 用户头像
        Image($r('app.media.user_37447_1280'))
          .width(80)
          .height(80)
          .borderRadius(40)
          .objectFit(ImageFit.Cover)

        // 用户信息
        Column({ space: 5 }) {
          Text('测试用户')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
          
          Row() {
            Text('账号: 5678910')
              .fontSize(14)
              .fontColor('#999')
            
            Text('已认证')
              .fontSize(12)
              .fontColor('#1890ff')
              .backgroundColor('rgba(24, 144, 255, 0.1)')
              .borderRadius(10)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .margin({ left: 10 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 15 })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 30, bottom: 20 })
      .backgroundColor(Color.White)

      // 用户家庭信息
      Row() {
        Text('测试用户的家')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        
        Text('1个房间')
          .fontSize(14)
          .fontColor('#999')
          .margin({ left: 10 })
        
        Blank()
        
        Image($r('app.media.index2_unused')) // 使用现有资源作为箭头图标
          .width(20)
          .height(20)
          .fillColor('#999')
      }
      .width('100%')
      .backgroundColor(Color.White)
      .padding({ left: 20, right: 20, top: 15, bottom: 15 })
      .margin({ top: 10 })
      .onClick(() => {
        // 点击跳转到家庭详情
      })

      // 设置选项列表
      Column({ space: 1 }) {
        // 更多设置
        Row() {
          Text('更多设置')
            .fontSize(16)
            .fontColor('#333')
          
          Blank()
          
          Image($r('app.media.index2_unused')) // 使用现有资源作为箭头图标
            .width(20)
            .height(20)
            .fillColor('#999')
        }
        .width('100%')
        .backgroundColor(Color.White)
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        .onClick(() => {
          // 点击跳转到更多设置
        })

        // 服务中心
        Row() {
          Text('服务中心')
            .fontSize(16)
            .fontColor('#333')
          
          Blank()
          
          Image($r('app.media.index2_unused')) // 使用现有资源作为箭头图标
            .width(20)
            .height(20)
            .fillColor('#999')
        }
        .width('100%')
        .backgroundColor(Color.White)
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        .onClick(() => {
          // 点击跳转到服务中心
        })

        // 帮助中心
        Row() {
          Text('帮助中心')
            .fontSize(16)
            .fontColor('#333')
          
          Blank()
          
          Image($r('app.media.index2_unused')) // 使用现有资源作为箭头图标
            .width(20)
            .height(20)
            .fillColor('#999')
        }
        .width('100%')
        .backgroundColor(Color.White)
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        .onClick(() => {
          // 点击跳转到帮助中心
        })

        // 关于我们
        Row() {
          Text('关于我们')
            .fontSize(16)
            .fontColor('#333')
          
          Blank()
          
          Image($r('app.media.index2_unused')) // 使用现有资源作为箭头图标
            .width(20)
            .height(20)
            .fillColor('#999')
        }
        .width('100%')
        .backgroundColor(Color.White)
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        .onClick(() => {
          // 点击跳转到关于我们
        })
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}

@Entry
@Component
struct ProfilePageEntry {
  build() {
    Column() {
      ProfilePage()
    }
  }
} 