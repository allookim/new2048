import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BasicAnimatedBackground extends StatelessWidget {
  const BasicAnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/images/bg_basic.json',
      fit: BoxFit.cover,
      repeat: true,
      animate: true,
    );
  }
}
