import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/user/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const OlivePalaceApp());
}

class OlivePalaceApp extends StatelessWidget {
  const OlivePalaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..checkAuth(),
      child: MaterialApp(
        title: 'Olive Palace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: switch (auth.status) {
        AuthStatus.loading        => const _SplashScreen(),
        AuthStatus.authenticated  => auth.isAdmin
            ? const AdminMainScreen()
            : const UserMainScreen(),
        AuthStatus.unauthenticated => const LoginScreen(),
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha(40), width: 2),
                ),
                child: const Icon(Icons.eco_rounded, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'Olive Palace',
                style: GoogleFonts.tajawal(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'منصة إرشاد الزيتون',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: AppColors.lightGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
