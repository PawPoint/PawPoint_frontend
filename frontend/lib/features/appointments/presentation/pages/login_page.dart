import 'package:flutter/material.dart';
import 'package:pawpoint_mobileapp/features/appointments/presentation/pages/splashscreen.dart.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key}); 

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  @override
  Widget build(BuildContext context){
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
              ),
              Image.asset(
                "assets/images/LOGO.png",
                width: 250,
                fit: BoxFit.contain,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "your paw-some appointment partner.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 40),

              Image.asset(
                "assets/images/catlogin.png",
                height: 300,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 60),

              ElevatedButton(
                onPressed: (){},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold),),
                ),
              )
            ],
          )

        )
          Align(
            alignment: Alignment(0, 1),
            child: Image.asset("assets/images/catlogin.png",
            width: 700,
            height: 700,
            ),
          ),
          Align(
            alignment: Alignment(-0.7, -0.9),
            child: Image.asset("assets/images/LOGO.png",
            width: 300,
            height: 200,
            ),
          ),
        ],
      )
    );
  }
}