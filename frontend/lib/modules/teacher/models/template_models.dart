class TimetableTemplate {
  TimetableTemplate({
    required this.schoolName,
    required this.schoolAddress,
    required this.className,
    required this.section,
    required this.academicYear,
    required this.slots,
    this.days = const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ],
    this.classTeacher,
  });

  factory TimetableTemplate.fromJson(Map<String, dynamic> json) =>
      TimetableTemplate(
        schoolName: json['schoolName'] as String,
        schoolAddress: json['schoolAddress'] as String,
        className: json['className'] as String,
        section: json['section'] as String,
        academicYear: json['academicYear'] as String,
        slots:
            (json['slots'] as List)
                .map((s) => TimetableSlot.fromJson(s as Map<String, dynamic>))
                .toList(),
        days: (json['days'] as List).cast<String>(),
        classTeacher: json['classTeacher'] as String?,
      );

  final String schoolName;
  final String schoolAddress;
  final String className;
  final String section;
  final String academicYear;
  final List<TimetableSlot> slots;
  final List<String> days;
  final String? classTeacher;

  Map<String, dynamic> toJson() => {
    'schoolName': schoolName,
    'schoolAddress': schoolAddress,
    'className': className,
    'section': section,
    'academicYear': academicYear,
    'slots': slots.map((s) => s.toJson()).toList(),
    'days': days,
    'classTeacher': classTeacher,
  };
}

class TimetableSlot {
  TimetableSlot({
    required this.timeRange,
    required this.periods,
    this.mergedLabel, // For lunch/break periods that span all days
  });

  factory TimetableSlot.fromJson(Map<String, dynamic> json) => TimetableSlot(
    timeRange: json['timeRange'] as String,
    periods: (json['periods'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        k,
        v != null ? SubjectPeriod.fromJson(v as Map<String, dynamic>) : null,
      ),
    ),
    mergedLabel: json['mergedLabel'] as String?,
  );

  final String timeRange;
  final Map<String, SubjectPeriod?> periods; // day -> period
  final String? mergedLabel; // If set, this slot is a merged break/lunch period

  Map<String, dynamic> toJson() => {
    'timeRange': timeRange,
    'periods': periods.map((k, v) => MapEntry(k, v?.toJson())),
    'mergedLabel': mergedLabel,
  };
}

class SubjectPeriod {
  SubjectPeriod({
    required this.subject,
    this.teacher,
    this.room,
    this.subjectId,
    this.teacherId,
    this.roomId,
  });

  factory SubjectPeriod.fromJson(Map<String, dynamic> json) => SubjectPeriod(
    subject: json['subject'] as String,
    teacher: json['teacher'] as String?,
    room: json['room'] as String?,
    subjectId: json['subjectId'] as int?,
    teacherId: json['teacherId'] as int?,
    roomId: json['roomId'] as int?,
  );

  final String subject;
  final String? teacher;
  final String? room;
  final int? subjectId;
  final int? teacherId;
  final int? roomId;

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'teacher': teacher,
    'room': room,
    'subjectId': subjectId,
    'teacherId': teacherId,
    'roomId': roomId,
  };
}

class QuestionPaperTemplate {
  QuestionPaperTemplate({
    required this.schoolName,
    required this.schoolAddress,
    required this.examName,
    required this.className,
    required this.subject,
    required this.date,
    required this.duration,
    required this.maxMarks,
    required this.sections,
    this.section = '', // Default to empty string if not provided
    this.instructions,
    this.logo,
  });

  factory QuestionPaperTemplate.fromJson(Map<String, dynamic> json) =>
      QuestionPaperTemplate(
        schoolName: json['schoolName'] as String,
        schoolAddress: json['schoolAddress'] as String,
        examName: json['examName'] as String,
        className: json['className'] as String,
        section: json['section'] as String? ?? '', // Handle nullable or empty
        subject: json['subject'] as String,
        date: json['date'] as String,
        duration: json['duration'] as String,
        maxMarks: json['maxMarks'] as int,
        sections:
            (json['sections'] as List)
                .map((s) => QuestionSection.fromJson(s as Map<String, dynamic>))
                .toList(),
        instructions: json['instructions'] as String?,
        logo: json['logo'] as String?,
      );

  final String schoolName;
  final String schoolAddress;
  final String examName;
  final String className;
  final String section; // Keep as String but it can be empty
  final String subject;
  final String date;
  final String duration;
  final int maxMarks;
  final List<QuestionSection> sections;
  final String? instructions;
  final String? logo;

  Map<String, dynamic> toJson() => {
    'schoolName': schoolName,
    'schoolAddress': schoolAddress,
    'examName': examName,
    'className': className,
    'section': section,
    'subject': subject,
    'date': date,
    'duration': duration,
    'maxMarks': maxMarks,
    'sections': sections.map((s) => s.toJson()).toList(),
    'instructions': instructions,
    'logo': logo,
  };
}

class QuestionSection {
  QuestionSection({
    required this.sectionName,
    required this.questions,
    required this.marksPerQuestion,
    this.description,
  });

  factory QuestionSection.fromJson(Map<String, dynamic> json) =>
      QuestionSection(
        sectionName: json['sectionName'] as String,
        description: json['description'] as String?,
        questions:
            (json['questions'] as List)
                .map((q) => Question.fromJson(q as Map<String, dynamic>))
                .toList(),
        marksPerQuestion: json['marksPerQuestion'] as int,
      );

  final String sectionName;
  final String? description;
  final List<Question> questions;
  final int marksPerQuestion;

  int get totalMarks => questions.fold(
    0,
    (sum, question) => sum + (question.customMarks ?? marksPerQuestion),
  );

  Map<String, dynamic> toJson() => {
    'sectionName': sectionName,
    'description': description,
    'questions': questions.map((q) => q.toJson()).toList(),
    'marksPerQuestion': marksPerQuestion,
  };
}

enum QuestionType {
  written, // Descriptive/written answer questions
  mcq, // Multiple choice questions
}

class Question {
  Question({
    required this.questionText,
    this.customMarks,
    this.type = QuestionType.written,
    this.hasImage = false,
    this.imagePlaceholder,
    this.mcqOptions,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    questionText: json['questionText'] as String,
    customMarks: json['customMarks'] as int?,
    type:
        json['type'] != null
            ? QuestionType.values.firstWhere(
              (e) => e.toString() == 'QuestionType.${json['type']}',
              orElse: () => QuestionType.written,
            )
            : QuestionType.written,
    hasImage: json['hasImage'] as bool? ?? false,
    imagePlaceholder: json['imagePlaceholder'] as String?,
    mcqOptions:
        json['mcqOptions'] != null
            ? (json['mcqOptions'] as List).cast<String>()
            : null,
  );

  final String questionText;
  final int? customMarks;
  final QuestionType type;
  final bool hasImage;
  final String? imagePlaceholder; // Text to show in image placeholder
  final List<String>? mcqOptions; // Options for MCQ questions

  Map<String, dynamic> toJson() => {
    'questionText': questionText,
    'customMarks': customMarks,
    'type': type.toString().split('.').last,
    'hasImage': hasImage,
    'imagePlaceholder': imagePlaceholder,
    'mcqOptions': mcqOptions,
  };
}
