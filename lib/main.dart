import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import your pages based on your folder structure
import 'presentation/misc/splashscreen.dart';
import 'presentation/auth/loginsignup_page.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/auth/signup_page.dart';
import 'presentation/auth/verify_page.dart';
import 'presentation/home/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase — guarded against duplicate-app errors on hot restart
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // Firebase already initialized (e.g. hot restart on Android) — safe to ignore
    debugPrint('Firebase already initialized: $e');
  }
  
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