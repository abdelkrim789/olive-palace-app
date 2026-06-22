import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/request_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'admin_request_detail_screen.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});
  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  List<RequestModel> _all      = [];
  List<RequestModel> _filtered = [];
  bool _loading                = true;
  String _statusFilter         = 'all';
  final _searchCtrl            = TextEditingController();

  static const _statusOptions = {
    'all':         'الكل',
    'pending':     'قيد الانتظار',
    'in_progress': 'جارٍ المعالجة',
    'resolved':    'تم الحل',
    'closed':      'مغلق',
  };

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_filter);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_filter);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final auth     = context.read<AuthProvider>();
    if (!auth.isSuperAdmin) {
      setState(() { _all = []; _loading = false; });
      _filter();
      return;
    }
    const endpoint = '/api/super-admin/guidence-requests/requests';
    try {
      final res  = await ApiClient.instance.get(endpoint);
      final list = (res.data['requests'] as List?) ?? [];
      _all = list.map((j) => RequestModel.fromJson(j)).toList();
    } catch (_) {}
    _filter();
    setState(() => _loading = false);
  }

  void _filter() {
    setState(() {
      _filtered = _all.where((r) {
        final matchStatus = _statusFilter == 'all' || r.status == _statusFilter;
        final q           = _searchCtrl.text.trim().toLowerCase();
        final matchSearch = q.isEmpty ||
            r.title.toLowerCase().contains(q) ||
            (r.user?.fullName.toLowerCase().contains(q) ?? false);
        return matchStatus && matchSearch;
      }).toList();
    });
  }

  void _setFilter(String s) {
    _statusFilter = s;
    _filter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبات'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchCtrl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'بحث عن طلب أو مستخدم...',
                    hintStyle: GoogleFonts.tajawal(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.lightGreen),
                    filled: true,
                    fillColor: AppColors.beige,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // Status filter chips
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: _statusOptions.entries.map((e) {
                    final selected = _statusFilter == e.key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 6),
                      child: FilterChip(
                        selected: selected,
                        label: Text(e.value, style: GoogleFonts.tajawal(fontSize: 13)),
                        onSelected: (_) => _setFilter(e.key),
                        selectedColor: AppColors.darkGreen,
                        checkmarkColor: Colors.white,
                        labelStyle: GoogleFonts.tajawal(
                          color: selected ? Colors.white : AppColors.textLight,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color: selected ? AppColors.darkGreen : AppColors.border,
                        ),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.darkGreen))
          : _filtered.isEmpty
              ? EmptyState(
                  icon: Icons.inbox_outlined,
                  message: 'لا توجد طلبات',
                  subtitle: 'لا توجد نتائج للفلتر الحالي',
                )
              : RefreshIndicator(
                  color: AppColors.darkGreen,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _AdminRequestCard(
                      req: _filtered[i],
                      index: i,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminRequestDetailScreen(req: _filtered[i]),
                          ),
                        );
                        _load();
                      },
                    ),
                  ),
                ),
    );
  }
}

class _AdminRequestCard extends StatelessWidget {
  final RequestModel req;
  final int index;
  final VoidCallback onTap;
  const _AdminRequestCard({required this.req, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: cardDecoration(radius: 16),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: req.status),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      req.title,
                      style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkGreen),
                      textAlign: TextAlign.right,
                    ),
                    if (req.user != null)
                      Text(
                        req.user!.fullName,
                        style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              req.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(fontSize: 13, color: AppColors.textLight, height: 1.5),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_back_ios_rounded, size: 14, color: AppColors.textMuted),
                    Text('تفاصيل', style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                if (req.createdAt != null)
                  Text(
                    '${req.createdAt!.day}/${req.createdAt!.month}/${req.createdAt!.year}',
                    style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.textMuted),
                  ),
              ],
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: index * 50))
          .fadeIn()
          .slideX(begin: 0.08),
    );
  }
}
