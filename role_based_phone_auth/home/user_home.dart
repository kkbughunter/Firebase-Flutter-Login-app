import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kkfinctracker/auth/phone_number_page.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut(); // Sign out the user
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PhoneNumberPage()),
      (Route<dynamic> route) =>
          false, // Remove all the routes and redirect to login
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _logout(); // Call the logout function
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("Welcome, User!"),
      ),
    );
  }
}
