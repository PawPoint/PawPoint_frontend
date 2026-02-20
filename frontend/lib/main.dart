import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Added this missing import
import 'package:pawpoint_mobileapp/presentation/splashscreen.dart'; // 2. Fixed .dart.dart naming
import 'package:pawpoint_mobileapp/firebase_options.dart';

// 3. Added 'async' so that 'await' can function
void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Initialize Firebase before the app starts
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ),
  );
}