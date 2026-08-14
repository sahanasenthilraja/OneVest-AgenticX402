import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================
  // SIGN UP
  // ==========================
  Future<String?> signUp({
    required String name,
    required String email,
    required String phone,
    required String riskProfile,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": name.trim(),
          "email": email.trim(),
          "phone": phone.trim(),
          "riskProfile": riskProfile,
          "portfolio": 0,
          "totalInvestment": 0,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================
  // LOGIN
  // ==========================
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ==========================
  // LOGOUT
  // ==========================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ==========================
  // CURRENT USER
  // ==========================
  User? get currentUser => _auth.currentUser;

  // ==========================
  // GET USER DATA
  // ==========================
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    final user = _auth.currentUser;

    return await _firestore.collection("users").doc(user!.uid).get();
  }
}