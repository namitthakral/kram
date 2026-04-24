import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../data/mock_data.dart';

/// Quick observation modal for giving feedback when a teacher taps a student.
class QuickObservationModal extends StatefulWidget {
  final RosterStudent student;

  const QuickObservationModal({super.key, required this.student});

  static Future<void> show(BuildContext context, RosterStudent student) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickObservationModal(student: student),
    );
  }

  @override
  State<QuickObservationModal> createState() => _QuickObservationModalState();
}

class _QuickObservationModalState extends State<QuickObservationModal> {
  final ValueNotifier<String?> _participation = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _conceptUnderstanding = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _homework = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _behavior = ValueNotifier<String?>(null);
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _participation.dispose();
    _conceptUnderstanding.dispose();
    _homework.dispose();
    _behavior.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(),
              _buildHeader(context),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildParticipationSection(),
                      const SizedBox(height: 28),
                      _buildConceptUnderstandingSection(),
                      const SizedBox(height: 28),
                      _buildHomeworkSection(),
                      const SizedBox(height: 28),
                      _buildBehaviorSection(),
                      const SizedBox(height: 28),
                      _buildAdditionalNotesSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildSaveButton(context),
            ],
          ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Container(
        width: 48,
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.borderLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurpleLight.withValues(alpha: 0.1),
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.student.avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.lavenderPlaceholder,
                      child: const Icon(Icons.person),
                    ),
                    errorWidget: (context, url, error) => Container(
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
                    color: AppColors.presentBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
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
                  widget.student.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  MockData.courseName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF515F74),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE2E7FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryPurple),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.4,
            color: AppColors.textMuted.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipationSection() {
    return ValueListenableBuilder<String?>(
      valueListenable: _participation,
      builder: (context, value, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader('Participation', Icons.group),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPillChip('Active', value == 'Active', () => _participation.value = 'Active', showCheckIcon: false)),
                const SizedBox(width: 10),
                Expanded(child: _buildPillChip('Quiet', value == 'Quiet', () => _participation.value = 'Quiet', showCheckIcon: false)),
                const SizedBox(width: 10),
                Expanded(child: _buildPillChip('Distracted', value == 'Distracted', () => _participation.value = 'Distracted', showCheckIcon: false)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildConceptUnderstandingSection() {
    return ValueListenableBuilder<String?>(
      valueListenable: _conceptUnderstanding,
      builder: (context, value, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader('Concept Understanding', Icons.lightbulb_outline),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildBoxChip(
                      'Strong',
                      Icons.sentiment_satisfied_alt,
                      value == 'Strong',
                      () => _conceptUnderstanding.value = 'Strong',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildBoxChip(
                      'Average',
                      Icons.sentiment_neutral,
                      value == 'Average',
                      () => _conceptUnderstanding.value = 'Average',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildBoxChip(
                      'Needs Help',
                      Icons.sentiment_dissatisfied,
                      value == 'Needs Help',
                      () => _conceptUnderstanding.value = 'Needs Help',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHomeworkSection() {
    return ValueListenableBuilder<String?>(
      valueListenable: _homework,
      builder: (context, value, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader('Homework', Icons.assignment_outlined),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildHomeworkSubmittedChip(
                    value == 'Submitted',
                    () => _homework.value = 'Submitted',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHomeworkMissingChip(
                    value == 'Missing',
                    () => _homework.value = 'Missing',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildBehaviorSection() {
    return ValueListenableBuilder<String?>(
      valueListenable: _behavior,
      builder: (context, value, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader('Behavior', Icons.psychology_outlined),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPillChip(
                    'Helpful',
                    value == 'Helpful',
                    () => _behavior.value = 'Helpful',
                    leadingIcon: Icons.volunteer_activism,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPillChip(
                    'Disruptive',
                    value == 'Disruptive',
                    () => _behavior.value = 'Disruptive',
                    isNegative: true,
                    leadingIcon: Icons.warning_amber_rounded,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAdditionalNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lavenderPlaceholder.withValues(alpha: 0.4),
            border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tap to add specific observations...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.tagBlueText.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.95),
            Colors.white,
          ],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Observation saved for ${widget.student.name}',
                ),
              ),
            );
          },
          icon: const Icon(Icons.save, size: 18, color: Colors.white),
          label: Text(
            'Save Observation',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  /// Pill chip - uses Container (no animation) and RepaintBoundary to prevent flicker.
  /// Only reserves icon space when needed. showCheckIcon: false for Participation to avoid overflow.
  Widget _buildPillChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    bool isNegative = false,
    IconData? leadingIcon,
    bool showCheckIcon = true,
  }) {
    final bool showCheck = showCheckIcon && isSelected && !isNegative;
    final bool showLeadingIcon = leadingIcon != null;
    final bool showIconArea = showCheck || showLeadingIcon;
    final Color iconColor = isSelected
        ? (isNegative ? AppColors.absentRedDark : Colors.white)
        : (isNegative ? AppColors.absentRedDark : AppColors.tagBlueText);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: isSelected && !isNegative
                ? const LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.primaryPurpleLight],
                  )
                : null,
            color: isSelected && isNegative
                ? AppColors.absentRedLight
                : !isSelected
                    ? (isNegative ? AppColors.absentRedLight : AppColors.tagLavender)
                    : null,
            border: Border.all(
              color: isSelected && isNegative ? AppColors.absentRed : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showIconArea) ...[
                SizedBox(
                  width: 20,
                  child: Center(
                    child: showCheck
                        ? const Icon(Icons.check, size: 15, color: Colors.white)
                        : Icon(leadingIcon, size: 18, color: iconColor),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? (isNegative ? AppColors.absentRedDark : Colors.white)
                        : (isNegative ? AppColors.absentRedDark : AppColors.tagBlueText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Homework Submitted - Figma: light purple bg, purple border, purple text when selected.
  Widget _buildHomeworkSubmittedChip(bool isSelected, VoidCallback onTap) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryPurple.withValues(alpha: 0.05)
                : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primaryPurple : const Color(0x4DCCC3D8),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: isSelected ? AppColors.primaryPurple : AppColors.tagBlueText,
              ),
              const SizedBox(width: 8),
              Text(
                'Submitted',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primaryPurple : const Color(0xFF515F74),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Homework Missing - Figma: white bg, light border when unselected.
  Widget _buildHomeworkMissingChip(bool isSelected, VoidCallback onTap) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.absentRedLight : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.absentRed : const Color(0x4DCCC3D8),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_late,
                size: 20,
                color: isSelected ? AppColors.absentRedDark : const Color(0xFF515F74),
              ),
              const SizedBox(width: 8),
              Text(
                'Missing',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.absentRedDark : const Color(0xFF515F74),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Box chip for Concept Understanding - equal size tiles, no animation.
  Widget _buildBoxChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryPurple, AppColors.primaryPurpleLight],
                  )
                : null,
            color: isSelected ? null : AppColors.tagLavender,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.tagBlueText,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.tagBlueText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
