import 'package:flutter/material.dart';
import '../../../../widgets/glassmorphism/glass_container.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: GlassContainer(
            borderRadius: 30,
            blurX: 10,
            blurY: 10,
            opacity: 0.1,
            backgroundColor: Colors.white,
            borderWidth: 1.0,
            borderColor: Colors.white24,
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search issues...',
                hintStyle: TextStyle(color: Colors.white60),
                prefixIcon: Icon(Icons.search, color: Colors.white60),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
