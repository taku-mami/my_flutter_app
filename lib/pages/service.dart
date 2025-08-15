import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../services/auth.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(66.0), // 50 + 16
        child: Builder(
          builder: (context) => CustomAppBar(
            title: '서비스 소개',
            showMenuButton: true,
            onMenuPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: _buildDrawer(context),
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
            children: [

              
              // 서비스 소개 헤더
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue[600]!.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue[600]!.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
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
                        Icons.psychology,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '해운대 DIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '지능형 대화 어시스턴트와 함께\n새로운 경험을 시작하세요',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        letterSpacing: 0.5,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 서비스 특징
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '주요 특징',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 특징 카드들
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: [
                      _buildFeatureCard(
                        icon: Icons.chat_bubble_outline,
                        title: '자연스러운 대화',
                        description: '자연어 처리를 통해 인간과 같은 대화를 나눌 수 있습니다.',
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildFeatureCard(
                        icon: Icons.lightbulb_outline,
                        title: '지능형 답변',
                        description: '맥락을 이해하고 적절한 답변을 제공합니다.',
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildFeatureCard(
                        icon: Icons.security,
                        title: '안전한 대화',
                        description: '개인정보를 보호하며 안전한 환경에서 대화할 수 있습니다.',
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildFeatureCard(
                        icon: Icons.access_time,
                        title: '24/7 이용 가능',
                        description: '언제든지 원하는 시간에 서비스를 이용할 수 있습니다.',
                      ),
                    ],
                  ),
                ),
              ),
              
              // 하단 버튼
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '시작하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 드로어 메뉴 위젯
  Widget _buildDrawer(BuildContext context) {
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
                    // 이미 서비스 페이지에 있으므로 아무 동작 안함
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
  
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[600]!.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue[400],
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
