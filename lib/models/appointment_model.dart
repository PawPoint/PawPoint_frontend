class AppointmentModel {
  /// Firestore document ID — null before the appointment is saved
  final String? id;

  final String service;
  final String pet;
  final String doctor;
  final DateTime dateTime;

  /// 'scheduled' | 'approved' | 'completed' | 'cancelled'
  final String status;

  // ── Payment Fields ────────────────────────────────────────────────────────
  final double totalPrice;
  final double amountPaidOnline;
  final double balanceRemaining;
  final String paymentStatus; // 'fully_paid', 'partially_paid', 'unpaid'
  final String paymentMethod; // 'online'
  final String checkoutSessionId; // PayMongo checkout session ID — needed for refunds
  final String proposedDateTime;   // set when status == reschedule_proposed

  const AppointmentModel({
    this.id,
    required this.service,
    required this.pet,
    required this.doctor,
    required this.dateTime,
    this.status = 'scheduled',
    this.totalPrice = 0.0,
    this.amountPaidOnline = 0.0,
    this.balanceRemaining = 0.0,
    this.paymentStatus = 'unpaid',
    this.paymentMethod = '',
    this.checkoutSessionId = '',
    this.proposedDateTime = '',
  });

  // ── Serialisation ──────────────────────────────────────────────────────────

  /// Convert to a plain map for sending to the backend / Firestore.
  Map<String, dynamic> toMap() => {
        'service': service,
        'pet': pet,
        'doctor': doctor,
        'dateTime': dateTime.toIso8601String(),
        'status': status,
        'totalPrice': totalPrice,
        'amountPaidOnline': amountPaidOnline,
        'balanceRemaining': balanceRemaining,
        'paymentStatus': paymentStatus,
        'paymentMethod': paymentMethod,
        'checkoutSessionId': checkoutSessionId,
        'proposedDateTime': proposedDateTime,
      };

  /// Create from a Firestore document map.
  factory AppointmentModel.fromMap(String? id, Map<String, dynamic> map) {
    DateTime parsedDate;
    final raw = map['dateTime'];
    if (raw is String) {
      parsedDate = DateTime.parse(raw);
    } else if (raw != null) {
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
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      amountPaidOnline: (map['amountPaidOnline'] as num?)?.toDouble() ?? 0.0,
      balanceRemaining: (map['balanceRemaining'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: (map['paymentStatus'] as String?) ?? 'unpaid',
      paymentMethod: (map['paymentMethod'] as String?) ?? '',
      checkoutSessionId: (map['checkoutSessionId'] as String?) ?? '',
      proposedDateTime: (map['proposedDateTime'] as String?) ?? '',
    );
  }

  AppointmentModel copyWith({
    String? id,
    String? status,
    double? totalPrice,
    double? amountPaidOnline,
    double? balanceRemaining,
    String? paymentStatus,
    String? paymentMethod,
    String? checkoutSessionId,
    String? proposedDateTime,
  }) =>
      AppointmentModel(
        id: id ?? this.id,
        service: service,
        pet: pet,
        doctor: doctor,
        dateTime: dateTime,
        status: status ?? this.status,
        totalPrice: totalPrice ?? this.totalPrice,
        amountPaidOnline: amountPaidOnline ?? this.amountPaidOnline,
        balanceRemaining: balanceRemaining ?? this.balanceRemaining,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        checkoutSessionId: checkoutSessionId ?? this.checkoutSessionId,
        proposedDateTime: proposedDateTime ?? this.proposedDateTime,
      );
}
