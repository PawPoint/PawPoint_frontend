import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawpoint_mobileapp/models/appointment_model.dart';
import 'widgets/shared_bottom_nav.dart';

// ── Doctor image map ──────────────────────────────────────────────────────────
const _doctorImages = {
  'Dr. Ji-eun Park': 'assets/images/doctor1-removebg-previewedit.png',
  'Dr. Matteo Rossi': 'assets/images/doctor2-removebg-previewedit.png',
  'Nurse Hana Kim': 'assets/images/n1-removebg-preview.png',
  'Nurse Sofia Müller': 'assets/images/n2-removebg-previewedit.png',
};

class AppointmentsPage extends StatefulWidget {
  /// Newly confirmed appointment to prepend in the Schedule tab.
  final AppointmentModel? newAppointment;

  const AppointmentsPage({super.key, this.newAppointment});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  int _selectedIndex = 3; // Appts tab active
  int _tabIndex = 0; // 0=Schedule 1=Completed 2=Cancel

  late List<AppointmentModel> _scheduled;
  late List<AppointmentModel> _completed;
  late List<AppointmentModel> _cancelled;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    // Seed with demo data
    _scheduled = [
      if (widget.newAppointment != null) widget.newAppointment!,
      AppointmentModel(
        service: 'General Check-up',
        pet: 'Mavy',
        doctor: 'Dr. Ji-eun Park',
        dateTime: DateTime(2026, 2, 25, 7, 0),
        status: 'approved',
      ),
      AppointmentModel(
        service: 'Dental Care',
        pet: 'Biscuit',
        doctor: 'Dr. Matteo Rossi',
        dateTime: DateTime(2026, 2, 27, 10, 0),
        status: 'scheduled',
      ),
    ];

    _completed = [
      AppointmentModel(
        service: 'Quick Grooming',
        pet: 'Mavy',
        doctor: 'Nurse Hana Kim',
        dateTime: DateTime(2026, 2, 10, 9, 0),
        status: 'completed',
      ),
    ];

    _cancelled = [];
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _fmtDate(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
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
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  String _fmtTime(DateTime dt) {
    String pad(int n) => n.toString().padLeft(2, '0');
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'Pm' : 'Am';
    final endHour = dt.add(const Duration(hours: 4)).hour;
    final endH = endHour == 0 ? 12 : (endHour > 12 ? endHour - 12 : endHour);
    return '$h - ${pad(endH)}:${pad(dt.minute)} $period';
  }

  // ── Nav ────────────────────────────────────────────────────────────────────

  void _onNavTapped(int index) {
    if (index == 3) return; // already here
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  // ── Tab content ────────────────────────────────────────────────────────────

  List<Widget> _buildCards(List<AppointmentModel> list) {
    if (list.isEmpty) {
      return [
        const SizedBox(height: 60),
        Center(
          child: Text(
            'No appointments here yet.',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black38),
          ),
        ),
      ];
    }
    return list
        .map(
          (appt) => _AppointmentCard(
            appt: appt,
            formattedDate: _fmtDate(appt.dateTime),
            formattedTime: _fmtTime(appt.dateTime),
            onCancel: appt.status != 'completed' && appt.status != 'cancelled'
                ? () {
                    setState(() {
                      _scheduled.remove(appt);
                      _cancelled.add(appt.copyWith(status: 'cancelled'));
                    });
                  }
                : null,
            onReschedule: appt.status == 'scheduled'
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Reschedule coming soon! 🐾',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.black,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                : null,
          ),
        )
        .toList();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: [
                // ── Header ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            size: 28,
                          ),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                      ),
                      Text(
                        'My Appointments',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Tabs ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _TabButton(
                        label: 'Schedule',
                        active: _tabIndex == 0,
                        onTap: () => setState(() => _tabIndex = 0),
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        label: 'Completed',
                        active: _tabIndex == 1,
                        onTap: () => setState(() => _tabIndex = 1),
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        label: 'Cancel',
                        active: _tabIndex == 2,
                        onTap: () => setState(() => _tabIndex = 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Cards ─────────────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      if (_tabIndex == 0) ..._buildCards(_scheduled),
                      if (_tabIndex == 1) ..._buildCards(_completed),
                      if (_tabIndex == 2) ..._buildCards(_cancelled),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ── Bottom Nav ──────────────────────────────────────────────────
      bottomNavigationBar: SharedBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavTapped,
      ),
    );
  }
}

// ── Appointment Card ──────────────────────────────────────────────────────────
class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appt;
  final String formattedDate;
  final String formattedTime;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  const _AppointmentCard({
    required this.appt,
    required this.formattedDate,
    required this.formattedTime,
    this.onCancel,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath =
        _doctorImages[appt.doctor] ?? 'assets/images/profile_icon.jpg';
    final isApproved = appt.status == 'approved';
    final isCompleted = appt.status == 'completed';
    final isCancelled = appt.status == 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Doctor photo panel ──────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
            child: Container(
              width: 110,
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, size: 50, color: Colors.white38),
              ),
            ),
          ),

          // ── Info panel ─────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Approved badge
                  if (isApproved)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Approved!',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  if (isCancelled)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Cancelled',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),

                  // Doctor name
                  Text(
                    appt.doctor,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  // Service
                  Text(
                    appt.service,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: Colors.black45,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Colors.black45,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formattedDate,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Colors.black45,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formattedTime,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isCompleted || isApproved)
                        _ActionButton(
                          label: isCompleted ? 'View Details' : 'Cancel',
                          filled: isCompleted,
                          onTap: isCompleted ? () {} : onCancel ?? () {},
                        ),
                      if (!isCompleted && !isApproved && !isCancelled) ...[
                        _ActionButton(
                          label: 'Cancel',
                          filled: false,
                          onTap: onCancel ?? () {},
                        ),
                        const SizedBox(width: 6),
                        _ActionButton(
                          label: 'Reschedule',
                          filled: true,
                          onTap: onReschedule ?? () {},
                        ),
                      ],
                      if (isApproved) ...[
                        const SizedBox(width: 6),
                        _ActionButton(
                          label: 'View Details',
                          filled: true,
                          onTap: () {},
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small action button ───────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: filled ? Colors.black : Colors.transparent,
          border: filled ? null : Border.all(color: Colors.black54, width: 1.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

// ── Tab Button ────────────────────────────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.black : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.black45,
          ),
        ),
      ),
    );
  }
}
