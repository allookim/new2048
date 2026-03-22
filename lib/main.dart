import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_controller.dart';
import 'game/game_controller.dart';
import 'screens/main_menu_screen.dart';

void main() {
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
            title: '2048',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: themeController.theme.fontFamily ?? 'sans-serif',
              useMaterial3: true,
            ),
            home: const MainMenuScreen(),
          );
        },
      ),
    );
  }
}
