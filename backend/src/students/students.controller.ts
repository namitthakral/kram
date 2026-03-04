import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
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
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.getAcademicRecordsByUuid(userUuid, user)
  }

  @Get(':user_uuid/attendance')
  async getAttendance(
    @Param('user_uuid') userUuid: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
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
    @Query('status') status?: string
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
}
