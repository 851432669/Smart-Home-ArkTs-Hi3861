import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { ApiService } from '../common/utils/ApiService'
import preferences from '@ohos.data.preferences'

interface RouterParams {
  username?: string;
}

@Entry
@Component
struct ResetPasswordPage {
  @State oldPassword: string = ''
  @State newPassword: string = ''
  @State confirmPassword: string = ''
  @State username: string = ''
  @State isLoading: boolean = false
  @State message: string = ''
  @State messageType: 'error' | 'success' | 'info' = 'info'
  @State passwordStrength: 'weak' | 'medium' | 'strong' | '' = ''
  private preferenceStore: preferences.Preferences | null = null

  // 生命周期钩子，页面显示时获取当前登录用户
  aboutToAppear() {
    // 尝试从路由参数获取用户名
    const params = router.getParams() as RouterParams;
    if (params && params.username) {
      this.username = params.username;
      return;
    }

    // 如果路由参数没有用户名，则从本地存储获取
    this.getUserInfo();
  }

  // 获取当前登录用户信息
  async getUserInfo() {
    try {
      // 获取偏好存储实例
      this.preferenceStore = await preferences.getPreferences(getContext(), 'userInfo')
      
      // 获取当前登录用户名
      const username = await this.preferenceStore.get('username', '') as string
      if (username) {
        this.username = username;
      } else {
        this.showMessage('未能获取用户信息，请返回重试', 'error')
        setTimeout(() => {
          router.back()
        }, 1500)
      }
    } catch (error) {
      console.error('获取用户信息失败:', JSON.stringify(error))
      this.showMessage('获取用户信息失败', 'error')
      setTimeout(() => {
        router.back()
      }, 1500)
    }
  }

  // 检查密码强度
  private checkPasswordStrength(password: string) {
    if (!password) {
      this.passwordStrength = ''
      return
    }

    const hasNum = /\d/.test(password)
    const hasLetter = /[a-zA-Z]/.test(password)
    const hasSymbol = /[^a-zA-Z0-9]/.test(password)

    if (hasNum && hasLetter && hasSymbol && password.length >= 8) {
      this.passwordStrength = 'strong'
    } else if ((hasNum && hasLetter) || (hasLetter && hasSymbol) || (hasNum && hasSymbol)) {
      this.passwordStrength = 'medium'
    } else {
      this.passwordStrength = 'weak'
    }
  }

  // 显示消息
  private showMessage(msg: string, type: 'error' | 'success' | 'info') {
    this.message = msg
    this.messageType = type
  }

  // 验证表单
  private validateForm(): boolean {
    if (!this.username) {
      this.showMessage('未获取到用户信息', 'error')
      return false
    }
    
    if (!this.oldPassword || !this.newPassword || !this.confirmPassword) {
      this.showMessage('请填写所有密码字段', 'error')
      return false
    }
    
    if (this.newPassword.length < 6) {
      this.showMessage('新密码长度不能少于6位', 'error')
      return false
    }
    
    if (this.newPassword !== this.confirmPassword) {
      this.showMessage('两次输入的新密码不一致', 'error')
      return false
    }
    
    if (this.oldPassword === this.newPassword) {
      this.showMessage('新密码不能与旧密码相同', 'error')
      return false
    }
    
    return true
  }

  // 重置密码
  private async resetPassword() {
    if (!this.validateForm()) {
      return
    }
    
    this.isLoading = true
    try {
      // 调用API服务重置密码
      const response = await ApiService.resetPassword(
        this.username,
        this.oldPassword,
        this.newPassword
      )
      
      if (response.success) {
        this.showMessage('密码重置成功', 'success')
        promptAction.showToast({
          message: '密码重置成功',
          duration: 2000
        })
        
        // 延迟返回
        setTimeout(() => {
          router.back()
        }, 1500)
      } else {
        this.showMessage(response.message || '密码重置失败', 'error')
      }
    } catch (error) {
      console.error('密码重置失败:', JSON.stringify(error))
      this.showMessage('密码重置失败，请检查网络连接', 'error')
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Stack() {
      // 背景图层
      Image($r('app.media.background'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 半透明遮罩层，提高表单可读性
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(255, 255, 255, 0.4)')

      // 内容层
      Column() {
        // 标题栏
        Row() {
          Image($r('app.media.back')) // 返回按钮
            .width(24)
            .height(24)
            .onClick(() => {
              router.back()
            })
          
          Text('重置密码')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 16 })
          
          Blank()
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .backgroundColor('rgba(255, 255, 255, 0.8)')

        // 表单内容
        Column({ space: 16 }) {
          Text('请输入您的原密码和新密码')
            .fontSize(16)
            .fontColor('#666')
            .margin({ top: 20, bottom: 10 })
            
          // 显示当前用户名
          Row() {
            Text('当前用户: ')
              .fontSize(16)
              .fontColor('#333')
            Text(this.username)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1890ff')
          }
          .width('90%')
          .justifyContent(FlexAlign.Start)

          TextInput({ placeholder: '请输入原密码' })
            .height(45)
            .type(InputType.Password)
            .backgroundColor('rgba(255, 255, 255, 0.8)')
            .borderRadius(8)
            .width('90%')
            .onChange(v => this.oldPassword = v)

          TextInput({ placeholder: '请输入新密码' })
            .height(45)
            .type(InputType.Password)
            .backgroundColor('rgba(255, 255, 255, 0.8)')
            .borderRadius(8)
            .width('90%')
            .onChange(v => {
              this.newPassword = v
              this.checkPasswordStrength(v)
            })

          if (this.passwordStrength) {
            Text(`密码强度：${this.passwordStrength}`)
              .fontColor(this.passwordStrength === 'weak' ? '#ff4d4f' :
                this.passwordStrength === 'medium' ? '#faad14' : '#52c41a')
              .width('90%')
              .fontSize(14)
          }

          TextInput({ placeholder: '请再次输入新密码' })
            .height(45)
            .type(InputType.Password)
            .backgroundColor('rgba(255, 255, 255, 0.8)')
            .borderRadius(8)
            .width('90%')
            .onChange(v => this.confirmPassword = v)

          Button('确认重置')
            .height(50)
            .width('90%')
            .backgroundColor('#1890ff')
            .fontColor(Color.White)
            .borderRadius(25)
            .margin({ top: 20 })
            .enabled(!this.isLoading)
            .onClick(() => this.resetPassword())

          if (this.message) {
            Text(this.message)
              .fontSize(14)
              .fontColor(this.messageType === 'error' ? '#ff4d4f' :
                this.messageType === 'success' ? '#52c41a' : '#1890ff')
              .margin({ top: 10 })
          }
        }
        .width('100%')
        .padding(20)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
  }
} 