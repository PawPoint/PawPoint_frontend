import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawpoint_mobileapp/models/appointment_model.dart';
import 'package:pawpoint_mobileapp/models/notification_model.dart';

/// Generates and persists in-app notifications for a client.
///
/// Notification sources:
///  1. Upcoming appointment reminders (within 48 h)
///  2. Appointment status transitions (approved / cancelled / completed →
///     lab results or pet-ready)
///  3. New services pushed by admin
class NotificationService {
  final _db = FirebaseFirestore.instance;

  // ── Collection helpers ────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _notifCol(String userId) =>
      _db.collection('users').doc(userId).collection('notifications');

  // ── Fetch persisted notifications ─────────────────────────────────────────

  Future<List<NotificationModel>> getNotifications({
    required String userId,
  }) async {
    final snap = await _notifCol(userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snap.docs
        .map((d) => NotificationModel.fromMap(d.id, d.data()))
        .toList();
  }

  // ── Mark one as read ──────────────────────────────────────────────────────

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    await _notifCol(userId).doc(notificationId).update({'isRead': true});
  }

  // ── Mark all as read ──────────────────────────────────────────────────────

  Future<void> markAllAsRead({required String userId}) async {
    final batch = _db.batch();
    final snap =
        await _notifCol(userId).where('isRead', isEqualTo: false).get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ── Derive & persist notifications from appointment list ──────────────────
  ///
  /// Call this after loading the appointments list. It will create new
  /// Firestore notification documents only for ones that don't exist yet
  /// (keyed by a deterministic ID so we never duplicate).

  Future<void> syncAppointmentNotifications({
    required String userId,
    required List<AppointmentModel> appointments,
  }) async {
    final now = DateTime.now();

    for (final appt in appointments) {
      if (appt.id == null) continue;

      final hoursUntil = appt.dateTime.difference(now).inHours;

      // ── 1. Upcoming reminder (24-48h window) ──────────────────────────────
      if ((appt.status == 'pending' ||
              appt.status == 'scheduled' ||
              appt.status == 'approved') &&
          hoursUntil >= 0 &&
          hoursUntil <= 48) {
        await _upsertNotification(
          userId: userId,
          notifId: 'reminder_${appt.id}',
          model: NotificationModel(
            id: 'reminder_${appt.id}',
            type: NotificationType.appointmentReminder,
            title: 'Upcoming Appointment 🐾',
            body:
                'Your ${appt.service} for ${appt.pet} with ${appt.doctor} is on '
                '${_fmtDateTime(appt.dateTime)}.',
            createdAt: now,
            appointmentId: appt.id,
            service: appt.service,
            pet: appt.pet,
            doctor: appt.doctor,
            appointmentDateTime: appt.dateTime,
          ),
        );
      }

      // ── 2. Approved notification ───────────────────────────────────────────
      if (appt.status == 'approved') {
        await _upsertNotification(
          userId: userId,
          notifId: 'approved_${appt.id}',
          model: NotificationModel(
            id: 'approved_${appt.id}',
            type: NotificationType.appointmentApproved,
            title: 'Appointment Approved ✅',
            body:
                'Your ${appt.service} appointment for ${appt.pet} on '
                '${_fmtDateTime(appt.dateTime)} has been approved!',
            createdAt: now,
            appointmentId: appt.id,
            service: appt.service,
            pet: appt.pet,
            doctor: appt.doctor,
            appointmentDateTime: appt.dateTime,
          ),
        );
      }

      // ── 3. Completed → possible lab results / pet ready ───────────────────
      if (appt.status == 'completed') {
        // Lab result notification for diagnostic services
        final diagServices = [
          'Diagnostics',
          'Lab Tests',
          'X-Ray',
          'Blood Work',
          'Urinalysis',
        ];
        final isLabService = diagServices
            .any((s) => appt.service.toLowerCase().contains(s.toLowerCase()));

        if (isLabService) {
          await _upsertNotification(
            userId: userId,
            notifId: 'labresult_${appt.id}',
            model: NotificationModel(
              id: 'labresult_${appt.id}',
              type: NotificationType.labResults,
              title: 'Lab Results Ready 🔬',
              body:
                  'Results for ${appt.pet}\'s ${appt.service} are now available. '
                  'Please visit the clinic or contact us for more details.',
              createdAt: now,
              appointmentId: appt.id,
              service: appt.service,
              pet: appt.pet,
              doctor: appt.doctor,
              appointmentDateTime: appt.dateTime,
            ),
          );
        } else {
          // General pet-ready notification
          await _upsertNotification(
            userId: userId,
            notifId: 'petready_${appt.id}',
            model: NotificationModel(
              id: 'petready_${appt.id}',
              type: NotificationType.petReady,
              title: '${appt.pet} is Ready for Pick-up! 🐕',
              body:
                  'The ${appt.service} session for ${appt.pet} is done. '
                  'Your pet is ready for pick-up at the clinic!',
              createdAt: now,
              appointmentId: appt.id,
              service: appt.service,
              pet: appt.pet,
              doctor: appt.doctor,
              appointmentDateTime: appt.dateTime,
            ),
          );
        }
      }

      // ── 4. Cancelled notification ─────────────────────────────────────────
      if (appt.status == 'cancelled') {
        await _upsertNotification(
          userId: userId,
          notifId: 'cancelled_${appt.id}',
          model: NotificationModel(
            id: 'cancelled_${appt.id}',
            type: NotificationType.appointmentCancelled,
            title: 'Appointment Cancelled',
            body:
                'Your ${appt.service} appointment for ${appt.pet} on '
                '${_fmtDateTime(appt.dateTime)} has been cancelled.',
            createdAt: now,
            appointmentId: appt.id,
            service: appt.service,
            pet: appt.pet,
            doctor: appt.doctor,
            appointmentDateTime: appt.dateTime,
          ),
        );
      }
    }
  }

  // ── Fetch admin-pushed "new service" notifications ────────────────────────
  /// Admin publishes docs to `admin_notifications` collection in Firestore.

  Future<List<NotificationModel>> getNewServiceNotifications() async {
    try {
      final snap = await _db
          .collection('admin_notifications')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snap.docs
          .map((d) => NotificationModel.fromMap(d.id, d.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Helper: upsert so we never duplicate ─────────────────────────────────

  Future<void> _upsertNotification({
    required String userId,
    required String notifId,
    required NotificationModel model,
  }) async {
    final ref = _notifCol(userId).doc(notifId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set(model.toMap());
    }
  }

  // ── Date formatter ────────────────────────────────────────────────────────

  String _fmtDateTime(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day} at $h:$min $period';
  }
}
