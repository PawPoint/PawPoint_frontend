import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String confirmPassword,
  }) async {
    try {
      // 1. Create the user account in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        // 2. Save the extra data (Name, Phone, Address) to Firestore Database
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'phone': phone,
          'address': address,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return user;
      }
    } catch (e) {
      // 3. IMPORTANT: Re-throw the error so your UI's catch block can read it!
      rethrow;
    }
    return null;
  }
}
