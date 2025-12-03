import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as web;

import '../models/template_models.dart';

class PdfTemplateService {
  static Future<void> generateTimetablePdf(TimetableTemplate template) async {
    final pdf =
        pw.Document()..addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build:
                (context) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Text(
                            template.schoolName.toUpperCase(),
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            template.schoolAddress,
                            style: const pw.TextStyle(fontSize: 11),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 16),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 2),
                            ),
                            child: pw.Text(
                              'CLASS TIME TABLE',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 24),

                    // Class Details
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Class: ${template.className} - ${template.section}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Academic Year: ${template.academicYear}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (template.classTeacher != null) ...[
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Class Teacher: ${template.classTeacher}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                    pw.SizedBox(height: 20),

                    // Timetable
                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        // Header row
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey300,
                          ),
                          children: [
                            _buildPdfHeaderCell('Time'),
                            ...template.days.map(_buildPdfHeaderCell),
                          ],
                        ),
                        // Time slot rows
                        ...template.slots.map(
                          (slot) => pw.TableRow(
                            children: [
                              _buildPdfTimeCell(slot.timeRange),
                              ...template.days.map(
                                (day) => _buildPdfPeriodCell(slot.periods[day]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.Spacer(),

                    // Footer
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(height: 40),
                            pw.Text('_________________'),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Class Teacher',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.SizedBox(height: 40),
                            pw.Text('_________________'),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Principal',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
          ),
        );

    // Save PDF
    // Sanitize filename by replacing spaces with underscores and removing special chars
    final className = template.className.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\-]'), '');
    final section = template.section.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\-]'), '');
    final fileName = 'TimeTable_${className}_$section.pdf';

    final pdfBytes = await pdf.save();

    if (kIsWeb) {
      // Web: Download using anchor element
      final fileInts = List<int>.from(pdfBytes);
      web.AnchorElement()
        ..href = 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}'
        ..setAttribute('download', fileName)
        ..click();
    } else {
      // Mobile: Save to temporary directory
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      // Note: On mobile, the file is saved to temp directory
      // Consider using a file picker or share dialog for better UX
    }
  }

  static Future<void> generateQuestionPaperPdf(
    QuestionPaperTemplate template,
  ) async {
    final pdf =
        pw.Document()..addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build:
                (context) => [
                  // Header
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          template.schoolName.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          template.schoolAddress,
                          style: const pw.TextStyle(fontSize: 11),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 16),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 2),
                          ),
                          child: pw.Text(
                            template.examName.toUpperCase(),
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Exam Details
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Class: ${template.className} - ${template.section}',
                            style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Subject: ${template.subject}',
                            style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Date: ${template.date}',
                            style: const pw.TextStyle(fontSize: 13),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Time: ${template.duration}',
                            style: const pw.TextStyle(fontSize: 13),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Max. Marks: ${template.maxMarks}',
                            style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                  pw.Divider(thickness: 2),
                  pw.SizedBox(height: 16),

                  // Instructions
                  if (template.instructions != null) ...[
                    pw.Text(
                      'GENERAL INSTRUCTIONS:',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      template.instructions!,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 20),
                  ],

                  // Sections
                  ...template.sections.map(_buildPdfSection),

                  pw.SizedBox(height: 32),

                  // Footer
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Divider(),
                        pw.SizedBox(height: 16),
                        pw.Text(
                          '*** END OF QUESTION PAPER ***',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        );

    // Save PDF
    // Sanitize filename by replacing spaces with underscores and removing special chars
    final subject = template.subject.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\-]'), '');
    final className = template.className.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\-]'), '');
    final section = template.section.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\-]'), '');
    final fileName = 'QuestionPaper_${subject}_${className}_$section.pdf';

    final pdfBytes = await pdf.save();

    if (kIsWeb) {
      // Web: Download using anchor element
      final fileInts = List<int>.from(pdfBytes);
      web.AnchorElement()
        ..href = 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}'
        ..setAttribute('download', fileName)
        ..click();
    } else {
      // Mobile: Save to temporary directory
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      // Note: On mobile, the file is saved to temp directory
      // Consider using a file picker or share dialog for better UX
    }
  }

  static Future<File> saveTimetablePdf(TimetableTemplate template) async {
    final pdf = pw.Document();
    // Same PDF generation code as above
    // ... (implementation similar to generateTimetablePdf)

    final output = await getApplicationDocumentsDirectory();
    final file = File(
      '${output.path}/Timetable_${template.className}_${template.section}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<File> saveQuestionPaperPdf(
    QuestionPaperTemplate template,
  ) async {
    final pdf = pw.Document();
    // Same PDF generation code as above
    // ... (implementation similar to generateQuestionPaperPdf)

    final output = await getApplicationDocumentsDirectory();
    final file = File(
      '${output.path}/Question_Paper_${template.subject}_${template.className}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Helper methods for timetable PDF
  static pw.Widget _buildPdfHeaderCell(String text) => pw.Container(
    padding: const pw.EdgeInsets.all(10),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
    ),
  );

  static pw.Widget _buildPdfTimeCell(String time) => pw.Container(
    padding: const pw.EdgeInsets.all(10),
    child: pw.Text(
      time,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
    ),
  );

  static pw.Widget _buildPdfPeriodCell(SubjectPeriod? period) => pw.Container(
    padding: const pw.EdgeInsets.all(8),
    height: 60,
    child:
        period != null
            ? pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  period.subject,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                if (period.teacher != null)
                  pw.Text(
                    period.teacher!,
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
              ],
            )
            : pw.SizedBox(),
  );

  // Helper methods for question paper PDF
  static pw.Widget _buildPdfSection(QuestionSection section) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey300,
          border: pw.Border.all(),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              section.sectionName.toUpperCase(),
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            if (section.description != null) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                section.description!,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
      pw.SizedBox(height: 16),
      ...List.generate(
        section.questions.length,
        (index) => _buildPdfQuestion(
          index + 1,
          section.questions[index],
          section.marksPerQuestion,
        ),
      ),
      pw.SizedBox(height: 24),
    ],
  );

  static pw.Widget _buildPdfQuestion(
    int number,
    Question question,
    int defaultMarks,
  ) {
    final marks = question.customMarks ?? defaultMarks;
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$number. ',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(
            child: pw.Text(
              question.questionText,
              style: const pw.TextStyle(fontSize: 13),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Text(
              '[$marks]',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
