import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

import '../providers/question_paper_provider.dart';

class QuestionPapersListScreen extends StatefulWidget {
  const QuestionPapersListScreen({super.key});

  @override
  State<QuestionPapersListScreen> createState() => _QuestionPapersListScreenState();
}

class _QuestionPapersListScreenState extends State<QuestionPapersListScreen> {
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
      context.read<QuestionPaperProvider>().loadAllQuestionPapers(userUuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionPaperProvider>();
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;

    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');

    return CustomMainScreenWithAppbar(
      title: 'Question Papers',
      isLoading: provider.isLoading,
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: user?.name ?? 'Teacher',
        designation: user?.teacher?.designation ?? 'Faculty',
        employeeId: user?.teacher?.employeeId ?? 'N/A',
        onNotificationIconPressed: () {},
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('create_question_paper'),
        backgroundColor: CustomAppColors.purple,
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
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: provider.questionPapers == null && provider.isLoading
            ? const SizedBox() // Initial loading handled by UnifiedLoader
            : provider.questionPapers == null || provider.questionPapers!.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: provider.questionPapers!.length,
                    itemBuilder: (context, index) {
                      final paper = provider.questionPapers![index];
                      // Fallback to defaults if fields are missing
                      final title = paper['title'] ?? paper['examName'] ?? 'Question Paper #${paper['id']}';
                      final subtitle = paper['courseName'] ?? 'General';

                      return _buildPaperItem(title, subtitle, () {
                        // Navigate to detail or edit
                        // context.pushNamed('question_paper_detail', extra: paper['id']);
                      });
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() => const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No question papers found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );

  Widget _buildPaperItem(String title, String subtitle, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
      ),
    );
}
