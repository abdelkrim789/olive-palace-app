class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? profilePicture;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.profilePicture,
  });

  String get fullName => '$firstName $lastName';
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] ?? 0,
        firstName: j['first_name'] ?? '',
        lastName: j['last_name'] ?? '',
        email: j['email'],
        phone: j['phone'],
        profilePicture: j['profile_picture'],
      );
}
