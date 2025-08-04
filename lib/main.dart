// Flutter 앱의 기본 패키지들을 import
import 'package:flutter/material.dart';
// Google Sign-In 기능을 위한 패키지
import 'package:google_sign_in/google_sign_in.dart';
// Firebase 관련 패키지들
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// SVG 이미지를 사용하기 위한 패키지
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert'; // Base64 디코딩을 위한 패키지
// API 클라이언트
import 'api_client.dart';

// 앱 설정을 관리하는 클래스
class AppConfig {
  // 싱글톤 패턴으로 설정 인스턴스 관리
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // 버튼 표시 설정
  bool showGoogleLoginButton = true; // Google 로그인 버튼 표시 여부 (기본값: true)
  bool showSignUpButton = false; // 회원가입 버튼 표시 여부
  bool showLocalLoginButton = false; // 로컬 로그인 버튼 표시 여부

  // 설정 변경 메서드
  void updateButtonSettings({
    bool? showSignUp,
    bool? showLocalLogin,
    bool? showGoogleLogin,
  }) {
    if (showSignUp != null) showSignUpButton = showSignUp;
    if (showLocalLogin != null) showLocalLoginButton = showLocalLogin;
    if (showGoogleLogin != null) showGoogleLoginButton = showGoogleLogin;
  }

  // 현재 활성화된 버튼 개수 반환
  int get activeButtonCount {
    int count = 0;
    if (showGoogleLoginButton) count++;
    if (showSignUpButton) count++;
    if (showLocalLoginButton) count++;
    return count;
  }
}

// 앱의 진입점 함수
void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화 (iOS 13.0 업데이트 후 활성화)
  await Firebase.initializeApp();
  
  // 앱 설정 초기화
  final appConfig = AppConfig();
  
  // 설정 예시들 (원하는 설정으로 변경하세요)
  
  // 예시: Google 로그인만 표시
  // appConfig.updateButtonSettings(
  //   showGoogleLogin: true,
  //   showSignUp: false,
  //   showLocalLogin: false,
  // );
  
  // Flutter 앱을 실행
  runApp(const MyApp());
}

// 메인 앱 위젯 클래스
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 앱의 루트 위젯을 빌드
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(), // 메인 화면으로 LoginScreen을 지정
      debugShowCheckedModeBanner: false, // 디버그 배너 제거 (우상단의 DEBUG 표시 제거)
    );
  }
}

// 커스텀 타자기 위젯 - 텍스트가 한 글자씩 나타나는 애니메이션 효과
class TypingText extends StatefulWidget {
  // 표시할 텍스트
  final String text;
  // 각 글자당 타이핑 속도
  final Duration duration;

  // 생성자 - text는 필수, duration은 기본값 200ms (기존 100ms에서 늘림)
  const TypingText({required this.text, this.duration = const Duration(milliseconds: 100)});

  @override
  _TypingTextState createState() => _TypingTextState();
}

// TypingText의 상태 관리 클래스
class _TypingTextState extends State<TypingText> with SingleTickerProviderStateMixin {
  // 애니메이션을 제어하는 컨트롤러
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 애니메이션 컨트롤러 초기화
    // 전체 애니메이션 시간 = 글자 수 × 각 글자당 시간
    _controller = AnimationController(
      duration: widget.duration * widget.text.length,
      vsync: this, // 애니메이션의 프레임 동기화를 위한 vsync
    );
    
    // 애니메이션 시작 및 반복 설정
    _startAnimation();
  }

  // 애니메이션 시작 및 반복 함수
  void _startAnimation() {
    _controller.forward().then((_) {
      // 애니메이션이 끝나면 1초 대기 후 다시 시작
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) { // 위젯이 여전히 존재하는지 확인
          _controller.reset(); // 애니메이션을 처음으로 되돌림
          _startAnimation(); // 다시 시작
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 애니메이션 빌더 - 애니메이션 값이 변경될 때마다 위젯을 다시 빌드
    return AnimatedBuilder(
      animation: _controller, // 감시할 애니메이션
      builder: (context, child) {
        // 현재까지 표시할 글자 수 계산 (0.0 ~ 1.0 값을 글자 수로 변환)
        int currentCount = (_controller.value * widget.text.length).floor();
        // 현재까지의 글자들만 표시
        return Text(
          widget.text.substring(0, currentCount),
          style: TextStyle(
            fontSize: 60, // 글자 크기
            color: Colors.white.withOpacity(0.3), // 흰색에 30% 투명도
            fontWeight: FontWeight.bold, // 굵은 글씨
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // 위젯이 제거될 때 애니메이션 컨트롤러도 정리 (메모리 누수 방지)
    _controller.dispose();
    super.dispose();
  }
}

// 로그인 화면 위젯
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 기기의 화면 높이를 가져와서 카드 높이 계산에 사용
    final screenHeight = MediaQuery.of(context).size.height;
    final appConfig = AppConfig(); // 설정 인스턴스 가져오기

    return Scaffold(
      backgroundColor: Colors.black, // 전체 배경을 검정색으로 설정
      body: Stack(
        children: [
          // 배경 타자기 효과 - 화면 중간에 텍스트가 타자기처럼 나타남
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3, // 화면 높이의 30% 지점에 배치
            left: 0, // 왼쪽 끝
            right: 0, // 오른쪽 끝 (가로 전체 너비 사용)
            child: Center(
              child: TypingText(text: '반갑습니다'), // 타자기 효과
            ),
          ),
          // 화면 하단에 카드 형태의 컨테이너를 배치
          Align(
            alignment: Alignment.bottomCenter, // 하단 중앙 정렬
            child: Container(
              // 동적 높이 계산: 버튼 개수에 따라 높이 조정
              height: _calculateCardHeight(screenHeight, appConfig.activeButtonCount),
              width: double.infinity, // 너비는 화면 전체
              padding: EdgeInsets.all(20), // 내부 여백 20px
              decoration: BoxDecoration(
                color: Colors.grey[900], // 카드 배경을 어두운 회색으로 설정
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24), // 위쪽 모서리만 둥글게 처리
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // 상단 정렬로 변경
                crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙 정렬
                children: [
                  SizedBox(height: 16), // 상단 여백 추가
                  // 동적으로 버튼들 생성
                  ..._buildButtons(appConfig),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 카드 높이를 동적으로 계산하는 메서드
  double _calculateCardHeight(double screenHeight, int buttonCount) {
    if (buttonCount == 0) {
      return screenHeight * 0.15; // 버튼이 없으면 최소 높이
    } else if (buttonCount == 1) {
      return screenHeight * 0.2; // 버튼 1개
    } else if (buttonCount == 2) {
      return screenHeight * 0.25; // 버튼 2개
    } else {
      return screenHeight * 0.3; // 버튼 3개 (기존)
    }
  }

  // 설정에 따라 버튼들을 동적으로 생성하는 메서드
  List<Widget> _buildButtons(AppConfig config) {
    List<Widget> buttons = [];

    // Google 로그인 버튼
    if (config.showGoogleLoginButton) {
      buttons.add(GoogleLoginButton());
      if (config.showSignUpButton || config.showLocalLoginButton) {
        buttons.add(SizedBox(height: 12));
      }
    }

    // 회원가입 버튼
    if (config.showSignUpButton) {
      buttons.add(LocalSignUpButton());
      if (config.showLocalLoginButton) {
        buttons.add(SizedBox(height: 12));
      }
    }

    // 로컬 로그인 버튼
    if (config.showLocalLoginButton) {
      buttons.add(LocalSignInButton());
    }

    return buttons;
  }
}

// Google 로그인 버튼 위젯
class GoogleLoginButton extends StatelessWidget {
  // Google Sign-In 인스턴스 생성
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email', // 이메일 정보 요청
      'profile', // 프로필 정보 요청
    ],
  );

  // Google 로그인 처리 함수 (Firebase 연동)
  void _handleSignIn(BuildContext context) async {
    print("🔍 로그인 시도");
    try {
      // 1. Google 로그인 시도
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser != null) {
        print("✅ Google 로그인 성공: ${googleUser.email}");
        
        // Firebase가 초기화되지 않은 경우 기본 Google 정보만 사용
        try {
          // 2. Google 인증 정보 가져오기
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          
          // JWT 토큰 구조 분석
          // _decodeJwtToken(googleAuth.idToken);
          
          // Firebase가 사용 가능한지 확인
          try {
            // 3. Firebase 인증 정보 생성
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            
            // 4. Firebase에 로그인하여 ID 토큰 받기
            final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
            final User? user = userCredential.user;
            
            if (user != null) {
              // 5. Firebase ID 토큰 가져오기
              final String? idToken = await user.getIdToken();
              
              print("✅ Firebase 로그인 성공!");
              
              // 6. 사용자 정보 출력
              final name = user.displayName ?? googleUser.displayName;
              print("🔍 이름: $name");
              print("🔍 이메일: ${user.email}");
              print("🔍 프로필 사진: ${user.photoURL}");
              
              // 7. 서버로 Firebase ID 토큰 전송
              if (idToken != null) {
                await _sendTokenToServer(idToken);
              }
              
              // 8. 성공 메시지 표시
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Firebase 로그인 성공! UID: ${user.uid}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              
            } else {
              print("❌ Firebase 로그인 실패");
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Firebase 로그인에 실패했습니다'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } catch (firebaseError) {
            // Firebase가 사용 불가능한 경우 기본 Google 정보만 사용
            print("⚠️ Firebase 사용 불가: $firebaseError");
            
            final name = googleUser.displayName;
            final email = googleUser.email;
            final photoUrl = googleUser.photoUrl;
            
            print("🔍 이름: $name");
            print("🔍 이메일: $email");
            print("🔍 프로필 사진: $photoUrl");
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Google 로그인 성공! (Firebase 미연동)'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
          
        } catch (authError) {
          print("❌ Google 인증 정보 가져오기 실패: $authError");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Google 인증 정보를 가져올 수 없습니다'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        
      } else {
        // 로그인 취소 시
        print("❌ 로그인 취소됨");
      }
    } catch (error) {
      // 로그인 실패 시
      print("🚨 로그인 실패: $error");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 중 오류가 발생했습니다: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ID 토큰을 서버로 전송하는 함수
  Future<void> _sendTokenToServer(String? idToken) async {
    if (idToken == null) return;
    
    try {
      print("📤 서버로 Firebase ID 토큰 전송 중...");
      
      // API 클라이언트 사용
      final apiClient = ApiClient();
      final response = await apiClient.loginWithGoogle(idToken);
      
      if (response.success) {
        print("✅ 서버 전송 성공: ${response.data}");
      } else {
        print("❌ 서버 전송 실패: ${response.message}");
      }
    } catch (error) {
      print("❌ 서버 전송 중 오류: $error");
    }
  }

  // JWT 토큰 디코딩 함수
  void _decodeJwtToken(String? token) {
    if (token == null) return;
    
    try {
      // JWT는 3부분으로 구성: header.payload.signature
      final parts = token.split('.');
      if (parts.length == 3) {
        print("🔍 JWT 토큰 구조:");
        print("  Header: ${parts[0]}");
        print("  Payload: ${parts[1]}");
        print("  Signature: ${parts[2]}"); // 전체 시그니처 표시
        
        // Base64 디코딩 (간단한 방법)
        try {
          final payload = parts[1];
          // Base64 패딩 추가
          final paddedPayload = payload + '=' * (4 - payload.length % 4);
          final decodedPayload = utf8.decode(base64Url.decode(paddedPayload));
          print("  Decoded Payload: $decodedPayload");
        } catch (e) {
          print("  Payload 디코딩 실패: $e");
        }
      }
    } catch (e) {
      print("❌ JWT 디코딩 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // 버튼의 너비를 카드 영역 전체로
      child: ElevatedButton.icon(
        onPressed: () => _handleSignIn(context), // Google 로그인 함수 호출
        icon: SvgPicture.asset(
          'assets/icons/google_logo.svg', // Google 공식 로고 SVG
          width: 24, // 아이콘 너비
          height: 24, // 아이콘 높이
        ),
        label: Text(
          "Google로 계속하기",
          style: TextStyle(fontSize: 16), // 글씨 크기를 16으로 설정
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800], // 어두운 회색으로 변경
          foregroundColor: Colors.white, // 텍스트 색상을 흰색으로 변경
          padding: EdgeInsets.symmetric(vertical: 14), // 상하 패딩
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 버튼 모서리 둥글게
          ),
        ),
      ),
    );
  }
}

// 로컬 회원가입 버튼 위젯
class LocalSignUpButton extends StatelessWidget {
  // 로컬 회원가입 처리 함수
  void _handleSignUp(BuildContext context) async {
    print("🔍 회원가입 시도");
    try {
      // 회원가입 다이얼로그 표시
      final result = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: false, // 배경 터치로 닫기 방지
        builder: (BuildContext context) {
          return SignUpDialog();
        },
      );
      
      if (result != null) {
        print("✅ 회원가입 정보: $result");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입이 완료되었습니다!')),
          );
        }
      }
    } catch (error) {
      print("🚨 회원가입 실패: $error");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 중 오류가 발생했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // 버튼의 너비를 카드 영역 전체로
      child: ElevatedButton.icon(
        onPressed: () => _handleSignUp(context), // 회원가입 함수 호출
        icon: Icon(Icons.person_add), // 사람 추가 아이콘
        label: Text(
          "회원가입",
          style: TextStyle(fontSize: 16), // 글씨 크기를 16으로 설정
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800], // 어두운 회색
          foregroundColor: Colors.white, // 텍스트 색상을 흰색으로
          padding: EdgeInsets.symmetric(vertical: 14), // 상하 패딩
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 버튼 모서리 둥글게
          ),
        ),
      ),
    );
  }
}

// 회원가입 다이얼로그 위젯
class SignUpDialog extends StatefulWidget {
  @override
  _SignUpDialogState createState() => _SignUpDialogState();
}

class _SignUpDialogState extends State<SignUpDialog> {
  // 텍스트 컨트롤러들
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // 비밀번호 표시/숨김 상태
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // 폼 검증을 위한 키
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // 컨트롤러 정리
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 회원가입 처리 함수
  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      // 폼이 유효하면 데이터 반환
      final userData = {
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text,
      };
      Navigator.of(context).pop(userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900], // 다이얼로그 배경색
      title: Text(
        '회원가입',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 이메일 입력 필드
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '이메일',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.email, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return '올바른 이메일 형식을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // 사용자명 입력 필드
              TextFormField(
                controller: _usernameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '사용자명',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.person, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '사용자명을 입력해주세요';
                  }
                  if (value.length < 2) {
                    return '사용자명은 2자 이상 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // 비밀번호 입력 필드
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.lock, color: Colors.grey[400]),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 6자 이상 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // 비밀번호 확인 입력 필드
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호 확인을 입력해주세요';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        // 취소 버튼
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
          child: Text(
            '취소',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
        // 회원가입 버튼
        ElevatedButton(
          onPressed: _handleSignUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('회원가입'),
        ),
      ],
    );
  }
}

// 로컬 로그인 버튼 위젯
class LocalSignInButton extends StatelessWidget {
  // 로컬 로그인 처리 함수
  void _handleSignIn(BuildContext context) async {
    print("🔍 로컬 로그인 시도");
    try {
      // 여기에 로컬 로그인 로직 구현
      // 예: 이메일/비밀번호 입력 다이얼로그, API 호출 등
      print("✅ 로컬 로그인 화면으로 이동");
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 기능은 준비 중입니다')),
        );
      }
    } catch (error) {
      print("🚨 로컬 로그인 실패: $error");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 중 오류가 발생했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // 버튼의 너비를 카드 영역 전체로
      child: ElevatedButton.icon(
        onPressed: () => _handleSignIn(context), // 로컬 로그인 함수 호출
        icon: Icon(Icons.person), // 사람 아이콘
        label: Text(
          "로그인",
          style: TextStyle(fontSize: 16), // 글씨 크기를 16으로 설정
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800], // 어두운 회색
          foregroundColor: Colors.white, // 텍스트 색상을 흰색으로
          padding: EdgeInsets.symmetric(vertical: 14), // 상하 패딩
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 버튼 모서리 둥글게
          ),
        ),
      ),
    );
  }
}