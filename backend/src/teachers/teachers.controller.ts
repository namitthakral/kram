import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common'
import { CurrentUser } from '../auth/decorators/current-user.decorator'
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { CreateAssignmentDto, UpdateAssignmentDto } from './dto/assignment.dto'
import {
  AttendanceQueryDto,
  BulkMarkAttendanceDto,
  MarkAttendanceDto,
  UpdateAttendanceDto,
} from './dto/attendance.dto'
import {
  BulkEnterExamResultDto,
  EnterExamResultDto,
  UpdateExamResultDto,
} from './dto/exam-result.dto'
import {
  CreateExaminationDto,
  UpdateExaminationDto,
} from './dto/examination.dto'
import {
  AssignSubjectsDto,
  BatchReportCardDto,
  TeacherQueryDto,
  UpdateTeacherDto,
} from './dto/teacher.dto'
import { UserWithRelations } from '../types/auth.types'
import { TeachersService } from './teachers.service'

@Controller('teachers')
@UseGuards(JwtAuthGuard)
export class TeachersController {
  constructor(private readonly teachersService: TeachersService) { }

  // NOTE: POST /teachers has been removed. Use POST /users with roleId=teacher instead.
  // This unified approach handles Kram ID generation and profile creation in one step.

  @Get()
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  findAll(@Query() query: TeacherQueryDto, @CurrentUser() user: UserWithRelations) {
    const institutionId = this.resolveInstitutionId(user)
    return this.teachersService.findAll(query, institutionId)
  }

  @Get(':user_uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  findByUuid(@Param('user_uuid') userUuid: string) {
    return this.teachersService.findByUuid(userUuid)
  }

  @Get(':user_uuid/subjects')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getTeacherSubjects(
    @Param('user_uuid') userUuid: string,
    @Query('academicYearId') academicYearId?: string
  ) {
    const parsedAcademicYearId = academicYearId
      ? parseInt(academicYearId, 10)
      : undefined
    return this.teachersService.getTeacherSubjectsByUuid(
      userUuid,
      parsedAcademicYearId
    )
  }

  @Get(':user_uuid/classes')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getTeacherClasses(
    @Param('user_uuid') userUuid: string,
    @Query('semesterId') semesterId?: string
  ) {
    const parsedSemesterId = semesterId ? parseInt(semesterId, 10) : undefined
    return this.teachersService.getTeacherClassesByUuid(
      userUuid,
      parsedSemesterId
    )
  }

  @Get(':user_uuid/semesters/active')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getActiveSemesters(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations,
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.teachersService.getActiveSemesters(institutionId)
  }

  @Get(':user_uuid/dashboard-stats')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getDashboardStats(@Param('user_uuid') userUuid: string) {
    return this.teachersService.getEnhancedDashboardStatsByUuid(userUuid)
  }

  @Get(':user_uuid/attendance-trends')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getAttendanceTrends(@Param('user_uuid') userUuid: string) {
    return this.teachersService.getAttendanceTrendsByUuid(userUuid)
  }

  @Get(':user_uuid/subject-performance')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getSubjectPerformance(@Param('user_uuid') userUuid: string) {
    return this.teachersService.getSubjectPerformanceDataByUuid(userUuid)
  }

  @Get(':user_uuid/grade-distribution')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getGradeDistribution(@Param('user_uuid') userUuid: string) {
    return this.teachersService.getGradeDistributionDataByUuid(userUuid)
  }

  @Get(':user_uuid/recent-activity')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getRecentStudentActivity(
    @Param('user_uuid') userUuid: string,
    @Query('limit') limit?: string
  ) {
    const parsedLimit = limit ? parseInt(limit, 10) : 10
    return this.teachersService.getRecentStudentActivityByUuid(
      userUuid,
      parsedLimit
    )
  }

  @Patch(':user_uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  update(
    @Param('user_uuid') userUuid: string,
    @Body() updateTeacherDto: UpdateTeacherDto
  ) {
    return this.teachersService.updateByUuid(userUuid, updateTeacherDto)
  }

  @Post(':user_uuid/assign-subjects')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  assignSubjects(
    @Param('user_uuid') userUuid: string,
    @Body() assignSubjectsDto: AssignSubjectsDto
  ) {
    return this.teachersService.assignSubjectsByUuid(
      userUuid,
      assignSubjectsDto
    )
  }

  @Delete(':user_uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('user_uuid') userUuid: string) {
    return this.teachersService.removeByUuid(userUuid)
  }

  // ==================== Assignment Management ====================

  @Post(':user_uuid/assignments')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  createAssignment(
    @Param('user_uuid') userUuid: string,
    @Body() createAssignmentDto: CreateAssignmentDto
  ) {
    return this.teachersService.createAssignment(userUuid, createAssignmentDto)
  }

  @Get(':user_uuid/assignments')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  getTeacherAssignments(
    @Param('user_uuid') userUuid: string,
    @Query('status') status?: string,
    @Query('courseId') courseId?: string
  ) {
    const parsedCourseId = courseId ? parseInt(courseId, 10) : undefined
    return this.teachersService.getTeacherAssignments(
      userUuid,
      status,
      parsedCourseId
    )
  }

  @Get(':user_uuid/assignments/:assignmentId')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  getAssignmentById(
    @Param('user_uuid') userUuid: string,
    @Param('assignmentId') assignmentId: string
  ) {
    return this.teachersService.getAssignmentById(
      userUuid,
      parseInt(assignmentId, 10)
    )
  }

  @Patch(':user_uuid/assignments/:assignmentId')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  updateAssignment(
    @Param('user_uuid') userUuid: string,
    @Param('assignmentId') assignmentId: string,
    @Body() updateAssignmentDto: UpdateAssignmentDto
  ) {
    return this.teachersService.updateAssignment(
      userUuid,
      parseInt(assignmentId, 10),
      updateAssignmentDto
    )
  }

  @Delete(':user_uuid/assignments/:assignmentId')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  deleteAssignment(
    @Param('user_uuid') userUuid: string,
    @Param('assignmentId') assignmentId: string
  ) {
    return this.teachersService.deleteAssignment(
      userUuid,
      parseInt(assignmentId, 10)
    )
  }

  // ==================== Examination Management ====================

  @Post(':user_uuid/examinations')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  createExamination(
    @Param('user_uuid') userUuid: string,
    @Body() createExaminationDto: CreateExaminationDto
  ) {
    return this.teachersService.createExamination(
      userUuid,
      createExaminationDto
    )
  }

  @Get(':user_uuid/examinations')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  getTeacherExaminations(
    @Param('user_uuid') userUuid: string,
    @Query('status') status?: string,
    @Query('courseId') courseId?: string
  ) {
    const parsedCourseId = courseId ? parseInt(courseId, 10) : undefined
    return this.teachersService.getTeacherExaminations(
      userUuid,
      status,
      parsedCourseId
    )
  }

  @Get(':user_uuid/examinations/:examinationId')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  getExaminationById(
    @Param('user_uuid') userUuid: string,
    @Param('examinationId') examinationId: string
  ) {
    return this.teachersService.getExaminationById(
      userUuid,
      parseInt(examinationId, 10)
    )
  }

  @Patch(':user_uuid/examinations/:examinationId')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  updateExamination(
    @Param('user_uuid') userUuid: string,
    @Param('examinationId') examinationId: string,
    @Body() updateExaminationDto: UpdateExaminationDto
  ) {
    return this.teachersService.updateExamination(
      userUuid,
      parseInt(examinationId, 10),
      updateExaminationDto
    )
  }

  @Delete(':user_uuid/examinations/:examinationId')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  deleteExamination(
    @Param('user_uuid') userUuid: string,
    @Param('examinationId') examinationId: string
  ) {
    return this.teachersService.deleteExamination(
      userUuid,
      parseInt(examinationId, 10)
    )
  }

  // ==================== Phase 1: Actionable Insights ====================

  @Get(':user_uuid/submissions/pending')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  getPendingSubmissions(
    @Param('user_uuid') userUuid: string,
    @Query('limit') limit?: string
  ) {
    return this.teachersService.getPendingSubmissions(
      userUuid,
      parseInt(limit || '10', 10)
    )
  }

  @Get(':user_uuid/students/at-risk')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  getStudentsAtRisk(
    @Param('user_uuid') userUuid: string,
    @Query('limit') limit?: string
  ) {
    return this.teachersService.getStudentsAtRisk(
      userUuid,
      parseInt(limit || '20', 10)
    )
  }

  // ==================== Attendance Management ====================

  @Get(':user_uuid/attendance/records')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  getAttendanceRecords(
    @Param('user_uuid') userUuid: string,
    @Query() query: AttendanceQueryDto
  ) {
    return this.teachersService.getAttendanceRecords(userUuid, query)
  }

  @Post(':user_uuid/attendance')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  @HttpCode(HttpStatus.CREATED)
  markAttendance(
    @Param('user_uuid') userUuid: string,
    @Body() markAttendanceDto: MarkAttendanceDto
  ) {
    return this.teachersService.markAttendance(userUuid, markAttendanceDto)
  }

  @Post(':user_uuid/attendance/bulk')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  @HttpCode(HttpStatus.CREATED)
  bulkMarkAttendance(
    @Param('user_uuid') userUuid: string,
    @Body() bulkMarkAttendanceDto: BulkMarkAttendanceDto
  ) {
    return this.teachersService.bulkMarkAttendance(
      userUuid,
      bulkMarkAttendanceDto
    )
  }

  @Patch(':user_uuid/attendance/:attendanceId')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  updateAttendance(
    @Param('user_uuid') userUuid: string,
    @Param('attendanceId') attendanceId: string,
    @Body() updateAttendanceDto: UpdateAttendanceDto
  ) {
    return this.teachersService.updateAttendance(
      userUuid,
      parseInt(attendanceId, 10),
      updateAttendanceDto
    )
  }

  @Delete(':user_uuid/attendance/:attendanceId')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  @HttpCode(HttpStatus.OK)
  deleteAttendance(
    @Param('user_uuid') userUuid: string,
    @Param('attendanceId') attendanceId: string
  ) {
    return this.teachersService.deleteAttendance(
      userUuid,
      parseInt(attendanceId, 10)
    )
  }

  // ==================== Exam Result Management ====================

  @Post(':user_uuid/examinations/:examId/results')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  @HttpCode(HttpStatus.CREATED)
  enterExamResult(
    @Param('user_uuid') userUuid: string,
    @Param('examId') examId: string,
    @Body() enterExamResultDto: EnterExamResultDto
  ) {
    return this.teachersService.enterExamResult(
      userUuid,
      parseInt(examId, 10),
      enterExamResultDto
    )
  }

  @Post(':user_uuid/examinations/:examId/results/bulk')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  @HttpCode(HttpStatus.CREATED)
  bulkEnterExamResults(
    @Param('user_uuid') userUuid: string,
    @Param('examId') examId: string,
    @Body() bulkEnterExamResultDto: BulkEnterExamResultDto
  ) {
    return this.teachersService.bulkEnterExamResults(
      userUuid,
      parseInt(examId, 10),
      bulkEnterExamResultDto
    )
  }

  @Get(':user_uuid/examinations/:examId/results')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  getExamResults(
    @Param('user_uuid') userUuid: string,
    @Param('examId') examId: string
  ) {
    return this.teachersService.getExamResults(userUuid, parseInt(examId, 10))
  }

  @Patch(':user_uuid/examinations/:examId/results/:resultId')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  updateExamResult(
    @Param('user_uuid') userUuid: string,
    @Param('examId') examId: string,
    @Param('resultId') resultId: string,
    @Body() updateExamResultDto: UpdateExamResultDto
  ) {
    return this.teachersService.updateExamResult(
      userUuid,
      parseInt(examId, 10),
      parseInt(resultId, 10),
      updateExamResultDto
    )
  }

  @Delete(':user_uuid/examinations/:examId/results/:resultId')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  @HttpCode(HttpStatus.OK)
  deleteExamResult(
    @Param('user_uuid') userUuid: string,
    @Param('examId') examId: string,
    @Param('resultId') resultId: string
  ) {
    return this.teachersService.deleteExamResult(
      userUuid,
      parseInt(examId, 10),
      parseInt(resultId, 10)
    )
  }

  // ==================== Batch Report Card Generation ====================

  @Post(':user_uuid/report-cards/generate')
  @UseGuards(RolesGuard)
  @Roles('teacher', 'super_admin', 'admin')
  generateBatchReportCards(
    @Param('user_uuid') userUuid: string,
    @Body() batchReportCardDto: BatchReportCardDto,
  ) {
    return this.teachersService.generateBatchReportCards(userUuid, {
      sectionId: batchReportCardDto.sectionId,
      courseId: batchReportCardDto.courseId,
      semesterId: batchReportCardDto.semesterId,
      studentIds: batchReportCardDto.studentIds,
      includeExamDetails: batchReportCardDto.includeExamDetails,
    })
  }

  @Get(':user_uuid/institution-info')
  getInstitutionInfo(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations,
  ) {
    return this.teachersService.getInstitutionInfo(userUuid, user)
  }

  private resolveInstitutionId(user: UserWithRelations): number | null {
    return (
      user.institutionId ??
      user.staff?.institutionId ??
      user.teacher?.institutionId ??
      user.student?.institutionId ??
      null
    )
  }
}
