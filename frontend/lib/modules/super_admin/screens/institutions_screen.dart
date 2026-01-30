import 'package:flutter/material.dart';

import '../../../../utils/custom_colors.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class InstitutionsScreen extends StatelessWidget {
  const InstitutionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock super admin data
    const userInitials = 'SA';
    const userName = 'Super Admin';
    const systemName = 'EdVerse Master';

    return CustomMainScreenWithAppbar(
      title: 'Institutions',
      appBarConfig: AppBarConfig.superAdmin(
        userInitials: userInitials,
        userName: userName,
        systemName: systemName,
        onNotificationIconPressed: () {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: CustomAppColors.primary,
        child: const Icon(Icons.add),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder:
            (context, index) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, size: 30, color: Colors.grey),
                ),
                title: Text(
                  'Institution ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'License: Enterprise\nStudents: 2500 | Staff: 150',
                ),
                trailing: PopupMenuButton(
                  itemBuilder:
                      (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'suspend',
                          child: Text('Suspend'),
                        ),
                      ],
                ),
              ),
            ),
      ),
    );
  }
}
