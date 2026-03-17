import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common'
import { CurrentUser } from '../auth/decorators/current-user.decorator'
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { UserWithRelations } from '../types/auth.types'
import {
  PaginationDto,
  ReportCardQueryDto,
  UpdateStudentDto,
} from './dto/student.dto'
import { StudentsService } from './students.service'

@Controller('students')
@UseGuards(JwtAuthGuard)
export class StudentsController {
  constructor(private readonly studentsService: StudentsService) {}

  @Get()
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  async findAll(
    @Query() paginationDto: PaginationDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.findAll(paginationDto, user)
  }

  @Get(':user_uuid')
  async findByUuid(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.findByUuid(userUuid, user)
  }

  // NOTE: POST /students has been removed. Use POST /users with roleId=student instead.
  // This unified approach handles Kram ID generation and profile creation in one step.

  @Patch(':user_uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  async update(
    @Param('user_uuid') userUuid: string,
    @Body() updateStudentDto: UpdateStudentDto
  ) {
    return this.studentsService.updateByUuid(userUuid, updateStudentDto)
  }

  @Delete(':user_uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  async remove(@Param('user_uuid') userUuid: string) {
    return this.studentsService.removeByUuid(userUuid)
  }

  @Get(':user_uuid/academic-records')
  async getAcademicRecords(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations,
    @Query('academicYearId') academicYearId?: string,
    @Query('semesterId') semesterId?: string
  ) {
    // First find the student by UUID
    const student = await this.studentsService.findByUuid(userUuid, user)
    if (!student.success) {
      return student
    }

    return this.studentsService.getAcademicRecords(
      student.data.id,
      user,
      academicYearId ? parseInt(academicYearId) : undefined,
      semesterId ? parseInt(semesterId) : undefined
    )
  }

  @Get(':user_uuid/attendance')
  async getAttendance(
    @Param('user_uuid') userUuid: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('academicYearId') academicYearId?: string,
    @CurrentUser() user?: UserWithRelations
  ) {
    return this.studentsService.getAttendanceByUuid(
      userUuid,
      startDate,
      endDate,
      user
    )
  }

  @Get(':user_uuid/dashboard-stats')
  async getDashboardStats(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.getDashboardStatsByUuid(userUuid, user)
  }

  @Get(':user_uuid/assignments')
  async getAssignments(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations,
    @Query('limit') limit?: string,
    @Query('status') status?: string
  ) {
    return this.studentsService.getAssignmentsByUuid(
      userUuid,
      parseInt(limit || '10'),
      status,
      user
    )
  }

  @Get(':user_uuid/performance-trends')
  async getPerformanceTrends(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations,
    @Query('startMonth') startMonth?: string,
    @Query('endMonth') endMonth?: string
  ) {
    return this.studentsService.getPerformanceTrendsByUuid(
      userUuid,
      startMonth,
      endMonth,
      user
    )
  }

  @Get(':user_uuid/attendance-history')
  async getAttendanceHistory(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations,
    @Query('semesterId') semesterId?: string
  ) {
    return this.studentsService.getAttendanceHistoryByUuid(
      userUuid,
      semesterId ? parseInt(semesterId) : undefined,
      user
    )
  }

  @Get(':user_uuid/subject-performance')
  async getSubjectPerformance(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.getSubjectPerformanceByUuid(userUuid, user)
  }

  @Get(':user_uuid/upcoming-events')
  async getUpcomingEvents(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations,
    @Query('limit') limit?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string
  ) {
    return this.studentsService.getUpcomingEventsByUuid(
      userUuid,
      parseInt(limit || '10'),
      startDate,
      endDate,
      user
    )
  }

  @Get(':user_uuid/examinations')
  async getExaminations(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations,
    @Query('status')
    status?: 'SCHEDULED' | 'ONGOING' | 'COMPLETED' | 'CANCELLED'
  ) {
    return this.studentsService.getExaminationsByUuid(userUuid, status, user)
  }

  @Get(':user_uuid/examinations/:examId/question-paper')
  async getPublishedQuestionPaper(
    @Param('user_uuid') userUuid: string,
    @Param('examId') examId: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.getPublishedQuestionPaperByUuid(
      userUuid,
      parseInt(examId),
      user
    )
  }

  // ==================== Report Card Generation ====================

  @Get(':user_uuid/report-card')
  async getReportCard(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations,
    @Query() queryDto: ReportCardQueryDto
  ) {
    return this.studentsService.generateReportCardByUuid(
      userUuid,
      {
        semesterId: queryDto.semesterId,
        academicYearId: queryDto.academicYearId,
        includeExamDetails: queryDto.includeExamDetails,
      },
      user
    )
  }

  // ==================== Academic Progression Endpoints ====================

  /**
   * Get academic history for a student by UUID
   * GET /students/:user_uuid/academic-history
   */
  @Get(':user_uuid/academic-history')
  async getAcademicHistory(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations
  ) {
    // First find the student by UUID
    const student = await this.studentsService.findByUuid(userUuid, user)
    if (!student.success) {
      return student
    }

    return this.studentsService.getAcademicHistory(student.data.id, user)
  }

  /**
   * Get current academic year for a student by UUID
   * GET /students/:user_uuid/current-academic-year
   */
  @Get(':user_uuid/current-academic-year')
  async getCurrentAcademicYear(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations
  ) {
    // First find the student by UUID
    const student = await this.studentsService.findByUuid(userUuid, user)
    if (!student.success) {
      return student
    }

    return this.studentsService.getCurrentAcademicYear(student.data.id, user)
  }

  /**
   * Get attendance summary for a student by UUID
   * GET /students/:user_uuid/attendance-summary
   */
  @Get(':user_uuid/attendance-summary')
  async getAttendanceSummary(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations,
    @Query('academicYearId') academicYearId?: string
  ) {
    // First find the student by UUID
    const student = await this.studentsService.findByUuid(userUuid, user)
    if (!student.success) {
      return student
    }

    return this.studentsService.getAttendanceSummary(
      student.data.id,
      academicYearId ? parseInt(academicYearId) : undefined,
      user
    )
  }

  /**
   * Get attendance trends for a student by UUID
   * GET /students/:user_uuid/attendance-trends
   */
  @Get(':user_uuid/attendance-trends')
  async getAttendanceTrends(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations,
    @Query('startAcademicYear') startAcademicYear?: string,
    @Query('endAcademicYear') endAcademicYear?: string
  ) {
    // First find the student by UUID
    const student = await this.studentsService.findByUuid(userUuid, user)
    if (!student.success) {
      return student
    }

    return this.studentsService.getAttendanceTrends(
      student.data.id,
      startAcademicYear ? parseInt(startAcademicYear) : undefined,
      endAcademicYear ? parseInt(endAcademicYear) : undefined,
      user
    )
  }

  // ==================== Student Search and Filtering ====================

  /**
   * Search students by academic year and class
   * GET /students/search/by-academic-year/:academicYearId
   */
  @Get('search/by-academic-year/:academicYearId')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher', 'staff')
  async searchByAcademicYear(
    @Param('academicYearId', ParseIntPipe) academicYearId: number,
    @CurrentUser() user: UserWithRelations,
    @Query('classLevel') classLevel?: string,
    @Query('classDivisionId') classDivisionId?: string
  ) {
    return this.studentsService.getStudentsByAcademicYear(
      academicYearId,
      classLevel ? parseInt(classLevel) : undefined,
      classDivisionId ? parseInt(classDivisionId) : undefined,
      user
    )
  }
}
