import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;
  final String? phoneNumber;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.isEmailVerified,
    this.phoneNumber,
  });

  // ============================================================
  // إنشاء UserModel من Firebase Authentication
  // ============================================================

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
      isEmailVerified: user.emailVerified,
      phoneNumber: user.phoneNumber,
    );
  }

  // ============================================================
  // UserModel فارغ
  // ============================================================

  const UserModel.empty()
      : id = '',
        email = '',
        displayName = '',
        photoURL = '',
        isEmailVerified = false,
        phoneNumber = '';

  // ============================================================
  // تحويل UserModel إلى Map
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isEmailVerified': isEmailVerified,
      'phoneNumber': phoneNumber,
    };
  }

  // ============================================================
  // إنشاء UserModel من Map
  // ============================================================

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      displayName: map['displayName']?.toString(),
      photoURL: map['photoURL']?.toString(),
      isEmailVerified: map['isEmailVerified'] == true,
      phoneNumber: map['phoneNumber']?.toString(),
    );
  }

  @override
  String toString() {
    return 'UserModel{id: $id, email: $email, '
        'isEmailVerified: $isEmailVerified}';
  }
}