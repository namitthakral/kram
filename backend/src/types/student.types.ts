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

// ============================================================================
// REPORT CARD TYPES
// ============================================================================

export interface ReportCardSubjectRecord {
  subjectName: string
  subjectCode: string
  credits: number
  marksObtained: number | null
  maxMarks: number | null
  percentage: number | null
  grade: string | null
  gradePoints: number | null
  status: 'PASSED' | 'FAILED' | 'INCOMPLETE' | 'WITHDRAWN'
  teacherRemarks?: string
}

export interface ReportCardAttendanceSummary {
  totalClasses: number
  classesAttended: number
  classesAbsent: number
  percentage: number
  status: 'excellent' | 'good' | 'satisfactory' | 'poor'
}

export interface ReportCardExamSummary {
  examType: string
  examName: string
  totalMarks: number
  marksObtained: number
  percentage: number
  grade: string
  rank?: number
}

export interface ReportCardStudentInfo {
  name: string
  kramid: string | null
  admissionNumber: string
  rollNumber: string | null
  courseName: string | null
  courseCode: string | null
  currentSemester: number | null
  currentYear: number | null
  section: string | null
  institutionName: string
}

export interface ReportCardSemesterInfo {
  semesterId: number
  semesterName: string
  semesterNumber: number
  academicYear: string
  startDate: string
  endDate: string
}

export interface ReportCardPerformanceSummary {
  sgpa: number // Semester Grade Point Average
  cgpa: number // Cumulative Grade Point Average
  totalCreditsEarned: number
  totalCreditsAttempted: number
  classRank: number | null
  totalStudents: number | null
  percentile: number | null
  overallGrade: string
  overallStatus: 'PASSED' | 'FAILED' | 'PROMOTED' | 'DETAINED'
}

export interface ReportCardRemarks {
  principalRemarks?: string
  classTeacherRemarks?: string
  strengths: string[]
  areasForImprovement: string[]
}

export interface ReportCard {
  studentInfo: ReportCardStudentInfo
  semesterInfo: ReportCardSemesterInfo
  subjectRecords: ReportCardSubjectRecord[]
  examSummaries: ReportCardExamSummary[]
  attendanceSummary: ReportCardAttendanceSummary
  performanceSummary: ReportCardPerformanceSummary
  remarks: ReportCardRemarks
  generatedAt: string
  reportCardNumber: string
}

export interface ReportCardResponse {
  success: boolean
  data: ReportCard
}

export interface ReportCardQueryParams {
  semesterId?: number
  academicYearId?: number
  includeExamDetails?: boolean
}

// ============================================================================
// BATCH REPORT CARD TYPES (For Teachers)
// ============================================================================

export interface BatchReportCardRequest {
  sectionId?: number
  courseId?: number
  semesterId?: number
  studentIds?: number[]
  includeExamDetails?: boolean
}

export interface BatchReportCardStudentSummary {
  studentId: number
  studentName: string
  admissionNumber: string
  rollNumber: string | null
  sgpa: number
  cgpa: number
  attendancePercentage: number
  overallGrade: string
  overallStatus: 'PASSED' | 'FAILED' | 'PROMOTED' | 'DETAINED'
  classRank: number | null
  reportCardNumber: string
}

export interface BatchReportCardResponse {
  success: boolean
  data: {
    reportCards: ReportCard[]
    summary: {
      totalStudents: number
      generated: number
      failed: number
      averageSgpa: number
      averageAttendance: number
      passCount: number
      failCount: number
      gradeDistribution: {
        grade: string
        count: number
        percentage: number
      }[]
    }
    studentSummaries: BatchReportCardStudentSummary[]
    generatedAt: string
    batchId: string
  }
}
