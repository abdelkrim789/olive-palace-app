import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../../core/api_client.dart';

// Opens Google OAuth in Chrome Custom Tabs (not WebView — avoids Google's
// disallowed_useragent block). The backend redirects back to olive-palace://auth
// after successful authentication.
Future<Map<String, String>?> launchGoogleAuth(BuildContext context) async {
  try {
    final result = await FlutterWebAuth2.authenticate(
      url: '${ApiClient.baseUrl}/auth/google/redirect?mobile=1',
      callbackUrlScheme: 'olive-palace',
    );
    final uri = Uri.parse(result);
    final token    = uri.queryParameters['token'];
    final userType = uri.queryParameters['user_type'] ?? 'web';
    if (token != null) return {'token': token, 'user_type': userType};
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إلغاء تسجيل الدخول بـ Google')),
      );
    }
  }
  return null;
}
