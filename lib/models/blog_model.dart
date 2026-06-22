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

  String get imageUrl =>
      image != null ? 'http://api.olivepalace.net/storage/$image' : '';

  String get excerpt =>
      content.length > 120 ? '${content.substring(0, 120)}...' : content;

  factory BlogModel.fromJson(Map<String, dynamic> j) => BlogModel(
        id: j['id'] ?? 0,
        title: j['title'] ?? '',
        content: j['content'] ?? '',
        image: j['image'],
        categoryName: j['category']?['name'],
        categoryId: j['category_id'],
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'])
            : null,
      );
}
