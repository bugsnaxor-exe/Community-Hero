import 'package:flutter/material.dart';
import 'glass_container.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double blurX;
  final double blurY;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const NeonCard({
    super.key,
    required this.child,
    required this.glowColor,
    this.blurX = 30.0,
    this.blurY = 30.0,
    this.opacity = 0.05,
    this.borderRadius = 24.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.15),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: GlassContainer(
        width: width,
        height: height,
        padding: padding,
        borderRadius: borderRadius,
        blurX: blurX,
        blurY: blurY,
        opacity: 0.95, // Highly opaque to block neon shadow from bleeding through
        borderWidth: 2.0,
        borderColor: glowColor, // Inner neon border
        backgroundColor: const Color(0xFF0A111F), // Dark background blocks shadow bleeding
        child: child,
      ),
    );
  }
}
