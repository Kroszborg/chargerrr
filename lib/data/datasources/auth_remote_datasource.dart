import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String email, String password, String fullName, String? phoneNumber);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel?> getCurrentUser();
  Future<bool> isUserSignedIn();
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> updateUserProfile({String? fullName, String? phoneNumber, String? profileImageUrl});
  Future<void> deleteAccount();
  Future<void> sendEmailVerification();
  Future<void> reloadUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Sign in failed');
      }

      return await _getUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String fullName,
    String? phoneNumber,
  ) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Sign up failed');
      }

      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: credential.user!.emailVerified,
        isActive: true,
        favoriteStations: [],
      );

      await _saveUserToFirestore(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(message: 'Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      return await _getUserFromFirestore(user.uid);
    } catch (e) {
      throw AuthException(message: 'Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<bool> isUserSignedIn() async {
    return firebaseAuth.currentUser != null;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        return await _getUserFromFirestore(user.uid);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<UserModel> updateUserProfile({
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No user signed in');
      }

      final currentUserData = await _getUserFromFirestore(user.uid);
      final updatedUser = currentUserData.copyWith(
        fullName: fullName ?? currentUserData.fullName,
        phoneNumber: phoneNumber ?? currentUserData.phoneNumber,
        profileImageUrl: profileImageUrl ?? currentUserData.profileImageUrl,
        updatedAt: DateTime.now(),
      );

      await _saveUserToFirestore(updatedUser);
      return updatedUser;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No user signed in');
      }

      await firestore.collection('users').doc(user.uid).delete();
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: 'Failed to delete account: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No user signed in');
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No user signed in');
      }

      await user.reload();
    } catch (e) {
      throw AuthException(message: 'Failed to reload user: ${e.toString()}');
    }
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw const AuthException(message: 'User data not found');
      }
      return UserModel.fromFirestore(doc);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Failed to get user data: ${e.toString()}');
    }
  }

  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      throw AuthException(message: 'Failed to save user data: ${e.toString()}');
    }
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Invalid password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'requires-recent-login':
        return 'Please sign in again to continue';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}