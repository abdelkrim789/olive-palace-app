import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';

class SubmitRequestScreen extends StatefulWidget {
  const SubmitRequestScreen({super.key});
  @override
  State<SubmitRequestScreen> createState() => _SubmitRequestScreenState();
}

class _SubmitRequestScreenState extends State<SubmitRequestScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  bool _loading    = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiClient.instance.post(
        '/api/user/guidance-requests/submit-request',
        data: {'title': _titleCtrl.text.trim(), 'description': _descCtrl.text.trim()},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال طلبك بنجاح ✓', style: GoogleFonts.tajawal()),
          backgroundColor: AppColors.statusResolved,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر إرسال الطلب', style: GoogleFonts.tajawal()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب إرشاد جديد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightGreen.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.green, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'سيقوم فريقنا من خبراء الزيتون بالرد عليك في أقرب وقت.',
                        style: GoogleFonts.tajawal(fontSize: 13, color: AppColors.textLight),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title field
              Text('عنوان الطلب', style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkGreen), textAlign: TextAlign.right),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: 'مثال: مشكلة في أشجار الزيتون',
                  prefixIcon: Icon(Icons.title_rounded, color: AppColors.lightGreen),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'أدخل عنوان الطلب' : null,
              ),
              const SizedBox(height: 20),

              // Description
              Text('وصف المشكلة', style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkGreen), textAlign: TextAlign.right),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                textAlign: TextAlign.right,
                maxLines: 7,
                decoration: const InputDecoration(
                  hintText: 'اشرح مشكلتك بالتفصيل لمساعدتك بشكل أفضل...',
                  contentPadding: EdgeInsets.all(16),
                ),
                validator: (v) => (v == null || v.length < 20)
                    ? 'الوصف يجب أن يكون 20 حرفاً على الأقل' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(_loading ? 'جارٍ الإرسال...' : 'إرسال الطلب',
                      style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
