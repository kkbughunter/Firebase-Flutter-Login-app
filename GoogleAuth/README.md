lib/screens/signin/signin.dart
```dart
import '/authmanagement/auth_manage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(
              height: 300,
              child: Image.asset("assets/images/sign_in.jpg"),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Sign In",
                style: TextStyle(fontSize: 25, color: Colors.grey),
              ),
            ),
            SizedBox(height: 30),
            // Google Sign-In Button
            buildCustomButton(),
          ],
        ),
      ),
    );
  }

  Widget buildCustomButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50),
      child: SizedBox(
        height: 60,
        child: SignInButton(
          Buttons.Google,
          mini: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          onPressed: () async {
            try {
              await AuthManage().LoginWithGoogle();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    "Google Sign-In failed: ${e.toString()}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
```

lib/screens/home/home.dart
```dart
import '/authmanagement/auth_manage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userID = "";

  @override
  void initState() {
    super.initState();
    userID = AuthManage().getUserID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IoT Control App"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hello, $userID"), // display the userID for the login user

            ElevatedButton(
                onPressed: () {
                  AuthManage().logout();
                },
                child: Text("Sign Out"))
          ],
        ),
      ),
    );
  }
}


```

lib/wapper.dart
```dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/home/home.dart'; // Make sure this import path is correct
import 'screens/signin/signin.dart'; // Make sure this import path is correct

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // While checking authentication state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If there's an error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "An error occurred: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // Check if user is logged in
          if (snapshot.hasData) {
            // User is logged in, go to HomePage
            return const HomePage();
          } else {
            // User is not logged in, show SigninScreen
            return const SigninScreen();
          }
        },
      ),
    );
  }
}
```

li/authmanagement/auth_manage.dart
```dart
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
  
  // ---------------------------- Google Login ------------------------------------- //
  // Logo In with Google
  Future<UserCredential?> LoginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();

      // Sign out to ensure account selection prompt
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }

  // ---------------------------- Common function ------------------------------------- //

  // getUserID() fnction to get the current user ID
  String getUserID() {
    return FirebaseAuth.instance.currentUser?.uid ?? "";
  }

  // logout() function to sign out the current user
  Future<void> logout() async {
    await _auth.signOut();
  }
}
```


