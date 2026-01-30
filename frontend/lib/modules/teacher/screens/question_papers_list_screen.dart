import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class QuestionPapersListScreen extends StatelessWidget {
  const QuestionPapersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;

    return CustomMainScreenWithAppbar(
      title: 'Question Papers',
      appBarConfig: AppBarConfig.teacher(
        userInitials: user?.name?.substring(0, 1) ?? 'T',
        userName: user?.name ?? 'Teacher',
        designation: user?.teacher?.designation ?? 'Teacher',
        employeeId: user?.teacher?.employeeId ?? 'EMP',
        onNotificationIconPressed: () {},
      ),
      bottomWidget: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
               context.pushNamed('create_question_paper');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomAppColors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
            label: const Text(
              'Create Question Paper',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: AppTheme.fontWeightBold,
              ),
            ),
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder List
             const Text(
              'Saved Papers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CustomAppColors.slate800,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaperItem('Mid-Term Math 2025', 'Class 10 - Mathematics'),
            const SizedBox(height: 12),
            _buildPaperItem('Physics Unit Test', 'Class 11 - Physics'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperItem(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomAppColors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: CustomAppColors.purple,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CustomAppColors.slate800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CustomAppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: CustomAppColors.slate400),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
