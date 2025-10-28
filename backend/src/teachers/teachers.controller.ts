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

  @Get(':uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  findByUuid(@Param('uuid') uuid: string) {
    return this.teachersService.findByUuid(uuid)
  }

  @Get(':uuid/subjects')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getTeacherSubjects(
    @Param('uuid') uuid: string,
    @Query('academicYearId') academicYearId?: string
  ) {
    const parsedAcademicYearId = academicYearId
      ? parseInt(academicYearId, 10)
      : undefined
    return this.teachersService.getTeacherSubjectsByUuid(
      uuid,
      parsedAcademicYearId
    )
  }

  @Get(':uuid/classes')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getTeacherClasses(
    @Param('uuid') uuid: string,
    @Query('semesterId') semesterId?: string
  ) {
    const parsedSemesterId = semesterId ? parseInt(semesterId, 10) : undefined
    return this.teachersService.getTeacherClassesByUuid(uuid, parsedSemesterId)
  }

  @Get(':uuid/stats')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getTeacherStats(@Param('uuid') uuid: string) {
    return this.teachersService.getTeacherStatsByUuid(uuid)
  }

  @Get(':uuid/dashboard-stats')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getDashboardStats(@Param('uuid') uuid: string) {
    return this.teachersService.getEnhancedDashboardStatsByUuid(uuid)
  }

  @Get(':uuid/attendance-trends')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getAttendanceTrends(@Param('uuid') uuid: string) {
    return this.teachersService.getAttendanceTrendsByUuid(uuid)
  }

  @Get(':uuid/subject-performance')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getSubjectPerformance(@Param('uuid') uuid: string) {
    return this.teachersService.getSubjectPerformanceDataByUuid(uuid)
  }

  @Get(':uuid/grade-distribution')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getGradeDistribution(@Param('uuid') uuid: string) {
    return this.teachersService.getGradeDistributionDataByUuid(uuid)
  }

  @Get(':uuid/recent-activity')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getRecentStudentActivity(
    @Param('uuid') uuid: string,
    @Query('limit') limit?: string
  ) {
    const parsedLimit = limit ? parseInt(limit, 10) : 10
    return this.teachersService.getRecentStudentActivityByUuid(
      uuid,
      parsedLimit
    )
  }

  @Get(':uuid/attendance-summary')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getAttendanceSummary(
    @Param('uuid') uuid: string,
    @Query('date') date?: string,
    @Query('period') period?: 'daily' | 'weekly' | 'monthly'
  ) {
    return this.teachersService.getAttendanceSummaryByUuid(uuid, date, period)
  }

  @Patch(':uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  update(
    @Param('uuid') uuid: string,
    @Body() updateTeacherDto: UpdateTeacherDto
  ) {
    return this.teachersService.updateByUuid(uuid, updateTeacherDto)
  }

  @Post(':uuid/assign-subjects')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  assignSubjects(
    @Param('uuid') uuid: string,
    @Body() assignSubjectsDto: AssignSubjectsDto
  ) {
    return this.teachersService.assignSubjectsByUuid(uuid, assignSubjectsDto)
  }

  @Delete(':uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('uuid') uuid: string) {
    return this.teachersService.removeByUuid(uuid)
  }
}
