import 'package:flutter/material.dart';

import '../../utils/custom_colors.dart';

class CustomCircleButton extends StatelessWidget {
  const CustomCircleButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.color = CustomAppColors.grey01,
    this.iconColor = CustomAppColors.white,
  });
  final VoidCallback onPressed;
  final Color color, iconColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 30,
    width: 30,
    child: MaterialButton(
      onPressed: onPressed,
      color: color,
      elevation: 0,
      padding: EdgeInsets.zero,
      shape: const CircleBorder(),
      child: Icon(icon, size: 16, color: iconColor),
    ),
  );
}
