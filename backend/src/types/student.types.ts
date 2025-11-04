import { ResidentialStatus, StudentStatus, StudentType } from '@prisma/client'

// Re-export Prisma enums for convenience
export { ResidentialStatus, StudentStatus, StudentType }

// Student Types
export interface Student {
  id: number
  userId: number
  institutionId: number
  programId?: number
  admissionNumber: string
  rollNumber?: string
  admissionDate?: Date
  graduationDate?: Date
  currentSemester?: number
  currentYear?: number
  gradeLevel?: string
  section?: string
  studentType: StudentType
  residentialStatus: ResidentialStatus
  transportRequired: boolean
  emergencyContactName?: string
  emergencyContactPhone?: string
  bloodGroup?: string
  medicalConditions?: string
  status: StudentStatus
  createdAt: Date
  updatedAt: Date
}

export interface CreateStudentRequest {
  userId: number
  institutionId: number
  programId?: number
  admissionNumber: string
  rollNumber?: string
  admissionDate?: Date
  currentSemester?: number
  currentYear?: number
  gradeLevel?: string
  section?: string
  studentType?: StudentType
  residentialStatus?: ResidentialStatus
  transportRequired?: boolean
  emergencyContactName?: string
  emergencyContactPhone?: string
  bloodGroup?: string
  medicalConditions?: string
}

// ============================================================================
// STUDENT DASHBOARD TYPES
// ============================================================================

export interface StudentDashboardStats {
  currentGpa: number
  maxGpa: number
  gpaChange: number
  attendance: number
  attendanceChange: number
  classRank: number
  totalStudents: number
  rankChange: number
  assignmentsDue: number
}

export interface StudentAssignment {
  id: number
  title: string
  subject: string
  dueDate: string
  status: 'submitted' | 'graded' | 'pending'
  grade?: string
  score?: string
  maxMarks?: number
  marksObtained?: number
}

export interface StudentAssignmentsResponse {
  success: boolean
  data: {
    assignments: StudentAssignment[]
    totalCount: number
  }
}

export interface PerformanceTrendDataPoint {
  month: string
  score: number
}

export interface SubjectPerformanceTrend {
  subject: string
  subjectCode: string
  dataPoints: PerformanceTrendDataPoint[]
}

export interface StudentPerformanceTrendsResponse {
  success: boolean
  data: {
    trends: SubjectPerformanceTrend[]
    period: {
      startMonth: string
      endMonth: string
    }
  }
}

export interface AttendanceHistoryDataPoint {
  month: string
  percentage: number
  totalClasses: number
  attendedClasses: number
}

export interface StudentAttendanceHistoryResponse {
  success: boolean
  data: {
    attendanceHistory: AttendanceHistoryDataPoint[]
    overallPercentage: number
    period: {
      startDate: string
      endDate: string
    }
  }
}

export interface StudentSubjectPerformance {
  subject: string
  subjectCode: string
  teacher: string
  nextTest?: string
  grade: string
  percentage: number
  gradePoints?: number
  status: 'excellent' | 'good' | 'average' | 'needs_improvement'
}

export interface StudentSubjectPerformanceResponse {
  success: boolean
  data: {
    subjects: StudentSubjectPerformance[]
    overallGpa: number
  }
}

export interface StudentUpcomingEvent {
  id: number
  title: string
  date: string
  time?: string
  type: 'test' | 'assignment' | 'event'
  subject?: string
  description?: string
}

export interface StudentUpcomingEventsResponse {
  success: boolean
  data: {
    events: StudentUpcomingEvent[]
    totalCount: number
  }
}

export interface StudentDashboardStatsResponse {
  success: boolean
  data: StudentDashboardStats
}
