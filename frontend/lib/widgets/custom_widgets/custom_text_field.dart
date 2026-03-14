import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../provider/theme_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';
import '../../utils/images/base_image.dart';
import '../../utils/images/image_asset.dart';

class CustomTextField extends StatefulWidget {
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
    this.suffixIcon,
  });
  final String? label;
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
  final Widget? prefixIcon, suffixIcon;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final theme = themeProvider.themeData;
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;

    final isFocused = _focusNode.hasFocus;
    final fillColor =
        widget.filled
            ? (isFocused ? Colors.white : CustomAppColors.slate50)
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label ?? '',
            style: TextStyle(
              fontWeight: AppTheme.fontWeightBold,
              fontSize: AppTheme.fontSizeSm,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          focusNode: _focusNode,
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          style:
              widget.textStyle ??
              context.textTheme.bodySm.copyWith(color: textColor),
          readOnly: !widget.isEnabled,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          validator: widget.validator,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            filled: widget.filled,
            fillColor: fillColor,
            prefixIcon:
                widget.prefixIcon ??
                (widget.prefixButtonIcon?.icon != null
                    ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: InkWell(
                        onTap: widget.prefixButtonIcon?.onIconTapped,
                        child: BaseImage(
                          asset: LocalAsset(url: widget.prefixButtonIcon!.icon),
                          fit: BoxFit.contain,
                          height: 25,
                          width: 25,
                          color: widget.prefixButtonIcon?.color,
                        ),
                      ),
                    )
                    : null),
            suffixIcon:
                widget.suffixIcon ??
                (widget.suffixButtonIcon?.icon != null
                    ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: InkWell(
                        onTap: widget.suffixButtonIcon?.onIconTapped,
                        child: BaseImage(
                          asset: LocalAsset(url: widget.suffixButtonIcon!.icon),
                          height: 25,
                          width: 25,
                          fit: BoxFit.contain,
                          color: widget.suffixButtonIcon?.color,
                        ),
                      ),
                    )
                    : null),
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: CustomAppColors.grey01),
            border:
                widget.border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: CustomAppColors.lightGrey01,
                  ),
                ),
            enabledBorder:
                widget.border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: CustomAppColors.lightGrey01,
                  ),
                ),
            focusedBorder:
                widget.border ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: CustomAppColors.lightGrey01,
                width: 2,
              ),
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
