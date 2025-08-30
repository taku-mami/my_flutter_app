import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api.dart';
import '../utils/config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();
  
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiClient _apiClient = ApiClient();
  
  // 현재 사용자 가져오기
  User? get currentUser => _auth.currentUser;
  
  // 로그인 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Google 로그인 처리
  Future<AuthResult> signInWithGoogle() async {
    try {
      print('🔍 로그인 시도');
      
      // Google 로그인 시도
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ 로그인 취소됨');
        throw AuthException('로그인이 취소되었습니다');
      }
      
      print('✅ Google 로그인 성공: ${googleUser.email}');
      
      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Firebase 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      
      if (user != null) {
        print('✅ Firebase 로그인 성공!');
        print('🔍 이름: ${user.displayName}');
        print('🔍 이메일: ${user.email}');
        print('🔍 프로필 사진: ${user.photoURL}');
        
        // ID 토큰 가져오기
        final String? idToken = await user.getIdToken();
        
        // 서버 검증 (개발 모드에서는 스킵)
        bool serverResponse = false;
        if (Config.isDevelopmentMode) {
          print("🔧 개발모드: 서버 검증 스킵");
          serverResponse = true;
        } else if (idToken != null) {
          print("🌐 프로덕션 모드: 서버 검증 수행");
          serverResponse = await _sendTokenToServer(idToken);
        }
        
        if (serverResponse) {
          return AuthResult(
            success: true,
            user: user,
            message: Config.isDevelopmentMode
                ? '개발모드: 서버 검증 스킵됨! UID: ${user.uid}'
                : '서버 인증 성공! UID: ${user.uid}',
            isDevelopmentMode: Config.isDevelopmentMode,
          );
        } else {
          return AuthResult(
            success: false,
            user: null,
            message: '서버 인증에 실패했습니다',
            isDevelopmentMode: false,
          );
        }
      } else {
        throw AuthException('Firebase 로그인에 실패했습니다');
      }
    } catch (error) {
      print('❌ 로그인 오류: $error');
      throw AuthException('로그인 중 오류가 발생했습니다: $error');
    }
  }
  
  // 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('✅ 로그아웃 완료');
    } catch (error) {
      print('❌ 로그아웃 오류: $error');
      throw AuthException('로그아웃 중 오류가 발생했습니다: $error');
    }
  }
  
  // 서버에 토큰 전송
  Future<bool> _sendTokenToServer(String idToken) async {
    try {
      final response = await _apiClient.loginWithGoogle(idToken);
      return response.success;
    } catch (e) {
      print('❌ 서버 통신 오류: $e');
      return false;
    }
  }
}

// 인증 결과 클래스
class AuthResult {
  final bool success;
  final User? user;
  final String message;
  final bool isDevelopmentMode;
  
  AuthResult({
    required this.success,
    required this.user,
    required this.message,
    required this.isDevelopmentMode,
  });
}

// 인증 예외 클래스
class AuthException implements Exception {
  final String message;
  
  AuthException(this.message);
  
  @override
  String toString() => message;
}
