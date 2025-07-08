import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { globalDataManager, UserInfo } from '../common/utils/GlobalDataManager'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { cameraPicker } from '@kit.CameraKit'
import { camera } from '@kit.CameraKit'

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
  
  // 在页面显示时获取最新的用户信息
  aboutToAppear() {
    this.userInfo = globalDataManager.getUserInfo()
    console.info(`ProfilePage - 当前用户账号ID: ${this.userInfo.account}`)
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
    // 显示开发中提示
    promptAction.showToast({
      message: '帮助中心功能开发中',
      duration: 2000
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
        
        Text(`${this.userInfo.roomCount}个房间`)
          .fontSize(14)
          .fontColor('#999')
          .margin({ left: 10 })
        
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
        // 点击跳转到家庭详情
        promptAction.showToast({
          message: '家庭详情功能开发中',
          duration: 2000
        })
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