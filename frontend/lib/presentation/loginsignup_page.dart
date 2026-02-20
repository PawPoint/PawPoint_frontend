import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';

class LoginsignupPage extends StatefulWidget {
  const LoginsignupPage({super.key});

  @override
  State<LoginsignupPage> createState() => _LoginsignupPage();
}

class _LoginsignupPage extends State<LoginsignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Welcome to",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
                ),
              ),
              Align(
                alignment: Alignment(-1.4, 0),
                child: Image.asset(
                "assets/images/LOGO.png",
                width: 250,
                height: 50,
              ),
              ),
              
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "your paw-some appointment partner.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 40),
              
              Transform.scale(
                scale: 1.6,
                child: Image.asset(
                "assets/images/catlogin.png",
                height: 400,
                fit: BoxFit.contain,
              ),
              ),

              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()
                  ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "LOGIN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()
                  ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "SIGN UP",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}