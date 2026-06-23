import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});
  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  List<Map<String, dynamic>> _questions = [];
  bool _loading = true;
  int? _expanded;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.get('/api/Questions');
      final raw = res.data;
      List list = [];
      if (raw is List) list = raw;
      else if (raw is Map) list = (raw['questions'] ?? raw['data'] ?? []) as List;
      if (mounted) setState(() => _questions = list.map((e) => Map<String, dynamic>.from(e as Map)).toList());
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.darkGreen,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(right: 20, bottom: 16),
              title: Text('الأسئلة الشائعة',
                style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.headerGradient),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.question_answer_rounded, size: 36, color: AppColors.lightGreen),
                      ),
                      const SizedBox(height: 10),
                      Text('كل ما تودّ معرفته',
                        style: GoogleFonts.tajawal(fontSize: 13, color: AppColors.lightGreen)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.darkGreen)),
            )
          else if (_questions.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox_rounded, size: 60, color: AppColors.lightGreen),
                    const SizedBox(height: 12),
                    Text('لا توجد أسئلة حالياً',
                      style: GoogleFonts.tajawal(color: AppColors.textMuted, fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.separated(
                itemCount: _questions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final q = _questions[i];
                  final isOpen = _expanded == i;
                  final question = q['question'] ?? q['title'] ?? '';
                  final answer   = q['answer']   ?? q['content'] ?? '';
                  return _FaqItem(
                    index: i,
                    question: question.toString(),
                    answer: answer.toString(),
                    isOpen: isOpen,
                    onTap: () => setState(() => _expanded = isOpen ? null : i),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final int index;
  final String question, answer;
  final bool isOpen;
  final VoidCallback onTap;
  const _FaqItem({required this.index, required this.question, required this.answer, required this.isOpen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isOpen ? AppColors.darkGreen : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGreen.withAlpha(isOpen ? 40 : 12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isOpen ? AppColors.lightGreen.withAlpha(80) : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: isOpen ? 0.25 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: isOpen ? AppColors.lightGreen : AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      question,
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isOpen ? Colors.white : AppColors.darkGreen,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: isOpen ? AppColors.lightGreen.withAlpha(40) : AppColors.beige,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isOpen ? AppColors.lightGreen : AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 18, right: 18, bottom: 18),
                child: Text(
                  answer,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    color: Colors.white.withAlpha(200),
                    height: 1.7,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 60)).fadeIn(duration: 400.ms).slideY(begin: 0.15);
  }
}
