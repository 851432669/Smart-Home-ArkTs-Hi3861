import { MqttAsync, MqttClient, MqttMessage, MqttResponse } from '@ohos/mqtt';
import { MQTT_URL } from '../constants/Constant';

export default class MQTTUtil {
  private mqttAsyncClient: MqttClient | null = null;
  private static instance: MQTTUtil | null = null;
  private isConnecting: boolean = false;
  private isConnected: boolean = false;
  private reconnectTimer: number = -1;
  private messageCallback: ((err: Error, data: MqttMessage) => void) | null = null;
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number = 5;
  private reconnectDelay: number = 1000; // 初始重连延迟1秒

  // 单例模式获取实例
  public static getInstance(): MQTTUtil {
    if (!MQTTUtil.instance) {
      MQTTUtil.instance = new MQTTUtil();
    }
    return MQTTUtil.instance;
  }

  // 检查连接状态
  public isClientConnected(): boolean {
    // 如果标记为已连接但客户端为null，修正状态
    if (this.isConnected && this.mqttAsyncClient === null) {
      this.isConnected = false;
      return false;
    }
    return this.isConnected && this.mqttAsyncClient !== null;
  }

  // 保存最后一个回调函数，用于重连时恢复
  private saveCallback(callback: (err: Error, data: MqttMessage) => void): void {
    this.messageCallback = callback;
  }

  // 重置重连计数器
  private resetReconnectAttempts(): void {
    this.reconnectAttempts = 0;
    this.reconnectDelay = 1000;
    if (this.reconnectTimer !== -1) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = -1;
    }
  }

  // 计算指数退避重连延迟
  private getNextReconnectDelay(): number {
    // 指数退避算法，最大延迟30秒
    const delay = Math.min(30000, this.reconnectDelay * Math.pow(1.5, this.reconnectAttempts));
    return delay;
  }

  async connect(callback: (err: Error, data: MqttMessage) => void) {
    // 保存回调函数以便重连时使用
    this.saveCallback(callback);
    
    // 如果已经在连接中，则不重复连接
    if (this.isConnecting) {
      console.info('MQTT连接正在进行中，请稍后再试');
      return;
    }

    // 如果已经连接，则直接返回
    if (this.isConnected && this.mqttAsyncClient) {
      console.info('MQTT已经连接，无需重复连接');
      // 重新设置回调
      this.mqttAsyncClient.messageArrived(callback);
      return;
    }

    this.isConnecting = true;
    console.info('开始建立MQTT连接...');

    try {
      // 如果客户端为null，重新创建
      if (!this.mqttAsyncClient) {
        //1、实例化MqttClient
        this.mqttAsyncClient = MqttAsync.createMqtt({
          url: MQTT_URL,
          clientId: 'harmonyos_gyz_' + Date.now(), // 添加时间戳避免客户端ID冲突
          persistenceType: 1,
        });
      }

      if (!this.mqttAsyncClient) {
        console.error('MQTT客户端创建失败');
        this.isConnecting = false;
        this.scheduleReconnect();
        return;
      }

      //2、连接
      let isConnect = await this.mqttAsyncClient.connect(
        {
          userName: "admin",
          password: "admin",
          connectTimeout: 300,
          cleanSession: true // 确保清除之前的会话
        }
      );

      if (!isConnect) {
        console.error('MQTT连接失败');
        this.isConnected = false;
        this.isConnecting = false;
        this.scheduleReconnect();
        return;
      }

      this.isConnected = true;
      this.resetReconnectAttempts(); // 连接成功，重置重连计数
      console.info('MQTT连接成功');

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

      //6、订阅设备状态反馈主题
      this.mqttAsyncClient.subscribe({
        topic: 'device_status',
        qos: 2
      })
      
      //7、订阅LED控制反馈主题
      this.mqttAsyncClient.subscribe({
        topic: 'led_status',
        qos: 2
      })
    } catch (error) {
      console.error(`MQTT连接异常: ${JSON.stringify(error)}`);
      this.isConnected = false;
      this.scheduleReconnect();
    } finally {
      this.isConnecting = false;
    }
  }
  
  // 安排自动重连
  private scheduleReconnect(): void {
    // 如果已达到最大重连次数，停止重连
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error(`已达到最大重连次数(${this.maxReconnectAttempts})，停止重连`);
      return;
    }
    
    // 清除可能存在的定时器
    if (this.reconnectTimer !== -1) {
      clearTimeout(this.reconnectTimer);
    }
    
    // 计算下次重连延迟
    const delay = this.getNextReconnectDelay();
    this.reconnectAttempts++;
    
    console.info(`安排MQTT重连，第${this.reconnectAttempts}次尝试，延迟${delay}ms`);
    
    // 设置重连定时器
    this.reconnectTimer = setTimeout(() => {
      console.info('执行MQTT重连...');
      if (this.messageCallback) {
        this.connect(this.messageCallback);
      } else {
        this.connect((err, data) => {
          if (!err) {
            console.info(`重连后收到消息: ${data.topic}, ${data.payload}`);
          }
        });
      }
    }, delay);
  }
  
  /**
   * 发布消息到指定主题
   * @param topic 主题
   * @param message 消息内容
   * @returns 发布是否成功
   */
  async publishMessage(topic: string, message: string): Promise<boolean> {
    // 检查连接状态，如果未连接则尝试重连
    if (!this.isClientConnected()) {
      console.warn('MQTT客户端未连接，尝试重新连接...');
      try {
        // 使用保存的回调进行重连
        if (this.messageCallback) {
          await this.connect(this.messageCallback);
        } else {
          // 使用默认回调进行重连
          await this.connect((err, data) => {
            if (!err) {
              console.info(`重连后收到消息: ${data.topic}, ${data.payload}`);
            }
          });
        }
        
        // 等待短暂时间确保连接完成
        await new Promise<void>((resolve) => setTimeout(resolve, 500));
        
        // 如果重连后仍然未连接，则返回失败
        if (!this.isClientConnected()) {
          console.error('MQTT重连失败，无法发送消息');
          return false;
        }
      } catch (error) {
        console.error(`MQTT重连异常: ${JSON.stringify(error)}`);
        return false;
      }
    }
    
    // 再次确认客户端不为null
    if (!this.mqttAsyncClient) {
      console.error('MQTT客户端为null，无法发送消息');
      return false;
    }
    
    try {
      console.info(`准备发送MQTT消息: topic=${topic}, message=${message}`);
      
      // 发布消息
      const response = await this.mqttAsyncClient.publish({
        topic: topic,
        payload: message,
        qos: 1,
        retained: false
      });
      
      // 检查response是否有效
      if (!response) {
        console.error('MQTT消息发布失败: 收到无效的响应');
        this.isConnected = false; // 标记连接状态为断开，下次将尝试重连
        return false;
      }
      
      console.info(`MQTT消息发布成功: topic=${topic}`);
      return true;
    } catch (error) {
      console.error(`MQTT消息发布异常: ${JSON.stringify(error)}`);
      this.isConnected = false; // 标记连接状态为断开
      // 发生错误时安排重连
      this.scheduleReconnect();
      return false;
    }
  }

  // 断开连接
  async disconnect(): Promise<boolean> {
    // 清除重连定时器
    if (this.reconnectTimer !== -1) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = -1;
    }
    
    if (!this.mqttAsyncClient || !this.isConnected) {
      console.info('MQTT客户端未连接，无需断开');
      this.isConnected = false;
      return true;
    }

    try {
      await this.mqttAsyncClient.disconnect();
      this.isConnected = false;
      console.info('MQTT连接已断开');
      return true;
    } catch (error) {
      console.error(`MQTT断开连接异常: ${JSON.stringify(error)}`);
      this.isConnected = false; // 无论如何都标记为已断开
      return false;
    }
  }
}