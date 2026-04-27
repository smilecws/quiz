/// 접속 통계 / Google Sign-In 설정 상수.
///
/// 여기에 들어가는 값은 모두 **공개 식별자**라 클라이언트 번들에 포함되어도 안전.
/// (Apps Script 가 매 요청 Google ID Token 의 서명·aud·iss·exp 를 검증하므로
///  클라이언트가 이 URL/ID 만 가지고는 위조된 행을 시트에 못 씀.)
///
/// 배포 전에 실제 값으로 교체할 것.
class AccessLogConfig {
  const AccessLogConfig._();

  /// Apps Script Web App 배포 URL.
  /// 빈 문자열이면 AccessLogService 가 호출을 스킵 (개발 중 fail-safe).
  static const String endpoint = '';

  /// Google Cloud Console 의 **Web** OAuth 2.0 Client ID.
  /// Android/iOS 도 이 ID 를 `serverClientId` 로 공유해 ID Token 의 `aud` 를
  /// 한 곳으로 통일 → Apps Script 검증이 단순해짐.
  static const String webClientId = '';

  /// 동의 스키마 버전. PIPA 고지 문구 변경 시 +1 → 기존 동의 무효화 후 재동의.
  static const int consentVersion = 1;

  static bool get isConfigured => endpoint.isNotEmpty && webClientId.isNotEmpty;
}
