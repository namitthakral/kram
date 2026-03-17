import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common'
import { Prisma, AttendanceType, AttendanceStatus } from '@prisma/client'
import { PrismaService } from '../../prisma/prisma.service'

export interface AttendanceRecord {
  id: number
  studentId: number
  studentAcademicYearId: number | null
  date: Date
  status: AttendanceStatus
  attendanceType: AttendanceType
  sectionId: number | null
  remarks: string | null
  markedBy: number
  markedAt: Date
}

export interface AttendanceSummary {
  studentId: number
  academicYearId: number
  classLevel: number
  totalDays: number
  presentDays: number
  absentDays: number
  lateDays: number
  excusedDays: number
  attendancePercentage: number
}

export interface AttendanceQueryOptions {
  studentId?: number
  academicYearId?: number
  classLevel?: number
  sectionId?: number
  attendanceType?: AttendanceType
  startDate?: Date
  endDate?: Date
  status?: AttendanceStatus
  limit?: number
  offset?: number
}

@Injectable()
export class AttendanceService {
  constructor(private prisma: PrismaService) {}

  /**
   * Record attendance for a student using academic year context
   */
  async recordAttendance(data: {
    studentId: number
    date: Date
    status: AttendanceStatus
    attendanceType?: AttendanceType
    sectionId?: number
    remarks?: string
    markedBy?: number
  }): Promise<{
    success: boolean
    data: AttendanceRecord
    message: string
  }> {
    // Get student's current academic year record
    const studentAcademicYear = await this.prisma.studentAcademicYear.findFirst({
      where: {
        studentId: data.studentId,
        promotionStatus: 'IN_PROGRESS',
      },
      orderBy: { academicYear: { startDate: 'desc' } },
    })

    if (!studentAcademicYear) {
      throw new NotFoundException(
        'No active academic year record found for student',
      )
    }

    // Check if attendance already exists for this date and context
    const existingAttendance = await this.prisma.attendance.findFirst({
      where: {
        studentId: data.studentId,
        date: data.date,
        attendanceType: data.attendanceType || AttendanceType.DAILY,
        sectionId: data.sectionId || null,
      },
    })

    if (existingAttendance) {
      throw new BadRequestException(
        'Attendance already recorded for this date and context',
      )
    }

    const attendance = await this.prisma.attendance.create({
      data: {
        studentId: data.studentId,
        studentAcademicYearId: studentAcademicYear.id,
        date: data.date,
        status: data.status,
        attendanceType: data.attendanceType || AttendanceType.DAILY,
        sectionId: data.sectionId,
        remarks: data.remarks,
        markedBy: data.markedBy || 1, // Default marker - should be passed from current user
      },
    })

    // Update attendance summary in StudentAcademicYear
    await this.updateAttendanceSummary(studentAcademicYear.id)

    return {
      success: true,
      data: attendance,
      message: 'Attendance recorded successfully',
    }
  }

  /**
   * Get attendance records with academic year context
   */
  async getAttendanceRecords(
    options: AttendanceQueryOptions,
  ): Promise<{
    success: boolean
    data: Array<AttendanceRecord & {
      student?: {
        user: { firstName: string; lastName: string }
        admissionNumber: string
      }
      section?: { 
        sectionName: string
        subject: { subjectName: string; subjectCode: string }
      }
    }>
    pagination: {
      total: number
      limit: number
      offset: number
    }
  }> {
    const where: Prisma.AttendanceWhereInput = {}

    if (options.studentId) {
      where.studentId = options.studentId
    }

    if (options.academicYearId) {
      where.studentAcademicYear = {
        academicYearId: options.academicYearId,
      }
    }

    if (options.classLevel) {
      where.studentAcademicYear = {
        classLevel: options.classLevel,
      }
    }

    if (options.sectionId) {
      where.sectionId = options.sectionId
    }

    if (options.attendanceType) {
      where.attendanceType = options.attendanceType
    }

    if (options.startDate && options.endDate) {
      where.date = {
        gte: options.startDate,
        lte: options.endDate,
      }
    } else if (options.startDate) {
      where.date = { gte: options.startDate }
    } else if (options.endDate) {
      where.date = { lte: options.endDate }
    }

    if (options.status) {
      where.status = options.status
    }

    const [records, total] = await Promise.all([
      this.prisma.attendance.findMany({
        where,
        include: {
          student: {
            select: {
              admissionNumber: true,
              user: {
                select: {
                  firstName: true,
                  lastName: true,
                },
              },
            },
          },
          section: {
            select: {
              sectionName: true,
              subject: {
                select: {
                  subjectName: true,
                  subjectCode: true,
                },
              },
            },
          },
        },
        orderBy: [
          { date: 'desc' },
          { markedAt: 'desc' },
        ],
        take: options.limit || 50,
        skip: options.offset || 0,
      }),
      this.prisma.attendance.count({ where }),
    ])

    return {
      success: true,
      data: records,
      pagination: {
        total,
        limit: options.limit || 50,
        offset: options.offset || 0,
      },
    }
  }

  /**
   * Get attendance summary for a student's academic year
   */
  async getAttendanceSummary(
    studentId: number,
    academicYearId?: number,
  ): Promise<{
    success: boolean
    data: AttendanceSummary | null
  }> {
    // Get student's academic year record
    const whereClause: Prisma.StudentAcademicYearWhereInput = {
      studentId,
    }

    if (academicYearId) {
      whereClause.academicYearId = academicYearId
    } else {
      whereClause.promotionStatus = 'IN_PROGRESS'
    }

    const studentAcademicYear = await this.prisma.studentAcademicYear.findFirst({
      where: whereClause,
      orderBy: { academicYear: { startDate: 'desc' } },
    })

    if (!studentAcademicYear) {
      return {
        success: true,
        data: null,
      }
    }

    // Use the optimized view for attendance summary
    const summaryData = await this.prisma.$queryRaw<
      Array<{
        student_id: number
        academic_year_id: number
        class_level: number
        days_present: bigint
        days_absent: bigint
        total_days: bigint
        attendance_percentage: number
      }>
    >`
      SELECT * FROM student_attendance_summary
      WHERE student_id = ${studentId} 
        AND academic_year_id = ${studentAcademicYear.academicYearId}
    `

    if (summaryData.length === 0) {
      return {
        success: true,
        data: {
          studentId,
          academicYearId: studentAcademicYear.academicYearId,
          classLevel: studentAcademicYear.classLevel,
          totalDays: 0,
          presentDays: 0,
          absentDays: 0,
          lateDays: 0,
          excusedDays: 0,
          attendancePercentage: 0,
        },
      }
    }

    const summary = summaryData[0]
    
    return {
      success: true,
      data: {
        studentId,
        academicYearId: studentAcademicYear.academicYearId,
        classLevel: studentAcademicYear.classLevel,
        totalDays: Number(summary.total_days),
        presentDays: Number(summary.days_present),
        absentDays: Number(summary.days_absent),
        lateDays: 0, // Will be calculated separately if needed
        excusedDays: 0, // Will be calculated separately if needed
        attendancePercentage: summary.attendance_percentage,
      },
    }
  }

  /**
   * Get attendance summary for multiple students in a class
   */
  async getClassAttendanceSummary(
    academicYearId: number,
    classLevel?: number,
    classDivisionId?: number,
  ): Promise<{
    success: boolean
    data: Array<AttendanceSummary & {
      studentName: string
      rollNumber: string
      admissionNumber: string
    }>
  }> {
    const whereClause: Prisma.StudentAcademicYearWhereInput = {
      academicYearId,
    }

    if (classLevel) {
      whereClause.classLevel = classLevel
    }

    if (classDivisionId) {
      whereClause.classDivisionId = classDivisionId
    }

    const students = await this.prisma.studentAcademicYear.findMany({
      where: whereClause,
      include: {
        student: {
          include: {
            user: {
              select: {
                firstName: true,
                lastName: true,
              },
            },
          },
        },
      },
      orderBy: [
        { classLevel: 'asc' },
        { rollNumber: 'asc' },
      ],
    })

    const summaryPromises = students.map(async (studentRecord) => {
      const summary = await this.getAttendanceSummary(
        studentRecord.studentId,
        academicYearId,
      )

      return {
        ...summary.data!,
        studentName: `${studentRecord.student.user.firstName} ${studentRecord.student.user.lastName}`,
        rollNumber: studentRecord.rollNumber,
        admissionNumber: studentRecord.student.admissionNumber,
      }
    })

    const summaries = await Promise.all(summaryPromises)

    return {
      success: true,
      data: summaries.filter(s => s.studentId), // Filter out null summaries
    }
  }

  /**
   * Update attendance summary for a student's academic year record
   */
  private async updateAttendanceSummary(
    studentAcademicYearId: number,
  ): Promise<void> {
    // Get attendance statistics for this academic year
    const stats = await this.prisma.attendance.groupBy({
      by: ['status'],
      where: {
        studentAcademicYearId,
      },
      _count: {
        id: true,
      },
    })

    let totalDays = 0
    let presentDays = 0

    stats.forEach((stat) => {
      totalDays += stat._count.id
      if (stat.status === 'PRESENT' || stat.status === 'LATE') {
        presentDays += stat._count.id
      }
    })

    const attendancePercentage = totalDays > 0 ? (presentDays / totalDays) * 100 : 0

    // Update the StudentAcademicYear record
    await this.prisma.studentAcademicYear.update({
      where: { id: studentAcademicYearId },
      data: {
        totalWorkingDays: totalDays,
        totalDaysPresent: presentDays,
        attendancePercentage,
      },
    })
  }

  /**
   * Bulk record attendance for multiple students
   */
  async bulkRecordAttendance(data: {
    date: Date
    attendanceType?: AttendanceType
    sectionId?: number
    markedBy: number
    records: Array<{
      studentId: number
      status: AttendanceStatus
      remarks?: string
    }>
  }): Promise<{
    success: boolean
    data: {
      recorded: number
      failed: Array<{ studentId: number; error: string }>
    }
    message: string
  }> {
    const recorded: number[] = []
    const failed: Array<{ studentId: number; error: string }> = []

    for (const record of data.records) {
      try {
        await this.recordAttendance({
          studentId: record.studentId,
          date: data.date,
          status: record.status,
          attendanceType: data.attendanceType,
          sectionId: data.sectionId,
          remarks: record.remarks,
          markedBy: data.markedBy,
        })
        recorded.push(record.studentId)
      } catch (error) {
        failed.push({
          studentId: record.studentId,
          error: error.message,
        })
      }
    }

    return {
      success: true,
      data: {
        recorded: recorded.length,
        failed,
      },
      message: `Bulk attendance recorded. ${recorded.length} successful, ${failed.length} failed.`,
    }
  }

  /**
   * Get attendance trends for a student across academic years
   */
  async getAttendanceTrends(
    studentId: number,
    startAcademicYear?: number,
    endAcademicYear?: number,
  ): Promise<{
    success: boolean
    data: Array<{
      academicYearId: number
      yearName: string
      classLevel: number
      attendancePercentage: number
      totalDays: number
      presentDays: number
    }>
  }> {
    const whereClause: Prisma.StudentAcademicYearWhereInput = {
      studentId,
    }

    if (startAcademicYear || endAcademicYear) {
      whereClause.academicYearId = {}
      if (startAcademicYear) {
        whereClause.academicYearId.gte = startAcademicYear
      }
      if (endAcademicYear) {
        whereClause.academicYearId.lte = endAcademicYear
      }
    }

    const records = await this.prisma.studentAcademicYear.findMany({
      where: whereClause,
      include: {
        academicYear: {
          select: {
            yearName: true,
          },
        },
      },
      orderBy: {
        academicYear: { startDate: 'asc' },
      },
    })

    const trends = records.map((record) => ({
      academicYearId: record.academicYearId,
      yearName: record.academicYear.yearName,
      classLevel: record.classLevel,
      attendancePercentage: record.attendancePercentage
        ? parseFloat(record.attendancePercentage.toString())
        : 0,
      totalDays: record.totalWorkingDays || 0,
      presentDays: record.totalDaysPresent || 0,
    }))

    return {
      success: true,
      data: trends,
    }
  }
}