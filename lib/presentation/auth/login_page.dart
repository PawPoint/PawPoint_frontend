import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/dashboard_page.dart';
import '../../../../auth/auth_service.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/error_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const AppLogo(width: 250),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const Spacer(),
              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  AppTextField(
                    controller: _emailController,
                    hint: "Email",
                    isRounded: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  Positioned(
                    bottom: -30,
                    child: Image.asset(
                      "assets/images/c1.png",
                      width: 350,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              AppTextField(
                controller: _passwordController,
                hint: "Password",
                obscureText: true,
                isRounded: false,
              ),
              const SizedBox(height: 40),
              AppButton(
                text: "LOGIN",
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _showForgotPasswordDialog,
                child: const Text(
                  "Forgot your password?",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      _showErrorSnackBar(emailError);
      return;
    }

    final passwordError = Validators.validateRequired(password, "Password");
    if (passwordError != null) {
      _showErrorSnackBar(passwordError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService().login(
        email: email,
        password: password,
      );

      if (mounted && user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(ErrorHandler.getErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    bool isSending = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Reset Password',
            style: AppTextStyles.h1.copyWith(fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(fontSize: 13.5, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: emailController,
                hint: "Email address",
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.black45)),
            ),
            AppButton(
              text: 'Send Reset Link',
              isLoading: isSending,
              height: 40,
              width: 150,
              hasShadow: false,
              onPressed: () async {
                final email = emailController.text.trim();
                final emailError = Validators.validateEmail(email);
                if (emailError != null) {
                  _showErrorSnackBar(emailError);
                  return;
                }
                setDialogState(() => isSending = true);
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reset link sent to $email. Check your inbox!'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  setDialogState(() => isSending = false);
                  if (mounted) _showErrorSnackBar(ErrorHandler.getErrorMessage(e));
                }
              },
            ),
          ],
        ),
      ),
    );

    emailController.dispose();
  }
}
