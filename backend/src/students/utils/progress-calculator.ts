import { Decimal } from '@prisma/client/runtime/library'
import { PrismaService } from '../../prisma/prisma.service'
import { GradingConfig } from './grading-config.interface'

/**
 * Utility class for calculating student progress metrics
 * Used by both real-time updates and scheduled batch jobs
 * Supports institution-specific grading configurations
 */
export class ProgressCalculator {
  /**
   * Default grading configuration (fallback if institution hasn't customized)
   */
  private static readonly DEFAULT_CONFIG: GradingConfig = {
    attendanceWeight: 10,
    assignmentWeight: 30,
    examWeight: 50,
    participationWeight: 10,

    gradeAPlusThreshold: 93,
    gradeAThreshold: 85,
    gradeBPlusThreshold: 77,
    gradeBThreshold: 70,
    gradeCThreshold: 60,

    gradeAPlusPoints: 4.0,
    gradeAPoints: 3.7,
    gradeBPlusPoints: 3.3,
    gradeBPoints: 3.0,
    gradeCPoints: 2.0,
    gradeDPoints: 1.0,

    atRiskAttendance: 75,
    atRiskAssignment: 60,
    atRiskExam: 60,
    atRiskGradePoints: 2.0,

    needsImprovementAttendance: 85,
    needsImprovementAssignment: 70,
    needsImprovementExam: 70,
    needsImprovementGradePoints: 3.0,

    excellentAttendance: 95,
    excellentAssignment: 90,
    excellentExam: 90,
    excellentGradePoints: 3.7,

    goodAttendance: 90,
    goodAssignment: 80,
    goodExam: 80,
    goodGradePoints: 3.3,
  }

  /**
   * Get grading configuration for an institution
   */
  static async getGradingConfig(
    prisma: PrismaService,
    institutionId: number
  ): Promise<GradingConfig> {
    const config = await prisma.institutionGradingConfig.findUnique({
      where: { institutionId, isActive: true },
    })

    if (!config) {
      return this.DEFAULT_CONFIG
    }

    // Convert Prisma Decimal to number
    return {
      attendanceWeight: parseFloat(config.attendanceWeight.toString()),
      assignmentWeight: parseFloat(config.assignmentWeight.toString()),
      examWeight: parseFloat(config.examWeight.toString()),
      participationWeight: parseFloat(config.participationWeight.toString()),

      gradeAPlusThreshold: parseFloat(config.gradeAPlusThreshold.toString()),
      gradeAThreshold: parseFloat(config.gradeAThreshold.toString()),
      gradeBPlusThreshold: parseFloat(config.gradeBPlusThreshold.toString()),
      gradeBThreshold: parseFloat(config.gradeBThreshold.toString()),
      gradeCThreshold: parseFloat(config.gradeCThreshold.toString()),

      gradeAPlusPoints: parseFloat(config.gradeAPlusPoints.toString()),
      gradeAPoints: parseFloat(config.gradeAPoints.toString()),
      gradeBPlusPoints: parseFloat(config.gradeBPlusPoints.toString()),
      gradeBPoints: parseFloat(config.gradeBPoints.toString()),
      gradeCPoints: parseFloat(config.gradeCPoints.toString()),
      gradeDPoints: parseFloat(config.gradeDPoints.toString()),

      atRiskAttendance: parseFloat(config.atRiskAttendance.toString()),
      atRiskAssignment: parseFloat(config.atRiskAssignment.toString()),
      atRiskExam: parseFloat(config.atRiskExam.toString()),
      atRiskGradePoints: parseFloat(config.atRiskGradePoints.toString()),

      needsImprovementAttendance: parseFloat(
        config.needsImprovementAttendance.toString()
      ),
      needsImprovementAssignment: parseFloat(
        config.needsImprovementAssignment.toString()
      ),
      needsImprovementExam: parseFloat(config.needsImprovementExam.toString()),
      needsImprovementGradePoints: parseFloat(
        config.needsImprovementGradePoints.toString()
      ),

      excellentAttendance: parseFloat(config.excellentAttendance.toString()),
      excellentAssignment: parseFloat(config.excellentAssignment.toString()),
      excellentExam: parseFloat(config.excellentExam.toString()),
      excellentGradePoints: parseFloat(config.excellentGradePoints.toString()),

      goodAttendance: parseFloat(config.goodAttendance.toString()),
      goodAssignment: parseFloat(config.goodAssignment.toString()),
      goodExam: parseFloat(config.goodExam.toString()),
      goodGradePoints: parseFloat(config.goodGradePoints.toString()),
    }
  }
  /**
   * Calculate attendance percentage for a student in a subject
   */
  static async calculateAttendance(
    prisma: PrismaService,
    studentId: number,
    subjectId: number,
    semesterId: number
  ): Promise<number> {
    // Get all sections for this subject in the current semester
    const sections = await prisma.classSection.findMany({
      where: {
        semesterId,
        subjectId,
      },
      select: { id: true },
    })

    if (sections.length === 0) return 0

    const sectionIds = sections.map(s => s.id)

    // Get attendance records
    const attendanceRecords = await prisma.attendance.findMany({
      where: {
        studentId,
        sectionId: { in: sectionIds },
      },
    })

    if (attendanceRecords.length === 0) return 0

    const presentCount = attendanceRecords.filter(
      a => a.status === 'PRESENT' || a.status === 'LATE'
    ).length

    return (
      Math.round((presentCount / attendanceRecords.length) * 100 * 100) / 100
    )
  }

  /**
   * Calculate average assignment score for a student in a subject
   */
  static async calculateAssignmentScore(
    prisma: PrismaService,
    studentId: number,
    subjectId: number,
    semesterId: number
  ): Promise<number> {
    // Get all sections for this subject in the current semester
    const sections = await prisma.classSection.findMany({
      where: {
        semesterId,
        subjectId,
      },
      select: { id: true },
    })

    if (sections.length === 0) return 0

    const sectionIds = sections.map(s => s.id)

    // Get all assignments for this subject and semester
    const assignments = await prisma.assignment.findMany({
      where: {
        subjectId,
        sectionId: { in: sectionIds },
      },
      select: { id: true },
    })

    if (assignments.length === 0) return 0

    const assignmentIds = assignments.map(a => a.id)

    // Get submissions
    const submissions = await prisma.submission.findMany({
      where: {
        studentId,
        assignmentId: { in: assignmentIds },
        status: 'GRADED',
        marksObtained: { not: null },
      },
      include: {
        assignment: {
          select: { maxMarks: true },
        },
      },
    })

    if (submissions.length === 0) return 0

    // Calculate weighted average
    let totalScore = 0
    let totalMaxMarks = 0

    submissions.forEach(sub => {
      if (sub.marksObtained && sub.assignment.maxMarks) {
        totalScore += parseFloat(sub.marksObtained.toString())
        totalMaxMarks += parseFloat(sub.assignment.maxMarks.toString())
      }
    })

    if (totalMaxMarks === 0) return 0

    return Math.round((totalScore / totalMaxMarks) * 100 * 100) / 100
  }

  /**
   * Calculate average exam score for a student in a subject
   */
  static async calculateExamScore(
    prisma: PrismaService,
    studentId: number,
    subjectId: number,
    semesterId: number
  ): Promise<number> {
    // Get all exams for this subject and semester
    const exams = await prisma.examination.findMany({
      where: {
        semesterId,
        subjectId,
      },
      select: { id: true },
    })

    if (exams.length === 0) return 0

    const examIds = exams.map(e => e.id)

    // Get exam results
    const results = await prisma.examResult.findMany({
      where: {
        studentId,
        examId: { in: examIds },
        marksObtained: { not: null },
      },
      include: {
        exam: {
          select: { totalMarks: true },
        },
      },
    })

    if (results.length === 0) return 0

    // Calculate weighted average
    let totalScore = 0
    let totalMaxMarks = 0

    results.forEach(result => {
      if (result.marksObtained && result.exam.totalMarks) {
        totalScore += parseFloat(result.marksObtained.toString())
        totalMaxMarks += parseFloat(result.exam.totalMarks.toString())
      }
    })

    if (totalMaxMarks === 0) return 0

    return Math.round((totalScore / totalMaxMarks) * 100 * 100) / 100
  }

  /**
   * Calculate participation score (can be extended with more logic)
   */
  static async calculateParticipationScore(
    prisma: PrismaService,
    studentId: number,
    subjectId: number,
    semesterId: number
  ): Promise<number> {
    // For now, use attendance as a proxy for participation
    // Can be extended to include class participation, discussions, etc.
    const attendance = await this.calculateAttendance(
      prisma,
      studentId,
      subjectId,
      semesterId
    )
    return attendance
  }

  /**
   * Calculate overall grade based on weighted components using institution config
   */
  static calculateOverallGrade(
    attendancePercentage: number,
    assignmentScore: number,
    examScore: number,
    participationScore: number,
    config: GradingConfig
  ): string {
    // Weighted average using institution's weights
    const weightedScore =
      attendancePercentage * (config.attendanceWeight / 100) +
      assignmentScore * (config.assignmentWeight / 100) +
      examScore * (config.examWeight / 100) +
      participationScore * (config.participationWeight / 100)

    return this.scoreToGrade(weightedScore, config)
  }

  /**
   * Convert numeric score to letter grade using institution's thresholds
   */
  static scoreToGrade(score: number, config: GradingConfig): string {
    if (score >= config.gradeAPlusThreshold) return 'A+'
    if (score >= config.gradeAThreshold) return 'A'
    if (score >= config.gradeBPlusThreshold) return 'B+'
    if (score >= config.gradeBThreshold) return 'B'
    if (score >= config.gradeCThreshold) return 'C'
    return 'D'
  }

  /**
   * Convert letter grade to grade points using institution's mapping
   */
  static gradeToPoints(grade: string, config: GradingConfig): number {
    const gradeMap: Record<string, number> = {
      'A+': config.gradeAPlusPoints,
      A: config.gradeAPoints,
      'B+': config.gradeBPlusPoints,
      B: config.gradeBPoints,
      C: config.gradeCPoints,
      D: config.gradeDPoints,
    }
    return gradeMap[grade] || 0
  }

  /**
   * Determine progress status based on metrics using institution's thresholds
   */
  static determineStatus(
    attendancePercentage: number,
    assignmentScore: number,
    examScore: number,
    overallGrade: string,
    config: GradingConfig
  ): string {
    const gradePoints = this.gradeToPoints(overallGrade, config)

    // At-risk criteria (using institution's thresholds)
    if (
      attendancePercentage < config.atRiskAttendance ||
      assignmentScore < config.atRiskAssignment ||
      examScore < config.atRiskExam ||
      gradePoints < config.atRiskGradePoints
    ) {
      return 'AT_RISK'
    }

    // Needs improvement
    if (
      attendancePercentage < config.needsImprovementAttendance ||
      assignmentScore < config.needsImprovementAssignment ||
      examScore < config.needsImprovementExam ||
      gradePoints < config.needsImprovementGradePoints
    ) {
      return 'NEEDS_IMPROVEMENT'
    }

    // Excellent
    if (
      attendancePercentage >= config.excellentAttendance &&
      assignmentScore >= config.excellentAssignment &&
      examScore >= config.excellentExam &&
      gradePoints >= config.excellentGradePoints
    ) {
      return 'EXCELLENT'
    }

    // Good
    if (
      attendancePercentage >= config.goodAttendance &&
      assignmentScore >= config.goodAssignment &&
      examScore >= config.goodExam &&
      gradePoints >= config.goodGradePoints
    ) {
      return 'GOOD'
    }

    // Default: On track
    return 'ON_TRACK'
  }

  /**
   * Recalculate all metrics and return complete progress data using institution config
   */
  static async calculateCompleteProgress(
    prisma: PrismaService,
    studentId: number,
    subjectId: number,
    semesterId: number,
    academicYearId: number,
    institutionId: number
  ): Promise<{
    attendancePercentage: Decimal
    assignmentScore: Decimal
    examScore: Decimal
    participationScore: Decimal
    overallGrade: string
    gradePoints: Decimal
    status: string
  }> {
    // Get institution's grading configuration
    const config = await this.getGradingConfig(prisma, institutionId)

    // Calculate all metrics
    const attendancePercentage = await this.calculateAttendance(
      prisma,
      studentId,
      subjectId,
      semesterId
    )

    const assignmentScore = await this.calculateAssignmentScore(
      prisma,
      studentId,
      subjectId,
      semesterId
    )

    const examScore = await this.calculateExamScore(
      prisma,
      studentId,
      subjectId,
      semesterId
    )

    const participationScore = await this.calculateParticipationScore(
      prisma,
      studentId,
      subjectId,
      semesterId
    )

    // Calculate overall grade using institution's config
    const overallGrade = this.calculateOverallGrade(
      attendancePercentage,
      assignmentScore,
      examScore,
      participationScore,
      config
    )

    const gradePoints = this.gradeToPoints(overallGrade, config)

    // Determine status using institution's thresholds
    const status = this.determineStatus(
      attendancePercentage,
      assignmentScore,
      examScore,
      overallGrade,
      config
    )

    return {
      attendancePercentage: new Decimal(attendancePercentage),
      assignmentScore: new Decimal(assignmentScore),
      examScore: new Decimal(examScore),
      participationScore: new Decimal(participationScore),
      overallGrade,
      gradePoints: new Decimal(gradePoints),
      status,
    }
  }
}
