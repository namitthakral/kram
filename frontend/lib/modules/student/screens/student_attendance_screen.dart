import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../models/student_attendance_model.dart';
import '../providers/student_attendance_provider.dart';
import '../providers/student_provider.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<StudentAttendanceProvider>();
      final loginProvider = context.read<LoginProvider>();
      final studentProvider = context.read<StudentProvider>();

        if (loginProvider.currentUser?.uuid != null) {
          // Default to current month
          final now = DateTime.now();
          final start = DateTime(now.year, now.month);
          final end = DateTime(now.year, now.month + 1, 0);
          await provider.fetchAttendance(
            loginProvider.currentUser!.uuid!,
            start: start,
            end: end,
          );
          await studentProvider.loadStudentData(loginProvider.currentUser!.uuid!);
        }
    });
  }

  void _fetchInitialData() {
    final user = context.read<LoginProvider>().currentUser;
    if (user != null && user.uuid != null) {
      // Default to current month
      final now = DateTime.now();
      final start = DateTime(now.year, now.month);
      final end = DateTime(now.year, now.month + 1, 0);
      context.read<StudentAttendanceProvider>().fetchAttendance(
        user.uuid!,
        start: start,
        end: end,
      );
    }
  }

  Future<void> _selectDateRange() async {
    final provider = context.read<StudentAttendanceProvider>();

    // Ensure dates are valid and not in the future
    final now = DateTime.now();
    final defaultStart = DateTime(now.year, now.month);
    final defaultEnd = DateTime(now.year, now.month, now.day);

    // Validate provider dates
    var selectedStart = provider.startDate ?? defaultStart;
    var selectedEnd = provider.endDate ?? defaultEnd;

    // Ensure start is not after end
    if (selectedStart.isAfter(selectedEnd)) {
      selectedStart = defaultStart;
      selectedEnd = defaultEnd;
    }

    // Ensure dates are not in the future
    if (selectedStart.isAfter(now)) {
      selectedStart = defaultStart;
    }
    if (selectedEnd.isAfter(now)) {
      selectedEnd = defaultEnd;
    }

    try {
      final result = await showDialog<Map<String, DateTime>>(
        context: context,
        builder: (BuildContext dialogContext) {
          var tempStart = selectedStart;
          var tempEnd = selectedEnd;

          return StatefulBuilder(
            builder: (context, setState) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: 500,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Date Range',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slate800,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Start Date
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempStart,
                            firstDate: DateTime(2000),
                            lastDate: tempEnd,
                            builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppTheme.blue500,
                                    onSurface: AppTheme.slate800,
                                  ),
                                ),
                                child: child!,
                              ),
                          );
                          if (picked != null) {
                            setState(() {
                              tempStart = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.slate200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: AppTheme.blue500,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Start Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.slate600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM d, yyyy').format(tempStart),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.slate800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // End Date
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempEnd,
                            firstDate: tempStart,
                            lastDate: now,
                            builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppTheme.blue500,
                                    onSurface: AppTheme.slate800,
                                  ),
                                ),
                                child: child!,
                              ),
                          );
                          if (picked != null) {
                            setState(() {
                              tempEnd = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.slate200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: AppTheme.blue500,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'End Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.slate600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM d, yyyy').format(tempEnd),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.slate800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pop({'start': tempStart, 'end': tempEnd});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.blue500,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          );
        },
      );

      if (result != null && mounted) {
        final user = context.read<LoginProvider>().currentUser;
        if (user != null && user.uuid != null) {
          // ignore: unawaited_futures
          context.read<StudentAttendanceProvider>().fetchAttendance(
            user.uuid!,
            start: result['start'],
            end: result['end'],
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading attendance data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening date picker. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final student = user?.student;

    // Get user display info
    final userInitials = UserUtils.getInitials(user?.name ?? 'Student');
    final userName = user?.name ?? 'Student';

    // Get dynamic grade/class info
    final studentProvider = context.watch<StudentProvider>();
    final className = studentProvider.studentClassName;
    final section = studentProvider.studentSection;
    final grade =
        (className.isNotEmpty || section.isNotEmpty)
            ? '$className $section'.trim()
            : 'Class N/A';

    final rollNumber = student?.rollNumber ?? 'N/A';

    // Get GPA from dashboard stats
    final statsData = studentProvider.dashboardStats;
    final gpa = statsData?['gpa']?.toString();

    return CustomMainScreenWithAppbar(
      title: 'Attendance',
      appBarConfig: AppBarConfig.student(
        userInitials: userInitials,
        userName: userName,
        grade: grade,
        rollNumber: rollNumber,
        gpa: gpa,
        onNotificationIconPressed: () {
          // Notification handler to be implemented
        },
      ),
      child: Consumer<StudentAttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final stats = provider.stats;

          return RefreshIndicator(
            onRefresh: () async {
              _fetchInitialData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(stats),
                  const SizedBox(height: 24),
                  _buildFilterSection(provider),
                  const SizedBox(height: 16),
                  _buildAttendanceList(provider.filteredAttendanceRecords),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(AttendanceStats stats) => Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return Column(
              children: [
                SizedBox(
                  height: 200,
                  child: _buildPieChart(stats),
                ),
                const SizedBox(height: 24),
                _buildStatsColumn(stats),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 220,
                  child: _buildPieChart(stats),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: _buildStatsColumn(stats),
              ),
            ],
          );
        },
      ),
    );

  Widget _buildPieChart(AttendanceStats stats) {
    if (stats.totalClasses == 0) {
      return const SizedBox.shrink();
    }

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        sectionsSpace: 4,
        centerSpaceRadius: 50,
        sections: [
          _buildPieSection(
            index: 0,
            value: stats.present.toDouble(),
            total: stats.totalClasses.toDouble(),
            color: AppTheme.success,
          ),
          _buildPieSection(
            index: 1,
            value: stats.absent.toDouble(),
            total: stats.totalClasses.toDouble(),
            color: AppTheme.danger,
          ),
          _buildPieSection(
            index: 2,
            value: stats.late.toDouble(),
            total: stats.totalClasses.toDouble(),
            color: AppTheme.warning,
          ),
          _buildPieSection(
            index: 3,
            value: stats.excused.toDouble(),
            total: stats.totalClasses.toDouble(),
            color: AppTheme.info,
          ),
        ].whereType<PieChartSectionData>().toList(),
      ),
    );
  }

  PieChartSectionData? _buildPieSection({
    required int index,
    required double value,
    required double total,
    required Color color,
  }) {
    if (value <= 0) {
      return null;
    }

    final isTouched = index == _touchedIndex;
    final fontSize = isTouched ? 16.0 : 12.0;
    final radius = isTouched ? 70.0 : 60.0;

    return PieChartSectionData(
      color: color,
      value: value,
      title: '${((value / total) * 100).toStringAsFixed(0)}%',
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildStatsColumn(AttendanceStats stats) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatItem(
          label: 'Overall Attendance',
          count: stats.attendancePercentage,
          suffix: '%',
          color: AppTheme.blue500,
          icon: Icons.percent,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                label: 'Present',
                count: stats.present,
                color: AppTheme.success,
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                label: 'Absent',
                count: stats.absent,
                color: AppTheme.danger,
                icon: Icons.highlight_off,
              ),
            ),
          ],
        ),
        if (stats.late > 0 || stats.excused > 0) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              if (stats.late > 0)
                Expanded(
                  child: _buildStatItem(
                    label: 'Late',
                    count: stats.late,
                    color: AppTheme.warning,
                    icon: Icons.access_time,
                  ),
                ),
              if (stats.late > 0 && stats.excused > 0) const SizedBox(width: 16),
              if (stats.excused > 0)
                Expanded(
                  child: _buildStatItem(
                    label: 'Excused',
                    count: stats.excused,
                    color: AppTheme.info,
                    icon: Icons.verified_user_outlined,
                  ),
                ),
            ],
          ),
        ],
      ],
    );

  Widget _buildStatItem({
    required String label,
    required num count,
    required Color color, required IconData icon, String suffix = '',
  }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _AnimatedCount(
          count: count,
          suffix: suffix,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.slate800,
          ),
        ),
      ],
    );

  // Helper _buildInfoCard is no longer needed

  Widget _buildFilterSection(StudentAttendanceProvider provider) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final start =
        provider.startDate != null
            ? dateFormat.format(provider.startDate!)
            : '';
    final end =
        provider.endDate != null ? dateFormat.format(provider.endDate!) : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.slate800,
          ),
        ),
        Row(
          children: [
            // Subject filter dropdown - compact version
            if (provider.availableSubjects.isNotEmpty) ...[
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.blue50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.subject,
                      size: 16,
                      color: AppTheme.blue500,
                    ),
                    const SizedBox(width: 6),
                    DropdownButton<String>(
                      value: provider.selectedSubject,
                      hint: const Text(
                        'All Subjects',
                        style: TextStyle(fontSize: 14),
                      ),
                      underline: const SizedBox(),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: AppTheme.blue500,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.slate800,
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          child: Text('All Subjects'),
                        ),
                        ...provider.availableSubjects.map((subject) => DropdownMenuItem<String>(
                            value: subject,
                            child: Text(subject),
                          )),
                      ],
                      onChanged: (value) {
                        provider.setSubjectFilter(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
            SizedBox(
              height: 40,
              child: TextButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  start.isNotEmpty ? '$start - $end' : 'Select Date Range',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.blue500,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  backgroundColor: AppTheme.blue50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceList(List<StudentAttendanceRecord> records) {
    if (records.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_note, size: 32, color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            Text(
              'No attendance records found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different date range',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: record.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      DateFormat('d').format(record.date),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: record.statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM yyyy').format(record.date),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.slate800,
                          ),
                        ),
                        if (record.subjectName != null &&
                            record.subjectName!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.class_outlined,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                record.subjectName!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 6),
                          Text(
                            'Daily Attendance',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: record.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      record.statusText.toUpperCase(),
                      style: TextStyle(
                        color: record.statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedCount extends StatefulWidget {

  const _AnimatedCount({
    required this.count,
    required this.style,
    this.suffix = '',
  });

  final num count;
  final String suffix;
  final TextStyle style;

  @override
  State<_AnimatedCount> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<_AnimatedCount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.count.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.count.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = widget.count is int
            ? _animation.value.toInt().toString()
            : _animation.value.toStringAsFixed(1);
        return Text(
          '$value${widget.suffix}',
          style: widget.style,
        );
      },
    );
}
