import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loginsignup_page.dart';
import 'book_now_page.dart';
import 'appointments_page.dart';
import 'my_pets_page.dart';
import 'widgets/shared_bottom_nav.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _experts = [
    {
      'name': 'Dr. Ji-eun Park',
      'image': 'assets/images/doctor1-removebg-previewedit.png',
    },
    {
      'name': 'Dr. Matteo Rossi',
      'image': 'assets/images/doctor2-removebg-previewedit.png',
    },
    {
      'name': 'Nurse Hana Kim',
      'image': 'assets/images/n1-removebg-preview.png',
    },
    {
      'name': 'Nurse Sofia Müller',
      'image': 'assets/images/n2-removebg-previewedit.png',
    },
  ];

  final List<Map<String, String>> _services = [
    {
      'title': 'General Check-up',
      'description': 'Routine health exams to keep your pet happy and healthy.',
      'image': 'assets/images/h1-removebg-preview.png',
    },
    {
      'title': 'Diagnostics',
      'description': 'Lab tests and screenings to detect issues early.',
      'image': '',
    },
    {
      'title': 'Dental Care',
      'description':
          'Cleaning and oral checks to maintain strong teeth and gums.',
      'image': 'assets/images/jaguar-removebg-preview.png',
    },
    {
      'title': 'Nutrition Consultations',
      'description': 'Expert advice on diet, allergies, and weight management.',
      'image': '',
    },
    {
      'title': 'Parasite Prevention',
      'description': 'Protection against fleas, ticks, and heartworms.',
      'image': 'assets/images/parrot-removebg-preview.png',
    },
    {
      'title': 'Quick Grooming',
      'description': 'Fast services like nail clipping or paw tidy-ups.',
      'image': '',
    },
    {
      'title': 'Special Treatments',
      'description': 'Flea baths, medicated shampoos, or coat conditioning.',
      'image': '',
    },
    {
      'title': 'Full Grooming Packages',
      'description':
          'Bath, haircut, nail trim, and ear cleaning for a fresh look.',
      'image': 'assets/images/red_panda-removebg-preview.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top App Bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logo1.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFEEEEEE),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Hero Banner ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 195,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Grey card background
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 155,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 20, 140, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Hi there, this is Scout! 🐾 Everything you need for your pets is right here — simple, safe, and ready whenever you are.',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 9,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  'Learn More',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Dog overflowing beyond the card
                      Positioned(
                        right: -5,
                        bottom: 0,
                        child: Image.asset(
                          'assets/images/d3-removebg-preview.png',
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Pet Care Experts ─────────────────────────────────────
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pet Care Experts',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 130,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _experts.length,
                        itemBuilder: (context, index) {
                          final expert = _experts[index];
                          return GestureDetector(
                            onTap: () {
                              final user = FirebaseAuth.instance.currentUser;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => user != null
                                      ? BookNowPage(
                                          initialDoctor: expert['name']!,
                                        )
                                      : const LoginsignupPage(),
                                ),
                              );
                            },
                            child: _ExpertCard(
                              name: expert['name']!,
                              imagePath: expert['image']!,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Services ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 14),
                child: Text(
                  'Services',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column — even indices: 0, 2, 4, 6
                    Expanded(
                      child: Column(
                        children: [
                          for (int i = 0; i < _services.length; i += 2)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _ServiceCard(
                                title: _services[i]['title']!,
                                description: _services[i]['description']!,
                                imagePath: _services[i]['image']!,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Right column — odd indices: 1, 3, 5, 7
                    Expanded(
                      child: Column(
                        children: [
                          for (int i = 1; i < _services.length; i += 2)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _ServiceCard(
                                title: _services[i]['title']!,
                                description: _services[i]['description']!,
                                imagePath: _services[i]['image']!,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────
      bottomNavigationBar: SharedBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          if (index == 1) {
            setState(() => _selectedIndex = 1);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyPetsPage()),
            ).then((_) => setState(() => _selectedIndex = 0));
          } else if (index == 2) {
            setState(() => _selectedIndex = 2);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookNowPage()),
            ).then((_) => setState(() => _selectedIndex = 0));
          } else if (index == 3) {
            setState(() => _selectedIndex = 3);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppointmentsPage()),
            ).then((_) => setState(() => _selectedIndex = 0));
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
    );
  }
}

// ── Expert Card Widget ────────────────────────────────────────────────────────
class _ExpertCard extends StatelessWidget {
  final String name;
  final String imagePath;

  const _ExpertCard({required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular photo with a slightly darker grey ring
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFDDDDDD),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Service Card Widget ───────────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const _ServiceCard({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imagePath.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E8E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Text content ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      size: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final user = FirebaseAuth.instance.currentUser;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => user != null
                                ? BookNowPage(initialService: title)
                                : const LoginsignupPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Book an appointment now!',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Animal image (fixed height) ───────────────────
            if (hasImage)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Image.asset(
                  imagePath,
                  height: 150,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
