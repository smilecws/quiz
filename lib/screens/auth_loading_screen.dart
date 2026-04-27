import 'package:flutter/material.dart';

import '../theme/app_theme_colors.dart';

class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: CircularProgressIndicator(color: colors.primary),
      ),
    );
  }
}
