import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawpoint_mobileapp/data/service_data.dart';
import 'package:pawpoint_mobileapp/models/appointment_model.dart';
import 'package:pawpoint_mobileapp/auth/appointment_service.dart';
import '../profile/profile_page.dart';
import '../home/dashboard_page.dart';
import '../pets/my_pets_page.dart';
import 'book_now_page.dart';
import '../widgets/shared_bottom_nav.dart';

// ── Doctor image map ──────────────────────────────────────────────────────────
const _doctorImages = {
  'Dr. Ji-eun Park': 'assets/images/doctor1-removebg-previewedit.png',
  'Dr. Matteo Rossi': 'assets/images/doctor2-removebg-previewedit.png',
  'Nurse Hana Kim': 'assets/images/n1-removebg-preview.png',
  'Nurse Sofia Müller': 'assets/images/n2-removebg-previewedit.png',
};

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

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

  List<AppointmentModel> _allAppointments = [];
  bool _isLoading = true;
  final _appointmentService = AppointmentService();

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

    _loadAppointments();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final appointments = await _appointmentService.getAppointments();
      if (mounted) {
        setState(() {
          _allAppointments = appointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load appointments: $e',
                style: GoogleFonts.poppins(fontSize: 12)),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  List<AppointmentModel> get _scheduled => _allAppointments
      .where((a) =>
          a.status == 'pending' ||
          a.status == 'scheduled' ||
          a.status == 'approved' ||
          a.status == 'reschedule_proposed')
      .toList();

  List<AppointmentModel> get _completed =>
      _allAppointments.where((a) => a.status == 'completed').toList();

  List<AppointmentModel> get _pending =>
      _allAppointments.where((a) =>
          a.status == 'pending' ||
          a.status == 'scheduled' ||
          a.status == 'reschedule_proposed').toList();

  List<AppointmentModel> get _cancelled =>
      _allAppointments.where((a) =>
          a.status == 'cancelled' ||
          a.status == 'auto_cancelled').toList();

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
      case 'scheduled':
        return 'Waiting for Approval';
      case 'approved':
        return 'Approved';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'auto_cancelled':
        return 'Auto-Cancelled';
      case 'reschedule_proposed':
        return 'Reschedule Proposed';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  String _fmtDate(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  String _fmtTime(DateTime dt) {
    String pad(int n) => n.toString().padLeft(2, '0');
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final endHour = dt.add(const Duration(hours: 1)).hour;
    final endH = endHour == 0 ? 12 : (endHour > 12 ? endHour - 12 : endHour);
    final endPeriod = endHour >= 12 ? 'PM' : 'AM';
    return '$h:${pad(dt.minute)} $period – $endH:${pad(dt.minute)} $endPeriod';
  }

  Future<void> _cancelAppointment(AppointmentModel appt) async {
    final hasPaid = appt.amountPaidOnline > 0;
    final isPending = appt.status == 'pending' || appt.status == 'scheduled';
    final isApproved = appt.status == 'approved';

    // ── Pre-cancel dialog with status-aware refund message ────────────────────
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Appointment',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel your ${appt.service} appointment with ${appt.doctor}?',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
            ),
            if (hasPaid) ...[
              const SizedBox(height: 14),
              // Pending → full refund
              if (isPending)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: Colors.green.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full Refund Eligible',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Since your appointment is still pending, your '  
                              'downpayment of ₱${appt.amountPaidOnline.toInt()} '
                              'will be fully refunded.',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.green.shade700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // Approved → no refund
              if (isApproved)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.red.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '⚠ No Refund — Downpayment Forfeited',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Your appointment was already approved. '  
                              'Your downpayment of ₱${appt.amountPaidOnline.toInt()} '  
                              'will NOT be refunded.',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.red.shade700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('No, Keep It',
                style: GoogleFonts.poppins(
                    color: Colors.black54, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Yes, Cancel',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || appt.id == null) return;

    try {
      final result = await _appointmentService.cancelAppointment(
        appointmentId: appt.id!,
      );

      await _loadAppointments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.snackbarMessage,
                style: GoogleFonts.poppins(fontSize: 12)),
            backgroundColor: result.snackbarColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel: $e',
                style: GoogleFonts.poppins(fontSize: 12)),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ── Reschedule ────────────────────────────────────────────────────────────

  Future<void> _rescheduleAppointment(AppointmentModel appt) async {
    if (appt.id == null) return;

    // Step 1 — Pick a new date
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Select New Date',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null || !mounted) return;

    // Step 2 — Pick a new time
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Select New Time',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null || !mounted) return;

    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Step 3 — Confirm dialog
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = newDateTime.hour > 12
        ? newDateTime.hour - 12
        : (newDateTime.hour == 0 ? 12 : newDateTime.hour);
    final min = newDateTime.minute.toString().padLeft(2, '0');
    final period = newDateTime.hour >= 12 ? 'PM' : 'AM';
    final label =
        '${months[newDateTime.month - 1]} ${newDateTime.day}, ${newDateTime.year}  ·  $h:$min $period';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Confirm Reschedule',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reschedule your ${appt.service} appointment to:',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_rounded,
                      color: Colors.blue.shade700, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your downpayment will be retained and the status will return to Pending for vet confirmation.',
              style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.black45, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Go Back',
                style: GoogleFonts.poppins(
                    color: Colors.black54, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Confirm',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _appointmentService.rescheduleAppointment(
        appointmentId: appt.id!,
        newDateTime: newDateTime,
      );
      await _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment rescheduled to $label 🗓️',
                style: GoogleFonts.poppins(fontSize: 12)),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reschedule: $e',
                style: GoogleFonts.poppins(fontSize: 12)),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ── Accept / Decline Reschedule ─────────────────────────────────────────────

  Future<void> _acceptReschedule(AppointmentModel appt) async {
    if (appt.id == null) return;
    try {
      await _appointmentService.acceptReschedule(appointmentId: appt.id!);
      await _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Reschedule accepted! Your appointment is now Approved ✓',
              style: GoogleFonts.poppins(fontSize: 12)),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e', style: GoogleFonts.poppins(fontSize: 12)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  Future<void> _declineReschedule(AppointmentModel appt) async {
    if (appt.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Decline Reschedule?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Declining will cancel this appointment and process a full refund of your downpayment.',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Go Back',
                style: GoogleFonts.poppins(color: Colors.black54, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Yes, Decline',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final result = await _appointmentService.declineReschedule(appointmentId: appt.id!);
      await _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.snackbarMessage,
              style: GoogleFonts.poppins(fontSize: 12)),
          backgroundColor: result.snackbarColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e', style: GoogleFonts.poppins(fontSize: 12)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  void _showAppointmentDetails(AppointmentModel appt) {
    // case-insensitive lookup
    final match = _doctorImages.keys.firstWhere(
      (k) => k.toLowerCase() == appt.doctor.toLowerCase(),
      orElse: () => '',
    );
    final imagePath = match.isNotEmpty ? _doctorImages[match]! : 'assets/images/profile_icon.jpg';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        // Keep content above the keyboard when it's open
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          // Cap at 90% of screen height so it never overflows
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.90,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Appointment Details',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appt.doctor,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            appt.service,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: appt.status),
                  ],
                ),
                const SizedBox(height: 20),
                _InfoTile(
                  icon: Icons.pets_rounded,
                  label: 'Pet',
                  value: appt.pet,
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.medical_services_outlined,
                  label: 'Service',
                  value: appt.service,
                ),
                const SizedBox(height: 10),
                if (kFormatPrice(appt.service).isNotEmpty)
                  _InfoTile(
                    icon: Icons.payments_rounded,
                    label: 'Price',
                    value: kFormatPrice(appt.service),
                  ),
                if (kFormatPrice(appt.service).isNotEmpty)
                  const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                  value: _fmtDate(appt.dateTime),
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.access_time_rounded,
                  label: 'Time',
                  value: _fmtTime(appt.dateTime),
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.info_outline_rounded,
                  label: 'Status',
                  value: _statusLabel(appt.status),
                ),
                const SizedBox(height: 24),
                // ── Action buttons ───────────────────────────────────────

                // ── Reschedule proposed: Accept / Decline ──
                if (appt.status == 'reschedule_proposed') ...
                [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit_calendar_rounded,
                                color: Color(0xFF1565C0), size: 16),
                            const SizedBox(width: 6),
                            Text('Reschedule Proposed',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1565C0),
                                )),
                          ],
                        ),
                        if (appt.proposedDateTime.isNotEmpty) ...
                        [
                          const SizedBox(height: 6),
                          Text(
                            'New proposed time: ${appt.proposedDateTime.substring(0, appt.proposedDateTime.length >= 16 ? 16 : appt.proposedDateTime.length).replaceAll('T', '  ')}',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: const Color(0xFF1565C0)),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'The clinic has proposed a new schedule. Please accept or decline.',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF1565C0).withOpacity(0.7),
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _declineReschedule(appt);
                            },
                            icon: const Icon(Icons.close_rounded, size: 18,
                                color: Color(0xFFEF4444)),
                            label: Text('Decline',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFEF4444),
                                )),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _acceptReschedule(appt);
                            },
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: Text('Accept',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                )),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // ── Reschedule — pending only (not when reschedule already proposed)
                if (appt.status == 'pending' || appt.status == 'scheduled')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _rescheduleAppointment(appt);
                        },
                        icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                        label: Text(
                          'Reschedule',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                // ── Cancel — not completed/cancelled/proposed
                if (appt.status != 'cancelled' &&
                    appt.status != 'auto_cancelled' &&
                    appt.status != 'completed' &&
                    appt.status != 'reschedule_proposed')
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _cancelAppointment(appt);
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: Text(
                        'Cancel Appointment',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                if (appt.status == 'cancelled')
                  Container(
                    width: double.infinity,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'This appointment has been cancelled',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                if (appt.status == 'completed')
                  Container(
                    width: double.infinity,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'This appointment has been completed',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onNavTapped(int index) {
    if (index == 3) return;
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
      ).then((_) => setState(() => _selectedIndex = 3));
      return;
    }
    if (index == 2) {
      setState(() => _selectedIndex = 2);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BookNowPage()),
      ).then((_) {
        setState(() => _selectedIndex = 3);
        _loadAppointments();
      });
      return;
    }
    if (index == 4) {
      setState(() => _selectedIndex = 4);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ).then((_) => setState(() => _selectedIndex = 3));
    }
  }

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
            onViewDetails: () => _showAppointmentDetails(appt),
            onReschedule: (appt.status == 'pending' || appt.status == 'scheduled')
                ? () => _rescheduleAppointment(appt)
                : null,
            onAcceptReschedule: appt.status == 'reschedule_proposed'
                ? () => _acceptReschedule(appt)
                : null,
            onDeclineReschedule: appt.status == 'reschedule_proposed'
                ? () => _declineReschedule(appt)
                : null,
            onCancel:
                appt.status != 'completed' &&
                        appt.status != 'cancelled' &&
                        appt.status != 'auto_cancelled' &&
                        appt.status != 'reschedule_proposed'
                    ? () => _cancelAppointment(appt)
                    : null,
          ),
        )
        .toList();
  }

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
                            Icons.refresh_rounded,
                            size: 28,
                          ),
                          onPressed: _loadAppointments,
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
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: Colors.black))
                      : RefreshIndicator(
                          color: Colors.black,
                          onRefresh: _loadAppointments,
                          child: ListView(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              if (_tabIndex == 0) ..._buildCards(_scheduled),
                              if (_tabIndex == 1) ..._buildCards(_completed),
                              if (_tabIndex == 2) ..._buildCards(_cancelled),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SharedBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavTapped,
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appt;
  final String formattedDate;
  final String formattedTime;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onAcceptReschedule;
  final VoidCallback? onDeclineReschedule;
  final VoidCallback onViewDetails;

  const _AppointmentCard({
    required this.appt,
    required this.formattedDate,
    required this.formattedTime,
    required this.onViewDetails,
    this.onCancel,
    this.onReschedule,
    this.onAcceptReschedule,
    this.onDeclineReschedule,
  });

  @override
  Widget build(BuildContext context) {
    // case-insensitive lookup
    final match = _doctorImages.keys.firstWhere(
      (k) => k.toLowerCase() == appt.doctor.toLowerCase(),
      orElse: () => '',
    );
    final imagePath = match.isNotEmpty ? _doctorImages[match]! : 'assets/images/profile_icon.jpg';

    final isPending  = appt.status == 'pending' || appt.status == 'scheduled';
    final isApproved = appt.status == 'approved';
    final isCompleted = appt.status == 'completed';
    final isCancelled = appt.status == 'cancelled' || appt.status == 'auto_cancelled';
    final isAutoCancelled = appt.status == 'auto_cancelled';

    return GestureDetector(
      onTap: onViewDetails,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.person, size: 50, color: Colors.white38),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isPending)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.hourglass_top_rounded,
                              size: 9,
                              color: const Color(0xFF856404),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Waiting for Approval',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF856404),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 9,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Approved!',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
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
                          color: isAutoCancelled
                              ? const Color(0xFFE8EAF6)
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAutoCancelled
                                  ? Icons.schedule_rounded
                                  : Icons.cancel_rounded,
                              size: 9,
                              color: isAutoCancelled
                                  ? const Color(0xFF3949AB)
                                  : Colors.red.shade700,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isAutoCancelled ? 'Auto-Cancelled' : 'Cancelled',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: isAutoCancelled
                                    ? const Color(0xFF3949AB)
                                    : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      appt.doctor,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      appt.service,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.black45,
                      ),
                    ),
                    if (kFormatPrice(appt.service).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.payments_rounded,
                                size: 11, color: Colors.black38),
                            const SizedBox(width: 4),
                            Text(
                              kFormatPrice(appt.service),
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Reschedule proposed — Accept/Decline only
                        if (appt.status == 'reschedule_proposed') ...
                        [
                          _ActionButton(
                            label: 'Decline',
                            filled: false,
                            onTap: onDeclineReschedule ?? () {},
                          ),
                          const SizedBox(width: 6),
                          _ActionButton(
                            label: 'Accept',
                            filled: true,
                            onTap: onAcceptReschedule ?? () {},
                          ),
                          const SizedBox(width: 6),
                        ],
                        // Reschedule — pending only (not when proposed)
                        if (isPending && onReschedule != null)
                          _ActionButton(
                            label: 'Reschedule',
                            filled: false,
                            onTap: onReschedule!,
                          ),
                        if (isPending && onReschedule != null)
                          const SizedBox(width: 6),
                        // Cancel — not completed/cancelled/proposed
                        if (!isCompleted && !isCancelled &&
                            appt.status != 'reschedule_proposed')
                          _ActionButton(
                            label: 'Cancel',
                            filled: false,
                            onTap: onCancel ?? () {},
                          ),
                        if (!isCompleted && !isCancelled &&
                            appt.status != 'reschedule_proposed')
                          const SizedBox(width: 6),
                        _ActionButton(
                          label: 'View Details',
                          filled: true,
                          onTap: onViewDetails,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          border:
              filled ? null : Border.all(color: Colors.black54, width: 1.2),
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'approved':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        label = 'Approved';
        break;
      case 'completed':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        label = 'Completed';
        break;
      case 'cancelled':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        label = 'Cancelled';
        break;
      case 'auto_cancelled':
        bgColor = const Color(0xFFE8EAF6);
        textColor = const Color(0xFF3949AB);
        label = 'Auto-Cancelled';
        break;
      case 'reschedule_proposed':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        label = 'Reschedule Proposed 📅';
        break;
      case 'pending':
      case 'scheduled':
      default:
        bgColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        label = 'Waiting for Approval';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black45),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black38,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
