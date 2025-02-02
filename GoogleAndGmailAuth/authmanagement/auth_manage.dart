import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

exceptionHandler(String errorCode) {
  switch (errorCode) {
    case 'invalid-credential':
      return 'Your login credentials are invalid. Please try again.';
    case 'weak-password':
      return 'The password myst be longer than 6 characters.';
    case 'email-already-in-use':
      return 'The email address is already in use.';
    case 'user-not-found':
      return 'No user found with this email.';
    case 'invalid-email':
      return 'Invalid email format.';
    case 'wrong-password':
      return 'Invalid credentials Email ID or password';
    default:
      return 'An unexpected error occurred.';
  }
}

class AuthManage {
  final _auth = FirebaseAuth.instance;
  Future<User> register(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw Exception(exceptionHandler(e.code));
    } catch (e) {
      throw Exception("Registration failed: ${e.toString()}");
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw Exception(exceptionHandler(e.code));
    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }

  // Email _auth
  Future<void> sendEmailVerificationLink() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }

  // Logo In with Google
  Future<UserCredential?> LoginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      final googleAuth = await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
    return null;
  }
}
