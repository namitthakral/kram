import 'package:flutter/material.dart';
import '../models/template_models.dart';
import '../../../core/theme/app_theme.dart';

class QuestionPaperPreviewScreen extends StatelessWidget {
  final QuestionPaperTemplate template;

  const QuestionPaperPreviewScreen({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Question Paper'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.slate800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              template.schoolName.toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              template.schoolAddress,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              template.examName.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Meta Data Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Class: ${template.className}'),
                Text('Date: ${template.date}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subject: ${template.subject}'),
                Text('Duration: ${template.duration} mins'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(), // Spacer
                Text('Max Marks: ${template.maxMarks}'),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Instructions
            if ((template.instructions ?? '').isNotEmpty) ...[
              const Text(
                'General Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(template.instructions ?? ''),
              const SizedBox(height: 24),
            ],

            // Sections
            ...template.sections.map((section) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      section.sectionName.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (section.description != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          section.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ...section.questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final q = entry.value;
                    final qNum = index + 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$qNum. ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(q.questionText),
                                if (q.mcqOptions != null) ...[
                                  const SizedBox(height: 8),
                                  ...q.mcqOptions!.map(
                                    (opt) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.circle_outlined,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(opt),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            ' [${q.customMarks ?? section.marksPerQuestion}]',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              );
            }),

            const SizedBox(height: 32),
            const Center(child: Text('*** END OF QUESTION PAPER ***')),
          ],
        ),
      ),
    );
  }
}
