import 'package:flutter/material.dart';

import 'custom_colors.dart';

class AppLogoCircularProgressIndicator extends StatelessWidget {
  const AppLogoCircularProgressIndicator({
    super.key,
    this.size = const Size.square(48.0),
    this.color = CustomAppColors.primary,
  });

  factory AppLogoCircularProgressIndicator.size(Size size) => AppLogoCircularProgressIndicator(size: size);
  final Size size;
  final Color color;

  @override
  Widget build(BuildContext context) => ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcATop),
      child: _progressIndicator,
    );

  Widget get _progressIndicator => SizedBox(
    height: size.height,
    width: size.width,
    child: const CircularProgressIndicator(),
  );
}
