import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(66.0), // 50 + 16
        child: Builder(
          builder: (context) => CustomAppBar(
            title: '설정',
            showBackButton: true,
          ),
        ),
      ),
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
              // 상단 여백
              const SizedBox(height: 24.0),
              
              // 설정 메뉴들
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: [
                      _buildSettingItem(
                        icon: Icons.person,
                        title: '프로필 설정',
                        subtitle: '계정 정보 및 프로필 관리',
                        onTap: () {
                          print('프로필 설정 클릭');
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildSettingItem(
                        icon: Icons.notifications,
                        title: '알림 설정',
                        subtitle: '푸시 알림 및 소리 설정',
                        onTap: () {
                          print('알림 설정 클릭');
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildSettingItem(
                        icon: Icons.security,
                        title: '보안 설정',
                        subtitle: '비밀번호 및 보안 옵션',
                        onTap: () {
                          print('보안 설정 클릭');
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildSettingItem(
                        icon: Icons.language,
                        title: '언어 설정',
                        subtitle: '앱 언어 및 지역 설정',
                        onTap: () {
                          print('언어 설정 클릭');
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildSettingItem(
                        icon: Icons.info,
                        title: '앱 정보',
                        subtitle: '버전 정보 및 라이선스',
                        onTap: () {
                          print('앱 정보 클릭');
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildSettingItem(
                        icon: Icons.help,
                        title: '도움말',
                        subtitle: '자주 묻는 질문 및 지원',
                        onTap: () {
                          print('도움말 클릭');
                        },
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
                      '확인',
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
  
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
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
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            height: 1.3,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[600],
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
