import 'package:flutter/material.dart';

import '../../utils/extensions.dart';
import '../../utils/localization/app_localizations.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class LegalAndPolicies extends StatelessWidget {
  const LegalAndPolicies({super.key});

  @override
  Widget build(BuildContext context) {
    final headerStyle = context.textTheme.labelBase;
    final bodyStyle = context.textTheme.bodySm.copyWith(
      color: const Color(0xFF666876),
    );

    return CustomMainScreenWithAppbar(
      title: context.translate('legal_policies'),
      child: ListView(
        children: [
          Text('Policies', style: headerStyle),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Eget ornare quam vel facilisis feugiat amet sagittis arcu, tortor. Sapien, consequat ultrices morbi orci semper sit nulla. Leo auctor ut etiam est, amet aliquet ut vivamus. Odio vulputate est id tincidunt fames.',
            style: bodyStyle,
          ),
        ],
      ),
    );
  }
}
