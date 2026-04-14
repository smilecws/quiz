import 'package:flutter/material.dart';

/// 언어·테마 등 루트에서만 바꾸는 UI 설정을 하위에 전달합니다.
class AppSettingsScope extends InheritedWidget {
  const AppSettingsScope({
    super.key,
    required this.setLocale,
    required this.themeMode,
    required this.setThemeMode,
    required super.child,
  });

  final void Function(Locale locale) setLocale;
  final ThemeMode themeMode;
  final void Function(ThemeMode mode) setThemeMode;

  static AppSettingsScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant AppSettingsScope oldWidget) =>
      oldWidget.themeMode != themeMode;
}
