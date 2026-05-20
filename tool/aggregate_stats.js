#!/usr/bin/env node
// tool/aggregate_stats.js
// GitHub Actions cron 에서 실행. Firestore user_answers 세션 로그를
// 집계해 aggregates.json, full_report.json, report.md 를 생성한다.
//
// 사용법:
//   GOOGLE_APPLICATION_CREDENTIALS=path/to/key.json node tool/aggregate_stats.js [out_dir]

import { readFile, mkdir, writeFile } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeApp, applicationDefault, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUT_DIR = process.argv[2] || join(__dirname, 'out');

// ── Firebase 초기화 ──────────────────────────────────────────────────────────

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

// ── 소카테고리 매핑 로드 ─────────────────────────────────────────────────────

async function loadSubcategoryMap() {
  const raw = await readFile(
    join(__dirname, '..', 'assets', 'question_subcategory.json'),
    'utf-8',
  );
  return JSON.parse(raw); // { "1": "license", "2": "license", ... }
}

// ── Firestore 데이터 수집 ────────────────────────────────────────────────────

async function fetchQuestionStats() {
  const usersSnap = await db.collection('user_answers').get();
  const stats = {};

  for (const userDoc of usersSnap.docs) {
    const sessionsSnap = await userDoc.ref.collection('sessions').get();
    for (const sessionDoc of sessionsSnap.docs) {
      const data = sessionDoc.data();
      const items = data.items;
      if (!Array.isArray(items)) continue;

      for (const item of items) {
        const qId = String(item.q);
        if (!stats[qId]) {
          stats[qId] = { attempts: 0, correct: 0, option_counts: {} };
        }
        stats[qId].attempts += 1;
        if (item.correct === true) {
          stats[qId].correct += 1;
        }
        const sel = item.sel;
        if (Array.isArray(sel)) {
          for (const idx of sel) {
            const key = String(idx);
            stats[qId].option_counts[key] =
              (stats[qId].option_counts[key] ?? 0) + 1;
          }
        }
      }
    }
  }

  return stats;
}

async function fetchUserCounts() {
  const usersSnap = await db.collection('user_answers').get();
  const totalUsers = usersSnap.size;

  let totalSessions = 0;
  for (const userDoc of usersSnap.docs) {
    const countSnap = await userDoc.ref
      .collection('sessions')
      .count()
      .get();
    totalSessions += countSnap.data().count;
  }

  return { totalUsers, totalSessions };
}

// ── 집계 로직 ────────────────────────────────────────────────────────────────

function computeWrongRate(attempts, correct) {
  return attempts > 0 ? 1 - correct / attempts : 0;
}

function buildHardestList(stats, topN) {
  return Object.entries(stats)
    .map(([id, s]) => ({
      question_id: Number(id),
      attempts: s.attempts,
      correct: s.correct,
      wrong_rate: computeWrongRate(s.attempts, s.correct),
    }))
    .filter((q) => q.attempts >= 5 && q.wrong_rate > 0)
    .sort((a, b) => b.wrong_rate - a.wrong_rate || b.attempts - a.attempts)
    .slice(0, topN);
}

function buildSubcategoryAggregates(stats, subcatMap) {
  const agg = {};
  for (const [id, s] of Object.entries(stats)) {
    const tag = subcatMap[id];
    if (!tag) continue;
    if (!agg[tag]) agg[tag] = { attempts: 0, correct: 0 };
    agg[tag].attempts += s.attempts;
    agg[tag].correct += s.correct;
  }
  // 표본 합 30 미만 태그 제외
  for (const tag of Object.keys(agg)) {
    if (agg[tag].attempts < 30) delete agg[tag];
  }
  return agg;
}

function buildAllQuestions(stats) {
  const result = {};
  for (const [id, s] of Object.entries(stats)) {
    result[id] = {
      attempts: s.attempts,
      correct: s.correct,
      wrong_rate: computeWrongRate(s.attempts, s.correct),
      option_counts: s.option_counts,
    };
  }
  return result;
}

// ── 출력 생성 ────────────────────────────────────────────────────────────────

function buildAggregatesJson(stats, subcatMap, updatedAt) {
  return {
    updated_at: updatedAt,
    hardest_top10: buildHardestList(stats, 10),
    subcategory: buildSubcategoryAggregates(stats, subcatMap),
    all_questions: buildAllQuestions(stats),
  };
}

function buildFullReportJson(stats, totalUsers, totalSessions, updatedAt) {
  return {
    updated_at: updatedAt,
    total_users: totalUsers,
    total_sessions: totalSessions,
    hardest_top20: buildHardestList(stats, 20),
    all_questions: buildAllQuestions(stats),
  };
}

function buildReportMd(fullReport) {
  const lines = [
    '# 운전면허 학과시험 1000제 통계 리포트',
    '',
    `> 최근 업데이트: ${fullReport.updated_at}`,
    '',
    '## 사용자 현황',
    `- 누적 사용자: **${fullReport.total_users.toLocaleString()}명**`,
    `- 누적 풀이 세션: **${fullReport.total_sessions.toLocaleString()}회**`,
    '',
    '## 가장 많이 틀리는 문제 TOP 20',
    '',
    '| 순위 | 문제 ID | 응시 | 오답률 |',
    '|------|---------|------|--------|',
  ];

  fullReport.hardest_top20.forEach((q, i) => {
    const pct = `${Math.round(q.wrong_rate * 100)}%`;
    lines.push(`| ${i + 1} | #${q.question_id} | ${q.attempts} | ${pct} |`);
  });

  lines.push('');
  return lines.join('\n');
}

// ── main ─────────────────────────────────────────────────────────────────────

async function main() {
  console.log('Fetching user_answers sessions...');
  const [stats, subcatMap, userCounts] = await Promise.all([
    fetchQuestionStats(),
    loadSubcategoryMap(),
    fetchUserCounts(),
  ]);

  const updatedAt = new Date().toISOString().replace(/\.\d{3}Z$/, 'Z');

  const aggregates = buildAggregatesJson(stats, subcatMap, updatedAt);
  const fullReport = buildFullReportJson(
    stats,
    userCounts.totalUsers,
    userCounts.totalSessions,
    updatedAt,
  );
  const reportMd = buildReportMd(fullReport);

  await mkdir(OUT_DIR, { recursive: true });

  await Promise.all([
    writeFile(join(OUT_DIR, 'aggregates.json'), JSON.stringify(aggregates, null, 2) + '\n'),
    writeFile(join(OUT_DIR, 'full_report.json'), JSON.stringify(fullReport, null, 2) + '\n'),
    writeFile(join(OUT_DIR, 'report.md'), reportMd),
  ]);

  console.log(`Done. Output written to ${OUT_DIR}`);
  console.log(`  - aggregates.json  (${aggregates.hardest_top10.length} hardest questions)`);
  console.log(`  - full_report.json (${Object.keys(fullReport.all_questions).length} questions, ${fullReport.total_users} users, ${fullReport.total_sessions} sessions)`);
  console.log(`  - report.md`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
