import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/browser/presentation/screens/browser_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to landscape mode for TV optimization
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Enable immersive mode for fullscreen experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(const SeekingBrowserApp());
}

/// Main application widget for Seeking Browser.
/// 
/// A modern web browser built specifically for Android TV with:
/// - D-pad optimized navigation
/// - Large, readable UI elements
/// - Dark theme by default
/// - Fast and lightweight browsing
class SeekingBrowserApp extends StatelessWidget {
  const SeekingBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seeking Browser',
      debugShowCheckedModeBanner: false,
      
      // Apply dark theme optimized for Android TV
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      
      // Default route is the browser screen
      initialRoute: '/',
      routes: {
        '/': (context) => const BrowserScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      
      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const BrowserScreen(),
        );
      },
    );
  }
}
