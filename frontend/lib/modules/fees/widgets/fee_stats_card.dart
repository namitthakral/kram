import 'package:flutter/material.dart';
import '../../../utils/app_styles.dart';

class FeeStatsCard extends StatelessWidget {
  final String title;
  final double? amount;
  final String? value;
  final Color color;
  final IconData icon;
  final bool isCurrency;

  const FeeStatsCard({
    super.key,
    required this.title,
    this.amount,
    this.value,
    required this.color,
    required this.icon,
    this.isCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue =
        isCurrency
            ? '₹${amount?.toStringAsFixed(2) ?? "0.00"}'
            : (value ?? "0");

    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(icon, color: color, size: 20)],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: AppStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
