import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../widgets/custom_widgets/custom_dialog.dart';
import '../../../widgets/custom_widgets/responsive_layout.dart';
import '../providers/grading_config_provider.dart';
import '../services/admin_service.dart';

class GradingConfigScreen extends StatefulWidget {
  const GradingConfigScreen({super.key});

  @override
  State<GradingConfigScreen> createState() => _GradingConfigScreenState();
}

class _GradingConfigScreenState extends State<GradingConfigScreen> {
  final AdminService _adminService = AdminService();
  String? _institutionType;
  Map<String, dynamic>? _restrictionInfo;
  bool _isLoadingRestriction = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInstitutionInfo();
      _loadConfig();
    });
  }

  Future<void> _loadInstitutionInfo() async {
    try {
      setState(() {
        _isLoadingRestriction = true;
      });

      final institutionInfo = await _adminService.getInstitutionInfo(_institutionId);
      final restrictionInfo = await _adminService.checkGradingRestriction(_institutionId);
      
      setState(() {
        _institutionType = institutionInfo['type'];
        _restrictionInfo = restrictionInfo;
        _isLoadingRestriction = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRestriction = false;
      });
      print('Error loading institution info: $e');
    }
  }

  Future<void> _loadConfig() async {
    await context.read<GradingConfigProvider>().loadConfig(_institutionId);
  }

  int get _institutionId {
    final loginProvider = context.read<LoginProvider>();
    final user = loginProvider.currentUser;
    return user?.institutionId ??           // For admin users
        user?.student?.institutionId ??  // For student users
        user?.teacher?.institutionId ??  // For teacher users
        user?.staff?.institutionId ??    // For staff users
        1; // Fallback - should rarely be used
  }

  String get _periodType {
    return _institutionType == 'SCHOOL' ? 'term' : 'semester';
  }

  String get _periodTypeCapitalized {
    return _institutionType == 'SCHOOL' ? 'Term' : 'Semester';
  }

  bool get _isRestricted {
    return _restrictionInfo?['isRestricted'] ?? false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.slate100,
    body: Consumer<GradingConfigProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.attendanceWeight == 0) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.blue500),
          );
        }

        if (provider.error != null && provider.attendanceWeight == 0) {
          return _buildErrorState(provider);
        }

        return ResponsiveLayout(
          mobile: _buildMobileLayout(provider),
          tablet: _buildDesktopLayout(provider),
          desktop: _buildDesktopLayout(provider),
        );
      },
    ),
  );

  Widget _buildErrorState(GradingConfigProvider provider) => Center(
    child: Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.danger.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.danger,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Failed to Load Configuration',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.slate800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error ?? 'An unexpected error occurred',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.slate500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadConfig,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.blue500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildMobileLayout(GradingConfigProvider provider) => Column(
    children: [
      _buildMobileHeader(),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_isLoadingRestriction)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppTheme.blue500),
                  ),
                )
              else ...[
                _buildRestrictionBanner(),
                _buildInfoBanner(),
              ],
              const SizedBox(height: 20),
              _buildWeightsSection(provider),
              const SizedBox(height: 20),
              _buildGradeBoundariesSection(provider),
              const SizedBox(height: 20),
              _buildGradePointsSection(provider),
              const SizedBox(height: 20),
              _buildRiskThresholdsSection(provider),
              const SizedBox(height: 24),
              _buildActionButtons(provider),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildDesktopLayout(GradingConfigProvider provider) => SafeArea(
    child: ResponsivePadding(
      desktop: const EdgeInsets.all(32),
      tablet: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildDesktopHeader(),
          const SizedBox(height: 32),
          Expanded(
            child: ResponsiveCenter(
              maxWidth: 1000,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_isLoadingRestriction)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: AppTheme.blue500),
                        ),
                      )
                    else ...[
                      _buildRestrictionBanner(),
                      _buildInfoBanner(),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildWeightsSection(provider),
                              const SizedBox(height: 24),
                              _buildGradeBoundariesSection(provider),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [
                              _buildGradePointsSection(provider),
                              const SizedBox(height: 24),
                              _buildRiskThresholdsSection(provider),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildActionButtons(provider),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildMobileHeader() => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppTheme.blue500, AppTheme.blue600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.blue600.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.tune,
                  size: 32,
                  color: AppTheme.blue500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Grading Configuration',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Configure Grading System',
                style: TextStyle(
                  color: AppTheme.blue600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildDesktopHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppTheme.blue500, AppTheme.blue600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppTheme.blue500.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grading Configuration',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure grading formula, boundaries, and risk thresholds',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildRestrictionBanner() {
    if (!_isRestricted || _restrictionInfo == null) {
      return const SizedBox.shrink();
    }

    final details = _restrictionInfo!['details'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.warning.withValues(alpha: 0.1),
            AppTheme.warning.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.warning,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grading Configuration Locked',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.warning,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Active $_periodTypeCapitalized: ${details['activePeriod']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.slate800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Academic Year: ${details['academicYear']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.slate600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      '📚 Why is this locked?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Grading configuration cannot be changed during an active $_periodType to ensure '
                  'all students are evaluated using the same grading standards throughout the $_periodType.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.slate600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: AppTheme.slate500),
                    const SizedBox(width: 8),
                    Text(
                      'Changes allowed after: ${_formatDate(details['endDate'])}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.slate600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildInfoBanner() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppTheme.info.withValues(alpha: 0.1),
          AppTheme.blue500.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.info,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.lightbulb_outline,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuration Guide',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.slate800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Configure how grades are calculated and when students are flagged as at-risk. Changes apply immediately to new calculations.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.slate600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildWeightsSection(GradingConfigProvider provider) => _buildCard(
    icon: Icons.pie_chart_rounded,
    iconColor: AppTheme.blue500,
    title: 'Grading Formula Weights',
    subtitle: 'Configure how different components contribute to the overall grade',
    child: Column(
      children: [
        _buildWeightItem(
          label: 'Attendance',
          icon: Icons.calendar_today,
          value: provider.attendanceWeight,
          onChanged: provider.updateAttendanceWeight,
          color: const Color(0xFF10B981),
        ),
        _buildWeightItem(
          label: 'Assignments',
          icon: Icons.assignment,
          value: provider.assignmentWeight,
          onChanged: provider.updateAssignmentWeight,
          color: const Color(0xFF3B82F6),
        ),
        _buildWeightItem(
          label: 'Exams',
          icon: Icons.quiz,
          value: provider.examWeight,
          onChanged: provider.updateExamWeight,
          color: const Color(0xFF8B5CF6),
        ),
        _buildWeightItem(
          label: 'Participation',
          icon: Icons.record_voice_over,
          value: provider.participationWeight,
          onChanged: provider.updateParticipationWeight,
          color: const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 16),
        _buildTotalWeightIndicator(provider),
      ],
    ),
  );

  Widget _buildWeightItem({
    required String label,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
    required Color color,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.slate800,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${value.toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            max: 100,
            divisions: 20,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );

  Widget _buildTotalWeightIndicator(GradingConfigProvider provider) {
    final total = provider.totalWeight;
    final isValid = provider.isWeightValid;
    final color = isValid ? AppTheme.success : AppTheme.danger;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isValid ? Icons.check : Icons.warning,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Weight: ${total.toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                if (!isValid)
                  const Text(
                    'Weights must add up to 100%',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.danger,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeBoundariesSection(GradingConfigProvider provider) => _buildCard(
    icon: Icons.leaderboard_rounded,
    iconColor: const Color(0xFF8B5CF6),
    title: 'Grade Boundaries',
    subtitle: 'Set minimum percentage scores for each letter grade',
    child: Column(
      children: [
        _buildGradeBoundaryItem('A+', provider.gradeAPlusThreshold, provider.updateGradeAPlusThreshold, const Color(0xFF10B981), '${provider.gradeAPlusThreshold.toInt()}% and above'),
        _buildGradeBoundaryItem('A', provider.gradeAThreshold, provider.updateGradeAThreshold, const Color(0xFF22C55E), '${provider.gradeAThreshold.toInt()}% - ${(provider.gradeAPlusThreshold - 1).toInt()}%'),
        _buildGradeBoundaryItem('B+', provider.gradeBPlusThreshold, provider.updateGradeBPlusThreshold, const Color(0xFF3B82F6), '${provider.gradeBPlusThreshold.toInt()}% - ${(provider.gradeAThreshold - 1).toInt()}%'),
        _buildGradeBoundaryItem('B', provider.gradeBThreshold, provider.updateGradeBThreshold, const Color(0xFF6366F1), '${provider.gradeBThreshold.toInt()}% - ${(provider.gradeBPlusThreshold - 1).toInt()}%'),
        _buildGradeBoundaryItem('C', provider.gradeCThreshold, provider.updateGradeCThreshold, const Color(0xFFF59E0B), '${provider.gradeCThreshold.toInt()}% - ${(provider.gradeBThreshold - 1).toInt()}%'),
        _buildStaticGradeItem('D', const Color(0xFFEF4444), 'Below ${provider.gradeCThreshold.toInt()}%'),
      ],
    ),
  );

  Widget _buildGradeBoundaryItem(
    String grade,
    double value,
    ValueChanged<double> onChanged,
    Color color,
    String range,
  ) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.slate100,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              grade,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              max: 100,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 90,
          child: Text(
            range,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.slate600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );

  Widget _buildStaticGradeItem(String grade, Color color, String range) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              grade,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Lowest Grade',
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          range,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _buildGradePointsSection(GradingConfigProvider provider) => _buildCard(
    icon: Icons.analytics_rounded,
    iconColor: const Color(0xFF10B981),
    title: 'Grade Points (GPA)',
    subtitle: 'Configure GPA values for each letter grade',
    child: Column(
      children: [
        _buildGradePointItem('A+', provider.gradeAPlusPoints, provider.updateGradeAPlusPoints, const Color(0xFF10B981)),
        _buildGradePointItem('A', provider.gradeAPoints, provider.updateGradeAPoints, const Color(0xFF22C55E)),
        _buildGradePointItem('B+', provider.gradeBPlusPoints, provider.updateGradeBPlusPoints, const Color(0xFF3B82F6)),
        _buildGradePointItem('B', provider.gradeBPoints, provider.updateGradeBPoints, const Color(0xFF6366F1)),
        _buildGradePointItem('C', provider.gradeCPoints, provider.updateGradeCPoints, const Color(0xFFF59E0B)),
        _buildGradePointItem('D', provider.gradeDPoints, provider.updateGradeDPoints, const Color(0xFFEF4444)),
      ],
    ),
  );

  Widget _buildGradePointItem(
    String grade,
    double value,
    ValueChanged<double> onChanged,
    Color color,
  ) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.slate100,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              grade,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              max: 5,
              divisions: 50,
              onChanged: onChanged,
            ),
          ),
        ),
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );

  Widget _buildRiskThresholdsSection(GradingConfigProvider provider) => _buildCard(
    icon: Icons.warning_amber_rounded,
    iconColor: AppTheme.warning,
    title: 'Risk Status Thresholds',
    subtitle: 'Configure when students are flagged for intervention',
    child: Column(
      children: [
        _buildRiskCategory(
          title: 'At Risk',
          icon: Icons.error,
          color: AppTheme.danger,
          description: 'Flag students if ANY metric falls below these values',
          attendanceValue: provider.atRiskAttendance,
          onAttendanceChanged: provider.updateAtRiskAttendance,
          assignmentValue: provider.atRiskAssignment,
          onAssignmentChanged: provider.updateAtRiskAssignment,
          examValue: provider.atRiskExam,
          onExamChanged: provider.updateAtRiskExam,
          gpaValue: provider.atRiskGradePoints,
          onGpaChanged: provider.updateAtRiskGradePoints,
        ),
        const SizedBox(height: 20),
        _buildRiskCategory(
          title: 'Needs Improvement',
          icon: Icons.trending_down,
          color: AppTheme.warning,
          description: 'Flag students if ANY metric falls below these values',
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
  );

  Widget _buildRiskCategory({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required double attendanceValue,
    required ValueChanged<double> onAttendanceChanged,
    required double assignmentValue,
    required ValueChanged<double> onAssignmentChanged,
    required double examValue,
    required ValueChanged<double> onExamChanged,
    required double gpaValue,
    required ValueChanged<double> onGpaChanged,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
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
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.slate500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildThresholdRow('Attendance', attendanceValue, onAttendanceChanged, '%', color),
        _buildThresholdRow('Assignment Score', assignmentValue, onAssignmentChanged, '%', color),
        _buildThresholdRow('Exam Score', examValue, onExamChanged, '%', color),
        _buildThresholdRow('GPA', gpaValue, onGpaChanged, '', color, max: 5.0),
      ],
    ),
  );

  Widget _buildThresholdRow(
    String label,
    double value,
    ValueChanged<double> onChanged,
    String suffix,
    Color color, {
    double max = 100,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.slate600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              max: max,
              divisions: max == 100 ? 100 : 50,
              onChanged: onChanged,
            ),
          ),
        ),
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            max == 100 ? '${value.toInt()}$suffix' : value.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget child,
  }) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.slate100),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.slate500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        child,
      ],
    ),
  );

  Widget _buildActionButtons(GradingConfigProvider provider) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.slate100),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isRestricted ? AppTheme.slate100 : AppTheme.blue500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isRestricted ? Icons.lock : Icons.save_outlined, 
                size: 22, 
                color: _isRestricted ? AppTheme.slate500 : AppTheme.blue500,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isRestricted ? 'Configuration Locked' : 'Save Configuration',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _isRestricted ? AppTheme.slate500 : AppTheme.slate800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isRestricted 
                      ? 'Changes restricted during active $_periodType'
                      : 'Apply changes to the grading system',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.slate500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: _isRestricted ? null : () => _showResetConfirmation(_institutionId),
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Reset to Defaults'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _isRestricted ? AppTheme.slate500 : AppTheme.danger,
                side: BorderSide(color: _isRestricted ? AppTheme.slate500 : AppTheme.danger),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isRestricted 
                  ? null 
                  : (provider.isWeightValid ? () => _saveConfig(provider, _institutionId) : null),
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(_isRestricted ? Icons.lock : Icons.check, size: 18),
              label: Text(
                _isRestricted 
                  ? 'Locked During $_periodTypeCapitalized'
                  : (provider.isLoading ? 'Saving...' : 'Save Changes')
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRestricted ? AppTheme.slate200 : AppTheme.blue500,
                foregroundColor: _isRestricted ? AppTheme.slate500 : Colors.white,
                disabledBackgroundColor: AppTheme.slate100,
                disabledForegroundColor: AppTheme.slate500,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: _isRestricted ? 0 : 2,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _saveConfig(
    GradingConfigProvider provider,
    int institutionId,
  ) async {
    try {
      final success = await provider.saveConfig(institutionId);

      if (!mounted) return;

      if (success) {
        showCustomSnackbar(
          message: 'Configuration saved successfully!',
          type: SnackbarType.success,
        );
        // Reload restriction info in case semester status changed
        await _loadInstitutionInfo();
      } else {
        showCustomSnackbar(
          message: 'Failed to save: ${provider.error}',
          type: SnackbarType.warning,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      if (e.toString().contains('ACTIVE_PERIOD_RESTRICTION')) {
        _showActivePeriodDialog();
        // Reload restriction info to get latest status
        await _loadInstitutionInfo();
      } else {
        showCustomSnackbar(
          message: 'Failed to save: ${e.toString()}',
          type: SnackbarType.warning,
        );
      }
    }
  }

  void _showActivePeriodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.lock, color: AppTheme.warning, size: 48),
        title: const Text('Configuration Locked'),
        content: Text(
          'Grading configuration cannot be modified during an active $_periodType. '
          'This ensures fairness and consistency for all students.\n\n'
          'Please wait until the current $_periodType ends to make changes.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetConfirmation(int institutionId) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'Reset to Defaults?',
      message: 'This will restore the standard grading formula. All custom settings will be lost. This action cannot be undone.',
      confirmText: 'Reset',
      cancelText: 'Cancel',
      confirmColor: AppTheme.danger,
      icon: Icons.restart_alt,
      iconColor: AppTheme.danger,
    );

    if (confirmed == true && mounted) {
      try {
        final provider = context.read<GradingConfigProvider>();
        final success = await provider.resetToDefaults(institutionId);

        if (!mounted) return;

        if (success) {
          showCustomSnackbar(
            message: 'Configuration reset to defaults!',
            type: SnackbarType.success,
          );
          // Reload restriction info in case semester status changed
          await _loadInstitutionInfo();
        } else {
          showCustomSnackbar(
            message: 'Failed to reset: ${provider.error}',
            type: SnackbarType.warning,
          );
        }
      } catch (e) {
        if (!mounted) return;
        
        if (e.toString().contains('ACTIVE_PERIOD_RESTRICTION')) {
          _showActivePeriodDialog();
          // Reload restriction info to get latest status
          await _loadInstitutionInfo();
        } else {
          showCustomSnackbar(
            message: 'Failed to reset: ${e.toString()}',
            type: SnackbarType.warning,
          );
        }
      }
    }
  }
}
