import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app_settings_scope.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth_loading_screen.dart';
import 'screens/consent_screen.dart';
import 'screens/home_screen.dart';
import 'services/access_log_service.dart';
import 'services/consent_service.dart';
import 'services/google_auth_service.dart';
import 'services/locale_service.dart';
import 'services/question_service.dart';
import 'services/theme_mode_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuizApp());
}

enum _AuthState { loading, needConsent, ready }

class QuizApp extends StatefulWidget {
  const QuizApp({super.key});

  @override
  State<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  Locale _locale = const Locale('ko');
  ThemeMode _themeMode = ThemeMode.system;
  _AuthState _authState = _AuthState.loading;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final results = await Future.wait([
      LocaleService.loadPreferredLocale(),
      ThemeModeService.loadPreferred(),
      ConsentService.load(),
    ]);
    if (!mounted) return;
    final locale = results[0] as Locale;
    final themeMode = results[1] as ThemeMode;
    final consent = results[2] as ConsentRecord?;
    QuestionService.setLanguageCode(locale.languageCode);
    setState(() {
      _locale = locale;
      _themeMode = themeMode;
    });

    // 데스크톱(Windows/macOS/Linux)은 google_sign_in 미지원 → 게이트 우회.
    if (!_isAuthGateSupported()) {
      setState(() => _authState = _AuthState.ready);
      return;
    }

    if (consent == null) {
      setState(() => _authState = _AuthState.needConsent);
      return;
    }

    // 동의 기록 있음 → 자동 로그인 시도해서 fresh idToken 으로 app_launch 로깅.
    GoogleSignInAccount? account;
    try {
      account = await GoogleAuthService.signInSilently();
    } catch (_) {
      account = null;
    }
    if (!mounted) return;

    if (account == null) {
      // 토큰 만료 / 철회 → 다시 동의 받기.
      setState(() => _authState = _AuthState.needConsent);
      return;
    }

    setState(() => _authState = _AuthState.ready);
    // ignore: discarded_futures
    AccessLogService.flushPending();
    // ignore: discarded_futures
    AccessLogService.send(eventType: 'app_launch', name: consent.name);
  }

  bool _isAuthGateSupported() {
    if (kIsWeb) return true;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  void _handleConsentGranted(ConsentRecord _) {
    if (!mounted) return;
    setState(() => _authState = _AuthState.ready);
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

  Widget _resolveHome() {
    switch (_authState) {
      case _AuthState.loading:
        return const AuthLoadingScreen();
      case _AuthState.needConsent:
        return ConsentScreen(onGranted: _handleConsentGranted);
      case _AuthState.ready:
        return const HomeScreen();
    }
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
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        supportedLocales: LocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: _resolveHome(),
      ),
    );
  }
}
