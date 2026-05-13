import 'package:shared_preferences/shared_preferences.dart';

/// 동의 직후 1회만 노출하는 친환경 운전 교육 인트로의 노출 여부 영속화.
/// 동의 철회 시 [clear] 로 함께 초기화해 재동의 흐름에서 다시 노출되도록 한다.
class EcoIntroService {
  EcoIntroService._();

  static const _key = 'eco_intro_shown_v1';

  static Future<bool> hasShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
