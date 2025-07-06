import { MqttAsync, MqttClient, MqttMessage } from '@ohos/mqtt';
import { MQTT_URL } from '../constants/Constant';

export default class MQTTUtil {
  private mqttAsyncClient: MqttClient | null = null;

  async connect(callback: (err: Error, data: MqttMessage) => void) {

    //1、实例化MqttClient
    this.mqttAsyncClient = MqttAsync.createMqtt({
      url: MQTT_URL,
      clientId: 'harmonyos_gyz',
      persistenceType: 1,
    });

    //2、连接
    let isConnect = await this.mqttAsyncClient.connect(
      {
        userName: "admin",
        password: "admin",
        connectTimeout: 300
      }
    );
    if (!isConnect) {
      return;
    }

    //3、设置回调
    this.mqttAsyncClient.messageArrived(callback)

    //4、订阅主题ems
    this.mqttAsyncClient.subscribe({
      topic: 'ems',
      qos: 2
    })
    
    //5、订阅烟雾报警主题
    this.mqttAsyncClient.subscribe({
      topic: 'smoke_alarm',
      qos: 2
    })
  }
}