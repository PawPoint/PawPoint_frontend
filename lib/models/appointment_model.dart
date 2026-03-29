class AppointmentModel {
  /// Firestore document ID — null before the appointment is saved
  final String? id;

  final String service;
  final String pet;
  final String doctor;
  final DateTime dateTime;

  /// 'scheduled' | 'approved' | 'completed' | 'cancelled'
  final String status;

  const AppointmentModel({
    this.id,
    required this.service,
    required this.pet,
    required this.doctor,
    required this.dateTime,
    this.status = 'scheduled',
  });

  // ── Serialisation ──────────────────────────────────────────────────────────

  /// Convert to a plain map for sending to the backend / Firestore.
  Map<String, dynamic> toMap() => {
        'service': service,
        'pet': pet,
        'doctor': doctor,
        // Store as ISO-8601 string so the backend / Firestore can parse it
        'dateTime': dateTime.toIso8601String(),
        'status': status,
      };

  /// Create from a Firestore document map.
  /// [id] is the Firestore document ID (passed separately).
  factory AppointmentModel.fromMap(String? id, Map<String, dynamic> map) {
    // dateTime may be stored as an ISO string or a Firestore Timestamp
    DateTime parsedDate;
    final raw = map['dateTime'];
    if (raw is String) {
      parsedDate = DateTime.parse(raw);
    } else if (raw != null) {
      // Firestore Timestamp — has a .toDate() method
      try {
        parsedDate = (raw as dynamic).toDate() as DateTime;
      } catch (_) {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    return AppointmentModel(
      id: id ?? map['id'] as String?,
      service: (map['service'] as String?) ?? '',
      pet: (map['pet'] as String?) ?? '',
      doctor: (map['doctor'] as String?) ?? '',
      dateTime: parsedDate,
      status: (map['status'] as String?) ?? 'scheduled',
    );
  }

  AppointmentModel copyWith({String? id, String? status}) => AppointmentModel(
        id: id ?? this.id,
        service: service,
        pet: pet,
        doctor: doctor,
        dateTime: dateTime,
        status: status ?? this.status,
      );
}
