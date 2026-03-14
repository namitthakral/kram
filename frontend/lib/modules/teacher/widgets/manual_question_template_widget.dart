import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/extensions.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../models/template_models.dart';
import 'question_sections_builder.dart';

/// Widget for creating a manual question paper template without headers.
/// Uses the same question paper creation template as examinations for consistency.
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
    sections =
        widget.existingSections != null
            ? List<QuestionSection>.from(widget.existingSections!)
            : [];

    if (sections.isEmpty) {
      sections.add(
        QuestionSection(
          sectionName: 'Section A',
          questions: [Question(questionText: 'Question 1 here')],
          marksPerQuestion: 1,
        ),
      );
    }
  }

  void _saveAndPop() {
    Navigator.pop(context, sections);
  }

  Widget _buildFloatingSaveButton() => DecoratedBox(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: CustomAppColors.primaryBlue.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: FloatingActionButton.extended(
      onPressed: _saveAndPop,
      backgroundColor: CustomAppColors.primaryBlue,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      label: const Text(
        'Save',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );

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
      title: 'Manual Question Template',
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        onNotificationIconPressed: () {},
      ),
      floatingActionButton: _buildFloatingSaveButton(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomAppColors.blue50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CustomAppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: CustomAppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manual Question Template',
                          style: context.textTheme.h5.copyWith(
                            color: CustomAppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create questions without header info. Same template as examinations for consistency.',
                          style: context.textTheme.bodySm.copyWith(
                            color: CustomAppColors.slate600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            QuestionSectionsBuilder(
              sections: sections,
              onSectionsChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }
}
