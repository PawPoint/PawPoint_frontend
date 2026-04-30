import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawpoint_mobileapp/models/appointment_model.dart';
import 'booking_confirmation_page.dart';

class MockPaymentGatewayPage extends StatefulWidget {
  final AppointmentModel appointment;
  final double amountToPay;

  const MockPaymentGatewayPage({
    super.key,
    required this.appointment,
    required this.amountToPay,
  });

  @override
  State<MockPaymentGatewayPage> createState() => _MockPaymentGatewayPageState();
}

class _MockPaymentGatewayPageState extends State<MockPaymentGatewayPage> {
  bool _isProcessing = false;

  Future<void> _simulatePayment() async {
    setState(() => _isProcessing = true);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationPage(appointment: widget.appointment),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPayPal = widget.appointment.paymentMethod == 'paypal_sandbox';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isProcessing ? _buildProcessingUI() : _buildGatewayUI(isPayPal),
      ),
    );
  }

  Widget _buildProcessingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.black),
          const SizedBox(height: 24),
          Text(
            'Processing Payment...',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Please do not close the app.',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayUI(bool isPayPal) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                isPayPal ? 'PayPal Sandbox' : 'Mock Payment Gateway',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Text(
                  'Amount to Pay',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
                Text(
                  '₱${widget.amountToPay.toInt()}',
                  style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          if (isPayPal) _buildPayPalUI() else _buildCardUI(),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _simulatePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPayPal ? const Color(0xFF0070BA) : Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Pay Now',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayPalUI() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF0070BA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded, size: 14, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                'paypal.com/sandbox/checkout',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              const Icon(Icons.more_vert_rounded, size: 16, color: Colors.white70),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo1.png', // Using your logo as the "Merchant" logo
                height: 40,
                errorBuilder: (_, _, _) => const Icon(Icons.pets, size: 40, color: Color(0xFF0070BA)),
              ),
              const SizedBox(height: 20),
              Text(
                'Pay with PayPal',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Log in to your PayPal account to complete your purchase of ₱${widget.amountToPay.toInt()} to PawPoint Clinic.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 24),
              _buildFakeInput('Email or mobile number', 'sb-buyer@example.com'),
              const SizedBox(height: 12),
              _buildFakeInput('Password', '••••••••', isObscure: true),
              const SizedBox(height: 20),
              Text(
                'Forgot password?',
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF0070BA), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFakeInput(String label, String value, {bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isObscure ? Colors.black : Colors.black87,
              letterSpacing: isObscure ? 2 : 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardUI() {
    return Column(
      children: [
        _buildTextField('Card Number', '#### #### #### ####'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Expiry Date', 'MM/YY')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('CVV', '###')),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
