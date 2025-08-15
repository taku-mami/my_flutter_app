import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onBackPressed;
  final bool showMenuButton;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.onBackPressed,
    this.showMenuButton = false,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 50.0, // 상단 여백 (상태바 + 추가 여백)
        left: 16.0,
        right: 16.0,
        bottom: 0.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Row(
        children: [
          // 메뉴 버튼 또는 뒤로 가기 버튼
          if (showMenuButton)
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: IconButton(
                onPressed: onMenuPressed,
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 24,
                ),
                padding: const EdgeInsets.all(8.0),
                constraints: const BoxConstraints(
                  minWidth: 40.0,
                  minHeight: 40.0,
                ),
              ),
            )
          else if (showBackButton)
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: IconButton(
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
                padding: const EdgeInsets.all(8.0),
                constraints: const BoxConstraints(
                  minWidth: 40.0,
                  minHeight: 40.0,
                ),
              ),
            ),
          
          const SizedBox(width: 16.0),
          
          // 제목 텍스트
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
