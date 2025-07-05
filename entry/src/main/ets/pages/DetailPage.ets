import router from '@ohos.router'

@Entry
@Component
struct DetailPage {
  @State type: string = ''

  onPageShow() {
    const params = router.getParams() as Record<string, string>
    this.type = params.type ?? '未知类型'
  }

  build() {
    Column({ space: 20 }) {
      MyComponent({ title: this.type })
        .backgroundColor(Color.Orange)
        .width('100%')
        .height('80%')

      Button("返回")
        .width('50%')
        .height(50)
        .onClick(() => {
          router.back()  // ✅ 返回上一页
        })
    }
    .padding(20)
  }
}

// ✅ 自定义组件定义在同一文件内
@Component
struct MyComponent {
  @Prop title: string

  build() {
    Row() {
      Text(`自定义组件 - ${this.title}`)
        .fontSize(24)
        .width('80%')
        .height('20%')
        .backgroundColor(Color.Pink)
    }
  }
}
