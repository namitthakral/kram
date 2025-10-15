import 'package:flutter/material.dart';

import '../../utils/custom_images.dart';
import '../../utils/localization/app_localizations.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../widgets/custom_widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!.translate;

    return CustomMainScreenWithAppbar(
      title: translate('Change Password'),
      child: Column(
        children: [
          CustomTextField(
            label: translate('New Password'),
            hintText: translate('Enter new password'),
            prefixButtonIcon: ButtonIcon(icon: CustomImages.iconLock),
            suffixButtonIcon: ButtonIcon(icon: CustomImages.iconVisible),
          ),
          CustomTextField(label: translate('Confirm Password')),
        ],
      ),
    );
  }
}
