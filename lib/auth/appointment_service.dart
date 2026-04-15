import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // <-- Added Firebase Auth
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

  /// Cancel an appointment
  Future<AppointmentModel> cancelAppointment({
    required String appointmentId,
  }) async {
    try {
      final token = await _getToken();

      final response = await http.put(
        Uri.parse('$_baseUrl/api/appointments/cancel/$appointmentId'), // <-- URL Updated
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // <-- Token attached!
        },
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