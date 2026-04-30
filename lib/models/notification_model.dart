/// Represents a single in-app notification for the client.
class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;

  /// Optional fields used for appointment-related notifs
  final String? appointmentId;
  final String? service;
  final String? pet;
  final String? doctor;
  final DateTime? appointmentDateTime;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.appointmentId,
    this.service,
    this.pet,
    this.doctor,
    this.appointmentDateTime,
  });

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        appointmentId: appointmentId,
        service: service,
        pet: pet,
        doctor: doctor,
        appointmentDateTime: appointmentDateTime,
      );

  /// Serialise to Firestore-friendly map
  Map<String, dynamic> toMap() => {
        'type': type.name,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
        'appointmentId': appointmentId,
        'service': service,
        'pet': pet,
        'doctor': doctor,
        'appointmentDateTime': appointmentDateTime?.toIso8601String(),
      };

  factory NotificationModel.fromMap(String docId, Map<String, dynamic> data) {
    return NotificationModel(
      id: docId,
      type: _parseType(data['type'] as String? ?? 'general'),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: DateTime.parse(
        data['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      isRead: data['isRead'] as bool? ?? false,
      appointmentId: data['appointmentId'] as String?,
      service: data['service'] as String?,
      pet: data['pet'] as String?,
      doctor: data['doctor'] as String?,
      appointmentDateTime: data['appointmentDateTime'] != null
          ? DateTime.parse(data['appointmentDateTime'] as String)
          : null,
    );
  }

  static NotificationType _parseType(String raw) {
    return NotificationType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => NotificationType.general,
    );
  }
}

enum NotificationType {
  appointmentReminder,
  appointmentApproved,
  appointmentCancelled,
  vetCancelled,
  rescheduleProposed,    // clinic proposed a new time
  labResults,
  petReady,
  newService,
  general,
}
