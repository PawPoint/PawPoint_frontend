class AppointmentModel {
  final String service;
  final String pet;
  final String doctor;
  final DateTime dateTime;

  /// 'scheduled' | 'approved' | 'completed' | 'cancelled'
  final String status;

  const AppointmentModel({
    required this.service,
    required this.pet,
    required this.doctor,
    required this.dateTime,
    this.status = 'scheduled',
  });

  AppointmentModel copyWith({String? status}) => AppointmentModel(
    service: service,
    pet: pet,
    doctor: doctor,
    dateTime: dateTime,
    status: status ?? this.status,
  );
}
