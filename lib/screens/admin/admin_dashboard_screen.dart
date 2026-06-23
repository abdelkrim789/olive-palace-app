import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final auth    = context.read<AuthProvider>();
    final isSa    = auth.isSuperAdmin;
    final endpoint = isSa ? '/api/super-admin/stats' : null;
    if (endpoint == null) {
      // Regular admin has no dedicated stats endpoint
      setState(() { _stats = {}; _loading = false; });
      return;
    }
    try {
      final res = await ApiClient.instance.get(endpoint);
      setState(() => _stats = res.data);
    } catch (e) {
      setState(() => _error = 'تعذر تحميل البيانات');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final isSa   = auth.isSuperAdmin;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.darkGreen,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.darkGreen,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(gradient: AppColors.headerGradient),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            isSa ? 'لوحة المدير العام' : 'لوحة المشرف',
                            style: GoogleFonts.tajawal(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'مرحباً، ${auth.user?.firstName ?? ''} 👋',
                            style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.lightGreen),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                title: Text(
                  isSa ? 'الإحصائيات' : 'لوحة التحكم',
                  style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.darkGreen)),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(_error!, style: GoogleFonts.tajawal(color: AppColors.textMuted)),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _load, child: Text('إعادة المحاولة', style: GoogleFonts.tajawal())),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (isSa) ..._buildSuperAdminContent() else ..._buildAdminContent(),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSuperAdminContent() {
    final s = _stats ?? {};
    // Backend shape: { request_stats: {pending,in_progress,resolved,closed},
    //                  total_users, total_admins, total_blogs,
    //                  visits: [int x30], recent_pending: [...] }
    final rs         = s['request_stats'] as Map? ?? {};
    final pending    = (rs['pending']     as num?)?.toInt() ?? 0;
    final inProgress = (rs['in_progress'] as num?)?.toInt() ?? 0;
    final resolved   = (rs['resolved']    as num?)?.toInt() ?? 0;
    final closed     = (rs['closed']      as num?)?.toInt() ?? 0;
    final totalReqs  = pending + inProgress + resolved + closed;

    final visitsList = s['visits'] as List? ?? [];
    final monthlyVisits = visitsList.fold<int>(0, (sum, v) => sum + ((v as num?)?.toInt() ?? 0));

    final recentPending = (s['recent_pending'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return [
      _SectionTitle('الطلبات'),
      const SizedBox(height: 12),
      _StatsGrid([
        _StatCard(label: 'إجمالي الطلبات',   value: '$totalReqs',   icon: Icons.inbox_rounded,                color: AppColors.primary),
        _StatCard(label: 'قيد الانتظار',      value: '$pending',     icon: Icons.hourglass_empty_rounded,      color: AppColors.statusPending),
        _StatCard(label: 'جارٍ المعالجة',     value: '$inProgress',  icon: Icons.sync_rounded,                 color: AppColors.statusProgress),
        _StatCard(label: 'تم الحل',            value: '$resolved',    icon: Icons.check_circle_outline_rounded, color: AppColors.statusResolved),
      ], index: 0),
      const SizedBox(height: 20),
      _SectionTitle('المستخدمون والمحتوى'),
      const SizedBox(height: 12),
      _StatsGrid([
        _StatCard(label: 'المستخدمون',          value: '${s['total_users']  ?? 0}', icon: Icons.people_rounded,               color: AppColors.primary),
        _StatCard(label: 'المشرفون',             value: '${s['total_admins'] ?? 0}', icon: Icons.admin_panel_settings_rounded,  color: AppColors.statusProgress),
        _StatCard(label: 'المقالات',             value: '${s['total_blogs']  ?? 0}', icon: Icons.article_rounded,               color: AppColors.peach),
        _StatCard(label: 'زيارات 30 يوم',       value: '$monthlyVisits',            icon: Icons.bar_chart_rounded,             color: AppColors.statusProgress),
      ], index: 1),
      if (recentPending.isNotEmpty) ...[
        const SizedBox(height: 20),
        _SectionTitle('أحدث الطلبات المعلقة'),
        const SizedBox(height: 12),
        ...recentPending.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _RecentRequestTile(e.value, e.key),
        )),
      ],
    ];
  }

  List<Widget> _buildAdminContent() {
    final s = _stats ?? {};
    final assigned  = s['my_requests'] as Map? ?? {};
    return [
      _SectionTitle('طلباتي المسندة'),
      const SizedBox(height: 12),
      _StatsGrid([
        _StatCard(label: 'إجمالي',        value: '${assigned['total']       ?? s['total']       ?? 0}', icon: Icons.inbox_rounded,               color: AppColors.primary),
        _StatCard(label: 'جارٍ المعالجة', value: '${assigned['in_progress'] ?? s['in_progress'] ?? 0}', icon: Icons.sync_rounded,                color: AppColors.statusProgress),
        _StatCard(label: 'تم الحل',        value: '${assigned['resolved']    ?? s['resolved']    ?? 0}', icon: Icons.check_circle_outline_rounded, color: AppColors.statusResolved),
        _StatCard(label: 'مغلقة',          value: '${assigned['closed']      ?? s['closed']      ?? 0}', icon: Icons.lock_outline_rounded,         color: AppColors.statusClosed),
      ], index: 0),
    ];
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkGreen),
        textAlign: TextAlign.right,
      );
}

class _StatsGrid extends StatelessWidget {
  final List<_StatCard> cards;
  final int index;
  final int crossAxis;
  const _StatsGrid(this.cards, {required this.index, this.crossAxis = 2});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxis,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: cards,
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn()
        .slideY(begin: 0.15);
  }
}

class _RecentRequestTile extends StatelessWidget {
  final Map<String, dynamic> req;
  final int index;
  const _RecentRequestTile(this.req, this.index);

  @override
  Widget build(BuildContext context) {
    final user = req['user'] as Map? ?? {};
    final firstName = user['first_name'] ?? '';
    final lastName  = user['last_name']  ?? '';
    final name = '$firstName $lastName'.trim();
    return Container(
      decoration: cardDecoration(radius: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.beige,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, color: AppColors.darkGreen),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name.isNotEmpty ? name : 'مستخدم',
              style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkGreen),
              textAlign: TextAlign.right,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.statusPending.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'معلق',
              style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.statusPending, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 60)).fadeIn(duration: 350.ms).slideX(begin: 0.1);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(radius: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: GoogleFonts.tajawal(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
