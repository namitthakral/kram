import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/custom_colors.dart';
import '../../../widgets/custom_widgets/custom_dialog.dart';
import '../../../widgets/custom_widgets/custom_form_dialog.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../models/template_models.dart';

/// Shared question sections builder used by both examination and assignment flows.
/// Keeps Add Section / Edit Section / Edit Question UI consistent.
class QuestionSectionsBuilder extends StatefulWidget {
  const QuestionSectionsBuilder({
    required this.sections,
    required this.onSectionsChanged,
    this.showStats = true,
    this.onTotalMarksChanged,
    this.trailingWidget,
    super.key,
  });

  final List<QuestionSection> sections;
  final void Function(List<QuestionSection>) onSectionsChanged;
  final bool showStats;
  final void Function(int totalMarks)? onTotalMarksChanged;
  final Widget? trailingWidget;

  @override
  State<QuestionSectionsBuilder> createState() =>
      _QuestionSectionsBuilderState();
}

class _QuestionSectionsBuilderState extends State<QuestionSectionsBuilder> {
  List<QuestionSection> get sections => widget.sections;

  void _notifyChange() {
    widget.onSectionsChanged(List<QuestionSection>.from(sections));
    widget.onTotalMarksChanged?.call(_calculateTotalMarks());
  }

  int _calculateTotalMarks() =>
      sections.fold(0, (sum, section) => sum + section.totalMarks);

  int _calculateTotalQuestions() =>
      sections.fold(0, (sum, section) => sum + section.questions.length);

  void _addSection() {
    final sectionNameController = TextEditingController(
      text: 'Section ${String.fromCharCode(65 + sections.length)}',
    );
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
            maxWidth: 500,
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
                  _notifyChange();
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
                            _notifyChange();
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
                const SizedBox(height: 16),
                CustomTextField(
                  controller: marksController,
                  label: 'Marks per Question',
                  keyboardType: TextInputType.number,
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
                _notifyChange();
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
          (context) => QuestionEditDialog(
            question: question,
            questionNumber: questionIndex + 1,
            defaultMarks: sections[sectionIndex].marksPerQuestion,
            onSave: (updatedQuestion) {
              setState(() {
                sections[sectionIndex].questions[questionIndex] =
                    updatedQuestion;
                _notifyChange();
              });
              Navigator.pop(context);
            },
          ),
    );
  }

  void _addQuestion(int sectionIndex) {
    setState(() {
      sections[sectionIndex].questions.add(
        Question(
          questionText:
              'Question ${sections[sectionIndex].questions.length + 1} here',
        ),
      );
      _notifyChange();
    });
  }

  void _removeQuestion(int sectionIndex, int questionIndex) {
    setState(() {
      sections[sectionIndex].questions.removeAt(questionIndex);
      _notifyChange();
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (widget.showStats) ...[
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
      ],
      Row(
        children: [
          Text(
            'Question Sections',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  widget.showStats
                      ? const Color(0xFF1e293b)
                      : AppTheme.slate800,
            ),
          ),
          if (widget.showStats) ...[
            const SizedBox(width: 12),
            Text(
              'Total: ${_calculateTotalMarks()} marks',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
          const Spacer(),
          if (widget.trailingWidget != null) ...[
            widget.trailingWidget!,
            const SizedBox(width: 8),
          ],
          ElevatedButton.icon(
            onPressed: _addSection,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.blue500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      ...List.generate(sections.length, _buildSectionCard),
    ],
  );

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) => Container(
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
          style: const TextStyle(fontSize: 12, color: AppTheme.slate600),
        ),
      ],
    ),
  );

  Widget _buildSectionCard(int sectionIndex) {
    final section = sections[sectionIndex];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
          subtitle:
              section.description != null
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
                    onPressed: () => _addQuestion(sectionIndex),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
          IconButton(
            icon: const Icon(Icons.delete, size: 18, color: AppTheme.danger),
            onPressed: () => _removeQuestion(sectionIndex, questionIndex),
            tooltip: 'Delete Question',
          ),
        ],
      ),
    );
  }
}

/// Reusable dialog for editing a single question (Written/MCQ, marks, options).
class QuestionEditDialog extends StatefulWidget {
  const QuestionEditDialog({
    required this.question,
    required this.questionNumber,
    required this.defaultMarks,
    required this.onSave,
    super.key,
  });

  final Question question;
  final int questionNumber;
  final int defaultMarks;
  final void Function(Question) onSave;

  @override
  State<QuestionEditDialog> createState() => _QuestionEditDialogState();
}

class _QuestionEditDialogState extends State<QuestionEditDialog> {
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

    if (widget.question.mcqOptions != null) {
      for (final option in widget.question.mcqOptions!) {
        _optionControllers.add(TextEditingController(text: option));
      }
    } else if (_questionType == QuestionType.mcq) {
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
          CustomTextField(
            controller: _questionController,
            label: 'Question Text',
            maxLines: 3,
            hintText: 'Enter the question...',
          ),
          const SizedBox(height: 16),
          if (_hasImage) ...[
            CustomTextField(
              controller: _imagePlaceholderController,
              label: 'Image URL / Placeholder',
              hintText: 'Enter image URL or description',
            ),
            const SizedBox(height: 16),
          ],
          CustomTextField(
            controller: _customMarksController,
            label: 'Marks',
            keyboardType: TextInputType.number,
            hintText: 'Default: ${widget.defaultMarks}',
          ),
          const SizedBox(height: 24),
          if (_questionType == QuestionType.mcq) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Options',
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
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(
              _optionControllers.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: CustomAppColors.slate100,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slate600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: _optionControllers[index],
                        hintText: 'Option ${index + 1}',
                      ),
                    ),
                    if (_optionControllers.length > 2)
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                        onPressed: () => _removeOption(index),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ),
    onConfirm: () {
      if (_questionController.text.isNotEmpty) {
        final options =
            _questionType == QuestionType.mcq
                ? _optionControllers.map((c) => c.text).toList()
                : null;
        widget.onSave(
          Question(
            questionText: _questionController.text,
            type: _questionType,
            customMarks: int.tryParse(_customMarksController.text),
            hasImage: _hasImage,
            imagePlaceholder:
                _hasImage && _imagePlaceholderController.text.isNotEmpty
                    ? _imagePlaceholderController.text
                    : null,
            mcqOptions: options,
          ),
        );
        Navigator.pop(context);
      }
    },
  );

  Widget _buildTypeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.blue50 : Colors.white,
        border: Border.all(
          color: isSelected ? AppTheme.blue500 : CustomAppColors.lightGrey01,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.blue500 : AppTheme.slate500,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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
