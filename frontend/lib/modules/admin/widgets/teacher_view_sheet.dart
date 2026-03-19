import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/user_utils.dart';
import '../../teacher/services/teacher_service.dart';

/// A modal bottom sheet that displays read-only teacher information.
///
/// Returns `true` if the caller should refresh the teacher list (status
/// toggled or edit dialog saved).
class TeacherViewSheet extends StatefulWidget {
  const TeacherViewSheet({required this.teacher, super.key});

  final Map<String, dynamic> teacher;

  @override
  State<TeacherViewSheet> createState() => _TeacherViewSheetState();
}

class _TeacherViewSheetState extends State<TeacherViewSheet> {
  final TeacherService _teacherService = TeacherService();
  bool _isTogglingStatus = false;
  bool _needsRefresh = false;

  // Local mutable copy of user status so setState() re-renders the badge
  late String _localUserStatus;

  // ── Helpers ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final user = (widget.teacher['user'] as Map<String, dynamic>?) ?? {};
    _localUserStatus = (user['accountStatus'] as String?) ?? 'ACTIVE';
  }

  Map<String, dynamic> get _user =>
      (widget.teacher['user'] as Map<String, dynamic>?) ?? {};

  String get _name {
    final firstName = _user['firstName'] as String? ?? '';
    final lastName = _user['lastName'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? 'Teacher' : fullName;
  }
  String get _email => _user['email'] as String? ?? '—';
  String get _phone => _user['phone'] as String? ?? '—';
  // Use local mutable state so toggles re-render immediately
  bool get _isActive => _localUserStatus == 'ACTIVE';

  String get _teacherUuid => _user['uuid'] as String? ?? '';

  String get _designation => widget.teacher['designation'] as String? ?? '—';
  String get _specialization =>
      widget.teacher['specialization'] as String? ?? '—';
  String get _qualification =>
      widget.teacher['qualification'] as String? ?? '—';
  String get _employmentType =>
      (widget.teacher['employmentType'] as String? ?? '—').replaceAll('_', ' ');
  String get _experienceYears {
    final v = widget.teacher['experienceYears'];
    if (v == null) return '—';
    return '$v year${v == 1 ? '' : 's'}';
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _toggleStatus() async {
    final newStatus = _isActive ? 'INACTIVE' : 'ACTIVE';
    setState(() => _isTogglingStatus = true);
    try {
      // Send `userStatus` — the backend maps this to User.status (ACTIVE/INACTIVE)
      await _teacherService.updateTeacher(_teacherUuid, {
        'userStatus': newStatus,
      });
      if (mounted) {
        _localUserStatus = newStatus; // update local reactive state
        _needsRefresh = true;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Teacher marked as ${newStatus == 'ACTIVE' ? 'Active' : 'Inactive'}',
            ),
            backgroundColor:
                newStatus == 'ACTIVE'
                    ? const Color(0xFF10b981)
                    : AppTheme.slate600,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingStatus = false);
    }
  }

  Future<void> _openEdit() async {
    // Close sheet first, then open edit dialog from parent
    Navigator.of(context).pop(true); // `true` = refresh list
    // Caller in admin_teachers_screen.dart will handle showing EditTeacherDialog
    // We signal via a special sentinel: pass teacher with edit flag
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final initials = UserUtils.getInitials(_name);

    return PopScope(
      onPopInvokedWithResult: (_, __) {
        // nothing special needed; parent detects result via Navigator.pop value
      },
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ───────────────────────────────────────────────
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.blue500.withValues(alpha: 0.15),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.blue600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _designation,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.slate500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _StatusBadge(isActive: _isActive),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(_needsRefresh),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: AppTheme.slate100, height: 1),

            // ── Details ───────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _email,
                    ),
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: _phone,
                    ),
                    _DetailRow(
                      icon: Icons.school_outlined,
                      label: 'Specialization',
                      value: _specialization,
                    ),
                    _DetailRow(
                      icon: Icons.workspace_premium_outlined,
                      label: 'Qualification',
                      value: _qualification,
                    ),
                    _DetailRow(
                      icon: Icons.timer_outlined,
                      label: 'Experience',
                      value: _experienceYears,
                    ),
                    _DetailRow(
                      icon: Icons.badge_outlined,
                      label: 'Employment Type',
                      value: _employmentType,
                    ),
                  ],
                ),
              ),
            ),

            // ── Action Buttons ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 8,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              child: Row(
                children: [
                  // Edit button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.blue600,
                        side: const BorderSide(color: AppTheme.blue500),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Toggle Active / Inactive button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isTogglingStatus ? null : _toggleStatus,
                      icon:
                          _isTogglingStatus
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Icon(
                                _isActive
                                    ? Icons.block_rounded
                                    : Icons.check_circle_outline_rounded,
                                size: 18,
                              ),
                      label: Text(_isActive ? 'Mark Inactive' : 'Mark Active'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isActive
                                ? const Color(0xFFef4444)
                                : const Color(0xFF10b981),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.slate200,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color:
          isActive
              ? const Color(0xFF10b981).withValues(alpha: 0.12)
              : AppTheme.slate100,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF10b981) : AppTheme.slate500,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF059669) : AppTheme.slate600,
          ),
        ),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.slate100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.slate500),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.slate500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.slate600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
