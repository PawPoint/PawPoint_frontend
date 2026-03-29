import "package:flutter/material.dart";
import "../home/dashboard_page.dart";
import "dart:async";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Logo at the top ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 64, bottom: 8),
            child: Center(
              child: Image.asset(
                "assets/images/LOGO.png",
                width: MediaQuery.of(context).size.width * 0.72,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ── "powered by" text ──────────────────────────────────────────
          const Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.black54),
              children: [
                TextSpan(
                  text: "powered by ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "HAPPY TAILS VETERINARY CLINIC",
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),

          // ── Pets group image fills the remaining space ─────────────────
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "assets/images/splashscreen1.jpg",
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
