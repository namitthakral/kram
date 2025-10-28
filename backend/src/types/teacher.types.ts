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

// ============================================================================
// ENHANCED DASHBOARD TYPES
// ============================================================================

// Enhanced Dashboard Overview (includes tab summaries)
export interface EnhancedTeacherDashboardStats extends TeacherDashboardStats {
  totalSubjects: number
  overallClassAverage: number
  studentsAtRisk: number
  tabSummaries: {
    attendanceTrends: AttendanceTrendsSummary
    subjectPerformance: SubjectPerformanceSummary
    gradeDistribution: GradeDistributionSummary
  }
}

export interface AttendanceTrendsSummary {
  weeklyAverage: number
  trend: 'improving' | 'declining' | 'stable'
  dailyPreview: DailyAttendancePreview[]
  lastUpdated: string
}

export interface DailyAttendancePreview {
  day: string
  percentage: number
}

export interface SubjectPerformanceSummary {
  bestSubject: string
  needsAttention: string
  lastUpdated: string
}

export interface GradeDistributionSummary {
  topGrade: string
  averageGrade: string
  lastUpdated: string
}

// ============================================================================
// ATTENDANCE TRENDS TAB - DETAILED DATA
// ============================================================================

export interface AttendanceTrendsData {
  weeklyOverview: WeeklyAttendanceData
  monthlyTrends: MonthlyAttendanceData
  attendancePatterns: AttendancePatterns
}

export interface WeeklyAttendanceData {
  weekStartDate: string
  weekEndDate: string
  dailyAttendance: DailyAttendanceDetail[]
  weeklyAverage: number
}

export interface DailyAttendanceDetail {
  day: string
  date: string
  present: number
  absent: number
  late: number
  excused: number
  total: number
  percentage: number
}

export interface MonthlyAttendanceData {
  monthYear: string
  weeklyBreakdown: WeeklyBreakdown[]
  monthlyAverage: number
  comparisonWithPreviousMonth: MonthComparison
}

export interface WeeklyBreakdown {
  weekNumber: number
  weekStartDate: string
  averageAttendance: number
  totalStudents: number
}

export interface MonthComparison {
  previousMonth: string
  percentageChange: number
  trend: 'up' | 'down' | 'stable'
}

export interface AttendancePatterns {
  bestAttendanceDay: string
  worstAttendanceDay: string
  consistentAttendees: number
  irregularAttendees: number
  improvingStudents: number
  decliningStudents: number
}

// ============================================================================
// SUBJECT PERFORMANCE TAB - DETAILED DATA
// ============================================================================

export interface SubjectPerformanceData {
  subjects: SubjectPerformanceDetail[]
  overallClassAverage: number
  bestPerformingSubject: BestPerformingSubject
  subjectNeedingAttention: SubjectNeedingAttention
  performanceComparison: PerformanceComparison
}

export interface SubjectPerformanceDetail {
  id: number
  name: string
  code: string
  averageScore: number
  totalStudents: number
  performanceTrend: 'improving' | 'declining' | 'stable'
  lastUpdated: string
}

export interface BestPerformingSubject {
  name: string
  averageScore: number
}

export interface SubjectNeedingAttention {
  name: string
  averageScore: number
  studentsAtRisk: number
}

export interface PerformanceComparison {
  currentMonth: number
  previousMonth: number
  percentageChange: number
}

// ============================================================================
// GRADE DISTRIBUTION TAB - DETAILED DATA
// ============================================================================

export interface GradeDistributionData {
  overallDistribution: OverallGradeDistribution
  subjectWiseDistribution: SubjectGradeDistribution[]
  gradeComparison: GradeComparisonData
  topPerformers: TopPerformer[]
}

export interface OverallGradeDistribution {
  gradeBreakdown: Record<string, number>
  percentageBreakdown: Record<string, number>
  totalStudents: number
}

export interface SubjectGradeDistribution {
  subjectId: number
  subjectName: string
  gradeDistribution: Record<string, number>
  averageGrade: string
  medianGrade: string
}

export interface GradeComparisonData {
  currentSemester: Record<string, number>
  previousSemester: Record<string, number>
  improvement: GradeImprovement[]
}

export interface GradeImprovement {
  grade: string
  change: number
}

export interface TopPerformer {
  studentId: string
  studentName: string
  overallGrade: string
  subjectGrades: Record<string, string>
}
