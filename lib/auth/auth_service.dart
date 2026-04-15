import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── LOGIN DIRECTLY WITH FIREBASE ───────────────────────────────────────
  Future<User?> login({required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseErrorMessage(e));
    }
  }

  // ─── SIGNUP DIRECTLY WITH FIREBASE & CREATE FIRESTORE DOCUMENT ────────
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String confirmPassword,
  }) async {
    try {
      // 1. Create the account in Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // 2. Automatically save the extra info to your Firestore 'users' collection
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'phone': phone,
          'address': address,
          'photoUrl': '', 
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(), 
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseErrorMessage(e));
    }
  }

  // ─── HELPER: LOGOUT ───────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── HELPER: CLEAN ERROR MESSAGES ──────────────────────────────────────
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}