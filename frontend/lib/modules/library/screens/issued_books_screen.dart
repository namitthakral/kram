import 'package:flutter/material.dart';

import '../../../../utils/custom_colors.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class IssuedBooksScreen extends StatelessWidget {
  const IssuedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock librarian data
    const userInitials = 'LB';
    const userName = 'Librarian';
    const libraryName = 'Main Library';

    return CustomMainScreenWithAppbar(
      title: 'Issued Books',
      appBarConfig: AppBarConfig.librarian(
        userInitials: userInitials,
        userName: userName,
        libraryName: libraryName,
        onNotificationIconPressed: () {},
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder:
            (context, index) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text('Book Title ${index + 1}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Student Name',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due: Oct 30, 2025',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: CustomAppColors.primary,
                    side: const BorderSide(color: CustomAppColors.primary),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Return'),
                ),
              ),
            ),
      ),
    );
  }
}
