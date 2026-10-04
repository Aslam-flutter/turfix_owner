class AuthModel {
  String uid;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String? photoUrl;
  final String role;
  final int? isAccepted;

  AuthModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.isAccepted,
    this.photoUrl,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'] ?? '',
      photoUrl: json['photoUrl'],
      role: 'owner',
      isAccepted: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role,
      'isAccepted': isAccepted,
    };
  }
}
