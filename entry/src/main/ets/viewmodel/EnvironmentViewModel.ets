//
//
// import { WeatherService } from '../common/utils/WeatherService'
//
// export default class EnvironmentViewModel {
//   stat: number = 0
//   temp: number = 0
//   gas: number = 0
//   hum: number = 0
//
//   toPromptString(): string {
//     return `请根据以下环境参数进行安全评估与建议：
// - 空气温度: ${this.temp}℃
// - 空气湿度: ${this.hum}%
// - 可燃气体浓度: ${this.gas} PPM
// - 当前安全级别: ${['安全', '警告', '危险'][this.stat]}`
//   }
//
//   async fetchXiamenWeather(): Promise<void> {
//     //模拟可行 函数已经调用
//     // this.temp = 25.5
//     // this.hum = 65
//     // this.gas = 120
//     // this.stat = 1
//     console.info("🟡 开始获取厦门天气...")
//     const response = await WeatherService.getCurrentWeather('101230201')
//     console.info("🔵 响应内容:", JSON.stringify(response))
//
//     if (response && response.now) {
//       this.temp = parseFloat(response.now.temp)
//       this.hum = parseFloat(response.now.humidity)
//       this.gas = Math.floor(Math.random() * 100)
//
//       if (this.gas < 100) this.stat = 0
//       else if (this.gas < 200) this.stat = 1
//       else this.stat = 2
//     } else {
//       console.warn("⚠️ 无天气数据返回")
//     }
//
//
//   }
//
//
// }
//
//
//
//
//
import { WeatherService } from '../common/utils/WeatherService'

export default class EnvironmentViewModel {
  city: string = '未知'
  stat: number = 0
  temp: number = 0
  gas: number = 0
  hum: number = 0
  weather: string = '晴' // 天气类型
  weatherCode: string = '100' // 天气代码
  isNight: boolean = false // 是否夜间

  toPromptString(): string {
    return `请根据以下环境参数进行安全评估与建议：
- 空气温度: ${this.temp}℃
- 空气湿度: ${this.hum}%
- 可燃气体浓度: ${this.gas} PPM
- 当前安全级别: ${['安全', '警告', '危险'][this.stat]}`
  }

  async fetchWeather(locationId: string): Promise<void> {
    console.info(`🟡 开始获取天气 (${locationId})...`)
    const response = await WeatherService.getCurrentWeather(locationId)
    console.info("🔵 天气响应内容:", JSON.stringify(response))

    if (response && response.now) {
      this.temp = parseFloat(response.now.temp)
      this.hum = parseFloat(response.now.humidity)
      this.gas = Math.floor(Math.random() * 100)
      
      // 设置城市名称
      this.city = "厦门"
      
      // 设置天气代码和类型
      if (response.now.icon) {
        this.weatherCode = response.now.icon
      }
      if (response.now.text) {
        this.weather = response.now.text
      }

      // 判断是否为夜间
      const now = new Date()
      const hours = now.getHours()
      this.isNight = hours < 6 || hours >= 18

      if (this.gas < 100) this.stat = 0
      else if (this.gas < 200) this.stat = 1
      else this.stat = 2
    } else {
      console.warn("⚠️ 无天气数据返回")
    }
  }

  // 获取天气图标
  getWeatherIcon(): Resource {
    console.info(`获取天气图标: 代码=${this.weatherCode}, 天气=${this.weather}, 夜间=${this.isNight}`)
    
    // 根据天气代码和是否夜间返回对应图标
    if (this.weatherCode.startsWith('10')) { // 晴
      if (this.isNight) {
        return $r('app.media.nightsunny')
      } else {
        return $r('app.media.sunny')
      }
    } else if (this.weatherCode.startsWith('11') || this.weatherCode.startsWith('12') || this.weatherCode.startsWith('13')) { // 多云
      return $r('app.media.cloudy')
    } else if (this.weatherCode.startsWith('3')) { // 雨
      return $r('app.media.rainy')
    } else if (this.weatherCode.startsWith('4')) { // 雪
      return $r('app.media.snowy')
    } else if (this.weatherCode.startsWith('2')) { // 阴
      return $r('app.media.cloudy')
    } else if (this.weatherCode.startsWith('9')) { // 大风
      return $r('app.media.cloudy')
    } else if (this.weatherCode.startsWith('30')) { // 雾霾
      return $r('app.media.cloudy')
    } else if (this.weatherCode.startsWith('5')) { // 霾
      return $r('app.media.cloudy')
    } else if (this.weatherCode.startsWith('6') || this.weatherCode.startsWith('7')) { // 雷电
      return $r('app.media.thunder')
    } else {
      // 默认图标
      console.info(`未匹配到天气图标，使用默认图标: ${this.weatherCode}`)
      return $r('app.media.weather')
    }
  }
}
