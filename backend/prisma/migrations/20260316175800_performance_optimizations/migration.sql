-- ============================================================================
-- COMPREHENSIVE PERFORMANCE OPTIMIZATIONS AND DATABASE VIEWS
-- This migration adds performance optimizations and database views for the Kram system
-- All columns use proper snake_case naming from the schema
-- ============================================================================

-- ============================================================================
-- STEP 1: CORE ACADEMIC YEAR INDEXES
-- ============================================================================

-- StudentAcademicYear indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_student_academic_years_student_id ON student_academic_years(student_id);
CREATE INDEX IF NOT EXISTS idx_student_academic_years_academic_year_id ON student_academic_years(academic_year_id);
CREATE INDEX IF NOT EXISTS idx_student_academic_years_class_level ON student_academic_years(class_level);
CREATE INDEX IF NOT EXISTS idx_student_academic_years_promotion_status ON student_academic_years(promotion_status);

-- Assessment indexes with academic year context
CREATE INDEX IF NOT EXISTS idx_exam_results_student_academic_year_id ON exam_results(student_academic_year_id);
CREATE INDEX IF NOT EXISTS idx_submissions_student_academic_year_id ON submissions(student_academic_year_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student_academic_year_id ON attendance(student_academic_year_id);
CREATE INDEX IF NOT EXISTS idx_academic_records_student_academic_year_id ON academic_records(student_academic_year_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_student_academic_year_id ON enrollments(student_academic_year_id);
CREATE INDEX IF NOT EXISTS idx_student_fees_student_academic_year_id ON student_fees(student_academic_year_id);

-- ============================================================================
-- STEP 2: USER AND INSTITUTION INDEXES
-- ============================================================================

-- Index on users table for role-based queries
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_account_status ON users(account_status);
CREATE INDEX IF NOT EXISTS idx_users_institution_id ON users(institution_id);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Index on institutions table
CREATE INDEX IF NOT EXISTS idx_institutions_status ON institutions(status);
CREATE INDEX IF NOT EXISTS idx_institutions_created_at ON institutions(created_at);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_users_role_institution ON users(role_id, institution_id);
CREATE INDEX IF NOT EXISTS idx_users_account_status_created ON users(account_status, created_at);

-- ============================================================================
-- STEP 3: ADDITIONAL PERFORMANCE INDEXES FOR NEW API ENDPOINTS
-- ============================================================================

-- Additional StudentAcademicYear indexes for new API endpoints
CREATE INDEX IF NOT EXISTS idx_student_academic_years_class_division_id ON student_academic_years(class_division_id);
CREATE INDEX IF NOT EXISTS idx_student_academic_years_class_teacher_id ON student_academic_years(class_teacher_id);
CREATE INDEX IF NOT EXISTS idx_student_academic_years_enrollment_date ON student_academic_years(enrollment_date);
CREATE INDEX IF NOT EXISTS idx_student_academic_years_completion_date ON student_academic_years(completion_date);

-- Composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_student_academic_years_academic_year_class ON student_academic_years(academic_year_id, class_level);
CREATE INDEX IF NOT EXISTS idx_student_academic_years_academic_year_division ON student_academic_years(academic_year_id, class_division_id);
CREATE INDEX IF NOT EXISTS idx_student_academic_years_student_promotion ON student_academic_years(student_id, promotion_status);
CREATE INDEX IF NOT EXISTS idx_student_academic_years_year_class_promotion ON student_academic_years(academic_year_id, class_level, promotion_status);

-- Attendance indexes for new attendance management features (using correct snake_case column names)
CREATE INDEX IF NOT EXISTS idx_attendance_date ON attendance(date);
CREATE INDEX IF NOT EXISTS idx_attendance_student_date ON attendance(student_id, date);
CREATE INDEX IF NOT EXISTS idx_attendance_section_date ON attendance(section_id, date);
CREATE INDEX IF NOT EXISTS idx_attendance_type_date ON attendance(attendance_type, date);
CREATE INDEX IF NOT EXISTS idx_attendance_status ON attendance(status);
CREATE INDEX IF NOT EXISTS idx_attendance_marked_by ON attendance(marked_by);

-- Academic Records indexes for enhanced academic record queries
CREATE INDEX IF NOT EXISTS idx_academic_records_semester_student ON academic_records(semester_id, student_id);
CREATE INDEX IF NOT EXISTS idx_academic_records_subject_semester ON academic_records(subject_id, semester_id);
CREATE INDEX IF NOT EXISTS idx_academic_records_status ON academic_records(status);
CREATE INDEX IF NOT EXISTS idx_academic_records_created_at ON academic_records(created_at);

-- Enrollment indexes for academic year context
CREATE INDEX IF NOT EXISTS idx_enrollments_semester_student ON enrollments(semester_id, student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_subject_semester ON enrollments(subject_id, semester_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_status ON enrollments(enrollment_status);

-- Exam Results indexes for performance queries
CREATE INDEX IF NOT EXISTS idx_exam_results_exam_student ON exam_results(exam_id, student_id);
CREATE INDEX IF NOT EXISTS idx_exam_results_marks_obtained ON exam_results(marks_obtained);
CREATE INDEX IF NOT EXISTS idx_exam_results_grade_points ON exam_results(grade_points);

-- Submissions indexes for assignment tracking
CREATE INDEX IF NOT EXISTS idx_submissions_assignment_student ON submissions(assignment_id, student_id);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON submissions(status);
CREATE INDEX IF NOT EXISTS idx_submissions_submitted_at ON submissions(submitted_at);

-- Indexes for search and filtering operations
CREATE INDEX IF NOT EXISTS idx_students_admission_number ON students(admission_number);
CREATE INDEX IF NOT EXISTS idx_users_first_name ON users(first_name);
CREATE INDEX IF NOT EXISTS idx_users_last_name ON users(last_name);
CREATE INDEX IF NOT EXISTS idx_users_full_name ON users(first_name, last_name);

-- Indexes for bulk operations
CREATE INDEX IF NOT EXISTS idx_student_academic_years_bulk_promotion ON student_academic_years(academic_year_id, promotion_status, class_level);

-- Indexes for date range queries (common in attendance and academic records)
CREATE INDEX IF NOT EXISTS idx_attendance_date_range ON attendance(date, student_id);
CREATE INDEX IF NOT EXISTS idx_academic_records_created_range ON academic_records(created_at, student_id);
CREATE INDEX IF NOT EXISTS idx_exam_results_exam_date ON exam_results(exam_id, student_id) WHERE marks_obtained IS NOT NULL;

-- ============================================================================
-- STEP 4: ENHANCED SUPER ADMIN SYSTEM STATS VIEW
-- ============================================================================

CREATE OR REPLACE VIEW super_admin_system_stats AS
SELECT 
  -- Institution counts (all institutions in the system)
  (SELECT COUNT(*) FROM institutions) as "totalInstitutions",
  (SELECT COUNT(*) FROM institutions WHERE status = 'INACTIVE') as "inactiveInstitutions",
  
  -- User counts by role (ONLY institutional users, excluding super_admins and users without institutions)
  (SELECT COUNT(*) FROM users u 
   JOIN roles r ON r.id = u.role_id 
   WHERE r.role_name = 'student' 
   AND u.institution_id IS NOT NULL) as "totalStudents",
   
  (SELECT COUNT(*) FROM users u 
   JOIN roles r ON r.id = u.role_id 
   WHERE r.role_name = 'teacher' 
   AND u.institution_id IS NOT NULL) as "totalTeachers",
   
  (SELECT COUNT(*) FROM users u 
   JOIN roles r ON r.id = u.role_id 
   WHERE r.role_name = 'admin' 
   AND u.institution_id IS NOT NULL) as "totalAdmins",
   
  (SELECT COUNT(*) FROM users u 
   JOIN roles r ON r.id = u.role_id 
   WHERE r.role_name IN ('staff', 'accountant', 'librarian') 
   AND u.institution_id IS NOT NULL) as "totalStaff",
   
  (SELECT COUNT(*) FROM users u 
   JOIN roles r ON r.id = u.role_id 
   WHERE r.role_name = 'parent' 
   AND u.institution_id IS NOT NULL) as "totalParents",
  
  -- User status counts (ONLY institutional users, excluding super_admins)
  (SELECT COUNT(*) FROM users u 
   JOIN roles r ON r.id = u.role_id 
   WHERE u.account_status = 'ACTIVE' 
   AND r.role_name != 'super_admin' 
   AND u.institution_id IS NOT NULL) as "totalActiveUsers",
   
  (SELECT COUNT(*) FROM users u 
   JOIN roles r ON r.id = u.role_id 
   WHERE u.account_status = 'PENDING_ACTIVATION' 
   AND r.role_name != 'super_admin' 
   AND u.institution_id IS NOT NULL) as "pendingUsers",
   
  (SELECT COUNT(*) FROM users u 
   JOIN roles r ON r.id = u.role_id 
   WHERE u.account_status = 'SUSPENDED' 
   AND r.role_name != 'super_admin' 
   AND u.institution_id IS NOT NULL) as "suspendedUsers",
   
  (SELECT COUNT(*) FROM users u 
   JOIN roles r ON r.id = u.role_id 
   WHERE u.account_status = 'LOCKED' 
   AND r.role_name != 'super_admin' 
   AND u.institution_id IS NOT NULL) as "lockedUsers",
  
  -- Recent activity (last 30 days) - institutional users only
  (SELECT COUNT(*) FROM users u 
   JOIN roles r ON r.id = u.role_id 
   WHERE u.created_at >= CURRENT_DATE - INTERVAL '30 days' 
   AND r.role_name != 'super_admin' 
   AND u.institution_id IS NOT NULL) as "newUsers30d",
   
  (SELECT COUNT(*) FROM institutions 
   WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as "newInstitutions30d",
  
  -- System health percentage (active institutional users / total institutional users * 100)
  CASE 
    WHEN (SELECT COUNT(*) FROM users u 
          JOIN roles r ON r.id = u.role_id 
          WHERE r.role_name != 'super_admin' 
          AND u.institution_id IS NOT NULL) > 0 THEN
      ROUND((
        (SELECT COUNT(*) FROM users u 
         JOIN roles r ON r.id = u.role_id 
         WHERE u.account_status = 'ACTIVE' 
         AND r.role_name != 'super_admin' 
         AND u.institution_id IS NOT NULL)::numeric / 
        (SELECT COUNT(*) FROM users u 
         JOIN roles r ON r.id = u.role_id 
         WHERE r.role_name != 'super_admin' 
         AND u.institution_id IS NOT NULL)::numeric
      ) * 100, 1)
    ELSE 100.0
  END as "userHealthPercentage";

-- ============================================================================
-- STEP 5: ENHANCED SUPER ADMIN INSTITUTION OVERVIEW VIEW
-- ============================================================================

CREATE OR REPLACE VIEW super_admin_institution_overview AS
SELECT 
  i.id,
  i.code,
  i.name,
  i.type,
  i.status,
  i.created_at as "createdAt",
  
  -- Admin information
  admin_info.admin_name as "adminName",
  admin_info.admin_email as "adminEmail",
  admin_info.admin_status as "adminStatus",
  
  -- User counts by institution
  COALESCE(user_counts.total_users, 0) as "totalUsers",
  COALESCE(user_counts.active_users, 0) as "activeUsers",
  COALESCE(user_counts.students, 0) as students,
  COALESCE(user_counts.teachers, 0) as teachers,
  COALESCE(user_counts.staff, 0) as staff,
  COALESCE(user_counts.parents, 0) as parents,
  
  -- Health percentage calculation
  CASE 
    WHEN COALESCE(user_counts.total_users, 0) = 0 THEN 100.0
    ELSE ROUND(
      (COALESCE(user_counts.active_users, 0)::DECIMAL / 
       COALESCE(user_counts.total_users, 1)::DECIMAL) * 100, 1
    )
  END as "healthPercentage"

FROM institutions i
LEFT JOIN (
  SELECT 
    u.institution_id,
    COUNT(*) as total_users,
    COUNT(CASE WHEN u.account_status = 'ACTIVE' THEN 1 END) as active_users,
    COUNT(CASE WHEN r.role_name = 'student' THEN 1 END) as students,
    COUNT(CASE WHEN r.role_name = 'teacher' THEN 1 END) as teachers,
    COUNT(CASE WHEN r.role_name = 'staff' THEN 1 END) as staff,
    COUNT(CASE WHEN r.role_name = 'parent' THEN 1 END) as parents
  FROM users u
  JOIN roles r ON u.role_id = r.id
  WHERE u.institution_id IS NOT NULL
  GROUP BY u.institution_id
) user_counts ON i.id = user_counts.institution_id
LEFT JOIN (
  SELECT 
    u.institution_id,
    CONCAT(u.first_name, ' ', u.last_name) as admin_name,
    u.email as admin_email,
    u.account_status as admin_status
  FROM users u
  JOIN roles r ON u.role_id = r.id
  WHERE r.role_name = 'admin'
  AND u.institution_id IS NOT NULL
) admin_info ON i.id = admin_info.institution_id
WHERE i.id IS NOT NULL
ORDER BY i.created_at DESC;

-- ============================================================================
-- STEP 6: ENHANCED SUPER ADMIN USER GROWTH VIEW
-- ============================================================================

CREATE OR REPLACE VIEW super_admin_user_growth AS
SELECT 
  DATE_TRUNC('month', created_at) as month,
  COUNT(*) as "newUsers",
  COUNT(CASE WHEN account_status = 'ACTIVE' THEN 1 END) as "activeNewUsers",
  SUM(COUNT(*)) OVER (ORDER BY DATE_TRUNC('month', created_at)) as "cumulativeUsers"
FROM users 
WHERE created_at >= NOW() - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month DESC;

-- ============================================================================
-- STEP 7: ENHANCED SUPER ADMIN RECENT ACTIVITY VIEW
-- ============================================================================

CREATE OR REPLACE VIEW super_admin_recent_activity AS
SELECT 
  'user_registration' as "activityType",
  CONCAT(u.first_name, ' ', u.last_name) as description,
  u.created_at as timestamp,
  u.institution_id as "institutionId"
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.created_at >= NOW() - INTERVAL '7 days'
AND r.role_name != 'super_admin'
AND u.institution_id IS NOT NULL
UNION ALL
SELECT 
  'institution_creation' as "activityType",
  i.name as description,
  i.created_at as timestamp,
  i.id as "institutionId"
FROM institutions i
WHERE i.created_at >= NOW() - INTERVAL '7 days'
ORDER BY timestamp DESC;

-- ============================================================================
-- STEP 8: UPDATE TABLE STATISTICS FOR BETTER QUERY PLANNING
-- ============================================================================

-- Update table statistics for better query planning
ANALYZE student_academic_years;
ANALYZE attendance;
ANALYZE academic_records;
ANALYZE students;
ANALYZE users;
ANALYZE enrollments;
ANALYZE exam_results;
ANALYZE submissions;
ANALYZE communications;