import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    required this.text,
    required this.onPressed,
    this.borderRadius = 12.0,
    super.key,
  });
  final String text;
  final VoidCallback onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 32.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      fixedSize: Size(MediaQuery.sizeOf(context).width, 48.0),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
    ),
  );
}
