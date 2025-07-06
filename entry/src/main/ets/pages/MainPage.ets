import router from '@ohos.router'
import { EnvMonitorPage } from './EnvMonitorPage'
import { SmartPage } from './SmartPage'
import { ProfilePage } from './ProfilePage'
import EnvironmentViewModel from '../viewmodel/EnvironmentViewModel'
import { globalDataManager, EnvironmentDataItem } from '../common/utils/GlobalDataManager';

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
    { id: 1, name: '空调', icon: $r('app.media.ac'), status: '26℃', isOn: true, value: '26' },
    { id: 2, name: '电视', icon: $r('app.media.tv'), status: '关闭', isOn: false },
    { id: 3, name: '窗帘', icon: $r('app.media.curtain'), status: '开启', isOn: true },
    { id: 4, name: '音响', icon: $r('app.media.audio'), status: '关闭', isOn: false },
    { id: 5, name: '扫地机器人', icon: $r('app.media.sweep'), status: '关闭', isOn: false }
  ]

  // 添加一个辅助的触发刷新的变量
  @State refreshTrigger: number = 0

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

  // 修改 toggleDevice 方法中的空调处理
  toggleDevice(deviceId: number) {
    this.devices = this.devices.map(device => {
      if (device.id === deviceId) {
        const isOn = !device.isOn;

        if (device.name === '空调') {
          // 手动复制空调属性
          return {
            id: device.id,
            name: device.name,
            icon: device.icon,
            status: isOn ? (device.value ? `${device.value}℃` : '26℃') : '关闭',
            isOn: isOn,
            value: device.value || '26'
          } as DeviceItem;
        } else {
          // 手动复制其他设备属性
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
        Text('4612的家')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')

        Blank()

        // 添加设备按钮 (替换原来的烟雾报警按钮)
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
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })

      // 基于选中的房间显示不同内容
      if (this.rooms.find(room => room.id === 1 && room.isSelected) ||
          this.rooms.find(room => room.id === 2 && room.isSelected) ||
          this.rooms.find(room => room.id === 3 && room.isSelected)||
          this.rooms.find(room => room.id === 4 && room.isSelected)) {
        // 客厅/卫生间/厨房被选中时，显示卡片式界面
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

  // 添加一个新方法用于获取天气数据
  aboutToAppear() {
    // 初始触发刷新
    this.refreshTrigger = 1;

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
  }
}