// Flutter 앱의 기본 패키지들을 import
import 'package:flutter/material.dart';
// Google Sign-In 기능을 위한 패키지
import 'package:google_sign_in/google_sign_in.dart';
// SVG 이미지를 사용하기 위한 패키지
import 'package:flutter_svg/flutter_svg.dart';

// 앱의 진입점 함수
void main() {
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

    return Scaffold(
      backgroundColor: Colors.black, // 전체 배경을 검정색으로 설정
      body: Stack(
        children: [
          // 배경 타자기 효과 - 화면 중간에 "안녕" 텍스트가 타자기처럼 나타남
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3, // 화면 높이의 30% 지점에 배치
            left: 0, // 왼쪽 끝
            right: 0, // 오른쪽 끝 (가로 전체 너비 사용)
            child: Center(
              child: TypingText(text: '안녕하세요'), // 타자기 효과로 "안녕" 표시
            ),
          ),
          // 화면 하단에 카드 형태의 컨테이너를 배치
          Align(
            alignment: Alignment.bottomCenter, // 하단 중앙 정렬
            child: Container(
              height: screenHeight * 0.3, // 화면 높이의 30%만큼 사용
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
                  // 첫 번째 버튼: Google로 계속하기
                  GoogleLoginButton(),
                  SizedBox(height: 12), // 버튼 간 여백
                  // 두 번째 버튼: 회원가입
                  _buildLoginButton(
                    "회원가입",
                    Icons.person_add, // 사람 추가 아이콘
                    Colors.grey[800]!, // 배경색: 어두운 회색
                  ),
                  SizedBox(height: 12), // 버튼 간 여백
                  // 세 번째 버튼: 일반 로그인
                  _buildLoginButton(
                    "로그인",
                    Icons.person, // 사람 아이콘
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

// Google 로그인 버튼 위젯
class GoogleLoginButton extends StatelessWidget {
  // Google Sign-In 인스턴스 생성
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email', // 이메일 정보 요청
      'profile', // 프로필 정보 요청
    ],
  );

  // Google 로그인 처리 함수
  void _handleSignIn(BuildContext context) async {
    try {
      // Google 로그인 시도
      final account = await _googleSignIn.signIn();
      if (account != null) {
        // 로그인 성공 시
        print("✅ 로그인 성공: ${account.email}");
        // 여기에 Firebase 연동 or 백엔드 처리 등 연결 가능
      } else {
        // 로그인 취소 시
        print("❌ 로그인 취소됨");
      }
    } catch (error) {
      // 로그인 실패 시
      print("🚨 로그인 실패: $error");
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