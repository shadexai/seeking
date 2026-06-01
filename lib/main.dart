import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'package:seeking/ideas.dart';
import 'package:seeking/music.dart';
import 'package:seeking/newidea.dart';

class C {
  static const bg = Color(0xFF0A0A0F);
  static const surface = Color(0xFF111118);
  static const card = Color(0xFF1C1C24);
  static const accent = Color(0xFF7B5EA7);
  static const accentLight = Color(0xFF9D7DD1);
  static const textPrimary = Color(0xFFF0EEF8);
  static const textSecondary = Color(0xFFB8B4CC);
  static const hint = Color(0xFF5A5870);
}

late MyAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(IdeaAdapter());
  await Hive.openBox<Idea>('ideas');

  // ✅ Run app immediately, init audio in background
  runApp(const SeekingApp());

  // ✅ Init audio after UI is shown — prevents splash freeze
  try {
    final handler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.seeking.audio',
        androidNotificationChannelName: 'Seeking Music',
        androidNotificationOngoing: true,
      ),
    ).timeout(const Duration(seconds: 10));
    audioHandler = handler as MyAudioHandler;
  } catch (e) {
    debugPrint('AudioService init failed: $e');
    // ✅ Fallback: init handler directly so app doesn't crash
    audioHandler = MyAudioHandler();
  }
}

class SeekingApp extends StatelessWidget {
  const SeekingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seeking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: C.bg,
        colorScheme: const ColorScheme.dark(primary: C.accent),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: C.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const MainShell(),
      routes: {
        '/newIdea': (context) => const NewIdeaScreen(),
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  final List<Widget> _screens = const [IdeasScreen(), MusicScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: C.surface,
        selectedItemColor: C.accentLight,
        unselectedItemColor: C.hint,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Ideas'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Music'),
        ],
      ),
    );
  }
}
