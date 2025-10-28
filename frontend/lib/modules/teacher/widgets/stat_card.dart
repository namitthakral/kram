import 'package:flutter/material.dart';

import '../../../utils/custom_colors.dart';
import '../../../utils/responsive_utils.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    super.key,
  });
  final String title;
  final String value;
  final String subtitle;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return DecoratedBox(
      // padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: backgroundColor.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(40),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.all(isMobile ? 8 : 10),
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: CustomAppColors.white,
                        size: isMobile ? 16 : 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 36,
                    fontWeight: FontWeight.bold,
                    color: backgroundColor,
                    // color: const Color(0xFF1e293b),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    color: const Color(0xFF64748b),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
