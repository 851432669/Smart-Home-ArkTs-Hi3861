import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { globalDataManager, UserInfo, RoomItem } from '../common/utils/GlobalDataManager'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { cameraPicker } from '@kit.CameraKit'
import { camera } from '@kit.CameraKit'

// 对话框结果接口
interface DialogResult {
  index: number;
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

// 定义房间列表对话框组件
@CustomDialog
struct RoomListDialog {
  controller: CustomDialogController
  @State rooms: RoomItem[] = []
  onDelete: (roomId: number) => void = () => {}
  
  aboutToAppear() {
    // 获取全局房间列表
    this.rooms = globalDataManager.getRooms()
    console.info(`RoomListDialog - 已获取全局房间列表，房间数量: ${this.rooms.length}`)
  }

  // 刷新房间列表
  refreshRooms() {
    // 获取全局房间列表
    this.rooms = globalDataManager.getRooms()
    console.info(`RoomListDialog - 已刷新房间列表，房间数量: ${this.rooms.length}`)
  }
  
  build() {
    Column() {
      Text('管理房间')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 10, bottom: 10 })
      
      List() {
        ForEach(this.rooms, (room: RoomItem) => {
          // 不显示"全屋"选项，因为它不能删除
          if (room.id !== 0) {
            ListItem() {
              Row() {
                Text(room.name)
                  .fontSize(16)
                  .fontColor('#333')
                  .layoutWeight(1)
                
                Button({ type: ButtonType.Circle }) {
                  Image($r('app.media.black'))
                    .width(16)
                    .height(16)
                    .fillColor(Color.Red)
                }
                .width(32)
                .height(32)
                .backgroundColor('rgba(255, 0, 0, 0.1)')
                .onClick(() => {
                  this.onDelete(room.id)
                  // 刷新本地房间列表
                  this.refreshRooms()
                })
              }
              .width('100%')
              .height(50)
              .padding({ left: 16, right: 16 })
            }
          }
        })
      }
      .width('90%')
      .height(200)
      .backgroundColor('#f5f5f5')
      .borderRadius(8)
      .margin({ bottom: 20 })
      
      Button('关闭')
        .onClick(() => {
          if (this.controller) {
            this.controller.close()
          } else {
            console.error('RoomListDialog - controller is undefined')
          }
        })
        .backgroundColor('#007DFF')
        .fontColor(Color.White)
        .width('90%')
        .height(40)
        .margin({ bottom: 10 })
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(10)
    .padding(10)
  }
}

// 定义昵称编辑对话框组件
@CustomDialog
struct NicknameEditDialog {
  controller: CustomDialogController
  @State nickname: string = ''
  onConfirm: (nickname: string) => void = () => {}
  
  aboutToAppear() {
    this.nickname = globalDataManager.getUserInfo().nickname
  }
  
  build() {
    Column() {
      Text('修改昵称')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 10, bottom: 10 })
      
      TextInput({ text: this.nickname })
        .width('90%')
        .height(50)
        .margin({ bottom: 10 })
        .onChange((value: string) => {
          this.nickname = value
        })
      
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .onClick(() => {
            this.controller.close()
          })
          .backgroundColor('#f5f5f5')
          .fontColor('#999')
          .width('40%')
          .height(40)
        
        Button('确定')
          .onClick(() => {
            if (this.nickname && this.nickname.trim().length > 0) {
              this.onConfirm(this.nickname)
              this.controller.close()
            } else {
              promptAction.showToast({
                message: '昵称不能为空',
                duration: 2000
              })
            }
          })
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .width('40%')
          .height(40)
      }
      .margin({ top: 10, bottom: 20 })
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(10)
    .padding(10)
  }
}

// 定义头像选择对话框组件
@CustomDialog
struct AvatarPickerDialog {
  controller: CustomDialogController
  onSelectImage: (uri: string) => void = () => {}
  
  build() {
    Column() {
      Text('选择头像')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 10, bottom: 20 })
      
      Row({ space: 20 }) {
        Column() {
          Image($r('app.media.index2_unused')) // 使用现有资源作为相机图标
            .width(60)
            .height(60)
            .objectFit(ImageFit.Contain)
          
          Text('拍照')
            .fontSize(16)
            .margin({ top: 10 })
        }
        .onClick(() => {
          this.controller.close()
          this.takePhoto()
        })
        
        Column() {
          Image($r('app.media.index2_unused')) // 使用现有资源作为相册图标
            .width(60)
            .height(60)
            .objectFit(ImageFit.Contain)
          
          Text('从相册选择')
            .fontSize(16)
            .margin({ top: 10 })
        }
        .onClick(() => {
          this.controller.close()
          this.pickFromGallery()
        })
      }
      .margin({ bottom: 20 })
      
      Button('取消')
        .onClick(() => {
          this.controller.close()
        })
        .backgroundColor('#f5f5f5')
        .fontColor('#999')
        .width('90%')
        .height(40)
        .margin({ bottom: 10 })
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(10)
    .padding(10)
  }
  
  // 拍照
  async takePhoto(): Promise<void> {
    try {
      let pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_FRONT // 默认使用前置摄像头
      }
      
      let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(
        getContext(),
        [cameraPicker.PickerMediaType.PHOTO],
        pickerProfile
      )
      
      console.info('拍照结果: ' + JSON.stringify(pickerResult))
      
      if (pickerResult && pickerResult.resultCode === 0) {
        this.onSelectImage(pickerResult.resultUri)
      }
    } catch (error) {
      let err = error as BusinessError
      console.error(`拍照失败: ${err.code}, ${err.message}`)
      promptAction.showToast({
        message: '拍照失败',
        duration: 2000
      })
    }
  }
  
  // 从相册选择
  async pickFromGallery(): Promise<void> {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1 // 最多选择1张图片
      
      const photoViewPicker = new photoAccessHelper.PhotoViewPicker()
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions)
      
      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        this.onSelectImage(photoSelectResult.photoUris[0])
      }
    } catch (error) {
      let err = error as BusinessError
      console.error(`选择图片失败: ${err.code}, ${err.message}`)
      promptAction.showToast({
        message: '选择图片失败',
        duration: 2000
      })
    }
  }
}

@Component
export struct ProfilePage {
  @Prop currentIndex: number = 3
  @State currentTab: number = 3 // 默认选中"我的"标签
  onTabChange?: (index: number) => void
  
  // 用户信息状态
  @State userInfo: UserInfo = globalDataManager.getUserInfo()
  @State avatarUri: string = '' // 头像URI
  // 房间列表
  @State rooms: RoomItem[] = []
  // 添加刷新触发器状态
  @State refreshTrigger: number = 0
  
  // 在页面显示时获取最新的用户信息
  aboutToAppear() {
    this.userInfo = globalDataManager.getUserInfo()
    this.rooms = globalDataManager.getRooms()
    console.info(`ProfilePage - 当前用户账号ID: ${this.userInfo.account}`)
  }
  
  // 每次页面显示时执行
  onPageShow() {
    this.syncUserAndRooms()
  }
  
  // 同步用户信息和房间列表
  syncUserAndRooms() {
    // 更新用户信息
    this.userInfo = globalDataManager.getUserInfo()
    // 更新房间列表
    this.rooms = globalDataManager.getRooms()
    // 触发UI刷新
    this.refreshTrigger = (this.refreshTrigger + 1) % 1000
    console.info(`ProfilePage - 已同步用户信息和房间列表，刷新触发器: ${this.refreshTrigger}`)
  }
  
  // 昵称编辑对话框控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: NicknameEditDialog({
      onConfirm: (nickname: string) => this.updateNickname(nickname)
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })
  
  // 头像选择对话框控制器
  avatarPickerController: CustomDialogController = new CustomDialogController({
    builder: AvatarPickerDialog({
      onSelectImage: (uri: string) => this.updateAvatar(uri)
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })
  
  // 自定义添加房间对话框控制器
  roomAddDialogController: CustomDialogController = new CustomDialogController({
    builder: RoomAddDialog({
      onConfirm: (roomName: string) => this.addRoom(roomName)
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })
  
  // 房间列表对话框控制器
  roomListDialogController: CustomDialogController = new CustomDialogController({
    builder: RoomListDialog({
      onDelete: (roomId: number) => this.deleteRoom(roomId)
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })
  
  // 打开房间列表对话框
  openRoomListDialog() {
    // 重新创建控制器，确保每次打开时都获取最新数据
    this.roomListDialogController = new CustomDialogController({
      builder: RoomListDialog({
        onDelete: (roomId: number) => this.deleteRoom(roomId)
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center
    })
    this.roomListDialogController.open()
  }
  
  // 修改昵称
  editNickname(): void {
    this.dialogController.open()
  }
  
  // 更新昵称
  updateNickname(nickname: string): void {
    // 更新昵称
    globalDataManager.updateUserNickname(nickname)
    // 更新本地状态
    this.userInfo = globalDataManager.getUserInfo()
    // 显示提示
    promptAction.showToast({
      message: '昵称修改成功',
      duration: 2000
    })
  }
  
  // 选择头像
  selectAvatar(): void {
    this.avatarPickerController.open()
  }
  
  // 更新头像
  updateAvatar(uri: string): void {
    if (uri) {
      this.avatarUri = uri
      console.info(`头像已更新: ${uri}`)
      promptAction.showToast({
        message: '头像更新成功',
        duration: 2000
      })
    }
  }
  
  // 添加房间
  addRoom(roomName: string): void {
    if (roomName && roomName.trim() !== '') {
      // 添加新房间
      if(globalDataManager.addRoom(roomName.trim())) {
        // 同步用户信息和房间列表
        this.syncUserAndRooms()
        
        // 显示成功提示
        promptAction.showToast({
          message: `成功添加房间：${roomName.trim()}`,
          duration: 2000
        });
      } else {
        // 显示失败提示
        promptAction.showToast({
          message: '房间已存在或名称无效',
          duration: 2000
        });
      }
    } else {
      promptAction.showToast({
        message: '房间名称不能为空',
        duration: 2000
      });
    }
  }
  
  // 删除房间
  deleteRoom(roomId: number): void {
    if (globalDataManager.deleteRoom(roomId)) {
      // 同步用户信息和房间列表
      this.syncUserAndRooms()
      
      // 显示成功提示
      promptAction.showToast({
        message: '已删除房间',
        duration: 2000
      })
    } else {
      // 显示失败提示
      promptAction.showToast({
        message: '删除房间失败',
        duration: 2000
      })
    }
  }
  
  // 跳转到设置页面
  navigateToSettings(): void {
    // 显示开发中提示
    promptAction.showToast({
      message: '更多设置功能开发中',
      duration: 2000
    })
  }
  
  // 跳转到服务中心
  navigateToServiceCenter(): void {
    // 显示开发中提示
    promptAction.showToast({
      message: '服务中心功能开发中',
      duration: 2000
    })
  }
  
  // 跳转到帮助中心
  navigateToHelpCenter(): void {
    router.pushUrl({
      url: 'pages/HelpCenterPage'
    }).catch((err: Error) => {
      console.error(`跳转到帮助中心页面失败: ${JSON.stringify(err)}`)
    })
  }
  
  // 跳转到关于我们
  navigateToAboutUs(): void {
    router.pushUrl({
      url: 'pages/TermsPage'
    }).catch((err: Error) => {
      console.error(`跳转到关于我们页面失败: ${JSON.stringify(err)}`)
    })
  }
  
  // 退出登录
  logout(): void {
    // 显示确认对话框
    promptAction.showDialog({
      title: '退出登录',
      message: '确定要退出当前账号吗？',
      buttons: [
        {
          text: '取消',
          color: '#999'
        },
        {
          text: '确定',
          color: '#007DFF'
        }
      ]
    }).then((result: DialogResult) => {
      if (result.index === 1) { // 用户点击了"确定"
        console.info('用户确认退出登录')
        
        // 显示退出提示
        promptAction.showToast({
          message: '退出成功',
          duration: 2000
        })
        
        // 退出到首页
        router.replaceUrl({
          url: 'pages/Index'
        }).catch((err: Error) => {
          console.error(`跳转到首页失败: ${JSON.stringify(err)}`)
        })
      }
    }).catch((err: Error) => {
      console.error(`显示退出确认对话框失败: ${JSON.stringify(err)}`)
    })
  }

  build() {
    Column() {
      // 用户信息区域
      Row() {
        // 用户头像
        Stack() {
          Image(this.avatarUri ? this.avatarUri : $r('app.media.user_37447_1280'))
            .width(80)
            .height(80)
            .borderRadius(40)
            .objectFit(ImageFit.Cover)
            .onClick(() => this.selectAvatar()) // 点击头像选择新头像
          
          Circle()
            .width(24)
            .height(24)
            .fill('#007DFF')
            .position({ x: 60, y: 60 })
            .border({ width: 2, color: Color.White })
          
          Image($r('app.media.index2_unused')) // 使用现有资源作为相机图标
            .width(14)
            .height(14)
            .position({ x: 60, y: 60 })
            .translate({ x: -7, y: -7 })
            .fillColor(Color.White)
        }
        .onClick(() => this.selectAvatar()) // 点击整个Stack区域选择新头像

        // 用户信息
        Column({ space: 5 }) {
          Row({ space: 10 }) {
            Text(this.userInfo.nickname)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .onClick(() => this.editNickname()) // 添加点击事件，点击昵称文字直接编辑
              
            Image($r('app.media.index2_unused')) // 使用现有资源作为编辑图标
              .width(20)
              .height(20)
              .fillColor('#666')
              .onClick(() => this.editNickname())
          }
          
          Row() {
            Text(`账号ID: ${this.userInfo.account}`)
              .fontSize(14)
              .fontColor('#999')
            
            Text(this.userInfo.isVerified ? '已认证' : '未认证')
              .fontSize(12)
              .fontColor(this.userInfo.isVerified ? '#1890ff' : '#ff4d4f')
              .backgroundColor(this.userInfo.isVerified ? 'rgba(24, 144, 255, 0.1)' : 'rgba(255, 77, 79, 0.1)')
              .borderRadius(10)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .margin({ left: 10 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 15 })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 30, bottom: 20 })
      .backgroundColor(Color.White)

      // 用户家庭信息
      Row() {
        Text(globalDataManager.getHomeName())
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        
        Row() {
          Text(`${this.userInfo.roomCount}个房间`)
            .fontSize(14)
            .fontColor('#999')
            .margin({ left: 10 })
          
          // 添加房间管理按钮
          Row() {
            // 添加房间按钮
            Image($r('app.media.increase'))
              .width(20)
              .height(20)
              .margin({ left: 5 })
              .onClick(() => {
                // 打开添加房间对话框
                this.roomAddDialogController.open()
              })
            
            // 管理房间按钮
            Image($r('app.media.index3_unused'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
              .onClick(() => {
                // 先同步房间列表，确保显示最新状态
                this.syncUserAndRooms()
                // 打开房间列表对话框
                this.openRoomListDialog()
              })
          }
        }
        
        Blank()
        
        Image($r('app.media.index2_unused')) // 使用现有资源作为箭头图标
          .width(20)
          .height(20)
          .fillColor('#999')
      }
      .width('100%')
      .backgroundColor(Color.White)
      .padding({ left: 20, right: 20, top: 15, bottom: 15 })
      .margin({ top: 10 })
      .onClick(() => {
        // 先同步房间列表，确保显示最新状态
        this.syncUserAndRooms()
        // 打开房间列表对话框
        this.openRoomListDialog()
      })

      // 设置选项列表
      Column({ space: 1 }) {
        // 更多设置
        Row() {
          Text('更多设置')
            .fontSize(16)
            .fontColor('#333')
          
          Blank()
          
          Image($r('app.media.index2_unused')) // 使用现有资源作为箭头图标
            .width(20)
            .height(20)
            .fillColor('#999')
        }
        .width('100%')
        .backgroundColor(Color.White)
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        .onClick(() => this.navigateToSettings())

        // 服务中心
        Row() {
          Text('服务中心')
            .fontSize(16)
            .fontColor('#333')
          
          Blank()
          
          Image($r('app.media.index2_unused')) // 使用现有资源作为箭头图标
            .width(20)
            .height(20)
            .fillColor('#999')
        }
        .width('100%')
        .backgroundColor(Color.White)
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        .onClick(() => this.navigateToServiceCenter())

        // 帮助中心
        Row() {
          Text('帮助中心')
            .fontSize(16)
            .fontColor('#333')
          
          Blank()
          
          Image($r('app.media.index2_unused')) // 使用现有资源作为箭头图标
            .width(20)
            .height(20)
            .fillColor('#999')
        }
        .width('100%')
        .backgroundColor(Color.White)
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        .onClick(() => this.navigateToHelpCenter())

        // 关于我们
        Row() {
          Text('关于我们')
            .fontSize(16)
            .fontColor('#333')
          
          Blank()
          
          Image($r('app.media.index2_unused')) // 使用现有资源作为箭头图标
            .width(20)
            .height(20)
            .fillColor('#999')
        }
        .width('100%')
        .backgroundColor(Color.White)
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        .onClick(() => this.navigateToAboutUs())

        // 退出登录按钮
        Row() {
          Text('退出登录')
            .fontSize(16)
            .fontColor('#ff4d4f') // 使用红色以突出显示
          
          Blank()
          
          Image($r('app.media.index2_unused')) // 使用现有资源作为箭头图标
            .width(20)
            .height(20)
            .fillColor('#ff4d4f')
        }
        .width('100%')
        .backgroundColor(Color.White)
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        .margin({ top: 10 }) // 添加上边距，与其他选项分开
        .onClick(() => this.logout())
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}

@Entry
@Component
struct ProfilePageEntry {
  build() {
    Column() {
      ProfilePage()
    }
  }
} 