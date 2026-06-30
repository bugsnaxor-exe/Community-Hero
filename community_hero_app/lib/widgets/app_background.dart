import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseBgColor = isDark ? const Color(0xFF020617) : const Color(0xFFF1F5F9);

    // Glow opacities
    final cyanGlow = isDark ? const Color(0x3300B2FF) : const Color(0x0C00B2FF);
    final purpleGlow = isDark ? const Color(0x33E228FF) : const Color(0x0CE228FF);
    final greenGlow = isDark ? const Color(0x3300FF5E) : const Color(0x0C00FF5E);
    final blueGlow = isDark ? const Color(0x661E3A8A) : const Color(0x111E3A8A);

    return Container(
      decoration: BoxDecoration(
        color: baseBgColor,
      ),
      child: Stack(
        children: [
          // Top-Left Cyan Glow
          Positioned(
            top: -300,
            left: -300,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    cyanGlow,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Top-Right/Middle Purple Glow
          Positioned(
            top: -300,
            right: -200,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    purpleGlow,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Bottom-Right Green Glow
          Positioned(
            bottom: -400,
            right: -300,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    greenGlow,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Bottom-Left Dark Blue Glow
          Positioned(
            bottom: -200,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    blueGlow,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Foreground content
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}
