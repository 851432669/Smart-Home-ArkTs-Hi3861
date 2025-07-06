import router from '@ohos.router';
import { MqttMessage } from '@ohos/mqtt';
import MQTTUtil from '../common/utils/MQTTUtil';
import EnvironmentViewModel from '../viewmodel/EnvironmentViewModel';

// Define payload interfaces
interface SmokeAlarmPayload {
  alarm: boolean;
  gas: number;
  level: number;
  message: string;
}

interface EmsPayload {
  smoke_alarm: number;
  gas: number;
}

@Entry
@Component
export struct SmokeAlarmPage {
  @State alarmActive: boolean = false
  @State gasLevel: number = 0
  @State alarmLevel: number = 0
  @State alarmMessage: string = ''
  @State lastUpdateTime: string = '等待数据...'

  private readonly alarmColors = ['#4CAF50', '#FFC107', '#F44336']
  private readonly alarmStates = ['正常', '警告', '危险']

  aboutToAppear() {
    this.connectToMQTT();
  }

  connectToMQTT() {
    new MQTTUtil().connect((err: Error, data: MqttMessage) => {
      if (!err) {
        try {
          const payloadStr = String(data.payload);
          console.info('收到MQTT消息:', payloadStr);

          if (data.topic === 'smoke_alarm') {
            const payload: SmokeAlarmPayload = JSON.parse(payloadStr);
            if (payload.alarm) {
              this.alarmActive = true;
              this.gasLevel = payload.gas;
              this.alarmLevel = payload.level;
              this.alarmMessage = payload.message;
              this.updateTime();

              if (this.alarmLevel === 2) {
                console.info('危险级别报警！');
              }
            }
          } else if (data.topic === 'ems') {
            const payload: EmsPayload = JSON.parse(payloadStr);
            this.alarmActive = payload.smoke_alarm > 0;
            this.gasLevel = payload.gas;
            this.alarmLevel = payload.smoke_alarm;

            if (this.alarmLevel === 0) {
              this.alarmMessage = '环境正常，未检测到异常气体。';
            } else if (this.alarmLevel === 1) {
              this.alarmMessage = '警告：检测到轻微异常气体，请注意通风。';
            } else if (this.alarmLevel === 2) {
              this.alarmMessage = '危险：检测到高浓度可燃气体，请立即采取措施！';
            }

            this.updateTime();
          }
        } catch (e) {
          console.error('解析MQTT消息失败:', e);
        }
      } else {
        console.error('MQTT连接错误:', err);
      }
    });
  }

  private updateTime() {
    const now = new Date();
    this.lastUpdateTime = `${now.toLocaleDateString()} ${now.toLocaleTimeString()}`;
  }
  build() {
    Column() {
      // 顶部栏
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ai_green_128'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .opacity(0.2)

        Column({ space: 4 }) {
          Text("烟雾气体报警系统")
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text("实时监测环境中的烟雾和可燃气体")
            .fontSize(16)
            .fontColor(Color.White)
            .opacity(0.8)
        }
      }
      .width('100%')
      .height(80)
      .backgroundColor('#E53935')  // 使用红色表示警报系统
      .clip(true)

      // 主体内容
      Scroll() {
        Column({ space: 16 }) {
          // 操作栏
          Row() {
            Button() {
              Row({ space: 8 }) {
                Image($r('app.media.back'))
                  .width(20)
                  .height(20)
                  .fillColor('#E53935')

                Text('返回')
                  .fontSize(16)
                  .fontColor('#E53935')
              }
            }
            .backgroundColor('rgba(229, 57, 53, 0.1)')
            .height(40)
            .borderRadius(20)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              router.back();
            })

            Blank()

            Button('刷新连接')
              .height(40)
              .backgroundColor('#E53935')
              .borderRadius(20)
              .fontSize(16)
              .onClick(() => {
                this.connectToMQTT();
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 4 })

          // 报警状态卡片
          Column() {
            // 报警状态指示器
            Row() {
              Column() {
                Text('报警状态')
                  .fontSize(16)
                  .fontColor('#333')
                  .opacity(0.7)

                Text(this.alarmActive ? '报警中' : '正常')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.alarmActive ? '#E53935' : '#4CAF50')
              }

              Blank()

              if (this.alarmActive) {
                Column() {
                  Image($r('app.media.attention'))
                    .width(60)
                    .height(60)
                    .objectFit(ImageFit.Contain)
                }
                .animation({
                  duration: 1000,
                  tempo: 1.0,
                  iterations: -1,
                  playMode: PlayMode.Alternate
                })
                .scale({ x: 1.2, y: 1.2 })
              } else {
                Image($r('app.media.foreground'))
                  .width(50)
                  .height(50)
                  .objectFit(ImageFit.Contain)
                  .fillColor('#4CAF50')
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 10, bottom: 20 })

            Divider().color('#EEEEEE').height(1)

            // 气体浓度显示
            Row() {
              Column({ space: 4 }) {
                Text('可燃气体浓度')
                  .fontSize(14)
                  .fontColor('#666')

                Row({ space: 4 }) {
                  Text(`${this.gasLevel}`)
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.alarmLevel === 0 ? '#4CAF50' :
                               this.alarmLevel === 1 ? '#FFC107' : '#E53935')

                  Text('PPM')
                    .fontSize(16)
                    .fontColor('#666')
                    .alignSelf(ItemAlign.End)
                }
              }

              Blank()

              Column({ space: 4 }) {
                Text('警报级别')
                  .fontSize(14)
                  .fontColor('#666')

                Text(this.alarmStates[this.alarmLevel])
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.alarmColors[this.alarmLevel])
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 20, bottom: 10 })
          }
          .width('92%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
          .margin({ left: '4%', right: '4%' })

          // 气体浓度进度条
          Column() {
            Text('气体浓度指示')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)

            Progress({ value: this.gasLevel, total: 2000, type: ProgressType.Capsule })
              .color(this.alarmLevel === 0 ? '#4CAF50' :
                     this.alarmLevel === 1 ? '#FFC107' : '#E53935')
              .height(26)
              .width('100%')
              .margin({ top: 10, bottom: 10 })

            Row() {
              Text('安全 (0)')
                .fontSize(12)
                .fontColor('#4CAF50')

              Blank()

              Text('警告 (1700)')
                .fontSize(12)
                .fontColor('#FFC107')

              Blank()

              Text('危险 (1800)')
                .fontSize(12)
                .fontColor('#E53935')
            }
            .width('100%')
          }
          .width('92%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
          .margin({ left: '4%', right: '4%' })

          // 报警信息卡片
          Column() {
            Text('报警信息')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)

            Text(this.alarmMessage || '无报警信息')
              .fontSize(16)
              .fontColor(this.alarmActive ? '#E53935' : '#333')
              .fontWeight(this.alarmActive ? FontWeight.Bold : FontWeight.Normal)
              .margin({ top: 10, bottom: 10 })

            if (this.alarmActive && this.alarmLevel === 2) {
              Column() {
                Text('紧急处理建议：')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#E53935')
                  .alignSelf(ItemAlign.Start)
                  .margin({ top: 10, bottom: 5 })

                Text('1. 立即打开门窗通风')
                  .fontSize(14)
                  .fontColor('#333')
                  .alignSelf(ItemAlign.Start)

                Text('2. 切断可能的气源')
                  .fontSize(14)
                  .fontColor('#333')
                  .alignSelf(ItemAlign.Start)

                Text('3. 避免使用明火或电器')
                  .fontSize(14)
                  .fontColor('#333')
                  .alignSelf(ItemAlign.Start)

                Text('4. 必要时撤离现场并联系专业人员')
                  .fontSize(14)
                  .fontColor('#333')
                  .alignSelf(ItemAlign.Start)
              }
              .width('100%')
              .backgroundColor('#FFEBEE')
              .padding(10)
              .borderRadius(8)
              .animation({
                duration: 1000,
                tempo: 1.0,
                iterations: -1,
                playMode: PlayMode.Alternate
              })
            }

            Divider().color('#EEEEEE').height(1).margin({ top: 10, bottom: 10 })

            Row() {
              Text('最后更新:')
                .fontSize(12)
                .fontColor('#666')

              Text(this.lastUpdateTime)
                .fontSize(12)
                .fontColor('#666')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
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
    .backgroundColor('#F5F7FA')
  }
}