import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app_settings_scope.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth_loading_screen.dart';
import 'screens/consent_screen.dart';
import 'screens/eco_intro_screen.dart';
import 'screens/home_screen.dart';
import 'services/access_log_service.dart';
import 'services/consent_service.dart';
import 'services/eco_intro_service.dart';
import 'services/google_auth_service.dart';
import 'services/locale_service.dart';
import 'services/question_service.dart';
import 'services/theme_mode_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuizApp());
}

enum _AuthState { loading, needConsent, needEcoIntro, ready }

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
      EcoIntroService.hasShown(),
    ]);
    if (!mounted) return;
    final locale = results[0] as Locale;
    final themeMode = results[1] as ThemeMode;
    final consent = results[2] as ConsentRecord?;
    final ecoIntroShown = results[3] as bool;
    QuestionService.setLanguageCode(locale.languageCode);
    setState(() {
      _locale = locale;
      _themeMode = themeMode;
    });

    // 데스크톱(Windows/macOS/Linux)은 google_sign_in 미지원 → 게이트 우회.
    // 동의·인트로 모두 스킵하고 바로 ready 로 진입.
    if (!_isAuthGateSupported()) {
      setState(() => _authState = _AuthState.ready);
      return;
    }

    if (consent == null) {
      setState(() => _authState = _AuthState.needConsent);
      return;
    }

    // 동의 기록은 PIPA 동의의 증거 그 자체 — silent sign-in 결과와 무관하게
    // 즉시 통과시킨다. 웹 GIS 는 third-party cookie 차단/세션 만료로 silent 가
    // 자주 null 반환하는데, 그때마다 동의 화면을 다시 띄우면 UX 가 망가진다.
    setState(() => _authState =
        ecoIntroShown ? _AuthState.ready : _AuthState.needEcoIntro);
    // ignore: discarded_futures
    _attemptLaunchLog(consent);
  }

  /// 자동 로그인이 되면 app_launch 로깅 + 큐 flush. 실패해도 게이트는 막지 않는다.
  Future<void> _attemptLaunchLog(ConsentRecord consent) async {
    GoogleSignInAccount? account;
    try {
      account = await GoogleAuthService.signInSilently();
    } catch (_) {
      return;
    }
    if (account == null) return;
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
    // 동의 직후엔 친환경 운전 교육 인트로를 1회 보여준 뒤 ready 로 진입.
    setState(() => _authState = _AuthState.needEcoIntro);
  }

  Future<void> _handleEcoIntroDone() async {
    await EcoIntroService.markShown();
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

  Future<void> _revokeConsent() async {
    await ConsentService.clear();
    // 재동의 시 친환경 운전 교육을 다시 1회 노출해야 하므로 함께 초기화.
    await EcoIntroService.clear();
    try {
      await GoogleAuthService.signOut();
    } catch (_) {
      // signOut 실패는 무시 — 로컬 동의 기록 삭제만으로도 게이트는 다시 뜬다.
    }
    if (!mounted) return;
    setState(() => _authState = _AuthState.needConsent);
  }

  Widget _resolveHome() {
    switch (_authState) {
      case _AuthState.loading:
        return const AuthLoadingScreen();
      case _AuthState.needConsent:
        return ConsentScreen(onGranted: _handleConsentGranted);
      case _AuthState.needEcoIntro:
        return EcoIntroScreen(onDone: _handleEcoIntroDone);
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
      revokeConsent: _revokeConsent,
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
