import 'package:flutter/material.dart';
import '../theme/app_theme_colors.dart';
import 'study_screen.dart';
import 'written_exam_menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KOREAN DRIVING',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: colors.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '초심찾기 도로교통법',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '무엇을 할까요?',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              _HomeMenuCard(
                icon: Icons.menu_book_rounded,
                title: '학습하기',
                subtitle: '개념과 자료로 차분히 공부해요',
                filled: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StudyScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _HomeMenuCard(
                icon: Icons.timer_outlined,
                title: '문제 풀기',
                subtitle: '모의고사 · 연습 · 오답 노트',
                filled: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const WrittenExamMenuScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeMenuCard extends StatelessWidget {
  const _HomeMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final bgColor = filled ? colors.primary : colors.surfaceWhite;
    final titleColor = filled ? colors.onPrimary : colors.textPrimary;
    final subtitleColor = filled
        ? colors.onPrimary.withValues(alpha: 0.8)
        : colors.textSecondary;
    final iconColor = filled ? colors.onPrimary : colors.primaryDark;
    final iconBg = filled
        ? colors.onPrimary.withValues(alpha: 0.2)
        : colors.chipBg;
    final chevronColor = filled
        ? colors.onPrimary.withValues(alpha: 0.8)
        : colors.textSecondary;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 26, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: chevronColor),
            ],
          ),
        ),
      ),
    );
  }
}
