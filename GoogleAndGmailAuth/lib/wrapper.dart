import 'screens/home/home.dart';
import 'screens/signin/signin.dart';
import 'screens/signup/verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("An error occurred: ${snapshot.error}"));
          } else {
            // Check if the user is logged in
            if (snapshot.data != null) {
              // User is logged in, show the home page
              if (snapshot.data?.emailVerified == true) {
                return const HomePage();
              }
              return const VerificationScreen();
            } else {
              // User is not logged in, show the login screen

              return const SigninScreen();
            }
          }
        },
      ),
    );
  }
}
