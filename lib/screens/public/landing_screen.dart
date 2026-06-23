import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/blog_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/leaf_particles.dart';
import '../../widgets/olive_orb.dart';
import '../../widgets/tilt_card_3d.dart';
import '../auth/google_auth_screen.dart' show launchGoogleAuth;
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../user/blog_detail_screen.dart';
import 'faq_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scroll = ScrollController();
  List<BlogModel> _blogs = [];
  bool _blogsLoading = true;

  // Team data
  static const _team = [
    {'name': 'نور الهدى', 'role': 'خبيرة الزيتون', 'img': 'assets/images/team/nour.jpg'},
    {'name': 'سعد أحمد',  'role': 'مهندس زراعي',   'img': 'assets/images/team/saad.jpg'},
    {'name': 'الصغيري',   'role': 'مستشار زراعي',  'img': 'assets/images/team/sghiri.jpg'},
    {'name': 'برازة',     'role': 'خبير زيتون',    'img': 'assets/images/team/braza.jpg'},
  ];

  static const _devTeam = [
    {'name': 'عبد الرحمن', 'role': 'Full-Stack Developer', 'img': 'assets/images/dev_team/abdelrahmen.jpg'},
    {'name': 'إسلام',      'role': 'Mobile Developer',      'img': 'assets/images/dev_team/islam.jpg'},
    {'name': 'كريم',       'role': 'Backend Developer',     'img': 'assets/images/dev_team/karim.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadBlogs() async {
    try {
      final res  = await ApiClient.instance.get('/api/blogsList');
      final list = (res.data['blogs'] as List?) ?? [];
      if (mounted) setState(() => _blogs = list.map((j) => BlogModel.fromJson(j)).toList().take(4).toList());
    } catch (_) {}
    if (mounted) setState(() => _blogsLoading = false);
  }

  void _goLogin()    => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  void _goRegister() => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));

  Future<void> _googleLogin() async {
    final result = await launchGoogleAuth(context);
    if (!mounted || result == null) return;
    await context.read<AuthProvider>().loginWithGoogle(result['token']!, result['user_type']!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          // ── Hero ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _HeroSection(onLogin: _goLogin, onRegister: _goRegister, onGoogle: _googleLogin)),
          // ── Features ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _FeaturesSection()),
          // ── Latest Articles ───────────────────────────────────────────────
          SliverToBoxAdapter(child: _BlogsSection(blogs: _blogs, loading: _blogsLoading)),
          // ── FAQ teaser ────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _FaqTeaser()),
          // ── Our Team ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _TeamSection(title: 'فريق الخبراء', members: _team)),
          // ── Dev Team ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _TeamSection(title: 'فريق التطوير', members: _devTeam, accent: AppColors.peach)),
          // ── CTA footer ────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _CtaFooter(onLogin: _goLogin, onRegister: _goRegister)),
        ],
      ),
    );
  }
}

// ── HERO ─────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final VoidCallback onLogin, onRegister, onGoogle;
  const _HeroSection({required this.onLogin, required this.onRegister, required this.onGoogle});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return LeafParticles(
      child: Container(
        height: h,
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: onLogin,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.beige,
                        side: const BorderSide(color: AppColors.lightGreen, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      ),
                      child: Text('دخول', style: GoogleFonts.tajawal(fontWeight: FontWeight.w600)),
                    ),
                    Image.asset('assets/images/logo.png', height: 44, color: Colors.white)
                        .animate().fadeIn(duration: 600.ms),
                  ],
                ),
              ),

              const Spacer(),

              // Olive orb
              const OliveOrb(size: 200)
                  .animate().scale(duration: 900.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 36),

              // Tagline
              Text(
                'Olive Palace',
                style: GoogleFonts.tajawal(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

              const SizedBox(height: 8),

              Text(
                'منصة إرشاد زراعة الزيتون',
                style: GoogleFonts.tajawal(fontSize: 16, color: AppColors.lightGreen, fontWeight: FontWeight.w500),
              ).animate().fadeIn(delay: 450.ms),

              const SizedBox(height: 10),

              Text(
                'علم • خبرة • طبيعة',
                style: GoogleFonts.tajawal(fontSize: 13, color: Colors.white.withAlpha(100), letterSpacing: 3),
              ).animate().fadeIn(delay: 550.ms),

              const SizedBox(height: 40),

              // CTA buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          foregroundColor: AppColors.darkGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text('انضم إلينا', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                    ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.3),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onGoogle,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('G', style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF4285F4))),
                            const SizedBox(width: 10),
                            Text('الدخول بـ Google', style: GoogleFonts.tajawal(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 720.ms),
                  ],
                ),
              ),

              const Spacer(),

              // Scroll indicator
              Column(
                children: [
                  Text('اكتشف المزيد', style: GoogleFonts.tajawal(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 6),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38, size: 28),
                ],
              ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: 8, duration: 900.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FEATURES ─────────────────────────────────────────────────────────────────
class _FeaturesSection extends StatelessWidget {
  static const _items = [
    {'icon': Icons.eco_rounded,         'title': 'إرشاد زراعي',   'sub': 'خبراء متخصصون في زراعة الزيتون'},
    {'icon': Icons.menu_book_rounded,   'title': 'مقالات علمية',  'sub': 'محتوى زراعي موثوق ومحدّث'},
    {'icon': Icons.question_answer_rounded, 'title': 'أسئلة شائعة', 'sub': 'إجابات لأبرز استفساراتك'},
  ];

  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        children: [
          _SectionLabel(text: 'لماذا Olive Palace؟'),
          const SizedBox(height: 28),
          Row(
            children: [
              for (int i = 0; i < _items.length; i++)
                Expanded(
                  child: _FeatureCard(
                    icon: _items[i]['icon'] as IconData,
                    title: _items[i]['title'] as String,
                    sub: _items[i]['sub'] as String,
                  ).animate(delay: Duration(milliseconds: i * 120))
                   .fadeIn(duration: 500.ms)
                   .slideY(begin: 0.3),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  const _FeatureCard({required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.darkGreen, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title,
            style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkGreen),
            textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(sub,
            style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.textMuted),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── BLOGS ─────────────────────────────────────────────────────────────────────
class _BlogsSection extends StatelessWidget {
  final List<BlogModel> blogs;
  final bool loading;
  const _BlogsSection({required this.blogs, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SectionLabel(text: 'أحدث المقالات'),
          ),
          const SizedBox(height: 20),
          if (loading)
            const Center(child: CircularProgressIndicator(color: AppColors.darkGreen))
          else if (blogs.isEmpty)
            Center(child: Text('لا توجد مقالات حالياً', style: GoogleFonts.tajawal(color: AppColors.textMuted)))
          else
            SizedBox(
              height: 260,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: blogs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, i) =>
                    _BlogMiniCard(blog: blogs[i], index: i),
              ),
            ),
        ],
      ),
    );
  }
}

class _BlogMiniCard extends StatelessWidget {
  final BlogModel blog;
  final int index;
  const _BlogMiniCard({required this.blog, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlogDetailScreen(blog: blog))),
      child: TiltCard3D(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: AppColors.darkGreen.withAlpha(15), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: blog.imageUrl.isNotEmpty
                    ? CachedNetworkImage(imageUrl: blog.imageUrl, height: 130, width: double.infinity, fit: BoxFit.cover,
                        errorWidget: (_, _, _) => _PlaceholderImg(height: 130))
                    : _PlaceholderImg(height: 130),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(blog.title,
                      style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkGreen),
                      maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right),
                    const SizedBox(height: 6),
                    Text(blog.excerpt,
                      style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.textMuted),
                      maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate(delay: Duration(milliseconds: index * 100)).fadeIn(duration: 400.ms).slideX(begin: 0.2),
    );
  }
}

class _PlaceholderImg extends StatelessWidget {
  final double height;
  const _PlaceholderImg({required this.height});
  @override
  Widget build(BuildContext context) => Container(
    height: height, color: AppColors.beige,
    child: const Center(child: Icon(Icons.eco_rounded, size: 36, color: AppColors.lightGreen)));
}

// ── FAQ TEASER ────────────────────────────────────────────────────────────────
class _FaqTeaser extends StatelessWidget {
  const _FaqTeaser();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E3A2E), Color(0xFF4A5E4A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.darkGreen.withAlpha(60), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightGreen,
              foregroundColor: AppColors.darkGreen,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('استعرضها', style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('الأسئلة الشائعة', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 4),
              Text('كل ما يخص زراعة الزيتون', style: GoogleFonts.tajawal(fontSize: 13, color: AppColors.lightGreen)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2);
  }
}

// ── TEAM ─────────────────────────────────────────────────────────────────────
class _TeamSection extends StatelessWidget {
  final String title;
  final List<Map<String, String>> members;
  final Color? accent;
  const _TeamSection({required this.title, required this.members, this.accent});

  @override
  Widget build(BuildContext context) {
    final bg = accent == null ? AppColors.surface : AppColors.background;
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SectionLabel(text: title, accent: accent),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: members.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, i) => _TeamMemberCard(member: members[i], index: i),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final Map<String, String> member;
  final int index;
  const _TeamMemberCard({required this.member, required this.index});

  @override
  Widget build(BuildContext context) {
    return TiltCard3D(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.darkGreen.withAlpha(20), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(
                member['img']!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 140,
                  color: AppColors.beige,
                  child: const Icon(Icons.person_rounded, size: 48, color: AppColors.lightGreen),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(member['name']!,
                      style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkGreen),
                      textAlign: TextAlign.center),
                    const SizedBox(height: 2),
                    Text(member['role']!,
                      style: GoogleFonts.tajawal(fontSize: 11, color: AppColors.textMuted),
                      textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 100)).fadeIn(duration: 400.ms).slideX(begin: 0.3);
  }
}

// ── CTA FOOTER ────────────────────────────────────────────────────────────────
class _CtaFooter extends StatelessWidget {
  final VoidCallback onLogin, onRegister;
  const _CtaFooter({required this.onLogin, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 28),
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Column(
        children: [
          Image.asset('assets/images/logo.png', height: 70, color: Colors.white.withAlpha(220)),
          const SizedBox(height: 20),
          Text('ابدأ رحلتك مع Olive Palace',
            style: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('انضم إلى مجتمع زراعة الزيتون وتواصل مع أفضل الخبراء',
            style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.lightGreen),
            textAlign: TextAlign.center),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGreen,
                    foregroundColor: AppColors.darkGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text('إنشاء حساب', style: GoogleFonts.tajawal(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onLogin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('تسجيل الدخول', style: GoogleFonts.tajawal(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('© 2025 Olive Palace · جميع الحقوق محفوظة',
            style: GoogleFonts.tajawal(fontSize: 11, color: Colors.white24)),
        ],
      ),
    );
  }
}

// ── SHARED ────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final Color? accent;
  const _SectionLabel({required this.text, this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(text,
          style: GoogleFonts.tajawal(
            fontSize: 22, fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 4, height: 24,
          decoration: BoxDecoration(
            color: accent ?? AppColors.darkGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
