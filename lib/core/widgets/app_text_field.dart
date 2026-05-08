import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? helperText;
  final bool isRounded;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.helperText,
    this.isRounded = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(widget.isRounded ? 16 : 50),
        border: !widget.isRounded ? Border.all(color: Colors.black) : null,
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _isObscured,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: widget.hint,
          helperText: widget.helperText,
          hintStyle: AppTextStyles.hint,
          helperStyle: AppTextStyles.hint.copyWith(fontSize: 11),
          prefixIcon: widget.prefixIcon != null 
              ? Icon(widget.prefixIcon, size: 20, color: AppColors.grey) 
              : null,
          suffixIcon: widget.obscureText 
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : widget.suffixIcon,
          border: widget.isRounded ? InputBorder.none : OutlineInputBorder(
            borderRadius: BorderRadius.circular(55),
            borderSide: const BorderSide(color: Colors.black),
          ),
          enabledBorder: widget.isRounded ? InputBorder.none : OutlineInputBorder(
            borderRadius: BorderRadius.circular(55),
            borderSide: const BorderSide(color: Colors.black),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}
