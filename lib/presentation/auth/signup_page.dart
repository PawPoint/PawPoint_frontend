import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'verify_page.dart';
import 'package:pawpoint_mobileapp/auth/auth_service.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/error_handler.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String get _fullPhone => '+63${_phoneController.text.trim()}';

  void _showSnack(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.body.copyWith(fontSize: 13)),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validations using Validators utility
    final nameError = Validators.validateRequired(name, "Full Name");
    if (nameError != null) { _showSnack(nameError); return; }

    final phoneError = Validators.validatePhone(phone);
    if (phoneError != null) { _showSnack(phoneError); return; }

    final emailError = Validators.validateEmail(email);
    if (emailError != null) { _showSnack(emailError); return; }

    final addressError = Validators.validateRequired(address, "Home Address");
    if (addressError != null) { _showSnack(addressError); return; }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) { _showSnack(passwordError); return; }

    if (password != confirmPassword) {
      _showSnack('Passwords do not match!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService().signUp(
        email: email,
        password: password,
        name: name,
        phone: _fullPhone,
        address: address,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VerifyPage()),
        );
      } else {
        _showSnack('Registration failed. Please try again.');
      }
    } catch (e) {
      _showSnack(ErrorHandler.getErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF0F0F0),
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
                          const AppLogo(assetName: 'assets/images/logo1.png', width: 100),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text('Create Account', style: AppTextStyles.h1),
                            const SizedBox(height: 4),
                            Text(
                              'Fill in the details below to get started. 🐾',
                              style: AppTextStyles.hint,
                            ),
                            const SizedBox(height: 28),
                            _sectionLabel('Personal Info'),
                            const SizedBox(height: 10),
                            AppTextField(
                              controller: _nameController,
                              hint: 'Full Name',
                              prefixIcon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(height: 12),
                            _buildPhoneField(),
                            const SizedBox(height: 12),
                            AppTextField(
                              controller: _emailController,
                              hint: 'Email Address',
                              prefixIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              controller: _addressController,
                              hint: 'Home Address',
                              prefixIcon: Icons.location_on_outlined,
                            ),
                            const SizedBox(height: 24),
                            _sectionLabel('Security'),
                            const SizedBox(height: 10),
                            AppTextField(
                              controller: _passwordController,
                              hint: 'Password',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              helperText: 'Must be at least 8 characters',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppColors.grey,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              controller: _confirmPasswordController,
                              hint: 'Confirm Password',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscureConfirm,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppColors.grey,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            AppButton(
                              text: 'Create Account',
                              isLoading: _isLoading,
                              onPressed: _handleRegister,
                              height: 54,
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                'Already have an account? Log in instead.',
                                style: AppTextStyles.hint.copyWith(fontSize: 11.5),
                              ),
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

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+63',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'Phone Number (10 digits)',
                hintStyle: AppTextStyles.hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.body.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.black45,
        letterSpacing: 0.8,
      ),
    );
  }
}
