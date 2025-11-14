// ============================================================================
// COURSE/SUBJECT TYPES
// ============================================================================
//
// TERMINOLOGY CLARIFICATION:
// - International: "Course" = Individual academic class (CS101, Math201)
// - Indian: "Subject/Paper" = Individual academic class (Data Structures, Physics)
//
// In this codebase:
// - Database table: "courses"
// - Indian API: "subjects"
// - Both refer to the same entity
//
// Examples:
// - Colleges: "Data Structures", "Database Management", "Organic Chemistry"
// - Schools: "English", "Hindi", "Mathematics", "Physics", "Biology"
// ============================================================================

/**
 * Course/Subject Interface
 * Represents an individual academic subject that students study
 */
export interface Course {
  id: number
  programId?: number // Optional - null for general subjects
  deptId?: number
  courseName: string // In Indian context: Subject name (e.g., "Data Structures", "English")
  courseCode: string // e.g., "CS201", "ENG101", "MATH10"
  credits: number // For colleges: credit hours; For schools: total marks
  lectureHours: number // Theory hours per week
  labHours: number // Practical/lab hours per week
  tutorialHours: number
  courseType: CourseType // CORE, ELECTIVE, etc.
  prerequisites?: string // JSON array of prerequisite course IDs
  description?: string
  syllabus?: string
  status: CourseStatus
  createdAt: Date
  updatedAt: Date
}

/**
 * Type alias for Indian context
 * Subject = Course in this system
 */
export type Subject = Course

export interface CreateCourseRequest {
  programId?: number
  deptId?: number
  courseName: string
  courseCode: string
  credits: number
  lectureHours?: number
  labHours?: number
  tutorialHours?: number
  courseType?: CourseType
  prerequisites?: string
  description?: string
  syllabus?: string
}

/**
 * Type alias for Indian context
 */
export type CreateSubjectRequest = CreateCourseRequest

// Course Enums
export enum CourseType {
  CORE = 'CORE',
  ELECTIVE = 'ELECTIVE',
  MINOR = 'MINOR',
  MAJOR = 'MAJOR',
}

export enum CourseStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
}

export enum DegreeType {
  CERTIFICATE = 'CERTIFICATE',
  DIPLOMA = 'DIPLOMA',
  BACHELORS = 'BACHELORS',
  MASTERS = 'MASTERS',
  PHD = 'PHD',
  OTHER = 'OTHER',
}

export enum ProgramStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
}
