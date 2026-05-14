/// 동의 시점에 이름·일자를 Google Form 으로 익명 POST 하기 위한 설정.
///
/// 운영자(앱 소유자)가 직접:
/// 1) Google Forms 에서 단답형 필드 ("이름", "동의 일자", 선택적으로 "플랫폼") 폼 생성
/// 2) "응답" 탭에서 Google Sheet 연결
/// 3) view URL 의 `viewform` 을 `formResponse` 로 치환한 값을 [endpoint] 에 넣기
/// 4) "미리 채우기 링크 가져오기" 로 받은 URL 의 `entry.숫자` 들을 각 필드에 매칭해 넣기
///
/// 미설정 상태면 [isConfigured] 가 false 가 되어 [ConsentLogService.submitConsent]
/// 는 호출 즉시 no-op 로 빠져나간다 (로컬 동의 저장은 정상 동작).
class ConsentLogConfig {
  const ConsentLogConfig._();

  static const String endpoint =
      'https://docs.google.com/forms/d/e/1FAIpQLSc_8xFyTE0vacWle6Hv3_0721R1G8mAcAFGwv4JR02Hl3dedg/formResponse';

  static const String entryName = 'entry.1615834685';
  static const String entryGrantedAt = 'entry.696072009';

  // 폼에 "플랫폼" 필드가 없으므로 빈 문자열로 둠. 전송 페이로드에서 자동 제외됨.
  // 나중에 플랫폼 정보가 필요해지면 폼에 단답형 필드 추가 후 entry.숫자 채우기.
  static const String entryPlatform = '';

  static bool get isConfigured => endpoint.isNotEmpty && entryName.isNotEmpty;
}
