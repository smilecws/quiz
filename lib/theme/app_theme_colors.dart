import 'package:flutter/material.dart';

/// 앱 전역 시맨틱 색 (라이트 / 다크). [ThemeData.extensions]에 등록합니다.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.background,
    required this.surfaceCard,
    required this.surfaceWhite,
    required this.primary,
    required this.primaryDark,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderLight,
    required this.chipBg,
  });

  final Color background;
  final Color surfaceCard;
  final Color surfaceWhite;
  final Color primary;
  final Color primaryDark;
  final Color onPrimary;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderLight;
  final Color chipBg;

  static const light = AppThemeColors(
    background: Color(0xFFF0FDF4),
    surfaceCard: Color(0xFFECFDF5),
    surfaceWhite: Color(0xFFFFFFFF),
    primary: Color(0xFF22C55E),
    primaryDark: Color(0xFF16A34A),
    onPrimary: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF64748B),
    borderLight: Color(0xFFD1FAE5),
    chipBg: Color(0xFFDCFCE7),
  );

  static const dark = AppThemeColors(
    background: Color(0xFF0C1210),
    surfaceCard: Color(0xFF142318),
    surfaceWhite: Color(0xFF1A2E22),
    primary: Color(0xFF4ADE80),
    primaryDark: Color(0xFF22C55E),
    onPrimary: Color(0xFF052E16),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    borderLight: Color(0xFF2D4A38),
    chipBg: Color(0xFF166534),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surfaceCard,
    Color? surfaceWhite,
    Color? primary,
    Color? primaryDark,
    Color? onPrimary,
    Color? textPrimary,
    Color? textSecondary,
    Color? borderLight,
    Color? chipBg,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceWhite: surfaceWhite ?? this.surfaceWhite,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      onPrimary: onPrimary ?? this.onPrimary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      borderLight: borderLight ?? this.borderLight,
      chipBg: chipBg ?? this.chipBg,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceWhite: Color.lerp(surfaceWhite, other.surfaceWhite, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
    );
  }
}

extension AppThemeColorsContext on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;
}
