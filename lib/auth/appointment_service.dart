import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawpoint_mobileapp/models/appointment_model.dart';
import '../core/utils/error_handler.dart';

class AppointmentService {
  static const String _baseUrl = 'http://localhost:8000';

  // Helper function to grab the token
  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// Create a new appointment via backend API
  Future<AppointmentModel> createAppointment({
    required AppointmentModel appointment,
  }) async {
    try {
      final token = await _getToken();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/appointments'), // <-- URL Updated
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // <-- Token attached!
        },
        body: jsonEncode(appointment.toMap()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apptData = data['appointment'] as Map<String, dynamic>;
        return AppointmentModel.fromMap(apptData['id'], apptData);
      } else {
        throw Exception('Failed to create appointment: ${response.body}');
      }
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  /// Fetch all appointments for a user
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/api/appointments'), // <-- URL Updated
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // <-- Token attached!
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final list = data['appointments'] as List;
          return list.map((e) {
            return AppointmentModel.fromMap(
              e['id'] as String,
              Map<String, dynamic>.from(e),
            );
          }).toList();
        } catch (parseError) {
          throw Exception('Failed to parse appointments response: $parseError');
        }
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  /// Cancel an appointment — returns refund outcome alongside the updated appointment.
  Future<CancelResult> cancelAppointment({
    required String appointmentId,
  }) async {
    try {
      final token = await _getToken();

      final response = await http.put(
        Uri.parse('$_baseUrl/api/appointments/cancel/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apptData = data['appointment'] as Map<String, dynamic>;
        return CancelResult(
          appointment: AppointmentModel.fromMap(apptData['id'], apptData),
          refundStatus: apptData['refundStatus'] as String? ?? 'unknown',
          refundAmount: (apptData['refundAmount'] as num?)?.toDouble() ?? 0.0,
        );
      } else {
        throw Exception('Failed to cancel appointment');
      }
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  /// Reschedule a pending appointment to a new date/time.
  Future<AppointmentModel> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDateTime,
  }) async {
    try {
      final token = await _getToken();

      final response = await http.put(
        Uri.parse('$_baseUrl/api/appointments/reschedule/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'new_datetime': newDateTime.toIso8601String()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apptData = data['appointment'] as Map<String, dynamic>;
        return AppointmentModel.fromMap(apptData['id'], apptData);
      } else {
        final detail = jsonDecode(response.body)['detail'] ?? 'Failed to reschedule';
        throw Exception(detail);
      }
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  /// Accept the clinic's proposed reschedule → status becomes approved.
  Future<AppointmentModel> acceptReschedule({
    required String appointmentId,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/api/appointments/accept-reschedule/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apptData = data['appointment'] as Map<String, dynamic>;
        return AppointmentModel.fromMap(apptData['id'], apptData);
      } else {
        final detail = jsonDecode(response.body)['detail'] ?? 'Failed to accept reschedule';
        throw Exception(detail);
      }
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  /// Decline the clinic's proposed reschedule → cancels and processes full refund.
  Future<CancelResult> declineReschedule({
    required String appointmentId,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/api/appointments/decline-reschedule/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apptData = data['appointment'] as Map<String, dynamic>;
        return CancelResult(
          appointment: AppointmentModel.fromMap(apptData['id'], apptData),
          refundStatus: apptData['refundStatus'] as String? ?? 'unknown',
          refundAmount: (apptData['refundAmount'] as num?)?.toDouble() ?? 0.0,
        );
      } else {
        final detail = jsonDecode(response.body)['detail'] ?? 'Failed to decline reschedule';
        throw Exception(detail);
      }
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }
}

/// Holds the result of a cancellation request.
class CancelResult {
  final AppointmentModel appointment;
  final String refundStatus;
  final double refundAmount;

  const CancelResult({
    required this.appointment,
    required this.refundStatus,
    required this.refundAmount,
  });

  /// Human-readable snackbar message based on the refund outcome.
  String get snackbarMessage {
    switch (refundStatus) {
      case 'refunded':
        return 'Appointment cancelled. A full refund of ₱${refundAmount.toInt()} has been initiated. 💳';
      case 'refund_pending':
        return 'Appointment cancelled. Your refund of ₱${refundAmount.toInt()} is being processed. 🔄';
      case 'forfeited':
        return 'Appointment cancelled. Downpayment is non-refundable (appointment was approved). 🐾';
      case 'refund_not_needed':
        return 'Appointment cancelled successfully 🐾';
      default:
        return 'Appointment cancelled successfully 🐾';
    }
  }

  Color get snackbarColor {
    switch (refundStatus) {
      case 'refunded':
        return const Color(0xFF2E7D32);
      case 'refund_pending':
        return const Color(0xFF1565C0);
      case 'forfeited':
        return const Color(0xFFC62828);
      default:
        return Colors.black;
    }
  }
}