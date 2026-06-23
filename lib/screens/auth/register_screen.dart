import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  final _phoneCtrl     = TextEditingController();
  final _addressCtrl   = TextEditingController();
  final _bioCtrl       = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  bool _showPass       = false;
  bool _loading        = false;
  String? _gender;
  DateTime? _dob;
  int _step = 0; // 0 = account info, 1 = personal info

  @override
  void dispose() {
    for (final c in [_firstNameCtrl, _lastNameCtrl, _emailCtrl, _phoneCtrl, _addressCtrl, _bioCtrl, _passCtrl, _confirmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 10),
      locale: const Locale('ar'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.darkGreen,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  bool _validateStep0() {
    // Manually validate step-0 fields
    if (_firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.length < 8 ||
        _confirmCtrl.text != _passCtrl.text) return false;
    return true;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gender == null) {
      _showError('يرجى اختيار الجنس');
      return;
    }
    if (_dob == null) {
      _showError('يرجى اختيار تاريخ الميلاد');
      return;
    }
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.register({
      'first_name':            _firstNameCtrl.text.trim(),
      'last_name':             _lastNameCtrl.text.trim(),
      'email':                 _emailCtrl.text.trim(),
      'password':              _passCtrl.text,
      'password_confirmation': _confirmCtrl.text,
      'phone':                 _phoneCtrl.text.trim(),
      'address':               _addressCtrl.text.trim(),
      'bio':                   _bioCtrl.text.trim(),
      'gender':                _gender!,
      'date_of_birth':         '${_dob!.year}-${_dob!.month.toString().padLeft(2,'0')}-${_dob!.day.toString().padLeft(2,'0')}',
    });
    if (!mounted) return;
    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _loading = false);
    if (auth.error != null) {
      _showError(auth.error!);
      auth.clearError();
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.tajawal()),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.beige, size: 20),
                      onPressed: () {
                        if (_step == 1) {
                          setState(() => _step = 0);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    Expanded(
                      child: Text(
                        _step == 0 ? 'إنشاء حساب' : 'المعلومات الشخصية',
                        style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.beige),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Step indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    Expanded(child: _StepDot(active: true, label: '1')),
                    Expanded(child: Container(height: 2, color: _step == 1 ? AppColors.lightGreen : Colors.white24)),
                    Expanded(child: _StepDot(active: _step == 1, label: '2')),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Form card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (_step == 0) ...[
                            _field(_firstNameCtrl, 'الاسم الأول', Icons.person_outline_rounded),
                            const SizedBox(height: 12),
                            _field(_lastNameCtrl, 'اسم العائلة', Icons.person_outline_rounded),
                            const SizedBox(height: 12),
                            _field(_emailCtrl, 'البريد الإلكتروني', Icons.mail_outline_rounded,
                                type: TextInputType.emailAddress, ltr: true),
                            const SizedBox(height: 12),
                            _passField(),
                            const SizedBox(height: 12),
                            _confirmField(),
                            const SizedBox(height: 28),
                            _nextButton(),
                          ] else ...[
                            _field(_phoneCtrl, 'رقم الهاتف', Icons.phone_outlined,
                                type: TextInputType.phone, ltr: true),
                            const SizedBox(height: 12),
                            _field(_addressCtrl, 'العنوان', Icons.home_outlined),
                            const SizedBox(height: 12),
                            _field(_bioCtrl, 'نبذة عنك', Icons.info_outline_rounded, maxLines: 2),
                            const SizedBox(height: 12),
                            _genderDropdown(),
                            const SizedBox(height: 12),
                            _dobPicker(),
                            const SizedBox(height: 28),
                            _registerButton(),
                          ],
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'لديك حساب؟ سجّل دخولك',
                              style: GoogleFonts.tajawal(
                                fontSize: 14, color: AppColors.darkGreen,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.darkGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ).animate(key: ValueKey(_step)).fadeIn(duration: 300.ms).slideX(begin: _step == 1 ? 0.1 : -0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {
    TextInputType type = TextInputType.text,
    bool ltr = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      textDirection: ltr ? TextDirection.ltr : null,
      textAlign: TextAlign.right,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.lightGreen),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget _passField() {
    return TextFormField(
      controller: _passCtrl,
      obscureText: !_showPass,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.lightGreen),
        suffixIcon: IconButton(
          icon: Icon(_showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 20),
          onPressed: () => setState(() => _showPass = !_showPass),
        ),
      ),
      validator: (v) => (v == null || v.length < 8) ? 'كلمة المرور 8 أحرف على الأقل' : null,
    );
  }

  Widget _confirmField() {
    return TextFormField(
      controller: _confirmCtrl,
      obscureText: !_showPass,
      textAlign: TextAlign.right,
      decoration: const InputDecoration(
        labelText: 'تأكيد كلمة المرور',
        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.lightGreen),
      ),
      validator: (v) => v != _passCtrl.text ? 'كلمتا المرور غير متطابقتين' : null,
    );
  }

  Widget _genderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: const InputDecoration(
        labelText: 'الجنس',
        prefixIcon: Icon(Icons.wc_rounded, color: AppColors.lightGreen),
      ),
      items: const [
        DropdownMenuItem(value: 'm', child: Text('ذكر')),
        DropdownMenuItem(value: 'f', child: Text('أنثى')),
      ],
      onChanged: (v) => setState(() => _gender = v),
      validator: (v) => v == null ? 'يرجى اختيار الجنس' : null,
    );
  }

  Widget _dobPicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: TextFormField(
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: 'تاريخ الميلاد',
            prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.lightGreen),
            hintText: _dob == null
                ? 'اختر تاريخ الميلاد'
                : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
          ),
          controller: TextEditingController(
            text: _dob == null ? '' : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
          ),
          validator: (_) => _dob == null ? 'يرجى اختيار تاريخ الميلاد' : null,
        ),
      ),
    );
  }

  Widget _nextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            setState(() => _step = 1);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: AppColors.darkGreen,
        ),
        child: Text('التالي', style: GoogleFonts.tajawal(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _register,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: AppColors.darkGreen,
        ),
        child: _loading
            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text('إنشاء الحساب', style: GoogleFonts.tajawal(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;
  final String label;
  const _StepDot({required this.active, required this.label});
  @override
  Widget build(BuildContext context) => Center(
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: active ? AppColors.lightGreen : Colors.white24,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(label, style: GoogleFonts.tajawal(
          fontSize: 14, fontWeight: FontWeight.w800,
          color: active ? AppColors.darkGreen : Colors.white54,
        )),
      ),
    ),
  );
}
