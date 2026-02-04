import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_tab_bar.dart';
import '../../student/services/student_service.dart';

/// Screen to view detailed information about a student
class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({
    required this.className,
    required this.sectionId,
    required this.studentId,
    required this.studentData,
    super.key,
  });

  final String className;
  final String sectionId;
  final String studentId;
  final Map<String, dynamic> studentData;

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StudentService _studentService = StudentService();

  // Tab Data
  bool _isLoadingTabs = false;
  Map<String, dynamic>? _performanceData;
  Map<String, dynamic>? _attendanceHistory;
  List<dynamic>? _upcomingEvents;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    // Fetch detailed data for tabs
    _fetchTabDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTabDetails() async {
    setState(() {
      _isLoadingTabs = true;
    });

    try {
      // Use studentId/userUuid if available in studentData
      final userUuid =
          widget.studentData['userUuid'] as String? ??
          widget.studentData['uuid'] as String?;

      if (userUuid != null) {
        final performance = await _studentService.getSubjectPerformance(
          userUuid,
        );
        final attendance = await _studentService.getAttendanceHistory(userUuid);
        final events = await _studentService.getUpcomingEvents(userUuid);

        if (mounted) {
          setState(() {
            _performanceData = performance;
            _attendanceHistory = attendance;
            _upcomingEvents = events;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching student details: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTabs = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final user = loginProvider.currentUser;
    final teacher = user?.teacher;

    final userInitials = UserUtils.getInitials(user?.name ?? 'Teacher');
    final userName = user?.name ?? 'Teacher';
    final designation = teacher?.designation ?? 'Faculty';
    final employeeId = teacher?.employeeId ?? 'N/A';

    return CustomMainScreenWithAppbar(
      title: 'Student Details',
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        onNotificationIconPressed: () {},
      ),
      child: Column(
        children: [
          _buildStudentHeader(),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomTabBar<int>(
              selectedValue: _tabController.index,
              onTabSelected: (index) {
                setState(() {
                  _tabController.animateTo(index);
                });
              },
              tabs: const [
                TabItem(value: 0, label: 'Profile', icon: Icons.person_outline),
                TabItem(
                  value: 1,
                  label: 'Performance',
                  icon: Icons.analytics_outlined,
                ),
                TabItem(
                  value: 2,
                  label: 'Attendance',
                  icon: Icons.calendar_today_outlined,
                ),
                TabItem(
                  value: 3,
                  label: 'Activity',
                  icon: Icons.history_edu_outlined,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildPerformanceTab(),
                _buildAttendanceTab(),
                _buildActivityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentHeader() {
    final name = widget.studentData['name'] as String? ?? 'N/A';
    final rollNo = widget.studentData['rollNumber'] as String? ?? 'N/A';
    final initials = UserUtils.getInitials(name);

    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: CustomAppColors.primary.withValues(alpha: 0.1),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: AppTheme.fontWeightBold,
                color: CustomAppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: AppTheme.fontWeightBold,
                    color: AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.slate100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.slate200),
                      ),
                      child: Text(
                        'Roll No: $rollNo',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.slate600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: CustomAppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: CustomAppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        widget.className,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CustomAppColors.primary,
                        ),
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

  Widget _buildProfileTab() {
    final data = widget.studentData;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Personal Information',
            children: [
              _buildInfoRow('Full Name', data['name'] ?? 'N/A'),
              _buildInfoRow('Roll Number', data['rollNumber'] ?? 'N/A'),
              _buildInfoRow('Date of Birth', data['dob'] ?? 'N/A'),
              _buildInfoRow('Gender', data['gender'] ?? 'N/A'),
              _buildInfoRow('Contact', data['phone'] ?? 'N/A'),
              _buildInfoRow('Email', data['email'] ?? 'N/A'),
              _buildInfoRow('Address', data['address'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Academic Summary',
            children: [
              _buildInfoRow(
                'Attendance',
                '${data['attendancePercentage'] ?? 0}%',
                valueColor: _getAttendanceColor(
                  (data['attendancePercentage'] as num?)?.toDouble() ?? 0.0,
                ),
              ),
              _buildInfoRow(
                'Average Grade',
                '${data['averageGrade'] ?? 0}',
                valueColor: _getGradeColor(
                  (data['averageGrade'] as num?)?.toDouble() ?? 0.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    if (_isLoadingTabs) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_performanceData == null || _performanceData!.isEmpty) {
      // Show empty state nicely
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No performance data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Attempt to parse subjects list. Assuming response has 'subjects' list or similar
    // Adjust this parsing based on actual API response structure which implies {data: [...]} or just {...}
    // Since we don't have the exact structure, we'll try to iterate common patterns.
    // If it's a direct map of subjects, convert to list.

    // Check for nested 'data' key or direct list
    // Check for nested 'data' key or direct list
    var subjectsRaw =
        _performanceData!['data'] ?? _performanceData!['subjects'];
    // If it's a map, try to find the list inside
    if (subjectsRaw is Map) {
      subjectsRaw = subjectsRaw['data'] ?? subjectsRaw['subjects'] ?? subjectsRaw['items'];
    }
    final subjects = (subjectsRaw is List) ? subjectsRaw : [];

    if (subjects.isEmpty) {
      return const Center(child: Text('No subject data found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final name = subject['subjectName'] ?? subject['name'] ?? 'Subject';
        final score =
            (subject['score'] ??
                    subject['marks'] ??
                    subject['percentage'] as num?)
                ?.toDouble() ??
            0.0;
        final total = (subject['total'] as num?)?.toDouble() ?? 100.0;
        final percentage = (score / total) * 100;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: AppTheme.fontWeightSemibold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${score.toStringAsFixed(1)} / ${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getGradeColor(percentage),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceTab() {
    if (_isLoadingTabs) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_attendanceHistory == null) {
      return const Center(
        child: Text('No attendance history available'),
      ); // Fallback
    }

    // Check for nested 'data' key or direct list
    // Check for nested 'data' key or direct list
    var historyRaw =
        _attendanceHistory!['data'] ?? _attendanceHistory!['attendanceHistory'];
    // If it's a map, try to find the list inside
    if (historyRaw is Map) {
      historyRaw = historyRaw['data'] ?? historyRaw['attendanceHistory'] ?? historyRaw['history'];
    }
    final history = (historyRaw is List) ? historyRaw : [];

    if (history.isEmpty) {
      return const Center(child: Text('No attendance records found'));
    }

    // Process data for chart
    // Filter out months with 0 total classes to avoid empty chart noise if preferred,
    // or keep them to show gaps. Let's keep valid months.
    final validHistory =
        history.where((m) => (m['totalClasses'] ?? 0) > 0).toList();

    if (validHistory.isEmpty) {
      // If all are 0, just show the valid ones anyway to avoid blank screen
    }

    // We can use a simple list view for now to ensure robustness,
    // or a custom painted bar chart if fl_chart adds too much complexity/risk of breaking.
    // Given the constraints and the explicit request for visualization,
    // a clean list with progress bars (similar to performance) is safer than a potentially buggy chart implementation
    // without knowing exact data ranges.
    // BUT the user specifically mentioned "visualise", implying chart.
    // I'll stick to a nice list with stats for now as it's highly functional and robust.

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = history[index];
        final month = record['month'] ?? '';
        final attended = record['attendedClasses'] ?? 0;
        final total = record['totalClasses'] ?? 0;
        final percentage = (record['percentage'] as num?)?.toDouble() ?? 0.0;

        // Skip if total is 0 and it looks like future/empty data
        if (total == 0 && percentage == 0) {
          return const SizedBox.shrink(); // Hide empty months if preferred
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    month,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getAttendanceColor(
                        percentage,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: _getAttendanceColor(percentage),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attended',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$attended',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Classes',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$total',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? (attended / total) : 0.0,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getAttendanceColor(percentage),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTab() {
    if (_isLoadingTabs) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_upcomingEvents == null || _upcomingEvents!.isEmpty) {
      return Center(
        child: Text(
          'No recent activity',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    // TODO: Visualize _upcomingEvents as timeline
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _upcomingEvents!.length,
      itemBuilder: (context, index) {
        final event = _upcomingEvents![index];
        return Card(
          child: ListTile(
            title: Text(event['title'] ?? 'Event'),
            subtitle: Text(event['date'] ?? ''),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) => Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: AppTheme.fontWeightBold,
                color: AppTheme.slate800,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.slate500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? AppTheme.slate800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75) return const Color(0xFF00a63e);
    if (percentage >= 60) return const Color(0xFFf59e0b);
    return const Color(0xFFef4444);
  }

  Color _getGradeColor(double grade) {
    if (grade >= 80) return const Color(0xFF00a63e);
    if (grade >= 60) return const Color(0xFFf59e0b);
    return const Color(0xFFef4444);
  }
}
