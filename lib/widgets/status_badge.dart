import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  static const _config = {
    'pending':     {'label': 'قيد الانتظار', 'bg': Color(0xFFFFF3E0), 'color': AppColors.statusPending},
    'in_progress': {'label': 'جارٍ المعالجة','bg': Color(0xFFE3F2FD), 'color': AppColors.statusProgress},
    'resolved':    {'label': 'تم الحل',      'bg': Color(0xFFE8F5E9), 'color': AppColors.statusResolved},
    'closed':      {'label': 'مغلق',         'bg': Color(0xFFF5F5F5), 'color': AppColors.statusClosed},
  };

  @override
  Widget build(BuildContext context) {
    final cfg = _config[status];
    final label = (cfg?['label'] as String?) ?? status;
    final bg    = (cfg?['bg']    as Color?)  ?? AppColors.border;
    final color = (cfg?['color'] as Color?)  ?? AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
