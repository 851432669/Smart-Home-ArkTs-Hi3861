import router from '@ohos.router'
import { globalDataManager } from '../common/utils/GlobalDataManager'

@Entry
@Component
struct SplashPage {
  @State logoScale: number = 0.8
  @State logoOpacity: number = 0
  @State textOpacity: number = 0
  @State textScale: number = 0.5
  @State appNameOpacity: number = 0
  @State dotCount: number = 0
  @State isDataLoaded: boolean = false
  private timerId: number = -1
  private animationTimerId: number = -1
  @State canNavigate: boolean = false; // 新增状态，用于控制导航

  aboutToAppear() {
    // 立即开始预加载天气数据
    this.preloadData();
    
    // 图片动画
    animateTo({
      duration: 1000,
      curve: Curve.EaseOut,
    }, () => {
      this.logoScale = 1
      this.logoOpacity = 1
    })

    // 文字动画，延迟500ms开始
    setTimeout(() => {
      animateTo({
        duration: 800,
        curve: Curve.EaseOut,
      }, () => {
        this.textOpacity = 1
        this.textScale = 1
      })

      // 应用名称动画，延迟300ms
      setTimeout(() => {
        animateTo({
          duration: 600,
          curve: Curve.EaseOut,
        }, () => {
          this.appNameOpacity = 1
        })
      }, 300)
    }, 500)

    // 动态点的动画
    this.animationTimerId = setInterval(() => {
      this.dotCount = (this.dotCount + 1) % 4
    }, 500)

    // 至少等待3秒钟，但不直接跳转，由数据加载完成来触发
    this.timerId = setTimeout(() => {
      // 如果数据已加载完成，则立即跳转
      if (this.isDataLoaded) {
        this.navigateToIndex();
      } else {
        // 如果数据还没加载完成，记录可以跳转的标记，等待数据加载
        this.canNavigate = true;
      }
    }, 3000)
  }

  // 预加载数据
  async preloadData() {
    console.info('开始在SplashPage预加载数据');
    let attempts = 0;
    while (attempts < 3) {
      try {
        await globalDataManager.preloadWeatherData();
        this.isDataLoaded = true;
        console.info('SplashPage预加载完成');
        break;
      } catch (error) {
        console.error('预加载数据出错:', JSON.stringify(error));
        // 非最后一次尝试，等待1秒后重试
        if (attempts < 2) {
          await new Promise<void>(resolve => setTimeout(resolve, 1000));
        }
      }
      attempts++;
    }
    
    // 检查是否已经超过3秒，如果是则立即导航
    if (this.canNavigate) {
      this.navigateToIndex();
    }
  }
  
  // 导航到主页
  navigateToIndex() {
    if (this.timerId !== -1) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
    
    console.info('导航到主页...');
    router.pushUrl({ url: 'pages/Index' });
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearTimeout(this.timerId)
      this.timerId = -1
    }
    if (this.animationTimerId !== -1) {
      clearInterval(this.animationTimerId)
      this.animationTimerId = -1
    }
  }

  getDots() {
    let dots = ''
    for (let i = 0; i < this.dotCount; i++) {
      dots += '.'
    }
    return dots
  }

  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#e8f4ff', 0.0], ['#c0e0ff', 1.0]]
        })

      // 主内容区 - 整体上移
      Column({ space: 30 }) {
        // Logo图片 - 上移
        Image($r('app.media.raccoon'))
          .width(200)
          .height(200)
          .objectFit(ImageFit.Contain)
          .scale({ x: this.logoScale, y: this.logoScale })
          .opacity(this.logoOpacity)
          .borderRadius(100)
          .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.2)', offsetX: 0, offsetY: 10 })
          .animation({
            duration: 1000,
            curve: Curve.EaseOut
          })

        // 文字上移
        Text(`让生活更智能${this.getDots()}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .opacity(this.textOpacity * 0.9)
          .scale({ x: this.textScale, y: this.textScale })
          .animation({
            duration: 800,
            curve: Curve.EaseOut,
            delay: 200
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .position({ x: 0, y: '25%' }) // 上移整体内容，减少y值

      // 底部应用名称和图标
      Column() {
        Row({ space: 10 }) {
          Image($r('app.media.app_icon'))
            .width(40)
            .height(40)
            .opacity(this.appNameOpacity)
            .animation({
              duration: 600,
              curve: Curve.EaseOut
            })

          Text('智能家居')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
            .opacity(this.appNameOpacity)
            .animation({
              duration: 600,
              curve: Curve.EaseOut
            })
        }
      }
      .width('100%')
      .position({ x: 0, y: '85%' })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
