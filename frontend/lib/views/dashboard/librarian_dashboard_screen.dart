import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../modules/teacher/widgets/stat_card.dart';
import '../../provider/login_signup/login_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/router_service.dart';
import '../../utils/user_utils.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

class LibrarianDashboardScreen extends StatelessWidget {
  const LibrarianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.router.goToLogin();
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userInitials = UserUtils.getInitials(user.name);
    final userName = user.name;

    return CustomMainScreenWithAppbar(
      title: context.translate('Library Dashboard'),
      appBarConfig: AppBarConfig.librarian(
        userInitials: userInitials,
        userName: userName,
        libraryName: 'Central Library', // TODO: Get from user data
        onNotificationIconPressed: () {},
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsSection(context),
            const SizedBox(height: 24),
            _buildQuickActionsSection(context),
            const SizedBox(height: 24),
            _buildRecentIssuesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final isMobile = context.isMobile;

    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isMobile ? 12 : 16,
      mainAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: isMobile ? 1.3 : 1.5,
      children: const [
        StatCard(
          title: 'Total Books',
          value: '5,432',
          subtitle: 'In collection',
          icon: Icons.book,
          backgroundColor: CustomAppColors.primary,
          iconColor: CustomAppColors.primary,
        ),
        StatCard(
          title: 'Issued Books',
          value: '234',
          subtitle: 'Currently issued',
          icon: Icons.library_books,
          backgroundColor: Color(0xFF10b981),
          iconColor: Color(0xFF10b981),
        ),
        StatCard(
          title: 'Overdue',
          value: '12',
          subtitle: 'Need follow-up',
          icon: Icons.warning,
          backgroundColor: Color(0xFFef4444),
          iconColor: Color(0xFFef4444),
        ),
        StatCard(
          title: 'Available',
          value: '5,198',
          subtitle: 'Ready to issue',
          icon: Icons.check_circle,
          backgroundColor: Color(0xFF8B5CF6),
          iconColor: Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final isMobile = context.isMobile;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e293b),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: isMobile ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildActionButton('Issue Book', Icons.add_circle, () {}),
              _buildActionButton('Return Book', Icons.replay, () {}),
              _buildActionButton('Add New Book', Icons.library_add, () {}),
              _buildActionButton('Search Books', Icons.search, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CustomAppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CustomAppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: CustomAppColors.primary, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1e293b),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _buildRecentIssuesSection(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Issues',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 16),
        _buildIssueItem(
          'The Great Gatsby',
          'John Doe - Grade 10',
          'Due: Nov 15, 2025',
          Icons.book,
          false,
        ),
        _buildIssueItem(
          'Physics Fundamentals',
          'Jane Smith - Grade 12',
          'Due: Nov 10, 2025',
          Icons.book,
          true,
        ),
        _buildIssueItem(
          'World History',
          'Bob Johnson - Grade 11',
          'Due: Nov 20, 2025',
          Icons.book,
          false,
        ),
      ],
    ),
  );

  Widget _buildIssueItem(
    String bookTitle,
    String studentInfo,
    String dueDate,
    IconData icon,
    bool isOverdue,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isOverdue
                    ? const Color(0xFFef4444)
                    : CustomAppColors.primary)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color:
                isOverdue ? const Color(0xFFef4444) : CustomAppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1e293b),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                studentInfo,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748b)),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              dueDate,
              style: TextStyle(
                fontSize: 12,
                color:
                    isOverdue
                        ? const Color(0xFFef4444)
                        : const Color(0xFF94a3b8),
                fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isOverdue)
              const Text(
                'OVERDUE',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFef4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ],
    ),
  );
}
