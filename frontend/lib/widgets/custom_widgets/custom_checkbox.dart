import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/custom_colors.dart';
import '../../utils/custom_images.dart';

class CustomCheckBox extends StatefulWidget {
  const CustomCheckBox({
    super.key,
    this.value,
    this.onValueChange,
    this.tristate = false,
    this.isDisabled = false,
  });
  final bool? value;
  final ValueChanged<bool>? onValueChange;
  final bool tristate;
  final bool isDisabled;

  @override
  State<StatefulWidget> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  bool? value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  void didUpdateWidget(CustomCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () {
      setState(() {
        widget.onValueChange?.call(!value!);
        if (!widget.tristate) {
          value = !value!;
        } else {
          value =
              value == null
                  ? true
                  : value == true
                  ? false
                  : null;
        }
      });
    },
    child: SvgPicture.asset(
      widget.isDisabled
          ? CustomImages.checkboxUnChecked
          : widget.tristate && value == null
          ? CustomImages.checkboxPartialChecked
          : value ?? false
          ? CustomImages.checkboxChecked
          : CustomImages.checkboxUnChecked,
      colorFilter: ColorFilter.mode(
        widget.isDisabled ? CustomAppColors.grey01 : CustomAppColors.primary,
        BlendMode.srcIn,
      ),
    ),
  );
}
