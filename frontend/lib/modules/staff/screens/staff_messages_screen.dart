import 'package:flutter/material.dart';

import '../../../../utils/custom_colors.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class StaffMessagesScreen extends StatelessWidget {
  const StaffMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock staff data
    const userInitials = 'SJ';
    const userName = 'Sarah Jones';
    const department = 'Administration';

    return CustomMainScreenWithAppbar(
      title: 'Messages',
      appBarConfig: AppBarConfig.staff(
        userInitials: userInitials,
        userName: userName,
        department: department,
        onNotificationIconPressed: () {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: CustomAppColors.primary,
        child: const Icon(Icons.edit),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (ctx, i) => const Divider(),
        itemBuilder:
            (context, index) => ListTile(
              leading: CircleAvatar(
                backgroundColor: CustomAppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: CustomAppColors.primary),
              ),
              title: Text('Sender Name ${index + 1}'),
              subtitle: Text(
                'This is a preview of the message sent by sender ${index + 1}...',
              ),
              trailing: Text(
                '10:30 AM',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              onTap: () {},
            ),
      ),
    );
  }
}
