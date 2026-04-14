import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 라이트 / 다크 / 시스템 테마 저장
class ThemeModeService {
  ThemeModeService._();

  static const _key = 'app_theme_mode';

  static Future<ThemeMode> loadPreferred() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_key);
    if (v == null || v.isEmpty) return ThemeMode.system;
    return switch (v) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }

  static Future<void> save(ThemeMode mode) async {
    final p = await SharedPreferences.getInstance();
    final s = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await p.setString(_key, s);
  }
}
