import http from '@ohos.net.http'

interface WeatherNow {
  temp: string
  humidity: string
  icon: string
  text: string
  obsTime: string
  feelsLike: string
  wind360: string
  windDir: string
  windScale: string
  windSpeed: string
  pressure: string
  vis: string
  cloud: string
  dew: string
}

export interface WeatherNowResponse {
  code: string
  now?: WeatherNow
}

// 城市查询接口返回结构
interface GeneratedTypeLiteralInterface_1 {
  name: string;
  id: string;
  adm1: string;
  adm2: string;
}

export interface CityLookupResponse {
  location: GeneratedTypeLiteralInterface_1[]
}

export class WeatherService {
  static readonly API_KEY: string = '0cc00bafbd474fe38076c5282f606527'
  static readonly BASE_URL: string = 'https://ne3v58tpgr.re.qweatherapi.com/v7/weather/now'

  static async getCurrentWeather(location: string): Promise<WeatherNowResponse | null> {
    const request = http.createHttp()
    const url = `${WeatherService.BASE_URL}?location=${location}`

    try {
      const response: http.HttpResponse = await request.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'X-QW-Api-Key': WeatherService.API_KEY
        },
        expectDataType: http.HttpDataType.STRING
      })

      const resultStr: string = response.result as string
      const json: WeatherNowResponse = JSON.parse(resultStr)
      return json
    } catch (err) {
      console.error('天气请求失败:', JSON.stringify(err))
      return null
    } finally {
      request.destroy()
    }
  }

  static async rawRequest(url: string): Promise<CityLookupResponse | null> {
    const request = http.createHttp()
    try {
      const response: http.HttpResponse = await request.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'X-QW-Api-Key': WeatherService.API_KEY
        },
        expectDataType: http.HttpDataType.STRING
      })

      const resultStr: string = response.result as string
      const json: CityLookupResponse = JSON.parse(resultStr)
      return json
    } catch (err) {
      console.error('❌ 通用请求失败:', JSON.stringify(err))
      return null
    } finally {
      request.destroy()
    }
  }
}


