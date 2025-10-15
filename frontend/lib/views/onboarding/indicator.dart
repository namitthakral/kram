import 'package:flutter/material.dart';

import '../../utils/custom_colors.dart';

class IndicatorWidget extends StatelessWidget {
  const IndicatorWidget({
    required this.length,
    required this.selectedIndex,
    super.key,
  });
  final int length;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: const Offset(0, -20),
    child: SizedBox(
      height: 6,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: length,
        itemBuilder:
            (context, index) => CircleAvatar(
              radius: 7,
              backgroundColor:
                  selectedIndex == index
                      ? CustomAppColors.primary
                      : CustomAppColors.grey01,
            ),
      ),
    ),
  );
}
