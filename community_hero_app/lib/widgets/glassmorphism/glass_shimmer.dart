import 'package:flutter/material.dart';
import 'glass_container.dart';

class GlassShimmer extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const GlassShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 24.0,
  });

  @override
  State<GlassShimmer> createState() => _GlassShimmerState();
}

class _GlassShimmerState extends State<GlassShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GlassContainer(
          width: widget.width,
          height: widget.height,
          borderRadius: widget.borderRadius,
          opacity: isDark ? 0.3 : 0.4,
          borderWidth: 1.5,
          borderColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          gradient: LinearGradient(
            begin: Alignment(-2.0 + _controller.value * 4.0, -1.0),
            end: Alignment(0.0 + _controller.value * 4.0, 1.0),
            colors: isDark
                ? [
                    const Color(0xFF0F172A).withValues(alpha: 0.1),
                    const Color(0xFF334155).withValues(alpha: 0.45),
                    const Color(0xFF0F172A).withValues(alpha: 0.1),
                  ]
                : [
                    const Color(0xFFE2E8F0).withValues(alpha: 0.1),
                    const Color(0xFFF8FAFC).withValues(alpha: 0.7),
                    const Color(0xFFE2E8F0).withValues(alpha: 0.1),
                  ],
            stops: const [0.1, 0.5, 0.9],
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}
