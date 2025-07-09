import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { EnvMonitorPage } from './EnvMonitorPage'
import { SmartPage } from './SmartPage'
import { ProfilePage } from './ProfilePage'
import EnvironmentViewModel from '../viewmodel/EnvironmentViewModel'
import { globalDataManager, EnvironmentDataItem, DeviceStatus } from '../common/utils/GlobalDataManager';

// 定义路由参数接口
interface RouterParams {
  refreshFlag?: number;
}

// 定义接口类型
interface TabItem {
  id: number,
  name: string,
  icon: Resource,
  selectedIcon: Resource
}

interface RoomItem {
  id: number,
  name: string,
  isSelected: boolean
}

// 自定义添加房间对话框
@CustomDialog
struct RoomAddDialog {
  controller: CustomDialogController
  @State roomName: string = ''
  onConfirm: (roomName: string) => void = () => {}
  
  build() {
    Column() {
      Text('添加房间')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 15, bottom: 15 })
      
      TextInput({ placeholder: '请输入房间名称' })
        .width('90%')
        .height(50)
        .onChange((value: string) => {
          this.roomName = value
        })
        .margin({ bottom: 20 })
      
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .onClick(() => {
            this.controller.close()
          })
          .backgroundColor('#f5f5f5')
          .fontColor('#666666')
          .width('40%')
          .height(40)
        
        Button('确定')
          .onClick(() => {
            if (this.roomName && this.roomName.trim().length > 0) {
              this.onConfirm(this.roomName.trim())
              this.controller.close()
            } else {
              promptAction.showToast({
                message: '房间名称不能为空',
                duration: 2000
              })
            }
          })
          .backgroundColor('#1890ff')
          .fontColor(Color.White)
          .width('40%')
          .height(40)
      }
      .width('90%')
    }
    .width('80%')
    .padding({ top: 20, bottom: 20 })
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}

interface DeviceItem {
  id: number,
  name: string,
  icon: Resource,
  status: string,
  value?: string,
  unit?: string,
  isOn?: boolean,
  weather?: string,
  weatherIcon?: Resource
}

@Entry
@Component
struct MainPage {
  @State currentTab: number = 0
  @State tabs: TabItem[] = [
    {
      id: 0,
      name: '首页',
      icon: $r('app.media.index1_unused'),
      selectedIcon: $r('app.media.index1_used')
    },
    {
      id: 1,
      name: '智能',
      icon: $r('app.media.index2_unused'),
      selectedIcon: $r('app.media.index2_used')
    },
    {
      id: 2,
      name: '评估',
      icon: $r('app.media.index3_unused'),
      selectedIcon: $r('app.media.index3_used')
    },
    {
      id: 3,
      name: '我的',
      icon: $r('app.media.user1_unused'),
      selectedIcon: $r('app.media.user1_used')
    }
  ]

  @State rooms: RoomItem[] = [
    { id: 0, name: '全屋', isSelected: true },
    { id: 1, name: '客厅', isSelected: false },
    { id: 2, name: '卫生间', isSelected: false },
    { id: 3, name: '厨房', isSelected: false },
    { id: 4, name: '阳台', isSelected: false }
  ]

  @State environmentData: EnvironmentDataItem[] = [
    { id: 0, name: '天气', icon: $r('app.media.tem'), status: '31.0', unit: '℃' },
    { id: 1, name: '湿度', icon: $r('app.media.humidity'), status: '65', unit: '%' },
    { id: 2, name: 'PM2.5', icon: $r('app.media.pm25_o'), status: '4', unit: '' },
  ]

  @State devices: DeviceItem[] = [
    { id: 0, name: '客厅灯', icon: $r('app.media.light'), status: '关闭', isOn: false },
    { id: 1, name: '空调', icon: $r('app.media.ac'), status: '关闭', isOn: false, value: '26' },
    { id: 2, name: '电视', icon: $r('app.media.tv'), status: '关闭', isOn: false },
    { id: 3, name: '窗帘', icon: $r('app.media.curtain'), status: '关闭', isOn: false },
    { id: 4, name: '音响', icon: $r('app.media.audio'), status: '关闭', isOn: false },
    { id: 5, name: '扫地机器人', icon: $r('app.media.sweep'), status: '关闭', isOn: false }
  ]

  // 添加一个辅助的触发刷新的变量
  @State refreshTrigger: number = 0

    // 接收路由参数
  @State params: RouterParams = {};
  
  // 添加定时器ID，用于实时检查设备状态更新
  private timerId: number = -1;

  // 添加房间名称状态
  @State newRoomName: string = '';

  // 添加房间对话框控制器
  private addRoomDialogController: CustomDialogController = new CustomDialogController({
    builder: RoomAddDialog({
      onConfirm: this.handleAddRoom.bind(this)
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  // 处理添加房间
  handleAddRoom(roomName: string) {
    if (roomName && roomName.trim() !== '') {
      // 添加新房间
      if(globalDataManager.addRoom(roomName)) {
        // 同步房间列表
        this.syncRoomsWithGlobalState();
        // 更新UI
        this.refreshTrigger = (this.refreshTrigger + 1) % 1000;
        
        // 显示成功提示
        promptAction.showToast({
          message: `成功添加房间：${roomName}`,
          duration: 2000
        });
      } else {
        promptAction.showToast({
          message: '房间已存在或名称无效',
          duration: 2000
        });
      }
    }
  }

  // 初始化，合并了两个aboutToAppear函数
  aboutToAppear() {
    // 初始触发刷新
    this.refreshTrigger = 1;
    
    // 同步全局设备状态
    this.syncDevicesWithGlobalState();
    
    // 同步全局房间列表状态
    this.syncRoomsWithGlobalState();
    
    // 直接使用全局数据管理器中的数据
    this.environmentData = globalDataManager.getEnvironmentData();

    // 如果数据未预加载成功(极少情况)，尝试重新加载
    if (!globalDataManager.isLoaded()) {
      console.info('天气数据未预加载，尝试重新获取');

      const LOCATION_ID = '101230201'; // 厦门
      const viewModel = new EnvironmentViewModel();

      viewModel.fetchWeather(LOCATION_ID).then(() => {
        const data: EnvironmentDataItem[] = [
          {
            id: 0,
            name: '天气',
            icon: $r('app.media.weather'),
            status: viewModel.weather,
            unit: '',
            weatherIcon: viewModel.getWeatherIcon()
          },
          {
            id: 1,
            name: '温度',
            icon: $r('app.media.tem'),
            status: `${viewModel.temp}`,
            unit: '℃'
          },
          {
            id: 2,
            name: '湿度',
            icon: $r('app.media.humidity'),
            status: `${viewModel.hum}`,
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

        // 更新数据并保存到全局管理器
        this.environmentData = data;
        globalDataManager.setEnvironmentData(data);

        // 触发UI刷新
        this.refreshTrigger = (this.refreshTrigger + 1) % 1000;
      }).catch((err: Error) => {
        console.error("获取天气数据失败", err.message);
      });
    }
    
    // 添加实时设备状态检查
    this.startDeviceStatusMonitor();
  }
  
  // 组件销毁时清除定时器
  aboutToDisappear() {
    this.stopDeviceStatusMonitor();
  }
  
  // 开始监控设备状态变化
  startDeviceStatusMonitor() {
    // 清除可能存在的定时器
    this.stopDeviceStatusMonitor();
    
    // 每秒检查一次设备状态变化
    this.timerId = setInterval(() => {
      // 检查设备状态是否有变化
      const anyDeviceChanged = this.checkDeviceStatusChanges();
      if (anyDeviceChanged) {
        console.info('检测到设备状态变化，正在更新UI...');
        // 如果有变化，同步状态并刷新UI
        this.syncDevicesWithGlobalState();
      }
    }, 1000);
    
    console.info('已启动设备状态监控');
  }
  
  // 停止监控设备状态
  stopDeviceStatusMonitor() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
      console.info('已停止设备状态监控');
    }
  }
  
  // 检查设备状态是否有变化
  checkDeviceStatusChanges(): boolean {
    // 获取全局设备状态
    const globalLightStatus = globalDataManager.getDeviceById('livingRoomLight')?.isOn;
    const globalACStatus = globalDataManager.getDeviceById('ac')?.isOn;
    const globalTVStatus = globalDataManager.getDeviceById('tv')?.isOn;
    const globalCurtainStatus = globalDataManager.getDeviceById('curtain')?.isOn;
    const globalAudioStatus = globalDataManager.getDeviceById('audio')?.isOn;
    const globalRobotStatus = globalDataManager.getDeviceById('robot')?.isOn;
    
    // 查找本地设备状态
    const localLightDevice = this.devices.find(d => d.name === '客厅灯');
    const localACDevice = this.devices.find(d => d.name === '空调');
    const localTVDevice = this.devices.find(d => d.name === '电视');
    const localCurtainDevice = this.devices.find(d => d.name === '窗帘');
    const localAudioDevice = this.devices.find(d => d.name === '音响');
    const localRobotDevice = this.devices.find(d => d.name === '扫地机器人');
    
    // 检查是否有状态不一致
    if (globalLightStatus !== undefined && localLightDevice && globalLightStatus !== localLightDevice.isOn) return true;
    if (globalACStatus !== undefined && localACDevice && globalACStatus !== localACDevice.isOn) return true;
    if (globalTVStatus !== undefined && localTVDevice && globalTVStatus !== localTVDevice.isOn) return true;
    if (globalCurtainStatus !== undefined && localCurtainDevice && globalCurtainStatus !== localCurtainDevice.isOn) return true;
    if (globalAudioStatus !== undefined && localAudioDevice && globalAudioStatus !== localAudioDevice.isOn) return true;
    if (globalRobotStatus !== undefined && localRobotDevice && globalRobotStatus !== localRobotDevice.isOn) return true;
    
    return false;
  }

  // 强制刷新函数
  forceRefresh() {
    console.info('正在强制刷新设备状态...');
    
    // 强制覆盖本地设备状态
    this.devices = [
      { 
        id: 0, 
        name: '客厅灯', 
        icon: $r('app.media.light'), 
        status: globalDataManager.getDeviceById('livingRoomLight')?.isOn ? '开启' : '关闭', 
        isOn: globalDataManager.getDeviceById('livingRoomLight')?.isOn || false 
      },
      { 
        id: 1, 
        name: '空调', 
        icon: $r('app.media.ac'), 
        status: globalDataManager.getDeviceById('ac')?.isOn ? '26℃' : '关闭', 
        isOn: globalDataManager.getDeviceById('ac')?.isOn || false,
        value: '26' 
      },
      { 
        id: 2, 
        name: '电视', 
        icon: $r('app.media.tv'), 
        status: globalDataManager.getDeviceById('tv')?.isOn ? '开启' : '关闭', 
        isOn: globalDataManager.getDeviceById('tv')?.isOn || false 
      },
      { 
        id: 3, 
        name: '窗帘', 
        icon: $r('app.media.curtain'), 
        status: globalDataManager.getDeviceById('curtain')?.isOn ? '开启' : '关闭', 
        isOn: globalDataManager.getDeviceById('curtain')?.isOn || false 
      },
      { 
        id: 4, 
        name: '音响', 
        icon: $r('app.media.audio'), 
        status: globalDataManager.getDeviceById('audio')?.isOn ? '开启' : '关闭', 
        isOn: globalDataManager.getDeviceById('audio')?.isOn || false 
      },
      { 
        id: 5, 
        name: '扫地机器人', 
        icon: $r('app.media.sweep'), 
        status: globalDataManager.getDeviceById('robot')?.isOn ? '开启' : '关闭', 
        isOn: globalDataManager.getDeviceById('robot')?.isOn || false 
      }
    ];
    
    console.info('设备状态已强制更新，客厅灯状态：' + (this.devices[0].isOn ? '开启' : '关闭'));
    console.info('设备状态已强制更新，扫地机状态：' + (this.devices[5].isOn ? '开启' : '关闭'));
    
    // 触发UI更新
    this.refreshTrigger = (this.refreshTrigger + 1) % 1000;
  }

  // 从全局状态同步设备数据到本地状态
  syncDevicesWithGlobalState() {
    console.info('同步设备状态到UI...');
    const globalDevices = globalDataManager.getDeviceStatus();
    
    // 更新本地设备状态
    this.devices = this.devices.map(device => {
      if (device.name === '客厅灯') {
        const globalDevice = globalDataManager.getDeviceById('livingRoomLight');
        if (globalDevice) {
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            isOn: globalDevice.isOn,
            status: globalDevice.isOn ? '开启' : '关闭'
          };
        }
      } 
      else if (device.name === '空调') {
        const globalDevice = globalDataManager.getDeviceById('ac');
        if (globalDevice) {
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            isOn: globalDevice.isOn,
            status: globalDevice.isOn ? `${device.value}℃` : '关闭',
            value: device.value
          };
        }
      }
      else if (device.name === '电视') {
        const globalDevice = globalDataManager.getDeviceById('tv');
        if (globalDevice) {
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            isOn: globalDevice.isOn,
            status: globalDevice.isOn ? '开启' : '关闭'
          };
        }
      }
      else if (device.name === '窗帘') {
        const globalDevice = globalDataManager.getDeviceById('curtain');
        if (globalDevice) {
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            isOn: globalDevice.isOn,
            status: globalDevice.isOn ? '开启' : '关闭'
          };
        }
      }
      else if (device.name === '音响') {
        const globalDevice = globalDataManager.getDeviceById('audio');
        if (globalDevice) {
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            isOn: globalDevice.isOn,
            status: globalDevice.isOn ? '开启' : '关闭'
          };
        }
      }
      else if (device.name === '扫地机器人') {
        const globalDevice = globalDataManager.getDeviceById('robot');
        if (globalDevice) {
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            isOn: globalDevice.isOn,
            status: globalDevice.isOn ? '开启' : '关闭'
          };
        }
      }
      // 其他设备不变
      return device;
    });
    
    // 触发UI更新
    this.refreshTrigger = (this.refreshTrigger + 1) % 1000;
    console.info(`设备状态已更新，refreshTrigger = ${this.refreshTrigger}`);
  }

  // 从全局状态同步房间列表到本地状态
  syncRoomsWithGlobalState() {
    console.info('开始同步房间列表到UI...');
    
    try {
      // 获取全局房间列表
      const globalRooms = globalDataManager.getRooms();
      console.info(`获取到全局房间列表，房间数量: ${globalRooms.length}`);
      
      // 保存当前选中的房间ID
      const selectedRoomId = this.rooms.find(room => room.isSelected)?.id || 0;
      console.info(`当前选中的房间ID: ${selectedRoomId}`);
      
      // 更新本地房间列表，保持选中状态
      this.rooms = globalRooms.map(room => {
        return {
          id: room.id,
          name: room.name,
          isSelected: room.id === selectedRoomId
        } as RoomItem;
      });
      
      // 输出新房间列表
      let roomNames = this.rooms.map(room => room.name).join(', ');
      console.info(`房间列表已更新，当前房间: [${roomNames}]，总数：${this.rooms.length}`);
    } catch (error) {
      console.error(`同步房间列表失败: ${JSON.stringify(error)}`);
    }
  }

  // 每次页面显示时执行
  onPageShow() {
    console.info('MainPage - 页面显示，正在同步最新数据...');
    // 同步设备状态
    this.syncDevicesWithGlobalState();
    
    // 同步房间列表状态
    this.syncRoomsWithGlobalState();
    
    // 强制触发UI更新
    this.refreshTrigger = (this.refreshTrigger + 1) % 1000;
    console.info(`MainPage - 数据同步完成，刷新触发器: ${this.refreshTrigger}`);
  }

  selectRoom(roomId: number) {
    // 修复: 显式创建 RoomItem 对象
    this.rooms = this.rooms.map(room => {
      return {
        id: room.id,
        name: room.name,
        isSelected: room.id === roomId
      } as RoomItem;
    });

    // 强制触发UI更新
    this.refreshTrigger = (this.refreshTrigger + 1) % 1000;
  }

  // 获取家庭名称
  getHomeName(): string {
    return globalDataManager.getHomeName();
  }

  // 修改设备开关状态
  toggleDevice(deviceId: number) {
    this.devices = this.devices.map(device => {
      if (device.id === deviceId) {
        const isOn = !device.isOn;
        
        // 同步到全局状态
        if (device.name === '空调') {
          globalDataManager.setDeviceStatus('ac', isOn);
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            status: isOn ? (device.value ? `${device.value}℃` : '26℃') : '关闭',
            isOn: isOn,
            value: device.value || '26'
          } as DeviceItem;
        } 
        else if (device.name === '客厅灯') {
          globalDataManager.setDeviceStatus('livingRoomLight', isOn);
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            status: isOn ? '开启' : '关闭',
            isOn: isOn
          } as DeviceItem;
        }
        else if (device.name === '电视') {
          globalDataManager.setDeviceStatus('tv', isOn);
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            status: isOn ? '开启' : '关闭',
            isOn: isOn
          } as DeviceItem;
        }
        else if (device.name === '窗帘') {
          globalDataManager.setDeviceStatus('curtain', isOn);
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            status: isOn ? '开启' : '关闭',
            isOn: isOn
          } as DeviceItem;
        }
        else if (device.name === '音响') {
          globalDataManager.setDeviceStatus('audio', isOn);
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            status: isOn ? '开启' : '关闭',
            isOn: isOn
          } as DeviceItem;
        }
        else if (device.name === '扫地机器人') {
          globalDataManager.setDeviceStatus('robot', isOn);
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            status: isOn ? '开启' : '关闭',
            isOn: isOn
          } as DeviceItem;
        }
        else {
          // 其他设备只更新本地状态
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            status: isOn ? '开启' : '关闭',
            isOn: isOn
          } as DeviceItem;
        }
      }
      return device;
    });
    
    // 强制触发UI刷新
    this.refreshTrigger = (this.refreshTrigger + 1) % 1000;
  }

  // 修改 adjustACTemperature 方法
  adjustACTemperature(value: string) {
    this.devices = this.devices.map(device => {
      if (device.name === '空调') {
        // 手动复制属性（避免使用...展开运算符）
        return {
          id: device.id,
          name: device.name,
          icon: device.icon,
          status: `${value}℃`,
          isOn: device.isOn,
          value: value
        } as DeviceItem;
      }
      return device;
    });
    
    // 强制触发UI刷新
    this.refreshTrigger = (this.refreshTrigger + 1) % 1000;
  }



  @Builder
  renderRoomItem(room: RoomItem) {
    Text(room.name)
      .fontSize(18)
      .fontWeight(room.isSelected ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(room.isSelected ? '#1890ff' : '#666')
      .padding({ left: 15, right: 15, top: 8, bottom: 8 })
      .border({
        width: room.isSelected ? 2 : 0,
        color: '#1890ff',
        radius: 20,
        style: BorderStyle.Solid
      })
      .backgroundColor(room.isSelected ? 'rgba(24, 144, 255, 0.05)' : 'transparent')
      .margin({ right: 10 })
      .onClick(() => {
        this.selectRoom(room.id);
      })
  }

  @Builder
  renderEnvironmentItem(item: EnvironmentDataItem) {
    Column() {
      Row() {
        Image(item.icon)
          .width(24)
          .height(24)
          .margin({ right: 8 })

        Text(item.name)
          .fontSize(16)
          .fontColor('#666')
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')

      // 天气卡片特殊处理，显示天气图标
      if (item.id === 0) {
        Column() {
          // 天气文字和图标在同一行
          Row() {
            Text(item.status)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')

            // 天气图标
            if (item.weatherIcon) {
              Image(item.weatherIcon)
                .width(30)
                .height(30)
                .margin({ left: 8 })
                .objectFit(ImageFit.Contain)
            }
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
      } else {
        // 其他卡片正常显示数值和单位
        Row() {
          Text(item.status)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')

          Text(item.unit)
            .fontSize(16)
            .fontColor('#999')
            .margin({ left: 4, top: 8 })
        }
        .margin({ top: 5 })
      }
    }
    .padding(15)
    .backgroundColor('#f9f9f9')
    .borderRadius(12)
    .width('23%') // 调整为23%宽度，4项均分
  }

  @Builder
  renderDeviceItem(device: DeviceItem) {
    Row() {
      Image(device.icon)
        .width(40)
        .height(40)
        .margin({ right: 12 })

      Column() {
        Text(device.name)
          .fontSize(18)
          .fontColor('#333')

        // 根据设备开关状态显示不同的状态文本
        if (device.name === '空调' && device.isOn) {
          Text(`${device.value || '26'}℃`)
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 4 })
        } else {
          Text(device.isOn ? '开启' : '关闭')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 特殊处理空调设备，添加温度选择下拉框
      if (device.name === '空调' && device.isOn) {
        Row() {
          Select([
            { value: '16℃', icon: '' },
            { value: '17℃', icon: '' },
            { value: '18℃', icon: '' },
            { value: '19℃', icon: '' },
            { value: '20℃', icon: '' },
            { value: '21℃', icon: '' },
            { value: '22℃', icon: '' },
            { value: '23℃', icon: '' },
            { value: '24℃', icon: '' },
            { value: '25℃', icon: '' },
            { value: '26℃', icon: '' },
            { value: '27℃', icon: '' },
            { value: '28℃', icon: '' },
            { value: '29℃', icon: '' },
            { value: '30℃', icon: '' },
          ])
            .selected(parseInt(device.value || '26') - 16) // 默认选中当前温度
            .value(`${device.value || '26'}℃`)
            .font({ size: 16 })
            .fontColor('#333')
            .selectedOptionFont({ size: 16 })
            .optionFont({ size: 16 })
            .width(80)
            .onSelect((index: number, value: string) => {
              // 提取温度数值（去掉℃符号）
              const tempValue = value.replace('℃', '');
              this.adjustACTemperature(tempValue);
            })

          Toggle({ type: ToggleType.Switch, isOn: device.isOn })
            .margin({ left: 10 })
            .onChange((isOn) => {
              if (isOn !== device.isOn) {
                this.toggleDevice(device.id);
              }
            })
        }
      } else {
        Toggle({ type: ToggleType.Switch, isOn: device.isOn })
          .onChange((isOn) => {
            if (isOn !== device.isOn) {
              this.toggleDevice(device.id);
            }
          })
      }
    }
    .padding(15)
    .backgroundColor('#ffffff')
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.05)', offsetX: 0, offsetY: 2 })
    .margin({ bottom: 10 })
    .width('100%')
  }

  // 修改设备列表的ForEach部分，使用refreshTrigger作为key的一部分
  @Builder
  HomeContent() {
    Column() {
      // 顶部标题栏 - 使用现有资源
      Row() {
        Text(this.getHomeName())
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')

        Blank()

        // 添加设备按钮 
        Button() {
          Row({ space: 8 }) {
            Image($r('app.media.increase'))
              .width(24)
              .height(24)
              .fillColor('#1890ff')

            Text('添加设备')
              .fontSize(16)
              .fontColor('#1890ff')
              .fontWeight(FontWeight.Bold)
          }
        }
        .backgroundColor('rgba(24, 144, 255, 0.1)')
        .height(40)
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          // 添加设备功能，暂时保留此占位
          console.info('添加设备按钮点击')
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 15, bottom: 15 })

      // 房间选择栏
      Scroll() {
        Row() {
          ForEach(this.rooms, (room: RoomItem) => {
            this.renderRoomItem(room)
          }, (room: RoomItem) => room.id.toString() + (this.refreshTrigger)) // 增加refreshTrigger使ForEach重新构建
          
          // 添加房间按钮
          Button() {
            Image($r('app.media.increase'))
              .width(22)
              .height(22)
              .fillColor('#1890ff')
          }
          .backgroundColor('#f0f0f0')
          .width(38)
          .height(38)
          .borderRadius(19)
          .margin({ left: 10 })
          .onClick(() => {
            // 打开添加房间对话框
            this.addRoomDialogController.open();
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })

      // 基于选中的房间显示不同内容
      if (this.rooms.find(room => room.id === 1 && room.isSelected) ||
          this.rooms.find(room => room.id === 2 && room.isSelected) ||
          this.rooms.find(room => room.id === 3 && room.isSelected)||
          this.rooms.find(room => room.id === 4 && room.isSelected) ||
          this.rooms.find(room => room.id > 4 && room.isSelected)) {
        // 客厅/卫生间/厨房/阳台/新添加的房间被选中时，显示卡片式界面
        Column() {
          Row() {
            Button() {
              Row({ space: 12 }) {
                Image($r('app.media.AddDevicesys'))
                  .width(28)
                  .height(28)
                  .fillColor('#1890ff')

                Text('添加设备')
                  .fontSize(18)
                  .fontColor('#1890ff')
                  .fontWeight(FontWeight.Bold)
              }
            }
            .backgroundColor('#ffffff')
            .borderRadius(16)
            .height(80)
            .width('100%')
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
            .onClick(() => {
              console.info('添加设备按钮点击')
            })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#f5f5f5')
      } else {
        // 环境数据卡片
        Row() {
          ForEach(this.environmentData, (item: EnvironmentDataItem) => {
            this.renderEnvironmentItem(item)
          }, (item: EnvironmentDataItem) => item.id.toString())
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 20, right: 20, top: 10, bottom: 20 })

        // 设备控制列表
        Column() {
          Text('设备控制')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 10 })

          // 将设备列表放入滚动容器中
          Scroll() {
            Column() {
              ForEach(this.devices, (device: DeviceItem) => {
                this.renderDeviceItem(device)
              }, (device: DeviceItem) => `${device.id}_${device.isOn}_${device.value || ''}_${this.refreshTrigger}`)

              // 在音响设备之后添加"添加设备"按钮
              Button() {
                Row({ space: 12 }) {
                  Image($r('app.media.AddDevicesys'))
                    .width(28)
                    .height(28)
                    .fillColor('#1890ff')

                  Text('添加设备')
                    .fontSize(18)
                    .fontColor('#1890ff')
                    .fontWeight(FontWeight.Bold)
                }
              }
              .backgroundColor('#ffffff')
              .borderRadius(12)
              .height(72)
              .width('100%')
              .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
              .margin({ top: 10, bottom: 80 }) // 增加底部间距，防止被底部导航栏遮挡
              .onClick(() => {
                console.info('添加设备按钮点击')
              })
            }
          }
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
          .width('100%')
          .layoutWeight(1) // 让滚动区域占满剩余空间
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .layoutWeight(1) // 让设备区域占满剩余空间
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  build() {
    Column() {
      // 主内容区域
      if (this.currentTab === 0) {
        this.HomeContent()
      } else if (this.currentTab === 1) {
        SmartPage({ currentIndex: 1, onTabChange: (index: number) => {
          this.currentTab = index;
        }})
      } else if (this.currentTab === 2) {
        EnvMonitorPage({ currentIndex: 2, onTabChange: (index: number) => {
          this.currentTab = index;
        }})
      } else if (this.currentTab === 3) {
        ProfilePage({ currentIndex: 3, onTabChange: (index: number) => {
          this.currentTab = index;
        }})
      }

      // 底部导航栏
      Row() {
        ForEach(this.tabs, (tab: TabItem) => {
          Column() {
            Image(this.currentTab === tab.id ? tab.selectedIcon : tab.icon)
              .width(24)
              .height(24)

            Text(tab.name)
              .fontSize(12)
              .fontColor(this.currentTab === tab.id ? '#1890ff' : '#999')
              .margin({ top: 4 })
          }
          .width('25%')
          .height(60)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            // 当切换到不同标签时
            if (this.currentTab !== tab.id) {
              console.info(`切换标签，从 ${this.currentTab} 到 ${tab.id}`);
              // 如果从其他页面切换到首页，立即同步数据
              if (tab.id === 0) {
                // 延迟50毫秒再同步，确保页面已经切换
                setTimeout(() => {
                  console.info('切换到首页，立即同步数据');
                  this.syncDevicesWithGlobalState();
                  this.syncRoomsWithGlobalState();
                  this.refreshTrigger = (this.refreshTrigger + 1) % 1000;
                }, 50);
              }
            }
            this.currentTab = tab.id;
          })
        })
      }
      .width('100%')
      .backgroundColor('#ffffff')
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetY: -2 })
      .padding({ top: 8, bottom: 8 })
      .position({ x: 0, y: '100%' })
      .translate({ y: -76 }) // 底部导航栏高度
    }
    .width('100%')
    .height('100%')
  }
}