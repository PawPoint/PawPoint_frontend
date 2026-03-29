import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawpoint_mobileapp/data/service_data.dart';
import 'package:pawpoint_mobileapp/models/appointment_model.dart';
import 'package:pawpoint_mobileapp/models/pet_model.dart';
import '../profile/profile_page.dart';
import '../widgets/shared_bottom_nav.dart';
import 'booking_confirmation_page.dart';
import 'appointments_page.dart';
import '../home/dashboard_page.dart';
import '../pets/my_pets_page.dart';

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

  // User's registered pets (alive only)
  List<PetModel> _userPets = [];
  bool _isLoadingPets = true;

  @override
  void initState() {
    super.initState();
    _selectedDoctor = widget.initialDoctor;
    _selectedService = widget.initialService;
    _loadUserPets();
  }

  Future<void> _loadUserPets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoadingPets = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .orderBy('name')
          .get();

      final pets = snapshot.docs
          .map((doc) => PetModel.fromMap(doc.id, doc.data()))
          .where((pet) => !pet.isDeceased)
          .toList();

      if (mounted) {
        setState(() {
          _userPets = pets;
          _isLoadingPets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPets = false);
      }
    }
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

  final List<String> _doctors = [
    'Dr. Ji-eun Park',
    'Dr. Matteo Rossi',
    'Nurse Hana Kim',
    'Nurse Sofia Müller',
  ];

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = now.weekday == DateTime.sunday
        ? now.add(const Duration(days: 1))
        : now;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      selectableDayPredicate: (day) => day.weekday != DateTime.sunday,
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

    final pickedHour = await _pickTimeSlot();
    if (pickedHour == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        pickedHour,
        0,
      );
    });
  }

  Future<int?> _pickTimeSlot() async {
    const morningSlots = [7, 8, 9, 10, 11];
    const afternoonSlots = [13, 14, 15, 16, 17, 18];

    String _label(int h) {
      final hour = h > 12 ? h - 12 : h;
      final period = h >= 12 ? 'PM' : 'AM';
      return '$hour:00 $period';
    }

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Select Time',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Mon – Sat  •  7:00 AM – 6:00 PM  (closed 12–1 PM)',
                style: GoogleFonts.poppins(
                    fontSize: 11.5, color: Colors.black45)),
            const SizedBox(height: 18),
            Text('Morning',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: morningSlots.map((h) => _SlotButton(
                label: _label(h),
                onTap: () => Navigator.pop(ctx, h),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.restaurant_rounded,
                      size: 14, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  Text('12:00 PM – 1:00 PM  ·  Staff lunch break',
                      style: GoogleFonts.poppins(
                          fontSize: 11.5, color: Colors.orange.shade700)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Afternoon',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: afternoonSlots.map((h) => _SlotButton(
                label: _label(h),
                onTap: () => Navigator.pop(ctx, h),
              )).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
    if (index == 2) return;
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
      ).then((_) {
        _loadUserPets();
        setState(() => _selectedIndex = 2);
      });
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
    if (index == 4) {
      setState(() => _selectedIndex = 4);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ).then((_) => setState(() => _selectedIndex = 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> petNames = _userPets.map((p) => p.name).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
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
                          _DropdownField(
                            hint: 'Services',
                            value: _selectedService,
                            items: _services,
                            onChanged: (v) =>
                                setState(() => _selectedService = v),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            child: _selectedService != null &&
                                    kServicePrices.containsKey(_selectedService)
                                ? Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.payments_rounded,
                                          size: 16,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Estimated cost',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white60,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          kFormatPrice(_selectedService!),
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 14),
                          _isLoadingPets
                              ? Container(
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
                                          'Loading pets...',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.black38,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black38,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : petNames.isEmpty
                              ? Container(
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
                                          'No pets registered yet',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.black38,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.pets_rounded,
                                        size: 20,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                )
                              : _DropdownField(
                                  hint: 'Pet',
                                  value: _selectedPet,
                                  items: petNames,
                                  onChanged: (v) =>
                                      setState(() => _selectedPet = v),
                                ),
                          const SizedBox(height: 14),
                          _DropdownField(
                            hint: 'Doctor',
                            value: _selectedDoctor,
                            items: _doctors,
                            onChanged: (v) =>
                                setState(() => _selectedDoctor = v),
                          ),
                          const SizedBox(height: 14),
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
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.info_outline_rounded,
                                          size: 14,
                                          color: Color(0xFF2E7D32)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Appointments: Mon – Sat, 7:00 AM – 6:00 PM'
                                          ' (closed 12 – 1 PM for staff lunch)',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: const Color(0xFF2E7D32),
                                            fontWeight: FontWeight.w500,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.emergency_rounded,
                                          size: 14,
                                          color: Color(0xFFC62828)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Clinic open 24 hours for emergencies',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: const Color(0xFFC62828),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
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
      bottomNavigationBar: SharedBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavTapped,
      ),
    );
  }
}

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

class _SlotButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SlotButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
