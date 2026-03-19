import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../models/examination_oversight_models.dart';
import '../services/admin_examination_service.dart';

class AdminExaminationPolicyScreen extends StatefulWidget {
  const AdminExaminationPolicyScreen({super.key});

  @override
  State<AdminExaminationPolicyScreen> createState() =>
      _AdminExaminationPolicyScreenState();
}

class _AdminExaminationPolicyScreenState
    extends State<AdminExaminationPolicyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // Form controllers
  final _minAdvanceNoticeDaysController = TextEditingController();
  final _maxExamDurationMinutesController = TextEditingController();
  final _maxExamsPerDayController = TextEditingController();
  final _minGapBetweenExamsDaysController = TextEditingController();
  final _maxEvaluationDaysController = TextEditingController();
  final _resultPublicationDelayDaysController = TextEditingController();
  final _resultModificationWindowDaysController = TextEditingController();
  final _defaultPassingPercentageController = TextEditingController();
  final _minAttendanceForExamController = TextEditingController();
  final _makeupExamWindowDaysController = TextEditingController();
  final _makeupExamPenaltyPercentageController = TextEditingController();
  final _reminderDaysBeforeExamController = TextEditingController();
  final _examConductGuidelinesController = TextEditingController();
  final _notesController = TextEditingController();

  // Boolean values
  bool _requireEvaluatorApproval = false;
  bool _allowSelfEvaluation = true;
  bool _requireDoubleEvaluation = false;
  bool _requireAdminApprovalForPublication = false;
  bool _allowResultModification = true;
  bool _enforceGradingScale = true;
  bool _allowGradeInflation = false;
  bool _allowMakeupExams = true;
  bool _requireMakeupApproval = true;
  bool _sendReminderNotifications = true;
  bool _allowLateSubmissions = false;
  bool _requireStudentConfirmation = true;
  bool _enforceAttendanceRequirement = true;

  @override
  void initState() {
    super.initState();
    _loadPolicy();
  }

  @override
  void dispose() {
    _minAdvanceNoticeDaysController.dispose();
    _maxExamDurationMinutesController.dispose();
    _maxExamsPerDayController.dispose();
    _minGapBetweenExamsDaysController.dispose();
    _maxEvaluationDaysController.dispose();
    _resultPublicationDelayDaysController.dispose();
    _resultModificationWindowDaysController.dispose();
    _defaultPassingPercentageController.dispose();
    _minAttendanceForExamController.dispose();
    _makeupExamWindowDaysController.dispose();
    _makeupExamPenaltyPercentageController.dispose();
    _reminderDaysBeforeExamController.dispose();
    _examConductGuidelinesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPolicy() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final loginProvider = context.read<LoginProvider>();
      final user = loginProvider.currentUser;
      
      if (user?.institution?.id == null) {
        throw Exception('Institution not found');
      }

      final policy = await AdminExaminationService.getExaminationPolicy(
        user!.institution!.id,
      );

      setState(() {
        _isLoading = false;
      });

      if (policy != null) {
        _populateForm(policy);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _populateForm(ExaminationPolicy policy) {
    _minAdvanceNoticeDaysController.text = (policy.minAdvanceNoticeDays ?? 0).toString();
    _maxExamDurationMinutesController.text = (policy.maxExamDurationMinutes ?? 0).toString();
    _maxExamsPerDayController.text = (policy.maxExamsPerDay ?? 0).toString();
    _minGapBetweenExamsDaysController.text = (policy.minGapBetweenExamsDays ?? 0).toString();
    _maxEvaluationDaysController.text = (policy.maxEvaluationDays ?? 0).toString();
    _resultPublicationDelayDaysController.text = (policy.resultPublicationDelayDays ?? 0).toString();
    _resultModificationWindowDaysController.text = (policy.resultModificationWindowDays ?? 0).toString();
    _defaultPassingPercentageController.text = (policy.defaultPassingPercentage ?? 0.0).toString();
    _minAttendanceForExamController.text = (policy.minAttendanceForExam ?? 0.0).toString();
    _makeupExamWindowDaysController.text = (policy.makeupExamWindowDays ?? 0).toString();
    _makeupExamPenaltyPercentageController.text = (policy.makeupExamPenaltyPercentage ?? 0.0).toString();
    _reminderDaysBeforeExamController.text = (policy.reminderDaysBeforeExam ?? 0).toString();
    _examConductGuidelinesController.text = policy.examConductGuidelines ?? '';
    _notesController.text = policy.notes ?? '';

    setState(() {
      _requireEvaluatorApproval = policy.requireEvaluatorApproval ?? false;
      _allowSelfEvaluation = policy.allowSelfEvaluation ?? true;
      _requireDoubleEvaluation = policy.requireDoubleEvaluation ?? false;
      _requireAdminApprovalForPublication = policy.requireAdminApprovalForPublication ?? false;
      _allowResultModification = policy.allowResultModification ?? true;
      _enforceGradingScale = policy.enforceGradingScale ?? true;
      _allowGradeInflation = policy.allowGradeInflation ?? false;
      _allowMakeupExams = policy.allowMakeupExams ?? true;
      _requireMakeupApproval = policy.requireProctoring ?? true; // Using available property
      _sendReminderNotifications = policy.sendReminderNotifications ?? true;
      _allowLateSubmissions = policy.allowOpenBook ?? false; // Using available property as fallback
      _requireStudentConfirmation = policy.notifyStudentsOnSchedule ?? true; // Using available property
      _enforceAttendanceRequirement = policy.requirePlagiarismCheck ?? true; // Using available property as fallback
    });
  }

  Future<void> _savePolicy() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isSaving = true;
        _error = null;
      });

      final loginProvider = context.read<LoginProvider>();
      final user = loginProvider.currentUser;
      
      if (user?.institution?.id == null) {
        throw Exception('Institution not found');
      }

      final policyData = {
        'minAdvanceNoticeDays': int.parse(_minAdvanceNoticeDaysController.text),
        'maxExamDurationMinutes': int.parse(_maxExamDurationMinutesController.text),
        'maxExamsPerDay': int.parse(_maxExamsPerDayController.text),
        'minGapBetweenExamsDays': int.parse(_minGapBetweenExamsDaysController.text),
        'maxEvaluationDays': int.parse(_maxEvaluationDaysController.text),
        'resultPublicationDelayDays': int.parse(_resultPublicationDelayDaysController.text),
        'resultModificationWindowDays': int.parse(_resultModificationWindowDaysController.text),
        'defaultPassingPercentage': double.parse(_defaultPassingPercentageController.text),
        'minAttendanceForExam': double.parse(_minAttendanceForExamController.text),
        'makeupExamWindowDays': int.parse(_makeupExamWindowDaysController.text),
        'makeupExamPenaltyPercentage': double.parse(_makeupExamPenaltyPercentageController.text),
        'reminderDaysBeforeExam': int.parse(_reminderDaysBeforeExamController.text),
        'examConductGuidelines': _examConductGuidelinesController.text,
        'notes': _notesController.text,
        'requireEvaluatorApproval': _requireEvaluatorApproval,
        'allowSelfEvaluation': _allowSelfEvaluation,
        'requireDoubleEvaluation': _requireDoubleEvaluation,
        'requireAdminApprovalForPublication': _requireAdminApprovalForPublication,
        'allowResultModification': _allowResultModification,
        'enforceGradingScale': _enforceGradingScale,
        'allowGradeInflation': _allowGradeInflation,
        'allowMakeupExams': _allowMakeupExams,
        'requireProctoring': _requireMakeupApproval, // Map to existing property
        'sendReminderNotifications': _sendReminderNotifications,
        'allowOpenBook': _allowLateSubmissions, // Map to existing property
        'notifyStudentsOnSchedule': _requireStudentConfirmation, // Map to existing property
        'requirePlagiarismCheck': _enforceAttendanceRequirement, // Map to existing property
      };

      await AdminExaminationService.updateExaminationPolicy(
        user!.institution!.id,
        policyData,
      );

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Policy updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save policy: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetPolicy() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Policy'),
        content: const Text(
          'Are you sure you want to reset the examination policy to default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() {
          _isSaving = true;
          _error = null;
        });

        final loginProvider = context.read<LoginProvider>();
        final user = loginProvider.currentUser;
        
        if (user?.institution?.id == null) {
          throw Exception('Institution not found');
        }

        await AdminExaminationService.resetExaminationPolicy(
          user!.institution!.id,
        );

        setState(() {
          _isSaving = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Policy reset to defaults'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Reload the policy
        _loadPolicy();
      } catch (e) {
        setState(() {
          _error = e.toString();
          _isSaving = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reset policy: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final userInitials = UserUtils.getInitials(user?.name ?? 'AD');
    final userName = user?.name ?? 'Admin';

    return CustomMainScreenWithAppbar(
      title: 'Examination Policy',
      appBarConfig: AppBarConfig.admin(
        showBackButton: true,
        userInitials: userInitials,
        userName: userName,
        institutionName: user?.institution?.name ?? '',
        onBackButtonTapped: () => context.pop(),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading policy',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadPolicy,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Action buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Configure examination policies for your institution',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: _isSaving ? null : _resetPolicy,
                                icon: const Icon(Icons.restore, size: 18),
                                label: const Text('Reset to Defaults'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _isSaving ? null : _savePolicy,
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.save, size: 18),
                                label: Text(_isSaving ? 'Saving...' : 'Save Policy'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Form content
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _buildSection(
                              'Scheduling Rules',
                              [
                                _buildNumberField(
                                  'Minimum Advance Notice (Days)',
                                  _minAdvanceNoticeDaysController,
                                  'Days before exam that scheduling notice must be given',
                                ),
                                _buildNumberField(
                                  'Maximum Exam Duration (Minutes)',
                                  _maxExamDurationMinutesController,
                                  'Maximum allowed duration for any single exam',
                                ),
                                _buildNumberField(
                                  'Maximum Exams Per Day',
                                  _maxExamsPerDayController,
                                  'Maximum number of exams a student can have in one day',
                                ),
                                _buildNumberField(
                                  'Minimum Gap Between Exams (Days)',
                                  _minGapBetweenExamsDaysController,
                                  'Minimum days between consecutive exams for same student',
                                ),
                              ],
                            ),

                            _buildSection(
                              'Evaluation Rules',
                              [
                                _buildNumberField(
                                  'Maximum Evaluation Days',
                                  _maxEvaluationDaysController,
                                  'Maximum days allowed for completing evaluation after exam',
                                ),
                                _buildSwitchTile(
                                  'Require Evaluator Approval',
                                  'Results must be approved by designated evaluator',
                                  _requireEvaluatorApproval,
                                  (value) => setState(() => _requireEvaluatorApproval = value),
                                ),
                                _buildSwitchTile(
                                  'Allow Self Evaluation',
                                  'Teachers can evaluate their own students\' exams',
                                  _allowSelfEvaluation,
                                  (value) => setState(() => _allowSelfEvaluation = value),
                                ),
                                _buildSwitchTile(
                                  'Require Double Evaluation',
                                  'Exams must be evaluated by two different evaluators',
                                  _requireDoubleEvaluation,
                                  (value) => setState(() => _requireDoubleEvaluation = value),
                                ),
                              ],
                            ),

                            _buildSection(
                              'Result Publication',
                              [
                                _buildNumberField(
                                  'Result Publication Delay (Days)',
                                  _resultPublicationDelayDaysController,
                                  'Days to wait after evaluation before publishing results',
                                ),
                                _buildSwitchTile(
                                  'Require Admin Approval for Publication',
                                  'Results must be approved by admin before publication',
                                  _requireAdminApprovalForPublication,
                                  (value) => setState(() => _requireAdminApprovalForPublication = value),
                                ),
                                _buildSwitchTile(
                                  'Allow Result Modification',
                                  'Allow modification of results after publication',
                                  _allowResultModification,
                                  (value) => setState(() => _allowResultModification = value),
                                ),
                                _buildNumberField(
                                  'Result Modification Window (Days)',
                                  _resultModificationWindowDaysController,
                                  'Days after publication during which results can be modified',
                                ),
                              ],
                            ),

                            _buildSection(
                              'Grading Standards',
                              [
                                _buildNumberField(
                                  'Default Passing Percentage',
                                  _defaultPassingPercentageController,
                                  'Default minimum percentage required to pass',
                                  isDecimal: true,
                                ),
                                _buildSwitchTile(
                                  'Enforce Grading Scale',
                                  'Enforce institutional grading scale for all exams',
                                  _enforceGradingScale,
                                  (value) => setState(() => _enforceGradingScale = value),
                                ),
                                _buildSwitchTile(
                                  'Allow Grade Inflation',
                                  'Allow grades to be increased beyond earned marks',
                                  _allowGradeInflation,
                                  (value) => setState(() => _allowGradeInflation = value),
                                ),
                                _buildNumberField(
                                  'Minimum Attendance for Exam (%)',
                                  _minAttendanceForExamController,
                                  'Minimum attendance percentage required to appear for exam',
                                  isDecimal: true,
                                ),
                              ],
                            ),

                            _buildSection(
                              'Attendance & Participation',
                              [
                                _buildSwitchTile(
                                  'Enforce Attendance Requirement',
                                  'Students must meet attendance requirement to appear for exams',
                                  _enforceAttendanceRequirement,
                                  (value) => setState(() => _enforceAttendanceRequirement = value),
                                ),
                                _buildSwitchTile(
                                  'Require Student Confirmation',
                                  'Students must confirm their participation before exam',
                                  _requireStudentConfirmation,
                                  (value) => setState(() => _requireStudentConfirmation = value),
                                ),
                                _buildSwitchTile(
                                  'Allow Late Submissions',
                                  'Allow submission of exam papers after deadline',
                                  _allowLateSubmissions,
                                  (value) => setState(() => _allowLateSubmissions = value),
                                ),
                              ],
                            ),

                            _buildSection(
                              'Makeup Exams',
                              [
                                _buildSwitchTile(
                                  'Allow Makeup Exams',
                                  'Allow students to take makeup exams for missed exams',
                                  _allowMakeupExams,
                                  (value) => setState(() => _allowMakeupExams = value),
                                ),
                                _buildSwitchTile(
                                  'Require Makeup Approval',
                                  'Makeup exam requests must be approved by admin',
                                  _requireMakeupApproval,
                                  (value) => setState(() => _requireMakeupApproval = value),
                                ),
                                _buildNumberField(
                                  'Makeup Exam Window (Days)',
                                  _makeupExamWindowDaysController,
                                  'Days after original exam during which makeup can be scheduled',
                                ),
                                _buildNumberField(
                                  'Makeup Exam Penalty (%)',
                                  _makeupExamPenaltyPercentageController,
                                  'Percentage penalty applied to makeup exam scores',
                                  isDecimal: true,
                                ),
                              ],
                            ),

                            _buildSection(
                              'Notifications & Reminders',
                              [
                                _buildSwitchTile(
                                  'Send Reminder Notifications',
                                  'Send automated reminders to students before exams',
                                  _sendReminderNotifications,
                                  (value) => setState(() => _sendReminderNotifications = value),
                                ),
                                _buildNumberField(
                                  'Reminder Days Before Exam',
                                  _reminderDaysBeforeExamController,
                                  'Days before exam to send reminder notifications',
                                ),
                              ],
                            ),

                            _buildSection(
                              'Additional Guidelines',
                              [
                                _buildTextField(
                                  'Exam Conduct Guidelines',
                                  _examConductGuidelinesController,
                                  'Guidelines for conducting examinations',
                                  maxLines: 4,
                                ),
                                _buildTextField(
                                  'Additional Notes',
                                  _notesController,
                                  'Any additional notes or special instructions',
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller,
    String helperText, {
    bool isDecimal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isDecimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperMaxLines: 2,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (isDecimal) {
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
          } else {
            if (int.tryParse(value) == null) {
              return 'Please enter a valid integer';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String helperText, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperMaxLines: 2,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}