import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.darkGreen,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(right: 20, bottom: 52),
              title: Text('تعديل الملف الشخصي',
                  style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              background: Container(decoration: const BoxDecoration(gradient: AppColors.headerGradient)),
            ),
            bottom: TabBar(
              controller: _tabs,
              labelStyle: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.tajawal(fontSize: 14),
              labelColor: AppColors.lightGreen,
              unselectedLabelColor: Colors.white60,
              indicatorColor: AppColors.lightGreen,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'المعلومات'),
                Tab(text: 'كلمة المرور'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: const [
            _InfoTab(),
            _PasswordTab(),
          ],
        ),
      ),
    );
  }
}

// ── Info Tab ──────────────────────────────────────────────────────────────────

class _InfoTab extends StatefulWidget {
  const _InfoTab();
  @override
  State<_InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<_InfoTab> {
  final _formKey     = GlobalKey<FormState>();
  final _firstCtrl   = TextEditingController();
  final _lastCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bioCtrl     = TextEditingController();
  bool _loading = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = context.read<AuthProvider>().user;
      _firstCtrl.text   = user?.firstName ?? '';
      _lastCtrl.text    = user?.lastName ?? '';
      _emailCtrl.text   = user?.email ?? '';
      _phoneCtrl.text   = user?.phone ?? '';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    for (final c in [_firstCtrl, _lastCtrl, _emailCtrl, _phoneCtrl, _addressCtrl, _bioCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile({
      'first_name': _firstCtrl.text.trim(),
      'last_name':  _lastCtrl.text.trim(),
      'email':      _emailCtrl.text.trim(),
      'phone':      _phoneCtrl.text.trim(),
      'address':    _addressCtrl.text.trim(),
      'bio':        _bioCtrl.text.trim(),
    });
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'تم حفظ التعديلات' : (auth.error ?? 'حدث خطأ'),
          style: GoogleFonts.tajawal()),
      backgroundColor: ok ? AppColors.statusResolved : AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    if (!ok) auth.clearError();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _card([
              _f(_firstCtrl,   'الاسم الأول',         Icons.person_outline_rounded),
              _f(_lastCtrl,    'اسم العائلة',          Icons.person_outline_rounded),
              _f(_emailCtrl,   'البريد الإلكتروني',   Icons.mail_outline_rounded, ltr: true, type: TextInputType.emailAddress),
              _f(_phoneCtrl,   'رقم الهاتف',           Icons.phone_outlined,        ltr: true, type: TextInputType.phone, required: false),
              _f(_addressCtrl, 'العنوان',              Icons.home_outlined,          required: false),
              _f(_bioCtrl,     'نبذة عنك',             Icons.info_outline_rounded,   maxLines: 2, required: false),
            ]).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text('حفظ التعديلات', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 350.ms),
          ],
        ),
      ),
    );
  }

  Widget _f(TextEditingController ctrl, String label, IconData icon, {
    TextInputType type = TextInputType.text,
    bool ltr = false,
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        textDirection: ltr ? TextDirection.ltr : null,
        textAlign: TextAlign.right,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: AppColors.lightGreen)),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null : null,
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
    decoration: cardDecoration(radius: 16),
    padding: const EdgeInsets.all(18),
    child: Column(children: children),
  );
}

// ── Password Tab ──────────────────────────────────────────────────────────────

class _PasswordTab extends StatefulWidget {
  const _PasswordTab();
  @override
  State<_PasswordTab> createState() => _PasswordTabState();
}

class _PasswordTabState extends State<_PasswordTab> {
  final _formKey  = GlobalKey<FormState>();
  final _currCtrl = TextEditingController();
  final _newCtrl  = TextEditingController();
  final _confCtrl = TextEditingController();
  bool _showCurr = false;
  bool _showNew  = false;
  bool _loading  = false;

  @override
  void dispose() {
    _currCtrl.dispose();
    _newCtrl.dispose();
    _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth     = context.read<AuthProvider>();
      final userType = auth.userType ?? 'web';
      final endpoints = {
        'super_admin': '/api/super-admin/profile/password',
        'admin':       '/api/admin/profile/password',
        'web':         '/api/user/profile/password',
      };
      await ApiClient.instance.put(endpoints[userType] ?? endpoints['web']!, data: {
        'current_password':      _currCtrl.text,
        'password':              _newCtrl.text,
        'password_confirmation': _confCtrl.text,
      });
      if (mounted) {
        _currCtrl.clear(); _newCtrl.clear(); _confCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('تم تغيير كلمة المرور', style: GoogleFonts.tajawal()),
          backgroundColor: AppColors.statusResolved,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('كلمة المرور الحالية غير صحيحة', style: GoogleFonts.tajawal()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              decoration: cardDecoration(radius: 16),
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                _passField(_currCtrl, 'كلمة المرور الحالية', _showCurr, () => setState(() => _showCurr = !_showCurr),
                    validator: (v) => (v == null || v.isEmpty) ? 'هذا الحقل مطلوب' : null),
                const SizedBox(height: 14),
                _passField(_newCtrl, 'كلمة المرور الجديدة', _showNew, () => setState(() => _showNew = !_showNew),
                    validator: (v) => (v == null || v.length < 8) ? '8 أحرف على الأقل' : null),
                const SizedBox(height: 14),
                _passField(_confCtrl, 'تأكيد كلمة المرور', _showNew, () {},
                    validator: (v) => v != _newCtrl.text ? 'كلمتا المرور غير متطابقتين' : null),
              ]),
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text('تغيير كلمة المرور', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 350.ms),
          ],
        ),
      ),
    );
  }

  Widget _passField(TextEditingController ctrl, String label, bool visible, VoidCallback toggle,
      {required String? Function(String?) validator}) {
    return TextFormField(
      controller: ctrl,
      obscureText: !visible,
      textAlign: TextAlign.right,
      style: GoogleFonts.tajawal(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.lightGreen),
        suffixIcon: label == 'كلمة المرور الحالية' ? null : IconButton(
          icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 20),
          onPressed: toggle,
        ),
      ),
      validator: validator,
    );
  }
}
