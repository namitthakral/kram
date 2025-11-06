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
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { CreateAssignmentDto, UpdateAssignmentDto } from './dto/assignment.dto'
import {
  CreateExaminationDto,
  UpdateExaminationDto,
} from './dto/examination.dto'
import {
  AssignSubjectsDto,
  CreateTeacherDto,
  TeacherQueryDto,
  UpdateTeacherDto,
} from './dto/teacher.dto'
import { TeachersService } from './teachers.service'

@Controller('teachers')
@UseGuards(JwtAuthGuard)
export class TeachersController {
  constructor(private readonly teachersService: TeachersService) {}

  @Post()
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  create(@Body() createTeacherDto: CreateTeacherDto) {
    return this.teachersService.create(createTeacherDto)
  }

  @Get()
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  findAll(@Query() query: TeacherQueryDto) {
    return this.teachersService.findAll(query)
  }

  @Get('stats')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  getStats() {
    // This would return overall teacher statistics
    return { message: 'Teacher stats endpoint - to be implemented' }
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

  @Get(':user_uuid/stats')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getTeacherStats(@Param('user_uuid') userUuid: string) {
    return this.teachersService.getTeacherStatsByUuid(userUuid)
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

  @Get(':user_uuid/attendance-summary')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getAttendanceSummary(
    @Param('user_uuid') userUuid: string,
    @Query('date') date?: string,
    @Query('period') period?: 'daily' | 'weekly' | 'monthly'
  ) {
    return this.teachersService.getAttendanceSummaryByUuid(
      userUuid,
      date,
      period
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
}
