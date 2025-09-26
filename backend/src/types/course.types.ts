// Course Types
export interface Course {
  id: number
  programId?: number
  deptId?: number
  courseName: string
  courseCode: string
  credits: number
  lectureHours: number
  labHours: number
  tutorialHours: number
  courseType: CourseType
  prerequisites?: string
  description?: string
  syllabus?: string
  status: CourseStatus
  createdAt: Date
  updatedAt: Date
}

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
