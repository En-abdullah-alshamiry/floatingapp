import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  GoogleSignIn get _googleSignIn => GoogleSignIn();
  FacebookAuth get _facebookAuth => FacebookAuth.instance;
  LocalAuthentication get _localAuth => LocalAuthentication();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> get isAuthenticated async {
    try {
      final user = _auth.currentUser;
      return user != null && user.emailVerified;
    } catch (e) {
      return false;
    }
  }

  UserModel? get currentUser {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        return UserModel.fromFirebase(user);
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return null;
      }

      // حفظ الاسم في Firebase Authentication
      await firebaseUser.updateDisplayName(name.trim());

      // إنشاء بيانات المستخدم في Firestore
      final userData = {
        'id': firebaseUser.uid,
        'email': firebaseUser.email ?? email.trim(),
        'displayName': name.trim(),
        'photoURL': null,
        'phoneNumber': phoneNumber?.trim().isEmpty == true
            ? null
            : phoneNumber?.trim(),
        'isEmailVerified': firebaseUser.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userData);

      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? email.trim(),
        displayName: name.trim(),
        photoURL: null,
        isEmailVerified: firebaseUser.emailVerified,
        phoneNumber: phoneNumber?.trim().isEmpty == true
            ? null
            : phoneNumber?.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print('Register FirebaseAuth error: ${e.code}');
      print('Message: ${e.message}');
      return null;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        return null;
      }

      // تحديث بيانات التحقق
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': user.email ?? email.trim(),
        'displayName': user.displayName,
        'isEmailVerified': user.emailVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return await getUserProfile();
    } on FirebaseAuthException catch (e) {
      print('Firebase Login Error: ${e.code}');
      print('Firebase Login Message: ${e.message}');
      return null;
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  // ============================================================
  // GET USER PROFILE
  // ============================================================

  Future<UserModel?> getUserProfile() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return null;
      }

      final document =
      await _firestore.collection('users').doc(user.uid).get();

      if (document.exists && document.data() != null) {
        return UserModel.fromMap(document.data()!);
      }

      return UserModel.fromFirebase(user);
    } catch (e) {
      print('Get Profile Error: $e');
      return currentUser;
    }
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<UserModel?> updateProfile({
    required String name,
    String? phoneNumber,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return null;
      }

      // تحديث الاسم في Firebase Authentication
      await user.updateDisplayName(name.trim());

      // تحديث البيانات في Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': user.email,
        'displayName': name.trim(),
        'phoneNumber': phoneNumber?.trim(),
        'isEmailVerified': user.emailVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.reload();

      return await getUserProfile();
    } catch (e) {
      print('Update Profile Error: $e');
      return null;
    }
  }

  // ============================================================
  // UPDATE PROFILE IMAGE (جديدة - تحفظ المسار المحلي في Firestore)
  // ============================================================

  Future<void> updateProfileImage(String imagePath) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return;
      }

      // تحديث Firestore بالمسار المحلي
      await _firestore.collection('users').doc(user.uid).set({
        'photoURL': imagePath,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Update Profile Image Error: $e');
    }
  }

  // ============================================================
  // UPLOAD PROFILE IMAGE (معدلة - تحفظ محلياً بدلاً من Firebase Storage)
  // ============================================================

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return null;
      }

      // الحصول على مجلد التطبيق الخاص
      final directory = await getApplicationDocumentsDirectory();

      // إنشاء اسم فريد للصورة
      final fileName = 'profile_${user.uid}${p.extension(imageFile.path)}';
      final savedImage = File('${directory.path}/$fileName');

      // حذف الصورة القديمة إذا وجدت
      if (await savedImage.exists()) {
        await savedImage.delete();
      }

      // نسخ الصورة المختارة إلى مجلد التطبيق
      await imageFile.copy(savedImage.path);

      // تحديث Firestore بالمسار المحلي
      await _firestore.collection('users').doc(user.uid).set({
        'photoURL': savedImage.path,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return savedImage.path;
    } catch (e) {
      print('Upload Profile Image Error: $e');
      return null;
    }
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<UserModel?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
      await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        return null;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        return null;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'phoneNumber': user.phoneNumber,
        'isEmailVerified': user.emailVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return await getUserProfile();
    } catch (e) {
      print('Google Login Error: $e');
      return null;
    }
  }

  // ============================================================
  // FACEBOOK LOGIN
  // ============================================================

  Future<UserModel?> loginWithFacebook() async {
    try {
      final LoginResult loginResult = await _facebookAuth.login();

      if (loginResult.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(
          loginResult.accessToken!.tokenString,
        );

        final UserCredential userCredential =
        await _auth.signInWithCredential(
          facebookAuthCredential,
        );

        final user = userCredential.user;

        if (user == null) {
          return null;
        }

        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'phoneNumber': user.phoneNumber,
          'isEmailVerified': user.emailVerified,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return await getUserProfile();
      }

      return null;
    } catch (e) {
      print('Facebook Login Error: $e');
      return null;
    }
  }

  // ============================================================
  // BIOMETRIC LOGIN
  // ============================================================

  Future<bool> loginWithBiometric() async {
    try {
      final bool canCheckBiometrics =
      await _localAuth.canCheckBiometrics;

      final bool isDeviceSupported =
      await _localAuth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Authenticate to access the app',
          options: const AuthenticationOptions(
            biometricOnly: true,
          ),
        );

        if (didAuthenticate) {
          return _auth.currentUser != null;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _facebookAuth.logOut();
    } catch (e) {
      // Ignore errors
    }
  }

  // ============================================================
  // EMAIL VERIFICATION
  // ============================================================

  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      print('Verification Error: $e');
    }
  }

  // ============================================================
  // PASSWORD RESET
  // ============================================================

  Future<void> passwordReset({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } catch (e) {
      print('Password Reset Error: $e');
    }
  }
}