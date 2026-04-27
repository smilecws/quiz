/**
 * Apps Script Web App — quiz_app 접속 통계 수집기.
 *
 * 흐름:
 *   1. Flutter 앱이 Google Sign-In 으로 받은 ID Token + 사용자 입력 이름을 POST.
 *   2. 이 스크립트가 Google tokeninfo 엔드포인트로 ID Token 의 서명·iss·exp 를 검증하고
 *      `aud` 가 우리 OAuth 클라이언트 ID 와 일치하는지 확인.
 *   3. 통과한 요청만 시트에 한 행 추가.
 *
 * 배포:
 *   - 시트 만들고 시트 이름을 'access_log' 로, 1행에 헤더 7개 입력:
 *     timestamp | google_sub | email | name | event_type | accessed_at | platform
 *   - script.google.com 에서 새 프로젝트에 이 파일 붙여넣기 → EXPECTED_AUD / SHEET_ID 채움.
 *   - "배포 → 새 배포 → 웹 앱, 액세스: 모든 사용자" 로 배포 → 발급된 URL 을
 *     lib/config/access_log_config.dart 의 endpoint 에 입력.
 *
 * 보안 노트:
 *   - 클라이언트(Flutter 앱)에는 어떤 비밀도 들어있지 않음.
 *   - 위조된 ID Token 은 Google 의 서명 검증을 통과 못 하므로 시트에 행이 추가되지 않음.
 *   - 다른 OAuth 클라이언트가 발급받은 ID Token 도 aud 가 안 맞아 거부.
 */

const EXPECTED_AUD = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
const SHEET_ID = 'YOUR_SHEET_ID';
const SHEET_NAME = 'access_log';

function doPost(e) {
  try {
    const body = JSON.parse(e.postData.contents);
    const claims = verifyIdToken(body.idToken);
    if (!claims) return _json({ ok: false, error: 'invalid_token' });
    if (claims.aud !== EXPECTED_AUD) {
      return _json({ ok: false, error: 'aud_mismatch' });
    }

    const sheet = SpreadsheetApp.openById(SHEET_ID).getSheetByName(SHEET_NAME);
    if (!sheet) return _json({ ok: false, error: 'sheet_missing' });

    // 시트 컬럼: timestamp | google_sub | email | name | event_type | accessed_at | platform
    // name 은 사용자가 ConsentScreen 에서 직접 입력한 값. claims.name 은 사용 안 함
    // (앱이 profile scope 를 요청하지 않아서 claims.name 자체가 없음).
    sheet.appendRow([
      new Date(),
      claims.sub,
      claims.email || '',
      String(body.name || '').slice(0, 30),
      String(body.eventType || '').slice(0, 50),
      String(body.accessedAt || ''),
      String(body.platform || ''),
    ]);
    return _json({ ok: true });
  } catch (err) {
    return _json({ ok: false, error: String(err) });
  }
}

function verifyIdToken(idToken) {
  if (!idToken || typeof idToken !== 'string') return null;
  const url =
    'https://oauth2.googleapis.com/tokeninfo?id_token=' +
    encodeURIComponent(idToken);
  const resp = UrlFetchApp.fetch(url, { muteHttpExceptions: true });
  if (resp.getResponseCode() !== 200) return null;
  const claims = JSON.parse(resp.getContentText());
  if (
    claims.iss !== 'accounts.google.com' &&
    claims.iss !== 'https://accounts.google.com'
  ) {
    return null;
  }
  if (parseInt(claims.exp, 10) * 1000 < Date.now()) return null;
  return claims;
}

function _json(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(
    ContentService.MimeType.JSON,
  );
}
