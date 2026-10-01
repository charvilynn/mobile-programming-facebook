import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import 'core_providers.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storage;

  ThemeModeNotifier(this._storage) : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final saved = await _storage.getThemeMode();
      if (saved == 'light') {
        AppColors.isDark = false;
        state = ThemeMode.light;
      } else {
        AppColors.isDark = true;
        state = ThemeMode.dark;
      }
    } catch (_) {
      AppColors.isDark = true;
      state = ThemeMode.dark;
    }
  }

  Future<void> toggleTheme(bool isDarkMode) async {
    AppColors.isDark = isDarkMode;
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    try {
      await _storage.saveThemeMode(isDarkMode ? 'dark' : 'light');
    } catch (_) {}
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeModeNotifier(storage);
});