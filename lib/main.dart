import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  await SettingsService.instance.load();
  GameCenterService.instance.signIn();
  await AudioService.instance.init();
  AudioService.instance.startBgm();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => GameController()),
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
