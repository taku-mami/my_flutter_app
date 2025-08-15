import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../utils/config.dart';
import 'landing.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

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
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 상단 로고/제목 영역
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 앱 로고 (PNG 이미지 사용)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue[600]!.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icons/dive_logo.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
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
                      
                      // // 부제목
                      // Text(
                      //   '지능형 대화 어시스턴트',
                      //   style: TextStyle(
                      //     color: Colors.grey[400],
                      //     fontSize: 16,
                      //     letterSpacing: 0.5,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              
              // // 중간 설명 텍스트 영역
              // Expanded(
              //   flex: 1,
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 40),
              //     child: Column(
              //       children: [
              //         // 환영 메시지
              //         const Text(
              //           '환영합니다!',
              //           style: TextStyle(
              //             color: Colors.white,
              //             fontSize: 24,
              //             fontWeight: FontWeight.w600,
              //           ),
              //           textAlign: TextAlign.center,
              //         ),
              //         const SizedBox(height: 15),
                      
              //         // 설명 텍스트
              //         Text(
              //           'Google 계정으로 간편하게 로그인하고\n시작하세요',
              //           style: TextStyle(
              //             color: Colors.grey[400],
              //             fontSize: 16,
              //             height: 1.5,
              //           ),
              //           textAlign: TextAlign.center,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              
              // 하단 로그인 버튼 영역
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google 로그인 버튼
                      GoogleLoginButton(
                        onSignIn: _isLoading ? null : () => _handleSignIn(context),
                        isLoading: _isLoading,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 개발 모드 표시
                      if (Config.isDevelopmentMode)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.developer_mode,
                                color: Colors.orange[400],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '개발 모드',
                                style: TextStyle(
                                  color: Colors.orange[400],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 30),
                      
                      // // 하단 안내 텍스트
                      // Text(
                      //   '로그인 시 서비스 이용약관과 개인정보처리방침에\n동의하는 것으로 간주됩니다',
                      //   style: TextStyle(
                      //     color: Colors.grey[500],
                      //     fontSize: 12,
                      //     height: 1.4,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Google 로그인 처리
  void _handleSignIn(BuildContext context) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await _authService.signInWithGoogle();
      
      if (result.success && context.mounted) {
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.isDevelopmentMode ? Colors.orange : Colors.green,
          ),
        );
        
        // 메인 페이지로 이동
        Future.delayed(const Duration(milliseconds: 200), () {
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const Landing(),
              ),
            );
          }
        });
      } else if (context.mounted) {
        // 실패 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Google 로그인 버튼 위젯
class GoogleLoginButton extends StatelessWidget {
  final VoidCallback? onSignIn;
  final bool isLoading;

  const GoogleLoginButton({
    super.key,
    required this.onSignIn,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: isLoading ? Colors.grey[300] : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onSignIn,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  // 로딩 인디케이터
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                    ),
                  )
                else
                  // Google 로고
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://developers.google.com/identity/images/g-logo.png',
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                
                const SizedBox(width: 16),
                
                // 버튼 텍스트
                Text(
                  isLoading ? '로그인 중...' : 'Google로 로그인',
                  style: TextStyle(
                    color: isLoading ? Colors.grey[600] : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
