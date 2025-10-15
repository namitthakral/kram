import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/theme_provider.dart';
import '../../utils/extensions.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    required this.onButtonPressed,
    required this.text,
    super.key,
    this.color,
    this.textStyle,
  });
  final void Function()? onButtonPressed;
  final String text;
  final Color? color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final themeData = Provider.of<ThemeProvider>(context).themeData;

    return TextButton(
      onPressed: onButtonPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        overlayColor: Colors.transparent,
      ),
      child: Text(
        text,
        style: (textStyle ?? context.textTheme.bodyXs).copyWith(
          color: color ?? themeData.primaryColor,
        ),
      ),
    );
  }
}
