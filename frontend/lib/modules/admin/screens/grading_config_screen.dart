import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/login_signup/login_provider.dart';
import '../providers/grading_config_provider.dart';

class GradingConfigScreen extends StatefulWidget {
  const GradingConfigScreen({super.key});

  @override
  State<GradingConfigScreen> createState() => _GradingConfigScreenState();
}

class _GradingConfigScreenState extends State<GradingConfigScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConfig();
    });
  }

  Future<void> _loadConfig() async {
    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;

    // Get institutionId from student or teacher (admins/super_admins use teacher profile)
    final institutionId =
        user?.student?.institutionId ?? user?.teacher?.institutionId;

    if (institutionId != null) {
      await context.read<GradingConfigProvider>().loadConfig(institutionId);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Grading Configuration'),
      backgroundColor: const Color(0xFF4F7CFF),
    ),
    body: Consumer<GradingConfigProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${provider.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadConfig,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBanner(),
              const SizedBox(height: 24),
              _buildWeightsSection(provider),
              const SizedBox(height: 24),
              _buildGradeBoundariesSection(provider),
              const SizedBox(height: 24),
              _buildGradePointsSection(provider),
              const SizedBox(height: 24),
              _buildRiskThresholdsSection(provider),
              const SizedBox(height: 32),
              _buildActionButtons(provider),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    ),
  );

  Widget _buildInfoBanner() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.blue.shade200),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, color: Colors.blue.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Configure how grades are calculated and when students are flagged as at-risk. Changes apply immediately to new calculations.',
            style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
          ),
        ),
      ],
    ),
  );

  Widget _buildWeightsSection(GradingConfigProvider provider) => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart, color: Color(0xFF4F7CFF)),
              const SizedBox(width: 8),
              Text(
                'Grading Formula Weights',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Configure how different components contribute to the overall grade',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          _buildWeightSlider(
            label: 'Attendance',
            value: provider.attendanceWeight,
            onChanged: provider.updateAttendanceWeight,
          ),
          _buildWeightSlider(
            label: 'Assignments',
            value: provider.assignmentWeight,
            onChanged: provider.updateAssignmentWeight,
          ),
          _buildWeightSlider(
            label: 'Exams',
            value: provider.examWeight,
            onChanged: provider.updateExamWeight,
          ),
          _buildWeightSlider(
            label: 'Participation',
            value: provider.participationWeight,
            onChanged: provider.updateParticipationWeight,
          ),
          const SizedBox(height: 16),
          _buildTotalWeightIndicator(provider),
        ],
      ),
    ),
  );

  Widget _buildWeightSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            '${value.toInt()}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4F7CFF),
            ),
          ),
        ],
      ),
      Slider(
        value: value,
        max: 100,
        divisions: 20,
        activeColor: const Color(0xFF4F7CFF),
        onChanged: onChanged,
      ),
    ],
  );

  Widget _buildTotalWeightIndicator(GradingConfigProvider provider) {
    final total = provider.totalWeight;
    final isValid = provider.isWeightValid;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            color: isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            'Total: ${total.toInt()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isValid ? Colors.green.shade900 : Colors.red.shade900,
            ),
          ),
          if (!isValid) ...[
            const SizedBox(width: 8),
            Text(
              '(Must be 100%)',
              style: TextStyle(color: Colors.red.shade900),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGradeBoundariesSection(GradingConfigProvider provider) => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grade, color: Color(0xFF4F7CFF)),
              const SizedBox(width: 8),
              Text(
                'Grade Boundaries',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Set minimum percentage scores for each letter grade',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          _buildGradeBoundaryRow(
            grade: 'A+',
            value: provider.gradeAPlusThreshold,
            onChanged: provider.updateGradeAPlusThreshold,
            suffix: 'and above',
          ),
          _buildGradeBoundaryRow(
            grade: 'A',
            value: provider.gradeAThreshold,
            onChanged: provider.updateGradeAThreshold,
            suffix: 'to ${(provider.gradeAPlusThreshold - 1).toInt()}%',
          ),
          _buildGradeBoundaryRow(
            grade: 'B+',
            value: provider.gradeBPlusThreshold,
            onChanged: provider.updateGradeBPlusThreshold,
            suffix: 'to ${(provider.gradeAThreshold - 1).toInt()}%',
          ),
          _buildGradeBoundaryRow(
            grade: 'B',
            value: provider.gradeBThreshold,
            onChanged: provider.updateGradeBThreshold,
            suffix: 'to ${(provider.gradeBPlusThreshold - 1).toInt()}%',
          ),
          _buildGradeBoundaryRow(
            grade: 'C',
            value: provider.gradeCThreshold,
            onChanged: provider.updateGradeCThreshold,
            suffix: 'to ${(provider.gradeBThreshold - 1).toInt()}%',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'D Grade',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Below ${provider.gradeCThreshold.toInt()}%',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildGradeBoundaryRow({
    required String grade,
    required double value,
    required ValueChanged<double> onChanged,
    required String suffix,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            grade,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            max: 100,
            divisions: 100,
            activeColor: const Color(0xFF4F7CFF),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 120,
          child: Text(
            '${value.toInt()}% $suffix',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    ),
  );

  Widget _buildGradePointsSection(GradingConfigProvider provider) => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.functions, color: Color(0xFF4F7CFF)),
              const SizedBox(width: 8),
              Text(
                'Grade Points (GPA)',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Configure GPA values for each letter grade',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          _buildGradePointRow(
            grade: 'A+',
            value: provider.gradeAPlusPoints,
            onChanged: provider.updateGradeAPlusPoints,
          ),
          _buildGradePointRow(
            grade: 'A',
            value: provider.gradeAPoints,
            onChanged: provider.updateGradeAPoints,
          ),
          _buildGradePointRow(
            grade: 'B+',
            value: provider.gradeBPlusPoints,
            onChanged: provider.updateGradeBPlusPoints,
          ),
          _buildGradePointRow(
            grade: 'B',
            value: provider.gradeBPoints,
            onChanged: provider.updateGradeBPoints,
          ),
          _buildGradePointRow(
            grade: 'C',
            value: provider.gradeCPoints,
            onChanged: provider.updateGradeCPoints,
          ),
          _buildGradePointRow(
            grade: 'D',
            value: provider.gradeDPoints,
            onChanged: provider.updateGradeDPoints,
          ),
        ],
      ),
    ),
  );

  Widget _buildGradePointRow({
    required String grade,
    required double value,
    required ValueChanged<double> onChanged,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            grade,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            max: 5,
            divisions: 50,
            activeColor: const Color(0xFF4F7CFF),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 60,
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4F7CFF),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildRiskThresholdsSection(GradingConfigProvider provider) => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Risk Status Thresholds',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Configure when students are flagged for intervention',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          _buildRiskCategory(
            title: '🔴 At Risk',
            description: 'Students flagged if ANY metric falls below:',
            color: Colors.red,
            attendanceValue: provider.atRiskAttendance,
            onAttendanceChanged: provider.updateAtRiskAttendance,
            assignmentValue: provider.atRiskAssignment,
            onAssignmentChanged: provider.updateAtRiskAssignment,
            examValue: provider.atRiskExam,
            onExamChanged: provider.updateAtRiskExam,
            gpaValue: provider.atRiskGradePoints,
            onGpaChanged: provider.updateAtRiskGradePoints,
          ),
          const Divider(height: 32),
          _buildRiskCategory(
            title: '🟡 Needs Improvement',
            description: 'Students flagged if ANY metric falls below:',
            color: Colors.orange,
            attendanceValue: provider.needsImprovementAttendance,
            onAttendanceChanged: provider.updateNeedsImprovementAttendance,
            assignmentValue: provider.needsImprovementAssignment,
            onAssignmentChanged: provider.updateNeedsImprovementAssignment,
            examValue: provider.needsImprovementExam,
            onExamChanged: provider.updateNeedsImprovementExam,
            gpaValue: provider.needsImprovementGradePoints,
            onGpaChanged: provider.updateNeedsImprovementGradePoints,
          ),
        ],
      ),
    ),
  );

  Widget _buildRiskCategory({
    required String title,
    required String description,
    required Color color,
    required double attendanceValue,
    required ValueChanged<double> onAttendanceChanged,
    required double assignmentValue,
    required ValueChanged<double> onAssignmentChanged,
    required double examValue,
    required ValueChanged<double> onExamChanged,
    required double gpaValue,
    required ValueChanged<double> onGpaChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: color,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        description,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      const SizedBox(height: 12),
      _buildThresholdSlider(
        label: 'Attendance',
        value: attendanceValue,
        onChanged: onAttendanceChanged,
        suffix: '%',
      ),
      _buildThresholdSlider(
        label: 'Assignment Score',
        value: assignmentValue,
        onChanged: onAssignmentChanged,
        suffix: '%',
      ),
      _buildThresholdSlider(
        label: 'Exam Score',
        value: examValue,
        onChanged: onExamChanged,
        suffix: '%',
      ),
      _buildThresholdSlider(
        label: 'GPA',
        value: gpaValue,
        onChanged: onGpaChanged,
        suffix: '',
        max: 5.0,
      ),
    ],
  );

  Widget _buildThresholdSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required String suffix,
    double max = 100,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Expanded(
          child: Slider(
            value: value,
            max: max,
            divisions: max == 100 ? 100 : 50,
            activeColor: const Color(0xFF4F7CFF),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 60,
          child: Text(
            max == 100
                ? '${value.toInt()}$suffix'
                : '${value.toStringAsFixed(1)}$suffix',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    ),
  );

  Widget _buildActionButtons(GradingConfigProvider provider) {
    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;

    // Get institutionId from student or teacher (admins/super_admins use teacher profile)
    final institutionId =
        user?.student?.institutionId ?? user?.teacher?.institutionId;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (provider.hasUnsavedChanges)
          OutlinedButton(
            onPressed: provider.discardChanges,
            child: const Text('Discard Changes'),
          ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () => _showResetConfirmation(institutionId),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          child: const Text('Reset to Defaults'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed:
              provider.isWeightValid && institutionId != null
                  ? () => _saveConfig(provider, institutionId)
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F7CFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child:
              provider.isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Save Changes'),
        ),
      ],
    );
  }

  Future<void> _saveConfig(
    GradingConfigProvider provider,
    int institutionId,
  ) async {
    final success = await provider.saveConfig(institutionId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grading configuration saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showResetConfirmation(int? institutionId) async {
    if (institutionId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset to Defaults?'),
            content: const Text(
              'This will restore the standard grading formula. '
              'All custom settings will be lost. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Reset'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<GradingConfigProvider>();
      final success = await provider.resetToDefaults(institutionId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration reset to defaults successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset: ${provider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
