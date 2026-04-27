import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/access_log_config.dart';
import 'google_auth_service.dart';

/// Apps Script Web App 으로 접속 이벤트를 보내는 서비스.
///
/// - 매 호출 시 fresh Google ID Token 을 GoogleAuthService 에서 받아 함께 전송.
/// - Apps Script 가 Google 공개키로 토큰 서명 / aud / iss / exp 를 검증.
/// - 호출 실패 시 페이로드를 로컬 큐에 적재 → 다음 [flushPending] 호출 시 재전송.
/// - UI 를 절대 차단하지 않음 (호출자는 unawaited 권장).
class AccessLogService {
  AccessLogService._();

  static const _pendingKey = 'access_log_pending_v1';
  static const _timeout = Duration(seconds: 5);

  static Future<void> send({
    required String eventType,
    required String name,
  }) async {
    if (!AccessLogConfig.isConfigured) return;
    final idToken = await GoogleAuthService.currentIdToken();
    if (idToken == null) return;

    final payload = <String, dynamic>{
      'name': name,
      'eventType': eventType,
      'accessedAt': DateTime.now().toUtc().toIso8601String(),
      'platform': _platformLabel(),
    };

    final ok = await _post(idToken: idToken, payload: payload);
    if (!ok) await _enqueue(payload);
  }

  /// 큐에 쌓인 페이로드들을 fresh idToken 으로 다시 보냄.
  /// 큐의 idToken 은 만료됐을 수 있으므로 무시하고 최신 토큰을 매번 발급.
  static Future<void> flushPending() async {
    if (!AccessLogConfig.isConfigured) return;
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList(_pendingKey) ?? const <String>[];
    if (pending.isEmpty) return;

    final idToken = await GoogleAuthService.currentIdToken();
    if (idToken == null) return;

    final remaining = <String>[];
    for (var i = 0; i < pending.length; i++) {
      final raw = pending[i];
      Map<String, dynamic>? payload;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) payload = decoded;
      } catch (_) {
        // 깨진 엔트리는 버림.
      }
      if (payload == null) continue;
      final ok = await _post(idToken: idToken, payload: payload);
      if (!ok) {
        // 실패 시점부터 끝까지 보존하고 다음 기회에 재시도.
        remaining.addAll(pending.sublist(i));
        break;
      }
    }
    await prefs.setStringList(_pendingKey, remaining);
  }

  static Future<bool> _post({
    required String idToken,
    required Map<String, dynamic> payload,
  }) async {
    final body = <String, dynamic>{...payload, 'idToken': idToken};
    try {
      final resp = await http
          .post(
            Uri.parse(AccessLogConfig.endpoint),
            // text/plain 으로 보내 CORS preflight (OPTIONS) 회피.
            // Apps Script 쪽에서 e.postData.contents 를 JSON.parse.
            headers: const {'Content-Type': 'text/plain;charset=UTF-8'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return resp.statusCode >= 200 && resp.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _enqueue(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final list = List<String>.from(
      prefs.getStringList(_pendingKey) ?? const <String>[],
    );
    list.add(jsonEncode(payload));
    // 큐 무한 증가 방지 — 가장 오래된 것부터 잘라 최대 100개 유지.
    const maxQueue = 100;
    if (list.length > maxQueue) {
      list.removeRange(0, list.length - maxQueue);
    }
    await prefs.setStringList(_pendingKey, list);
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
