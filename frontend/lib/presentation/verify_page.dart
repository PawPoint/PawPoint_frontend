import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawpoint_mobileapp/presentation/welcome_page.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPage();
}

class _VerifyPage extends State<VerifyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "VERIFY EMAIL",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  // This 48px width balances the IconButton on the left
                  const SizedBox(width: 50),
                ],
              ),

              const SizedBox(height: 40),
              // You can add your squirrel image and OTP boxes here
              Align(
                alignment: Alignment(0.30, 0),
                child: Image.asset(
                  "assets/images/forgotpassicon.png",
                  width: 300,
                  fit: BoxFit.contain,
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: Text(
                  "Please enter the 4 digit code\nsent to your email",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // Place this inside your Column children list
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _otpBox(context),
                  _otpBox(context),
                  _otpBox(context),
                  _otpBox(context),
                ],
              ),

              const SizedBox(height: 80),

              Align(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomePage()),
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
                    "Verify",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white
                    ),
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox(BuildContext context) {
    return Container(
      height: 70,
      width: 65,
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background like your mockup
        borderRadius: BorderRadius.circular(10), // Slightly rounded corners
      ),
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        maxLength: 1, // Only allows one number per box
        decoration: const InputDecoration(
          border: InputBorder.none, // Removes the bottom line
          counterText: "", // Hides the "0/1" counter at the bottom
        ),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(
              context,
            ).nextFocus(); // Automatically moves to next box
          }
        },
      ),
    );
  }
}
