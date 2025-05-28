import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:quizpp/constants.dart';
import 'package:quizpp/features/auth/views/login.dart';
import 'package:quizpp/features/auth/views/signup.dart';
import 'package:quizpp/features/chatBot/chatbot_page.dart';
import 'package:quizpp/features/home_page/view/home.dart';
import 'package:quizpp/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //insiitalise the gemini in our app
  Gemini.init(apiKey: GEMINI_API_KEY);
  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  static const String KEYLOGIN = "login";

  bool isLoading = true;
  Widget? initialScreen;

  @override
  void initState() {
    super.initState();
    whereToGO();
  }

  Future<void> whereToGO() async {
    var sharedPref = await SharedPreferences.getInstance();
    var isLoggedIn = sharedPref.getBool(KEYLOGIN);
    setState(() {
      if (isLoggedIn == true) {
        initialScreen = Home();
        // initialScreen = ChatbotPage();
      } else if (isLoggedIn == false) {
        initialScreen = Login();
      } else {
        // Implement your error handling here, for example, a network error or a timeout error
        // For now, just show a default screen
        initialScreen = Signup();
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show a loading screen while deciding
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Quiz App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Please wait...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    )),
              ],
            ),
          ),
        ),
      );
    }

    // Show the decided screen
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: initialScreen,
    );
  }
}


