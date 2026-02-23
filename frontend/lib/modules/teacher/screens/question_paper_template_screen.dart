import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/services/class_section_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_form_section.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../models/examination_models.dart';
import '../models/template_models.dart';
import '../providers/examination_provider.dart';
import '../providers/question_paper_provider.dart';
import '../services/pdf_template_service.dart';
import '../widgets/question_sections_builder.dart';
import 'question_paper_preview_screen.dart';

class QuestionPaperTemplateScreen extends StatefulWidget {
  const QuestionPaperTemplateScreen({super.key, this.paperId});

  final int? paperId;

  @override
  State<QuestionPaperTemplateScreen> createState() =>
      _QuestionPaperTemplateScreenState();
}

class _QuestionPaperTemplateScreenState
    extends State<QuestionPaperTemplateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _examNameController = TextEditingController(
    text: 'Mid-Term Examination',
  );
  final _dateController = TextEditingController(
    text: DateFormat('d MMMM, yyyy').format(DateTime.now()),
  );
  final _durationController = TextEditingController(text: '180');
  final _maxMarksController = TextEditingController(text: '100');
  final _instructionsController = TextEditingController(
    text:
        '1. All questions are compulsory.\n'
        '2. Write your answers in the space provided.\n'
        '3. Use of calculators is not permitted.\n'
        '4. Read each question carefully before answering.',
  );

  // Exam Name Dropdown
  bool _isCustomExamName = false;
  final List<String> _examNames = [
    'Add manually',
    'Mid-Term Examination',
    'Final Examination',
    'Unit Test 1',
    'Unit Test 2',
    'Half Yearly Examination',
    'Annual Examination',
  ];
  String? _selectedExamNameDropdown;

  // Data
  Map<int, String> _coursesMap = {}; // ID -> Name (Class)
  Map<int, List<Map<String, dynamic>>> _courseSubjectsMap =
      {}; // CourseID -> List<SubjectObj>
  Map<int, String> _subjectsMap = {}; // Keep this for easy lookup!

  // Selected values
  int? _selectedCourseId;
  int? _selectedSubjectId;

  bool _isLoadingData = false;

  // Sections
  final List<QuestionSection> sections = [];

  // Edit Mode Data
  int? _existingExaminationId;
  int? _originalSubjectId;

  @override
  void initState() {
    super.initState();
    // Load class sections when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClassSections();
      // Always add default sections, creating a "fresh" experience even when editing
      if (widget.paperId != null) {
        _loadPaperData(widget.paperId!);
      } else {
        // Add default sections only for new papers
        setState(() {
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
        });
      }
      _updateMaxMarks();
    });
  }

  Future<void> _loadPaperData(int paperId) async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final loginProvider = context.read<LoginProvider>();
      final userUuid = loginProvider.currentUser?.uuid;
      if (userUuid == null) {
        return;
      }

      final qpProvider = context.read<QuestionPaperProvider>();
      await qpProvider.loadQuestionPaperById(userUuid, paperId);

      if (!mounted) {
        return;
      }

      final paperWrapper = qpProvider.questionPaper;
      if (paperWrapper == null || paperWrapper['data'] == null) {
        throw Exception('Paper data not found');
      }

      final paper = paperWrapper['data'] as Map<String, dynamic>;
      final exam = paper['examination'] as Map<String, dynamic>?;
      final subject = exam?['subject'] as Map<String, dynamic>?;
      final course = subject?['course'] as Map<String, dynamic>?;

      // Safe Parsing Helpers
      int? parseInt(val) => val is int ? val : int.tryParse(val.toString());

      setState(() {
        _existingExaminationId = parseInt(paper['examinationId']);
        _examNameController.text = paper['title'] ?? exam?['examName'] ?? '';

        // Handle dropdowns
        if (course != null) {
          _selectedCourseId = parseInt(course['id']);
        }
        if (subject != null) {
          _selectedSubjectId = parseInt(subject['id']);
          _originalSubjectId = _selectedSubjectId;
        }

        // Handle Date
        final examDateStr = exam?['examDate'];
        if (examDateStr != null) {
          try {
            final dt = DateTime.parse(examDateStr.toString());
            _dateController.text = DateFormat('d MMMM, yyyy').format(dt);
          } on Exception catch (_) {}
        }

        // Other fields
        _durationController.text =
            exam?['durationMinutes']?.toString() ?? '180';
        _maxMarksController.text = paper['totalMarks']?.toString() ?? '100';
        _instructionsController.text = paper['instructions'] ?? '';

        // Sections
        sections.clear();
        final sectionsData = paper['sections'] as List<dynamic>?;
        if (sectionsData != null) {
          for (final sData in sectionsData) {
            final sMap = sData as Map<String, dynamic>;
            final questionsData = sMap['questions'] as List<dynamic>?;

            final parsedQuestions = <Question>[];
            if (questionsData != null) {
              for (final qData in questionsData) {
                final qMap = qData as Map<String, dynamic>;

                // Options
                final optionsData = qMap['options'] as List<dynamic>?;
                List<String>? mcqOptions;
                if (optionsData != null && optionsData.isNotEmpty) {
                  mcqOptions =
                      optionsData.map((o) => o['text'].toString()).toList();
                }

                parsedQuestions.add(
                  Question(
                    questionText: qMap['text'] ?? '',
                    type:
                        (qMap['questionType'] == 'MCQ')
                            ? QuestionType.mcq
                            : QuestionType.written,
                    customMarks: parseInt(qMap['marks']),
                    mcqOptions: mcqOptions,
                  ),
                );
              }
            }

            var estimatedMarks = 1;
            if (parsedQuestions.isNotEmpty &&
                parsedQuestions.first.customMarks != null) {
              estimatedMarks = parsedQuestions.first.customMarks!;
            }

            sections.add(
              QuestionSection(
                sectionName: sMap['name'] ?? 'Section',
                description: sMap['description'],
                marksPerQuestion: estimatedMarks,
                questions: parsedQuestions,
              ),
            );
          }
        }

        _isLoadingData = false;
        _updateMaxMarks();
      });
    } on Exception catch (e) {
      debugPrint('Error parsing paper data: $e');
      if (mounted) {
        setState(() => _isLoadingData = false);

        final isNotFound =
            e.toString().contains('404') || e.toString().contains('not found');
        if (isNotFound) {
          showCustomSnackbar(
            message: 'Question paper not found or has been deleted.',
            type: SnackbarType.warning,
          );
          // Optionally pop back?
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else {
          showCustomSnackbar(
            message: 'Error loading paper: $e',
            type: SnackbarType.error,
          );
        }
      }
    }
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
          _isLoadingData = false;
        });
        return;
      }

      final classSectionService = ClassSectionService();
      final sections = await classSectionService.getClassSections(
        institutionId: 1,
        teacherId: teacherId,
        status: 'ACTIVE',
      );

      // Process the data to extract Class (Course) -> Subject
      final coursesMap = <int, String>{};
      final courseSubjectsMap = <int, List<Map<String, dynamic>>>{};
      final subjectsMap = <int, String>{};

      for (final section in sections) {
        final sectionMap = section as Map<String, dynamic>;
        final subject = sectionMap['subject'] as Map<String, dynamic>?;
        final course = sectionMap['course'] as Map<String, dynamic>?;

        if (subject != null) {
          final subjectId = subject['id'] as int?;
          final subjectName = subject['name'] as String? ?? 'Unknown';
          if (subjectId != null) {
            subjectsMap[subjectId] = subjectName;
          }
        }

        if (course != null) {
          final courseId = course['id'] as int?;
          final courseName = course['name'] as String? ?? 'Unknown';

          if (courseId != null) {
            coursesMap[courseId] = courseName;

            if (subject != null) {
              if (!courseSubjectsMap.containsKey(courseId)) {
                courseSubjectsMap[courseId] = [];
              }
              // Avoid duplicates
              final existing = courseSubjectsMap[courseId]!.any(
                (s) => s['id'] == subject['id'],
              );
              if (!existing) {
                courseSubjectsMap[courseId]!.add(subject);
              }
            }
          }
        }
      }

      setState(() {
        _coursesMap = coursesMap;
        _courseSubjectsMap = courseSubjectsMap;
        _subjectsMap = subjectsMap;
        _isLoadingData = false;

        // Initialize Exam Name Dropdown
        if (_examNames.contains(_examNameController.text)) {
          _selectedExamNameDropdown = _examNameController.text;
          _isCustomExamName = false;
        } else {
          if (_examNameController.text.isEmpty) {
            _selectedExamNameDropdown = 'Mid-Term Examination';
            _examNameController.text = 'Mid-Term Examination';
          } else {
            _selectedExamNameDropdown = 'Add manually';
            _isCustomExamName = true;
          }
        }
      });
    } on Exception catch (e) {
      print('Error loading class sections: $e');
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _examNameController.dispose();
    _dateController.dispose();
    _durationController.dispose();
    _maxMarksController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _savePaper() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;
    final userUuid = user?.uuid;

    if (userUuid == null || teacher == null) {
      showCustomSnackbar(
        message: 'User information not found',
        type: SnackbarType.error,
      );
      return;
    }

    if (_selectedCourseId == null || _selectedSubjectId == null) {
      showCustomSnackbar(
        message: 'Please select class and subject',
        type: SnackbarType.error,
      );
      return;
    }

    setState(() {
      _isLoadingData = true;
    });

    var examinationId = _existingExaminationId;

    // If subject changed, we cannot use the existing examination (which is linked to the old subject)
    // We must treat this as a potentially new exam
    if (_originalSubjectId != null &&
        _selectedSubjectId != _originalSubjectId) {
      examinationId = null;
    }

    final examName =
        _isCustomExamName
            ? _examNameController.text.trim()
            : _selectedExamNameDropdown ?? 'Examination';

    // 1. Create Examination Payload (Only if creating new exam)
    var examDate = DateTime.now();
    try {
      final dateText = _dateController.text;
      if (dateText.isNotEmpty) {
        final cleanText = dateText.replaceAll(RegExp('(st|nd|rd|th)'), '');
        examDate = DateFormat('d MMMM, yyyy').parse(cleanText);
      }
    } on Exception catch (e) {
      debugPrint('Error parsing date: $e');
    }

    final durationMin = int.tryParse(_durationController.text) ?? 180;
    final totalMarksVal = int.tryParse(_maxMarksController.text) ?? 100;

    final examProvider = context.read<ExaminationProvider>();
    final qpProvider = context.read<QuestionPaperProvider>();

    try {
      // If we don't have an exam ID (New Paper), create one
      if (examinationId == null) {
        int? semesterId;
        if (examProvider.semesters.isNotEmpty) {
          semesterId = examProvider.semesters.first.id;
        } else {
          await examProvider.loadSemesters(userUuid);
          if (examProvider.semesters.isNotEmpty) {
            semesterId = examProvider.semesters.first.id;
          }
        }

        if (semesterId == null) {
          if (mounted) {
            setState(() => _isLoadingData = false);
            showCustomSnackbar(
              message: 'No active academic semester found.',
              type: SnackbarType.error,
            );
          }
          return;
        }

        final createExamDto = CreateExaminationDto(
          courseId: _selectedSubjectId!,
          semesterId: semesterId,
          examName: examName,
          examType: 'THEORY',
          totalMarks: totalMarksVal,
          passingMarks: (totalMarksVal * 0.4).toInt(),
          durationMinutes: durationMin,
          examDate: examDate,
          startTime: DateTime(
            examDate.year,
            examDate.month,
            examDate.day,
            9,
          ),
        );

        final successExam = await examProvider.createExamination(
          userUuid,
          createExamDto,
        );

        if (!successExam) {
          throw Exception(
            'Failed to create examination: ${examProvider.error}',
          );
        }

        final createdExam = examProvider.examinations.first;
        examinationId = createdExam.id;
      }

      // If updating, delete the OLD paper first to avoid duplicates (Simulate Full Update)
      // TODO: Ideally we should use a transaction or a better update endpoint
      if (widget.paperId != null) {
        try {
          await qpProvider.deleteQuestionPaper(userUuid, widget.paperId!);
        } on Exception catch (e) {
          debugPrint('Error deleting old paper: $e');
          // Continue anyway? If delete fails, we might have duplicate or error.
        }
      }

      // 3. Construct Question Paper Payload
      final sectionsPayload =
          sections
              .map(
                (section) => {
                  'sectionName': section.sectionName,
                  'instructions': '', // Ensure not null
                  'sortOrder': 0,
                  'questions':
                      section.questions.map((question) {
                        List<Map<String, dynamic>>? optionsPayload;

                        if (question.mcqOptions != null) {
                          var optIndex = 0;
                          optionsPayload = [];
                          for (final optText in question.mcqOptions!) {
                            optionsPayload.add({
                              'optionText': optText,
                              'optionLabel': String.fromCharCode(65 + optIndex),
                              'isCorrect': false,
                            });
                            optIndex++;
                          }
                        }

                        return {
                          'questionText': question.questionText,
                          'questionType': _mapQuestionTypeToBackend(
                            question.type,
                          ),
                          'marks':
                              question.customMarks ?? section.marksPerQuestion,
                          'options':
                              optionsPayload ??
                              [], // Ensure not null just in case
                        };
                      }).toList(),
                },
              )
              .toList();

      final questionPaperPayload = {
        'examinationId': examinationId,
        'title': examName,
        'instructions': _instructionsController.text,
        'sections': sectionsPayload,
      };

      final successQP = await qpProvider.createFullQuestionPaper(
        userUuid,
        questionPaperPayload,
      );

      setState(() => _isLoadingData = false);

      if (successQP && mounted) {
        showCustomSnackbar(
          message:
              widget.paperId != null
                  ? 'Question Paper updated successfully!'
                  : 'Question Paper saved successfully!',
          type: SnackbarType.success,
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        showCustomSnackbar(
          message: qpProvider.createError ?? 'Failed to save question paper',
          type: SnackbarType.error,
        );
      }
    } on Exception catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        showCustomSnackbar(
          message: 'An unexpected error occurred: $e',
          type: SnackbarType.error,
        );
      }
    }
  }

  String _mapQuestionTypeToBackend(QuestionType type) {
    if (type == QuestionType.mcq) {
      return 'MCQ';
    }
    return 'SHORT_ANSWER';
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
                schoolName:
                    'Springfield High School', // TODO: Get from provider
                schoolAddress:
                    '123 Education Street', // TODO: Get from provider
                examName: _examNameController.text,
                className: courseName,
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

  void _updateMaxMarks() {
    _maxMarksController.text = _calculateTotalMarks().toString();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    var initialDate = now;

    try {
      final currentText = _dateController.text;
      if (currentText.isNotEmpty) {
        final cleanText = currentText.replaceAll(RegExp('(st|nd|rd|th)'), '');
        initialDate = DateFormat('d MMMM, yyyy').parse(cleanText);
      }
    } catch (_) {
      initialDate = now;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.blue500,
                onSurface: AppTheme.slate800,
              ),
            ),
            child: child!,
          ),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('d MMMM, yyyy').format(pickedDate);
      });
    }
  }

  Widget _buildClassDropdown() => Column(
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
                  value: _selectedCourseId,
                  underline: const SizedBox(),
                  hint: const Text(
                    'Select Class',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeBase,
                      color: CustomAppColors.grey01,
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeBase,
                    color: AppTheme.slate800,
                    fontWeight: FontWeight.normal,
                  ),
                  items:
                      _coursesMap.entries
                          .map(
                            (entry) => DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(
                                'Class ${entry.value}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (courseId) {
                    setState(() {
                      _selectedCourseId = courseId;
                      _selectedSubjectId = null;
                    });
                  },
                ),
      ),
    ],
  );

  Widget _buildSubjectDropdown() {
    final availableSubjects =
        _selectedCourseId != null
            ? (_courseSubjectsMap[_selectedCourseId] ?? [])
            : <Map<String, dynamic>>[];

    return Column(
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
          child: DropdownButton<int>(
            isExpanded: true,
            value: _selectedSubjectId,
            underline: const SizedBox(),
            hint: Text(
              _selectedCourseId == null
                  ? 'Select class first'
                  : 'Select subject',
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
                availableSubjects
                    .map(
                      (subject) => DropdownMenuItem<int>(
                        value: subject['id'] as int,
                        child: Text(subject['name'] as String? ?? 'Unknown'),
                      ),
                    )
                    .toList(),
            onChanged:
                _selectedCourseId == null
                    ? null
                    : (subjectId) {
                      setState(() {
                        _selectedSubjectId = subjectId;
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
              // Header
              Text(
                widget.paperId != null
                    ? 'Edit Question Paper'
                    : 'Create Question Paper',
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
                  // Exam Name Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Examination Name',
                        style: TextStyle(
                          fontWeight: AppTheme.fontWeightBold,
                          fontSize: AppTheme.fontSizeSm,
                          color: AppTheme.slate800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CustomAppColors.lightGrey01,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          color: CustomAppColors.slate50,
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedExamNameDropdown,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeBase,
                            color: AppTheme.slate800,
                            fontWeight: FontWeight.normal,
                          ),
                          items:
                              _examNames
                                  .map(
                                    (name) => DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: AppTheme.fontSizeBase,
                                          color: AppTheme.slate800,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedExamNameDropdown = value;
                              if (value == 'Add manually') {
                                _isCustomExamName = true;
                                _examNameController.clear();
                              } else {
                                _isCustomExamName = false;
                                _examNameController.text = value ?? '';
                              }
                            });
                          },
                        ),
                      ),
                      if (_isCustomExamName)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: CustomTextField(
                            hintText: 'Enter examination name',
                            controller: _examNameController,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Class Dropdown
                  _buildClassDropdown(),
                  const SizedBox(height: 16),

                  // Subject
                  _buildSubjectDropdown(),

                  const SizedBox(height: 16),

                  // Date, Duration, Max Marks
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Date',
                          controller: _dateController,
                          isEnabled: false, // Make read-only
                          onTap: _selectDate,
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: AppTheme.slate500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Duration (in minutes)',
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Max Marks',
                          controller: _maxMarksController,
                          keyboardType: TextInputType.number,
                          isEnabled: false, // Auto-calculated
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

              // Sections (shared with assignment manual template)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QuestionSectionsBuilder(
                  sections: sections,
                  onSectionsChanged: (_) => setState(() => _updateMaxMarks()),
                  showStats: false,
                  onTotalMarksChanged: (_) => _updateMaxMarks(),
                  trailingWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total: ${_calculateTotalMarks()} marks',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _previewPaper,
                        icon: const Icon(Icons.visibility),
                        label: const Text('Preview'),
                      ),
                    ],
                  ),
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
                    child: OutlinedButton.icon(
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
                              schoolName:
                                  'Springfield High School', // TODOprovider
                              schoolAddress:
                                  '123 Education Street', // TODOprovider
                              examName: _examNameController.text,
                              className: courseName,
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
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.blue500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: AppTheme.blue500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingData ? null : _savePaper,
                      icon:
                          _isLoadingData
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.save),
                      label: Text(
                        _isLoadingData ? 'Saving...' : 'Save Paper',
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

}
