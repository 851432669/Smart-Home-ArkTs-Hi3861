// @CustomDialog
// export struct QuestionDialog {
//   @Prop controller: CustomDialogController
//   @Prop questions: string[]
//   @Prop onSelect: (question: string) => void
//
//   build() {
//     Column({ space: 10 }) {
//       Text('选择一个密保问题').fontSize(18).fontWeight(FontWeight.Bold)
//
//       ForEach(this.questions, (q: string) => {
//         Button(q)
//           .onClick(() => {
//             this.onSelect(q)
//             this.controller.close()
//           })
//       }, item => item)
//
//       Button('取消')
//         .onClick(() => this.controller.close())
//         .margin({ top: 10 })
//      }
//     .padding(20)
//     .width('100%')
//   }
// }
