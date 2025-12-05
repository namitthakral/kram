import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_form_section.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../models/template_models.dart';
import '../services/pdf_template_service.dart';

class QuestionPaperTemplateScreen extends StatefulWidget {
  const QuestionPaperTemplateScreen({super.key});

  @override
  State<QuestionPaperTemplateScreen> createState() =>
      _QuestionPaperTemplateScreenState();
}

class _QuestionPaperTemplateScreenState
    extends State<QuestionPaperTemplateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Paper Info
  final _schoolNameController = TextEditingController(
    text: 'Springfield High School',
  );
  final _schoolAddressController = TextEditingController(
    text: '123 Education Street, Springfield, ST 12345',
  );
  final _examNameController = TextEditingController(
    text: 'Mid-Term Examination',
  );
  final _classNameController = TextEditingController(text: 'Class 10');
  final _sectionController = TextEditingController(text: 'A');
  final _subjectController = TextEditingController(text: 'Mathematics');
  final _dateController = TextEditingController(text: '15th December, 2024');
  final _durationController = TextEditingController(text: '3 Hours');
  final _maxMarksController = TextEditingController(text: '100');
  final _instructionsController = TextEditingController(
    text:
        '1. All questions are compulsory.\n'
        '2. Write your answers in the space provided.\n'
        '3. Use of calculators is not permitted.\n'
        '4. Read each question carefully before answering.',
  );

  // Sections
  final List<QuestionSection> sections = [];

  @override
  void initState() {
    super.initState();
    // Add default sections
    sections.addAll([
      QuestionSection(
        sectionName: 'Section A - Multiple Choice',
        questions: List.generate(
          5,
          (index) => Question(questionText: 'Question ${index + 1} here'),
        ),
        marksPerQuestion: 1,
        description: 'Choose the correct answer',
      ),
      QuestionSection(
        sectionName: 'Section B - Short Answer',
        questions: List.generate(
          5,
          (index) => Question(questionText: 'Question ${index + 1} here'),
        ),
        marksPerQuestion: 3,
        description: 'Answer in 2-3 sentences',
      ),
      QuestionSection(
        sectionName: 'Section C - Long Answer',
        questions: List.generate(
          3,
          (index) => Question(questionText: 'Question ${index + 1} here'),
        ),
        marksPerQuestion: 10,
        description: 'Answer in detail',
      ),
    ]);
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _schoolAddressController.dispose();
    _examNameController.dispose();
    _classNameController.dispose();
    _sectionController.dispose();
    _subjectController.dispose();
    _dateController.dispose();
    _durationController.dispose();
    _maxMarksController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _addSection() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final sectionNameController = TextEditingController();
        final descriptionController = TextEditingController();
        final marksController = TextEditingController(text: '1');
        final questionsController = TextEditingController(text: '5');

        return AlertDialog(
          title: const Text('Add Section'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: sectionNameController,
                  decoration: const InputDecoration(
                    labelText: 'Section Name',
                    hintText: 'e.g., Section A - Multiple Choice',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'e.g., Choose the correct answer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: marksController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Marks Per Question',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: questionsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of Questions',
                    border: OutlineInputBorder(),
                  ),
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
                  final numQuestions =
                      int.tryParse(questionsController.text) ?? 1;
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
                        marksPerQuestion:
                            int.tryParse(marksController.text) ?? 1,
                        description:
                            descriptionController.text.isEmpty
                                ? null
                                : descriptionController.text,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editSection(int sectionIndex) {
    final section = sections[sectionIndex];
    showDialog<void>(
      context: context,
      builder: (context) {
        final sectionNameController = TextEditingController(
          text: section.sectionName,
        );
        final descriptionController = TextEditingController(
          text: section.description ?? '',
        );
        final marksController = TextEditingController(
          text: section.marksPerQuestion.toString(),
        );

        return AlertDialog(
          title: const Text('Edit Section'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: sectionNameController,
                  decoration: const InputDecoration(
                    labelText: 'Section Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: marksController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Marks Per Question',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  sections.removeAt(sectionIndex);
                });
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
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
                    description:
                        descriptionController.text.isEmpty
                            ? null
                            : descriptionController.text,
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
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
      builder:
          (context) => AlertDialog(
            title: Text('Edit Question ${questionIndex + 1}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: questionController,
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: customMarksController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Custom Marks (Optional)',
                      hintText:
                          'Default: ${sections[sectionIndex].marksPerQuestion}',
                      border: const OutlineInputBorder(),
                    ),
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
                      customMarks:
                          customMarksController.text.isEmpty
                              ? null
                              : int.tryParse(customMarksController.text),
                    );
                  });
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _previewPaper() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuestionPaperPreviewScreen(
              template: QuestionPaperTemplate(
                schoolName: _schoolNameController.text,
                schoolAddress: _schoolAddressController.text,
                examName: _examNameController.text,
                className: _classNameController.text,
                section: _sectionController.text,
                subject: _subjectController.text,
                date: _dateController.text,
                duration: _durationController.text,
                maxMarks: int.tryParse(_maxMarksController.text) ?? 100,
                sections: sections,
                instructions: _instructionsController.text,
              ),
            ),
      ),
    );
  }

  int _calculateTotalMarks() =>
      sections.fold(0, (sum, section) => sum + section.totalMarks);

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');
    final userName = user?.name ?? 'Teacher';
    final designation = teacher?.designation ?? 'Teacher';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return CustomMainScreenWithAppbar(
      title: 'Question Paper Generator',
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        onNotificationIconPressed: () {},
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Navigation
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: AppTheme.blue500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Back to Academic Management',
                        style: context.textTheme.bodySm.copyWith(
                          fontWeight: AppTheme.fontWeightMedium,
                          color: AppTheme.blue500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Header
              Text(
                'Create Question Paper',
                style: context.textTheme.h2.copyWith(color: AppTheme.slate800),
              ),
              const SizedBox(height: 4),
              Text(
                'Design a traditional examination question paper',
                style: context.textTheme.bodySm.copyWith(
                  color: AppTheme.slate500,
                ),
              ),
              const SizedBox(height: 24),

              // Paper Information
              CustomFormSection(
                title: 'Examination Details',
                subtitle: 'Enter exam and school information',
                icon: Icons.description_outlined,
                children: [
                  CustomTextField(
                    label: 'School Name',
                    controller: _schoolNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'School Address',
                    controller: _schoolAddressController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Examination Name',
                    controller: _examNameController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Class',
                          controller: _classNameController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Section',
                          controller: _sectionController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Subject',
                    controller: _subjectController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Date',
                          controller: _dateController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Duration',
                          controller: _durationController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Max Marks',
                          controller: _maxMarksController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'General Instructions',
                    controller: _instructionsController,
                    maxLines: 5,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sections
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Question Sections',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1e293b),
                              ),
                            ),
                            Text(
                              'Total: ${_calculateTotalMarks()} marks',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: _previewPaper,
                              icon: const Icon(Icons.visibility),
                              label: const Text('Preview'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _addSection,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Section'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(sections.length, _buildSectionCard),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.slate500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: context.textTheme.labelBase.copyWith(
                          color: AppTheme.slate600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await PdfTemplateService.generateQuestionPaperPdf(
                            QuestionPaperTemplate(
                              schoolName: _schoolNameController.text,
                              schoolAddress: _schoolAddressController.text,
                              examName: _examNameController.text,
                              className: _classNameController.text,
                              section: _sectionController.text,
                              subject: _subjectController.text,
                              date: _dateController.text,
                              duration: _durationController.text,
                              maxMarks:
                                  int.tryParse(_maxMarksController.text) ?? 100,
                              sections: sections,
                              instructions: _instructionsController.text,
                            ),
                          );
                          if (context.mounted) {
                            showCustomSnackbar(
                              message: 'PDF downloaded successfully',
                              type: SnackbarType.success,
                            );
                          }
                        } on Exception catch (e) {
                          if (context.mounted) {
                            showCustomSnackbar(
                              message: 'Failed to generate PDF: $e',
                              type: SnackbarType.warning,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text(
                        'Generate PDF',
                        style: context.textTheme.labelBase,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.blue500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(int sectionIndex) {
    final section = sections[sectionIndex];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
            Text(
              '${section.totalMarks} marks',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        subtitle:
            section.description != null ? Text(section.description!) : null,
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _editSection(sectionIndex),
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
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
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

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF8b5cf6),
        radius: 16,
        child: Text(
          '${questionIndex + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(question.questionText, style: const TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text('$marks marks'),
            backgroundColor: Colors.grey[100],
            labelStyle: const TextStyle(fontSize: 12),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _editQuestion(sectionIndex, questionIndex),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            onPressed: () {
              setState(() {
                sections[sectionIndex].questions.removeAt(questionIndex);
              });
            },
          ),
        ],
      ),
    );
  }
}

// Preview Screen
class QuestionPaperPreviewScreen extends StatelessWidget {
  const QuestionPaperPreviewScreen({required this.template, super.key});

  final QuestionPaperTemplate template;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Question Paper Preview'),
      actions: [
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () async {
            try {
              await PdfTemplateService.generateQuestionPaperPdf(template);
              if (context.mounted) {
                showCustomSnackbar(
                  message: 'PDF downloaded successfully',
                  type: SnackbarType.success,
                );
              }
            } on Exception catch (e) {
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
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Text(
                    template.schoolName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    template.schoolAddress,
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(border: Border.all(width: 2)),
                    child: Text(
                      template.examName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Exam Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class: ${template.className} - ${template.section}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Subject: ${template.subject}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Date: ${template.date}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time: ${template.duration}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Max. Marks: ${template.maxMarks}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.black, thickness: 2),
            const SizedBox(height: 16),

            // Instructions
            if (template.instructions != null) ...[
              const Text(
                'GENERAL INSTRUCTIONS:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                template.instructions!,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black, thickness: 1),
              const SizedBox(height: 20),
            ],

            // Sections
            ...template.sections.map(_buildSection),

            const SizedBox(height: 32),

            // Footer
            const Center(
              child: Column(
                children: [
                  Divider(color: Colors.black),
                  SizedBox(height: 16),
                  Text(
                    '*** END OF QUESTION PAPER ***',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildSection(QuestionSection section) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.sectionName.toUpperCase(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            if (section.description != null) ...[
              const SizedBox(height: 4),
              Text(
                section.description!,
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
      ...List.generate(
        section.questions.length,
        (index) => _buildQuestion(
          index + 1,
          section.questions[index],
          section.marksPerQuestion,
        ),
      ),
      const SizedBox(height: 24),
    ],
  );

  Widget _buildQuestion(int number, Question question, int defaultMarks) {
    final marks = question.customMarks ?? defaultMarks;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              question.questionText,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(border: Border.all()),
            child: Text(
              '[$marks]',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
