import 'package:flutter/material.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9A84D),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Num Loop',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 88,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -3,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'animated edition',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: Color(0xB3FFFFFF),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 56),
              _PlayButton(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PlayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 52, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF6DDDD0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Play',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF3A2A70),
          ),
        ),
      ),
    );
  }
}
