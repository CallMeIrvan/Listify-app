import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigasi otomatis setelah 5 detik
    Future.delayed(const Duration(seconds: 5), () {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/app_icon.png',
                width: 450,
                height: 450,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
