import 'package:flutter/material.dart';
import '../services/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          // 드로어 헤더
          Container(
            padding: const EdgeInsets.only(
              top: 50.0,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Row(
              children: [
                // 사용자 프로필 아이콘
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(AuthService().currentUser?.photoURL ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                // 사용자 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AuthService().currentUser?.displayName ?? '사용자',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AuthService().currentUser?.email ?? '이메일 없음',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 메뉴 아이템들
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.chat,
                  title: '홈',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.map,
                  title: '서비스',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/service');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: '설정',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),
          
          // 하단 로그아웃 버튼
          Container(
            padding: const EdgeInsets.all(16.0),
            child: _buildDrawerItem(
              icon: Icons.logout,
              title: '로그아웃',
              onTap: () {
                Navigator.pop(context);
                AuthService().signOut();
                Navigator.pushNamed(context, '/');
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // 드로어 메뉴 아이템 위젯
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      tileColor: Colors.transparent,
      hoverColor: Colors.grey[800],
    );
  }
}
