import 'package:flutter/material.dart';
import 'package:pawpoint_mobileapp/presentation/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Align(
                    alignment: Alignment(0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset("assets/images/LOGO.png",
                        width: 250,
                        fit: BoxFit.contain,)
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Balancing space for the back button
                ],
              ),
              
              const Spacer(),

              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none, // This ensures the cat isn't cut off
                children: [
            // 1. The Email TextField (The base layer)
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      enabledBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(55),
                         borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
                  // The Cat Image positioned slightly above the text field
                  Positioned(
                    bottom: -30, // Adjust this to make the cat sit perfectly on the line
                    child: Image.asset(
                      "assets/images/c1-removebg-preview.png",
                      width: 350,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // 3. Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 4. Login Button with Shadow
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: (){
                  

                    Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardPage(),
                    ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: const Text("Forgot your password?", style: TextStyle(color: Colors.black54)),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}