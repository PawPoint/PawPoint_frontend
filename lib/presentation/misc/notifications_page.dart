import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawpoint_mobileapp/auth/appointment_service.dart';
import 'package:pawpoint_mobileapp/auth/notification_service.dart';
import 'package:pawpoint_mobileapp/models/notification_model.dart';
import '../auth/loginsignup_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  // ── Services ──────────────────────────────────────────────────────────────
  final _notifService = NotificationService();
  final _apptService = AppointmentService();

  // ── State ─────────────────────────────────────────────────────────────────
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _isGuest = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // ── Filter tab: 0 = All, 1 = Unread ──────────────────────────────────────
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadNotifications();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    _animCtrl.reset();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _isGuest = true;
      });
      _animCtrl.forward();
      return;
    }
    // Reset guest flag in case the user signed in between visits
    _isGuest = false;

    try {
      // 1. Sync appointment-derived notifications first
      final appointments =
          await _apptService.getAppointments();
      await _notifService.syncAppointmentNotifications(
        userId: user.uid,
        appointments: appointments,
      );

      // 2. Load persisted notifications
      final notifs =
          await _notifService.getNotifications(userId: user.uid);

      // 3. Load admin new-service notifications and merge
      final adminNotifs =
          await _notifService.getNewServiceNotifications();

      if (mounted) {
        setState(() {
          _notifications = [
            ...notifs,
            ...adminNotifs.where(
              (a) => !notifs.any((n) => n.id == a.id),
            ),
          ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _isLoading = false;
        });
        _animCtrl.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _animCtrl.forward();
      }
    }
  }

  // ── Mark all as read ──────────────────────────────────────────────────────

  Future<void> _markAllRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _notifService.markAllAsRead(userId: user.uid);
    setState(() {
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  // ── Mark single as read ───────────────────────────────────────────────────

  Future<void> _markRead(NotificationModel notif) async {
    if (notif.isRead) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _notifService.markAsRead(
      userId: user.uid,
      notificationId: notif.id,
    );
    setState(() {
      final i = _notifications.indexWhere((n) => n.id == notif.id);
      if (i >= 0) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get _filtered => _filterIndex == 1
      ? _notifications.where((n) => !n.isRead).toList()
      : _notifications;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  // ── Notification meta helpers ─────────────────────────────────────────────

  _NotifMeta _meta(NotificationType type) {
    switch (type) {
      case NotificationType.appointmentReminder:
        return _NotifMeta(
          icon: Icons.alarm_rounded,
          color: const Color(0xFFFF8C00),
          bg: const Color(0xFFFFF3E0),
          label: 'Reminder',
        );
      case NotificationType.appointmentApproved:
        return _NotifMeta(
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF2E7D32),
          bg: const Color(0xFFE8F5E9),
          label: 'Approved',
        );
      case NotificationType.appointmentCancelled:
        return _NotifMeta(
          icon: Icons.cancel_rounded,
          color: const Color(0xFFC62828),
          bg: const Color(0xFFFFEBEE),
          label: 'Cancelled',
        );
      case NotificationType.labResults:
        return _NotifMeta(
          icon: Icons.science_rounded,
          color: const Color(0xFF1565C0),
          bg: const Color(0xFFE3F2FD),
          label: 'Lab Results',
        );
      case NotificationType.petReady:
        return _NotifMeta(
          icon: Icons.pets_rounded,
          color: const Color(0xFF6A1B9A),
          bg: const Color(0xFFF3E5F5),
          label: 'Pet Ready',
        );
      case NotificationType.newService:
        return _NotifMeta(
          icon: Icons.new_releases_rounded,
          color: const Color(0xFF00695C),
          bg: const Color(0xFFE0F2F1),
          label: 'New Service',
        );
      case NotificationType.general:
        return _NotifMeta(
          icon: Icons.info_rounded,
          color: const Color(0xFF37474F),
          bg: const Color(0xFFECEFF1),
          label: 'Info',
        );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            _buildHeader(),

            // ── Filter Tabs (hidden for guests) ──────────────────────────
            if (!_isGuest) _buildFilterTabs(),

            if (!_isGuest) const SizedBox(height: 4),

            // ── Content ──────────────────────────────────────────────────
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            onPressed: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Text(
              'Notifications',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Mark all read',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Refresh',
            onPressed: _loadNotifications,
          ),
        ],
      ),
    );
  }

  // ── Filter tabs ───────────────────────────────────────────────────────────

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isActive: _filterIndex == 0,
            onTap: () => setState(() => _filterIndex = 0),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Unread${_unreadCount > 0 ? ' ($_unreadCount)' : ''}',
            isActive: _filterIndex == 1,
            onTap: () => setState(() => _filterIndex = 1),
          ),
        ],
      ),
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
          strokeWidth: 2,
        ),
      );
    }

    // ── Guest / not signed-in state ──────────────────────────────────────
    if (_isGuest) {
      return FadeTransition(
        opacity: _fadeAnim,
        child: _buildSignInPrompt(),
      );
    }

    final list = _filtered;

    if (list.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnim,
        child: _buildEmptyState(),
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: RefreshIndicator(
        color: Colors.black,
        onRefresh: _loadNotifications,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: list.length,
          separatorBuilder: (context, idx) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final notif = list[index];
            return _NotificationCard(
              notif: notif,
              meta: _meta(notif.type),
              timeAgo: _timeAgo(notif.createdAt),
              onTap: () => _markRead(notif),
            );
          },
        ),
      ),
    );
  }

  // ── Sign-in Prompt ────────────────────────────────────────────────────────

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                size: 50,
                color: Colors.black26,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Sign in to view notifications',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              'Stay up to date with your appointments,\nlab results, and clinic updates by signing in to your account.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: Colors.black45,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 32),

            // Sign-in button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginsignupPage(),
                    ),
                  ).then((_) {
                    // Re-check auth after returning from login
                    _loadNotifications();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Create account link
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginsignupPage(),
                  ),
                ).then((_) => _loadNotifications());
              },
              child: Text(
                'Don\'t have an account? Create one',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black45,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_rounded,
                size: 44,
                color: Colors.black26,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No notifications yet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You\'ll be notified about upcoming appointments,\nlab results, and updates from the clinic.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black38,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification Card ─────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationModel notif;
  final _NotifMeta meta;
  final String timeAgo;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notif,
    required this.meta,
    required this.timeAgo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead
                ? const Color(0xFFEEEEEE)
                : meta.color.withValues(alpha: 0.25),
            width: notif.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon container ──────────────────────────────────────
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: meta.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(meta.icon, color: meta.color, size: 22),
              ),
              const SizedBox(width: 12),

              // ── Text content ────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label + time row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: meta.bg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            meta.label,
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: meta.color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeAgo,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.black38,
                          ),
                        ),
                        if (!notif.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: meta.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      notif.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight:
                            notif.isRead ? FontWeight.w500 : FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Body
                    Text(
                      notif.body,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.black54,
                        height: 1.45,
                      ),
                    ),

                    // ── Appointment details chip (if any) ───────────────
                    if (notif.appointmentDateTime != null) ...[
                      const SizedBox(height: 8),
                      _AppointmentChip(notif: notif),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Appointment detail chip inside notification card ──────────────────────────

class _AppointmentChip extends StatelessWidget {
  final NotificationModel notif;
  const _AppointmentChip({required this.notif});

  String _fmtDt(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}  •  $h:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 11, color: Colors.black45),
          const SizedBox(width: 5),
          Text(
            _fmtDt(notif.appointmentDateTime!),
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (notif.pet != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.pets_rounded, size: 11, color: Colors.black38),
            const SizedBox(width: 4),
            Text(
              notif.pet!,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

// ── Notification metadata ─────────────────────────────────────────────────────

class _NotifMeta {
  final IconData icon;
  final Color color;
  final Color bg;
  final String label;

  const _NotifMeta({
    required this.icon,
    required this.color,
    required this.bg,
    required this.label,
  });
}
