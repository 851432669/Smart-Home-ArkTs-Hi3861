import router from '@ohos.router'

@Entry
@Component
struct TermsPage {
  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F5F5')
      
      // 内容
      Column() {
        // 顶部栏
        Row() {
          Text('用户管理条例')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 })
          
          Blank()
          
          Button('同意')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#1890ff')
            .borderRadius(20)
            .height(40)
            .width(80)
            .margin({ right: 16 })
            .onClick(() => {
              router.back()
            })
        }
        .width('100%')
        .height(56)
        .backgroundColor(Color.White)
        .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.05)', offsetY: 2 })
        
        // 条例内容
        Scroll() {
          Column({ space: 16 }) {
            Text('智慧家居管理系统用户管理条例')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 20 })
            
            Text('一、总则')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .margin({ top: 10 })
            
            Text('1.1 本条例旨在规范用户使用智慧家居管理系统（以下简称"本系统"）的行为，保护用户合法权益，明确各方权利义务。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('1.2 用户在注册、使用本系统前，应当仔细阅读本条例所有内容。注册或使用本系统即表示用户已同意遵守本条例的所有约定。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('二、用户注册与账号管理')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .margin({ top: 10 })
            
            Text('2.1 用户注册时应提供真实、准确、完整的个人资料，并保持信息更新。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('2.2 用户应妥善保管账号和密码，因账号或密码保管不善造成的损失由用户自行承担。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('2.3 用户不得将账号出借、转让或以其他方式允许他人使用，否则由此产生的后果由用户自行承担。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('三、隐私保护')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .margin({ top: 10 })
            
            Text('3.1 本系统重视用户隐私保护，将按照相关法律法规保护用户的个人信息安全。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('3.2 本系统收集的用户信息仅用于提供服务、改进产品体验和必要的系统通知。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('3.3 未经用户同意，本系统不会向第三方披露用户个人信息，法律法规另有规定的除外。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('四、用户行为规范')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .margin({ top: 10 })
            
            Text('4.1 用户应遵守中华人民共和国相关法律法规，不得利用本系统从事违法违规活动。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('4.2 用户不得干扰本系统的正常运行，不得尝试未经授权访问系统数据或功能。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('4.3 用户应尊重知识产权，不得未经许可使用本系统内容进行商业活动。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('五、系统运行与维护')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .margin({ top: 10 })
            
            Text('5.1 本系统将尽力保障服务的连续性和安全性，但不对因网络、设备故障等不可抗力导致的服务中断承担责任。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('5.2 本系统有权在必要时进行系统维护、升级，可能造成服务暂时中断，将尽可能提前通知用户。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('六、条例修改')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .margin({ top: 10 })
            
            Text('6.1 本系统有权在必要时修改本条例，修改后的条例将在系统内公布。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('6.2 用户继续使用本系统即视为接受修改后的条例。如不同意修改内容，应立即停止使用本系统。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('七、其他规定')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .margin({ top: 10 })
            
            Text('7.1 本条例的最终解释权归本系统所有。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5 })
            
            Text('7.2 本条例自发布之日起生效。')
              .fontSize(14)
              .textAlign(TextAlign.Start)
              .margin({ top: 5, bottom: 30 })
          }
          .width('90%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 16, bottom: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
      .width('100%')
      .height('100%')
    }
  }
} 