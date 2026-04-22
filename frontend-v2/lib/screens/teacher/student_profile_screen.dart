import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../data/mock_data.dart';

class StudentProfileScreen extends StatefulWidget {
  final StudentProfileData profile;

  const StudentProfileScreen({super.key, required this.profile});

  static void push(BuildContext context, StudentProfileData profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudentProfileScreen(profile: profile),
      ),
    );
  }

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _insightGenerated = false;
  bool _isGeneratingInsight = false;

  Future<void> _generateInsight() async {
    if (_insightGenerated || _isGeneratingInsight) return;
    setState(() => _isGeneratingInsight = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isGeneratingInsight = false;
        _insightGenerated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textDark,
        ),
        title: Text(
          'Student Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
            color: AppColors.textDark,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 128),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 32),
              _buildDevelopmentSummaryCard(),
              const SizedBox(height: 16),
              _buildKeyIndicatorsCard(),
              const SizedBox(height: 16),
              _buildEngagementTrendCard(),
              const SizedBox(height: 16),
              _buildAiInsightCard(context),
              const SizedBox(height: 16),
              _buildRecentObservationsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textDark.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.profile.avatarUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.lavenderPlaceholder,
                    child: const Icon(Icons.person, size: 48),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.lavenderPlaceholder,
                    child: const Icon(Icons.person, size: 48),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurpleLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF8F9FE), width: 4),
                ),
                child: const Icon(Icons.star, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.profile.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.75,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.profile.gradeSection,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.profile.badges.asMap().entries.map((e) {
                  final isFirst = e.key == 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isFirst
                          ? AppColors.primaryPurpleLight.withValues(alpha: 0.1)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      e.value.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.55,
                        color: isFirst ? AppColors.primaryPurpleLight : const Color(0xFF15803D),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDevelopmentSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.05),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, size: 16, color: AppColors.primaryPurpleLight),
              const SizedBox(width: 8),
              Text(
                'Development Summary',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurpleLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProfileProgressBar('PARTICIPATION', widget.profile.participationPercent, AppColors.primaryPurpleLight),
          const SizedBox(height: 24),
          _buildProfileProgressBar('UNDERSTANDING', widget.profile.understandingPercent, AppColors.blueTrend),
          const SizedBox(height: 24),
          _buildProfileProgressBar('BEHAVIOR', widget.profile.behaviorPercent, AppColors.textDark),
        ],
      ),
    );
  }

  Widget _buildProfileProgressBar(String label, int percent, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
                color: AppColors.textMuted.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '$percent%',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.lavenderPlaceholder,
            borderRadius: BorderRadius.circular(999),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent / 100,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyIndicatorsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.05),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label_outline, size: 16, color: AppColors.primaryPurpleLight),
              const SizedBox(width: 8),
              Text(
                'Key Indicators',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurpleLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.profile.keyIndicators.asMap().entries.map((e) {
              final isFirst = e.key == 0;
              final isNeedsReview = e.value == 'Needs Review';
              Color bgColor;
              Color textColor;
              if (isNeedsReview) {
                bgColor = AppColors.absentRedLight;
                textColor = AppColors.absentRed;
              } else if (isFirst) {
                bgColor = AppColors.primaryPurpleLight.withValues(alpha: 0.05);
                textColor = AppColors.primaryPurpleLight;
              } else {
                bgColor = AppColors.cardBackground;
                textColor = AppColors.textMuted;
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isNeedsReview ? Border.all(color: const Color(0xFFFEE2E2)) : null,
                ),
                child: Text(
                  e.value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementTrendCard() {
    final maxVal = widget.profile.engagementTrend.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.05),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.show_chart, size: 14, color: AppColors.primaryPurpleLight),
                  const SizedBox(width: 8),
                  Text(
                    '4-Week Engagement\nTrend',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: AppColors.primaryPurpleLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.blueTrend.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '+12% vs\nLY',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueTrend,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < widget.profile.engagementTrend.length; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: maxVal > 0
                              ? (widget.profile.engagementTrend[i] / maxVal * 100).clamp(16.0, 100.0)
                              : 16,
                          decoration: BoxDecoration(
                            color: i == 3
                                ? AppColors.primaryPurpleLight
                                : AppColors.primaryPurpleLight.withValues(alpha: 0.2 + i * 0.2),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          i == 3 ? 'CUR' : 'W${i + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: i == 3 ? AppColors.primaryPurpleLight : AppColors.textMuted.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard(BuildContext context) {
    final placeholderText =
        "Click the sparkle icon to generate a deep AI analysis of ${widget.profile.name}'s strengths based on all classroom signals.";
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryPurpleLight, Color(0xFF5B21B6)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurpleLight.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kram AI Insight',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _isGeneratingInsight ? null : _generateInsight,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isGeneratingInsight
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryPurpleLight,
                          ),
                        )
                      : const Icon(Icons.auto_awesome, color: AppColors.primaryPurpleLight, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _insightGenerated ? widget.profile.aiInsight : placeholderText,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
              fontStyle: _insightGenerated ? FontStyle.normal : FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          if (_insightGenerated) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Schedule Check-in tapped')),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Schedule Check-in',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryPurpleLight,
                ),
              ),
            ),
          ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentObservationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Observations',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.profile.recentObservations.map((obs) => _buildObservationCard(obs)),
      ],
    );
  }

  Widget _buildObservationCard(StudentProfileObservation obs) {
    Color iconBg;
    IconData icon;
    switch (obs.variant) {
      case 'assessment':
        iconBg = const Color(0xFFE0E7FF);
        icon = Icons.description_outlined;
        break;
      case 'seminar':
        iconBg = const Color(0xFFCFFAFE);
        icon = Icons.chat_bubble_outline;
        break;
      case 'warning':
        iconBg = const Color(0xFFFEF3C7);
        icon = Icons.warning_amber_rounded;
        break;
      default:
        iconBg = AppColors.tagLavender;
        icon = Icons.note_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.05),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.textDark),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      obs.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      obs.timeAgo.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  obs.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sizes child to a fraction of the total space.
class FractionallySizedBox extends StatelessWidget {
  final double widthFactor;
  final Alignment alignment;
  final Widget child;

  const FractionallySizedBox({
    super.key,
    required this.widthFactor,
    this.alignment = Alignment.centerLeft,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: alignment,
          child: SizedBox(
            width: constraints.maxWidth * widthFactor,
            child: child,
          ),
        );
      },
    );
  }
}
