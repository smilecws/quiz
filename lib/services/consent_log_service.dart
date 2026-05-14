import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/consent_log_config.dart';

/// 동의 시점에 Google Form 으로 이름·일자를 익명 POST 한다.
///
/// - 인증 없음. 누구나 폼 URL 을 알면 임의 데이터를 넣을 수 있다.
///   학습 앱이라 공격 동기가 약하다는 판단으로 1차 수용. 봇 스팸이 실제 발생하면
///   캡차(Cloudflare Turnstile 등) 추가는 후속 작업.
/// - fire-and-forget. 실패해도 throw 하지 않는다. 로컬 동의 저장은 호출자에서
///   이미 끝났으므로 네트워크 실패가 게이트 통과를 막지 않는다.
/// - 재시도 큐는 두지 않는다 — Google Form 은 멱등성이 없어 중복 행이 쌓일 위험.
///   네트워크가 끊긴 상태에서 동의한 사용자의 이름은 시트에 안 잡힐 수 있음 (수용 사양).
/// - 웹: CORS Access-Control-Allow-Origin 헤더가 없어 응답을 읽지는 못하지만,
///   application/x-www-form-urlencoded 는 simple request 로 분류되어 preflight 없이
///   POST 자체는 발사된다. 시트에는 행이 들어간다.
class ConsentLogService {
  ConsentLogService._();

  static const _timeout = Duration(seconds: 5);

  static Future<void> submitConsent({
    required String name,
    required DateTime grantedAtUtc,
  }) async {
    if (!ConsentLogConfig.isConfigured) return;

    final body = <String, String>{
      ConsentLogConfig.entryName: name,
      if (ConsentLogConfig.entryGrantedAt.isNotEmpty)
        // Google Form 의 날짜 필드는 YYYY-MM-DD 만 받음 (시간/ISO8601 거부).
        ConsentLogConfig.entryGrantedAt: _formatDate(grantedAtUtc),
      if (ConsentLogConfig.entryPlatform.isNotEmpty)
        ConsentLogConfig.entryPlatform: _platformLabel(),
    };

    try {
      await http
          .post(
            Uri.parse(ConsentLogConfig.endpoint),
            headers: const {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body,
          )
          .timeout(_timeout);
    } catch (_) {
      // 의도적 무시 — fire-and-forget.
    }
  }

  static String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static String _platformLabel() {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
      if (Platform.isWindows) return 'windows';
      if (Platform.isMacOS) return 'macos';
      if (Platform.isLinux) return 'linux';
      if (Platform.isFuchsia) return 'fuchsia';
    } catch (_) {}
    return 'unknown';
  }
}
