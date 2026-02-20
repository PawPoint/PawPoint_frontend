import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Updated signUp to save extra profile info
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      // 1. Create the user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Save the extra details to Cloud Firestore using the same UID
      if (result.user != null) {
        await _firestore.collection('Users').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return result.user;
    } catch (e) {
      debugPrint("Error during signup: $e");
      return null;
    }
  }

  // Login function
  Future<User?> logIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      debugPrint(
        "Error during signup: $e",
      ); // Use debugPrint instead of print      
      return null;
    }
  }

  // Logout function
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
