import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.beige,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: AppColors.lightGreen),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: GoogleFonts.tajawal(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
