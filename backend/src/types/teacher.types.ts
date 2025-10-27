import { EmploymentType, TeacherStatus } from '@prisma/client'

// Re-export Prisma enums for convenience
export { EmploymentType, TeacherStatus }

// Teacher Types
export interface Teacher {
  id: number
  userId: number
  institutionId: number
  deptId?: number
  employeeId: string
  designation?: string
  specialization?: string
  qualification?: string
  experienceYears: number
  joinDate?: Date
  salary?: number | { toNumber(): number } // Support Prisma Decimal type
  employmentType: EmploymentType
  officeLocation?: string
  officeHours?: string
  researchInterests?: string
  publications?: string
  status: TeacherStatus
  createdAt: Date
  updatedAt: Date
}

export interface CreateTeacherRequest {
  userId: number
  institutionId: number
  deptId?: number
  employeeId: string
  designation?: string
  specialization?: string
  qualification?: string
  experienceYears?: number
  joinDate?: Date
  salary?: number
  employmentType?: EmploymentType
  officeLocation?: string
  officeHours?: string
  researchInterests?: string
  publications?: string
}

// Teacher Dashboard Types
export interface TeacherDashboardStats {
  totalStudents: number
  presentToday: number
  absentToday: number
  lateToday: number
  attendancePercentageToday: number
  avgAttendanceThisMonth: number
}

export interface TeacherStudentActivity {
  id: number
  name: string
  firstName: string
  lastName: string
  initials: string
  lastActive: string
  lastActivityDate: Date | null
  grade: string
  percentage: number
  attendancePercentage: number
  admissionNumber: string
  rollNumber: string | null
}

export interface TeacherAttendanceSummary {
  period: 'daily' | 'weekly' | 'monthly'
  startDate: Date
  endDate: Date
  summary: {
    present: number
    absent: number
    late: number
    excused: number
    total: number
  }
  attendancePercentage: number
  records: TeacherAttendanceRecord[]
}

export interface TeacherAttendanceRecord {
  id: number
  date: Date
  status: string
  student: {
    id: number
    name: string
    admissionNumber: string
  }
  course: {
    name: string
    code: string
  }
  remarks: string | null
}

// Additional teacher dashboard-related types
export type TeacherAttendancePeriod = 'daily' | 'weekly' | 'monthly'

export interface TeacherAttendanceStatusCount {
  present: number
  absent: number
  late: number
  excused: number
  total: number
}

export interface TeacherStudentGradeInfo {
  grade: string
  percentage: number
  totalExams: number
}

export interface TeacherDashboardFilters {
  date?: string
  period?: TeacherAttendancePeriod
  limit?: number
}
