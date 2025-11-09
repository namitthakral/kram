import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/auth_models.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/extensions.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0.5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('profile_information'),
            style: context.textTheme.titleLg.copyWith(color: AppTheme.slate800),
          ),
          const SizedBox(height: 16),

          // Email
          _InfoRow(
            icon: Icons.email_outlined,
            label: context.translate('email'),
            value: user.email,
            canCopy: true,
          ),

          const Divider(height: 24),

          // Phone
          if (user.phone != null)
            _InfoRow(
              icon: Icons.phone_outlined,
              label: context.translate('phone'),
              value: user.phone!,
              canCopy: true,
            ),

          if (user.phone != null) const Divider(height: 24),

          // EdVerse ID
          if (user.edverseId != null)
            _InfoRow(
              icon: Icons.badge_outlined,
              label: context.translate('edverse_id'),
              value: user.edverseId!,
              canCopy: true,
            ),

          if (user.edverseId != null) const Divider(height: 24),

          // Status
          _InfoRow(
            icon: Icons.info_outline,
            label: context.translate('status'),
            value: user.status.toUpperCase(),
            valueColor:
                user.status.toLowerCase() == 'active'
                    ? AppTheme.success
                    : AppTheme.warning,
          ),

          const Divider(height: 24),

          // Member Since
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: context.translate('member_since'),
            value: DateFormat('MMM dd, yyyy').format(user.createdAt),
          ),

          // Student/Teacher specific info
          if (user.student != null) ...[
            const Divider(height: 24),
            _buildStudentInfo(context, user.student!),
          ],

          if (user.teacher != null) ...[
            const Divider(height: 24),
            _buildTeacherInfo(context, user.teacher!),
          ],
        ],
      ),
    ),
  );

  Widget _buildStudentInfo(BuildContext context, Student student) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.translate('student_information'),
        style: context.textTheme.titleBase.copyWith(color: AppTheme.slate800),
      ),
      const SizedBox(height: 12),
      _InfoRow(
        icon: Icons.school_outlined,
        label: context.translate('student_id'),
        value: student.institutionId?.toString() ?? '',
        canCopy: true,
      ),
      if (student.admissionNumber != null) ...[
        const Divider(height: 24),
        _InfoRow(
          icon: Icons.confirmation_number_outlined,
          label: context.translate('admission_number'),
          value: student.admissionNumber!,
          canCopy: true,
        ),
      ],
      if (student.rollNumber != null) ...[
        const Divider(height: 24),
        _InfoRow(
          icon: Icons.numbers_outlined,
          label: context.translate('roll_number'),
          value: student.rollNumber!,
        ),
      ],
    ],
  );

  Widget _buildTeacherInfo(BuildContext context, Teacher teacher) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.translate('teacher_information'),
        style: context.textTheme.titleBase.copyWith(color: AppTheme.slate800),
      ),
      const SizedBox(height: 12),
      _InfoRow(
        icon: Icons.work_outline,
        label: context.translate('employee_id'),
        value: teacher.employeeId,
        canCopy: true,
      ),
      const Divider(height: 24),
      _InfoRow(
        icon: Icons.business_center_outlined,
        label: context.translate('designation'),
        value: teacher.designation,
      ),
      if (teacher.specialization != null) ...[
        const Divider(height: 24),
        _InfoRow(
          icon: Icons.stars_outlined,
          label: context.translate('specialization'),
          value: teacher.specialization!,
        ),
      ],
      if (teacher.qualification != null) ...[
        const Divider(height: 24),
        _InfoRow(
          icon: Icons.school_outlined,
          label: context.translate('qualification'),
          value: teacher.qualification!,
        ),
      ],
      const Divider(height: 24),
      _InfoRow(
        icon: Icons.work_history_outlined,
        label: context.translate('experience'),
        value: '${teacher.experienceYears} ${context.translate('years')}',
      ),
      if (teacher.officeLocation != null) ...[
        const Divider(height: 24),
        _InfoRow(
          icon: Icons.location_on_outlined,
          label: context.translate('office_location'),
          value: teacher.officeLocation!,
        ),
      ],
    ],
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.canCopy = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool canCopy;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.blue50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppTheme.blue500),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textTheme.bodySm.copyWith(
                color: AppTheme.slate500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: context.textTheme.labelBase.copyWith(
                color: valueColor ?? AppTheme.slate800,
              ),
            ),
          ],
        ),
      ),
      if (canCopy)
        IconButton(
          icon: const Icon(Icons.copy_outlined, size: 20, color: AppTheme.slate500),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            showCustomSnackbar(
              message: context.translate('copied_to_clipboard'),
              type: SnackbarType.success,
            );
          },
        ),
    ],
  );
}
