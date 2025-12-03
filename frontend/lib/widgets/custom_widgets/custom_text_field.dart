import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/theme_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';
import '../../utils/images/base_image.dart';
import '../../utils/images/image_asset.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textStyle,
    this.filled = true,
    this.isEnabled = true,
    this.border,
    this.prefixButtonIcon,
    this.suffixButtonIcon,
    this.onTap,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.prefixIcon,
  });
  final String? label /* ,prefixIcon, suffixIcon */;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextStyle? textStyle;
  final bool filled, isEnabled;
  final InputBorder? border;
  final String? hintText;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int? maxLines;
  final ButtonIcon? prefixButtonIcon, suffixButtonIcon;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final theme = themeProvider.themeData;
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label ?? '',
            style: TextStyle(
              fontWeight: AppTheme.fontWeightBold,
              fontSize: AppTheme.fontSizeSm,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style:
              textStyle ?? context.textTheme.bodySm.copyWith(color: textColor),
          readOnly: !isEnabled,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: filled,
            fillColor: filled ? CustomAppColors.slate50 : null,
            prefixIcon:
                prefixIcon ??
                (prefixButtonIcon?.icon != null
                    ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: InkWell(
                        onTap: prefixButtonIcon?.onIconTapped,
                        child: BaseImage(
                          asset: LocalAsset(url: prefixButtonIcon!.icon),
                          fit: BoxFit.contain,
                          height: 25,
                          width: 25,
                          color: prefixButtonIcon?.color,
                        ),
                      ),
                    )
                    : null),
            suffixIcon:
                suffixButtonIcon?.icon != null
                    ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: InkWell(
                        onTap: suffixButtonIcon?.onIconTapped,
                        child: BaseImage(
                          asset: LocalAsset(url: suffixButtonIcon!.icon),
                          height: 25,
                          width: 25,
                          fit: BoxFit.contain,
                          color: suffixButtonIcon?.color,
                        ),
                      ),
                    )
                    : null,
            hintText: hintText,
            hintStyle: const TextStyle(color: CustomAppColors.grey01),
            border:
                border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: CustomAppColors.lightGrey01),
                ),
            enabledBorder:
                border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: CustomAppColors.lightGrey01),
                ),
            focusedBorder:
                border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: CustomAppColors.lightGrey01, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class ButtonIcon {
  ButtonIcon({required this.icon, this.color, this.onIconTapped});
  final String icon;
  final Color? color;
  final void Function()? onIconTapped;
}
