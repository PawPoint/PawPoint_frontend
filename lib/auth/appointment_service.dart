import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pawpoint_mobileapp/models/appointment_model.dart';
import 'package:flutter/material.dart';
import '../core/utils/error_handler.dart';

class AppointmentService {
  static const String _baseUrl = 'http://localhost:8000';

  /// Create a new appointment via backend API
  Future<AppointmentModel> createAppointment({
    required String userId,
    required AppointmentModel appointment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/appointments/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(appointment.toMap()),
      );

      debugPrint('[AppointmentService] createAppointment status: ${response.statusCode}');
      debugPrint('[AppointmentService] createAppointment body: ${response.body}');

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
  Future<List<AppointmentModel>> getAppointments({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/appointments/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('[AppointmentService] getAppointments status: ${response.statusCode}');
      debugPrint('[AppointmentService] getAppointments body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final list = data['appointments'] as List;
          debugPrint('[AppointmentService] Parsing ${list.length} appointment(s)');
          return list
              .map((e) {
                debugPrint('[AppointmentService] Parsing entry: $e');
                return AppointmentModel.fromMap(
                  e['id'] as String,
                  Map<String, dynamic>.from(e),
                );
              })
              .toList();
        } catch (parseError) {
          debugPrint('[AppointmentService] PARSE ERROR: $parseError');
          throw Exception('Failed to parse appointments response: $parseError');
        }
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  /// Cancel an appointment
  Future<AppointmentModel> cancelAppointment({
    required String userId,
    required String appointmentId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/appointments/$userId/cancel/$appointmentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final apptData = data['appointment'] as Map<String, dynamic>;
        return AppointmentModel.fromMap(apptData['id'], apptData);
      } else {
        throw Exception('Failed to cancel appointment');
      }
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }
}
