class TimetableTemplate {
  TimetableTemplate({
    required this.schoolName,
    required this.schoolAddress,
    required this.className,
    required this.section,
    required this.academicYear,
    required this.slots,
    this.days = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    this.classTeacher,
  });

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

  factory TimetableTemplate.fromJson(Map<String, dynamic> json) =>
      TimetableTemplate(
        schoolName: json['schoolName'] as String,
        schoolAddress: json['schoolAddress'] as String,
        className: json['className'] as String,
        section: json['section'] as String,
        academicYear: json['academicYear'] as String,
        slots: (json['slots'] as List)
            .map((s) => TimetableSlot.fromJson(s as Map<String, dynamic>))
            .toList(),
        days: (json['days'] as List).cast<String>(),
        classTeacher: json['classTeacher'] as String?,
      );
}

class TimetableSlot {
  TimetableSlot({
    required this.timeRange,
    required this.periods,
    this.mergedLabel,  // For lunch/break periods that span all days
  });

  final String timeRange;
  final Map<String, SubjectPeriod?> periods; // day -> period
  final String? mergedLabel;  // If set, this slot is a merged break/lunch period

  Map<String, dynamic> toJson() => {
        'timeRange': timeRange,
        'periods': periods.map((k, v) => MapEntry(k, v?.toJson())),
        'mergedLabel': mergedLabel,
      };

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
}

class SubjectPeriod {
  SubjectPeriod({
    required this.subject,
    this.teacher,
    this.room,
  });

  final String subject;
  final String? teacher;
  final String? room;

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'teacher': teacher,
        'room': room,
      };

  factory SubjectPeriod.fromJson(Map<String, dynamic> json) => SubjectPeriod(
        subject: json['subject'] as String,
        teacher: json['teacher'] as String?,
        room: json['room'] as String?,
      );
}

class QuestionPaperTemplate {
  QuestionPaperTemplate({
    required this.schoolName,
    required this.schoolAddress,
    required this.examName,
    required this.className,
    required this.section,
    required this.subject,
    required this.date,
    required this.duration,
    required this.maxMarks,
    required this.sections,
    this.instructions,
    this.logo,
  });

  final String schoolName;
  final String schoolAddress;
  final String examName;
  final String className;
  final String section;
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

  factory QuestionPaperTemplate.fromJson(Map<String, dynamic> json) =>
      QuestionPaperTemplate(
        schoolName: json['schoolName'] as String,
        schoolAddress: json['schoolAddress'] as String,
        examName: json['examName'] as String,
        className: json['className'] as String,
        section: json['section'] as String,
        subject: json['subject'] as String,
        date: json['date'] as String,
        duration: json['duration'] as String,
        maxMarks: json['maxMarks'] as int,
        sections: (json['sections'] as List)
            .map((s) => QuestionSection.fromJson(s as Map<String, dynamic>))
            .toList(),
        instructions: json['instructions'] as String?,
        logo: json['logo'] as String?,
      );
}

class QuestionSection {
  QuestionSection({
    required this.sectionName,
    required this.questions,
    required this.marksPerQuestion,
    this.description,
  });

  final String sectionName;
  final String? description;
  final List<Question> questions;
  final int marksPerQuestion;

  int get totalMarks => questions.length * marksPerQuestion;

  Map<String, dynamic> toJson() => {
        'sectionName': sectionName,
        'description': description,
        'questions': questions.map((q) => q.toJson()).toList(),
        'marksPerQuestion': marksPerQuestion,
      };

  factory QuestionSection.fromJson(Map<String, dynamic> json) =>
      QuestionSection(
        sectionName: json['sectionName'] as String,
        description: json['description'] as String?,
        questions: (json['questions'] as List)
            .map((q) => Question.fromJson(q as Map<String, dynamic>))
            .toList(),
        marksPerQuestion: json['marksPerQuestion'] as int,
      );
}

class Question {
  Question({
    required this.questionText,
    this.customMarks,
  });

  final String questionText;
  final int? customMarks;

  Map<String, dynamic> toJson() => {
        'questionText': questionText,
        'customMarks': customMarks,
      };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        questionText: json['questionText'] as String,
        customMarks: json['customMarks'] as int?,
      );
}
