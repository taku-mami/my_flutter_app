import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(), // 메인 화면으로 LoginScreen을 지정
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
    );
  }
}

// 배경 애니메이션 위젯
class BackgroundAnimation extends StatefulWidget {
  @override
  _BackgroundAnimationState createState() => _BackgroundAnimationState();
}

class _BackgroundAnimationState extends State<BackgroundAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.3, // 카드 위쪽 중간 영역
          left: 0,
          right: 0,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Center(
              child: Text(
                '안녕',
                style: TextStyle(
                  fontSize: 60,
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 로그인 화면
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 기기의 화면 높이 가져오기 (20% 계산용)
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black, // 전체 배경을 검정색으로 설정
      body: Stack(
        children: [
          // 배경 애니메이션 효과
          BackgroundAnimation(),
          // 화면 하단에 카드 형태의 컨테이너를 배치
          Align(
            alignment: Alignment.bottomCenter, // 하단 중앙 정렬
            child: Container(
              height: screenHeight * 0.3, // 화면 높이의 30%로 증가 (20% → 30%)
              width: double.infinity, // 너비는 화면 전체
              padding: EdgeInsets.all(20), // 내부 여백
              decoration: BoxDecoration(
                color: Colors.grey[900], // 카드 배경을 더 어두운 회색으로 변경
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24), // 위쪽 모서리 둥글게 처리
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // 상단 정렬로 변경
                crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙 정렬
                children: [
                  SizedBox(height: 16), // 상단 여백 추가
                  // 첫 번째 버튼: Google로 계속하기
                  GoogleLoginButton(),
                  SizedBox(height: 12), // 버튼 간 여백
                  // 두 번째 버튼: 회원가입
                  _buildLoginButton(
                    "회원가입",
                    Icons.person_add,
                    Colors.grey[800]!, // 배경색: 어두운 회색
                  ),
                  SizedBox(height: 12), // 버튼 간 여백
                  // 세 번째 버튼: 일반 로그인
                  _buildLoginButton(
                    "로그인",
                    Icons.person,
                    Colors.grey[800]!, // 배경색: 어두운 회색 (다른 버튼들과 동일)
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 로그인 버튼을 생성하는 함수 (재사용 가능)
  Widget _buildLoginButton(String text, IconData icon, Color color) {
    return SizedBox(
      width: double.infinity, // 버튼의 너비를 카드 영역 전체로
      child: ElevatedButton.icon(
        onPressed: () {
          // 버튼 클릭 시 수행할 작업 (현재는 비어 있음)
        },
        icon: Icon(icon), // 왼쪽에 표시될 아이콘
        label: Text(
          text,
          style: TextStyle(fontSize: 16), // 글씨 크기를 16으로 설정
        ), // 버튼 텍스트
        style: ElevatedButton.styleFrom(
          foregroundColor: color == Colors.transparent ? Colors.black : Colors.white, // 투명 배경일 때는 검정 텍스트
          backgroundColor: color, // 버튼 배경색
          padding: EdgeInsets.symmetric(vertical: 14), // 상하 패딩
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 버튼 모서리 둥글게
            side: color == Colors.transparent ? BorderSide(color: Colors.grey[400]!, width: 1) : BorderSide.none, // 투명 배경일 때만 테두리 추가
          ),
        ),
      ),
    );
  }
}

class GoogleLoginButton extends StatelessWidget {
  GoogleLoginButton({super.key}); // 위젯의 고유 키

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
    ],
  );

  void _handleSignIn(BuildContext context) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        print("✅ 로그인 성공: ${account.email}");
      } else {
        print("❌ 로그인 취소됨");
      }
    } catch (error) {
      print("🚨 로그인 실패: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // 버튼의 너비를 카드 영역 전체로
      child: ElevatedButton.icon(
        onPressed: () => _handleSignIn(context),
        icon: SvgPicture.asset(
          'assets/icons/google_logo.svg',
          width: 24,
          height: 24,
        ),
        label: Text(
          "Google로 계속하기",
          style: TextStyle(fontSize: 16), // 글씨 크기를 16으로 설정
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800], // 어두운 회색으로 변경
          foregroundColor: Colors.white, // 텍스트 색상을 흰색으로 변경
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 버튼 모서리 둥글게
          ),
        ),
      ),
    );
  }
}