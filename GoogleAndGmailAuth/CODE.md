main.dart
```dart
import 'authmanagement/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Control App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const Wrapper(),
    );
  }
}

```
authmanagement/auth_manager.dart
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
}
```
wrapper.dart
```dart
import '../screens/home/home.dart';
import '../screens/signin/signin.dart';
import '../screens/signup/verification_screen.dart';
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
```
screens/signin/signin.dart
```dart
import '/authmanagement/auth_manage.dart';
import '../forget_password/forget_password.dart';
import 'package:flutter/material.dart';
import '../signup/signup.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
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
            builder: (context) => SignupScreen(),
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
```
screens/signup/signup.dart
```dart
import '/authmanagement/auth_manage.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = true;
  final _signFormKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Account"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _signFormKey,
          child: ListView(
            children: [
              SizedBox(
                height: 300,
                child: Image.asset("assets/images/sign_up.jpg"),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Sign Up",
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
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "User Name",
                    hintText: "Samuel",
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
                    } else if (_passwordController !=
                        _confirmPasswordController.text.trim()) {
                      return "Password does not match";
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
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (_confirmPasswordController) {
                    if (_confirmPasswordController!.length < 6) {
                      return "Password lengith must be at least 6 characters";
                    }
                    return null;
                  },
                  controller: _confirmPasswordController,
                  obscureText: _isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
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
                padding: const EdgeInsets.only(top: 4, left: 50, right: 50),
                child: registerButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget registerButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_signFormKey.currentState!.validate()) {
          try {
            await AuthManage().register(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  "The email address is already in use.",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
        }
      },
      child:
          Text("Submit", style: TextStyle(fontSize: 20, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(0, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: Colors.blue[900],
      ),
    );
  }
}

```
screens/forget_password/forget_password.dart
```dart
import 'package:flutter/material.dart';
import '/authmanagement/auth_manage.dart';

class AppForgetPasswordPage extends StatefulWidget {
  const AppForgetPasswordPage({super.key});

  @override
  State<AppForgetPasswordPage> createState() => _AppForgetPasswordPageState();
}

class _AppForgetPasswordPageState extends State<AppForgetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter your email to receive a password reset link",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "example@gmail.com",
                  prefixIcon: Icon(Icons.email, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await AuthManage()
                            .resetPassword(_emailController.text.trim());
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              "Error: ${e.toString()}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.blue[900],
                  ),
                  child: Text(
                    "Reset Password",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

screens/home/home.dart
```dart
import '/authmanagement/auth_manage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            Text("Hello user"),
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


















