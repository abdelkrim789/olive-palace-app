import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import 'google_auth_screen.dart' show launchGoogleAuth;
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool _showPass       = false;
  bool _loading        = false;
  bool _googleLoading  = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _googleLogin() async {
    setState(() => _googleLoading = true);
    final result = await launchGoogleAuth(context);
    if (!mounted) return;
    if (result != null) {
      final ok = await context.read<AuthProvider>().loginWithGoogle(result['token']!, result['user_type']!);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }
    }
    if (mounted) setState(() => _googleLoading = false);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth    = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _loading = false);
    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!, style: GoogleFonts.tajawal()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Logo area ──────────────────────────────────────────────
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(40), width: 2),
                      ),
                      child: const Icon(Icons.eco_rounded, size: 46, color: AppColors.beige),
                    )
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut)
                        .fadeIn(duration: 400.ms),
                    const SizedBox(height: 16),
                    Text(
                      'Olive Palace',
                      style: GoogleFonts.tajawal(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.beige,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                    const SizedBox(height: 6),
                    Text(
                      'منصة الإرشاد الزراعي للزيتون',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: AppColors.lightGreen,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),

              // ── Form card ──────────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'تسجيل الدخول',
                            style: GoogleFonts.tajawal(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkGreen,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 20),

                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.lightGreen),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'أدخل بريدك الإلكتروني' : null,
                          ),
                          const SizedBox(height: 14),

                          // Password
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: !_showPass,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.lightGreen),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () => setState(() => _showPass = !_showPass),
                              ),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'أدخل كلمة المرور' : null,
                          ),
                          const SizedBox(height: 24),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: AppColors.darkGreen,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'دخول',
                                      style: GoogleFonts.tajawal(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Register link
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.tajawal(
                                    fontSize: 14,
                                    color: AppColors.textLight,
                                  ),
                                  children: [
                                    const TextSpan(text: 'ليس لديك حساب؟  '),
                                    TextSpan(
                                      text: 'سجّل الآن',
                                      style: GoogleFonts.tajawal(
                                        color: AppColors.darkGreen,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.darkGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('أو', style: GoogleFonts.tajawal(color: AppColors.textMuted, fontSize: 13)),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Google login
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _googleLoading ? null : _googleLogin,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppColors.border, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                backgroundColor: Colors.white,
                              ),
                              child: _googleLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('G', style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF4285F4))),
                                        const SizedBox(width: 10),
                                        Text('الدخول بـ Google', style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 0.4, duration: 500.ms, curve: Curves.easeOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
