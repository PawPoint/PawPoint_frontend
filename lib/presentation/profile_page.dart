import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'widgets/shared_bottom_nav.dart';
import 'dashboard_page.dart';
import 'my_pets_page.dart';
import 'book_now_page.dart';
import 'appointments_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 4; // Profile tab is active

  // ── Navigation Routing Logic ──────────────────────────────────────────
  void _onNavTapped(int index) {
    if (index == 4) return; // already here
    
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
      return;
    }
    if (index == 1) {
      setState(() => _selectedIndex = 1);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyPetsPage()),
      ).then((_) => setState(() => _selectedIndex = 4));
      return;
    }
    if (index == 2) {
      setState(() => _selectedIndex = 2);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BookNowPage()),
      ).then((_) => setState(() => _selectedIndex = 4));
      return;
    }
    if (index == 3) {
      setState(() => _selectedIndex = 3);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AppointmentsPage()),
      ).then((_) => setState(() => _selectedIndex = 4));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('PROFILE'),
      ),
      
      // ── Bottom Nav Bar ──────────────────────────────────────────────────
      bottomNavigationBar: SharedBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavTapped,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Profile Header Card ---
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(
                      'https://cataas.com/cat/cute',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seraine', // We can make this dynamic later!
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'sean_rane@gmail.com', // We can make this dynamic later!
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Account Section ---
            _buildSectionTitle('Account'),
            _buildSectionCard([
              _buildListTile(Icons.person_outline, 'Manage Profile'),
              _buildDivider(),
              _buildListTile(Icons.notifications_none, 'Notifications'),
              _buildDivider(),
              _buildListTile(Icons.lock_outline, 'Change Password'),
            ]),
            const SizedBox(height: 24),

            // --- Preferences Section ---
            _buildSectionTitle('Preferences'),
            _buildSectionCard([
              _buildListTile(Icons.info_outline, 'About Us'),
              _buildDivider(),
              _buildListTile(Icons.support_agent_outlined, 'Services'),
              _buildDivider(),
              _buildListTile(Icons.assignment_outlined, 'Appointments'),
            ]),
            const SizedBox(height: 24),

            // --- Support Section ---
            _buildSectionTitle('Support'),
            _buildSectionCard([
              _buildListTile(Icons.mail_outline, 'Contact Us'),
            ]),
            const SizedBox(height: 24),

            // --- Bottom Actions Section ---
            _buildSectionCard([
              _buildListTile(
                Icons.logout,
                'Logout',
                iconColor: Colors.black,
                textColor: Colors.red,
                onTap: () async {
                  // Firebase Sign Out Logic!
                  await FirebaseAuth.instance.signOut();
                  
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        // TODO: Change this to your actual login/welcome screen class name
                        builder: (context) => const Placeholder(), 
                      ),
                      (route) => false, 
                    );
                  }
                },
              ),
              _buildDivider(),
              _buildListTile(Icons.switch_account_outlined, 'Change Account'),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Helper Methods ──────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Notice the added 'VoidCallback? onTap' parameter here!
  Widget _buildListTile(
    IconData icon,
    String title, {
    Color iconColor = Colors.black87,
    Color textColor = Colors.black87,
    VoidCallback? onTap, 
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap, // Connected here!
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100);
  }
}