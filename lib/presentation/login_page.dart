import 'package:flutter/material.dart';
import 'dart:convert'; // Required for jsonEncode/jsonDecode
import 'package:http/http.dart' as http; // Required for API calls
import 'package:pawpoint_mobileapp/presentation/dashboard_page.dart';
import 'package:pawpoint_mobileapp/Admin/admin_dashboard_page.dart';
// Ensure you create this file or rename it to match your admin page file
// import 'package:pawpoint_mobileapp/presentation/admin_dashboard_page.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        "assets/images/LOGO.png",
                        width: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balancing space
                ],
              ),

              const Spacer(),

              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 20,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(55),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(55),
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    child: Image.asset(
                      "assets/images/c1-removebg-preview.png",
                      width: 350,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 20,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter both email and password.")),
                      );
                      return;
                    }

                    try {
                      // Update this URL based on your environment:
                      // Android Emulator: http://10.0.2.2:8000/api/auth/login
                      // iOS/Chrome/Desktop: http://127.0.0.1:8000/api/auth/login
                      // Use localhost for Web testing
                      final response = await http.post(
                        Uri.parse('http://localhost:8000/api/auth/login'), 
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'email': email,
                          'password': password,
                        }),
                      );

                      if (response.statusCode == 200) {
                        final data = jsonDecode(response.body);
                        String role = data['role'];

                        if (context.mounted) {
                          if (role == 'admin') {
                            // 1. Change DashboardPage() to AdminDashboardPage() once you create it
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminDashboardPage()), 
                            );
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Welcome back, Admin"), backgroundColor: Colors.green),
                            );
                          } else {
                            // 2. Regular users go here
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const DashboardPage()),
                            );
                          }
                        }
                      } else {
                        final errorData = jsonDecode(response.body);
                        String errorMessage = errorData['detail'] ?? "Login failed.";
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Connection error: Make sure backend is running!"), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {},
                child: const Text(
                  "Forgot your password?",
                  style: TextStyle(color: Colors.black54),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}