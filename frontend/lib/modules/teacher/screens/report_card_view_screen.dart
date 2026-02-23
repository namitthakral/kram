import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../models/report_card_models.dart';
import '../services/pdf_template_service.dart';

/// Viewable report card screen: shows full report and provides Download.
class ReportCardViewScreen extends StatelessWidget {
  const ReportCardViewScreen({super.key, required this.reportCard});

  final ReportCardData reportCard;

  @override
  Widget build(BuildContext context) {
    final student = reportCard.studentInfo;
    final semester = reportCard.semesterInfo;
    final perf = reportCard.performanceSummary;
    final att = reportCard.attendanceSummary;
    final courseSection =
        '${student.courseName ?? ''}${student.section != null ? ' / ${student.section}' : ''}'.trim();

    return CustomMainScreenWithAppbar(
      title: 'Report Card - ${student.name}',
      appBarConfig: AppBarConfig.standard(
        showBackButton: true,
        onBackButtonTapped: () => context.pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: () => PdfTemplateService.generateReportCardPdf(reportCard),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header block
            _SectionCard(
              title: reportCard.studentInfo.institutionName,
              subtitle: 'Report No: ${reportCard.reportCardNumber}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow('Student Name', student.name),
                  _InfoRow('Admission No', student.admissionNumber),
                  if (student.rollNumber != null)
                    _InfoRow('Roll No', student.rollNumber!),
                  _InfoRow('Class / Section', courseSection.isEmpty ? '-' : courseSection),
                  _InfoRow('School Year', semester.academicYear),
                  _InfoRow('Semester', semester.semesterName),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Subjects
            _SectionCard(
              title: 'Subject-wise performance',
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FlexColumnWidth(2.5),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    children: [
                    _tableHeader('Subject'),
                    _tableHeader('Marks'),
                    _tableHeader('Max'),
                    _tableHeader('Grade'),
                    ],
                  ),
                  for (final sub in reportCard.subjectRecords)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Text(
                            sub.subjectName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _tableCell(sub.marksObtained?.toString() ?? '-'),
                        _tableCell(sub.maxMarks?.toString() ?? '-'),
                        _tableCell(sub.grade ?? '-'),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Performance & attendance
            _SectionCard(
              title: 'Performance summary',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow('SGPA', '${perf.sgpa}'),
                  _InfoRow('CGPA', '${perf.cgpa}'),
                  _InfoRow('Overall grade', perf.overallGrade),
                  _InfoRow('Status', perf.overallStatus),
                  if (perf.classRank != null)
                    _InfoRow('Class rank', '${perf.classRank}'),
                  const Divider(height: 24),
                  _InfoRow('Total school days', '${att.totalClasses}'),
                  _InfoRow('Attendance', '${(att.percentage).toStringAsFixed(1)}%'),
                ],
              ),
            ),
            if (reportCard.remarks.principalRemarks != null &&
                reportCard.remarks.principalRemarks!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Remarks',
                child: Text(
                  reportCard.remarks.principalRemarks!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            if (reportCard.remarks.classTeacherRemarks != null &&
                reportCard.remarks.classTeacherRemarks!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SectionCard(
                title: "Teacher's remarks",
                child: Text(
                  reportCard.remarks.classTeacherRemarks!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e293b),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _tableHeader(String text) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );

Widget _tableCell(String text) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
