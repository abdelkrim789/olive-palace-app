class RequestModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final String? adminNotes;
  final UserRef? user;
  final DateTime? createdAt;

  RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.adminNotes,
    this.user,
    this.createdAt,
  });

  bool get isPending    => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved   => status == 'resolved';
  bool get isClosed     => status == 'closed';
  bool get canDelete    => isPending;
  bool get canModify    => isPending || isInProgress;

  factory RequestModel.fromJson(Map<String, dynamic> j) => RequestModel(
        id: j['id'] ?? 0,
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        status: j['status'] ?? 'pending',
        adminNotes: j['admin_notes'],
        user: j['user'] != null ? UserRef.fromJson(j['user']) : null,
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'])
            : null,
      );
}

class UserRef {
  final int id;
  final String firstName;
  final String lastName;
  final String? profilePicture;

  UserRef({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  String get fullName => '$firstName $lastName';

  factory UserRef.fromJson(Map<String, dynamic> j) => UserRef(
        id: j['id'] ?? 0,
        firstName: j['first_name'] ?? '',
        lastName: j['last_name'] ?? '',
        profilePicture: j['profile_picture'],
      );
}
