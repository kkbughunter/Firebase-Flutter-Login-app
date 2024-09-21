import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iet_control/auth/phone_number_page.dart';
import 'package:iet_control/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IET Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthGate(),
      routes: {
        '/home': (context) =>
            HomePage(uid: FirebaseAuth.instance.currentUser?.uid ?? ''),
        '/login': (context) => const PhoneNumberPage(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the user is already logged in
    User? user = FirebaseAuth.instance.currentUser;

    // If the user is logged in, navigate to HomePage; otherwise, navigate to PhoneNumberPage
    return user != null ? HomePage(uid: user.uid) : const PhoneNumberPage();
  }
}
