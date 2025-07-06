import router from '@ohos.router';
import { MqttMessage } from '@ohos/mqtt';
import MQTTUtil from '../common/utils/MQTTUtil';
import EnvironmentViewModel from '../viewmodel/EnvironmentViewModel';
import { CellComponent } from '../view/CellComponent';
import { StatusArray } from '../common/constants/Constant';

// 定义MQTT负载接口
interface MQTTPayload {
  temp?: number;
  hum?: number;
  gas?: number;
}

@Entry
@Component
struct EnvironmentInfoPage {
  @State item: EnvironmentViewModel = new EnvironmentViewModel();

  aboutToAppear(): void {
    // 确保MQTTUtil是可构造的类
    const mqttUtil = new MQTTUtil();

    mqttUtil.connect(
      (err: Error | null, data: MqttMessage | null) => {
        if (err) {
          console.error('MQTT错误:', err);
          return;
        }

        if (!data || !data.payload) {
          console.warn('收到空MQTT消息');
          return;
        }

        try {
          console.info('收到MQTT消息: ' + String(data.payload));
          console.info('主题: ' + data.topic);

          if (data.topic === 'ems') {
            // 使用类型安全的解析
            const payload: MQTTPayload = JSON.parse(String(data.payload));

            // 更新状态变量
            this.item.temp = payload.temp ?? 0;
            this.item.hum = payload.hum ?? 0;
            this.item.gas = payload.gas ?? 0;

            // 根据气体浓度设置安全级别
            if (this.item.gas < 100) this.item.stat = 0; // 安全
            else if (this.item.gas < 200) this.item.stat = 1; // 警告
            else this.item.stat = 2; // 危险
          }
        } catch (e) {
          console.error('解析MQTT消息失败:', e);
        }
      }
    );
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => router.back())

        Text('室内环境监测')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')

        Blank()
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')

      // 主要内容区域
      Scroll() {
        Column({ space: 20 }) {
          // 环境卡片
          Column() {
            // 顶部标题和状态指示
            Row() {
              Text('室内环境参数')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')

              Blank()

              Row() {
                Text('状态：')
                  .fontSize(16)
                  .fontColor('#666')

                Text(StatusArray[this.item.stat])
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.item.stat === 0 ? '#4CAF50' :
                    this.item.stat === 1 ? '#FF9800' : '#F44336')
              }
            }
            .width('100%')
            .padding({ bottom: 16 })

            // 数据显示
            Column() {
              CellComponent({
                title: "空气温度：",
                value: `${this.item.temp} °C`,
                color: this.getTextColor(this.item.stat)
              })

              // 使用Row替代Line组件
              Row()
                .width('94%')
                .height(1)
                .backgroundColor('#E0E0E0')
                .margin({ top: 8, bottom: 8 })

              CellComponent({
                title: "空气湿度：",
                value: `${this.item.hum} %`,
                color: this.getTextColor(this.item.stat)
              })

              // 使用Row替代Line组件
              Row()
                .width('94%')
                .height(1)
                .backgroundColor('#E0E0E0')
                .margin({ top: 8, bottom: 8 })

              CellComponent({
                title: "可燃气体：",
                value: `${this.item.gas} PPM`,
                color: this.getTextColor(this.item.stat)
              })
            }
            .backgroundColor(this.getCardColor(this.item.stat))
            .padding(16)
            .borderRadius(12)
            .width('100%')
          }
          .width('90%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })

          // 提示卡片
          Column() {
            Text('环境提示')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 12 })

            Text(this.getEnvironmentTips())
              .fontSize(16)
              .fontColor('#333')
              .lineHeight(24)
              .margin({ bottom: 8 })

            if (this.item.stat > 0) {
              Text('安全建议')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .alignSelf(ItemAlign.Start)
                .margin({ top: 12, bottom: 8 })

              Text(this.getSafetyTips())
                .fontSize(16)
                .fontColor('#333')
                .lineHeight(24)
            }
          }
          .width('90%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
          .margin({ bottom: 20 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 20, bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }

  // 获取卡片背景色
  private getCardColor(status: number): string {
    switch (status) {
      case 0:
        return '#E8F5E9'; // 安全-浅绿色
      case 1:
        return '#FFF3E0'; // 警告-浅橙色
      case 2:
        return '#FFEBEE'; // 危险-浅红色
      default:
        return '#F5F5F5'; // 未知-浅灰色
    }
  }
  
  // 获取文字颜色
  private getTextColor(status: number): Color {
    switch (status) {
      case 0:
        return Color.Green; // 安全-深绿色
      case 1:
        return Color.Orange; // 警告-深橙色
      case 2:
        return Color.Red; // 危险-深红色
      default:
        return Color.Gray; // 未知-深灰色
    }
  }


  // 获取环境提示
  private getEnvironmentTips(): string {
    if (this.item.stat === 0) {
      return `当前室内环境良好。\n温度${this.item.temp}°C，湿度${this.item.hum}%，气体浓度${this.item.gas} PPM，均在安全范围内。`;
    } else if (this.item.stat === 1) {
      return `注意！室内环境出现异常。\n温度${this.item.temp}°C，湿度${this.item.hum}%，气体浓度${this.item.gas} PPM，气体浓度略高，请注意通风。`;
    } else {
      return `警告！室内环境可能存在危险。\n温度${this.item.temp}°C，湿度${this.item.hum}%，气体浓度${this.item.gas} PPM，气体浓度已超过安全阈值，请立即采取措施！`;
    }
  }

  // 获取安全建议
  private getSafetyTips(): string {
    if (this.item.stat === 1) {
      return '1. 开窗通风，增加室内空气流通\n2. 检查燃气设备是否关闭\n3. 短时间内如情况没有改善，请考虑离开房间';
    } else if (this.item.stat === 2) {
      return '1. 立即打开所有窗户通风\n2. 关闭所有可能的气源\n3. 迅速离开房间\n4. 如有必要，请拨打紧急电话求助';
    }
    return '';
  }
}