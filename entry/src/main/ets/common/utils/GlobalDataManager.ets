import EnvironmentViewModel from '../../viewmodel/EnvironmentViewModel';

// 定义环境数据项接口
export interface EnvironmentDataItem {
  id: number;
  name: string;
  icon: Resource;
  status: string;
  unit: string;
  weatherIcon?: Resource;
}

// 设备状态接口
export interface DeviceStatus {
  id: string;
  name: string;
  isOn: boolean;
  temperature?: number; // 适用于空调
  level?: number; // 适用于可调节设备
}

// 用户信息接口
export interface UserInfo {
  nickname: string;
  account: string;
  isVerified: boolean;
  roomCount: number;
}

class GlobalDataManager {
  // 环境数据
  private environmentData: EnvironmentDataItem[] = [
    {
      id: 0,
      name: '天气',
      icon: $r('app.media.weather'),
      status: '加载中',
      unit: '',
      weatherIcon: $r('app.media.sunny')
    },
    {
      id: 1,
      name: '温度',
      icon: $r('app.media.tem'),
      status: '--',
      unit: '℃'
    },
    {
      id: 2,
      name: '湿度',
      icon: $r('app.media.humidity'),
      status: '--',
      unit: '%'
    },
    {
      id: 3,
      name: 'PM2.5',
      icon: $r('app.media.pm25_o'),
      status: '--',
      unit: ''
    },
  ];

  // 设备状态数据 - 确保初始状态与UI一致
  private deviceStatus: DeviceStatus[] = [
    {
      id: 'ac',
      name: '空调',
      isOn: false,  // 默认改为关闭
      temperature: 26
    },
    {
      id: 'livingRoomLight',
      name: '客厅灯',
      isOn: false  // 默认改为关闭
    },
    {
      id: 'tv',
      name: '电视',
      isOn: false  // 默认改为关闭
    },
    {
      id: 'curtain',
      name: '窗帘',
      isOn: false  // 默认改为关闭
    },
    {
      id: 'robot',
      name: '扫地机',
      isOn: false  // 默认为关闭
    },
    {
      id: 'audio',
      name: '音响',
      isOn: false  // 默认改为关闭
    }
  ];

  // 用户信息数据
  private userInfo: UserInfo = {
    nickname: '测试用户',
    account: '5678910',
    isVerified: true,
    roomCount: 1
  };

  // 数据是否已加载标志
  private isDataLoaded: boolean = false;

  // 获取环境数据
  getEnvironmentData(): EnvironmentDataItem[] {
    return this.environmentData;
  }

  // 设置环境数据
  setEnvironmentData(data: EnvironmentDataItem[]): void {
    this.environmentData = data;
    this.isDataLoaded = true;
  }

  // 初始化设备状态 - 将所有设备设为关闭状态
  initializeDeviceStatus(): void {
    console.info('初始化所有设备为关闭状态');
    // 遍历设备，将所有设备设为关闭状态
    this.deviceStatus.forEach(device => {
      device.isOn = false;
    });
  }

  // 获取所有设备状态
  getDeviceStatus(): DeviceStatus[] {
    return this.deviceStatus;
  }

  // 获取单个设备状态
  getDeviceById(deviceId: string): DeviceStatus | undefined {
    return this.deviceStatus.find(device => device.id === deviceId);
  }

  // 获取用户信息
  getUserInfo(): UserInfo {
    return this.userInfo;
  }

  // 更新用户昵称
  updateUserNickname(nickname: string): void {
    if (nickname && nickname.trim().length > 0) {
      this.userInfo.nickname = nickname.trim();
      console.info(`用户昵称已更新为: ${nickname}`);
    }
  }

  // 更新用户账号
  updateUserAccount(account: string): void {
    if (account && account.trim().length > 0) {
      this.userInfo.account = account.trim();
    }
  }

  // 更新用户认证状态
  updateUserVerificationStatus(isVerified: boolean): void {
    this.userInfo.isVerified = isVerified;
  }

  // 更新房间数量
  updateRoomCount(count: number): void {
    if (count >= 0) {
      this.userInfo.roomCount = count;
    }
  }

  // 获取家庭名称
  getHomeName(): string {
    return `${this.userInfo.nickname}的家`;
  }

  // 设置单个设备状态
  setDeviceStatus(deviceId: string, isOn: boolean): void {
    const device = this.deviceStatus.find(device => device.id === deviceId);
    if (device) {
      device.isOn = isOn;
    }
  }

  // 批量更新设备状态 - 用于场景模式
  updateDevicesForScene(scene: string): void {
    if (scene === 'leaveHome') {
      // 离家模式：关闭所有设备，只开启扫地机
      this.setDeviceStatus('ac', false);         // 关闭空调
      this.setDeviceStatus('livingRoomLight', false); // 关闭客厅灯
      this.setDeviceStatus('tv', false);         // 关闭电视
      this.setDeviceStatus('curtain', false);    // 关闭窗帘
      this.setDeviceStatus('audio', false);      // 关闭音响
      this.setDeviceStatus('robot', true);       // 开启扫地机
    }
    // 可以添加其他场景...
  }

  // 检查数据是否已加载
  isLoaded(): boolean {
    return this.isDataLoaded;
  }

  // 预加载天气数据
  async preloadWeatherData(): Promise<void> {
    // 避免重复加载
    if (this.isDataLoaded) {
      console.info('天气数据已预加载，跳过');
      return;
    }

    console.info('开始预加载天气数据...');
    const LOCATION_ID = '101230201'; // 厦门
    const viewModel = new EnvironmentViewModel();
    
    // 添加重试机制
    for (let attempts = 0; attempts < 3; attempts++) {
      try {
        // 设置超时
        const timeoutPromise = new Promise<void>((_, reject) => {
          setTimeout(() => reject(new Error('获取天气数据超时')), 5000);
        });
        
        // 使用Promise.race进行超时控制
        await Promise.race<Promise<void>>([
          viewModel.fetchWeather(LOCATION_ID),
          timeoutPromise
        ]);
        
        // 更新环境数据
        this.environmentData = [
          {
            id: 0,
            name: '天气',
            icon: $r('app.media.weather'),
            status: viewModel.weather || '晴',
            unit: '',
            weatherIcon: viewModel.getWeatherIcon() || $r('app.media.sunny')
          },
          {
            id: 1,
            name: '温度',
            icon: $r('app.media.tem'),
            status: `${viewModel.temp || 25}`,
            unit: '℃'
          },
          {
            id: 2,
            name: '湿度',
            icon: $r('app.media.humidity'),
            status: `${viewModel.hum || 60}`,
            unit: '%'
          },
          {
            id: 3,
            name: 'PM2.5',
            icon: $r('app.media.pm25_o'),
            status: '4',
            unit: ''
          },
        ];
        
        this.isDataLoaded = true;
        console.info('天气数据预加载完成');
        return;
        
      } catch (err) {
        console.error(`天气数据预加载失败(尝试 ${attempts + 1}/3):`, JSON.stringify(err));
        
        // 最后一次尝试失败时，使用默认值
        if (attempts === 2) {
          console.info('使用默认天气数据');
          this.environmentData = [
            {
              id: 0,
              name: '天气',
              icon: $r('app.media.weather'),
              status: '晴',
              unit: '',
              weatherIcon: $r('app.media.sunny')
            },
            {
              id: 1,
              name: '温度',
              icon: $r('app.media.tem'),
              status: '25',
              unit: '℃'
            },
            {
              id: 2,
              name: '湿度',
              icon: $r('app.media.humidity'),
              status: '60',
              unit: '%'
            },
            {
              id: 3,
              name: 'PM2.5',
              icon: $r('app.media.pm25_o'),
              status: '4',
              unit: ''
            },
          ];
          
          this.isDataLoaded = true; // 即使用默认值也标记为已加载
        }
        
        // 非最后一次尝试，等待1秒后重试
        if (attempts < 2) {
          await new Promise<void>(resolve => setTimeout(resolve, 1000));
        }
      }
    }
  }
}

// 创建全局单例实例
export const globalDataManager = new GlobalDataManager(); 
