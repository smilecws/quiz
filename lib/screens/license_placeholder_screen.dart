import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';

/// 기능시험·도로주행 등 아직 콘텐츠가 없는 구간용 화면
class LicensePlaceholderScreen extends StatelessWidget {
  const LicensePlaceholderScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '이 메뉴는 준비 중입니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
