import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawpoint_mobileapp/auth/appointment_service.dart';
import 'package:pawpoint_mobileapp/auth/notification_service.dart';
import 'package:pawpoint_mobileapp/core/utils/image_utils.dart';
import '../info/about_us_page.dart';
import '../info/contact_us_page.dart';
import '../misc/notifications_page.dart';
import '../profile/profile_page.dart';
import '../auth/loginsignup_page.dart';
import '../appointments/book_now_page.dart';
import '../appointments/appointments_page.dart';
import '../pets/my_pets_page.dart';
import '../widgets/shared_bottom_nav.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int _unreadNotifCount = 0;

  final _notifService = NotificationService();
  final _apptService = AppointmentService();

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
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final appointments =
          await _apptService.getAppointments();
      await _notifService.syncAppointmentNotifications(
        userId: user.uid,
        appointments: appointments,
      );
      final notifs =
          await _notifService.getNotifications(userId: user.uid);
      final adminNotifs =
          await _notifService.getNewServiceNotifications();
      final all = [
        ...notifs,
        ...adminNotifs.where((a) => !notifs.any((n) => n.id == a.id))
      ];
      if (mounted) {
        setState(() {
          _unreadNotifCount = all.where((n) => !n.isRead).length;
        });
      }
    } catch (_) {}
  }

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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsPage(),
                          ),
                        ).then((_) => _loadUnreadCount());
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFEEEEEE),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 20,
                              color: Colors.black54,
                            ),
                          ),
                          if (_unreadNotifCount > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                width: 17,
                                height: 17,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _unreadNotifCount > 9
                                      ? '9+'
                                      : '$_unreadNotifCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
                                onPressed: () {
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (_) => AboutUsPage(),
                                  ),
                                  );
                                },
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
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('admins')
                            .where('isActive', isEqualTo: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final experts = snapshot.data!.docs;
                          if (experts.isEmpty) {
                            return Center(
                              child: Text(
                                'No experts available yet',
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black38),
                              ),
                            );
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: experts.length,
                            itemBuilder: (context, index) {
                              final expert = experts[index].data() as Map<String, dynamic>;
                              final name = expert['name'] ?? 'Expert';
                              final photoUrl = expert['photoUrl'] ?? '';
                              return GestureDetector(
                                onTap: () {
                                  final user = FirebaseAuth.instance.currentUser;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => user != null
                                          ? BookNowPage(
                                              initialDoctor: name,
                                            )
                                          : const LoginsignupPage(),
                                    ),
                                  );
                                },
                                child: _ExpertCard(
                                  name: name,
                                  imagePath: photoUrl,
                                ),
                              );
                            },
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
          final user = FirebaseAuth.instance.currentUser;

          if (index == 1) {
            setState(() => _selectedIndex = 1);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    user != null ? const MyPetsPage() : const LoginsignupPage(),
              ),
            ).then((_) => setState(() => _selectedIndex = 0));
          } else if (index == 2) {
            setState(() => _selectedIndex = 2);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => user != null
                    ? const BookNowPage()
                    : const LoginsignupPage(),
              ),
            ).then((_) => setState(() => _selectedIndex = 0));
          } else if (index == 3) {
            setState(() => _selectedIndex = 3);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => user != null
                    ? const AppointmentsPage()
                    : const LoginsignupPage(),
              ),
            ).then((_) => setState(() => _selectedIndex = 0));
          } else if (index == 4) {
            setState(() => _selectedIndex = 4);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => user != null
                    ? const ProfileScreen()
                    : const LoginsignupPage(),
              ),
            ).then((_) => setState(() => _selectedIndex = 0));
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),

      // ── Help / Contact Us FAB ─────────────────────────────────────
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          width: 52,
          height: 52,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ContactUsPage(),
                ),
              );
            },
            backgroundColor: const Color(0xFF1A1A1A),
            elevation: 6,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _ExpertCard extends StatelessWidget {
  final String name;
  final String imagePath;

  const _ExpertCard({required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final imageProvider = ImageUtils.getProfileImage(imagePath);

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFDDDDDD),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.hardEdge,
            child: imageProvider != null
                ? Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_rounded,
                        size: 40,
                        color: Colors.white70),
                  )
                : (imagePath.isNotEmpty
                    ? Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: Colors.white70),
                      )
                    : const Icon(Icons.person_rounded,
                        size: 40, color: Colors.white70)),
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
