import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quizpp/features/auth/auth_services/firebase_services.dart';
import 'package:quizpp/features/auth/views/signup.dart';
import 'package:quizpp/features/profile/profilepage.dart';
import 'package:quizpp/main.dart';
import 'package:quizpp/widgets/text_field_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home_page/view/home.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState(); // Correct state class
}

AuthResult? globalAuthResult;

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<AuthResult> callLogin(String email, String password) async {
    final res = await signIn(email, password);
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFieldWidget(
                      text: "Email",
                      textEditingController: emailController,
                    ),
                    const SizedBox(height: 16),
                    TextFieldWidget(
                      text: "Password",
                      textEditingController: passwordController,
                      isPassword: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final res = await callLogin(email, password);
                    print("The response generated in login is ${res.message}");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res.message)),
                    );

                    if (res.status == AuthStatus.success) { // Use the enum here
                      var sharedPref = await SharedPreferences.getInstance();
                      sharedPref.setBool(MyAppState.KEYLOGIN, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Welcome to Quiz APP"),
                        ),
                      );
                      //send the user data to the profile page
                      globalAuthResult = res;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    }
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Don't Have an Account? ",
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Sign Up",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Signup()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
