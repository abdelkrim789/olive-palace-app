import 'dart:convert';

class BlogModel {
  final int id;
  final String title;
  final String content;
  final String? image;
  final String? categoryName;
  final int? categoryId;
  final DateTime? createdAt;

  BlogModel({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    this.categoryName,
    this.categoryId,
    this.createdAt,
  });

  // Backend stores images as JSON array string: '["/storage/blogs/1/image0.jpg"]'
  static String? _parseFirstImage(dynamic raw) {
    if (raw == null) return null;
    try {
      final list = raw is List ? raw : (jsonDecode(raw.toString()) as List);
      return list.isNotEmpty ? list.first.toString() : null;
    } catch (_) {
      return null;
    }
  }

  // Path already starts with /storage/ so just prepend the base URL
  String get imageUrl => image != null ? 'https://api.olivepalace.net$image' : '';

  // Strip HTML tags for plain-text excerpt
  String get excerpt {
    final stripped = content
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return stripped.length > 120 ? '${stripped.substring(0, 120)}...' : stripped;
  }

  factory BlogModel.fromJson(Map<String, dynamic> j) => BlogModel(
        id: j['id'] ?? 0,
        title: j['title'] ?? '',
        content: j['content'] ?? '',
        image: _parseFirstImage(j['images']),
        categoryName: j['category']?['name'],
        categoryId: j['category_id'],
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'])
            : null,
      );
}
