import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawpoint_mobileapp/presentation/dashboard_page.dart';


class WelcomePage extends StatefulWidget{
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 150),
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
                width: 270,
                height: 50,
              ),
              ),
              
              const SizedBox(height: 5),
              
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "care made simple for every kind of pet.",
                  style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 90),

              Transform.translate(offset: const Offset(10, 55), //this method is alternative for alignment
              child: Transform.scale(
                scale: 1.7,
                child: Image.asset(
                  "assets/images/welcomepage.png",
                  height: 400,
                  fit: BoxFit.contain,
                ),
              ),
              ),

              Transform.translate(offset: const Offset(0, -380),
              child: Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 20,
                    ),
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                    "Finish",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white
                    ),
                    ),
                ),
              ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
        ),
    );
  }
}