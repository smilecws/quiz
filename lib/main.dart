import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_settings_scope.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/locale_service.dart';
import 'services/question_service.dart';
import 'services/theme_mode_service.dart';
import 'theme/app_theme_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuizApp());
}

class QuizApp extends StatefulWidget {
  const QuizApp({super.key});

  @override
  State<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  Locale _locale = const Locale('ko');
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    Future.wait([
      LocaleService.loadPreferredLocale(),
      ThemeModeService.loadPreferred(),
    ]).then((results) {
      if (!mounted) return;
      final locale = results[0] as Locale;
      final themeMode = results[1] as ThemeMode;
      QuestionService.setLanguageCode(locale.languageCode);
      setState(() {
        _locale = locale;
        _themeMode = themeMode;
      });
    });
  }

  Future<void> _setLocale(Locale locale) async {
    if (!LocaleService.isSupported(locale)) return;
    await LocaleService.saveLanguageCode(locale.languageCode);
    QuestionService.setLanguageCode(locale.languageCode);
    if (mounted) setState(() => _locale = locale);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    await ThemeModeService.save(mode);
    if (mounted) setState(() => _themeMode = mode);
  }

  static ThemeData _lightTheme() {
    const ac = AppThemeColors.light;
    final colorScheme = ColorScheme.light(
      primary: ac.primary,
      onPrimary: ac.onPrimary,
      surface: ac.surfaceWhite,
      onSurface: ac.textPrimary,
      onSurfaceVariant: ac.textSecondary,
      outline: ac.borderLight,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      extensions: const [AppThemeColors.light],
      scaffoldBackgroundColor: ac.background,
      textTheme: GoogleFonts.juaTextTheme(
        ThemeData(brightness: Brightness.light).textTheme,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ac.surfaceWhite,
        selectedItemColor: ac.textSecondary,
        unselectedItemColor: ac.textSecondary,
        elevation: 8,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ac.surfaceWhite,
        foregroundColor: ac.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.jua(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ac.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ac.primary,
          foregroundColor: ac.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  static ThemeData _darkTheme() {
    const ac = AppThemeColors.dark;
    final colorScheme = ColorScheme.dark(
      primary: ac.primary,
      onPrimary: ac.onPrimary,
      surface: ac.surfaceWhite,
      onSurface: ac.textPrimary,
      onSurfaceVariant: ac.textSecondary,
      outline: ac.borderLight,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      extensions: const [AppThemeColors.dark],
      scaffoldBackgroundColor: ac.background,
      textTheme: GoogleFonts.juaTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ac.surfaceWhite,
        selectedItemColor: ac.textSecondary,
        unselectedItemColor: ac.textSecondary,
        elevation: 8,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ac.surfaceWhite,
        foregroundColor: ac.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.jua(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ac.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ac.primary,
          foregroundColor: ac.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      setLocale: _setLocale,
      themeMode: _themeMode,
      setThemeMode: _setThemeMode,
      child: MaterialApp(
        title: '운전면허 학과시험 1000제',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        themeMode: _themeMode,
        theme: _lightTheme(),
        darkTheme: _darkTheme(),
        supportedLocales: LocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeScreen(),
      ),
    );
  }
}
