import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common'
import { CurrentUser } from '../../auth/decorators/current-user.decorator'
import { Roles } from '../../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../../auth/guards/roles.guard'
import { UserWithRelations } from '../../types/auth.types'
import { AttendanceService } from '../services/attendance.service'
import { StudentsService } from '../students.service'
import {
  RecordAttendanceDto,
  BulkAttendanceDto,
  AttendanceQueryDto,
} from '../dto/attendance.dto'

@Controller('students/attendance')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AttendanceController {
  constructor(
    private readonly attendanceService: AttendanceService,
    private readonly studentsService: StudentsService,
  ) {}

  // ============================================================================
  // ATTENDANCE RECORDING
  // ============================================================================

  /**
   * Record attendance for a single student
   * POST /students/attendance/record
   */
  @Post('record')
  @Roles('super_admin', 'admin', 'teacher')
  async recordAttendance(
    @Body() attendanceDto: RecordAttendanceDto,
    @CurrentUser() user: UserWithRelations,
  ) {
    return this.studentsService.recordAttendance(
      {
        studentId: attendanceDto.studentId,
        date: new Date(attendanceDto.date),
        status: attendanceDto.status,
        attendanceType: attendanceDto.attendanceType,
        sectionId: attendanceDto.sectionId,
        remarks: attendanceDto.remarks,
      },
      user,
    )
  }

  /**
   * Record attendance for multiple students at once
   * POST /students/attendance/bulk-record
   */
  @Post('bulk-record')
  @Roles('super_admin', 'admin', 'teacher')
  async bulkRecordAttendance(
    @Body() bulkAttendanceDto: BulkAttendanceDto,
    @CurrentUser() user: UserWithRelations,
  ) {
    // Determine who is marking the attendance based on role
    const markedBy = user.teacher?.id || user.id // Use teacher ID or fallback to user ID for admin/super_admin

    return this.attendanceService.bulkRecordAttendance({
      date: new Date(bulkAttendanceDto.date),
      attendanceType: bulkAttendanceDto.attendanceType,
      sectionId: bulkAttendanceDto.sectionId,
      markedBy,
      records: bulkAttendanceDto.records,
    })
  }

  // ============================================================================
  // ATTENDANCE QUERIES
  // ============================================================================

  /**
   * Get attendance records with filtering
   * GET /students/attendance/records
   */
  @Get('records')
  @Roles('super_admin', 'admin', 'teacher')
  async getAttendanceRecords(
    @Query() query: AttendanceQueryDto,
  ) {
    const options = {
      studentId: query.studentId,
      academicYearId: query.academicYearId,
      classLevel: query.classLevel,
      sectionId: query.sectionId,
      attendanceType: query.attendanceType,
      startDate: query.startDate ? new Date(query.startDate) : undefined,
      endDate: query.endDate ? new Date(query.endDate) : undefined,
      status: query.status,
      limit: query.limit || 50,
      offset: query.offset || 0,
    }

    return this.attendanceService.getAttendanceRecords(options)
  }

  /**
   * Get attendance summary for a specific student
   * GET /students/attendance/student/:studentId/summary
   */
  @Get('student/:studentId/summary')
  @Roles('super_admin', 'admin', 'teacher', 'student', 'parent')
  async getStudentAttendanceSummary(
    @Param('studentId', ParseIntPipe) studentId: number,
    @CurrentUser() user: UserWithRelations,
    @Query('academicYearId') academicYearId?: string,
  ) {
    return this.studentsService.getAttendanceSummary(
      studentId,
      academicYearId ? parseInt(academicYearId) : undefined,
      user,
    )
  }

  /**
   * Get attendance trends for a student across academic years
   * GET /students/attendance/student/:studentId/trends
   */
  @Get('student/:studentId/trends')
  @Roles('super_admin', 'admin', 'teacher', 'student', 'parent')
  async getStudentAttendanceTrends(
    @Param('studentId', ParseIntPipe) studentId: number,
    @CurrentUser() user: UserWithRelations,
    @Query('startAcademicYear') startAcademicYear?: string,
    @Query('endAcademicYear') endAcademicYear?: string,
  ) {
    return this.studentsService.getAttendanceTrends(
      studentId,
      startAcademicYear ? parseInt(startAcademicYear) : undefined,
      endAcademicYear ? parseInt(endAcademicYear) : undefined,
      user,
    )
  }

  // ============================================================================
  // CLASS ATTENDANCE MANAGEMENT
  // ============================================================================

  /**
   * Get attendance summary for an entire class
   * GET /students/attendance/class/summary
   */
  @Get('class/summary')
  @Roles('super_admin', 'admin', 'teacher')
  async getClassAttendanceSummary(
    @Query('academicYearId') academicYearId: string,
    @Query('classLevel') classLevel?: string,
    @Query('classDivisionId') classDivisionId?: string,
  ) {
    if (!academicYearId) {
      return {
        success: false,
        message: 'Academic year ID is required',
      }
    }

    return this.attendanceService.getClassAttendanceSummary(
      parseInt(academicYearId),
      classLevel ? parseInt(classLevel) : undefined,
      classDivisionId ? parseInt(classDivisionId) : undefined,
    )
  }

  /**
   * Get attendance records for a specific date and class
   * GET /students/attendance/class/date/:date
   */
  @Get('class/date/:date')
  @Roles('super_admin', 'admin', 'teacher')
  async getClassAttendanceByDate(
    @Param('date') date: string,
    @Query('academicYearId') academicYearId?: string,
    @Query('classLevel') classLevel?: string,
    @Query('classDivisionId') classDivisionId?: string,
    @Query('sectionId') sectionId?: string,
  ) {
    const options = {
      startDate: new Date(date),
      endDate: new Date(date),
      academicYearId: academicYearId ? parseInt(academicYearId) : undefined,
      classLevel: classLevel ? parseInt(classLevel) : undefined,
      sectionId: sectionId ? parseInt(sectionId) : undefined,
      limit: 1000, // High limit for class attendance
    }

    return this.attendanceService.getAttendanceRecords(options)
  }

  // ============================================================================
  // ATTENDANCE ANALYTICS
  // ============================================================================

  /**
   * Get attendance statistics for an academic year
   * GET /students/attendance/academic-year/:academicYearId/stats
   */
  @Get('academic-year/:academicYearId/stats')
  @Roles('super_admin', 'admin', 'teacher')
  async getAcademicYearAttendanceStats(
    @Param('academicYearId', ParseIntPipe) academicYearId: number,
    @Query('classLevel') classLevel?: string,
    @Query('classDivisionId') classDivisionId?: string,
  ) {
    // Get class attendance summary
    const summaryResult = await this.attendanceService.getClassAttendanceSummary(
      academicYearId,
      classLevel ? parseInt(classLevel) : undefined,
      classDivisionId ? parseInt(classDivisionId) : undefined,
    )

    if (!summaryResult.success) {
      return summaryResult
    }

    const attendanceData = summaryResult.data
    const totalStudents = attendanceData.length

    if (totalStudents === 0) {
      return {
        success: true,
        data: {
          academicYearId,
          totalStudents: 0,
          averageAttendance: 0,
          attendanceDistribution: {},
          lowAttendanceStudents: [],
        },
      }
    }

    // Calculate statistics
    const totalAttendancePercentage = attendanceData.reduce(
      (sum, student) => sum + student.attendancePercentage,
      0,
    )
    const averageAttendance = totalAttendancePercentage / totalStudents

    // Attendance distribution
    const attendanceRanges = {
      excellent: attendanceData.filter(s => s.attendancePercentage >= 90).length, // 90%+
      good: attendanceData.filter(s => s.attendancePercentage >= 75 && s.attendancePercentage < 90).length, // 75-89%
      satisfactory: attendanceData.filter(s => s.attendancePercentage >= 60 && s.attendancePercentage < 75).length, // 60-74%
      poor: attendanceData.filter(s => s.attendancePercentage < 60).length, // <60%
    }

    // Students with low attendance (below 75%)
    const lowAttendanceStudents = attendanceData
      .filter(student => student.attendancePercentage < 75)
      .sort((a, b) => a.attendancePercentage - b.attendancePercentage)
      .slice(0, 20) // Top 20 students with lowest attendance

    return {
      success: true,
      data: {
        academicYearId,
        classLevel: classLevel ? parseInt(classLevel) : null,
        classDivisionId: classDivisionId ? parseInt(classDivisionId) : null,
        totalStudents,
        averageAttendance: Math.round(averageAttendance * 100) / 100,
        attendanceDistribution: {
          excellent: { count: attendanceRanges.excellent, percentage: Math.round((attendanceRanges.excellent / totalStudents) * 100) },
          good: { count: attendanceRanges.good, percentage: Math.round((attendanceRanges.good / totalStudents) * 100) },
          satisfactory: { count: attendanceRanges.satisfactory, percentage: Math.round((attendanceRanges.satisfactory / totalStudents) * 100) },
          poor: { count: attendanceRanges.poor, percentage: Math.round((attendanceRanges.poor / totalStudents) * 100) },
        },
        lowAttendanceStudents,
        generatedAt: new Date().toISOString(),
      },
    }
  }
}