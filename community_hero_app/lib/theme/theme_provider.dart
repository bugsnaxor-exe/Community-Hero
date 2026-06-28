import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_constants.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(const FlutterSecureStorage());
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final FlutterSecureStorage _storage;
  
  ThemeNotifier(this._storage) : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeStr = await _storage.read(key: 'app_theme_mode');
    if (themeStr == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await _storage.write(key: 'app_theme_mode', value: 'light');
    } else {
      state = ThemeMode.dark;
      await _storage.write(key: 'app_theme_mode', value: 'dark');
    }
  }
}
