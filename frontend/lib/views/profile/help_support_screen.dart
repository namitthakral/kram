import 'package:flutter/material.dart';

import '../../utils/extensions.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final descriptionStyle = context.textTheme.bodySm.copyWith(
      color: const Color(0xFF6C6C6C),
    );

    return CustomMainScreenWithAppbar(
      title: context.translate('help_and_support'),
      child: Column(
        children: [
          _CustomExpansionTile(
            title: context.translate('help_and_support'),
            description: [
              Text(context.translate('help_and_support'), style: descriptionStyle),
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
