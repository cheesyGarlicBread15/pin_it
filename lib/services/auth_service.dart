import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register user with email and password, and save extra details to Firestore
  Future<User?> signUp({
    required String firstName,
    required String lastName,
    required int age,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (password != passwordConfirmation) {
      throw Exception("Passwords do not match");
    }

    try {
      // Create auth user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Save additional user data in Firestore
        await _firestore.collection("users").doc(user.uid).set({
          "firstName": firstName,
          "lastName": lastName,
          "age": age,
          "email": email,
          "role": "user",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  /// Login user with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  /// Logout user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get currently signed in user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    DocumentSnapshot doc = await _firestore.collection("users").doc(uid).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  /// Handle FirebaseAuth exceptions
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
