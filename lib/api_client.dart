import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

// API 응답 모델
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(success: true, data: data);
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

// API 클라이언트 클래스
class ApiClient {
  static const String _baseUrl = 'http://sungtak.iptime.org:8000'; // 실제 API 서버 URL로 변경
  static const Duration _timeout = Duration(seconds: 2);

  late Dio _dio;

  // 싱글톤 패턴
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _initializeDio();
  }

  // Dio 초기화
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 인터셉터 추가
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 요청 전에 토큰 추가
        await _addAuthToken(options);
        print('🌐 API 요청: ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ API 응답: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ API 에러: ${error.response?.statusCode} ${error.message}');
        handler.next(error);
      },
    ));
  }

  // 인증 토큰 추가
  Future<void> _addAuthToken(RequestOptions options) async {
    try {
      // 현재 로그인한 사용자의 토큰 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (e) {
      print('⚠️ 토큰 가져오기 실패: $e');
    }
  }

  // GET 요청
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(response.data as T);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // POST 요청
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(response.data as T);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // PUT 요청
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(response.data as T);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // DELETE 요청
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(response.data as T);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // PATCH 요청
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(response.data as T);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // Dio 에러 처리
  ApiResponse<T> _handleDioError<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.error('서버 연결 시간이 초과되었습니다.');
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? '서버 오류가 발생했습니다.';
        
        switch (statusCode) {
          case 400:
            return ApiResponse.error('잘못된 요청입니다: $message', statusCode: statusCode);
          case 401:
            return ApiResponse.error('인증이 필요합니다: $message', statusCode: statusCode);
          case 403:
            return ApiResponse.error('접근이 거부되었습니다: $message', statusCode: statusCode);
          case 404:
            return ApiResponse.error('요청한 리소스를 찾을 수 없습니다: $message', statusCode: statusCode);
          case 500:
            return ApiResponse.error('서버 내부 오류가 발생했습니다: $message', statusCode: statusCode);
          default:
            return ApiResponse.error('서버 오류가 발생했습니다: $message', statusCode: statusCode);
        }
      
      case DioExceptionType.cancel:
        return ApiResponse.error('요청이 취소되었습니다.');
      
      case DioExceptionType.connectionError:
        return ApiResponse.error('인터넷 연결을 확인해주세요.');
      
      default:
        return ApiResponse.error('네트워크 오류가 발생했습니다: ${e.message}');
    }
  }

  // 사용자 관련 API 메서드들
  Future<ApiResponse<Map<String, dynamic>>> loginWithGoogle(String idToken) async {
    // 헤더에만 토큰을 포함하고 body는 비움 (서버가 헤더에서만 토큰을 받음)
    return post<Map<String, dynamic>>('/auth/google');
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    return get<Map<String, dynamic>>('/user/profile');
  }

  Future<ApiResponse<Map<String, dynamic>>> updateUserProfile(Map<String, dynamic> data) async {
    return put<Map<String, dynamic>>('/user/profile', data: data);
  }

  Future<ApiResponse<Map<String, dynamic>>> registerUser(Map<String, dynamic> userData) async {
    return post<Map<String, dynamic>>('/auth/register', data: userData);
  }

  Future<ApiResponse<Map<String, dynamic>>> loginUser(String email, String password) async {
    return post<Map<String, dynamic>>('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<ApiResponse<void>> logout() async {
    return post<void>('/auth/logout');
  }
}

// API 엔드포인트 상수
class ApiEndpoints {
  // 인증 관련
  static const String googleLogin = '/auth/google';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  
  // 사용자 관련
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  
  // 기타 API 엔드포인트들
  static const String posts = '/posts';
  static const String comments = '/comments';
} 