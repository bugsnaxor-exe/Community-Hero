import 'package:flutter/material.dart';
import '../../../../widgets/glassmorphism/glass_container.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white60 : Colors.black54;
    final borderColor = isDark ? Colors.white24 : Colors.black12;
    final opacity = isDark ? 0.1 : 0.6;

    return Row(
      children: [
        Expanded(
          child: GlassContainer(
            borderRadius: 30,
            blurX: 10,
            blurY: 10,
            opacity: opacity,
            backgroundColor: Colors.white,
            borderWidth: 1.0,
            borderColor: borderColor,
            child: TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search issues...',
                hintStyle: TextStyle(color: hintColor),
                prefixIcon: Icon(Icons.search, color: hintColor),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GlassContainer(
          borderRadius: 16,
          blurX: 10,
          blurY: 10,
          opacity: 0.2,
          backgroundColor: Theme.of(context).primaryColor,
          child: IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // Show filter bottom sheet or dialog
            },
          ),
        ),
      ],
    );
  }
}
