import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ConsentRecord {
  const ConsentRecord({
    required this.name,
    required this.grantedAt,
    required this.version,
  });

  final String name;
  final DateTime grantedAt;
  final int version;

  Map<String, dynamic> toJson() => {
        'name': name,
        'grantedAt': grantedAt.toIso8601String(),
        'version': version,
      };

  static ConsentRecord? fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final grantedAtStr = json['grantedAt'];
    if (name is! String || grantedAtStr is! String) {
      return null;
    }
    final grantedAt = DateTime.tryParse(grantedAtStr);
    if (grantedAt == null) return null;
    return ConsentRecord(
      name: name,
      grantedAt: grantedAt,
      version: json['version'] is int ? json['version'] as int : 1,
    );
  }
}

class ConsentService {
  ConsentService._();

  static const _key = 'user_consent_v1';

  /// PIPA 고지·수집 항목 변경 시 +1 → 기존 동의 무효화 후 재동의.
  /// v3: Google 로그인 제거. sub/email 필드 폐기, name·grantedAt·version 만 보관.
  static const int currentVersion = 3;

  /// 저장된 동의 기록 로드. 없거나 버전 불일치면 null.
  static Future<ConsentRecord?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      final record = ConsentRecord.fromJson(json);
      if (record == null) return null;
      if (record.version != currentVersion) return null;
      return record;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(ConsentRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(record.toJson()));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
