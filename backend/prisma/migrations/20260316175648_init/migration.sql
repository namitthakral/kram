-- CreateEnum
CREATE TYPE "SequenceResetPolicy" AS ENUM ('YEARLY', 'NEVER', 'MONTHLY');

-- CreateEnum
CREATE TYPE "UserAccountStatus" AS ENUM ('PENDING_ACTIVATION', 'ACTIVE', 'SUSPENDED', 'LOCKED', 'INACTIVE');

-- CreateEnum
CREATE TYPE "InstitutionType" AS ENUM ('SCHOOL', 'COLLEGE', 'UNIVERSITY', 'INSTITUTE');

-- CreateEnum
CREATE TYPE "InstitutionStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- CreateEnum
CREATE TYPE "DegreeType" AS ENUM ('CERTIFICATE', 'DIPLOMA', 'BACHELORS', 'MASTERS', 'PHD', 'OTHER');

-- CreateEnum
CREATE TYPE "CourseStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- CreateEnum
CREATE TYPE "SubjectType" AS ENUM ('CORE', 'ELECTIVE', 'MINOR', 'MAJOR', 'OPTIONAL', 'EXTRA_CURRICULAR', 'LANGUAGE', 'SCIENCE', 'MATHEMATICS', 'SOCIAL_STUDIES', 'ARTS', 'PHYSICAL_EDUCATION');

-- CreateEnum
CREATE TYPE "SubjectStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- CreateEnum
CREATE TYPE "AcademicYearStatus" AS ENUM ('CURRENT', 'PAST', 'FUTURE');

-- CreateEnum
CREATE TYPE "SemesterStatus" AS ENUM ('UPCOMING', 'ACTIVE', 'COMPLETED');

-- CreateEnum
CREATE TYPE "StudentType" AS ENUM ('REGULAR', 'TRANSFER', 'EXCHANGE');

-- CreateEnum
CREATE TYPE "PromotionStatus" AS ENUM ('IN_PROGRESS', 'PROMOTED', 'REPEATED', 'FAILED', 'TRANSFERRED', 'COMPLETED');

-- CreateEnum
CREATE TYPE "ResidentialStatus" AS ENUM ('DAY_SCHOLAR', 'HOSTELER');

-- CreateEnum
CREATE TYPE "StudentEnrollmentStatus" AS ENUM ('PENDING_ENROLLMENT', 'ACTIVE', 'ALUMNI', 'DROPOUT', 'TRANSFERRED', 'SUSPENDED');

-- CreateEnum
CREATE TYPE "EmploymentType" AS ENUM ('FULL_TIME', 'PART_TIME', 'CONTRACT', 'VISITING');

-- CreateEnum
CREATE TYPE "TeacherEmploymentStatus" AS ENUM ('ACTIVE', 'ON_LEAVE', 'RESIGNED', 'RETIRED');

-- CreateEnum
CREATE TYPE "ParentRelation" AS ENUM ('FATHER', 'MOTHER', 'GUARDIAN', 'OTHER');

-- CreateEnum
CREATE TYPE "StaffType" AS ENUM ('ADMINISTRATIVE', 'TECHNICAL', 'SUPPORT', 'SECURITY', 'MAINTENANCE', 'TRANSPORT', 'CLEANING', 'CAFETERIA', 'MEDICAL', 'OTHER');

-- CreateEnum
CREATE TYPE "StaffEmploymentStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'ON_LEAVE', 'RESIGNED', 'TERMINATED', 'RETIRED');

-- CreateEnum
CREATE TYPE "AcademicRecordStatus" AS ENUM ('PASSED', 'FAILED', 'INCOMPLETE', 'WITHDRAWN');

-- CreateEnum
CREATE TYPE "AttendanceStatus" AS ENUM ('PRESENT', 'ABSENT', 'LATE', 'EXCUSED');

-- CreateEnum
CREATE TYPE "AttendanceType" AS ENUM ('DAILY', 'SUBJECT_WISE', 'EVENT', 'EXAM');

-- CreateEnum
CREATE TYPE "ClassSectionStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ClassDivisionStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- CreateEnum
CREATE TYPE "EnrollmentStatus" AS ENUM ('ENROLLED', 'DROPPED', 'COMPLETED', 'FAILED');

-- CreateEnum
CREATE TYPE "ExamType" AS ENUM ('QUIZ', 'MIDTERM', 'FINAL', 'ASSIGNMENT', 'PROJECT', 'PRACTICAL');

-- CreateEnum
CREATE TYPE "ExamStatus" AS ENUM ('SCHEDULED', 'ONGOING', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "AssignmentStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'CLOSED');

-- CreateEnum
CREATE TYPE "SubmissionStatus" AS ENUM ('SUBMITTED', 'GRADED', 'RETURNED', 'RESUBMITTED');

-- CreateEnum
CREATE TYPE "FeeType" AS ENUM ('TUITION', 'ADMISSION', 'EXAMINATION', 'LIBRARY', 'LABORATORY', 'TRANSPORT', 'HOSTEL', 'SPORTS', 'DEVELOPMENT', 'MISCELLANEOUS');

-- CreateEnum
CREATE TYPE "RecurringFrequency" AS ENUM ('MONTHLY', 'QUARTERLY', 'SEMESTER', 'ANNUAL');

-- CreateEnum
CREATE TYPE "FeeStructureStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "FeeStatus" AS ENUM ('PENDING', 'PARTIAL', 'PAID', 'OVERDUE', 'WAIVED');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('CASH', 'CHEQUE', 'BANK_TRANSFER', 'ONLINE', 'UPI', 'CARD');

-- CreateEnum
CREATE TYPE "PaymentMode" AS ENUM ('OFFLINE', 'ONLINE');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "CommunicationType" AS ENUM ('GENERAL', 'ACADEMIC', 'EXAMINATION', 'ADMISSION', 'EVENT', 'HOLIDAY', 'EMERGENCY', 'MAINTENANCE', 'ACHIEVEMENT', 'ALERT');

-- CreateEnum
CREATE TYPE "CommunicationPriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');

-- CreateEnum
CREATE TYPE "MessageType" AS ENUM ('PERSONAL', 'GROUP', 'BROADCAST', 'SYSTEM');

-- CreateEnum
CREATE TYPE "MessagePriority" AS ENUM ('LOW', 'NORMAL', 'HIGH', 'URGENT');

-- CreateEnum
CREATE TYPE "GroupType" AS ENUM ('CLASS', 'DEPARTMENT', 'PROGRAM', 'CUSTOM', 'PARENT_TEACHER', 'STUDENT_GROUP');

-- CreateEnum
CREATE TYPE "GroupRole" AS ENUM ('ADMIN', 'MODERATOR', 'MEMBER');

-- CreateEnum
CREATE TYPE "BookCondition" AS ENUM ('EXCELLENT', 'GOOD', 'FAIR', 'POOR', 'DAMAGED');

-- CreateEnum
CREATE TYPE "BookStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'LOST', 'DAMAGED', 'WITHDRAWN');

-- CreateEnum
CREATE TYPE "IssueStatus" AS ENUM ('ISSUED', 'RETURNED', 'OVERDUE', 'LOST', 'DAMAGED');

-- CreateEnum
CREATE TYPE "ReservationStatus" AS ENUM ('ACTIVE', 'FULFILLED', 'EXPIRED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "TransactionType" AS ENUM ('ISSUE', 'RETURN', 'RENEWAL', 'FINE_PAYMENT', 'BOOK_LOST', 'BOOK_DAMAGED', 'RESERVATION');

-- CreateEnum
CREATE TYPE "LeaveType" AS ENUM ('CASUAL', 'SICK', 'ANNUAL', 'MATERNITY', 'PATERNITY', 'EMERGENCY', 'UNPAID');

-- CreateEnum
CREATE TYPE "LeaveStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "AssignmentType" AS ENUM ('MAINTENANCE', 'CLEANING', 'SECURITY', 'TRANSPORT', 'EVENT_SUPPORT', 'ADMINISTRATIVE', 'TECHNICAL_SUPPORT', 'OTHER');

-- CreateEnum
CREATE TYPE "StaffAssignmentStatus" AS ENUM ('ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'OVERDUE');

-- CreateEnum
CREATE TYPE "TaskPriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');

-- CreateEnum
CREATE TYPE "GatePassType" AS ENUM ('TEMPORARY', 'HALF_DAY', 'FULL_DAY', 'MULTIPLE_DAYS', 'EMERGENCY', 'MEDICAL', 'FAMILY_FUNCTION', 'OFFICIAL_WORK');

-- CreateEnum
CREATE TYPE "GatePassStatus" AS ENUM ('PENDING', 'PARENT_APPROVED', 'TEACHER_APPROVED', 'APPROVED', 'REJECTED', 'EXPIRED', 'USED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "VisitorPassStatus" AS ENUM ('SCHEDULED', 'APPROVED', 'CHECKED_IN', 'CHECKED_OUT', 'REJECTED', 'EXPIRED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "DayOfWeek" AS ENUM ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY');

-- CreateEnum
CREATE TYPE "SlotType" AS ENUM ('LECTURE', 'PRACTICAL', 'TUTORIAL', 'BREAK', 'LUNCH', 'ASSEMBLY', 'SPORTS', 'LIBRARY', 'STUDY_HALL');

-- CreateEnum
CREATE TYPE "RoomType" AS ENUM ('CLASSROOM', 'LABORATORY', 'LIBRARY', 'AUDITORIUM', 'SPORTS_ROOM', 'COMPUTER_LAB', 'CONFERENCE_ROOM', 'STAFF_ROOM', 'PRINCIPAL_OFFICE', 'MEDICAL_ROOM');

-- CreateEnum
CREATE TYPE "SubstitutionStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ProgressStatus" AS ENUM ('EXCELLENT', 'GOOD', 'ON_TRACK', 'NEEDS_IMPROVEMENT', 'AT_RISK', 'FAILING');

-- CreateEnum
CREATE TYPE "AlertSeverity" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');

-- CreateEnum
CREATE TYPE "ApplicationStatus" AS ENUM ('PENDING', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'CANCELLED', 'COMPLETED');

-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "uuid" UUID,
    "kram_id" VARCHAR(20),
    "first_name" VARCHAR(50) NOT NULL,
    "last_name" VARCHAR(50) NOT NULL,
    "email" VARCHAR(100),
    "phone" VARCHAR(15),
    "password_hash" VARCHAR(255) NOT NULL,
    "role_id" INTEGER NOT NULL,
    "institution_id" INTEGER,
    "last_login" TIMESTAMP(3),
    "login_attempts" INTEGER NOT NULL DEFAULT 0,
    "account_status" "UserAccountStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "roles" (
    "id" SERIAL NOT NULL,
    "role_name" VARCHAR(50) NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "institutions" (
    "id" SERIAL NOT NULL,
    "code" VARCHAR(4) NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "type" "InstitutionType" NOT NULL,
    "address" TEXT,
    "city" VARCHAR(100),
    "state" VARCHAR(100),
    "country" VARCHAR(100),
    "postal_code" VARCHAR(20),
    "phone" VARCHAR(15),
    "email" VARCHAR(100),
    "website" VARCHAR(200),
    "established_year" INTEGER,
    "accreditation" VARCHAR(100),
    "status" "InstitutionStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "institutions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "institution_grading_configs" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "attendance_weight" DECIMAL(5,2) NOT NULL DEFAULT 10,
    "assignment_weight" DECIMAL(5,2) NOT NULL DEFAULT 30,
    "exam_weight" DECIMAL(5,2) NOT NULL DEFAULT 50,
    "participation_weight" DECIMAL(5,2) NOT NULL DEFAULT 10,
    "grade_a_plus_threshold" DECIMAL(5,2) NOT NULL DEFAULT 93,
    "grade_a_threshold" DECIMAL(5,2) NOT NULL DEFAULT 85,
    "grade_b_plus_threshold" DECIMAL(5,2) NOT NULL DEFAULT 77,
    "grade_b_threshold" DECIMAL(5,2) NOT NULL DEFAULT 70,
    "grade_c_threshold" DECIMAL(5,2) NOT NULL DEFAULT 60,
    "grade_a_plus_points" DECIMAL(3,1) NOT NULL DEFAULT 4.0,
    "grade_a_points" DECIMAL(3,1) NOT NULL DEFAULT 3.7,
    "grade_b_plus_points" DECIMAL(3,1) NOT NULL DEFAULT 3.3,
    "grade_b_points" DECIMAL(3,1) NOT NULL DEFAULT 3.0,
    "grade_c_points" DECIMAL(3,1) NOT NULL DEFAULT 2.0,
    "grade_d_points" DECIMAL(3,1) NOT NULL DEFAULT 1.0,
    "at_risk_attendance" DECIMAL(5,2) NOT NULL DEFAULT 75,
    "at_risk_assignment" DECIMAL(5,2) NOT NULL DEFAULT 60,
    "at_risk_exam" DECIMAL(5,2) NOT NULL DEFAULT 60,
    "at_risk_grade_points" DECIMAL(3,1) NOT NULL DEFAULT 2.0,
    "needs_improvement_attendance" DECIMAL(5,2) NOT NULL DEFAULT 85,
    "needs_improvement_assignment" DECIMAL(5,2) NOT NULL DEFAULT 70,
    "needs_improvement_exam" DECIMAL(5,2) NOT NULL DEFAULT 70,
    "needs_improvement_grade_points" DECIMAL(3,1) NOT NULL DEFAULT 3.0,
    "excellent_attendance" DECIMAL(5,2) NOT NULL DEFAULT 95,
    "excellent_assignment" DECIMAL(5,2) NOT NULL DEFAULT 90,
    "excellent_exam" DECIMAL(5,2) NOT NULL DEFAULT 90,
    "excellent_grade_points" DECIMAL(3,1) NOT NULL DEFAULT 3.7,
    "good_attendance" DECIMAL(5,2) NOT NULL DEFAULT 90,
    "good_assignment" DECIMAL(5,2) NOT NULL DEFAULT 80,
    "good_exam" DECIMAL(5,2) NOT NULL DEFAULT 80,
    "good_grade_points" DECIMAL(3,1) NOT NULL DEFAULT 3.3,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "institution_grading_configs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "institution_id_configs" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "admission_number_format" VARCHAR(100) NOT NULL DEFAULT '{YEAR}/{COURSE}/{SEQ:5}',
    "roll_number_format" VARCHAR(100) NOT NULL DEFAULT '{COURSE}-{SECTION}-{SEQ:3}',
    "teacher_employee_id_format" VARCHAR(100) NOT NULL DEFAULT 'EMP-{YEAR}-{SEQ:5}',
    "staff_employee_id_format" VARCHAR(100) NOT NULL DEFAULT 'STF-{YEAR}-{SEQ:5}',
    "sequence_reset_policy" "SequenceResetPolicy" NOT NULL DEFAULT 'YEARLY',
    "admission_seq_year" INTEGER NOT NULL DEFAULT 0,
    "admission_seq_counter" INTEGER NOT NULL DEFAULT 0,
    "roll_seq_year" INTEGER NOT NULL DEFAULT 0,
    "roll_seq_counter" INTEGER NOT NULL DEFAULT 0,
    "teacher_seq_year" INTEGER NOT NULL DEFAULT 0,
    "teacher_seq_counter" INTEGER NOT NULL DEFAULT 0,
    "staff_seq_year" INTEGER NOT NULL DEFAULT 0,
    "staff_seq_counter" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "institution_id_configs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "academic_years" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "year_name" VARCHAR(20) NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE NOT NULL,
    "status" "AcademicYearStatus" NOT NULL DEFAULT 'CURRENT',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "academic_years_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "semesters" (
    "id" SERIAL NOT NULL,
    "academic_year_id" INTEGER NOT NULL,
    "semester_name" VARCHAR(50) NOT NULL,
    "semester_number" INTEGER NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE NOT NULL,
    "registration_start" DATE,
    "registration_end" DATE,
    "status" "SemesterStatus" NOT NULL DEFAULT 'UPCOMING',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "semesters_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "courses" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "code" VARCHAR(20),
    "degree_type" "DegreeType" NOT NULL,
    "duration_years" DECIMAL(3,1),
    "total_credits" INTEGER,
    "description" TEXT,
    "eligibility_criteria" TEXT,
    "status" "CourseStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "courses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "subjects" (
    "id" SERIAL NOT NULL,
    "course_id" INTEGER,
    "subject_name" VARCHAR(200) NOT NULL,
    "subject_code" VARCHAR(20),
    "credits" INTEGER,
    "theory_hours" INTEGER NOT NULL DEFAULT 0,
    "practical_hours" INTEGER NOT NULL DEFAULT 0,
    "tutorial_hours" INTEGER NOT NULL DEFAULT 0,
    "subject_type" "SubjectType" NOT NULL DEFAULT 'CORE',
    "prerequisites" TEXT,
    "description" TEXT,
    "syllabus" TEXT,
    "status" "SubjectStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "subjects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "students" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "course_id" INTEGER,
    "class_division_id" INTEGER,
    "roll_number" VARCHAR(50),
    "current_semester" INTEGER,
    "current_year" INTEGER,
    "section" VARCHAR(10),
    "admission_number" VARCHAR(50) NOT NULL,
    "admission_date" DATE,
    "graduation_date" DATE,
    "student_type" "StudentType" NOT NULL DEFAULT 'REGULAR',
    "residential_status" "ResidentialStatus" NOT NULL DEFAULT 'DAY_SCHOLAR',
    "transport_required" BOOLEAN NOT NULL DEFAULT false,
    "class10_board_roll_no" VARCHAR(50),
    "class12_board_roll_no" VARCHAR(50),
    "college_roll_number" VARCHAR(50),
    "emergency_contact_name" VARCHAR(100),
    "emergency_contact_phone" VARCHAR(15),
    "emergency_contact_email" VARCHAR(100),
    "blood_group" VARCHAR(5),
    "medical_conditions" TEXT,
    "enrollment_status" "StudentEnrollmentStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "students_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "student_academic_years" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "academic_year_id" INTEGER NOT NULL,
    "class_level" INTEGER NOT NULL,
    "section" VARCHAR(10),
    "roll_number" VARCHAR(50) NOT NULL,
    "class_division_id" INTEGER,
    "class_teacher_id" INTEGER,
    "current_roll_number" VARCHAR(50),
    "board_roll_number" VARCHAR(50),
    "promotion_status" "PromotionStatus" NOT NULL DEFAULT 'IN_PROGRESS',
    "final_grade" VARCHAR(5),
    "final_percentage" DECIMAL(5,2),
    "attendance_percentage" DECIMAL(5,2),
    "total_working_days" INTEGER DEFAULT 0,
    "total_days_present" INTEGER DEFAULT 0,
    "enrollment_date" DATE NOT NULL,
    "completion_date" DATE,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "student_academic_years_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "teachers" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "employee_id" VARCHAR(50) NOT NULL,
    "designation" VARCHAR(100),
    "specialization" VARCHAR(200),
    "qualification" VARCHAR(200),
    "experience_years" INTEGER NOT NULL DEFAULT 0,
    "join_date" DATE,
    "salary" DECIMAL(12,2),
    "employment_type" "EmploymentType" NOT NULL DEFAULT 'FULL_TIME',
    "office_location" VARCHAR(100),
    "office_hours" VARCHAR(200),
    "research_interests" TEXT,
    "publications" TEXT,
    "employment_status" "TeacherEmploymentStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "teachers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "parents" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "student_id" INTEGER NOT NULL,
    "relation" "ParentRelation" NOT NULL,
    "occupation" VARCHAR(100),
    "annual_income" DECIMAL(12,2),
    "education_level" VARCHAR(50),
    "is_primary_contact" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "parents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "staff" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "employee_id" VARCHAR(50) NOT NULL,
    "staff_type" "StaffType" NOT NULL,
    "designation" VARCHAR(100) NOT NULL,
    "department" VARCHAR(100),
    "join_date" DATE,
    "salary" DECIMAL(12,2),
    "employment_type" "EmploymentType" NOT NULL DEFAULT 'FULL_TIME',
    "working_hours" VARCHAR(100),
    "reporting_manager" INTEGER,
    "skills" TEXT[],
    "qualifications" VARCHAR(300),
    "experience" VARCHAR(300),
    "emergency_contact" VARCHAR(15),
    "address" TEXT,
    "employment_status" "StaffEmploymentStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "staff_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "academic_records" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "semester_id" INTEGER NOT NULL,
    "subject_id" INTEGER NOT NULL,
    "student_academic_year_id" INTEGER,
    "marks_obtained" DECIMAL(6,2),
    "max_marks" DECIMAL(6,2),
    "grade" VARCHAR(5),
    "grade_points" DECIMAL(4,2),
    "credits_earned" INTEGER,
    "status" "AcademicRecordStatus" NOT NULL DEFAULT 'PASSED',
    "remarks" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "academic_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "section_id" INTEGER,
    "student_academic_year_id" INTEGER,
    "date" DATE NOT NULL,
    "status" "AttendanceStatus" NOT NULL,
    "attendance_type" "AttendanceType" NOT NULL DEFAULT 'DAILY',
    "remarks" TEXT,
    "marked_by" INTEGER NOT NULL,
    "marked_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attendance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "class_sections" (
    "id" SERIAL NOT NULL,
    "subject_id" INTEGER NOT NULL,
    "semester_id" INTEGER NOT NULL,
    "teacher_id" INTEGER NOT NULL,
    "section_name" VARCHAR(10) NOT NULL,
    "max_capacity" INTEGER NOT NULL DEFAULT 50,
    "current_enrollment" INTEGER NOT NULL DEFAULT 0,
    "room_number" VARCHAR(50),
    "schedule" JSONB,
    "status" "ClassSectionStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "class_sections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "class_divisions" (
    "id" SERIAL NOT NULL,
    "course_id" INTEGER NOT NULL,
    "section_name" VARCHAR(10) NOT NULL,
    "teacher_id" INTEGER,
    "max_capacity" INTEGER NOT NULL DEFAULT 50,
    "room_number" VARCHAR(50),
    "schedule" VARCHAR(200),
    "status" "ClassDivisionStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "class_divisions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "enrollments" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "subject_id" INTEGER NOT NULL,
    "semester_id" INTEGER NOT NULL,
    "student_academic_year_id" INTEGER,
    "enrollment_date" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "enrollment_status" "EnrollmentStatus" NOT NULL DEFAULT 'ENROLLED',
    "grade" VARCHAR(5),
    "credits_earned" INTEGER NOT NULL DEFAULT 0,
    "attendance_percentage" DECIMAL(5,2),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "enrollments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "examinations" (
    "id" SERIAL NOT NULL,
    "subject_id" INTEGER NOT NULL,
    "semester_id" INTEGER NOT NULL,
    "exam_name" VARCHAR(100) NOT NULL,
    "exam_type" "ExamType" NOT NULL,
    "exam_date" DATE,
    "start_time" TIME,
    "duration_minutes" INTEGER,
    "total_marks" INTEGER NOT NULL,
    "passing_marks" INTEGER,
    "weightage_percentage" DECIMAL(5,2),
    "instructions" TEXT,
    "venue" VARCHAR(100),
    "status" "ExamStatus" NOT NULL DEFAULT 'SCHEDULED',
    "created_by" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "examinations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "exam_results" (
    "id" SERIAL NOT NULL,
    "exam_id" INTEGER NOT NULL,
    "student_id" INTEGER NOT NULL,
    "student_academic_year_id" INTEGER,
    "marks_obtained" DECIMAL(6,2),
    "grade" VARCHAR(5),
    "grade_points" DECIMAL(4,2),
    "rank_in_class" INTEGER,
    "remarks" TEXT,
    "is_absent" BOOLEAN NOT NULL DEFAULT false,
    "evaluated_by" INTEGER,
    "evaluated_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "exam_results_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "assignments" (
    "id" SERIAL NOT NULL,
    "subject_id" INTEGER NOT NULL,
    "section_id" INTEGER,
    "teacher_id" INTEGER NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "description" TEXT,
    "instructions" TEXT,
    "max_marks" INTEGER NOT NULL DEFAULT 100,
    "weightage_percentage" DECIMAL(5,2),
    "assigned_date" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "due_date" TIMESTAMP(3) NOT NULL,
    "late_submission_allowed" BOOLEAN NOT NULL DEFAULT true,
    "late_penalty_percentage" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "attachment_url" VARCHAR(500),
    "status" "AssignmentStatus" NOT NULL DEFAULT 'DRAFT',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "submissions" (
    "id" SERIAL NOT NULL,
    "assignment_id" INTEGER NOT NULL,
    "student_id" INTEGER NOT NULL,
    "student_academic_year_id" INTEGER,
    "file_url" VARCHAR(500),
    "file_name" VARCHAR(255),
    "file_size" INTEGER,
    "submission_text" TEXT,
    "submitted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_late" BOOLEAN NOT NULL DEFAULT false,
    "marks_obtained" DECIMAL(6,2),
    "feedback" TEXT,
    "graded_by" INTEGER,
    "graded_at" TIMESTAMP(3),
    "status" "SubmissionStatus" NOT NULL DEFAULT 'SUBMITTED',
    "version" INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT "submissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fee_structures" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "course_id" INTEGER,
    "academic_year_id" INTEGER NOT NULL,
    "fee_type" "FeeType" NOT NULL,
    "fee_name" VARCHAR(100) NOT NULL,
    "amount" DECIMAL(10,2) NOT NULL,
    "due_date" DATE,
    "late_fee_amount" DECIMAL(10,2) DEFAULT 0,
    "late_fee_after_days" INTEGER DEFAULT 30,
    "is_recurring" BOOLEAN NOT NULL DEFAULT false,
    "recurring_frequency" "RecurringFrequency",
    "description" TEXT,
    "status" "FeeStructureStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "fee_structures_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "student_fees" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "fee_structure_id" INTEGER NOT NULL,
    "semester_id" INTEGER,
    "student_academic_year_id" INTEGER,
    "amount_due" DECIMAL(10,2) NOT NULL,
    "amount_paid" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "late_fee_applied" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "discount" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "due_date" DATE NOT NULL,
    "status" "FeeStatus" NOT NULL DEFAULT 'PENDING',
    "remarks" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "student_fees_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "student_fee_id" INTEGER,
    "amount" DECIMAL(10,2) NOT NULL,
    "payment_method" "PaymentMethod" NOT NULL,
    "payment_mode" "PaymentMode" NOT NULL,
    "transaction_id" VARCHAR(100),
    "reference_number" VARCHAR(100),
    "bank_name" VARCHAR(100),
    "cheque_number" VARCHAR(50),
    "cheque_date" DATE,
    "payment_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "remarks" TEXT,
    "receipt_number" VARCHAR(50),
    "processed_by" INTEGER,
    "processed_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "communications" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "content" TEXT NOT NULL,
    "communication_type" "CommunicationType" NOT NULL,
    "priority" "CommunicationPriority" NOT NULL DEFAULT 'MEDIUM',
    "target_audience" TEXT[],
    "department_ids" INTEGER[],
    "program_ids" INTEGER[],
    "class_ids" INTEGER[],
    "is_emergency" BOOLEAN NOT NULL DEFAULT false,
    "is_pinned" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "attachment_url" VARCHAR(500),
    "publish_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiry_date" TIMESTAMP(3),
    "created_by" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "communications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "communication_read_receipts" (
    "id" SERIAL NOT NULL,
    "communication_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    "read_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "communication_read_receipts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "messages" (
    "id" SERIAL NOT NULL,
    "sender_id" INTEGER NOT NULL,
    "receiver_id" INTEGER,
    "group_id" INTEGER,
    "subject" VARCHAR(200),
    "content" TEXT NOT NULL,
    "message_type" "MessageType" NOT NULL,
    "priority" "MessagePriority" NOT NULL DEFAULT 'NORMAL',
    "attachment_url" VARCHAR(500),
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "read_at" TIMESTAMP(3),
    "sent_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "message_groups" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "group_type" "GroupType" NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "created_by" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "message_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "group_members" (
    "id" SERIAL NOT NULL,
    "group_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    "role" "GroupRole" NOT NULL DEFAULT 'MEMBER',
    "joined_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "group_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "books" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "isbn" VARCHAR(20),
    "title" VARCHAR(300) NOT NULL,
    "author" VARCHAR(200) NOT NULL,
    "publisher" VARCHAR(200),
    "publication_year" INTEGER,
    "edition" VARCHAR(50),
    "language" VARCHAR(50),
    "category_id" INTEGER NOT NULL,
    "subject_area" VARCHAR(100),
    "total_copies" INTEGER NOT NULL DEFAULT 1,
    "available_copies" INTEGER NOT NULL DEFAULT 1,
    "location" VARCHAR(100),
    "price" DECIMAL(10,2),
    "condition" "BookCondition" NOT NULL DEFAULT 'GOOD',
    "description" TEXT,
    "cover_image_url" VARCHAR(500),
    "status" "BookStatus" NOT NULL DEFAULT 'ACTIVE',
    "added_by" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "books_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "book_categories" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "parent_category_id" INTEGER,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "book_categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "book_issues" (
    "id" SERIAL NOT NULL,
    "book_id" INTEGER NOT NULL,
    "student_id" INTEGER NOT NULL,
    "issued_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "due_date" TIMESTAMP(3) NOT NULL,
    "returned_date" TIMESTAMP(3),
    "renewal_count" INTEGER NOT NULL DEFAULT 0,
    "max_renewals" INTEGER NOT NULL DEFAULT 2,
    "fine_amount" DECIMAL(8,2) NOT NULL DEFAULT 0,
    "fine_paid" BOOLEAN NOT NULL DEFAULT false,
    "condition" "BookCondition" NOT NULL DEFAULT 'GOOD',
    "remarks" TEXT,
    "status" "IssueStatus" NOT NULL DEFAULT 'ISSUED',
    "issued_by" INTEGER NOT NULL,
    "returned_by" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "book_issues_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "book_reservations" (
    "id" SERIAL NOT NULL,
    "book_id" INTEGER NOT NULL,
    "student_id" INTEGER NOT NULL,
    "reserved_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiry_date" TIMESTAMP(3) NOT NULL,
    "status" "ReservationStatus" NOT NULL DEFAULT 'ACTIVE',
    "notified_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "book_reservations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "library_settings" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "max_books_per_student" INTEGER NOT NULL DEFAULT 3,
    "default_issue_days" INTEGER NOT NULL DEFAULT 14,
    "max_renewals" INTEGER NOT NULL DEFAULT 2,
    "fine_per_day" DECIMAL(5,2) NOT NULL DEFAULT 1.00,
    "reservation_days" INTEGER NOT NULL DEFAULT 3,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "library_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "staff_attendance" (
    "id" SERIAL NOT NULL,
    "staff_id" INTEGER NOT NULL,
    "date" DATE NOT NULL,
    "check_in_time" TIMESTAMP(3),
    "check_out_time" TIMESTAMP(3),
    "total_hours" DECIMAL(4,2),
    "status" "AttendanceStatus" NOT NULL,
    "remarks" TEXT,
    "location" VARCHAR(100),
    "marked_by" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "staff_attendance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "staff_leaves" (
    "id" SERIAL NOT NULL,
    "staff_id" INTEGER NOT NULL,
    "leave_type" "LeaveType" NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE NOT NULL,
    "total_days" INTEGER NOT NULL,
    "reason" TEXT NOT NULL,
    "status" "LeaveStatus" NOT NULL DEFAULT 'PENDING',
    "applied_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "approved_by" INTEGER,
    "approved_date" TIMESTAMP(3),
    "rejection_reason" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "staff_leaves_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "staff_assignments" (
    "id" SERIAL NOT NULL,
    "staff_id" INTEGER NOT NULL,
    "assignment_type" "AssignmentType" NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "description" TEXT,
    "location" VARCHAR(100),
    "start_date" DATE NOT NULL,
    "end_date" DATE,
    "priority" "TaskPriority" NOT NULL DEFAULT 'MEDIUM',
    "status" "StaffAssignmentStatus" NOT NULL DEFAULT 'ASSIGNED',
    "assigned_by" INTEGER NOT NULL,
    "completed_at" TIMESTAMP(3),
    "remarks" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "staff_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "gate_passes" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "student_id" INTEGER NOT NULL,
    "pass_type" "GatePassType" NOT NULL,
    "reason" VARCHAR(300) NOT NULL,
    "requested_by" INTEGER NOT NULL,
    "request_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "from_date" TIMESTAMP(3) NOT NULL,
    "to_date" TIMESTAMP(3),
    "from_time" TIME,
    "to_time" TIME,
    "destination" VARCHAR(200),
    "contact_person" VARCHAR(100),
    "contact_number" VARCHAR(15),
    "parent_approval" BOOLEAN NOT NULL DEFAULT false,
    "parent_approved_by" INTEGER,
    "parent_approved_at" TIMESTAMP(3),
    "teacher_approval" BOOLEAN NOT NULL DEFAULT false,
    "teacher_approved_by" INTEGER,
    "teacher_approved_at" TIMESTAMP(3),
    "admin_approval" BOOLEAN NOT NULL DEFAULT false,
    "admin_approved_by" INTEGER,
    "admin_approved_at" TIMESTAMP(3),
    "status" "GatePassStatus" NOT NULL DEFAULT 'PENDING',
    "actual_exit_time" TIMESTAMP(3),
    "actual_return_time" TIMESTAMP(3),
    "security_remarks" TEXT,
    "rejection_reason" TEXT,
    "is_emergency" BOOLEAN NOT NULL DEFAULT false,
    "attachment_url" VARCHAR(500),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "gate_passes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "gate_pass_settings" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "require_parent_approval" BOOLEAN NOT NULL DEFAULT true,
    "require_teacher_approval" BOOLEAN NOT NULL DEFAULT true,
    "require_admin_approval" BOOLEAN NOT NULL DEFAULT false,
    "max_hours_without_approval" INTEGER NOT NULL DEFAULT 2,
    "allow_weekend_passes" BOOLEAN NOT NULL DEFAULT false,
    "allow_holiday_passes" BOOLEAN NOT NULL DEFAULT false,
    "auto_approve_emergency" BOOLEAN NOT NULL DEFAULT false,
    "notification_enabled" BOOLEAN NOT NULL DEFAULT true,
    "sms_notification" BOOLEAN NOT NULL DEFAULT false,
    "email_notification" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "gate_pass_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "visitor_passes" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "visitor_name" VARCHAR(100) NOT NULL,
    "visitor_phone" VARCHAR(15) NOT NULL,
    "visitor_email" VARCHAR(100),
    "id_proof_type" VARCHAR(50) NOT NULL,
    "id_proof_number" VARCHAR(50) NOT NULL,
    "purpose_of_visit" VARCHAR(300) NOT NULL,
    "person_to_meet" VARCHAR(100) NOT NULL,
    "department" VARCHAR(100),
    "visit_date" DATE NOT NULL,
    "expected_in_time" TIMESTAMP(3) NOT NULL,
    "expected_out_time" TIMESTAMP(3),
    "actual_in_time" TIMESTAMP(3),
    "actual_out_time" TIMESTAMP(3),
    "status" "VisitorPassStatus" NOT NULL DEFAULT 'SCHEDULED',
    "approved_by" INTEGER,
    "approved_at" TIMESTAMP(3),
    "security_remarks" TEXT,
    "vehicle_number" VARCHAR(20),
    "accompanied_by" VARCHAR(200),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "visitor_passes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "timetables" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "academic_year_id" INTEGER NOT NULL,
    "semester_id" INTEGER NOT NULL,
    "class_id" INTEGER,
    "course_id" INTEGER,
    "section" VARCHAR(10),
    "day_of_week" "DayOfWeek" NOT NULL,
    "time_slot_id" INTEGER NOT NULL,
    "subject_id" INTEGER NOT NULL,
    "teacher_id" INTEGER NOT NULL,
    "room_id" INTEGER,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "timetables_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "time_slots" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "slot_name" VARCHAR(50) NOT NULL,
    "start_time" TIME NOT NULL,
    "end_time" TIME NOT NULL,
    "slot_type" "SlotType" NOT NULL,
    "duration" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "time_slots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rooms" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "room_number" VARCHAR(20) NOT NULL,
    "room_name" VARCHAR(100),
    "room_type" "RoomType" NOT NULL,
    "building" VARCHAR(100),
    "floor" VARCHAR(20),
    "capacity" INTEGER,
    "facilities" TEXT[],
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "rooms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "teacher_subjects" (
    "id" SERIAL NOT NULL,
    "teacher_id" INTEGER NOT NULL,
    "subject_id" INTEGER NOT NULL,
    "academic_year_id" INTEGER NOT NULL,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "teacher_subjects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "teacher_substitutions" (
    "id" SERIAL NOT NULL,
    "original_timetable_id" INTEGER NOT NULL,
    "substitute_teacher_id" INTEGER NOT NULL,
    "date" DATE NOT NULL,
    "reason" VARCHAR(200) NOT NULL,
    "status" "SubstitutionStatus" NOT NULL DEFAULT 'PENDING',
    "requested_by" INTEGER NOT NULL,
    "approved_by" INTEGER,
    "approved_at" TIMESTAMP(3),
    "remarks" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "teacher_substitutions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "class_teachers" (
    "id" SERIAL NOT NULL,
    "teacher_id" INTEGER NOT NULL,
    "course_id" INTEGER,
    "class_level" VARCHAR(20),
    "section" VARCHAR(10),
    "academic_year_id" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "assigned_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "class_teachers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "student_progress" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "subject_id" INTEGER NOT NULL,
    "semester_id" INTEGER NOT NULL,
    "academic_year_id" INTEGER NOT NULL,
    "overall_grade" VARCHAR(5),
    "grade_points" DECIMAL(4,2),
    "attendance_percentage" DECIMAL(5,2),
    "assignment_score" DECIMAL(6,2),
    "exam_score" DECIMAL(6,2),
    "participation_score" DECIMAL(6,2),
    "status" "ProgressStatus" NOT NULL DEFAULT 'ON_TRACK',
    "strengths" TEXT[],
    "areas_for_improvement" TEXT[],
    "teacher_comments" TEXT,
    "parent_comments" TEXT,
    "last_updated" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "student_progress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "career_guidance" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "teacher_id" INTEGER NOT NULL,
    "session_date" DATE NOT NULL,
    "session_type" VARCHAR(50) NOT NULL,
    "interests" TEXT[],
    "strengths" TEXT[],
    "career_goals" VARCHAR(500),
    "recommended_paths" TEXT[],
    "action_plan" VARCHAR(1000),
    "follow_up_date" DATE,
    "teacher_notes" TEXT,
    "student_feedback" TEXT,
    "status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "career_guidance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "applications" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "application_type" VARCHAR(50) NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "description" TEXT,
    "supporting_documents" TEXT[],
    "status" "ApplicationStatus" NOT NULL DEFAULT 'PENDING',
    "submitted_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reviewed_by" INTEGER,
    "reviewed_date" TIMESTAMP(3),
    "review_comments" TEXT,
    "approved_date" TIMESTAMP(3),
    "rejection_reason" TEXT,
    "priority" VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "applications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "system_alerts" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "alert_type" VARCHAR(50) NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "message" TEXT NOT NULL,
    "severity" "AlertSeverity" NOT NULL,
    "category" VARCHAR(50),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "is_resolved" BOOLEAN NOT NULL DEFAULT false,
    "resolved_by" INTEGER,
    "resolved_at" TIMESTAMP(3),
    "resolution_notes" TEXT,
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "system_alerts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "question_papers" (
    "id" SERIAL NOT NULL,
    "examination_id" INTEGER NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "instructions" TEXT,
    "total_marks" INTEGER NOT NULL,
    "total_questions" INTEGER NOT NULL DEFAULT 0,
    "created_by" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'DRAFT',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "question_papers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "question_paper_sections" (
    "id" SERIAL NOT NULL,
    "question_paper_id" INTEGER NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "sort_order" INTEGER NOT NULL,

    CONSTRAINT "question_paper_sections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "questions" (
    "id" SERIAL NOT NULL,
    "section_id" INTEGER NOT NULL,
    "text" TEXT NOT NULL,
    "marks" INTEGER NOT NULL,
    "question_type" TEXT NOT NULL,
    "sort_order" INTEGER NOT NULL,

    CONSTRAINT "questions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "question_options" (
    "id" SERIAL NOT NULL,
    "question_id" INTEGER NOT NULL,
    "text" TEXT NOT NULL,
    "is_correct" BOOLEAN NOT NULL DEFAULT false,
    "sort_order" INTEGER NOT NULL,

    CONSTRAINT "question_options_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "institution_examination_policies" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "min_advance_notice_days" INTEGER DEFAULT 3,
    "max_exam_duration_minutes" INTEGER DEFAULT 180,
    "max_exams_per_day" INTEGER DEFAULT 3,
    "min_gap_between_exams_days" INTEGER DEFAULT 0,
    "max_evaluation_days" INTEGER DEFAULT 7,
    "require_evaluator_approval" BOOLEAN DEFAULT false,
    "allow_self_evaluation" BOOLEAN DEFAULT true,
    "require_double_evaluation" BOOLEAN DEFAULT false,
    "result_publication_delay_days" INTEGER DEFAULT 0,
    "require_admin_approval_for_publication" BOOLEAN DEFAULT false,
    "allow_result_modification" BOOLEAN DEFAULT true,
    "result_modification_window_days" INTEGER DEFAULT 7,
    "default_passing_percentage" DECIMAL(5,2) DEFAULT 40,
    "enforce_grading_scale" BOOLEAN DEFAULT true,
    "allow_grade_inflation" BOOLEAN DEFAULT false,
    "min_attendance_for_exam" DECIMAL(5,2) DEFAULT 75,
    "allow_makeup_exams" BOOLEAN DEFAULT true,
    "makeup_exam_window_days" INTEGER DEFAULT 7,
    "makeup_exam_penalty_percentage" DECIMAL(5,2) DEFAULT 0,
    "require_proctoring" BOOLEAN DEFAULT false,
    "allow_open_book" BOOLEAN DEFAULT false,
    "require_plagiarism_check" BOOLEAN DEFAULT false,
    "exam_conduct_guidelines" TEXT,
    "notify_students_on_schedule" BOOLEAN DEFAULT true,
    "notify_parents_on_results" BOOLEAN DEFAULT true,
    "send_reminder_notifications" BOOLEAN DEFAULT true,
    "reminder_days_before_exam" INTEGER DEFAULT 1,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "institution_examination_policies_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_uuid_key" ON "users"("uuid");

-- CreateIndex
CREATE UNIQUE INDEX "users_kram_id_key" ON "users"("kram_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "roles_role_name_key" ON "roles"("role_name");

-- CreateIndex
CREATE UNIQUE INDEX "institutions_code_key" ON "institutions"("code");

-- CreateIndex
CREATE UNIQUE INDEX "institution_grading_configs_institution_id_key" ON "institution_grading_configs"("institution_id");

-- CreateIndex
CREATE UNIQUE INDEX "institution_id_configs_institution_id_key" ON "institution_id_configs"("institution_id");

-- CreateIndex
CREATE UNIQUE INDEX "courses_code_key" ON "courses"("code");

-- CreateIndex
CREATE UNIQUE INDEX "subjects_subject_code_key" ON "subjects"("subject_code");

-- CreateIndex
CREATE UNIQUE INDEX "students_user_id_key" ON "students"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "students_admission_number_key" ON "students"("admission_number");

-- CreateIndex
CREATE UNIQUE INDEX "student_academic_years_student_id_academic_year_id_key" ON "student_academic_years"("student_id", "academic_year_id");

-- CreateIndex
CREATE UNIQUE INDEX "student_academic_years_academic_year_id_class_division_id_r_key" ON "student_academic_years"("academic_year_id", "class_division_id", "roll_number");

-- CreateIndex
CREATE UNIQUE INDEX "teachers_user_id_key" ON "teachers"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "teachers_employee_id_key" ON "teachers"("employee_id");

-- CreateIndex
-- Add composite unique constraint to prevent duplicate parent-student relationships
-- while allowing same parent to be linked to multiple students
CREATE UNIQUE INDEX "parents_user_id_student_id_key" ON "parents"("user_id", "student_id");

-- CreateIndex
CREATE UNIQUE INDEX "institution_examination_policies_institution_id_key" ON "institution_examination_policies"("institution_id");

-- CreateIndex
CREATE UNIQUE INDEX "staff_user_id_key" ON "staff"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "staff_employee_id_key" ON "staff"("employee_id");

-- CreateIndex
CREATE UNIQUE INDEX "academic_records_student_id_semester_id_subject_id_key" ON "academic_records"("student_id", "semester_id", "subject_id");

-- CreateIndex
CREATE UNIQUE INDEX "attendance_student_id_section_id_date_key" ON "attendance"("student_id", "section_id", "date");

-- CreateIndex
CREATE UNIQUE INDEX "class_divisions_course_id_section_name_key" ON "class_divisions"("course_id", "section_name");

-- CreateIndex
CREATE UNIQUE INDEX "enrollments_student_id_subject_id_semester_id_key" ON "enrollments"("student_id", "subject_id", "semester_id");

-- CreateIndex
CREATE UNIQUE INDEX "exam_results_exam_id_student_id_key" ON "exam_results"("exam_id", "student_id");

-- CreateIndex
CREATE UNIQUE INDEX "submissions_assignment_id_student_id_version_key" ON "submissions"("assignment_id", "student_id", "version");

-- CreateIndex
CREATE UNIQUE INDEX "student_fees_student_id_fee_structure_id_semester_id_key" ON "student_fees"("student_id", "fee_structure_id", "semester_id");

-- CreateIndex
CREATE UNIQUE INDEX "payments_receipt_number_key" ON "payments"("receipt_number");

-- CreateIndex
CREATE UNIQUE INDEX "communication_read_receipts_communication_id_user_id_key" ON "communication_read_receipts"("communication_id", "user_id");

-- CreateIndex
CREATE UNIQUE INDEX "group_members_group_id_user_id_key" ON "group_members"("group_id", "user_id");

-- CreateIndex
CREATE UNIQUE INDEX "books_isbn_key" ON "books"("isbn");

-- CreateIndex
CREATE UNIQUE INDEX "book_reservations_book_id_student_id_key" ON "book_reservations"("book_id", "student_id");

-- CreateIndex
CREATE UNIQUE INDEX "library_settings_institution_id_key" ON "library_settings"("institution_id");

-- CreateIndex
CREATE UNIQUE INDEX "staff_attendance_staff_id_date_key" ON "staff_attendance"("staff_id", "date");

-- CreateIndex
CREATE UNIQUE INDEX "gate_pass_settings_institution_id_key" ON "gate_pass_settings"("institution_id");

-- CreateIndex
CREATE UNIQUE INDEX "timetables_institution_id_academic_year_id_semester_id_cour_key" ON "timetables"("institution_id", "academic_year_id", "semester_id", "course_id", "section", "day_of_week", "time_slot_id");

-- CreateIndex
CREATE UNIQUE INDEX "rooms_institution_id_room_number_key" ON "rooms"("institution_id", "room_number");

-- CreateIndex
CREATE UNIQUE INDEX "teacher_subjects_teacher_id_subject_id_academic_year_id_key" ON "teacher_subjects"("teacher_id", "subject_id", "academic_year_id");

-- CreateIndex
CREATE UNIQUE INDEX "class_teachers_course_id_class_level_section_academic_year__key" ON "class_teachers"("course_id", "class_level", "section", "academic_year_id");

-- CreateIndex
CREATE UNIQUE INDEX "student_progress_student_id_subject_id_semester_id_key" ON "student_progress"("student_id", "subject_id", "semester_id");

-- CreateIndex
CREATE UNIQUE INDEX "question_papers_examination_id_key" ON "question_papers"("examination_id");

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institution_grading_configs" ADD CONSTRAINT "institution_grading_configs_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institution_id_configs" ADD CONSTRAINT "institution_id_configs_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "academic_years" ADD CONSTRAINT "academic_years_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "semesters" ADD CONSTRAINT "semesters_academic_year_id_fkey" FOREIGN KEY ("academic_year_id") REFERENCES "academic_years"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "courses" ADD CONSTRAINT "courses_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "subjects" ADD CONSTRAINT "subjects_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "courses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "courses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_class_division_id_fkey" FOREIGN KEY ("class_division_id") REFERENCES "class_divisions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_academic_years" ADD CONSTRAINT "student_academic_years_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_academic_years" ADD CONSTRAINT "student_academic_years_academic_year_id_fkey" FOREIGN KEY ("academic_year_id") REFERENCES "academic_years"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_academic_years" ADD CONSTRAINT "student_academic_years_class_division_id_fkey" FOREIGN KEY ("class_division_id") REFERENCES "class_divisions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_academic_years" ADD CONSTRAINT "student_academic_years_class_teacher_id_fkey" FOREIGN KEY ("class_teacher_id") REFERENCES "teachers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teachers" ADD CONSTRAINT "teachers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teachers" ADD CONSTRAINT "teachers_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "parents" ADD CONSTRAINT "parents_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "parents" ADD CONSTRAINT "parents_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "staff" ADD CONSTRAINT "staff_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "staff" ADD CONSTRAINT "staff_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "academic_records" ADD CONSTRAINT "academic_records_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "academic_records" ADD CONSTRAINT "academic_records_semester_id_fkey" FOREIGN KEY ("semester_id") REFERENCES "semesters"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "academic_records" ADD CONSTRAINT "academic_records_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "subjects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "academic_records" ADD CONSTRAINT "academic_records_student_academic_year_id_fkey" FOREIGN KEY ("student_academic_year_id") REFERENCES "student_academic_years"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance" ADD CONSTRAINT "attendance_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance" ADD CONSTRAINT "attendance_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "class_sections"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance" ADD CONSTRAINT "attendance_student_academic_year_id_fkey" FOREIGN KEY ("student_academic_year_id") REFERENCES "student_academic_years"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance" ADD CONSTRAINT "attendance_marked_by_fkey" FOREIGN KEY ("marked_by") REFERENCES "teachers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_sections" ADD CONSTRAINT "class_sections_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "subjects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_sections" ADD CONSTRAINT "class_sections_semester_id_fkey" FOREIGN KEY ("semester_id") REFERENCES "semesters"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_sections" ADD CONSTRAINT "class_sections_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "teachers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_divisions" ADD CONSTRAINT "class_divisions_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "courses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_divisions" ADD CONSTRAINT "class_divisions_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "teachers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "enrollments" ADD CONSTRAINT "enrollments_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "enrollments" ADD CONSTRAINT "enrollments_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "subjects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "enrollments" ADD CONSTRAINT "enrollments_semester_id_fkey" FOREIGN KEY ("semester_id") REFERENCES "semesters"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "enrollments" ADD CONSTRAINT "enrollments_student_academic_year_id_fkey" FOREIGN KEY ("student_academic_year_id") REFERENCES "student_academic_years"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "examinations" ADD CONSTRAINT "examinations_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "subjects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "examinations" ADD CONSTRAINT "examinations_semester_id_fkey" FOREIGN KEY ("semester_id") REFERENCES "semesters"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "examinations" ADD CONSTRAINT "examinations_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "teachers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exam_results" ADD CONSTRAINT "exam_results_exam_id_fkey" FOREIGN KEY ("exam_id") REFERENCES "examinations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exam_results" ADD CONSTRAINT "exam_results_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exam_results" ADD CONSTRAINT "exam_results_student_academic_year_id_fkey" FOREIGN KEY ("student_academic_year_id") REFERENCES "student_academic_years"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exam_results" ADD CONSTRAINT "exam_results_evaluated_by_fkey" FOREIGN KEY ("evaluated_by") REFERENCES "teachers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "assignments" ADD CONSTRAINT "assignments_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "subjects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "assignments" ADD CONSTRAINT "assignments_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "class_sections"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "assignments" ADD CONSTRAINT "assignments_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "teachers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "submissions" ADD CONSTRAINT "submissions_assignment_id_fkey" FOREIGN KEY ("assignment_id") REFERENCES "assignments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "submissions" ADD CONSTRAINT "submissions_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "submissions" ADD CONSTRAINT "submissions_student_academic_year_id_fkey" FOREIGN KEY ("student_academic_year_id") REFERENCES "student_academic_years"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "submissions" ADD CONSTRAINT "submissions_graded_by_fkey" FOREIGN KEY ("graded_by") REFERENCES "teachers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fee_structures" ADD CONSTRAINT "fee_structures_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fee_structures" ADD CONSTRAINT "fee_structures_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "courses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fee_structures" ADD CONSTRAINT "fee_structures_academic_year_id_fkey" FOREIGN KEY ("academic_year_id") REFERENCES "academic_years"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_fees" ADD CONSTRAINT "student_fees_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_fees" ADD CONSTRAINT "student_fees_fee_structure_id_fkey" FOREIGN KEY ("fee_structure_id") REFERENCES "fee_structures"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_fees" ADD CONSTRAINT "student_fees_semester_id_fkey" FOREIGN KEY ("semester_id") REFERENCES "semesters"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_fees" ADD CONSTRAINT "student_fees_student_academic_year_id_fkey" FOREIGN KEY ("student_academic_year_id") REFERENCES "student_academic_years"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_student_fee_id_fkey" FOREIGN KEY ("student_fee_id") REFERENCES "student_fees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_processed_by_fkey" FOREIGN KEY ("processed_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "communications" ADD CONSTRAINT "communications_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "communications" ADD CONSTRAINT "communications_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "communication_read_receipts" ADD CONSTRAINT "communication_read_receipts_communication_id_fkey" FOREIGN KEY ("communication_id") REFERENCES "communications"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "communication_read_receipts" ADD CONSTRAINT "communication_read_receipts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_receiver_id_fkey" FOREIGN KEY ("receiver_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "message_groups"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "message_groups" ADD CONSTRAINT "message_groups_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "message_groups" ADD CONSTRAINT "message_groups_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "group_members" ADD CONSTRAINT "group_members_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "message_groups"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "group_members" ADD CONSTRAINT "group_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "books" ADD CONSTRAINT "books_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "books" ADD CONSTRAINT "books_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "book_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "books" ADD CONSTRAINT "books_added_by_fkey" FOREIGN KEY ("added_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "book_categories" ADD CONSTRAINT "book_categories_parent_category_id_fkey" FOREIGN KEY ("parent_category_id") REFERENCES "book_categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "book_issues" ADD CONSTRAINT "book_issues_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "books"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "book_issues" ADD CONSTRAINT "book_issues_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "book_issues" ADD CONSTRAINT "book_issues_issued_by_fkey" FOREIGN KEY ("issued_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "book_issues" ADD CONSTRAINT "book_issues_returned_by_fkey" FOREIGN KEY ("returned_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "book_reservations" ADD CONSTRAINT "book_reservations_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "books"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "book_reservations" ADD CONSTRAINT "book_reservations_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "library_settings" ADD CONSTRAINT "library_settings_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "staff_attendance" ADD CONSTRAINT "staff_attendance_staff_id_fkey" FOREIGN KEY ("staff_id") REFERENCES "staff"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "staff_attendance" ADD CONSTRAINT "staff_attendance_marked_by_fkey" FOREIGN KEY ("marked_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "staff_leaves" ADD CONSTRAINT "staff_leaves_staff_id_fkey" FOREIGN KEY ("staff_id") REFERENCES "staff"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "staff_leaves" ADD CONSTRAINT "staff_leaves_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "staff_assignments" ADD CONSTRAINT "staff_assignments_staff_id_fkey" FOREIGN KEY ("staff_id") REFERENCES "staff"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "staff_assignments" ADD CONSTRAINT "staff_assignments_assigned_by_fkey" FOREIGN KEY ("assigned_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gate_passes" ADD CONSTRAINT "gate_passes_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gate_passes" ADD CONSTRAINT "gate_passes_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gate_passes" ADD CONSTRAINT "gate_passes_requested_by_fkey" FOREIGN KEY ("requested_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gate_passes" ADD CONSTRAINT "gate_passes_parent_approved_by_fkey" FOREIGN KEY ("parent_approved_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gate_passes" ADD CONSTRAINT "gate_passes_teacher_approved_by_fkey" FOREIGN KEY ("teacher_approved_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gate_passes" ADD CONSTRAINT "gate_passes_admin_approved_by_fkey" FOREIGN KEY ("admin_approved_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gate_pass_settings" ADD CONSTRAINT "gate_pass_settings_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "visitor_passes" ADD CONSTRAINT "visitor_passes_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "visitor_passes" ADD CONSTRAINT "visitor_passes_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timetables" ADD CONSTRAINT "timetables_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timetables" ADD CONSTRAINT "timetables_academic_year_id_fkey" FOREIGN KEY ("academic_year_id") REFERENCES "academic_years"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timetables" ADD CONSTRAINT "timetables_semester_id_fkey" FOREIGN KEY ("semester_id") REFERENCES "semesters"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timetables" ADD CONSTRAINT "timetables_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "courses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timetables" ADD CONSTRAINT "timetables_time_slot_id_fkey" FOREIGN KEY ("time_slot_id") REFERENCES "time_slots"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timetables" ADD CONSTRAINT "timetables_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "subjects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timetables" ADD CONSTRAINT "timetables_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "teachers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timetables" ADD CONSTRAINT "timetables_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "rooms"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "time_slots" ADD CONSTRAINT "time_slots_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rooms" ADD CONSTRAINT "rooms_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teacher_subjects" ADD CONSTRAINT "teacher_subjects_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "teachers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teacher_subjects" ADD CONSTRAINT "teacher_subjects_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "subjects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teacher_subjects" ADD CONSTRAINT "teacher_subjects_academic_year_id_fkey" FOREIGN KEY ("academic_year_id") REFERENCES "academic_years"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teacher_substitutions" ADD CONSTRAINT "teacher_substitutions_original_timetable_id_fkey" FOREIGN KEY ("original_timetable_id") REFERENCES "timetables"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teacher_substitutions" ADD CONSTRAINT "teacher_substitutions_substitute_teacher_id_fkey" FOREIGN KEY ("substitute_teacher_id") REFERENCES "teachers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teacher_substitutions" ADD CONSTRAINT "teacher_substitutions_requested_by_fkey" FOREIGN KEY ("requested_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teacher_substitutions" ADD CONSTRAINT "teacher_substitutions_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_teachers" ADD CONSTRAINT "class_teachers_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "teachers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_teachers" ADD CONSTRAINT "class_teachers_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "courses"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_teachers" ADD CONSTRAINT "class_teachers_academic_year_id_fkey" FOREIGN KEY ("academic_year_id") REFERENCES "academic_years"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_progress" ADD CONSTRAINT "student_progress_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_progress" ADD CONSTRAINT "student_progress_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "subjects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "student_progress" ADD CONSTRAINT "student_progress_semester_id_fkey" FOREIGN KEY ("semester_id") REFERENCES "semesters"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "career_guidance" ADD CONSTRAINT "career_guidance_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "career_guidance" ADD CONSTRAINT "career_guidance_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "teachers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "applications" ADD CONSTRAINT "applications_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "applications" ADD CONSTRAINT "applications_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "system_alerts" ADD CONSTRAINT "system_alerts_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "system_alerts" ADD CONSTRAINT "system_alerts_resolved_by_fkey" FOREIGN KEY ("resolved_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_papers" ADD CONSTRAINT "question_papers_examination_id_fkey" FOREIGN KEY ("examination_id") REFERENCES "examinations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_papers" ADD CONSTRAINT "question_papers_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "teachers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_paper_sections" ADD CONSTRAINT "question_paper_sections_question_paper_id_fkey" FOREIGN KEY ("question_paper_id") REFERENCES "question_papers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "questions" ADD CONSTRAINT "questions_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "question_paper_sections"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_options" ADD CONSTRAINT "question_options_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "institution_examination_policies" ADD CONSTRAINT "institution_examination_policies_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ============================================================================
-- CLASS SECTIONS OPTIMIZATION: DATABASE VIEW AND INDEXES
-- ============================================================================

-- Create optimized view for class sections with all related data
CREATE OR REPLACE VIEW class_sections_detailed AS
SELECT 
    cs.id,
    cs.section_name,
    cs.max_capacity,
    cs.current_enrollment,
    cs.room_number,
    cs.schedule,
    cs.status,
    cs.created_at,
    cs.updated_at,
    
    -- Subject details
    s.id as subject_id,
    s.subject_name,
    s.subject_code,
    s.credits,
    s.subject_type,
    
    -- Course details
    c.id as course_id,
    c.name as course_name,
    c.code as course_code,
    c.degree_type,
    
    -- Semester details
    sem.id as semester_id,
    sem.semester_name,
    sem.semester_number,
    sem.start_date as semester_start_date,
    sem.end_date as semester_end_date,
    sem.status as semester_status,
    
    -- Academic Year details
    ay.id as academic_year_id,
    ay.year_name,
    ay.start_date as academic_year_start_date,
    ay.end_date as academic_year_end_date,
    ay.status as academic_year_status,
    
    -- Teacher details
    t.id as teacher_id,
    u.uuid as teacher_uuid,
    u.first_name as teacher_first_name,
    u.last_name as teacher_last_name,
    u.email as teacher_email,
    
    -- Institution details
    i.id as institution_id,
    i.name as institution_name,
    i.code as institution_code,
    i.type as institution_type
    
FROM class_sections cs
INNER JOIN subjects s ON cs.subject_id = s.id
LEFT JOIN courses c ON s.course_id = c.id
INNER JOIN semesters sem ON cs.semester_id = sem.id
INNER JOIN academic_years ay ON sem.academic_year_id = ay.id
LEFT JOIN teachers t ON cs.teacher_id = t.id
LEFT JOIN users u ON t.user_id = u.id
LEFT JOIN institutions i ON (
    c.institution_id = i.id OR 
    t.institution_id = i.id OR 
    u.institution_id = i.id
);

-- Create indexes for optimal performance
CREATE INDEX IF NOT EXISTS idx_class_sections_status_semester 
ON class_sections(status, semester_id);

CREATE INDEX IF NOT EXISTS idx_class_sections_teacher_institution 
ON class_sections(teacher_id) 
INCLUDE (status, semester_id);

CREATE INDEX IF NOT EXISTS idx_subjects_course_status 
ON subjects(course_id, status);

CREATE INDEX IF NOT EXISTS idx_semesters_academic_year_status 
ON semesters(academic_year_id, status);

CREATE INDEX IF NOT EXISTS idx_teachers_institution_active 
ON teachers(institution_id) 
WHERE employment_status = 'ACTIVE';

-- Composite index for common filter combinations
CREATE INDEX IF NOT EXISTS idx_class_sections_filters 
ON class_sections(status, semester_id, teacher_id) 
INCLUDE (section_name, max_capacity, current_enrollment);

-- ============================================================================
-- DATABASE FUNCTIONS: KRAM ID GENERATION
-- ============================================================================

-- Function to generate unique Kram IDs
-- Format: KRAM-{INSTITUTION_CODE}-{ROLE_PREFIX}{SEQUENCE}
-- Example: KRAM-PPS-ST001, KRAM-PPS-TC001, KRAM-PPS-AD001
CREATE OR REPLACE FUNCTION generate_kramid(institution_code TEXT, role_name TEXT)
RETURNS TEXT AS $$
DECLARE
    role_prefix TEXT;
    sequence_num INTEGER;
    kramid TEXT;
    max_attempts INTEGER := 100;
    attempt INTEGER := 0;
BEGIN
    -- Map role names to prefixes
    CASE role_name
        WHEN 'student' THEN role_prefix := 'ST';
        WHEN 'teacher' THEN role_prefix := 'TC';
        WHEN 'admin' THEN role_prefix := 'AD';
        WHEN 'parent' THEN role_prefix := 'PR';
        WHEN 'staff' THEN role_prefix := 'SF';
        WHEN 'librarian' THEN role_prefix := 'LB';
        WHEN 'accountant' THEN role_prefix := 'AC';
        WHEN 'super_admin' THEN role_prefix := 'SA';
        ELSE role_prefix := 'US'; -- Generic user
    END CASE;
    
    -- Find the next available sequence number
    LOOP
        attempt := attempt + 1;
        
        -- Get the highest existing sequence for this institution and role
        SELECT COALESCE(
            MAX(
                CAST(
                    SUBSTRING(
                        kram_id FROM 
                        LENGTH('KRAM-' || institution_code || '-' || role_prefix) + 1
                    ) AS INTEGER
                )
            ), 0
        ) + attempt
        INTO sequence_num
        FROM users 
        WHERE kram_id LIKE 'KRAM-' || institution_code || '-' || role_prefix || '%';
        
        -- Format the Kram ID
        kramid := 'KRAM-' || institution_code || '-' || role_prefix || LPAD(sequence_num::TEXT, 3, '0');
        
        -- Check if this ID already exists
        IF NOT EXISTS (SELECT 1 FROM users WHERE kram_id = kramid) THEN
            RETURN kramid;
        END IF;
        
        -- Prevent infinite loop
        IF attempt >= max_attempts THEN
            RAISE EXCEPTION 'Unable to generate unique Kram ID after % attempts', max_attempts;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SEED DATA: ESSENTIAL ROLES AND SUPER ADMIN USER
-- ============================================================================

-- Insert all system roles (based on the roles shown in Prisma Studio)
INSERT INTO roles (role_name, description, created_at) VALUES 
('super_admin', 'System Super Administrator', NOW()),
('admin', 'Institution Administrator', NOW()),
('student', 'Student', NOW()),
('parent', 'Parent/Guardian', NOW()),
('teacher', 'Teaching Faculty', NOW()),
('librarian', 'Library Staff', NOW()),
('staff', 'Support Staff', NOW()),
('accountant', 'Accountant/Finance Staff', NOW());

-- Insert default super admin user
INSERT INTO users (
  first_name, 
  last_name,
  uuid,
  kram_id, 
  email, 
  password_hash, 
  role_id, 
  account_status, 
  created_at, 
  updated_at
) VALUES (
  'Namit', 
  'Thakral', 
  gen_random_uuid(),
  'KRAM-SA26-DJHD',
  'superadmin@kramedu.in', 
  '$2b$10$4wTikP4R3Y6YOJbBjh7pmO7/our0SOG.Slb6AYVefAoiayAghzZim',
  1,
  'ACTIVE', 
  NOW(), 
  NOW()
);
