import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_dialog.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../models/marks_models.dart';
import '../providers/marks_provider.dart';

class EnterMarksScreen extends StatelessWidget {
  const EnterMarksScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => MarksProvider(),
    child: const _EnterMarksContent(),
  );
}

class _EnterMarksContent extends StatelessWidget {
  const _EnterMarksContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarksProvider>();
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    // Use real user data
    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');
    final userName = user?.name ?? 'Teacher';
    final designation = teacher?.designation ?? 'Teacher';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: CustomMainScreenWithAppbar(
        title: 'Enter Marks',
        appBarConfig: AppBarConfig.teacher(
          userInitials: userInitials,
          userName: userName,
          designation: designation,
          employeeId: employeeId,
          onNotificationIconPressed: () {
            // Notification handler to be implemented
          },
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Navigation Link
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: CustomAppColors.primaryBlue,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Back to Academic Management',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeSm,
                          fontWeight: AppTheme.fontWeightMedium,
                          color: CustomAppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Header
              const Text(
                'Enter Marks',
                style: TextStyle(
                  fontSize: AppTheme.fontSize2xl,
                  fontWeight: AppTheme.fontWeightBold,
                  color: CustomAppColors.slate800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Quick marks entry for recent assessment',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSm,
                  color: CustomAppColors.slate600,
                ),
              ),
              const SizedBox(height: 20),

              // Class, Subject, Exam Type Row
              Row(
                children: [
                  Expanded(
                    child: _CompactDropdownCard(
                      label: 'Class',
                      value: provider.selectedClass?.name,
                      icon: Icons.class_,
                      onTap: () => _showClassPicker(context, provider),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CompactDropdownCard(
                      label: 'Subject',
                      value: provider.selectedSubject?.name,
                      icon: Icons.book,
                      onTap: () => _showSubjectPicker(context, provider),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CompactDropdownCard(
                      label: 'Exam Type',
                      value: provider.selectedExamType?.name,
                      icon: Icons.assignment,
                      onTap: () => _showExamTypePicker(context, provider),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Total Marks & Exam Date Row
              Row(
                children: [
                  Expanded(
                    child: _TotalMarksCard(
                      totalMarks: provider.totalMarks,
                      onChanged: provider.setTotalMarks,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExamDateCard(
                      examDate: provider.examDate,
                      onDateSelected: provider.setExamDate,
                    ),
                  ),
                ],
              ),

              if (provider.selectedClass != null) ...[
                const SizedBox(height: 20),

                // Students List
                if (provider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else ...[
                  ...provider.displayedStudents.map(
                    (student) => _StudentMarksCard(
                      student: student,
                      totalMarks: provider.totalMarks ?? 100,
                      onMarksChanged:
                          (marks) =>
                              provider.updateStudentMarks(student.id, marks),
                    ),
                  ),

                  if (provider.hasMoreStudents) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CustomAppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CustomAppColors.slate200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: CustomAppColors.slate600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Showing ${provider.displayedStudents.length} of ${provider.students.length} students. Open full marks entry module for complete list.',
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeXs,
                                color: CustomAppColors.slate600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Select class, subject, and exam type to begin',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeBase,
                            color: CustomAppColors.slate600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CustomAppColors.slate700,
                        side: const BorderSide(
                          color: CustomAppColors.slate300,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeBase,
                          fontWeight: AppTheme.fontWeightSemibold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed:
                          provider.canSave
                              ? () async {
                                final success = await provider.saveMarks();
                                if (context.mounted) {
                                  if (success) {
                                    showCustomSnackbar(
                                      message: 'Marks saved successfully',
                                      type: SnackbarType.success,
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    showCustomSnackbar(
                                      message:
                                          provider.error ?? 'Failed to save',
                                      type: SnackbarType.warning,
                                    );
                                  }
                                }
                              }
                              : null,
                      icon:
                          provider.isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.save_rounded, size: 20),
                      label: Text(
                        provider.isLoading ? 'Saving...' : 'Save Marks',
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeBase,
                          fontWeight: AppTheme.fontWeightSemibold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomAppColors.success,
                        foregroundColor: CustomAppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        disabledBackgroundColor: CustomAppColors.slate300,
                        disabledForegroundColor: CustomAppColors.slate500,
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

  // Show Class Picker
  Future<void> _showClassPicker(
    BuildContext context,
    MarksProvider provider,
  ) async {
    final selectedClass = await CustomDialog.showSelection<ClassInfo>(
      context: context,
      title: 'Select Class',
      subtitle: 'Choose the class to enter marks',
      headerIcon: Icons.class_,
      selectedValue: provider.selectedClass,
      items:
          provider.availableClasses
              .map(
                (classInfo) => SelectionItem<ClassInfo>(
                  value: classInfo,
                  label: classInfo.name,
                  subtitle: '${classInfo.totalStudents} students enrolled',
                  icon: Icons.school,
                ),
              )
              .toList(),
    );

    if (selectedClass != null) {
      provider.setSelectedClass(selectedClass);
    }
  }

  // Show Subject Picker
  Future<void> _showSubjectPicker(
    BuildContext context,
    MarksProvider provider,
  ) async {
    final selectedSubject = await CustomDialog.showSelection<SubjectInfo>(
      context: context,
      title: 'Select Subject',
      subtitle: 'Choose the subject for marks entry',
      headerIcon: Icons.book,
      selectedValue: provider.selectedSubject,
      items:
          provider.availableSubjects
              .map(
                (subject) => SelectionItem<SubjectInfo>(
                  value: subject,
                  label: subject.name,
                  icon: Icons.menu_book,
                ),
              )
              .toList(),
    );

    if (selectedSubject != null) {
      provider.setSelectedSubject(selectedSubject);
    }
  }

  // Show Exam Type Picker
  Future<void> _showExamTypePicker(
    BuildContext context,
    MarksProvider provider,
  ) async {
    final selectedExamType = await CustomDialog.showSelection<ExamType>(
      context: context,
      title: 'Select Exam Type',
      subtitle: 'Choose the type of examination',
      headerIcon: Icons.assignment,
      selectedValue: provider.selectedExamType,
      items:
          provider.availableExamTypes
              .map(
                (examType) => SelectionItem<ExamType>(
                  value: examType,
                  label: examType.name,
                  icon: Icons.assignment_turned_in,
                ),
              )
              .toList(),
    );

    if (selectedExamType != null) {
      provider.setSelectedExamType(selectedExamType);
    }
  }
}

// Compact Dropdown Card
class _CompactDropdownCard extends StatelessWidget {
  const _CompactDropdownCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CustomAppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              value != null
                  ? CustomAppColors.primaryBlue
                  : CustomAppColors.slate200,
          width: value != null ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CustomAppColors.black01.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: CustomAppColors.slate600),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: CustomAppColors.slate600,
                  fontWeight: AppTheme.fontWeightMedium,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: CustomAppColors.slate400,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'Select',
            style: TextStyle(
              fontSize: 15,
              fontWeight: AppTheme.fontWeightBold,
              color:
                  value != null
                      ? CustomAppColors.slate800
                      : CustomAppColors.slate400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

// Total Marks Card
class _TotalMarksCard extends StatelessWidget {
  const _TotalMarksCard({required this.totalMarks, required this.onChanged});

  final double? totalMarks;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: CustomAppColors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: CustomAppColors.black01.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.grading, size: 14, color: CustomAppColors.slate600),
            SizedBox(width: 4),
            Text(
              'Total Marks',
              style: TextStyle(
                fontSize: 11,
                color: CustomAppColors.slate600,
                fontWeight: AppTheme.fontWeightMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          key: const ValueKey('total_marks_input'),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          onChanged: (value) {
            final marks = double.tryParse(value);
            onChanged(marks);
          },
          style: const TextStyle(
            fontSize: AppTheme.fontSizeLg,
            fontWeight: AppTheme.fontWeightBold,
            color: CustomAppColors.slate800,
          ),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            hintText: '100',
            hintStyle: TextStyle(
              fontSize: AppTheme.fontSizeLg,
              fontWeight: AppTheme.fontWeightBold,
              color: CustomAppColors.slate400,
            ),
          ),
          controller: TextEditingController.fromValue(
            TextEditingValue(
              text: totalMarks?.toStringAsFixed(0) ?? '',
              selection: TextSelection.collapsed(
                offset: totalMarks?.toStringAsFixed(0).length ?? 0,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// Exam Date Card
class _ExamDateCard extends StatelessWidget {
  const _ExamDateCard({required this.examDate, required this.onDateSelected});

  final DateTime? examDate;
  final ValueChanged<DateTime?> onDateSelected;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async {
      final date = await showDatePicker(
        context: context,
        initialDate: examDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (date != null) {
        onDateSelected(date);
      }
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CustomAppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              examDate != null
                  ? CustomAppColors.primaryBlue
                  : CustomAppColors.slate200,
          width: examDate != null ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CustomAppColors.black01.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: CustomAppColors.slate600,
              ),
              SizedBox(width: 4),
              Text(
                'Exam Date',
                style: TextStyle(
                  fontSize: 11,
                  color: CustomAppColors.slate600,
                  fontWeight: AppTheme.fontWeightMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            examDate != null
                ? DateFormat('dd/MM/yyyy').format(examDate!)
                : 'dd/mm/yyyy',
            style: TextStyle(
              fontSize: 15,
              fontWeight: AppTheme.fontWeightBold,
              color:
                  examDate != null
                      ? CustomAppColors.slate800
                      : CustomAppColors.slate400,
            ),
          ),
        ],
      ),
    ),
  );
}

// Student Marks Card
class _StudentMarksCard extends StatelessWidget {
  const _StudentMarksCard({
    required this.student,
    required this.totalMarks,
    required this.onMarksChanged,
  });

  final StudentMarks student;
  final double totalMarks;
  final ValueChanged<double?> onMarksChanged;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: CustomAppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: CustomAppColors.slate200),
      boxShadow: [
        BoxShadow(
          color: CustomAppColors.black01.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [CustomAppColors.primaryBlue, Color(0xFF0c47d1)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                student.initials,
                style: const TextStyle(
                  color: CustomAppColors.white,
                  fontSize: AppTheme.fontSizeBase,
                  fontWeight: AppTheme.fontWeightBold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              student.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: AppTheme.fontWeightSemibold,
                color: CustomAppColors.slate800,
              ),
            ),
          ),

          // Marks Input
          Row(
            children: [
              const Text(
                'Marks',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeXs,
                  color: CustomAppColors.slate600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: CustomAppColors.slate50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CustomAppColors.slate300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: ValueKey('student_marks_${student.id}'),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeSm,
                          fontWeight: AppTheme.fontWeightSemibold,
                          color: CustomAppColors.slate800,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: '-',
                        ),
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: student.marks?.toStringAsFixed(0) ?? '',
                            selection: TextSelection.collapsed(
                              offset:
                                  student.marks?.toStringAsFixed(0).length ?? 0,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          final marks = double.tryParse(value);
                          onMarksChanged(marks);
                        },
                      ),
                    ),
                    Text(
                      ' / ${totalMarks.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeXs,
                        color: CustomAppColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
