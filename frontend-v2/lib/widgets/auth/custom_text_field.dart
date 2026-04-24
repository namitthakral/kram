import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final Widget? prefixIcon;
  final bool isPassword;
  final String? forgotPasswordText;
  final VoidCallback? onForgotPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.forgotPasswordText,
    this.onForgotPassword,
    this.controller,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row with forgot password link
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
              if (widget.forgotPasswordText != null)
                MouseRegion(
                  cursor: widget.onForgotPassword != null
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.basic,
                  child: GestureDetector(
                    onTap: widget.onForgotPassword,
                    child: Text(
                      widget.forgotPasswordText!.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Input field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.lavenderPlaceholder.withValues(alpha: 0.5),
          ),
          child: TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            obscureText: widget.isPassword ? _isObscured : false,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: AppColors.textMuted,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: AppColors.textMuted.withValues(alpha: 0.6),
              ),
              prefixIcon: widget.prefixIcon != null 
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: widget.prefixIcon,
                  )
                : null,
              suffixIcon: widget.isPassword 
                ? MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => setState(() => _isObscured = !_isObscured),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(
                          _isObscured 
                            ? Icons.visibility_off_outlined 
                            : Icons.visibility_outlined,
                          size: 16,
                          color: AppColors.textMuted.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  )
                : null,
              border: InputBorder.none,
              errorStyle: const TextStyle(height: 0), // Hide default error text
              contentPadding: EdgeInsets.only(
                left: widget.prefixIcon != null ? 48 : 16,
                right: widget.isPassword ? 48 : 16,
                top: 18,
                bottom: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}