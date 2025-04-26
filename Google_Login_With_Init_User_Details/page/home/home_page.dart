import 'package:astraval_smart/model/user_data.dart';
import 'package:astraval_smart/service/user_service.dart';

import '/authmanagement/auth_manage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userID = "";

  // get user data from user service
  UserData? userData;
  UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    userID = AuthManage().getUserID();
    userService.getUserData(userID).then((value) {
      setState(() {
        userData = value;
      });
    });
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
            Text("Hello, $userID"),
            Text("Hello, ${userData?.name}"),
            const SizedBox(height: 20),
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
