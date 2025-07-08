import router from '@ohos.router'

@Entry
@Component
struct QuestionDialog {
  @State question: string = ''
  @State answer: string = ''
  
  aboutToAppear() {
    const params = router.getParams() as Record<string, string>
    if (params) {
      this.question = params.question || '常见问题'
      this.answer = params.answer || '暂无回答'
    }
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
        
        Text('问题详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
        
        Blank()
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      
      // 问题详情内容
      Column() {
        // 问题标题
        Text(this.question)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 20 })
        
        // 回答内容
        Text(this.answer)
          .fontSize(16)
          .fontColor('#333')
          .lineHeight(24)
          .margin({ bottom: 20 })
        
        // 问题是否解决
        Column() {
          Text('此回答是否解决了您的问题？')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 30, bottom: 16 })
          
          Row({ space: 20 }) {
            Button('已解决')
              .backgroundColor('#007DFF')
              .fontColor(Color.White)
              .width(120)
              .height(40)
              .onClick(() => {
                router.back()
              })
            
            Button('未解决')
              .backgroundColor('#f5f5f5')
              .fontColor('#666')
              .width(120)
              .height(40)
              .onClick(() => {
                // 可以添加跳转到客服页面的逻辑
                router.back()
              })
          }
        }
        .margin({ top: 30 })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
