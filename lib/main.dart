import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import your pages based on your folder structure
import 'presentation/splashscreen.dart';
import 'presentation/loginsignup_page.dart';
import 'presentation/login_page.dart';
import 'presentation/signup_page.dart';
import 'presentation/verify_page.dart';
import 'presentation/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using the firebase_options.dart file shown in your lib folder
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
      debugShowCheckedModeBanner: false,
      title: 'Pawpoint Digi-App',
      
      // Set the Splash Screen as the starting point
      initialRoute: '/', 
      
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const LoginsignupPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/verify': (context) => const VerifyPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}