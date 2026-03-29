import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome_page.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;

  // One controller + focus node per OTP digit
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isVerifying = false;
  bool _canResend = false;
  int _resendCooldown = 30;
  Timer? _timer;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    // Send verification email on page load
    _sendVerificationEmail();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String get _enteredOtp => _otpControllers.map((c) => c.text).join();

  void _startResendTimer() {
    _resendCooldown = 30;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_resendCooldown > 1) {
          _resendCooldown--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (_) {
      // Silently ignore — user can always resend
    }
  }

  Future<void> _handleVerify() async {
    if (_enteredOtp.length < 4) {
      _showSnack('Please enter the 4-digit code from your email.');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      // Reload user to get latest emailVerified status
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => WelcomePage()),
        );
      } else {
        _showSnack(
          'Email not verified yet. Please check your inbox and click the link, then tap Verify.',
        );
      }
    } catch (e) {
      _showSnack('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;
    await _sendVerificationEmail();
    _startResendTimer();
    _showSnack('Verification email resent! Check your inbox.', isError: false);
  }

  void _showSnack(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final userEmail = _auth.currentUser?.email ?? 'your email';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Decorative blobs ──────────────────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF0F0F0),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8E8E8),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // ── Top bar ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 14,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(
                                Icons.chevron_left_rounded,
                                size: 28,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Image.asset(
                            'assets/images/logo1.png',
                            height: 26,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),

                            // ── Illustration ────────────────────────
                            Image.asset(
                              'assets/images/forgotpassicon.png',
                              height: 200,
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(height: 24),

                            // ── Title ───────────────────────────────
                            Text(
                              'Verify Your Email',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // ── Subtitle ────────────────────────────
                            Text(
                              'We sent a verification link to',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Click the link in your email, then enter\nthe 4-digit code below.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color: Colors.black38,
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 36),

                            // ── OTP boxes ───────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                4,
                                (i) => _OtpBox(
                                  controller: _otpControllers[i],
                                  focusNode: _focusNodes[i],
                                  onChanged: (val) {
                                    if (val.length == 1 && i < 3) {
                                      _focusNodes[i + 1].requestFocus();
                                    } else if (val.isEmpty && i > 0) {
                                      _focusNodes[i - 1].requestFocus();
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 36),

                            // ── Verify button ────────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _isVerifying ? null : _handleVerify,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.black
                                      .withOpacity(0.3),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: _isVerifying
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        'Verify Email',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Resend ───────────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Didn't receive it? ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    color: Colors.black38,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _canResend ? _handleResend : null,
                                  child: Text(
                                    _canResend
                                        ? 'Resend'
                                        : 'Resend in ${_resendCooldown}s',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: _canResend
                                          ? Colors.black
                                          : Colors.black26,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── OTP Box Widget ────────────────────────────────────────────────────────────
class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  @override
  void initState() {
    super.initState();
    // Rebuild whenever focus changes so the border highlight updates
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool focused = widget.focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 64,
      height: 68,
      decoration: BoxDecoration(
        color: focused ? Colors.white : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused ? Colors.black87 : const Color(0xFFE0E0E0),
          width: focused ? 2 : 1.5,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
