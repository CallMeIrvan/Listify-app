import 'package:flutter/cupertino.dart';
import '../utils/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;
  const GradientBackground({
    required this.child,
    required this.isDarkMode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!isDarkMode)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent.withAlpha((0.35 * 255).toInt()),
                  CupertinoColors.systemBlue.withAlpha((0.25 * 255).toInt()),
                  CupertinoColors.white,
                ],
              ),
            ),
          ),
        child,
      ],
    );
  }
}
