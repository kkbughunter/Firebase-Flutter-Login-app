import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/auth/phone_number_page.dart';

class HomePage extends StatelessWidget {
  final String uid;

  const HomePage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Sign out
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const PhoneNumberPage()), // Navigate to LoginPage
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'User ID: $uid',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
