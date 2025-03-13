import '/authmanagement/auth_manage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../signin/signin.dart'; // Import SigninScreen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userID = "";
  Map<String, dynamic> userData = {};
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userID = AuthManage().getUserID();
    final databaseRef = FirebaseDatabase.instance.ref();
    final snapshot = await databaseRef.child('users').child(userID).get();
    if (snapshot.exists) {
      setState(() {
        userData = Map<String, dynamic>.from(snapshot.value as Map);
      });
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _isSigningOut = true);
    try {
      await AuthManage().logout();
      // Navigate to SigninScreen after successful logout
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SigninScreen()),
          (Route<dynamic> route) => false, // Removes all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IoT Control App"),
        centerTitle: true,
      ),
      body: Center(
        child: _isSigningOut
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Welcome, ${userData['name'] ?? 'User'}"),
                  Text("Email: ${userData['gmail'] ?? ''}"),
                  Text("Location: ${userData['location'] ?? ''}"),
                  Text("User ID: $userID"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _handleSignOut,
                    child: const Text("Sign Out"),
                  ),
                ],
              ),
      ),
    );
  }
}
