import 'package:flutter/material.dart';

import 'extensions.dart';
import 'global_constants.dart';

enum SnackbarType { success, warning /* error, warning, info */ }

void showCustomSnackbar({required String message, required SnackbarType type}) {
  Color backgroundColor;
  Color textColor;
  IconData icon;

  switch (type) {
    case SnackbarType.success:
      backgroundColor = const Color(0xFFE1FFF1);
      textColor = const Color(0xFF00D261);
      icon = Icons.check_circle;
      break;
    // case SnackbarType.error:
    //   backgroundColor = Colors.red.shade100;
    //   textColor = Colors.red.shade800;
    //   icon = Icons.error;
    //   break;
    case SnackbarType.warning:
      backgroundColor = const Color(0xFFFFF8E9);
      textColor = const Color(0xFFE68C00);
      icon = Icons.warning_amber_rounded;
      break;
  }

  final snackBar = SnackBar(
    content: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(icon, color: textColor),
        ),
        Expanded(
          child: Text(
            message,
            style: GlobalConstants.snackbarKey.currentContext?.textTheme.bodySm
                .copyWith(color: textColor),
          ),
        ),
      ],
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 3),
  );

  // Use global snackbar key instead of context
  GlobalConstants.snackbarKey.currentState?.showSnackBar(snackBar);
}
