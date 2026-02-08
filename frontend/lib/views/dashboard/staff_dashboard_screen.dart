import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/login_signup/login_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/extensions.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/router_service.dart';
import '../../utils/user_utils.dart';
import '../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../widgets/custom_widgets/dashboard_widgets.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

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
      title: context.translate('Staff Dashboard'),
      appBarConfig: AppBarConfig.staff(
        userInitials: userInitials,
        userName: userName,
        department: 'Administration', // TODO: Get from user data
        onNotificationIconPressed: () {},
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsSection(context),
            const SizedBox(height: 24),
            _buildTodayScheduleSection(context),
            const SizedBox(height: 24),
            _buildNoticesSection(context),
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
        DashboardStatCard(
          title: 'My Attendance',
          value: '95%',
          subtitle: 'This month',
          icon: Icons.calendar_today,
          backgroundColor: CustomAppColors.primary,
          iconColor: CustomAppColors.primary,
        ),
        DashboardStatCard(
          title: 'Tasks Pending',
          value: '8',
          subtitle: 'Need attention',
          icon: Icons.assignment,
          backgroundColor: Color(0xFFf59e0b),
          iconColor: Color(0xFFf59e0b),
        ),
        DashboardStatCard(
          title: 'Tasks Completed',
          value: '24',
          subtitle: 'This week',
          icon: Icons.check_circle,
          backgroundColor: Color(0xFF10b981),
          iconColor: Color(0xFF10b981),
        ),
        DashboardStatCard(
          title: 'Notices',
          value: '3',
          subtitle: 'Unread',
          icon: Icons.notifications,
          backgroundColor: Color(0xFF8B5CF6),
          iconColor: Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildTodayScheduleSection(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 16),
        _buildScheduleItem(
          '9:00 AM',
          'Morning Shift Starts',
          'Administration Desk',
          Icons.access_time,
        ),
        _buildScheduleItem(
          '11:00 AM',
          'Staff Meeting',
          'Conference Room',
          Icons.group,
        ),
        _buildScheduleItem(
          '2:00 PM',
          'Document Processing',
          'Office',
          Icons.description,
        ),
        _buildScheduleItem('5:00 PM', 'End of Shift', 'Sign Out', Icons.logout),
      ],
    ),
  );

  Widget _buildScheduleItem(
    String time,
    String title,
    String location,
    IconData icon,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CustomAppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: CustomAppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1e293b),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748b)),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94a3b8),
          ),
        ),
      ],
    ),
  );

  Widget _buildNoticesSection(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Important Notices',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        const SizedBox(height: 16),
        _buildNoticeItem(
          'Staff Training Session',
          'Mandatory training on new systems scheduled for Nov 15',
          '2 days ago',
          true,
        ),
        _buildNoticeItem(
          'Holiday Announcement',
          'Office will be closed on Nov 20 for festival',
          '5 days ago',
          false,
        ),
        _buildNoticeItem(
          'Uniform Policy Update',
          'New uniform guidelines effective from Dec 1',
          '1 week ago',
          false,
        ),
      ],
    ),
  );

  Widget _buildNoticeItem(
    String title,
    String description,
    String time,
    bool isNew,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isNew
                ? CustomAppColors.primary.withValues(alpha: 0.05)
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isNew
                  ? CustomAppColors.primary.withValues(alpha: 0.2)
                  : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notifications_active,
            color: isNew ? CustomAppColors.primary : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1e293b),
                        ),
                      ),
                    ),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CustomAppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748b),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94a3b8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
