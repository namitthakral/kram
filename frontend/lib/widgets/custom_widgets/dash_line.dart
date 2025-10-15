import 'package:flutter/material.dart';

import '../../utils/custom_colors.dart';

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 5, startX = 0;
    final paint =
        Paint()
          ..color = CustomAppColors.grey03
          ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DashLine extends StatelessWidget {
  const DashLine({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: CustomPaint(painter: _DashedLinePainter()),
  );
}
