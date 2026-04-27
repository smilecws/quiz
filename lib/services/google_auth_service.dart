import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/access_log_config.dart';

/// google_sign_in 래퍼.
///
/// scopes 에 `profile` 을 요청하지 **않음** — Google displayName / 사진은 수집 안 함.
/// 시트에 기록되는 '이름' 은 사용자가 ConsentScreen 에서 직접 입력한 값.
class GoogleAuthService {
  GoogleAuthService._();

  static GoogleSignIn? _instance;

  static GoogleSignIn _signIn() {
    return _instance ??= GoogleSignIn(
      clientId: kIsWeb ? AccessLogConfig.webClientId : null,
      serverClientId: AccessLogConfig.webClientId,
      scopes: const ['email'],
    );
  }

  static Future<GoogleSignInAccount?> signIn() => _signIn().signIn();

  static Future<GoogleSignInAccount?> signInSilently() =>
      _signIn().signInSilently();

  static Future<void> signOut() => _signIn().signOut();

  static GoogleSignInAccount? get currentUser => _signIn().currentUser;

  /// 웹의 GIS 버튼 클릭 결과는 programmatic 반환이 아니라 이 스트림으로만 전달된다.
  static Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _signIn().onCurrentUserChanged;

  /// 캐시된 계정이 있으면 그 idToken, 없으면 silent sign-in 시도 후 idToken.
  static Future<String?> currentIdToken() async {
    final account = _signIn().currentUser ?? await _signIn().signInSilently();
    final auth = await account?.authentication;
    return auth?.idToken;
  }
}
