import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/request_model.dart';
import '../../widgets/status_badge.dart';

class UserRequestDetailScreen extends StatefulWidget {
  final RequestModel request;
  const UserRequestDetailScreen({super.key, required this.request});
  @override
  State<UserRequestDetailScreen> createState() => _UserRequestDetailScreenState();
}

class _UserRequestDetailScreenState extends State<UserRequestDetailScreen> {
  late RequestModel _req;
  bool _editing = false;
  bool _saving  = false;
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _req = widget.request;
    _titleCtrl.text = _req.title;
    _descCtrl.text  = _req.description;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final res = await ApiClient.instance.put(
        '/api/user/guidance-requests/my-requests/${_req.id}',
        data: {'title': _titleCtrl.text.trim(), 'description': _descCtrl.text.trim()},
      );
      final updated = RequestModel.fromJson(res.data['request'] ?? res.data);
      if (mounted) {
        setState(() { _req = updated; _editing = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('تم تحديث الطلب', style: GoogleFonts.tajawal()),
          backgroundColor: AppColors.statusResolved,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('فشل التحديث، حاول مجدداً', style: GoogleFonts.tajawal()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
    if (mounted) setState(() => _saving = false);
  }

  String _statusDesc(String s) => switch (s) {
    'pending'     => 'طلبك في قائمة الانتظار، سيراجعه فريقنا قريباً.',
    'in_progress' => 'خبراؤنا يعملون على طلبك الآن.',
    'resolved'    => 'تم حل طلبك بنجاح. يمكنك التواصل معنا لأي استفسار.',
    'closed'      => 'تم إغلاق هذا الطلب.',
    _             => '',
  };

  @override
  Widget build(BuildContext context) {
    final canEdit = _req.status == 'pending';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.darkGreen,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context, _req),
            ),
            actions: [
              if (canEdit && !_editing)
                TextButton.icon(
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit_rounded, color: AppColors.lightGreen, size: 16),
                  label: Text('تعديل', style: GoogleFonts.tajawal(color: AppColors.lightGreen, fontWeight: FontWeight.w700)),
                ),
              if (_editing)
                TextButton(
                  onPressed: () => setState(() {
                    _editing = false;
                    _titleCtrl.text = _req.title;
                    _descCtrl.text  = _req.description;
                  }),
                  child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.beige)),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(right: 20, bottom: 14),
              title: Text('تفاصيل الطلب',
                  style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.headerGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StatusBadge(status: _req.status),
                        const SizedBox(height: 8),
                        Text(_statusDesc(_req.status),
                          style: GoogleFonts.tajawal(fontSize: 12, color: Colors.white70),
                          textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _editing ? _buildEditForm() : _buildView(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _editing ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _saving
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text('حفظ التعديلات', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ) : null,
    );
  }

  Widget _buildView() {
    return Column(
      children: [
        // Title + date card
        _Card(children: [
          _Row('العنوان', _req.title, large: true),
          const SizedBox(height: 8),
          _Row('تاريخ الإرسال', _req.createdAt != null
              ? '${_req.createdAt!.day}/${_req.createdAt!.month}/${_req.createdAt!.year}'
              : '—'),
        ]).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1),

        const SizedBox(height: 14),

        // Description
        _Card(title: 'تفاصيل الطلب', children: [
          Text(_req.description,
            style: GoogleFonts.tajawal(fontSize: 15, color: AppColors.text, height: 1.8),
            textAlign: TextAlign.right),
        ]).animate(delay: 80.ms).fadeIn(duration: 350.ms).slideY(begin: 0.1),

        // Admin notes
        if (_req.adminNotes != null && _req.adminNotes!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withAlpha(8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkGreen.withAlpha(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('رد المشرف', style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkGreen)),
                  const SizedBox(width: 8),
                  const Icon(Icons.admin_panel_settings_rounded, size: 18, color: AppColors.darkGreen),
                ]),
                const SizedBox(height: 10),
                Text(_req.adminNotes!,
                  style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.textLight, height: 1.7),
                  textAlign: TextAlign.right),
              ],
            ),
          ).animate(delay: 160.ms).fadeIn(duration: 350.ms).slideY(begin: 0.1),
        ],
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: _Card(title: 'تعديل الطلب', children: [
        TextFormField(
          controller: _titleCtrl,
          textAlign: TextAlign.right,
          style: GoogleFonts.tajawal(fontSize: 15),
          decoration: const InputDecoration(
            labelText: 'عنوان الطلب',
            prefixIcon: Icon(Icons.title_rounded, color: AppColors.lightGreen),
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'العنوان مطلوب' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _descCtrl,
          textAlign: TextAlign.right,
          style: GoogleFonts.tajawal(fontSize: 15),
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'تفاصيل الطلب',
            prefixIcon: Icon(Icons.description_outlined, color: AppColors.lightGreen),
            alignLabelWithHint: true,
          ),
          validator: (v) => v == null || v.trim().length < 20 ? 'التفاصيل يجب أن تكون 20 حرفاً على الأقل' : null,
        ),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _Card({this.title, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: cardDecoration(radius: 16),
    padding: const EdgeInsets.all(18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      if (title != null) ...[
        Text(title!, style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkGreen)),
        const Divider(height: 20),
      ],
      ...children,
    ]),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool large;
  const _Row(this.label, this.value, {this.large = false});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text(label, style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.textMuted)),
    const SizedBox(height: 2),
    Text(value, style: GoogleFonts.tajawal(
      fontSize: large ? 17 : 14,
      fontWeight: large ? FontWeight.w700 : FontWeight.w500,
      color: AppColors.darkGreen,
    ), textAlign: TextAlign.right),
  ]);
}
