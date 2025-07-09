import http from '@ohos.net.http'

/**
 * API响应接口
 */
interface ApiResponse {
  success: boolean;
  message: string;
  data?: Record<string, string | number | boolean | null>;
  error?: Record<string, string | number | boolean | null>;
}

/**
 * 重置密码请求接口
 */
interface ResetPasswordRequest {
  username: string;
  oldPassword: string;
  newPassword: string;
}

/**
 * 登录请求接口
 */
interface LoginRequest {
  username: string;
  password: string;
}

/**
 * 验证用户请求接口
 */
interface VerifyUserRequest {
  username: string;
}

/**
 * 验证密保答案请求接口
 */
interface VerifySecurityAnswerRequest {
  username: string;
  answer: string;
}

/**
 * 发送验证码请求接口
 */
interface SendVerificationCodeRequest {
  username: string;
  contactType: string;
  contactValue: string;
}

/**
 * 验证验证码请求接口
 */
interface VerifyCodeRequest {
  username: string;
  verificationCode: string;
}

/**
 * 忘记密码请求接口
 */
interface ForgotPasswordRequest {
  username: string;
  newPassword: string;
  verifyMethod: 'security' | 'verification';
}

/**
 * HTTP头部接口
 */
class HttpHeader {
  contentType: string = 'application/json';
}

/**
 * HTTP请求选项接口
 */
class HttpRequestOptions {
  method: http.RequestMethod = http.RequestMethod.POST;
  header: HttpHeader = new HttpHeader();
  extraData: string = '';
}

/**
 * HTTP请求参数类
 */
class HttpRequestParams {
  method: http.RequestMethod = http.RequestMethod.POST;
  header: Record<string, string> = {};
  extraData: string = '';

  constructor() {
    this.header = {};
  }

  addHeader(key: string, value: string): void {
    this.header[key] = value;
  }
}

/**
 * 错误信息类
 */
class ErrorObject {
  message: string = '';
}

/**
 * 响应数据包装类
 */
class ResponseDataWrapper {
  private dataMap: Record<string, string | number | boolean | null> = {};
  
  constructor() {
    this.dataMap = {};
  }
  
  setValue(key: string, value: string | number | boolean | null): void {
    this.dataMap[key] = value;
  }
  
  getValue(key: string): string | number | boolean | null {
    return this.dataMap[key];
  }
  
  getAll(): Record<string, string | number | boolean | null> {
    return this.dataMap;
  }
}

/**
 * API服务类
 * 封装了与后端服务器通信的方法
 */
export class ApiService {
  private static readonly apiBaseUrl: string = 'http://192.168.12.85:3001'//wifi

  /**
   * 用户登录
   * @param username 用户名
   * @param password 密码
   * @returns Promise with API response
   */
  static async login(username: string, password: string): Promise<ApiResponse> {
    let httpRequest = http.createHttp()

    try {
      // 构建请求数据
      let requestData: LoginRequest = {
        username: username,
        password: password
      }

      // 创建请求参数
      const requestParams = new HttpRequestParams();
      requestParams.method = http.RequestMethod.POST;
      requestParams.addHeader('Content-Type', 'application/json');
      requestParams.extraData = JSON.stringify(requestData);

      let response = await httpRequest.request(
        `${ApiService.apiBaseUrl}/api/login`,
        requestParams
      )

      // 解析响应数据
      let responseData = JSON.parse(response.result as string) as Record<string, string | number | boolean | null>;

      // 返回符合ApiResponse类型的结构
      const successResponse: ApiResponse = {
        success: response.responseCode === 200 && (responseData.success as boolean),
        message: (responseData.message as string) || '登录成功',
        data: responseData
      }

      return successResponse;
    } catch (error) {
      const errorObj = new ErrorObject();
      errorObj.message = error instanceof Error ? error.message : '网络请求失败';

      const wrapper = new ResponseDataWrapper();
      wrapper.setValue('message', errorObj.message);

      const errorResponse: ApiResponse = {
        success: false,
        message: '登录失败，请检查网络连接',
        error: wrapper.getAll()
      }

      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 重置密码
   * @param username 用户名
   * @param oldPassword 原密码
   * @param newPassword 新密码
   * @returns Promise with API response
   */
  static async resetPassword(username: string, oldPassword: string, newPassword: string): Promise<ApiResponse> {
    // 创建HTTP请求客户端
    let httpRequest = http.createHttp()

    try {
      // 构建请求数据
      let requestData: ResetPasswordRequest = {
        username: username,
        oldPassword: oldPassword,
        newPassword: newPassword
      }

      // 创建请求参数
      const requestParams = new HttpRequestParams();
      requestParams.method = http.RequestMethod.POST;
      requestParams.addHeader('Content-Type', 'application/json');
      requestParams.extraData = JSON.stringify(requestData);

      let response = await httpRequest.request(
        `${ApiService.apiBaseUrl}/api/reset-password`,
        requestParams
      )

      // 解析响应数据
      let responseData = JSON.parse(response.result as string) as Record<string, string | number | boolean | null>;

      // 返回符合ApiResponse类型的结构
      const successResponse: ApiResponse = {
        success: response.responseCode === 200 && (responseData.success as boolean),
        message: (responseData.message as string) || '操作完成',
        data: responseData
      }

      return successResponse;
    } catch (error) {
      // 创建具体类型的错误对象
      const errorObj = new ErrorObject();
      errorObj.message = error instanceof Error ? error.message : '网络请求失败';

      // 创建错误数据包装器
      const wrapper = new ResponseDataWrapper();
      wrapper.setValue('message', errorObj.message);

      const errorResponse: ApiResponse = {
        success: false,
        message: '网络请求失败',
        error: wrapper.getAll()
      }

      return errorResponse;
    } finally {
      // 释放HTTP客户端资源
      httpRequest.destroy();
    }
  }

  /**
   * 验证用户是否存在，并获取用户基本信息（如密保问题）
   * @param username 用户名
   * @returns Promise with API response
   */
  static async verifyUser(username: string): Promise<ApiResponse> {
    let httpRequest = http.createHttp()

    try {
      // 构建请求数据
      let requestData: VerifyUserRequest = {
        username: username
      }

      // 创建请求参数
      const requestParams = new HttpRequestParams();
      requestParams.method = http.RequestMethod.POST;
      requestParams.addHeader('Content-Type', 'application/json');
      requestParams.extraData = JSON.stringify(requestData);

      console.log('verifyUser 发送请求:', `${ApiService.apiBaseUrl}/api/verify-user`, JSON.stringify(requestData));

      let response = await httpRequest.request(
        `${ApiService.apiBaseUrl}/api/verify-user`,
        requestParams
      )

      console.log('verifyUser 原始响应:', response.responseCode, response.result);
      
      // 解析响应数据
      interface UserData {
        username: string;
        question: string;
        hasEmail: boolean;
        hasPhone: boolean;
      }
      
      interface UserResponseData {
        success: boolean;
        message: string;
        data?: UserData;
      }
      
      let responseData = JSON.parse(response.result as string) as UserResponseData;
      console.log('verifyUser 解析后的响应数据:', JSON.stringify(responseData));

      // 检查问题字段
      if (responseData.data) {
        console.log('密保问题检查:', {
          hasQuestion: !!responseData.data.question,
          questionLength: responseData.data.question ? responseData.data.question.length : 0,
          questionValue: responseData.data.question || '未设置'
        });
      } else {
        console.log('响应中没有data字段或data为空');
      }

      // 转换数据为符合ApiResponse的格式
      let apiData: Record<string, string | number | boolean | null> = {};
      
      if (responseData.data) {
        // 将UserData转换为Record<string, string | number | boolean | null>
        apiData['username'] = responseData.data.username;
        apiData['question'] = responseData.data.question;
        apiData['hasEmail'] = responseData.data.hasEmail;
        apiData['hasPhone'] = responseData.data.hasPhone;
      }

      // 返回符合ApiResponse类型的结构
      const successResponse: ApiResponse = {
        success: response.responseCode === 200 && responseData.success,
        message: responseData.message || '验证完成',
        data: apiData
      }

      console.log('verifyUser 处理后返回的响应:', JSON.stringify(successResponse));
      return successResponse;
    } catch (error) {
      console.error('验证用户出错:', error instanceof Error ? error.message : JSON.stringify(error));
      
      const errorObj = new ErrorObject();
      errorObj.message = error instanceof Error ? error.message : '网络请求失败';

      const wrapper = new ResponseDataWrapper();
      wrapper.setValue('message', errorObj.message);

      const errorResponse: ApiResponse = {
        success: false,
        message: '验证用户失败，请检查网络连接',
        error: wrapper.getAll()
      }

      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 验证密保答案
   * @param username 用户名
   * @param answer 密保答案
   * @returns Promise with API response
   */
  static async verifySecurityAnswer(username: string, answer: string): Promise<ApiResponse> {
    let httpRequest = http.createHttp()

    try {
      // 构建请求数据
      let requestData: VerifySecurityAnswerRequest = {
        username: username,
        answer: answer
      }

      // 创建请求参数
      const requestParams = new HttpRequestParams();
      requestParams.method = http.RequestMethod.POST;
      requestParams.addHeader('Content-Type', 'application/json');
      requestParams.extraData = JSON.stringify(requestData);

      let response = await httpRequest.request(
        `${ApiService.apiBaseUrl}/api/verify-security-answer`,
        requestParams
      )

      // 解析响应数据
      let responseData = JSON.parse(response.result as string) as Record<string, string | number | boolean | null>;

      // 返回符合ApiResponse类型的结构
      const successResponse: ApiResponse = {
        success: response.responseCode === 200 && (responseData.success as boolean),
        message: (responseData.message as string) || '验证完成',
        data: responseData
      }

      return successResponse;
    } catch (error) {
      const errorObj = new ErrorObject();
      errorObj.message = error instanceof Error ? error.message : '网络请求失败';

      const wrapper = new ResponseDataWrapper();
      wrapper.setValue('message', errorObj.message);

      const errorResponse: ApiResponse = {
        success: false,
        message: '验证密保答案失败，请检查网络连接',
        error: wrapper.getAll()
      }

      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 发送验证码
   * @param username 用户名
   * @param contactType 联系方式类型 ('phone' | 'email')
   * @param contactValue 联系方式值
   * @returns Promise with API response
   */
  static async sendVerificationCode(username: string, contactType: string, contactValue: string): Promise<ApiResponse> {
    let httpRequest = http.createHttp()

    try {
      // 构建请求数据
      let requestData: SendVerificationCodeRequest = {
        username: username,
        contactType: contactType,
        contactValue: contactValue
      }

      // 创建请求参数
      const requestParams = new HttpRequestParams();
      requestParams.method = http.RequestMethod.POST;
      requestParams.addHeader('Content-Type', 'application/json');
      requestParams.extraData = JSON.stringify(requestData);

      let response = await httpRequest.request(
        `${ApiService.apiBaseUrl}/api/send-verification-code`,
        requestParams
      )

      // 解析响应数据
      let responseData = JSON.parse(response.result as string) as Record<string, string | number | boolean | null>;

      // 返回符合ApiResponse类型的结构
      const successResponse: ApiResponse = {
        success: response.responseCode === 200 && (responseData.success as boolean),
        message: (responseData.message as string) || '验证码已发送',
        data: responseData
      }

      return successResponse;
    } catch (error) {
      const errorObj = new ErrorObject();
      errorObj.message = error instanceof Error ? error.message : '网络请求失败';

      const wrapper = new ResponseDataWrapper();
      wrapper.setValue('message', errorObj.message);

      const errorResponse: ApiResponse = {
        success: false,
        message: '发送验证码失败，请检查网络连接',
        error: wrapper.getAll()
      }

      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 验证验证码
   * @param username 用户名
   * @param verificationCode 验证码
   * @returns Promise with API response
   */
  static async verifyCode(username: string, verificationCode: string): Promise<ApiResponse> {
    let httpRequest = http.createHttp()

    try {
      // 构建请求数据
      let requestData: VerifyCodeRequest = {
        username: username,
        verificationCode: verificationCode
      }

      // 创建请求参数
      const requestParams = new HttpRequestParams();
      requestParams.method = http.RequestMethod.POST;
      requestParams.addHeader('Content-Type', 'application/json');
      requestParams.extraData = JSON.stringify(requestData);

      let response = await httpRequest.request(
        `${ApiService.apiBaseUrl}/api/verify-code`,
        requestParams
      )

      // 解析响应数据
      let responseData = JSON.parse(response.result as string) as Record<string, string | number | boolean | null>;

      // 返回符合ApiResponse类型的结构
      const successResponse: ApiResponse = {
        success: response.responseCode === 200 && (responseData.success as boolean),
        message: (responseData.message as string) || '验证完成',
        data: responseData
      }

      return successResponse;
    } catch (error) {
      const errorObj = new ErrorObject();
      errorObj.message = error instanceof Error ? error.message : '网络请求失败';

      const wrapper = new ResponseDataWrapper();
      wrapper.setValue('message', errorObj.message);

      const errorResponse: ApiResponse = {
        success: false,
        message: '验证码验证失败，请检查网络连接',
        error: wrapper.getAll()
      }

      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 忘记密码 - 重置密码（不需要旧密码）
   * @param username 用户名
   * @param newPassword 新密码
   * @param verifyMethod 验证方式 ('security' | 'verification')
   * @returns Promise with API response
   */
  static async forgotPassword(username: string, newPassword: string, verifyMethod: 'security' | 'verification'): Promise<ApiResponse> {
    let httpRequest = http.createHttp()

    try {
      // 构建请求数据
      let requestData: ForgotPasswordRequest = {
        username: username,
        newPassword: newPassword,
        verifyMethod: verifyMethod
      }

      // 创建请求参数
      const requestParams = new HttpRequestParams();
      requestParams.method = http.RequestMethod.POST;
      requestParams.addHeader('Content-Type', 'application/json');
      requestParams.extraData = JSON.stringify(requestData);

      let response = await httpRequest.request(
        `${ApiService.apiBaseUrl}/api/forgot-password`,
        requestParams
      )

      // 解析响应数据
      let responseData = JSON.parse(response.result as string) as Record<string, string | number | boolean | null>;

      // 返回符合ApiResponse类型的结构
      const successResponse: ApiResponse = {
        success: response.responseCode === 200 && (responseData.success as boolean),
        message: (responseData.message as string) || '密码重置成功',
        data: responseData
      }

      return successResponse;
    } catch (error) {
      const errorObj = new ErrorObject();
      errorObj.message = error instanceof Error ? error.message : '网络请求失败';

      const wrapper = new ResponseDataWrapper();
      wrapper.setValue('message', errorObj.message);

      const errorResponse: ApiResponse = {
        success: false,
        message: '密码重置失败，请检查网络连接',
        error: wrapper.getAll()
      }

      return errorResponse;
    } finally {
      httpRequest.destroy();
    }
  }
}
