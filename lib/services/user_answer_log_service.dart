import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/mock_exam_license_kind.dart';
import '../models/session_result.dart';
import 'global_answer_stats_service.dart';
import 'global_stats_consent_service.dart';

/// 한 세션의 모든 풀이 결과를 Firestore 에
/// `user_answers/{uid}/sessions/{auto_id}` 1 문서로 저장한다.
///
/// 운영자(=프로젝트 소유자) 가 Firebase 콘솔에서 uid 단위로
/// 어떤 사용자가 어떤 답을 골랐는지 조회하기 위한 용도이며, 클라이언트에서
/// 다시 읽지 않는다(보안 규칙도 read 금지).
class UserAnswerLogService {
  UserAnswerLogService._();

  static const _collection = 'user_answers';

  /// 세션 종료 시 1회 호출. 실패해도 throw 하지 않는다.
  /// 동의 거부 / 미지원 플랫폼 / 익명 로그인 실패 시 no-op.
  static Future<void> saveSession(
    List<SessionResult> results, {
    MockExamLicenseKind? licenseKind,
    DateTime? startedAt,
  }) async {
    if (!GlobalAnswerStatsService.isSupported || results.isEmpty) return;

    final consent = await GlobalStatsConsentService.load();
    if (!consent) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final int score = results.where((r) => r.isCorrect).length;
      final List<Map<String, dynamic>> items = [
        for (final r in results)
          {
            'q': r.questionId,
            'sel': r.selectedIndices,
            'correct': r.isCorrect,
          },
      ];

      await firestore
          .collection(_collection)
          .doc(user.uid)
          .collection('sessions')
          .add({
        'display_name': user.displayName ?? '',
        'started_at': startedAt != null
            ? Timestamp.fromDate(startedAt)
            : FieldValue.serverTimestamp(),
        'finished_at': FieldValue.serverTimestamp(),
        'license_kind': licenseKind?.name,
        'score': score,
        'total': results.length,
        'items': items,
      });
    } catch (e) {
      debugPrint('UserAnswerLogService.saveSession failed: $e');
    }
  }
}
