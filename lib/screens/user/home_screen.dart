import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/blog_model.dart';
import '../../providers/auth_provider.dart';
import 'blog_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BlogModel> _blogs   = [];
  bool _loading            = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res  = await ApiClient.instance.get('/api/blogsList');
      final list = (res.data['blogs'] as List?) ?? [];
      setState(() => _blogs = list.map((j) => BlogModel.fromJson(j)).toList());
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.darkGreen,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            // ── Collapsing header ──────────────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.darkGreen,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Container(
                  decoration: const BoxDecoration(gradient: AppColors.headerGradient),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(20),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.eco_rounded, color: AppColors.beige, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Olive Palace',
                                      style: GoogleFonts.tajawal(
                                        color: AppColors.beige,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'مرحباً، ${user?.firstName ?? 'بك'} 👋',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'اكتشف مقالات الزيتون',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 13,
                                      color: AppColors.lightGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'المقالات',
                  style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            // ── Blog list ──────────────────────────────────────────────
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.darkGreen)),
              )
            else if (_blogs.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'لا توجد مقالات بعد',
                    style: GoogleFonts.tajawal(color: AppColors.textMuted, fontSize: 16),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.separated(
                  itemCount: _blogs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) =>
                      _BlogCard(blog: _blogs[i], index: i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  final BlogModel blog;
  final int index;
  const _BlogCard({required this.blog, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BlogDetailScreen(blog: blog)),
      ),
      child: Container(
        decoration: cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: blog.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: blog.imageUrl,
                      height: 190,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        height: 190,
                        color: AppColors.beige,
                        child: const Icon(Icons.image_outlined, size: 50, color: AppColors.lightGreen),
                      ),
                      errorWidget: (_, _, _) => Container(
                        height: 190,
                        color: AppColors.beige,
                        child: const Icon(Icons.eco_rounded, size: 50, color: AppColors.lightGreen),
                      ),
                    )
                  : Container(
                      height: 190,
                      color: AppColors.beige,
                      child: const Icon(Icons.eco_rounded, size: 60, color: AppColors.lightGreen),
                    ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (blog.categoryName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.beige,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        blog.categoryName!,
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    blog.title,
                    style: GoogleFonts.tajawal(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    blog.excerpt,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: AppColors.textLight,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.darkGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'اقرأ المزيد',
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (blog.createdAt != null)
                        Text(
                          '${blog.createdAt!.day}/${blog.createdAt!.month}/${blog.createdAt!.year}',
                          style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: index * 80))
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.2),
    );
  }
}
