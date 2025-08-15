class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  
  factory AppConfig() {
    return _instance;
  }
  
  AppConfig._internal();
  
  // 개발 모드 설정
  bool isDevelopmentMode = true;
  
  // 개발 모드 설정 변경 메서드
  void setDevelopmentMode(bool isDev) {
    isDevelopmentMode = isDev;
  }
  
  // 앱 버전
  String get appVersion => '1.0.0';
  
  // 앱 이름
  String get appName => '해운대 DIVE';
  
  // 앱 설명
  String get appDescription => '부제목';
}
