import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/unified_loader.dart';
import '../models/examination_models.dart';
import '../providers/marks_provider.dart';

class MarksListScreen extends StatefulWidget {
  const MarksListScreen({super.key});

  @override
  State<MarksListScreen> createState() => _MarksListScreenState();
}

class _MarksListScreenState extends State<MarksListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final loginProvider = context.read<LoginProvider>();
    final userUuid = loginProvider.currentUser?.uuid;
    if (userUuid != null) {
      context.read<MarksProvider>().loadRecentExams(userUuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarksProvider>();
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');

    return Stack(
      children: [
        CustomMainScreenWithAppbar(
          title: 'Marks & Results',
          appBarConfig: AppBarConfig.teacher(
            userInitials: userInitials,
            userName: user?.name ?? 'Teacher',
            designation: user?.teacher?.designation ?? 'Faculty',
            employeeId: user?.teacher?.employeeId ?? 'N/A',
            onNotificationIconPressed: () {},
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              context.pushNamed('enter_marks');
            },
            backgroundColor: CustomAppColors.pink,
            icon: const Icon(Icons.grading_rounded, color: Colors.white),
            label: const Text(
              'Enter Marks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: AppTheme.fontWeightBold,
              ),
            ),
          ),
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 80,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Exams',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CustomAppColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (provider.recentExams.isEmpty && !provider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No exams found'),
                      ),
                    )
                  else
                    ...provider.recentExams.map((exam) {
                      // Handling potential dynamic or Examination model
                      String title = 'Unknown Exam';
                      String subtitle = 'Unknown Class';
                      String dateStr = '';
                      bool isPending = false;
                      // Logic: if current date < exam date + duration? Or check status?
                      // Assuming 'scheduled' is pending results? Or 'completed' needs marks.

                      if (exam is Examination) {
                        title = exam.examName;
                        subtitle =
                            exam.courseName ?? exam.courseId.toString();
                        dateStr = DateFormat(
                          'MMM d, yyyy',
                        ).format(exam.examDate);
                        isPending = exam.status == 'scheduled'; // Example logic
                      } else if (exam is Map<String, dynamic>) {
                        title = exam['name'] ?? 'Unknown Exam';
                        subtitle = exam['courseName'] ?? '';
                        dateStr = exam['date'] ?? '';
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildMarksItem(
                          title,
                          subtitle,
                          dateStr,
                          isPending: isPending,
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
        if (provider.isLoading) const UnifiedLoader(),
      ],
    );
  }

  Widget _buildMarksItem(
    String title,
    String subtitle,
    String time, {
    bool isPending = false,
  }) {
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
              color:
                  isPending
                      ? Colors.orange.withOpacity(0.1)
                      : CustomAppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPending
                  ? Icons.pending_actions_rounded
                  : Icons.check_circle_rounded,
              color: isPending ? Colors.orange : CustomAppColors.success,
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
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: CustomAppColors.slate400,
            ),
          ),
        ],
      ),
    );
  }
}
