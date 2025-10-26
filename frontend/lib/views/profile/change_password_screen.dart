import 'package:flutter/material.dart';

import '../../utils/custom_images.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../widgets/custom_widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomMainScreenWithAppbar(
    title: context.translate('Change Password'),
    child: Column(
      children: [
        CustomTextField(
          label: context.translate('New Password'),
          hintText: context.translate('Enter new password'),
          prefixButtonIcon: ButtonIcon(icon: CustomImages.iconLock),
          suffixButtonIcon: ButtonIcon(icon: CustomImages.iconVisible),
        ),
        CustomTextField(label: context.translate('Confirm Password')),
      ],
    ),
  );
}
