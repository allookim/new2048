import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/theme_controller.dart';
import 'game/game_controller.dart';
import 'screens/splash_screen.dart';
import 'services/supabase_service.dart';
import 'services/game_center_service.dart';
import 'services/audio_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: 'https://hifomhsghpjceidveplk.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpZm9taHNnaHBqY2VpZHZlcGxrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNjA3MjYsImV4cCI6MjA5MTYzNjcyNn0.RkYVnK8ZnJjEoOljtuG53zoXn-3Wk5aHNRbQvS-BwAY',
    );
    await SupabaseService.instance.init();
  } catch (e) {
    debugPrint('Supabase setup error: $e');
  }
  // 세션 없으면 로컬 점수 초기화 (자동 백업 복원 대응)
  if (!SupabaseService.instance.isLoggedIn) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('best_score', 0);
    await prefs.setInt('best_item_score', 0);
  }
  await SettingsService.instance.load();
  GameCenterService.instance.signIn();
  await AudioService.instance.init();
  AudioService.instance.startBgm();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _gameController = GameController();

  @override
  void initState() {
    super.initState();
    // 로그인/로그아웃 시 점수 동기화
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn) {
        final prefs = await SharedPreferences.getInstance();
        final localBest = prefs.getInt('best_score') ?? 0;
        final localBestItem = prefs.getInt('best_item_score') ?? 0;
        final synced = await SupabaseService.instance.syncLocalScores(localBest, localBestItem);
        await _gameController.syncFromServer(synced.bestScore, synced.bestItemScore);
        if (!SupabaseService.instance.isAnonymous) {
          await SupabaseService.instance.init();
        }
      } else if (data.event == AuthChangeEvent.signedOut) {
        // 로그아웃 시 로컬 점수 초기화
        await _gameController.syncFromServer(0, 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider.value(value: _gameController),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            title: 'Num Loop',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: themeController.theme.fontFamily ?? 'Nunito',
              useMaterial3: true,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
