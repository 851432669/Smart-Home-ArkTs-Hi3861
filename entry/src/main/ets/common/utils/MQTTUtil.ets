import { MqttAsync, MqttClient, MqttMessage, MqttResponse } from '@ohos/mqtt';
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

    //4、订阅主题ems，用于接收环境数据
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
  
  /**
   * 发布消息到指定主题
   * @param topic 主题
   * @param message 消息内容
   * @returns 发布是否成功
   */
  async publishMessage(topic: string, message: string): Promise<boolean> {
    if (!this.mqttAsyncClient) {
      console.error('MQTT客户端未连接');
      return false;
    }
    
    try {
      // 发布消息
      const response = await this.mqttAsyncClient.publish({
        topic: topic,
        payload: message,
        qos: 1,
        retained: false // 修改retain为retained
      });
      
      // 检查response是否有效，根据实际API返回类型修改判断条件
      const result = !!response;
      console.info(`MQTT消息发布${result ? '成功' : '失败'}: topic=${topic}, message=${message}`);
      return result;
    } catch (error) {
      console.error(`MQTT消息发布异常: ${JSON.stringify(error)}`);
      return false;
    }
  }
}