import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

/// GIS(Google Identity Services) 가 직접 렌더링하는 공식 Sign-In Button.
/// google_sign_in 6.x + google_sign_in_web 0.12.x 조합에서는 이 버튼을 통해서만
/// 웹 로그인이 가능하다 (signIn() programmatic 호출은 deprecated).
/// 클릭 결과는 GoogleSignIn.onCurrentUserChanged 스트림으로 전달된다.
class GoogleSignInWebButton extends StatelessWidget {
  const GoogleSignInWebButton({super.key});

  @override
  Widget build(BuildContext context) {
    return web.renderButton(
      configuration: web.GSIButtonConfiguration(
        type: web.GSIButtonType.standard,
        theme: web.GSIButtonTheme.outline,
        size: web.GSIButtonSize.large,
        text: web.GSIButtonText.signinWith,
        shape: web.GSIButtonShape.rectangular,
      ),
    );
  }
}
