import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../info/about_us_page.dart';
import '../misc/notifications_page.dart';
import '../info/services_page.dart';
import 'manage_profile_page.dart';
import '../info/contact_us_page.dart';
import '../widgets/shared_bottom_nav.dart';
import '../home/dashboard_page.dart';
import '../pets/my_pets_page.dart';
import '../appointments/book_now_page.dart';
import '../appointments/appointments_page.dart';
import '../auth/loginsignup_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 4;

  String _displayName = '';
  String _email = '';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (mounted) {
      setState(() {
        _email = user.email ?? '';
        _displayName = user.displayName ?? '';
      });
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};
      
      if (mounted) {
        setState(() {
          _displayName = (data['name'] as String?)?.isNotEmpty == true
              ? data['name'] as String
              : user.displayName ?? 'User';
          _photoUrl = data['photoUrl'] as String?;
        });
      }
    } catch (_) {}
  }

  ImageProvider? _getAvatarImage() {
    if (_photoUrl == null || _photoUrl!.isEmpty) return null;

    if (_photoUrl!.startsWith('http')) {
      return NetworkImage(_photoUrl!);
    }

    if (_photoUrl!.startsWith('data:image')) {
      try {
        final base64String = _photoUrl!.split(',').last;
        return MemoryImage(base64Decode(base64String));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void _onNavTapped(int index) {
    if (index == 4) return;
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
      return;
    }
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPetsPage())).then((_) => setState(() => _selectedIndex = 4));
      return;
    }
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const BookNowPage())).then((_) => setState(() => _selectedIndex = 4));
      return;
    }
    if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsPage())).then((_) => setState(() => _selectedIndex = 4));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('PROFILE', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
      ),
      bottomNavigationBar: SharedBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavTapped,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFFE8E8E8),
                    backgroundImage: _getAvatarImage(),
                    child: _getAvatarImage() == null
                        ? const Icon(Icons.person, size: 38, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName.isEmpty ? 'Loading…' : _displayName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Account'),
            _buildSectionCard([
              _buildListTile(
                Icons.person_outline,
                'Manage Profile',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManageProfilePage()),
                  );
                  _loadUserData();
                },
              ),
              _buildDivider(),
              _buildListTile(
                Icons.notifications_none,
                'Notifications',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
              ),
            ]),
            const SizedBox(height: 24),

            _buildSectionTitle('Preferences'),
            _buildSectionCard([
              _buildListTile(Icons.info_outline, 'About Us', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsPage()))),
              _buildDivider(),
              _buildListTile(Icons.support_agent_outlined, 'Services', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicesPage()))),
              _buildDivider(),
              _buildListTile(Icons.assignment_outlined, 'Appointments', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AppointmentsPage()))),
            ]),
            const SizedBox(height: 24),

            _buildSectionTitle('Support'),
            _buildSectionCard([
              _buildListTile(Icons.mail_outline, 'Contact Us', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsPage()))),
            ]),
            const SizedBox(height: 24),

            _buildSectionCard([
              _buildListTile(
                Icons.logout,
                'Logout',
                iconColor: Colors.black,
                textColor: Colors.red,
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginsignupPage()),
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(IconData icon, String title, {Color iconColor = Colors.black87, Color textColor = Colors.black87, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(title, style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.black26),
      onTap: onTap,
    );
  }

  Widget _buildDivider() => Divider(height: 1, thickness: 1, color: Colors.grey.shade100);
}
