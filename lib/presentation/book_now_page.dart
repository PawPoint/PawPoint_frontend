import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawpoint_mobileapp/models/appointment_model.dart';
import 'package:pawpoint_mobileapp/presentation/profile_page.dart';
import 'widgets/shared_bottom_nav.dart';
import 'booking_confirmation_page.dart';
import 'appointments_page.dart';
import 'dashboard_page.dart';
import 'my_pets_page.dart';

class BookNowPage extends StatefulWidget {
  final String? initialDoctor;
  final String? initialService;

  const BookNowPage({super.key, this.initialDoctor, this.initialService});

  @override
  State<BookNowPage> createState() => _BookNowPageState();
}

class _BookNowPageState extends State<BookNowPage> {
  int _selectedIndex = 2; // "Book" is active

  String? _selectedService;
  String? _selectedPet;
  String? _selectedDoctor;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDoctor = widget.initialDoctor;
    _selectedService = widget.initialService;
  }

  final List<String> _services = [
    'General Check-up',
    'Diagnostics',
    'Dental Care',
    'Nutrition Consultations',
    'Parasite Prevention',
    'Quick Grooming',
    'Special Treatments',
    'Full Grooming Packages',
  ];

  final List<String> _pets = [
    'Dog',
    'Cat',
    'Bird',
    'Rabbit',
    'Hamster',
    'Other',
  ];

  final List<String> _doctors = [
    'Dr. Ji-eun Park',
    'Dr. Matteo Rossi',
    'Nurse Hana Kim',
    'Nurse Sofia Müller',
  ];

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  •  $hour:$minute $period';
  }

  bool get _isFormValid =>
      _selectedService != null &&
      _selectedPet != null &&
      _selectedDoctor != null &&
      _selectedDateTime != null;

  void _onNavTapped(int index) {
    if (index == 2) return; // already here
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
    if (index == 3) {
      setState(() => _selectedIndex = 3);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AppointmentsPage()),
      ).then((_) => setState(() => _selectedIndex = 2));
      return;
    } 
    if (index == 4){
      setState(() => _selectedIndex = 4);
      Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ).then((_) => setState(() => _selectedIndex = 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
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
                    'Book Now',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Content ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // ── Booking Card ─────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Book your paw-fect visit now!',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Services dropdown
                          _DropdownField(
                            hint: 'Services',
                            value: _selectedService,
                            items: _services,
                            onChanged: (v) =>
                                setState(() => _selectedService = v),
                          ),
                          const SizedBox(height: 14),

                          // Pet dropdown
                          _DropdownField(
                            hint: 'Pet',
                            value: _selectedPet,
                            items: _pets,
                            onChanged: (v) => setState(() => _selectedPet = v),
                          ),
                          const SizedBox(height: 14),

                          // Doctor dropdown
                          _DropdownField(
                            hint: 'Doctor',
                            value: _selectedDoctor,
                            items: _doctors,
                            onChanged: (v) =>
                                setState(() => _selectedDoctor = v),
                          ),
                          const SizedBox(height: 14),

                          // Date & Time picker
                          GestureDetector(
                            onTap: _pickDateTime,
                            child: Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedDateTime != null
                                          ? _formatDateTime(_selectedDateTime!)
                                          : 'Date & Time',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: _selectedDateTime != null
                                            ? Colors.black87
                                            : Colors.black38,
                                      ),
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/nav_booknow.png',
                                    width: 22,
                                    height: 22,
                                    fit: BoxFit.contain,
                                    color: Colors.black45,
                                    colorBlendMode: BlendMode.srcIn,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.pets,
                                      size: 20,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Continue button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isFormValid
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              BookingConfirmationPage(
                                                appointment: AppointmentModel(
                                                  service: _selectedService!,
                                                  pet: _selectedPet!,
                                                  doctor: _selectedDoctor!,
                                                  dateTime: _selectedDateTime!,
                                                ),
                                              ),
                                        ),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                disabledBackgroundColor: Colors.black
                                    .withOpacity(0.3),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Continue',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Nav Bar ────────────────────────────────────────────────
      bottomNavigationBar: SharedBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavTapped,
      ),
    );
  }
}

// ── Reusable Dropdown Field ───────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black38),
          ),
          isExpanded: true,
          icon: Image.asset(
            'assets/images/nav_booknow.png',
            width: 22,
            height: 22,
            fit: BoxFit.contain,
            color: Colors.black45,
            colorBlendMode: BlendMode.srcIn,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.pets, size: 20, color: Colors.black45),
          ),
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          items: items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
