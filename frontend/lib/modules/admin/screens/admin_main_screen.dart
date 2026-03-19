import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/dashboard_widgets.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;

    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';

    return CustomMainScreenWithAppbar(
      title: context.translate('admin_features'),
      appBarConfig: AppBarConfig.admin(
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onNotificationIconPressed: () {},
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                FeatureActionCard(
                  title: context.translate('user_management'),
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF3b82f6),
                  onTap: () => context.push('/admin-users'),
                ),
                FeatureActionCard(
                  title: context.translate('students'),
                  icon: Icons.school_rounded,
                  color: const Color(0xFF0ea5e9),
                  onTap: () => context.push('/students'),
                ),
                FeatureActionCard(
                  title: context.translate('staff_management'),
                  icon: Icons.badge_rounded,
                  color: const Color(0xFF6366f1),
                  onTap: () => context.push('/staff'),
                ),
                FeatureActionCard(
                  title: context.translate('library_management'),
                  icon: Icons.local_library_rounded,
                  color: const Color(0xFF8b5cf6),
                  onTap: () => context.push('/books'),
                ),
                FeatureActionCard(
                  title: context.translate('teachers'),
                  icon: Icons.person_rounded,
                  color: const Color(0xFF8b5cf6),
                  onTap: () => context.push('/teachers'),
                ),
                FeatureActionCard(
                  title: context.translate('course_management'),
                  icon: Icons.book_rounded,
                  color: const Color(0xFF059669),
                  onTap: () => context.push('/courses'),
                ),
                FeatureActionCard(
                  title: context.translate('class_sections'),
                  icon: Icons.class_rounded,
                  color: const Color(0xFF7c3aed),
                  onTap: () => context.push('/class-sections'),
                ),
                FeatureActionCard(
                  title: context.translate('attendance'),
                  icon: Icons.how_to_reg_rounded,
                  color: const Color(0xFFec4899),
                  onTap: () => context.push('/academic/attendance'),
                ),
                FeatureActionCard(
                  title: context.translate('examinations'),
                  icon: Icons.quiz_rounded,
                  color: const Color(0xFFf43f5e),
                  onTap: () => context.push('/admin/examinations'),
                ),
                FeatureActionCard(
                  title: context.translate('fees_management'),
                  icon: Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF10b981),
                  onTap: () => context.push('/fees'),
                ),
                FeatureActionCard(
                  title: context.translate('transport'),
                  icon: Icons.directions_bus_rounded,
                  color: const Color(0xFFf59e0b),
                  onTap: () => context.push('/transport'),
                ),
                FeatureActionCard(
                  title: context.translate('reports_analytics'),
                  icon: Icons.analytics_rounded,
                  color: const Color(0xFFef4444),
                  onTap: () => context.push('/reports'),
                ),
                FeatureActionCard(
                  title: context.translate('grading_config'),
                  icon: Icons.grid_view_rounded,
                  color: const Color(0xFF06b6d4),
                  onTap: () => context.push('/grading-config'),
                ),
                FeatureActionCard(
                  title: context.translate('academic_year_management'),
                  icon: Icons.calendar_view_month_rounded,
                  color: const Color(0xFF8b5a2b),
                  onTap: () => context.push('/academic-management'),
                ),
                FeatureActionCard(
                  title: context.translate('institution_settings'),
                  icon: Icons.settings_applications_rounded,
                  color: const Color(0xFF64748b),
                  onTap: () => context.push('/institution-settings'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
