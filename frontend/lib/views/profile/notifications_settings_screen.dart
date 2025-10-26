import 'package:flutter/material.dart';

import '../../utils/extensions.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomMainScreenWithAppbar(
    title: context.translate('notifications'),
    child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE3E7EC)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: Text(context.translate('payment')),
            value: true,
            onChanged: (va) {},
          ),
          const Divider(indent: 16.0, endIndent: 16.0),
          SwitchListTile(
            title: Text(context.translate('schedule')),
            value: true,
            onChanged: (va) {},
          ),
          const Divider(indent: 16.0, endIndent: 16.0),
          SwitchListTile(
            title: Text(context.translate('cancellation')),
            value: true,
            onChanged: (va) {},
          ),
          const Divider(indent: 16.0, endIndent: 16.0),
          SwitchListTile(
            title: Text(context.translate('notification')),
            value: true,
            onChanged: (va) {},
          ),
        ],
      ),
    ),
  );
}
