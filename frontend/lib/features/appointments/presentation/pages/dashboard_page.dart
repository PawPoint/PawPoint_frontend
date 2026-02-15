import "package:flutter/material.dart";
import "package:pawpoint_mobileapp/features/appointments/presentation/pages/login_page.dart";

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  State<DashboardPage> createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Dashboard")),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()
                  ),
                );
                },
                child: const Text(
                  "Login"
                ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
