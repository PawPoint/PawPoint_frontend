import "package:flutter/material.dart";
import "package:pawpoint_mobileapp/features/appointments/presentation/pages/dashboard_page.dart";
import "dart:async";

import "package:pawpoint_mobileapp/features/appointments/presentation/pages/dashboard_page.dart";

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key}); 

  @override
  State<SplashScreen> createState() => _SplashScreen();
  
}

class _SplashScreen extends State<SplashScreen>{
 @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    });
}

  @override
  Widget build(BuildContext context){
    return Scaffold( 
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(""),
      ),
      body: Stack(
        children: [
          Align(
            alignment: const Alignment(0, -0.4), // Positions the whole group
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prevents Column from taking full height
              children: [
                Image.asset(
                  "assets/images/LOGO.png",
                  width: 350, // Slightly reduced to fit better with text
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10), // Space between logo and text
                const Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    children: [
                      TextSpan(
                        text: "powered by ",
                        style: TextStyle(fontWeight: FontWeight.bold), // Bold part
                      ),
                      TextSpan(
                        text: "HAPPY TAILS VETERINARY CLINIC",
                        style: TextStyle(fontWeight: FontWeight.normal), // Normal part
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter, // Keeps it pinned to the bottom
            child: Image.asset(
              "assets/images/splashscreen1.jpg",
              width: MediaQuery.of(context).size.width, // Responsively fills width
              fit: BoxFit.cover,
              ),
          ),
        ],
      ),
    );
  }
}