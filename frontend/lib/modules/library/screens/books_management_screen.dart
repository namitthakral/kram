import 'package:flutter/material.dart';

import '../../../../utils/custom_colors.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class BooksManagementScreen extends StatelessWidget {
  const BooksManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock librarian data
    const userInitials = 'LB';
    const userName = 'Librarian';
    const libraryName = 'Main Library';

    return CustomMainScreenWithAppbar(
      title: 'Books',
      appBarConfig: AppBarConfig.librarian(
        userInitials: userInitials,
        userName: userName,
        libraryName: libraryName,
        onNotificationIconPressed: () {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: CustomAppColors.primary,
        child: const Icon(Icons.add),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildBookItem(
                  'The Great Gatsby',
                  'F. Scott Fitzgerald',
                  'Available',
                  Colors.green,
                ),
                _buildBookItem(
                  '1984',
                  'George Orwell',
                  'Issued',
                  Colors.orange,
                ),
                _buildBookItem(
                  'To Kill a Mockingbird',
                  'Harper Lee',
                  'Available',
                  Colors.green,
                ),
                _buildBookItem(
                  'Pride and Prejudice',
                  'Jane Austen',
                  'Reserved',
                  Colors.blue,
                ),
                _buildBookItem(
                  'The Catcher in the Rye',
                  'J.D. Salinger',
                  'Lost',
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(
    String title,
    String author,
    String status,
    Color statusColor,
  ) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(child: Icon(Icons.book, color: Colors.grey)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(author),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}
