import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';

class GoogleAuthScreen extends StatefulWidget {
  const GoogleAuthScreen({super.key});

  @override
  State<GoogleAuthScreen> createState() => _GoogleAuthScreenState();
}

class _GoogleAuthScreenState extends State<GoogleAuthScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  // Inject this before the OAuth callback page runs so we can capture
  // the token that the backend sends via window.opener.postMessage(...)
  static const _interceptScript = '''
    window.opener = {
      postMessage: function(data, origin) {
        FlutterGoogleAuth.postMessage(JSON.stringify(data));
      }
    };
    window.close = function() {};
  ''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterGoogleAuth',
        onMessageReceived: (msg) => _handleToken(msg.message),
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (url) {
          setState(() => _loading = false);
          // Inject the interceptor on every page load so it's ready
          // before the callback script runs
          _controller.runJavaScript(_interceptScript);
        },
      ))
      ..loadRequest(Uri.parse('${ApiClient.baseUrl}/auth/google'));
  }

  void _handleToken(String raw) {
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final token    = data['token'] as String?;
      final userType = data['user_type'] as String?;
      if (token != null && mounted) {
        Navigator.pop(context, {'token': token, 'user_type': userType ?? 'web'});
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل الدخول بـ Google', style: GoogleFonts.tajawal()),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: _loading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.beige,
                ),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
