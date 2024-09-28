import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'auth/phone_number_page.dart';
import 'home/admin_home.dart';
import 'home/user_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IET Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthGate(),
      routes: {
        '/admin': (context) => const AdminHome(),
        '/user': (context) => const UserHome(),
        '/login': (context) => const PhoneNumberPage(),
        '/home': (context) => HomePage(
            uid: FirebaseAuth.instance.currentUser?.uid ??
                ''), // Define the home route
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is already logged in
    User? user = FirebaseAuth.instance.currentUser;

    // If the user is logged in, fetch the user's role and navigate accordingly
    return user != null
        ? RoleBasedRedirect(uid: user.uid)
        : const PhoneNumberPage();
  }
}

class RoleBasedRedirect extends StatelessWidget {
  final String uid;

  const RoleBasedRedirect({super.key, required this.uid});

  Future<String?> _getUserRole() async {
    // Reference to the Firebase Realtime Database to fetch user data
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('users/$uid');
    DataSnapshot snapshot = await userRef.get();

    if (snapshot.exists) {
      return snapshot.child('role').value as String?;
    }
    return null; // Return null if user data doesn't exist
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        // If role is available, redirect based on the role
        String? role = snapshot.data;
        if (role == 'ADMIN') {
          // Navigate to AdminHome if the role is ADMIN
          return const AdminHome();
        } else if (role == 'USER') {
          // Navigate to UserHome if the role is USER
          return const UserHome();
        } else {
          // Handle cases where role is not found or invalid
          return const Scaffold(
            body: Center(child: Text('No valid role found for the user.')),
          );
        }
      },
    );
  }
}

class HomePage extends StatelessWidget {
  final String uid;

  const HomePage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Center(
        child: Text("Welcome User with UID: $uid"),
      ),
    );
  }
}
