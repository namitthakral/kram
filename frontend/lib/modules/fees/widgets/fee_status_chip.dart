import 'package:flutter/material.dart';

class FeeStatusChip extends StatelessWidget {
  const FeeStatusChip({required this.status, super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    Color textColor;

    switch (status.toUpperCase()) {
      case 'PAID':
        color = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'PARTIAL':
        color = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'OVERDUE':
        color = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case 'PENDING':
      default:
        color = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
