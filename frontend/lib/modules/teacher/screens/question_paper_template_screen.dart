import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/class_section_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_dialog.dart';
import '../../../widgets/custom_widgets/custom_form_dialog.dart';
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

  // Dropdown data
  List<Map<String, dynamic>> _availableClassSections = [];
  Map<int, String> _subjectsMap = {}; // subjectId -> subjectName
  Map<int, String> _coursesMap = {}; // courseId -> courseName
  Map<int, List<String>> _sectionsMap = {}; // subjectId -> list of sections

  // Selected values
  int? _selectedSubjectId;
  int? _selectedCourseId;
  String? _selectedSection;

  bool _isLoadingData = false;

  // Sections
  final List<QuestionSection> sections = [];

  @override
  void initState() {
    super.initState();
    // Load class sections when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClassSections();
    });

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

  Future<void> _loadClassSections() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final loginProvider = context.read<LoginProvider>();
      final teacherId = loginProvider.currentUser?.teacher?.id;

      if (teacherId == null) {
        setState(() {
          _availableClassSections = [];
          _isLoadingData = false;
        });
        return;
      }

      final classSectionService = ClassSectionService();
      final sections = await classSectionService.getClassSections(
        teacherId: teacherId,
        status: 'ACTIVE',
      );

      // Process the data to extract subjects, courses, and sections
      final subjectsMap = <int, String>{};
      final coursesMap = <int, String>{};
      final sectionsMap = <int, Set<String>>{};

      for (final section in sections) {
        final sectionMap = section as Map<String, dynamic>;
        final subject = sectionMap['subject'] as Map<String, dynamic>?;
        final course = sectionMap['course'] as Map<String, dynamic>?;
        final sectionName = sectionMap['sectionName'] as String? ?? '';

        if (subject != null) {
          final subjectId = subject['id'] as int?;
          final subjectName = subject['name'] as String? ?? 'Unknown';
          final courseId = subject['courseId'] as int?;

          if (subjectId != null) {
            subjectsMap[subjectId] = subjectName;

            // Initialize sections set for this subject if not exists
            if (!sectionsMap.containsKey(subjectId)) {
              sectionsMap[subjectId] = <String>{};
            }
            if (sectionName.isNotEmpty) {
              sectionsMap[subjectId]!.add(sectionName);
            }
          }

          if (courseId != null && course != null) {
            final courseName = course['name'] as String? ?? 'Unknown';
            coursesMap[courseId] = courseName;
          }
        }
      }

      setState(() {
        _availableClassSections = sections.cast<Map<String, dynamic>>();
        _subjectsMap = subjectsMap;
        _coursesMap = coursesMap;
        _sectionsMap = sectionsMap.map(
          (key, value) => MapEntry(key, value.toList()..sort()),
        );
        _isLoadingData = false;
      });
    } on Exception catch (e) {
      print('Error loading class sections: $e');
      setState(() {
        _availableClassSections = [];
        _isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _schoolAddressController.dispose();
    _examNameController.dispose();
    _dateController.dispose();
    _durationController.dispose();
    _maxMarksController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _addSection() {
    final sectionNameController = TextEditingController();
    final descriptionController = TextEditingController();
    final marksController = TextEditingController(text: '1');
    final questionsController = TextEditingController(text: '5');

    showDialog<void>(
      context: context,
      builder:
          (context) => CustomFormDialog(
            title: 'Add Section',
            subtitle: 'Create a new section for the question paper',
            headerIcon: Icons.add_box,
            confirmText: 'Add',
            content: Column(
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
            ),
            onConfirm: () {
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
                      marksPerQuestion: int.tryParse(marksController.text) ?? 1,
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
      builder:
          (context) => CustomFormDialog(
            title: 'Edit Section',
            subtitle: 'Modify section details',
            headerIcon: Icons.edit,
            maxWidth: 550,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final confirm = await CustomDialog.showConfirmation(
                          context: context,
                          title: 'Delete Section',
                          message:
                              'Are you sure you want to delete this section?',
                          confirmText: 'Delete',
                          confirmColor: AppTheme.danger,
                          icon: Icons.delete,
                          iconColor: AppTheme.danger,
                        );
                        if (confirm == true && context.mounted) {
                          setState(() {
                            sections.removeAt(sectionIndex);
                          });
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete Section'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: sectionNameController,
                  label: 'Section Name',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: descriptionController,
                  label: 'Description (Optional)',
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      sections[sectionIndex] = QuestionSection(
                        sectionName: sectionNameController.text,
                        questions: section.questions,
                        marksPerQuestion:
                            int.tryParse(marksController.text) ?? 1,
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
            ),
            onConfirm: () {
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
          ),
    );
  }

  void _editQuestion(int sectionIndex, int questionIndex) {
    final question = sections[sectionIndex].questions[questionIndex];

    showDialog<void>(
      context: context,
      builder:
          (context) => _QuestionEditDialog(
            question: question,
            questionNumber: questionIndex + 1,
            defaultMarks: sections[sectionIndex].marksPerQuestion,
            onSave: (updatedQuestion) {
              setState(() {
                sections[sectionIndex].questions[questionIndex] =
                    updatedQuestion;
              });
            },
          ),
    );
  }

  void _previewPaper() {
    final subjectName =
        _selectedSubjectId != null
            ? _subjectsMap[_selectedSubjectId] ?? ''
            : '';
    final courseName =
        _selectedCourseId != null ? _coursesMap[_selectedCourseId] ?? '' : '';

    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuestionPaperPreviewScreen(
              template: QuestionPaperTemplate(
                schoolName: _schoolNameController.text,
                schoolAddress: _schoolAddressController.text,
                examName: _examNameController.text,
                className: courseName,
                section: _selectedSection ?? '',
                subject: subjectName,
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

  Widget _buildSubjectDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Subject',
        style: TextStyle(
          fontWeight: AppTheme.fontWeightBold,
          fontSize: AppTheme.fontSizeSm,
          color: AppTheme.slate800,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: CustomAppColors.lightGrey01),
          borderRadius: BorderRadius.circular(15),
          color: CustomAppColors.slate50,
        ),
        child:
            _isLoadingData
                ? const SizedBox(
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
                : DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedSubjectId,
                  underline: const SizedBox(),
                  hint: const Text(
                    'Select subject',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeBase,
                      color: CustomAppColors.grey01,
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeBase,
                    color: AppTheme.slate800,
                  ),
                  items:
                      _subjectsMap.entries
                          .map(
                            (entry) => DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                  onChanged: (subjectId) {
                    setState(() {
                      _selectedSubjectId = subjectId;
                      _selectedSection = null; // Reset section

                      // Find course ID for this subject
                      if (subjectId != null) {
                        for (final section in _availableClassSections) {
                          final subject =
                              section['subject'] as Map<String, dynamic>?;
                          if (subject != null && subject['id'] == subjectId) {
                            _selectedCourseId = subject['courseId'] as int?;
                            break;
                          }
                        }
                      }
                    });
                  },
                ),
      ),
    ],
  );

  Widget _buildCourseDisplay() {
    final courseName =
        _selectedCourseId != null
            ? _coursesMap[_selectedCourseId] ?? 'Unknown'
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Class',
          style: TextStyle(
            fontWeight: AppTheme.fontWeightBold,
            fontSize: AppTheme.fontSizeSm,
            color: AppTheme.slate800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: CustomAppColors.lightGrey01),
            borderRadius: BorderRadius.circular(15),
            color: CustomAppColors.slate50,
          ),
          child: Text(
            courseName ?? 'Select subject first',
            style: TextStyle(
              fontSize: AppTheme.fontSizeBase,
              color:
                  courseName != null
                      ? AppTheme.slate800
                      : CustomAppColors.grey01,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionDropdown() {
    final availableSections =
        _selectedSubjectId != null
            ? (_sectionsMap[_selectedSubjectId] ?? [])
            : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Section',
          style: TextStyle(
            fontWeight: AppTheme.fontWeightBold,
            fontSize: AppTheme.fontSizeSm,
            color: AppTheme.slate800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: CustomAppColors.lightGrey01),
            borderRadius: BorderRadius.circular(15),
            color: CustomAppColors.slate50,
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedSection,
            underline: const SizedBox(),
            hint: Text(
              _selectedSubjectId == null
                  ? 'Select subject first'
                  : 'Select section',
              style: const TextStyle(
                fontSize: AppTheme.fontSizeBase,
                color: CustomAppColors.grey01,
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            style: const TextStyle(
              fontSize: AppTheme.fontSizeBase,
              color: AppTheme.slate800,
            ),
            items:
                availableSections
                    .map(
                      (section) => DropdownMenuItem<String>(
                        value: section,
                        child: Text(section),
                      ),
                    )
                    .toList(),
            onChanged:
                _selectedSubjectId == null
                    ? null
                    : (section) {
                      setState(() {
                        _selectedSection = section;
                      });
                    },
          ),
        ),
      ],
    );
  }

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
                  // CustomTextField(
                  //   label: 'School Address',
                  //   controller: _schoolAddressController,
                  //   maxLines: 2,
                  // ),
                  // const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Examination Name',
                    controller: _examNameController,
                  ),
                  const SizedBox(height: 16),
                  _buildSubjectDropdown(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildCourseDisplay()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSectionDropdown()),
                    ],
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
                        final subjectName =
                            _selectedSubjectId != null
                                ? _subjectsMap[_selectedSubjectId] ?? ''
                                : '';
                        final courseName =
                            _selectedCourseId != null
                                ? _coursesMap[_selectedCourseId] ?? ''
                                : '';

                        try {
                          await PdfTemplateService.generateQuestionPaperPdf(
                            QuestionPaperTemplate(
                              schoolName: _schoolNameController.text,
                              schoolAddress: _schoolAddressController.text,
                              examName: _examNameController.text,
                              className: courseName,
                              section: _selectedSection ?? '',
                              subject: subjectName,
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

// Question Edit Dialog
class _QuestionEditDialog extends StatefulWidget {
  const _QuestionEditDialog({
    required this.question,
    required this.questionNumber,
    required this.defaultMarks,
    required this.onSave,
  });

  final Question question;
  final int questionNumber;
  final int defaultMarks;
  final void Function(Question) onSave;

  @override
  State<_QuestionEditDialog> createState() => _QuestionEditDialogState();
}

class _QuestionEditDialogState extends State<_QuestionEditDialog> {
  late TextEditingController _questionController;
  late TextEditingController _customMarksController;
  late TextEditingController _imagePlaceholderController;
  late QuestionType _questionType;
  late bool _hasImage;
  final List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.question.questionText,
    );
    _customMarksController = TextEditingController(
      text: widget.question.customMarks?.toString() ?? '',
    );
    _imagePlaceholderController = TextEditingController(
      text: widget.question.imagePlaceholder ?? '',
    );
    _questionType = widget.question.type;
    _hasImage = widget.question.hasImage;

    // Initialize MCQ options
    if (widget.question.mcqOptions != null) {
      for (final option in widget.question.mcqOptions!) {
        _optionControllers.add(TextEditingController(text: option));
      }
    } else if (_questionType == QuestionType.mcq) {
      // Default 4 options for new MCQ questions
      for (var i = 0; i < 4; i++) {
        _optionControllers.add(TextEditingController());
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _customMarksController.dispose();
    _imagePlaceholderController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) => CustomFormDialog(
    title: 'Edit Question ${widget.questionNumber}',
    subtitle: 'Configure question details',
    headerIcon: Icons.quiz,
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Type Switch
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomAppColors.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CustomAppColors.lightGrey01),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Question Type',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeSm,
                    fontWeight: AppTheme.fontWeightBold,
                    color: AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeOption(
                        icon: Icons.edit_note,
                        label: 'Written',
                        isSelected: _questionType == QuestionType.written,
                        onTap: () {
                          setState(() {
                            _questionType = QuestionType.written;
                            _optionControllers.clear();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeOption(
                        icon: Icons.radio_button_checked,
                        label: 'MCQ',
                        isSelected: _questionType == QuestionType.mcq,
                        onTap: () {
                          setState(() {
                            _questionType = QuestionType.mcq;
                            if (_optionControllers.isEmpty) {
                              for (var i = 0; i < 4; i++) {
                                _optionControllers.add(TextEditingController());
                              }
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Has Image Switch
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomAppColors.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CustomAppColors.lightGrey01),
            ),
            child: Row(
              children: [
                const Icon(Icons.image, size: 20, color: AppTheme.slate600),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Include Image/Diagram',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeBase,
                      fontWeight: AppTheme.fontWeightMedium,
                      color: AppTheme.slate800,
                    ),
                  ),
                ),
                Switch(
                  value: _hasImage,
                  onChanged: (value) {
                    setState(() {
                      _hasImage = value;
                    });
                  },
                  activeThumbColor: AppTheme.blue500,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Question Text
          CustomTextField(
            controller: _questionController,
            label: 'Question Text',
            maxLines: 3,
            hintText: 'Enter the question...',
          ),

          const SizedBox(height: 16),

          // Image Placeholder (if image is enabled)
          if (_hasImage) ...[
            CustomTextField(
              controller: _imagePlaceholderController,
              label: 'Image Placeholder Text (Optional)',
              hintText: 'e.g., [Diagram will be inserted here]',
            ),
            const SizedBox(height: 16),
          ],

          // MCQ Options (if MCQ type)
          if (_questionType == QuestionType.mcq) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Answer Options',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeSm,
                    fontWeight: AppTheme.fontWeightBold,
                    color: AppTheme.slate800,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Option'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.blue500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._optionControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.blue500.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: const TextStyle(
                            fontWeight: AppTheme.fontWeightBold,
                            color: AppTheme.blue500,
                            fontSize: AppTheme.fontSizeSm,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: controller,
                        hintText: 'Option ${String.fromCharCode(65 + index)}',
                      ),
                    ),
                    if (_optionControllers.length > 2)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _removeOption(index),
                        color: AppTheme.danger,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Custom Marks
          CustomTextField(
            controller: _customMarksController,
            label: 'Custom Marks (Optional)',
            hintText: 'Default: ${widget.defaultMarks}',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    ),
    onConfirm: () {
      final mcqOptions =
          _questionType == QuestionType.mcq
              ? _optionControllers
                  .map((c) => c.text.trim())
                  .where((text) => text.isNotEmpty)
                  .toList()
              : null;

      final updatedQuestion = Question(
        questionText: _questionController.text,
        customMarks:
            _customMarksController.text.isEmpty
                ? null
                : int.tryParse(_customMarksController.text),
        type: _questionType,
        hasImage: _hasImage,
        imagePlaceholder:
            _hasImage && _imagePlaceholderController.text.isNotEmpty
                ? _imagePlaceholderController.text
                : null,
        mcqOptions: mcqOptions,
      );

      widget.onSave(updatedQuestion);
      Navigator.pop(context);
    },
  );

  Widget _buildTypeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppTheme.blue500.withValues(alpha: 0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppTheme.blue500 : CustomAppColors.lightGrey01,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? AppTheme.blue500 : AppTheme.slate600,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: AppTheme.fontSizeSm,
              fontWeight:
                  isSelected
                      ? AppTheme.fontWeightBold
                      : AppTheme.fontWeightMedium,
              color: isSelected ? AppTheme.blue500 : AppTheme.slate600,
            ),
          ),
        ],
      ),
    ),
  );
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number and text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$number. ',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Image placeholder (if exists)
          if (question.hasImage) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  color: Colors.grey[100],
                ),
                child: Center(
                  child: Text(
                    question.imagePlaceholder ?? '[Image/Diagram]',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // MCQ Options (if MCQ type)
          if (question.type == QuestionType.mcq &&
              question.mcqOptions != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...question.mcqOptions!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${String.fromCharCode(65 + index)}. ',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
