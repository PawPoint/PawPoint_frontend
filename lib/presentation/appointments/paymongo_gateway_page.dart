import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:pawpoint_mobileapp/models/appointment_model.dart';
import 'booking_confirmation_page.dart';

class PayMongoGatewayPage extends StatefulWidget {
  final AppointmentModel appointment;
  final double amountToPay;

  const PayMongoGatewayPage({
    super.key,
    required this.appointment,
    required this.amountToPay,
  });

  @override
  State<PayMongoGatewayPage> createState() => _PayMongoGatewayPageState();
}

class _PayMongoGatewayPageState extends State<PayMongoGatewayPage> {
  bool _isLoading = true;
  bool _isVerifying = false;
  String? _checkoutUrl;
  String? _sessionId;       
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCheckoutUrl();
  }

  Future<void> _fetchCheckoutUrl() async {
    try {
      final String baseUrl = kIsWeb || !defaultTargetPlatform.toString().toLowerCase().contains('android') 
          ? 'http://localhost:8000' 
          : 'http://10.0.2.2:8000';

      final response = await http.post(
        Uri.parse('$baseUrl/payments/create-checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': widget.amountToPay,
          'service_name': widget.appointment.service,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _checkoutUrl = data['checkout_url'];
          _sessionId = data['session_id'];   
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Backend error: ${response.body}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _launchPayMongo() async {
    if (_checkoutUrl == null) return;
    
    final uri = Uri.parse(_checkoutUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      _showReturnPrompt();
    }
  }

  void _showReturnPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Payment Verification', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isVerifying 
                    ? 'Checking payment status with PayMongo...' 
                    : 'Did you complete the payment in the browser?',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                if (_isVerifying) ...[
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: Colors.black),
                ]
              ],
            ),
            actions: [
              if (!_isVerifying)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Not Yet', style: GoogleFonts.poppins(color: Colors.black54)),
                ),
              if (!_isVerifying)
                ElevatedButton(
                  onPressed: () async {
                    setModalState(() => _isVerifying = true);
                    bool paid = await _verifyPayment();
                    setModalState(() => _isVerifying = false);
                    
                    if (paid) {
                      if (context.mounted) Navigator.pop(ctx);
                      _completeBooking();
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment not yet detected. Please finish payment in the browser.')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Text('Verify & Finish', style: GoogleFonts.poppins(color: Colors.white)),
                ),
            ],
          );
        }
      ),
    );
  }

  Future<bool> _verifyPayment() async {
    if (_sessionId == null) return false;
    
    try {
      final String baseUrl = kIsWeb || !defaultTargetPlatform.toString().toLowerCase().contains('android') 
          ? 'http://localhost:8000' 
          : 'http://10.0.2.2:8000';

      final response = await http.get(
        Uri.parse('$baseUrl/payments/verify-checkout/$_sessionId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['paid'] == true;
      }
    } catch (e) {
      debugPrint("Verification error: $e");
    }
    return false;
  }

  void _completeBooking() {
    final apptWithSession = _sessionId != null
        ? widget.appointment.copyWith(checkoutSessionId: _sessionId)
        : widget.appointment;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmationPage(appointment: apptWithSession),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('PayMongo Checkout', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet_rounded, size: 64, color: Color(0xFF4F46E5)),
              const SizedBox(height: 24),
              Text(
                'Ready to Secure Your Booking',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap the button below to open the secure PayMongo sandbox payment page. You can use GCash, Maya, or Test Cards there.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.black)
              else if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center)
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _launchPayMongo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Open PayMongo Sandbox',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
