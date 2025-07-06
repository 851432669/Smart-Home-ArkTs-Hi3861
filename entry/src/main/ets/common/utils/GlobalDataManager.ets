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
