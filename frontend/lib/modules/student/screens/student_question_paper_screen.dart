import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/question_paper_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../provider/login_signup/login_provider.dart';
import '../../../../utils/custom_snackbar.dart';
import '../../../../utils/extensions.dart';
import '../../../../utils/user_utils.dart';
import '../../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../teacher/models/template_models.dart';
import '../../teacher/services/pdf_template_service.dart';
import '../providers/student_provider.dart';

class StudentQuestionPaperScreen extends StatefulWidget {
  const StudentQuestionPaperScreen({required this.examId, super.key});

  final int examId;

  @override
  State<StudentQuestionPaperScreen> createState() =>
      _StudentQuestionPaperScreenState();
}

class _StudentQuestionPaperScreenState
    extends State<StudentQuestionPaperScreen> {
  final QuestionPaperService _questionPaperService = QuestionPaperService();
  bool _isLoading = true;
  String? _error;
  QuestionPaperTemplate? _questionPaper;

  @override
  void initState() {
    super.initState();
    _fetchQuestionPaper();
  }

  Future<void> _fetchQuestionPaper() async {
    if (widget.examId <= 0) {
      if (mounted) {
        setState(() {
          _error = 'Invalid Exam ID';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final loginProvider = context.read<LoginProvider>();
      final user = loginProvider.currentUser;

      if (user?.uuid == null) {
        throw Exception('User authentication error');
      }

      final data = await _questionPaperService.getPublishedQuestionPaper(
        user!.uuid!,
        widget.examId,
      );

      setState(() {
        _questionPaper = QuestionPaperTemplate.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();

    final user = context.watch<LoginProvider>().currentUser;
    final userInitials = user != null ? UserUtils.getInitials(user.name) : 'ST';
    final userName = user?.name ?? 'Student';

    // Get dynamic grade/class info
    final className = studentProvider.studentClassName;
    final section = studentProvider.studentSection;
    final grade =
        (className.isNotEmpty || section.isNotEmpty)
            ? '$className $section'.trim()
            : 'Class N/A';

    final rollNumber = user?.student?.rollNumber ?? 'N/A';

    // Get GPA from dashboard stats
    final statsData = studentProvider.dashboardStats;
    final gpa = statsData?['gpa']?.toString();

    return CustomMainScreenWithAppbar(
      title: 'Question Paper',
      isLoading: _isLoading,
      appBarConfig: AppBarConfig.student(
        userInitials: userInitials,
        userName: userName,
        grade: grade,
        rollNumber: rollNumber,
        gpa: gpa,
        onNotificationIconPressed: () {},
        actions: [
          if (_questionPaper != null)
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Download PDF',
              padding: const EdgeInsets.only(right: 16),
              color: Colors.black, // Dark color for profile app bar (white bg)
              onPressed: () async {
                try {
                  await PdfTemplateService.generateQuestionPaperPdf(
                    _questionPaper!,
                  );
                  if (context.mounted) {
                    showCustomSnackbar(
                      message: 'PDF downloaded successfully',
                      type: SnackbarType.success,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    showCustomSnackbar(
                      message: 'Failed to generate PDF: $e',
                      type: SnackbarType.warning,
                    );
                  }
                }
              },
            ),
        ],
      ),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    // _isLoading is handled by CustomMainScreenWithAppbar overlay
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _error?.replaceAll('Exception: ', '') ??
                  'Could not load question paper',
              textAlign: TextAlign.center,
              style: context.textTheme.h3.copyWith(color: AppTheme.slate800),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later or contact your teacher.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodySm.copyWith(
                color: AppTheme.slate500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchQuestionPaper,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_questionPaper == null) {
      return const Center(child: Text('No question paper found.'));
    }

    // Reuse the rendering logic similar to QuestionPaperPreviewScreen
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Center(
              child: Column(
                children: [
                  Text(
                    _questionPaper!.schoolName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _questionPaper!.schoolAddress,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: Text(
                      _questionPaper!.examName.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Exam Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Class:', _questionPaper!.className),
                      _buildDetailRow('Subject:', _questionPaper!.subject),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildDetailRow('Date:', _questionPaper!.date),
                      _buildDetailRow(
                        'Duration:',
                        '${_questionPaper!.duration} mins',
                      ),
                      _buildDetailRow(
                        'Max Marks:',
                        '${_questionPaper!.maxMarks}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2, height: 32),

            // Instructions
            if (_questionPaper!.instructions != null &&
                _questionPaper!.instructions!.isNotEmpty) ...[
              const Text(
                'General Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_questionPaper!.instructions!),
              const Divider(thickness: 2, height: 32),
            ],

            // Sections and Questions
            ..._questionPaper!.sections.map(_buildSection),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );

  Widget _buildSection(QuestionSection section) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            section.sectionName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        if (section.description != null) ...[
          const SizedBox(height: 4),
          Center(
            child: Text(
              section.description!,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        ...section.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          return _buildQuestion(question, index + 1, section.marksPerQuestion);
        }),
        const SizedBox(height: 24),
      ],
    );

  Widget _buildQuestion(Question question, int number, int defaultMarks) {
    final marks = question.customMarks ?? defaultMarks;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.questionText,
                  style: const TextStyle(fontSize: 14),
                ),
                if (question.hasImage && question.imagePlaceholder != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        question.imagePlaceholder!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),

                // Display MCQ Options if available
                if (question.type == QuestionType.mcq &&
                    question.mcqOptions != null) ...[
                  const SizedBox(height: 8),
                  ...question.mcqOptions!.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final option = entry.value;
                    final letter = String.fromCharCode(65 + idx); // A, B, C...
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            '($letter) ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Expanded(child: Text(option)),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '[$marks]',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
