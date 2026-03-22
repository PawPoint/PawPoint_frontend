import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawpoint_mobileapp/models/pet_model.dart';
import 'package:pawpoint_mobileapp/presentation/profile_page.dart';
import 'package:pawpoint_mobileapp/presentation/pet_info_page.dart';
import 'select_pet_type_page.dart';
import 'widgets/shared_bottom_nav.dart';
import 'book_now_page.dart';
import 'appointments_page.dart';
import 'dashboard_page.dart';

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({super.key});

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  int _selectedIndex = 1; // Pets tab is active

  void _onNavTapped(int index) {
    if (index == 1) return; // already here
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
      return;
    }
    if (index == 2) {
      setState(() => _selectedIndex = 2);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BookNowPage()),
      ).then((_) => setState(() => _selectedIndex = 1));
      return;
    }
    if (index == 3) {
      setState(() => _selectedIndex = 3);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AppointmentsPage()),
      ).then((_) => setState(() => _selectedIndex = 1));
      return;
    }
    if (index == 4) {
      setState(() => _selectedIndex = 4);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ).then((_) => setState(() => _selectedIndex = 1));
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 28),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  Text(
                    'My Pets',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // ── Pet List ─────────────────────────────────────────────
            Expanded(
              child: user == null
                  ? Center(
                      child: Text(
                        'Please log in to view your pets.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black38,
                        ),
                      ),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('pets')
                          .orderBy('name')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.pets_rounded,
                                  size: 64,
                                  color: Colors.black12,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No pets yet!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black38,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tap the button below to add your first pet.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black26,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final pets = docs
                            .map(
                              (doc) => PetModel.fromMap(
                                doc.id,
                                doc.data() as Map<String, dynamic>,
                              ),
                            )
                            .toList();

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: pets.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 0),
                          itemBuilder: (context, index) {
                            return _PetListTile(pet: pets[index]);
                          },
                        );
                      },
                    ),
            ),

            // ── Add Button ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 56,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SelectPetTypePage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: const StadiumBorder(),
                      ),
                      child: const Icon(Icons.add, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Nav Bar ────────────────────────────────────────────
      bottomNavigationBar: SharedBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavTapped,
      ),
    );
  }
}

// ── Pet List Tile Widget ────────────────────────────────────────────────────
class _PetListTile extends StatelessWidget {
  final PetModel pet;

  const _PetListTile({required this.pet});

  /// Calculate age from birthday, showing months or days as appropriate
  String _calculateAge() {
    if (pet.birthday.isEmpty) {
      final years = int.tryParse(pet.age) ?? 0;
      return '$years yrs old';
    }
    try {
      final parts = pet.birthday.split('-');
      final birthDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final now = DateTime.now();
      int months =
          (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
      if (now.day < birthDate.day) months--;
      if (months < 0) months = 0;

      if (months == 0) {
        final days = now.difference(birthDate).inDays;
        if (days <= 0) return '< 1 day old';
        if (days == 1) return '1 day old';
        return '$days days old';
      }

      return '$months mos old';
    } catch (_) {
      final years = int.tryParse(pet.age) ?? 0;
      return '$years yrs old';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDeceased = pet.isDeceased;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDeceased ? const Color(0xFFE8E8E8) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // ── Pet Photo ─────────────────────────────────────────
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE0E0E0),
              border: Border.all(
                color: isDeceased ? Colors.grey[400]! : const Color(0xFFCCCCCC),
                width: 2,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: _buildAvatar(isDeceased),
          ),

          const SizedBox(width: 16),

          // ── Pet Details ────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDeceased ? Colors.grey : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pet.gender,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDeceased ? Colors.grey : Colors.black45,
                  ),
                ),
                Text(
                  _calculateAge(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDeceased ? Colors.grey : Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          // ── Paw Icon (navigates to Pet Info) ───────────────────
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PetInfoPage(pet: pet)),
              );
            },
            child: ColorFiltered(
              colorFilter: isDeceased
                  ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                  : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
              child: Image.asset(
                'assets/images/nav_pets.jpg',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.pets_rounded,
                  size: 26,
                  color: isDeceased ? Colors.grey : Colors.black26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDeceased) {
    Widget imageWidget;
    if (pet.imageUrl != null && pet.imageUrl!.isNotEmpty) {
      imageWidget = Image.memory(
        base64Decode(pet.imageUrl!),
        fit: BoxFit.cover,
        width: 64,
        height: 64,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.pets_rounded, size: 28, color: Colors.black26),
      );
    } else {
      imageWidget = const Icon(
        Icons.pets_rounded,
        size: 28,
        color: Colors.black26,
      );
    }

    if (isDeceased) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: imageWidget,
      );
    }
    return imageWidget;
  }
}
