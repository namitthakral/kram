import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    required this.text,
    required this.onPressed,
    this.borderRadius = 12.0,
    this.isLoading = false,
    this.color,
    this.icon,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final double borderRadius;
  final bool isLoading;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Theme.of(context).colorScheme.primary;

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: buttonColor,
        side: BorderSide(
          color: buttonColor,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        minimumSize: Size(MediaQuery.sizeOf(context).width, 48.0),
      ),
      icon: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
              ),
            )
          : icon != null
              ? Icon(icon, size: 20)
              : const SizedBox.shrink(),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: AppTheme.fontSizeBase,
          fontWeight: AppTheme.fontWeightSemibold,
        ),
      ),
    );
  }
}
