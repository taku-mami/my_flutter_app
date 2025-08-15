import 'package:flutter/material.dart';
import 'package:my_flutter_app/pages/login.dart';
import '../utils/config.dart';
import '../services/auth.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/app_drawer.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDrawerOpen = false; // 드로어 상태 추적

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 자동으로 키보드 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    String message = _controller.text.trim();
    if (message.isNotEmpty) {
      // 여기에서 메시지를 처리하거나 전송하는 로직을 추가하세요.
      print('전송된 메시지: $message');
      _controller.clear();
      // 메시지 전송 후 다시 키보드에 포커스
      _focusNode.requestFocus();
    }
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 배경을 투명하게 설정
      drawer: const AppDrawer(), // 왼쪽 드로어 메뉴 추가
      drawerScrimColor: Colors.transparent, // 기본 스크림 색상 제거
      onDrawerChanged: (isOpen) {
        setState(() {
          _isDrawerOpen = isOpen;
        });
      },
      body: Stack(
        children: [
          // 메인 콘텐츠 (항상 검은색 배경)
          Container(
            color: Colors.black,
            child: Column(
              children: [
                // 상단 앱바
                Builder(
                  builder: (context) => CustomAppBar(
                    title: '해운대 DIVE',
                    showMenuButton: true,
                    onMenuPressed: () {
                      // 왼쪽에서 드로어 메뉴 열기
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                
                // 상단 환영 메시지 영역 - 터치하면 키보드 내려감
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // 키보드 포커스 해제하여 키보드 내리기
                      _focusNode.unfocus();
                    },
                    child: Container(
                      color: Colors.transparent, // 터치 이벤트를 받을 수 있도록 투명 배경
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${AuthService().currentUser?.displayName}님, 반갑습니다.',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 하단 챗봇 입력 영역 - 터치해도 키보드 유지
                Container(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: 32.0, // 아래 여백을 32.0으로 증가
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    // border: Border(
                    //   top: BorderSide(
                    //     color: Colors.grey[800]!,
                    //     width: 1.0,
                    //   ),
                    // ),
                  ),
                  child: Stack(
                    children: [
                      // 텍스트 입력창
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: '메세지를 입력하세요...',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.only(
                            left: 20.0,
                            right: 60.0, // 전송 버튼 공간 확보
                            top: 15.0,
                            bottom: 15.0,
                          ),
                          isDense: true,
                        ),
                        onSubmitted: (value) => _sendMessage(),
                        textInputAction: TextInputAction.send,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        autofocus: true,
                      ),
                      
                      // 입력창 내부 전송 버튼
                      Positioned(
                        right: 8.0,
                        top: 8.0,
                        bottom: 8.0,
                        child: Container(
                          height: 40.0,
                          width: 40.0,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _sendMessage,
                            icon: const Icon(
                              Icons.arrow_upward,
                              color: Colors.black,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40.0,
                              minHeight: 40.0,
                            ),
                            splashRadius: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ), // 텍스트 입력창
                ), // 하단 챗봇 입력 영역
              ],
            ), // 메인 콘텐츠
          ),
          
          // 드로어가 열려 있을 때만 반투명 오버레이 표시
          if (_isDrawerOpen)
            GestureDetector(
              onTap: () {
                // 오버레이를 탭하면 드로어 닫기
                Navigator.of(context).pop();
              },
              child: Container(
                color: Colors.grey[800]!.withValues(alpha: 0.7), // 더 명확한 회색 오버레이
              ),
            ),
        ],
      ),
    );
  }
}
