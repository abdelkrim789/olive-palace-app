import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent    = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiClient.instance.post('/api/auth/forgot-password', data: {
        'email': _emailCtrl.text.trim(),
      });
      if (mounted) setState(() => _sent = true);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تعذّر إرسال الرابط، تحقق من البريد الإلكتروني', style: GoogleFonts.tajawal()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.beige, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text('استعادة كلمة المرور',
                          style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.beige),
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: _sent ? _buildSuccess() : _buildForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withAlpha(8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkGreen.withAlpha(20)),
            ),
            child: Column(
              children: [
                const Icon(Icons.lock_reset_rounded, size: 48, color: AppColors.darkGreen),
                const SizedBox(height: 12),
                Text('أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.',
                    style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.textLight, height: 1.6),
                    textAlign: TextAlign.center),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),

          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.lightGreen),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'أدخل بريدك الإلكتروني';
              if (!v.contains('@')) return 'بريد إلكتروني غير صحيح';
              return null;
            },
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text('إرسال رابط الاستعادة',
                      style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(color: AppColors.statusResolved.withAlpha(20), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_rounded, size: 48, color: AppColors.statusResolved),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text('تم الإرسال!',
            style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.darkGreen))
            .animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 10),
        Text('تحقق من بريدك الإلكتروني واتبع التعليمات لإعادة تعيين كلمة المرور.',
            style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.textMuted, height: 1.6),
            textAlign: TextAlign.center)
            .animate(delay: 300.ms).fadeIn(),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.darkGreen),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text('العودة لتسجيل الدخول',
              style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.darkGreen)),
        ).animate(delay: 400.ms).fadeIn(),
      ],
    );
  }
}
