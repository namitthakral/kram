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
}
