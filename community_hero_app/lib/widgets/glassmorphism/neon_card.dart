import 'package:flutter/material.dart';
import 'glass_container.dart';

class NeonCard extends StatefulWidget {
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
  State<NeonCard> createState() => _NeonCardState();
}

class _NeonCardState extends State<NeonCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF0A111F) : const Color(0xFFF8FAFC);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double pulse = _animation.value;
        final double blurRadius1 = 12.0 + pulse * 10.0;
        final double spreadRadius1 = pulse * 1.5;
        final double blurRadius2 = 30.0 + pulse * 20.0;
        final double spreadRadius2 = 1.0 + pulse * 2.0;

        return Container(
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: isDark ? (0.3 + pulse * 0.15) : (0.15 + pulse * 0.1)),
                blurRadius: blurRadius1,
                spreadRadius: spreadRadius1,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: widget.glowColor.withValues(alpha: isDark ? (0.1 + pulse * 0.08) : (0.05 + pulse * 0.05)),
                blurRadius: blurRadius2,
                spreadRadius: spreadRadius2,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: GlassContainer(
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            borderRadius: widget.borderRadius,
            blurX: widget.blurX,
            blurY: widget.blurY,
            opacity: isDark ? 0.95 : 0.9, // Highly opaque to block neon shadow from bleeding through
            borderWidth: 2.0,
            borderColor: widget.glowColor.withValues(alpha: isDark ? (0.6 + pulse * 0.3) : (0.4 + pulse * 0.2)), // Inner neon border
            backgroundColor: cardBgColor,
            child: widget.child,
          ),
        );
      },
    );
  }
}
