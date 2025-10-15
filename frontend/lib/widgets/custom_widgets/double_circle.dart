import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/theme_provider.dart';
import '../../utils/images/base_image.dart';
import '../../utils/images/image_asset.dart';

class DoubleCircle extends StatelessWidget {
  const DoubleCircle({required this.url, super.key, this.color});
  final Color? color;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeProvider>().themeData;

    return CircleAvatar(
      radius: 65,
      backgroundColor: (color ?? theme.colorScheme.primary).withValues(
        alpha: 0.1,
      ),
      child: CircleAvatar(
        radius: 45,
        backgroundColor: color ?? theme.colorScheme.primary,
        child: BaseImage(
          asset: LocalAsset(url: url!),
          width: 36,
          height: 36,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
