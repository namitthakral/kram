-- ============================================================================
-- PERFORMANCE OPTIMIZATION MIGRATION
-- Creates database views and indexes for improved query performance
-- ============================================================================

-- ============================================================================
-- 1. STUDENT ATTENDANCE SUMMARY VIEW
-- Pre-aggregated attendance data per student/subject/semester
-- Used by: Report cards, student dashboard, progress tracking
-- ============================================================================
CREATE OR REPLACE VIEW student_attendance_summary AS
SELECT 
  a.student_id,
  cs.semester_id,
  cs.subject_id,
  s.subject_name,
  s.subject_code,
  cs.section_name,
  COUNT(*) as total_classes,
  COUNT(*) FILTER (WHERE a.status = 'PRESENT') as classes_present,
  COUNT(*) FILTER (WHERE a.status = 'ABSENT') as classes_absent,
  COUNT(*) FILTER (WHERE a.status = 'LATE') as classes_late,
  COUNT(*) FILTER (WHERE a.status = 'EXCUSED') as classes_excused,
  ROUND(
    (COUNT(*) FILTER (WHERE a.status IN ('PRESENT', 'LATE'))::DECIMAL / NULLIF(COUNT(*), 0)) * 100, 
    2
  ) as attendance_percentage,
  CASE 
    WHEN ROUND((COUNT(*) FILTER (WHERE a.status IN ('PRESENT', 'LATE'))::DECIMAL / NULLIF(COUNT(*), 0)) * 100, 2) >= 95 
      THEN 'excellent'
    WHEN ROUND((COUNT(*) FILTER (WHERE a.status IN ('PRESENT', 'LATE'))::DECIMAL / NULLIF(COUNT(*), 0)) * 100, 2) >= 90 
      THEN 'good'
    WHEN ROUND((COUNT(*) FILTER (WHERE a.status IN ('PRESENT', 'LATE'))::DECIMAL / NULLIF(COUNT(*), 0)) * 100, 2) >= 75 
      THEN 'satisfactory'
    WHEN ROUND((COUNT(*) FILTER (WHERE a.status IN ('PRESENT', 'LATE'))::DECIMAL / NULLIF(COUNT(*), 0)) * 100, 2) >= 60 
      THEN 'needs_improvement'
    ELSE 'at_risk'
  END as status,
  MIN(a.date) as first_class_date,
  MAX(a.date) as last_class_date
FROM attendance a
JOIN class_sections cs ON a.section_id = cs.id
JOIN subjects s ON cs.subject_id = s.id
GROUP BY a.student_id, cs.semester_id, cs.subject_id, s.subject_name, s.subject_code, cs.section_name
HAVING COUNT(*) > 0;

-- ============================================================================
-- 2. TEACHER ATTENDANCE SUMMARY VIEW
-- Pre-aggregated attendance data per teacher/subject/semester
-- Used by: Teacher dashboard, performance reports
-- ============================================================================
CREATE OR REPLACE VIEW teacher_attendance_summary AS
SELECT 
  cs.teacher_id,
  cs.semester_id,
  cs.subject_id,
  s.subject_name,
  s.subject_code,
  cs.section_name,
  COUNT(DISTINCT a.date) as total_classes_held,
  COUNT(*) as total_attendance_records,
  COUNT(*) FILTER (WHERE a.status = 'PRESENT') as students_present_count,
  COUNT(*) FILTER (WHERE a.status = 'ABSENT') as students_absent_count,
  COUNT(*) FILTER (WHERE a.status = 'LATE') as students_late_count,
  COUNT(*) FILTER (WHERE a.status = 'EXCUSED') as students_excused_count,
  ROUND(
    (COUNT(*) FILTER (WHERE a.status = 'PRESENT')::DECIMAL / NULLIF(COUNT(*), 0)) * 100, 
    2
  ) as overall_attendance_percentage,
  COUNT(DISTINCT a.student_id) as unique_students,
  MIN(a.date) as first_class_date,
  MAX(a.date) as last_class_date
FROM class_sections cs
LEFT JOIN attendance a ON cs.id = a.section_id
JOIN subjects s ON cs.subject_id = s.id
WHERE cs.status = 'ACTIVE'
GROUP BY cs.teacher_id, cs.semester_id, cs.subject_id, s.subject_name, s.subject_code, cs.section_name;

-- ============================================================================
-- 3. SEMESTER GRADE SUMMARY VIEW
-- Pre-computed grade aggregations per student/semester
-- Used by: Report cards, SGPA/CGPA calculations
-- ============================================================================
CREATE OR REPLACE VIEW semester_grade_summary AS
SELECT 
  ar.student_id,
  ar.semester_id,
  sem.semester_name,
  ay.year_name as academic_year,
  COUNT(DISTINCT ar.subject_id) as total_subjects,
  SUM(ar.marks_obtained) as total_marks_obtained,
  SUM(ar.max_marks) as total_max_marks,
  ROUND(
    (SUM(ar.marks_obtained)::DECIMAL / NULLIF(SUM(ar.max_marks), 0)) * 100,
    2
  ) as percentage,
  ROUND(
    AVG(ar.grade_points),
    2
  ) as sgpa,
  STRING_AGG(DISTINCT ar.grade, ', ' ORDER BY ar.grade) as grades_earned,
  COUNT(*) FILTER (WHERE ar.grade IN ('A+', 'A')) as excellent_grades_count,
  COUNT(*) FILTER (WHERE ar.grade IN ('B+', 'B')) as good_grades_count,
  COUNT(*) FILTER (WHERE ar.grade IN ('C', 'D', 'F')) as poor_grades_count
FROM academic_records ar
JOIN semesters sem ON ar.semester_id = sem.id
JOIN academic_years ay ON sem.academic_year_id = ay.id
GROUP BY ar.student_id, ar.semester_id, sem.semester_name, ay.year_name;

-- ============================================================================
-- 4. ASSIGNMENT SCORE SUMMARY VIEW
-- Pre-computed assignment scores per student/subject/semester
-- Used by: Progress tracking, performance metrics
-- ============================================================================
CREATE OR REPLACE VIEW assignment_score_summary AS
SELECT 
  s.student_id,
  a.subject_id,
  cs.semester_id,
  COUNT(*) as total_assignments,
  COUNT(*) FILTER (WHERE s.status = 'GRADED') as graded_assignments,
  COUNT(*) FILTER (WHERE s.status = 'SUBMITTED') as pending_grading,
  COUNT(*) FILTER (WHERE s.status = 'RETURNED') as returned_count,
  SUM(s.marks_obtained) as total_marks_obtained,
  SUM(a.max_marks) as total_max_marks,
  ROUND(
    (SUM(s.marks_obtained)::DECIMAL / NULLIF(SUM(a.max_marks), 0)) * 100,
    2
  ) as average_score_percentage,
  MIN(s.submitted_at) as first_submission_date,
  MAX(s.submitted_at) as last_submission_date
FROM submissions s
JOIN assignments a ON s.assignment_id = a.id
JOIN class_sections cs ON a.section_id = cs.id
WHERE s.status = 'GRADED' AND s.marks_obtained IS NOT NULL
GROUP BY s.student_id, a.subject_id, cs.semester_id;

-- ============================================================================
-- 5. EXAM SCORE SUMMARY VIEW
-- Pre-computed exam scores per student/subject/semester
-- Used by: Report cards, progress tracking
-- ============================================================================
CREATE OR REPLACE VIEW exam_score_summary AS
SELECT 
  er.student_id,
  e.subject_id,
  e.semester_id,
  COUNT(*) as total_exams,
  SUM(er.marks_obtained) as total_marks_obtained,
  SUM(e.total_marks) as total_max_marks,
  ROUND(
    (SUM(er.marks_obtained)::DECIMAL / NULLIF(SUM(e.total_marks), 0)) * 100,
    2
  ) as average_score_percentage,
  STRING_AGG(e.exam_type::TEXT, ', ' ORDER BY e.exam_date) as exam_types_taken,
  MIN(e.exam_date) as first_exam_date,
  MAX(e.exam_date) as last_exam_date
FROM exam_results er
JOIN examinations e ON er.exam_id = e.id
WHERE er.marks_obtained IS NOT NULL
GROUP BY er.student_id, e.subject_id, e.semester_id;

-- ============================================================================
-- PERFORMANCE INDEXES
-- Optimize frequent queries on base tables
-- ============================================================================

-- Attendance table indexes (if not already present)
CREATE INDEX IF NOT EXISTS idx_attendance_student_date ON attendance(student_id, date);
CREATE INDEX IF NOT EXISTS idx_attendance_section_date ON attendance(section_id, date);
CREATE INDEX IF NOT EXISTS idx_attendance_status ON attendance(status);
CREATE INDEX IF NOT EXISTS idx_attendance_student_section ON attendance(student_id, section_id);

-- Enrollment table indexes
CREATE INDEX IF NOT EXISTS idx_enrollments_student_semester ON enrollments(student_id, semester_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_subject_semester ON enrollments(subject_id, semester_id);

-- Academic records indexes
CREATE INDEX IF NOT EXISTS idx_academic_records_student_semester ON academic_records(student_id, semester_id);
CREATE INDEX IF NOT EXISTS idx_academic_records_grade_points ON academic_records(grade_points);

-- Submission/Assignment indexes
CREATE INDEX IF NOT EXISTS idx_submissions_student_status ON submissions(student_id, status);
CREATE INDEX IF NOT EXISTS idx_assignments_subject_section ON assignments(subject_id, section_id);

-- Exam results indexes
CREATE INDEX IF NOT EXISTS idx_exam_results_student ON exam_results(student_id);
CREATE INDEX IF NOT EXISTS idx_examinations_subject_semester ON examinations(subject_id, semester_id);

-- Class sections indexes
CREATE INDEX IF NOT EXISTS idx_class_sections_teacher_semester ON class_sections(teacher_id, semester_id) WHERE status = 'ACTIVE';

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON VIEW student_attendance_summary IS 'Pre-aggregated attendance data per student/subject/semester. Used for report cards and performance tracking. Updated on-the-fly when queried.';
COMMENT ON VIEW teacher_attendance_summary IS 'Pre-aggregated attendance data per teacher/subject/semester. Used for teacher dashboards and performance reports.';
COMMENT ON VIEW semester_grade_summary IS 'Pre-computed grade aggregations per student/semester including SGPA. Used for report card generation.';
COMMENT ON VIEW assignment_score_summary IS 'Pre-computed assignment scores per student/subject/semester. Used for progress tracking.';
COMMENT ON VIEW exam_score_summary IS 'Pre-computed exam scores per student/subject/semester. Used for progress tracking and report cards.';

