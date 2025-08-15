// Flutter 앱의 기본 패키지들을 import
import 'package:flutter/material.dart';
// Firebase 관련 패키지들
import 'package:firebase_core/firebase_core.dart';
// 카카오 지도 플러그인
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
// 페이지들
import 'pages/login.dart';
import 'pages/landing.dart';
import 'pages/service.dart';
import 'pages/settings.dart';
// 서비스들
import 'services/auth.dart';
// 설정
import 'utils/config.dart';

// 앱의 진입점 함수
void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp();
  
  // 카카오 지도 플러그인 초기화
  AuthRepository.initialize(appKey: Config.kakaoMapApiKey);
  
  // 앱 설정 초기화
  // final appConfig = AppConfig(); // 주석 처리
  
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
      title: Config.appName,
      theme: ThemeData.dark().copyWith(
        // 다크 테마 기본 설정
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        // 키보드 관련 색상 설정
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/service': (context) => const ServicePage(),
        '/settings': (context) => const SettingsPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// 인증 상태에 따른 라우팅을 처리하는 위젯
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        // 인증된 사용자가 있으면 메인 페이지로
        if (snapshot.hasData && snapshot.data != null) {
          return const Landing();
        }
        
        // 인증되지 않은 사용자는 로그인 페이지로
        return const LoginPage();
      },
    );
  }
}

// 스플래시 화면
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue[600]!.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 30),
              
              // 앱 이름
              const Text(
                '해운대 DIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              
              // 부제목
              Text(
                '부제목',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),
              
              // 로딩 인디케이터
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}