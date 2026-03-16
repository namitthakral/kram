import { Injectable, Logger } from '@nestjs/common'
import { OnEvent } from '@nestjs/event-emitter'
import { Cron } from '@nestjs/schedule'
import { PrismaService } from '../../prisma/prisma.service'
import { ProgressCalculator } from '../utils/progress-calculator'

/**
 * Service responsible for updating StudentProgress records
 * Uses both event-driven (real-time) and scheduled (batch) approaches
 */
@Injectable()
export class ProgressUpdaterService {
  private readonly logger = new Logger(ProgressUpdaterService.name)

  constructor(private readonly prisma: PrismaService) {}

  
  private getFullName(firstName: string, lastName: string): string {
    return `${firstName} ${lastName}`.trim()
  }
/**
   * Trigger a progress recalculation (fire-and-forget)
   * This emits an event that will be handled asynchronously
   */
  triggerRecalculation(
    studentId: number,
    subjectId: number,
    semesterId: number,
    academicYearId: number,
    trigger: string
  ): void {
    this.logger.debug(
      `Triggering progress recalculation for student ${studentId}, subject ${subjectId} (trigger: ${trigger})`
    )
    // Event will be handled by handleProgressRecalculation
  }

  /**
   * Event handler for progress recalculation
   * Runs asynchronously without blocking the API response
   */
  @OnEvent('progress.recalculate', { async: true })
  async handleProgressRecalculation(payload: {
    studentId: number
    subjectId: number
    semesterId: number
    academicYearId: number
    trigger: string
  }): Promise<void> {
    try {
      this.logger.debug(
        `Processing progress recalculation for student ${payload.studentId}, subject ${payload.subjectId} (trigger: ${payload.trigger})`
      )

      await this.recalculateProgress(
        payload.studentId,
        payload.subjectId,
        payload.semesterId,
        payload.academicYearId
      )

      this.logger.debug(
        `Successfully recalculated progress for student ${payload.studentId}, subject ${payload.subjectId}`
      )
    } catch (error) {
      this.logger.error(
        `Failed to recalculate progress for student ${payload.studentId}, subject ${payload.subjectId}`,
        error.stack
      )
      // Don't throw - this is async and shouldn't affect the main operation
    }
  }

  /**
   * Core method to recalculate and update student progress
   */
  async recalculateProgress(
    studentId: number,
    subjectId: number,
    semesterId: number,
    academicYearId: number
  ): Promise<void> {
    // Get student's institution
    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
      select: { institutionId: true },
    })

    if (!student) {
      this.logger.warn(`Student ${studentId} not found`)
      return
    }

    // Calculate all metrics using optimized batch ProgressCalculator
    const progressMap = await ProgressCalculator.calculateProgressBatch(
      this.prisma,
      [studentId], // Batch method even for single student (uses optimized views)
      subjectId,
      semesterId,
      academicYearId,
      student.institutionId
    )
    
    const progressData = progressMap.get(studentId)
    if (!progressData) {
      this.logger.warn(`Could not calculate progress for student ${studentId}`)
      return
    }

    // Update or create StudentProgress record
    await this.prisma.studentProgress.upsert({
      where: {
        unique_student_progress: {
          studentId,
          subjectId,
          semesterId,
        },
      },
      update: {
        attendancePercentage: progressData.attendancePercentage,
        assignmentScore: progressData.assignmentScore,
        examScore: progressData.examScore,
        participationScore: progressData.participationScore,
        overallGrade: progressData.overallGrade,
        gradePoints: progressData.gradePoints,
        status: progressData.status as any,
        lastUpdated: new Date(),
        updatedAt: new Date(),
      },
      create: {
        studentId,
        subjectId,
        semesterId,
        academicYearId,
        attendancePercentage: progressData.attendancePercentage,
        assignmentScore: progressData.assignmentScore,
        examScore: progressData.examScore,
        participationScore: progressData.participationScore,
        overallGrade: progressData.overallGrade,
        gradePoints: progressData.gradePoints,
        status: progressData.status as any,
        strengths: [],
        areasForImprovement: [],
        lastUpdated: new Date(),
      },
    })
  }

  /**
   * Recalculate progress for all subjects of a specific student
   */
  async recalculateStudentProgress(studentId: number): Promise<void> {
    this.logger.debug(`Recalculating all progress for student ${studentId}`)

    // Get current semester
    const currentSemester = await this.prisma.semester.findFirst({
      where: { status: 'ACTIVE' },
    })

    if (!currentSemester) {
      this.logger.warn('No active semester found')
      return
    }

    // Get all enrollments for this student in current semester
    const enrollments = await this.prisma.enrollment.findMany({
      where: {
        studentId,
        semesterId: currentSemester.id,
      },
      include: {
        subject: {
          select: {
            id: true,
            subjectCode: true,
            courseId: true,
            course: {
              select: {
                institutionId: true,
              },
            },
          },
        },
      },
    })

    // Get academic year
    const academicYear = await this.prisma.academicYear.findFirst({
      where: { id: currentSemester.academicYearId },
    })

    if (!academicYear) {
      this.logger.warn('No academic year found')
      return
    }

    // Recalculate for each enrolled subject
    for (const enrollment of enrollments) {
      if (!enrollment.subject.course) continue

      try {
        await this.recalculateProgress(
          studentId,
          enrollment.subject.id,
          currentSemester.id,
          academicYear.id
        )
      } catch (error) {
        this.logger.error(
          `Failed to recalculate progress for student ${studentId}, subject ${enrollment.subject.id}`,
          error.stack
        )
      }
    }

    this.logger.debug(
      `Completed progress recalculation for student ${studentId}`
    )
  }

  /**
   * Scheduled job: Daily comprehensive progress recalculation
   * Runs at 2 AM every day to ensure data integrity
   */
  @Cron('0 2 * * *', {
    name: 'daily-progress-recalculation',
    timeZone: 'UTC',
  })
  async dailyProgressRecalculation(): Promise<void> {
    this.logger.log('Starting daily comprehensive progress recalculation...')

    try {
      // Get current semester
      const currentSemester = await this.prisma.semester.findFirst({
        where: { status: 'ACTIVE' },
      })

      if (!currentSemester) {
        this.logger.warn('No active semester found, skipping recalculation')
        return
      }

      // Get all student progress records for current semester
      const progressRecords = await this.prisma.studentProgress.findMany({
        where: { semesterId: currentSemester.id },
        select: {
          studentId: true,
          subjectId: true,
          semesterId: true,
          academicYearId: true,
        },
      })

      this.logger.log(
        `Found ${progressRecords.length} progress records to recalculate`
      )

      // Process in batches of 50 to avoid memory issues
      const batchSize = 50
      for (let i = 0; i < progressRecords.length; i += batchSize) {
        const batch = progressRecords.slice(i, i + batchSize)

        await Promise.all(
          batch.map(record =>
            this.recalculateProgress(
              record.studentId,
              record.subjectId,
              record.semesterId,
              record.academicYearId
            ).catch(error => {
              this.logger.error(
                `Failed to recalculate progress for student ${record.studentId}, subject ${record.subjectId}`,
                error.stack
              )
            })
          )
        )

        this.logger.debug(
          `Processed batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(progressRecords.length / batchSize)}`
        )
      }

      this.logger.log(
        'Daily comprehensive progress recalculation completed successfully'
      )
    } catch (error) {
      this.logger.error('Daily progress recalculation failed', error.stack)
    }
  }

  /**
   * Scheduled job: Weekly at-risk student identification
   * Runs every Monday at 8 AM
   */
  @Cron('0 8 * * 1', {
    name: 'weekly-at-risk-identification',
    timeZone: 'UTC',
  })
  async weeklyAtRiskIdentification(): Promise<void> {
    this.logger.log('Starting weekly at-risk student identification...')

    try {
      const currentSemester = await this.prisma.semester.findFirst({
        where: { status: 'ACTIVE' },
      })

      if (!currentSemester) {
        this.logger.warn('No active semester found')
        return
      }

      // Find all at-risk students
      const atRiskStudents = await this.prisma.studentProgress.findMany({
        where: {
          semesterId: currentSemester.id,
          status: {
            in: ['AT_RISK', 'FAILING', 'NEEDS_IMPROVEMENT'],
          },
        },
        include: {
          student: {
            select: {
              user: {
                select: { firstName: true, lastName: true, email: true },
              },
            },
          },
          subject: {
            select: { subjectName: true, subjectCode: true },
          },
        },
      })

      this.logger.log(
        `Identified ${atRiskStudents.length} at-risk student records`
      )

      // Here you could send notifications, create alerts, etc.
      // For now, just log the information
      const studentGroups = new Map<number, any[]>()
      atRiskStudents.forEach(record => {
        if (!studentGroups.has(record.studentId)) {
          studentGroups.set(record.studentId, [])
        }
        studentGroups.get(record.studentId)!.push({
          subject: record.subject.subjectName,
          status: record.status,
          grade: record.overallGrade,
          attendance: record.attendancePercentage,
        })
      })

      studentGroups.forEach((subjects, studentId) => {
        const studentRecord = atRiskStudents.find(
          r => r.studentId === studentId
        )
        if (studentRecord) {
          this.logger.warn(
            `At-risk student: ${studentRecord.student.user.firstName} ${studentRecord.student.user.lastName} (${studentRecord.student.user.email}) - ${subjects.length} subjects need attention`
          )
        }
      })

      this.logger.log('Weekly at-risk student identification completed')
    } catch (error) {
      this.logger.error('Weekly at-risk identification failed', error.stack)
    }
  }

  /**
   * Manual trigger for recalculating all progress (useful for admin operations)
   */
  async recalculateAllProgress(): Promise<{
    success: boolean
    recordsProcessed: number
  }> {
    this.logger.log('Starting manual comprehensive progress recalculation...')

    try {
      const currentSemester = await this.prisma.semester.findFirst({
        where: { status: 'ACTIVE' },
      })

      if (!currentSemester) {
        throw new Error('No active semester found')
      }

      const progressRecords = await this.prisma.studentProgress.findMany({
        where: { semesterId: currentSemester.id },
        select: {
          studentId: true,
          subjectId: true,
          semesterId: true,
          academicYearId: true,
        },
      })

      const batchSize = 50
      for (let i = 0; i < progressRecords.length; i += batchSize) {
        const batch = progressRecords.slice(i, i + batchSize)
        await Promise.all(
          batch.map(record =>
            this.recalculateProgress(
              record.studentId,
              record.subjectId,
              record.semesterId,
              record.academicYearId
            )
          )
        )
      }

      this.logger.log(
        `Manual recalculation completed: ${progressRecords.length} records processed`
      )

      return {
        success: true,
        recordsProcessed: progressRecords.length,
      }
    } catch (error) {
      this.logger.error('Manual recalculation failed', error.stack)
      throw error
    }
  }
}
