import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class SsoButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onPressed;

  const SsoButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.cardBackground,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          mouseCursor: onPressed != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 8),
                Text(
                  text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}