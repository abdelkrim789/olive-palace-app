import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  bool _showPass       = false;
  bool _loading        = false;

  @override
  void dispose() {
    for (final c in [_firstNameCtrl, _lastNameCtrl, _emailCtrl, _passCtrl, _confirmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth    = context.read<AuthProvider>();
    final success = await auth.register({
      'first_name':            _firstNameCtrl.text.trim(),
      'last_name':             _lastNameCtrl.text.trim(),
      'email':                 _emailCtrl.text.trim(),
      'password':              _passCtrl.text,
      'password_confirmation': _confirmCtrl.text,
    });
    if (!mounted) return;
    setState(() => _loading = false);
    if (!success && auth.error != null) {
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
              // Back + title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.beige, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'إنشاء حساب',
                        style: GoogleFonts.tajawal(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.beige,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _field(_firstNameCtrl, 'الاسم الأول',   Icons.person_outline_rounded),
                          const SizedBox(height: 12),
                          _field(_lastNameCtrl,  'اسم العائلة',   Icons.person_outline_rounded),
                          const SizedBox(height: 12),
                          _field(_emailCtrl,     'البريد الإلكتروني', Icons.mail_outline_rounded,
                              type: TextInputType.emailAddress, ltr: true),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: !_showPass,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.lightGreen),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.textMuted, size: 20,
                                ),
                                onPressed: () => setState(() => _showPass = !_showPass),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 8)
                                ? 'كلمة المرور 8 أحرف على الأقل' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: !_showPass,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              labelText: 'تأكيد كلمة المرور',
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.lightGreen),
                            ),
                            validator: (v) => v != _passCtrl.text
                                ? 'كلمتا المرور غير متطابقتين' : null,
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _register,
                              child: _loading
                                  ? const SizedBox(
                                      height: 22, width: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Text('تسجيل', style: GoogleFonts.tajawal(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'لديك حساب؟ سجّل دخولك',
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.darkGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool ltr = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.lightGreen),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null,
    );
  }
}
