import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../../state/attendance_state.dart';

class AttendanceLoggingScreen extends StatefulWidget {
  final bool isPushed;

  const AttendanceLoggingScreen({super.key, this.isPushed = false});

  @override
  State<AttendanceLoggingScreen> createState() =>
      _AttendanceLoggingScreenState();
}

class _AttendanceLoggingScreenState extends State<AttendanceLoggingScreen> {
  late Map<String, bool> _attendanceState;

  @override
  void initState() {
    super.initState();
    _attendanceState = AttendanceState.instance.getInitialState();
  }

  int get _presentCount =>
      _attendanceState.values.where((v) => v).length;
  int get _absentCount =>
      _attendanceState.values.where((v) => !v).length;
  int get _completionPercent =>
      AttendanceMockData.totalEnrolled == 0
          ? 0
          : ((_presentCount + _absentCount) / AttendanceMockData.totalEnrolled * 100)
              .round()
              .clamp(0, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 96,
              left: 24,
              right: 24,
              bottom: widget.isPushed ? 128 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 24),
                _buildActionButtons(context),
                const SizedBox(height: 32),
                _buildStatsGrid(),
                const SizedBox(height: 32),
                _buildStudentList(context),
              ],
            ),
          ),
          _buildTopBar(context),
        ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.isPushed
                  ? IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textDark,
                    )
                  : const SizedBox(width: 48),
              Text(
                MockData.teacherName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: AppColors.purpleMedium,
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings tapped')),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
                color: AppColors.textDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance –\n${AttendanceMockData.courseName}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.9,
            height: 1.1,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: AppColors.tagBlueText),
            const SizedBox(width: 8),
            Text(
              '${AttendanceMockData.dateLabel} • ${AttendanceMockData.periodLabel}',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.tagBlueText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _markAllPresent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.tagBlue,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checklist, size: 20, color: AppColors.tagBlueText),
                  const SizedBox(width: 8),
                  Text(
                    'Mark All Present',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tagBlueText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Scanner tapped')),
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryPurpleLight,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  void _markAllPresent() {
    setState(() {
      for (final s in AttendanceMockData.students) {
        _attendanceState[s.studentId] = true;
      }
      AttendanceState.instance.updateState(_attendanceState);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All marked present')),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _StatCard(
          label: 'Total\nEnrolled',
          value: '${AttendanceMockData.totalEnrolled}\nStudents',
          valueColor: AppColors.textDark,
        ),
        _StatCard(
          label: 'Present',
          value: '$_presentCount',
          labelColor: AppColors.presentBlue,
        ),
        _StatCard(
          label: 'Absent',
          value: '$_absentCount',
          labelColor: AppColors.absentRed,
        ),
        _StatCard(
          label: 'Completion',
          value: '$_completionPercent%',
        ),
      ],
    );
  }

  Widget _buildStudentList(BuildContext context) {
    return Column(
      children: AttendanceMockData.students.map((student) {
        final isPresent = _attendanceState[student.studentId] ?? student.isPresent;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _AttendanceStudentCard(
            student: student,
            isPresent: isPresent,
            onToggle: () {
              setState(() {
                _attendanceState[student.studentId] = !isPresent;
                AttendanceState.instance.updateState(_attendanceState);
              });
            },
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: labelColor ?? AppColors.tagBlueText,
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textDark,
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _AttendanceStudentCard extends StatelessWidget {
  final AttendanceStudent student;
  final bool isPresent;
  final VoidCallback onToggle;

  const _AttendanceStudentCard({
    required this.student,
    required this.isPresent,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isPresent ? Colors.white : AppColors.cardBackground,
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: isPresent ? 0.15 : 0.05),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isPresent
            ? [
                BoxShadow(
                  color: AppColors.textDark.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isPresent ? AppColors.primaryPurple : AppColors.absentRed)
                          .withValues(alpha: 0.2),
                      blurRadius: 0,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: student.avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.lavenderPlaceholder,
                      child: const Icon(Icons.person),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.lavenderPlaceholder,
                      child: const Icon(Icons.person),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isPresent ? AppColors.presentBlue : AppColors.absentRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    isPresent ? Icons.check : Icons.close,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isPresent ? AppColors.textDark : AppColors.tagBlueText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Student ID: ${student.studentId}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.tagBlueText.withValues(
                      alpha: isPresent ? 1.0 : 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPresent ? AppColors.lavenderPlaceholder : AppColors.absentRedLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPresent ? Icons.toggle_on : Icons.toggle_off,
                size: 36,
                color: isPresent ? AppColors.primaryPurpleLight : AppColors.absentRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
