import router from '@ohos.router'
import promptAction from '@ohos.promptAction'

// 定义自助服务项类型
class ServiceItem {
  title: string
  icon: Resource
  action: () => void

  constructor(title: string, icon: Resource, action: () => void) {
    this.title = title
    this.icon = icon
    this.action = action
  }
}

// 定义常见问题项类型
class FAQItem {
  question: string
  answer: string

  constructor(question: string, answer: string) {
    this.question = question
    this.answer = answer
  }
}

@Entry
@Component
struct HelpCenterPage {
  @State searchText: string = ''
  @State activeTabIndex: number = 0
  
  // 自助服务选项
  private selfServiceItems: ServiceItem[] = [
    new ServiceItem(
      '重置密码',
      $r('app.media.startIcon'),
      () => this.showFeatureInDevelopment('重置密码')
    ),
    new ServiceItem(
      '账号申诉',
      $r('app.media.startIcon'),
      () => this.showFeatureInDevelopment('账号申诉')
    ),
    new ServiceItem(
      '冻结账号',
      $r('app.media.startIcon'),
      () => this.showFeatureInDevelopment('冻结账号')
    ),
    new ServiceItem(
      '解冻账号',
      $r('app.media.startIcon'),
      () => this.showFeatureInDevelopment('解冻账号')
    ),
    new ServiceItem(
      '解封账号',
      $r('app.media.startIcon'),
      () => this.showFeatureInDevelopment('解封账号')
    ),
    new ServiceItem(
      '注销账号',
      $r('app.media.startIcon'),
      () => this.showFeatureInDevelopment('注销账号')
    )
  ]
  
  // 常见问题列表
  private faqItems: FAQItem[] = [
    new FAQItem(
      '如何修改登录密码？',
      '您可以在个人信息页面点击"更多设置"，然后选择"修改密码"选项进行密码修改。'
    ),
    new FAQItem(
      '忘记账号密码怎么办？',
      '您可以通过自助服务中的"重置密码"功能，通过绑定的手机号或邮箱重新设置密码。'
    ),
    new FAQItem(
      '如何绑定/更换手机号码？',
      '您可以在个人信息页面点击"更多设置"，然后选择"手机号管理"进行手机号绑定或更换。'
    ),
    new FAQItem(
      '账号被盗/异常登录怎么处理？',
      '请立即通过自助服务中的"账号申诉"功能提交申诉，或联系客服处理。为了账号安全，建议同时修改密码。'
    ),
    new FAQItem(
      '如何注销/删除账号？',
      '您可以通过自助服务中的"注销账号"功能申请注销账号，但请注意注销后账号相关信息将无法恢复。'
    ),
    new FAQItem(
      '如何修改个人资料？',
      '您可以在个人信息页面点击头像或昵称进行修改，其他个人资料可在"更多设置"中找到相应选项。'
    ),
    new FAQItem(
      '无法接收验证码怎么办？',
      '请检查手机信号是否正常，短信是否被拦截，或等待一段时间后重试。如仍无法接收，请联系客服解决。'
    ),
    new FAQItem(
      '应用闪退/无法打开怎么办？',
      '请尝试重启应用或手机，检查应用是否为最新版本，或清除应用缓存后重试。如问题持续，请联系客服反馈。'
    )
  ]
  
  // 显示功能开发中提示
  private showFeatureInDevelopment(feature: string): void {
    promptAction.showToast({
      message: `${feature}功能开发中`,
      duration: 2000
    })
  }
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.back')) // 返回按钮
          .width(24)
          .height(24)
          .onClick(() => {
            router.back()
          })
        
        Text('帮助中心')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
        
        Blank()
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      
      // 搜索框
      Row() {
        Image($r('app.media.search')) // 使用搜索图标
          .width(24)
          .height(24)
          .margin({ right: 8 })
        
        TextInput({ placeholder: '请输入问题关键词' })
          .width('90%')
          .height(40)
          .backgroundColor('transparent')
          .placeholderColor('#999')
          .onChange((value: string) => {
            this.searchText = value
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .borderRadius(20)
      .backgroundColor('#f0f0f0')
      .margin({ top: 12, bottom: 12, left: 16, right: 16 })
      
      // 标签栏
      Row() {
        Text('自助服务')
          .fontSize(16)
          .fontWeight(this.activeTabIndex === 0 ? FontWeight.Medium : FontWeight.Normal)
          .fontColor(this.activeTabIndex === 0 ? '#333' : '#999')
          .onClick(() => {
            this.activeTabIndex = 0
          })
        
        Text('常见问题')
          .fontSize(16)
          .fontWeight(this.activeTabIndex === 1 ? FontWeight.Medium : FontWeight.Normal)
          .fontColor(this.activeTabIndex === 1 ? '#333' : '#999')
          .margin({ left: 20 })
          .onClick(() => {
            this.activeTabIndex = 1
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .justifyContent(FlexAlign.Start)
      
      // 内容区
      if (this.activeTabIndex === 0) {
        // 自助服务内容
        Column() {
          
          
          // 自助服务网格
          Grid() {
            ForEach(this.selfServiceItems, (item: ServiceItem) => {
              GridItem() {
                Column() {
                  // 使用圆形背景的图标
                  Stack() {
                    Circle()
                      .width(48)
                      .height(48)
                      .fill('#f0f0f0')
                    
                    Image(item.icon)
                      .width(24)
                      .height(24)
                      .fillColor('#666')
                  }
                  
                  Text(item.title)
                    .fontSize(14)
                    .margin({ top: 8 })
                }
                .onClick(item.action)
              }
            })
          }
          .columnsTemplate('1fr 1fr 1fr')
          .rowsGap(16)
          .columnsGap(8)
          .padding({ left: 16, right: 16 })
          
          // 帮助中心标题
          Row() {
            Text('帮助中心')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            
            Text('更多')
              .fontSize(14)
              .fontColor('#999')
              .onClick(() => this.showFeatureInDevelopment('更多帮助'))
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 24, bottom: 16 })
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .layoutWeight(1)
      } else if (this.activeTabIndex === 1) {
        // 常见问题内容
        Column() {
          ForEach(this.faqItems, (item: FAQItem, index: number) => {
            Column() {
              Row() {
                Text(item.question)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                
                Image($r('app.media.right')) // 使用向右箭头图标
                  .width(20)
                  .height(20)
                  .fillColor('#999')
              }
              .width('100%')
              .padding({ top: 16, bottom: 16, left: 16, right: 16 })
              .backgroundColor(Color.White)
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                // 跳转到问题详情页
                router.pushUrl({
                  url: 'pages/QuestionDialog',
                  params: {
                    question: item.question,
                    answer: item.answer
                  }
                }).catch((err: Error) => {
                  console.error(`跳转到问题详情页失败: ${JSON.stringify(err)}`)
                  // 如果跳转失败，显示回答
                  promptAction.showDialog({
                    title: item.question,
                    message: item.answer,
                    buttons: [
                      {
                        text: '知道了',
                        color: '#007DFF'
                      }
                    ]
                  })
                })
              })
            }
            .margin({ bottom: index === this.faqItems.length - 1 ? 0 : 1 })
          })
        }
        .backgroundColor('#f5f5f5')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
} 