import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/request_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/status_badge.dart';

class AdminRequestDetailScreen extends StatefulWidget {
  final RequestModel req;
  const AdminRequestDetailScreen({super.key, required this.req});
  @override
  State<AdminRequestDetailScreen> createState() => _AdminRequestDetailScreenState();
}

class _AdminRequestDetailScreenState extends State<AdminRequestDetailScreen> {
  late RequestModel _req;
  bool _actionLoading = false;
  final _notesCtrl    = TextEditingController();

  @override
  void initState() {
    super.initState();
    _req = widget.req;
    _notesCtrl.text = _req.adminNotes ?? '';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  // Maps Flutter status strings to the correct backend route segment
  String _actionEndpoint(String status) {
    return switch (status) {
      'in_progress' => '/api/super-admin/guidence-requests/assign/${_req.id}',
      'resolved'    => '/api/super-admin/guidence-requests/resolve/${_req.id}',
      _             => '/api/super-admin/guidence-requests/cancel/${_req.id}',
    };
  }

  Future<void> _updateStatus(String status, {String? notes}) async {
    setState(() => _actionLoading = true);
    try {
      final body = <String, dynamic>{};
      if (notes != null && notes.isNotEmpty) body['admin_notes'] = notes;
      final res = await ApiClient.instance.put(
        _actionEndpoint(status),
        data: body,
      );
      final updated = res.data['request'];
      if (updated != null) setState(() => _req = RequestModel.fromJson(updated));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث الطلب ✓', style: GoogleFonts.tajawal()),
          backgroundColor: AppColors.statusResolved,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر تحديث الطلب', style: GoogleFonts.tajawal()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() => _actionLoading = false);
  }

  void _showNotesSheet({required String targetStatus, required String actionLabel, required Color color}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(actionLabel,
                style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesCtrl,
                maxLines: 4,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ملاحظات للمستخدم (اختياري)...',
                  hintStyle: GoogleFonts.tajawal(color: AppColors.textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(14),
                ),
                style: GoogleFonts.tajawal(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _updateStatus(targetStatus, notes: _notesCtrl.text.trim());
                },
                child: Text(actionLabel,
                  style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isSa = auth.isSuperAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status + meta
            Container(
              decoration: cardDecoration(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(status: _req.status),
                      Text(
                        'طلب #${_req.id}',
                        style: GoogleFonts.tajawal(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _req.title,
                    style: GoogleFonts.tajawal(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  if (_req.createdAt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${_req.createdAt!.day}/${_req.createdAt!.month}/${_req.createdAt!.year}',
                          style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textMuted),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Requester
            if (_req.user != null)
              Container(
                decoration: cardDecoration(),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('طالب الإرشاد',
                          style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.textMuted)),
                        Text(_req.user!.fullName,
                          style: GoogleFonts.tajawal(
                            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkGreen,
                          )),
                      ],
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.beige,
                      child: Text(
                        _req.user!.fullName.isNotEmpty ? _req.user!.firstName[0] : '؟',
                        style: GoogleFonts.tajawal(
                          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),

            // Description
            Container(
              decoration: cardDecoration(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('وصف المشكلة',
                    style: GoogleFonts.tajawal(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkGreen,
                    )),
                  const SizedBox(height: 10),
                  Text(
                    _req.description,
                    style: GoogleFonts.tajawal(fontSize: 15, height: 1.8, color: AppColors.text),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Admin notes
            if (_req.adminNotes != null && _req.adminNotes!.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.statusResolved.withAlpha(12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.statusResolved.withAlpha(50)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('ملاحظات المشرف',
                          style: GoogleFonts.tajawal(
                            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.statusResolved,
                          )),
                        const SizedBox(width: 6),
                        const Icon(Icons.note_alt_outlined, color: AppColors.statusResolved, size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _req.adminNotes!,
                      style: GoogleFonts.tajawal(fontSize: 14, height: 1.7, color: AppColors.text),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Action buttons
            if (_actionLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.darkGreen))
            else ...[
              if (_req.status == 'pending' && (isSa || auth.isAdmin))
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusProgress,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showNotesSheet(
                    targetStatus: 'in_progress',
                    actionLabel: 'بدء المعالجة',
                    color: AppColors.statusProgress,
                  ),
                  icon: const Icon(Icons.sync_rounded, color: Colors.white),
                  label: Text('بدء المعالجة',
                    style: GoogleFonts.tajawal(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              if (_req.status == 'in_progress' || _req.status == 'pending') ...[
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusResolved,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showNotesSheet(
                    targetStatus: 'resolved',
                    actionLabel: 'تحديد كمحلول',
                    color: AppColors.statusResolved,
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                  label: Text('تحديد كمحلول',
                    style: GoogleFonts.tajawal(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showNotesSheet(
                    targetStatus: 'closed',
                    actionLabel: 'إغلاق الطلب',
                    color: AppColors.error,
                  ),
                  icon: const Icon(Icons.lock_outline_rounded, color: AppColors.error),
                  label: Text('إغلاق الطلب',
                    style: GoogleFonts.tajawal(color: AppColors.error, fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ],
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
