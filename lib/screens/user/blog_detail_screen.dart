import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/blog_model.dart';

class BlogDetailScreen extends StatelessWidget {
  final BlogModel blog;
  const BlogDetailScreen({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.darkGreen,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (blog.imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: blog.imageUrl,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: AppColors.beige,
                      child: const Icon(Icons.eco_rounded, size: 80, color: AppColors.lightGreen),
                    ),
                  // gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.darkGreen.withAlpha(200),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  // Category badge at bottom
                  if (blog.categoryName != null)
                    Positioned(
                      bottom: 16,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          blog.categoryName!,
                          style: GoogleFonts.tajawal(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Date
                  if (blog.createdAt != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${blog.createdAt!.day}/${blog.createdAt!.month}/${blog.createdAt!.year}',
                          style: GoogleFonts.tajawal(fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                      ],
                    ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    blog.title,
                    style: GoogleFonts.tajawal(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 20),

                  // Divider with leaf
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.eco_rounded, color: AppColors.lightGreen, size: 18),
                      ),
                      Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Body
                  Text(
                    blog.content,
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      color: AppColors.text,
                      height: 1.9,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
