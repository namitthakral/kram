import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/services/class_section_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_search_bar.dart';
import '../../../widgets/custom_widgets/dashboard_widgets.dart';
import '../models/assignment_models.dart';
import '../models/examination_models.dart';
import '../services/teacher_service.dart';
import '../widgets/activity_timeline_widget.dart';

import '../widgets/student_profile_card.dart';

/// Comprehensive class detail screen with chips navigation
class ClassDetailScreen extends StatefulWidget {
  const ClassDetailScreen({
    required this.className,
    required this.sectionId,
    this.courseId,
    super.key,
  });

  final String className;
  final int sectionId;
  final int? courseId;

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final ClassSectionService _classSectionService = ClassSectionService();
  final TeacherService _teacherService = TeacherService();

  // Navigation state
  String _selectedTab = 'Students'; // Default tab

  // Data
  List<dynamic> _students = [];
  List<dynamic> _filteredStudents = [];
  List<Assignment> _assignments = [];
  List<Examination> _exams = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final loginProvider = context.read<LoginProvider>();
      final teacherUserUuid = loginProvider.currentUser?.uuid;

      if (teacherUserUuid == null) {
        throw Exception('User not logged in');
      }

      final response = await _classSectionService.getEnrolledStudents(
        sectionId: widget.sectionId,
      );

      final data = response['data'] as Map<String, dynamic>?;
      final students = data?['students'] as List<dynamic>? ?? [];

      // Fetch assignments and exams if courseId is available
      var assignments = <Assignment>[];
      var exams = <Examination>[];

      if (widget.courseId != null) {
        assignments = await _teacherService.getAssignments(
          teacherUserUuid,
          courseId: widget.courseId,
          status: 'PUBLISHED', // Only show published/active
        );

        exams = await _teacherService.getExaminations(
          teacherUserUuid,
          courseId: widget.courseId,
          status: 'SCHEDULED', // Only show scheduled
        );
      }

      if (mounted) {
        setState(() {
          _students = students;
          _filteredStudents = students;
          _assignments = assignments;
          _exams = exams;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Calculate average attendance from student data
  double _calculateAverageAttendance() {
    if (_students.isEmpty) return 0.0;

    // Check if students have attendance percentage, otherwise default to 0
    var totalAttendance = 0.0;
    var count = 0;

    for (final student in _students) {
      if (student['attendancePercentage'] != null) {
        totalAttendance += (student['attendancePercentage'] as num).toDouble();
        count++;
      }
    }

    return count > 0 ? totalAttendance / count : 0.0;
  }

  // Calculate average grade from student data
  double _calculateAverageGrade() {
    if (_students.isEmpty) return 0.0;

    var totalGrade = 0.0;
    var count = 0;

    for (final student in _students) {
      if (student['averageGrade'] != null) {
        totalGrade += (student['averageGrade'] as num).toDouble();
        count++;
      }
    }

    return count > 0 ? totalGrade / count : 0.0;
  }

  void _filterStudents(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredStudents = _students;
      } else {
        _filteredStudents =
            _students.where((student) {
              final name = (student['name'] as String? ?? '').toLowerCase();
              final rollNumber =
                  (student['rollNumber'] as String? ?? '').toLowerCase();
              final searchLower = query.toLowerCase();
              return name.contains(searchLower) ||
                  rollNumber.contains(searchLower);
            }).toList();
      }
    });
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
      title: widget.className,
      appBarConfig: AppBarConfig.teacher(
        userInitials: userInitials,
        userName: userName,
        designation: designation,
        employeeId: employeeId,
        onNotificationIconPressed: () {},
      ),
      child: Column(
        children: [
          // Horizontal Chip Navigation
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildChip('Students'),
                const SizedBox(width: 8),
                _buildChip('Overview'),
                const SizedBox(width: 8),
                _buildChip('Performance'),
                const SizedBox(width: 8),
                _buildChip('Attendance'),
                const SizedBox(width: 8),
                _buildChip('Activities'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content Area
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? _buildErrorState()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    final isSelected = _selectedTab == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedTab = label;
          });
        }
      },
      selectedColor: CustomAppColors.primary.withValues(alpha: 0.15),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? CustomAppColors.primary : Colors.grey.shade300,
      ),
      labelStyle: TextStyle(
        color: isSelected ? CustomAppColors.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 'Students':
        return _buildStudentsContent();
      case 'Overview':
        return _buildOverviewContent();
      case 'Performance':
        return _buildPerformanceContent();
      case 'Attendance':
        return _buildAttendanceContent();
      case 'Activities':
        return _buildActivitiesContent();
      default:
        return _buildStudentsContent();
    }
  }

  Widget _buildOverviewContent() {
    // Calculate statistics
    final totalStudents = _students.length;
    final averageAttendance = _calculateAverageAttendance();
    final averageGrade = _calculateAverageGrade();

    // Count upcoming deadlines (assignments due in future)
    final now = DateTime.now();
    final upcomingAssignments =
        _assignments.where((a) => a.dueDate.isAfter(now)).length;
    final upcomingExams = _exams.where((e) => e.examDate.isAfter(now)).length;
    final upcomingDeadlines = upcomingAssignments + upcomingExams;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                DashboardStatCard(
                  title: 'Students',
                  value: totalStudents.toString(),
                  subtitle: 'Enrolled',
                  backgroundColor: Colors.blue,
                  iconColor: Colors.blue.shade700,
                  icon: Icons.people,
                  onTap: () => setState(() => _selectedTab = 'Students'),
                ),
                DashboardStatCard(
                  title: 'Attendance',
                  value: '${averageAttendance.toInt()}%',
                  subtitle: 'Average',
                  backgroundColor: Colors.green,
                  iconColor: Colors.green.shade700,
                  icon: Icons.check_circle,
                  onTap: () => setState(() => _selectedTab = 'Attendance'),
                ),
                DashboardStatCard(
                  title: 'Academics',
                  value: '${averageGrade.toInt()}%',
                  subtitle: 'Avg. Grade',
                  backgroundColor: Colors.purple,
                  iconColor: Colors.purple.shade700,
                  icon: Icons.grade,
                  onTap: () => setState(() => _selectedTab = 'Performance'),
                ),
                DashboardStatCard(
                  title: 'Deadlines',
                  value: upcomingDeadlines.toString(),
                  subtitle: 'Upcoming',
                  backgroundColor: Colors.orange,
                  iconColor: Colors.orange.shade700,
                  icon: Icons.warning_amber_rounded,
                  onTap: () => setState(() => _selectedTab = 'Activities'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: AppTheme.fontWeightSemibold,
                color: AppTheme.slate800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionButton(
                  icon: Icons.how_to_reg_outlined,
                  label: 'Mark Attendance',
                  color: const Color(0xFF00a63e),
                  onTap: () {
                    context.pushNamed(
                      'attendance_view',
                      queryParameters: {
                        'sectionId': widget.sectionId.toString(),
                        if (widget.courseId != null)
                          'courseId': widget.courseId.toString(),
                      },
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.assignment_outlined,
                  label: 'Create Assignment',
                  color: CustomAppColors.primary,
                  onTap: () {
                    context.pushNamed(
                      'create_assignment',
                      queryParameters: {
                        if (widget.courseId != null)
                          'courseId': widget.courseId.toString(),
                        'sectionId': widget.sectionId.toString(),
                      },
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.quiz_outlined,
                  label: 'Create Exam',
                  color: const Color(0xFFf59e0b),
                  onTap: () {
                    context.pushNamed(
                      'create_exam',
                      queryParameters: {
                        if (widget.courseId != null)
                          'courseId': widget.courseId.toString(),
                        'sectionId': widget.sectionId.toString(),
                      },
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.download_outlined,
                  label: 'Export Data',
                  color: const Color(0xFF8b5cf6),
                  onTap: () {
                    // TODO: Export functionality
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activities Preview
            if (_assignments.isNotEmpty || _exams.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: AppTheme.fontWeightSemibold,
                      color: AppTheme.slate800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRecentActivitiesPreview(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsContent() => Column(
    children: [
      // Search Bar
      Padding(
        padding: const EdgeInsets.all(16),
        child: CustomSearchBar(
          hintText: 'Search students...',
          onChanged: _filterStudents,
        ),
      ),

      // Student Count
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              '${_filteredStudents.length} ${_filteredStudents.length == 1 ? 'Student' : 'Students'}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: AppTheme.fontWeightSemibold,
                color: AppTheme.slate600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                // TODO: Filter options
              },
              icon: const Icon(Icons.filter_list, size: 18),
              label: const Text('Filter'),
            ),
          ],
        ),
      ),

      // Student List
      Expanded(
        child:
            _filteredStudents.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No students enrolled'
                            : 'No students found',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: AppTheme.fontWeightSemibold,
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = _filteredStudents[index];
                    // Defensive coding for student properties
                    final name = student['name'] as String? ?? 'Unknown';
                    final rollNo = student['rollNumber'] as String? ?? 'N/A';
                    final attendance =
                        (student['attendancePercentage'] as num?)?.toDouble() ??
                        0.0;
                    final grade =
                        (student['averageGrade'] as num?)?.toDouble() ?? 0.0;

                    return StudentProfileCard(
                      studentName: name,
                      rollNumber: rollNo,
                      attendancePercentage: attendance,
                      averageGrade: grade,
                      onTap: () {
                        // Navigate to student detail with full student object
                        context.pushNamed(
                          'student_detail',
                          pathParameters: {
                            'className': widget.className,
                            'sectionId': widget.sectionId.toString(),
                            'studentId': '${student['id'] ?? 0}',
                          },
                          extra: student,
                        );
                      },
                      onContact: () {
                        // TODO: Contact student
                      },
                      onAddRemark: () {
                        // TODO: Add remark
                      },
                    );
                  },
                ),
      ),
    ],
  );

  Widget _buildPerformanceContent() {
    // Show list of students with top performance
    // Since we don't have separate performance API, we use students list sorted by grade
    final sortedStudents = List.from(_students);
    sortedStudents.sort((a, b) {
      final gradeA = (a['averageGrade'] as num?)?.toDouble() ?? 0.0;
      final gradeB = (b['averageGrade'] as num?)?.toDouble() ?? 0.0;
      return gradeB.compareTo(gradeA); // Descending
    });

    if (sortedStudents.isEmpty) {
      return const Center(child: Text('No performance available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedStudents.length,
      itemBuilder: (context, index) {
        final student = sortedStudents[index];
        final name = student['name'] ?? 'Unknown';
        final grade = (student['averageGrade'] as num?)?.toDouble() ?? 0.0;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: CustomAppColors.primary.withValues(alpha: 0.1),
              foregroundColor: CustomAppColors.primary,
              child: Text(UserUtils.getInitials(name)),
            ),
            title: Text(name),
            subtitle: Text('Rank: #${index + 1}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    grade >= 75
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${grade.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: grade >= 75 ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceContent() {
    // Show list of students sorted by lowest attendance (to highlight issues)
    final sortedStudents = List.from(_students);
    sortedStudents.sort((a, b) {
      final attA = (a['attendancePercentage'] as num?)?.toDouble() ?? 0.0;
      final attB = (b['attendancePercentage'] as num?)?.toDouble() ?? 0.0;
      return attA.compareTo(attB); // Ascending (lowest first)
    });

    if (sortedStudents.isEmpty) {
      return const Center(child: Text('No attendance data available'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Students needing attention (Low Attendance)',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedStudents.length,
            itemBuilder: (context, index) {
              final student = sortedStudents[index];
              final name = student['name'] ?? 'Unknown';
              final attendance =
                  (student['attendancePercentage'] as num?)?.toDouble() ?? 0.0;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(UserUtils.getInitials(name)),
                  ),
                  title: Text(name),
                  trailing: Text(
                    '${attendance.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: attendance < 75 ? Colors.red : Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesContent() {
    // Combine assignments and exams into ActivityItems
    final activities = <ActivityItem>[];

    for (final assignment in _assignments) {
      activities.add(
        ActivityItem(
          type: 'assignment',
          title: assignment.title,
          description:
              'Due: ${DateFormat('MMM d, h:mm a').format(assignment.dueDate)}',
          timestamp: assignment.createdAt,
          studentName:
              assignment
                  .status, // Using studentName field for status temporarily
        ),
      );
    }

    for (final exam in _exams) {
      activities.add(
        ActivityItem(
          type: 'exam',
          title: exam.examName,
          description:
              'Date: ${DateFormat('MMM d, h:mm a').format(exam.examDate)}',
          timestamp: exam.createdAt,
          studentName: exam.examType, // Using studentName field for type
        ),
      );
    }

    // Sort by timestamp (newest first)
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No recent activities',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ActivityTimelineWidget(activities: activities);
  }

  Widget _buildRecentActivitiesPreview() {
    // Combine and take top 3
    final allItems = <dynamic>[..._assignments, ..._exams]..sort((a, b) {
      final dateA =
          a is Assignment ? a.updatedAt : (a as Examination).createdAt;
      final dateB =
          b is Assignment ? b.updatedAt : (b as Examination).createdAt;
      return dateB.compareTo(dateA);
    });

    final recentItems = allItems.take(3).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (var i = 0; i < recentItems.length; i++) ...[
              if (i > 0) const Divider(),
              _buildModernActivityItem(recentItems[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModernActivityItem(item) {
    final isAssignment = item is Assignment;
    final title = isAssignment ? item.title : (item as Examination).examName;
    final subtitle =
        isAssignment
            ? 'Assignment due ${DateFormat('MMM d').format(item.dueDate)}'
            : 'Exam on ${DateFormat('MMM d').format((item as Examination).examDate)}';
    var time = ''; // Calculate relative time ideally
    // Simple relative time logic
    final date =
        isAssignment ? item.updatedAt : (item as Examination).createdAt;
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      time = '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      time = '${diff.inHours}h ago';
    } else {
      time = '${diff.inMinutes}m ago';
    }

    final icon = isAssignment ? Icons.assignment_outlined : Icons.quiz_outlined;
    final color =
        isAssignment ? CustomAppColors.primary : const Color(0xFFf59e0b);

    return _buildActivityItem(
      icon: icon,
      title: title,
      subtitle: subtitle,
      time: time,
      color: color,
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: AppTheme.fontWeightSemibold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppTheme.slate600),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
        ),
      ],
    ),
  );

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: AppTheme.fontWeightSemibold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildErrorState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text('Error: $_error'),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
      ],
    ),
  );
}
