/// Core constants used throughout the application.
/// 
/// This file contains all the constant values like strings, numbers, 
/// and other fixed values used in the app.

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Seeking Browser';
  static const String appVersion = '1.0.0';
  
  // Default URLs
  static const String defaultHomePage = 'https://www.google.com';
  static const String newTabPage = 'about:blank';
  
  // Storage Keys
  static const String homePageKey = 'home_page_url';
  static const String searchEngineKey = 'search_engine';
  static const String darkModeKey = 'dark_mode';
  static const String fullscreenKey = 'fullscreen_mode';
  static const String userAgentKey = 'user_agent';
  
  // Search Engines
  static const String googleSearch = 'https://www.google.com/search?q=';
  static const String bingSearch = 'https://www.bing.com/search?q=';
  static const String duckDuckGoSearch = 'https://duckduckgo.com/?q=';
  
  // Default User Agent (Android TV Chrome)
  static const String defaultUserAgent = 
      'Mozilla/5.0 (Linux; Android 10; ADT-2 Build/QQ3A.200805.001; wv) '
      'AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 '
      'Chrome/91.0.4472.114 Mobile Safari/537.36';
  
  // UI Constants
  static const double defaultButtonSize = 48.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  
  // Animation Durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;
}
