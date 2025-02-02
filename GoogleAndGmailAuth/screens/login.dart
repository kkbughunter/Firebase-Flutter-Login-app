import 'package:control/authmanagement/auth_manage.dart';
import 'package:control/screens/forget_password.dart';
import 'package:control/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:control/screens/register.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class AppLoginScreen extends StatefulWidget {
  const AppLoginScreen({super.key});

  @override
  State<AppLoginScreen> createState() => _AppLoginScreenState();
}

class _AppLoginScreenState extends State<AppLoginScreen> {
  bool _isPasswordVisible = true;
  final _signFormKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _signFormKey,
          child: ListView(
            children: [
              SizedBox(
                // height: 200,
                child: Image.asset("assets/images/sign_in.png"),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Sign In",
                  style: TextStyle(fontSize: 25, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (_emailController) {
                    if (_emailController!.isEmpty) {
                      return "Email is required";
                    }
                    return null;
                  },
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "admin@gmail.com",
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (_passwordController) {
                    if (_passwordController!.length < 6) {
                      return "Password lengith must be at least 6 characters";
                    }
                    return null;
                  },
                  controller: _passwordController,
                  obscureText: _isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "********",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.password,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 90, right: 90),
                child: loginButton(),
              ),
              SizedBox(height: 30),
              // google auth option will be added here
              buildCustomButton("button", () {
                print("hello");
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: forgetPasswordTextButton(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't Have an Account?"),
                  createAccoutnTextButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createAccoutnTextButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppRegisterPage(),
          ),
        );
      },
      child: Text(
        'Create Account?',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }

  Widget forgetPasswordTextButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppForgetPasswordPage(),
          ),
        );
      },
      child: Text('Forgot Password?'),
    );
  }

  Widget loginButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_signFormKey.currentState!.validate()) {
          try {
            await AuthManage().login(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    "Invalid credentials Email ID or password",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
            );
          }
        }
      },
      child: Text("Login", style: TextStyle(fontSize: 20, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(0, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: Colors.blue[900],
      ),
    );
  }

  Widget buildCustomButton(String title, Function()? onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50),
      child: SizedBox(
        height: 60, // Adjust height as needed
        child: SignInButton(
          Buttons.Google,
          mini: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          onPressed: () async {
            await AuthManage().LoginWithGoogle();
          },
        ),
      ),
    );
  }
}
