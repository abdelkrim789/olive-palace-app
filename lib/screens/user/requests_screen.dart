import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/request_model.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'submit_request_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});
  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  List<RequestModel> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res  = await ApiClient.instance.get('/api/user/guidance-requests/my-requests');
      final list = (res.data['requests'] as List?) ?? [];
      setState(() => _requests = list.map((j) => RequestModel.fromJson(j)).toList());
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _delete(RequestModel req) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تأكيد الحذف',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w700), textAlign: TextAlign.right),
        content: Text('هل تريد حذف هذا الطلب؟',
            style: GoogleFonts.tajawal(), textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: GoogleFonts.tajawal(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiClient.instance.delete('/api/user/guidance-requests/my-requests/${req.id}');
      setState(() => _requests.remove(req));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف الطلب', style: GoogleFonts.tajawal()),
          backgroundColor: AppColors.statusResolved,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: FilledButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubmitRequestScreen()),
                );
                _load();
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text('جديد', style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.darkGreen))
          : _requests.isEmpty
              ? EmptyState(
                  icon: Icons.inbox_outlined,
                  message: 'لا توجد طلبات بعد',
                  subtitle: 'اضغط على "جديد" لإرسال طلب إرشاد',
                )
              : RefreshIndicator(
                  color: AppColors.darkGreen,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _RequestCard(req: _requests[i], onDelete: _delete, index: i),
                  ),
                ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestModel req;
  final Future<void> Function(RequestModel) onDelete;
  final int index;
  const _RequestCard({required this.req, required this.onDelete, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(radius: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (req.canDelete)
                      IconButton(
                        onPressed: () => onDelete(req),
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.error.withAlpha(15),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                  ],
                ),
                StatusBadge(status: req.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              req.title,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 6),
            Text(
              req.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.textLight, height: 1.5),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  req.createdAt != null
                      ? '${req.createdAt!.day}/${req.createdAt!.month}/${req.createdAt!.year}'
                      : '',
                  style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn()
        .slideX(begin: 0.1);
  }
}
