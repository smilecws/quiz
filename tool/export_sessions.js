// Firestore `user_answers/*/sessions` 를 모두 CSV 한 파일로 export.
//
// 사용법은 tool/export_sessions.README.md 참고.
//   - Cloud Shell: 인증 자동(ADC). `npm install firebase-admin && node export_sessions.js > sessions.csv`
//   - 본인 PC: service account 키 다운로드 후 GOOGLE_APPLICATION_CREDENTIALS 환경변수 지정.
//
// 출력은 stdout(CSV). 한 행 = 한 사용자의 한 문제 답변(items 펼침).
//   uid, display_name, session_id, finished_at, license_kind, score, total,
//   question_id, selected, correct

const admin = require('firebase-admin');

admin.initializeApp({ projectId: 'quiz-ace9a' });
const db = admin.firestore();

// CSV 셀 escape: 쉼표/따옴표/줄바꿈 포함 시 따옴표로 감싸고 내부 따옴표는 두 개로.
function csv(v) {
  if (v === null || v === undefined) return '';
  const s = String(v);
  if (/[",\n\r]/.test(s)) return '"' + s.replace(/"/g, '""') + '"';
  return s;
}

(async () => {
  const headers = [
    'uid', 'display_name', 'session_id', 'finished_at', 'license_kind',
    'score', 'total', 'question_id', 'selected', 'correct',
  ];
  process.stdout.write(headers.join(',') + '\n');

  const snap = await db.collectionGroup('sessions').get();
  process.stderr.write(`fetched ${snap.size} session docs\n`);

  let rowCount = 0;
  for (const doc of snap.docs) {
    // 부모 문서 ID 가 uid. doc.ref.parent = sessions, .parent.parent = user_answers/{uid}.
    const uid = doc.ref.parent.parent?.id ?? '';
    const d = doc.data();
    const finishedAt = d.finished_at?.toDate?.().toISOString?.() ?? '';
    const items = Array.isArray(d.items) ? d.items : [];

    for (const item of items) {
      const row = [
        uid,
        d.display_name ?? '',
        doc.id,
        finishedAt,
        d.license_kind ?? '',
        d.score ?? '',
        d.total ?? '',
        item.q ?? '',
        Array.isArray(item.sel) ? item.sel.join('|') : '',
        item.correct === true ? 'TRUE' : 'FALSE',
      ];
      process.stdout.write(row.map(csv).join(',') + '\n');
      rowCount++;
    }
  }
  process.stderr.write(`wrote ${rowCount} item rows\n`);
})().catch((e) => {
  process.stderr.write(`ERROR: ${e.message}\n${e.stack}\n`);
  process.exit(1);
});
