import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';

import '../providers/question_paper_provider.dart';
import '../models/template_models.dart';
import '../services/pdf_template_service.dart';

class QuestionPapersListScreen extends StatefulWidget {
  const QuestionPapersListScreen({super.key});

  @override
  State<QuestionPapersListScreen> createState() =>
      _QuestionPapersListScreenState();
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
        onPressed: () async {
          final result = await context.pushNamed('create_question_paper');
          if (result == true) {
            _loadData(); // Refresh list on successful creation
          }
        },
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
        child:
            provider.questionPapers == null && provider.isLoading
                ? const SizedBox() // Initial loading handled by UnifiedLoader
                : provider.questionPapers == null ||
                    provider.questionPapers!.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: provider.questionPapers!.length,
                  itemBuilder: (context, index) {
                    final paper = provider.questionPapers![index];
                    final exam = paper['examination'] as Map<String, dynamic>?;
                    final subject = exam?['subject'] as Map<String, dynamic>?;
                    final course = subject?['course'] as Map<String, dynamic>?;

                    // Fallback to defaults if fields are missing
                    final title =
                        paper['title'] ??
                        exam?['examName'] ??
                        'Question Paper #${paper['id']}';
                    final subtitle =
                        subject?['subjectName'] ?? course?['name'] ?? 'General';
                    final date =
                        exam?['examDate'] != null
                            ? exam!['examDate'].toString().split('T')[0]
                            : 'No Date';
                    final marks =
                        paper['totalMarks']?.toString() ??
                        exam?['totalMarks']?.toString() ??
                        '100';
                    final duration = paper['duration']?.toString() ?? '180';

                    return _buildPaperItem(
                      paper,
                      title,
                      subtitle,
                      date,
                      marks,
                      duration,
                      () async {
                        final paperId = paper['id'] as int?;
                        if (paperId != null) {
                          final result = await context.pushNamed(
                            'create_question_paper',
                            extra: {'paperId': paperId},
                          );
                          if (result == true) {
                            _loadData();
                          }
                        }
                      },
                    );
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

  Widget _buildPaperItem(
    Map<String, dynamic> paper,
    String title,
    String subtitle,
    String date,
    String marks,
    String duration,
    VoidCallback onTap,
  ) => GestureDetector(
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
                Row(
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CustomAppColors.slate500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: CustomAppColors.slate300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CustomAppColors.slate500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$marks Marks',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CustomAppColors.slate400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$duration mins',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CustomAppColors.slate400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.download_rounded,
              color: CustomAppColors.slate400,
            ),
            onPressed: () => _downloadPaper(paper),
          ),
        ],
      ),
    ),
  );

  Future<void> _downloadPaper(Map<String, dynamic> paper) async {
    final loginProvider = context.read<LoginProvider>();
    final userUuid = loginProvider.currentUser?.uuid;
    if (userUuid == null) return;

    final paperId = paper['id'] as int;
    final provider = context.read<QuestionPaperProvider>();

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preparing PDF...')));

      await provider.loadQuestionPaperById(userUuid, paperId);
      final fullPaper = provider.questionPaper;

      if (fullPaper != null && context.mounted) {
        final template = _mapToTemplate(fullPaper);
        await PdfTemplateService.generateQuestionPaperPdf(template);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF downloaded successfully'),
              backgroundColor: CustomAppColors.success,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load paper details'),
              backgroundColor: CustomAppColors.danger,
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: CustomAppColors.danger,
          ),
        );
      }
    }
  }

  QuestionPaperTemplate _mapToTemplate(Map<String, dynamic> json) {
    // Helper to safely parse sections
    List<QuestionSection> parseSections(List<dynamic>? sectionsList) {
      if (sectionsList == null) return [];
      return sectionsList.map((s) {
        final sMap = s as Map<String, dynamic>;
        return QuestionSection(
          sectionName: sMap['sectionName'] ?? 'Section',
          description: sMap['description'],
          marksPerQuestion: 1, // Default or calculate from questions?
          questions:
              (sMap['questions'] as List? ?? []).map((q) {
                final qMap = q as Map<String, dynamic>;
                return Question(
                  questionText: qMap['text'] ?? qMap['questionText'] ?? '',
                  customMarks: qMap['marks'],
                  type:
                      (qMap['type'] == 'MCQ' || qMap['questionType'] == 'MCQ')
                          ? QuestionType.mcq
                          : QuestionType.written,
                  mcqOptions:
                      (qMap['options'] as List?)?.map((o) {
                        if (o is Map) {
                          return (o['optionText'] ?? '').toString();
                        }
                        return o.toString();
                      }).toList(),
                );
              }).toList(),
        );
      }).toList();
    }

    return QuestionPaperTemplate(
      schoolName: 'EdVerse Academy', // TODO: Fetch from profile
      schoolAddress: 'Digital Campus',
      examName: json['title'] ?? json['examName'] ?? 'Examination',
      className: json['courseName'] ?? 'Class',
      section: '',
      subject: json['subjectName'] ?? 'Subject',
      date:
          json['examDate'] != null
              ? json['examDate'].toString().split('T')[0]
              : 'Date',
      duration: (json['duration'] ?? 180).toString(),
      maxMarks: json['totalMarks'] ?? 100,
      instructions: json['instructions'],
      sections: parseSections(json['sections']),
    );
  }
}
