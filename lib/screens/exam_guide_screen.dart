import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme_colors.dart';

/// 한국도로교통공단 안전운전 통합민원 「면허시험순서」 안내 요약.
/// https://www.safedriving.or.kr/guide/rerGuide01View.do?menuCode=MN-PO-1111
class ExamGuideScreen extends StatelessWidget {
  const ExamGuideScreen({super.key});

  static const String _officialGuideUrl =
      'https://www.safedriving.or.kr/guide/rerGuide01View.do?menuCode=MN-PO-1111';
  /// 면허시험 일정·접수 (모바일 웹)
  static const String _officialScheduleUrl =
      'https://www.safedriving.or.kr/rerrest/rerrestScheduleViewM.do?menuCode=MN-PO-1131';
  /// 특별교통안전교육 교육장·날짜 선택 (모바일 웹)
  static const String _officialEducationScheduleUrl =
      'https://www.safedriving.or.kr/eduSeSpecial/eduSeSpecialExmDayLocalNoneM.do';
  static const String _officialPreparationGuideUrl =
      'https://www.safedriving.or.kr/guide/rerGuide07View.do?menuCode=MN-PO-1117';

  static Future<void> openOfficialPage(BuildContext context) async {
    final uri = Uri.parse(_officialGuideUrl);
    try {
      var ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        ok = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('브라우저를 열 수 없습니다. 잠시 후 다시 시도해 주세요.'),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('openOfficialPage: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('링크를 열지 못했습니다.')),
        );
      }
    }
  }

  static Future<void> openSchedulePage(BuildContext context) async {
    final uri = Uri.parse(_officialScheduleUrl);
    try {
      var ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        ok = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('브라우저를 열 수 없습니다. 잠시 후 다시 시도해 주세요.'),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('openSchedulePage: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('링크를 열지 못했습니다.')),
        );
      }
    }
  }

  static Future<void> openEducationSchedulePage(BuildContext context) async {
    final uri = Uri.parse(_officialEducationScheduleUrl);
    try {
      var ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        ok = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('브라우저를 열 수 없습니다. 잠시 후 다시 시도해 주세요.'),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('openEducationSchedulePage: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('링크를 열지 못했습니다.')),
        );
      }
    }
  }

  static Future<void> openPreparationGuidePage(BuildContext context) async {
    final uri = Uri.parse(_officialPreparationGuideUrl);
    try {
      var ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        ok = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('브라우저를 열 수 없습니다. 잠시 후 다시 시도해 주세요.'),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('openPreparationGuidePage: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('링크를 열지 못했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: const Text('면허시험 순서'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            '응시 전 교통안전교육부터 면허증 발급까지의 흐름입니다. '
            '시험장·면허 종류에 따라 달라질 수 있으니 원문을 꼭 확인하세요.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ..._steps.map((s) => _StepCard(step: s)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => openOfficialPage(context),
              icon: const Icon(Icons.open_in_new, size: 20),
              label: const Text('공식 안내 페이지에서 자세히 보기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.appColors.primaryDark,
                side: BorderSide(
                  color: context.appColors.primary.withValues(alpha: 0.45),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '출처: 한국도로교통공단 안전운전 통합민원',
            style: TextStyle(
              fontSize: 11,
              color: context.appColors.textSecondary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// 한국도로교통공단 안전운전 통합민원 「면허시험 준비물 가이드」 요약.
/// https://www.safedriving.or.kr/guide/rerGuide07View.do?menuCode=MN-PO-1117
class PreparationGuideScreen extends StatelessWidget {
  const PreparationGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: const Text('준비물 가이드'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            '시험 종류별 수수료·준비물·접수 방법 요약입니다. '
            '시험장·면허 종류에 따라 달라질 수 있으니 원문을 꼭 확인하세요.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ..._preparationSteps.map((s) => _StepCard(step: s)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  ExamGuideScreen.openPreparationGuidePage(context),
              icon: const Icon(Icons.open_in_new, size: 20),
              label: const Text('공식 안내 페이지에서 자세히 보기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.appColors.primaryDark,
                side: BorderSide(
                  color: context.appColors.primary.withValues(alpha: 0.45),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '출처: 한국도로교통공단 안전운전 통합민원',
            style: TextStyle(
              fontSize: 11,
              color: context.appColors.textSecondary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStep {
  const _GuideStep({
    required this.title,
    required this.lines,
  });

  final String title;
  final List<String> lines;
}

const List<_GuideStep> _steps = [
  _GuideStep(
    title: '1. 응시 전 교통안전교육',
    lines: [
      '학과시험 전까지 이수 완료(특별교통안전교육 이수자 이수 불필요)',
      '준비물: 신분증',
    ],
  ),
  _GuideStep(
    title: '2. 신체검사',
    lines: [
      '시험장 내 신체검사실 또는 병원에서 검사 진행',
      '문경·강릉·태백·광양·충주·춘천 시험장에는 시험장 내 신체검사원이 없음',
    ],
  ),
  _GuideStep(
    title: '3. 학과시험',
    lines: [
      '준비물: 응시원서, 신분증, 6개월 이내 촬영 컬러 사진(3.5×4.5cm) 3매',
      '일부 시험장은 학과시험 방문시간 예약이 필요할 수 있음',
    ],
  ),
  _GuideStep(
    title: '4. 기능시험',
    lines: [
      '준비물: 응시원서, 신분증',
      '대리접수: 대리인 신분증 및 위임자의 위임장',
      '불합격 시: 불합격일로부터 3일 경과 후 재응시 가능',
    ],
  ),
  _GuideStep(
    title: '5. 연습면허 발급',
    lines: [
      '제1·2종 보통면허 시험 응시자 중 학과·장내기능 시험에 모두 합격한 자',
      '준비물: 응시원서, 신분증',
    ],
  ),
  _GuideStep(
    title: '6. 도로주행시험',
    lines: [
      '불합격 시: 불합격일로부터 3일 경과 후 재응시 가능',
      '준비물: 응시원서, 신분증',
    ],
  ),
  _GuideStep(
    title: '7. 운전면허증 발급',
    lines: [
      '제1·2종 보통: 연습면허 취득 후 도로주행시험에 합격한 자',
      '기타 면허: 학과·기능시험에 합격한 자',
      '준비물: 응시원서, 신분증',
    ],
  ),
];

/// [면허시험 준비물 가이드](https://www.safedriving.or.kr/guide/rerGuide07View.do?menuCode=MN-PO-1117) 요약
const List<_GuideStep> _preparationSteps = [
  _GuideStep(
    title: '신규 응시 신체검사',
    lines: [
      '수수료: 1종 대형·특수 7,000원, 그 외 면허 6,000원(시험장 내 신체검사장 기준)',
      '준비물·유의: 신분증, 6개월 이내 촬영 컬러 사진(3.5×4.5cm) 3매 등',
      '인터넷·대리 접수 불가(본인 신체검사)',
    ],
  ),
  _GuideStep(
    title: '학과 시험(재응시 포함)',
    lines: [
      '수수료: 10,000원(원동기 8,000원)',
      '준비물: 신분증, 응시원서',
      '인터넷 방문시간 예약 가능, 대리 접수 불가',
    ],
  ),
  _GuideStep(
    title: '기능 시험(재응시 포함)',
    lines: [
      '수수료: 대형·특수·1·2종 보통 25,000원, 2종 소형 14,000원, 원동기 10,000원',
      '준비물: 신분증, 응시원서',
      '대리 접수 가능(위임장, 대리인·위임자 신분증, 응시원서)',
    ],
  ),
  _GuideStep(
    title: '도로주행 시험(재응시 포함)',
    lines: [
      '수수료: 30,000원',
      '준비물: 신분증, 응시원서',
      '대리 접수 가능(위임장, 대리인·위임자 신분증, 응시원서)',
    ],
  ),
  _GuideStep(
    title: '합격자 면허증 교부',
    lines: [
      '수수료: 국문·영문 면허증 10,000원, 모바일 면허증(국문·영문) 15,000원',
      '준비물: 신분증, 응시원서, 6개월 이내 컬러 사진(3.5×4.5cm) 1매(기존 면허 소지 시 반납)',
      '인터넷 불가, 대리 접수 가능·수령은 본인만 가능',
    ],
  ),
  _GuideStep(
    title: '연습면허·연습면허 재교부',
    lines: [
      '수수료: 4,000원',
      '준비물: 신분증, 응시원서',
      '인터넷 가능(연습면허 재교부는 인터넷 불가), 대리 접수 가능',
    ],
  ),
  _GuideStep(
    title: '응시원서 분실',
    lines: [
      '수수료: 1,000원(연습면허 재발급 시 4,000원)',
      '준비물: 신분증, 6개월 이내 컬러 사진(3.5×4.5cm) 1매',
      '인터넷 불가, 대리 접수 가능',
    ],
  ),
];

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});

  final _GuideStep step;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            ...step.lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: c.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        line,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
