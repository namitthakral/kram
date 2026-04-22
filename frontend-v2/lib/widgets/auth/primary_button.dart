import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? suffixIcon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.primaryPurple,
            AppColors.primaryPurpleLight,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          mouseCursor: (isLoading || onPressed == null)
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else ...[
                  Text(
                    text,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    suffixIcon!,
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}