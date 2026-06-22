import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _roleLabels = {
    'web':         'مستخدم',
    'admin':       'مشرف',
    'super_admin': 'مدير عام',
  };

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthProvider>();
    final user     = auth.user;
    final roleName = _roleLabels[auth.userType] ?? auth.userType ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.darkGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.headerGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white.withAlpha(25),
                        child: Text(
                          user?.initials ?? '؟',
                          style: GoogleFonts.tajawal(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.fullName ?? '',
                        style: GoogleFonts.tajawal(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withAlpha(40)),
                        ),
                        child: Text(
                          roleName,
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            color: AppColors.beige,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: Text('حسابي', style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),

          // Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Info card
                  Container(
                    decoration: cardDecoration(),
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: [
                        _InfoTile(icon: Icons.person_rounded,   label: 'الاسم الأول',         value: user?.firstName),
                        _InfoTile(icon: Icons.person_outline,   label: 'اسم العائلة',          value: user?.lastName),
                        _InfoTile(icon: Icons.mail_outline_rounded, label: 'البريد الإلكتروني', value: user?.email),
                        if (user?.phone != null)
                          _InfoTile(icon: Icons.phone_outlined, label: 'الهاتف', value: user?.phone),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logout
                  Container(
                    decoration: cardDecoration(),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                      ),
                      title: Text(
                        'تسجيل الخروج',
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      onTap: () => _confirmLogout(context, auth),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Olive Palace v1.0.0',
                    style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Icon(Icons.logout_rounded, color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            Text('تسجيل الخروج', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('هل تريد تسجيل الخروج من حسابك؟', style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.textMuted)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.textLight)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    onPressed: () {
                      Navigator.pop(context);
                      auth.logout();
                    },
                    child: Text('خروج', style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  const _InfoTile({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.beige,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.darkGreen, size: 18),
      ),
      title: Text(label, style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.textMuted), textAlign: TextAlign.right),
      subtitle: Text(
        value ?? '—',
        style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.text),
        textAlign: TextAlign.right,
      ),
    );
  }
}
