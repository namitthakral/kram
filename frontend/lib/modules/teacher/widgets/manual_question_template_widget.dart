import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/custom_colors.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../models/template_models.dart';

/// Widget for creating a manual question paper template without headers
/// This allows teachers to create questions that can be manually processed
class ManualQuestionTemplateWidget extends StatefulWidget {
  const ManualQuestionTemplateWidget({
    this.existingSections,
    this.subjectName = 'Subject',
    super.key,
  });

  final List<QuestionSection>? existingSections;
  final String subjectName;

  @override
  State<ManualQuestionTemplateWidget> createState() =>
      _ManualQuestionTemplateWidgetState();
}

class _ManualQuestionTemplateWidgetState
    extends State<ManualQuestionTemplateWidget> {
  late List<QuestionSection> sections;

  @override
  void initState() {
    super.initState();
    sections = widget.existingSections ?? [];

    // If no existing sections, add a default section
    if (sections.isEmpty) {
      sections.add(
        QuestionSection(
          sectionName: 'Section A',
          questions: [
            Question(questionText: 'Question 1 here'),
          ],
          marksPerQuestion: 1,
        ),
      );
    }
  }

  void _addSection() {
    final sectionNameController = TextEditingController(
      text: 'Section ${String.fromCharCode(65 + sections.length)}',
    );
    final descriptionController = TextEditingController();
    final marksController = TextEditingController(text: '1');
    final questionsController = TextEditingController(text: '5');

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.blue500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_box,
                    color: AppTheme.blue500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add Section',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: sectionNameController,
                label: 'Section Name',
                hintText: 'e.g., Section A - Multiple Choice',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: descriptionController,
                label: 'Description (Optional)',
                hintText: 'e.g., Choose the correct answer',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: marksController,
                      label: 'Marks per Question',
                      hintText: '1',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: questionsController,
                      label: 'Number of Questions',
                      hintText: '5',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (sectionNameController.text.isNotEmpty) {
                final numQuestions = int.tryParse(questionsController.text) ?? 1;
                setState(() {
                  sections.add(
                    QuestionSection(
                      sectionName: sectionNameController.text,
                      questions: List.generate(
                        numQuestions,
                        (index) => Question(
                          questionText: 'Question ${index + 1} here',
                        ),
                      ),
                      marksPerQuestion: int.tryParse(marksController.text) ?? 1,
                      description: descriptionController.text.isEmpty
                          ? null
                          : descriptionController.text,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.blue500,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
          ),
        ),
      ),
    );
  }

  void _editSection(int sectionIndex) {
    final section = sections[sectionIndex];
    final sectionNameController = TextEditingController(
      text: section.sectionName,
    );
    final descriptionController = TextEditingController(
      text: section.description ?? '',
    );
    final marksController = TextEditingController(
      text: section.marksPerQuestion.toString(),
    );

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.blue500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: AppTheme.blue500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Edit Section',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.danger),
              onPressed: () {
                setState(() {
                  sections.removeAt(sectionIndex);
                });
                Navigator.pop(context);
              },
              tooltip: 'Delete Section',
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: sectionNameController,
                label: 'Section Name',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: descriptionController,
                label: 'Description (Optional)',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: marksController,
                label: 'Marks per Question',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                sections[sectionIndex] = QuestionSection(
                  sectionName: sectionNameController.text,
                  questions: section.questions,
                  marksPerQuestion: int.tryParse(marksController.text) ?? 1,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                );
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.blue500,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
          ),
        ),
      ),
    );
  }

  void _editQuestion(int sectionIndex, int questionIndex) {
    final question = sections[sectionIndex].questions[questionIndex];
    final questionController = TextEditingController(
      text: question.questionText,
    );
    final customMarksController = TextEditingController(
      text: question.customMarks?.toString() ?? '',
    );

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.blue500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.quiz,
                    color: AppTheme.blue500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Edit Question ${questionIndex + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.danger),
              onPressed: () {
                setState(() {
                  sections[sectionIndex].questions.removeAt(questionIndex);
                });
                Navigator.pop(context);
              },
              tooltip: 'Delete Question',
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: questionController,
                label: 'Question',
                maxLines: 4,
                hintText: 'Enter the question text...',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: customMarksController,
                label: 'Custom Marks (Optional)',
                hintText: 'Default: ${sections[sectionIndex].marksPerQuestion}',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                sections[sectionIndex].questions[questionIndex] = Question(
                  questionText: questionController.text,
                  customMarks: customMarksController.text.isEmpty
                      ? null
                      : int.tryParse(customMarksController.text),
                );
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.blue500,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
          ),
        ),
      ),
    );
  }

  int _calculateTotalMarks() => sections.fold(
        0,
        (sum, section) => sum + section.totalMarks,
      );

  int _calculateTotalQuestions() => sections.fold(
        0,
        (sum, section) => sum + section.questions.length,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Create Questions'),
          backgroundColor: AppTheme.blue500,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context, sections);
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.blue500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.blue500.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.blue500,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manual Question Template',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeBase,
                              fontWeight: AppTheme.fontWeightBold,
                              color: AppTheme.blue500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create questions without header info. Questions can be filled manually after printing.',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeSm,
                              color: AppTheme.slate600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.dashboard,
                      label: 'Sections',
                      value: sections.length.toString(),
                      color: AppTheme.blue500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.quiz,
                      label: 'Questions',
                      value: _calculateTotalQuestions().toString(),
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.stars,
                      label: 'Total Marks',
                      value: _calculateTotalMarks().toString(),
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sections header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Question Sections',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate800,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addSection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blue500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Section'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sections list
              ...List.generate(sections.length, _buildSectionCard),
            ],
          ),
        ),
      );

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomAppColors.lightGrey01),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.slate600,
              ),
            ),
          ],
        ),
      );

  Widget _buildSectionCard(int sectionIndex) {
    final section = sections[sectionIndex];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                section.sectionName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.blue500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${section.totalMarks} marks',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.blue500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: section.description != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  section.description!,
                  style: const TextStyle(fontSize: 13),
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => _editSection(sectionIndex),
          tooltip: 'Edit Section',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(
                  section.questions.length,
                  (qIndex) => _buildQuestionItem(sectionIndex, qIndex),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      section.questions.add(
                        Question(
                          questionText:
                              'Question ${section.questions.length + 1} here',
                        ),
                      );
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Question'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.blue500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(int sectionIndex, int questionIndex) {
    final question = sections[sectionIndex].questions[questionIndex];
    final marks =
        question.customMarks ?? sections[sectionIndex].marksPerQuestion;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CustomAppColors.slate50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CustomAppColors.lightGrey01),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.blue500,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${questionIndex + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.questionText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$marks marks',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => _editQuestion(sectionIndex, questionIndex),
            tooltip: 'Edit Question',
            color: AppTheme.slate600,
          ),
        ],
      ),
    );
  }
}
