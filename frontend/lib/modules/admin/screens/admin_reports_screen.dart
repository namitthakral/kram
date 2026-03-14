import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/extensions.dart';
import '../../../../utils/responsive_utils.dart';
import '../../../../utils/router_service.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../../widgets/custom_widgets/dashboard_widgets.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';
    final institutionName = user?.institution?.name ?? '';

    return CustomMainScreenWithAppbar(
      title: context.translate('admin_reports'),
      appBarConfig: AppBarConfig.admin(
        showBackButton: true,
        userInitials: userInitials,
        userName: userName,
        institutionName: institutionName,
        onNotificationIconPressed: () {},
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: isMobile ? 1.0 : 1.1,
              ),
              delegate: SliverChildListDelegate([
                FeatureActionCard(
                  title: 'Student Enrollment',
                  icon: Icons.people_rounded,
                  color: AppTheme.blue500,
                  onTap: () => context.router.router.push('/admin-dashboard'),
                ),
                FeatureActionCard(
                  title: 'Staff Attendance',
                  icon: Icons.work_rounded,
                  color: AppTheme.warning,
                  onTap: () => context.router.router.push('/admin-dashboard'),
                ),
                FeatureActionCard(
                  title: 'Financial Audit',
                  icon: Icons.monetization_on_rounded,
                  color: AppTheme.success,
                  onTap: () => context.router.router.push('/fees'),
                ),
                FeatureActionCard(
                  title: 'Transport Usage',
                  icon: Icons.directions_bus_rounded,
                  color: const Color(0xFF8b5cf6),
                  onTap: () => context.router.router.push('/transport'),
                ),
                FeatureActionCard(
                  title: 'Library Stats',
                  icon: Icons.library_books_rounded,
                  color: AppTheme.danger,
                  onTap: () => context.router.router.push('/books'),
                ),
                FeatureActionCard(
                  title: 'System Logs',
                  icon: Icons.settings_rounded,
                  color: AppTheme.slate500,
                  onTap: () => context.router.router.push('/admin-dashboard'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
