import 'package:flutter/material.dart';

import '../../utils/extensions.dart';
import '../../utils/localization/app_localizations.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!.translate;
    final descriptionStyle = context.textTheme.bodySm.copyWith(
      color: const Color(0xFF6C6C6C),
    );

    return CustomMainScreenWithAppbar(
      title: translate('help_and_support'),
      child: Column(
        children: [
          _CustomExpansionTile(
            title: 'Hello world 1',
            description: [
              Text('test', style: descriptionStyle),
              Text('hello', style: descriptionStyle),
              Text('qwe', style: descriptionStyle),
            ],
          ),
          const Divider(),
          _CustomExpansionTile(
            title: 'Hello world 2',
            description: [
              Text('test', style: descriptionStyle),
              Text('hello', style: descriptionStyle),
              Text('qwe', style: descriptionStyle),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class _CustomExpansionTile extends StatelessWidget {
  const _CustomExpansionTile({required this.title, required this.description});
  final String title;
  final List<Widget> description;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    expandedAlignment: Alignment.centerLeft,
    dense: false,
    minTileHeight: 48,
    shape: const RoundedRectangleBorder(),
    tilePadding: EdgeInsets.zero,
    childrenPadding: const EdgeInsets.only(left: 4.0),
    iconColor: const Color(0xFF111111),
    title: Text(title, style: context.textTheme.labelBase),
    children: description,
  );
}
