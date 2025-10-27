import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
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

  @Get(':id')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.teachersService.findOne(id)
  }

  @Get(':id/subjects')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getTeacherSubjects(
    @Param('id', ParseIntPipe) id: number,
    @Query('academicYearId') academicYearId?: string
  ) {
    const parsedAcademicYearId = academicYearId
      ? parseInt(academicYearId, 10)
      : undefined
    return this.teachersService.getTeacherSubjects(id, parsedAcademicYearId)
  }

  @Get(':id/classes')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getTeacherClasses(
    @Param('id', ParseIntPipe) id: number,
    @Query('semesterId') semesterId?: string
  ) {
    const parsedSemesterId = semesterId ? parseInt(semesterId, 10) : undefined
    return this.teachersService.getTeacherClasses(id, parsedSemesterId)
  }

  @Get(':id/stats')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getTeacherStats(@Param('id', ParseIntPipe) id: number) {
    return this.teachersService.getTeacherStats(id)
  }

  @Get(':id/dashboard-stats')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getDashboardStats(@Param('id', ParseIntPipe) id: number) {
    return this.teachersService.getDashboardStats(id)
  }

  @Get(':id/recent-activity')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getRecentStudentActivity(
    @Param('id', ParseIntPipe) id: number,
    @Query('limit') limit?: string
  ) {
    const parsedLimit = limit ? parseInt(limit, 10) : 10
    return this.teachersService.getRecentStudentActivity(id, parsedLimit)
  }

  @Get(':id/attendance-summary')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  getAttendanceSummary(
    @Param('id', ParseIntPipe) id: number,
    @Query('date') date?: string,
    @Query('period') period?: 'daily' | 'weekly' | 'monthly'
  ) {
    return this.teachersService.getAttendanceSummary(id, date, period)
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateTeacherDto: UpdateTeacherDto
  ) {
    return this.teachersService.update(id, updateTeacherDto)
  }

  @Post(':id/assign-subjects')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  assignSubjects(
    @Param('id', ParseIntPipe) id: number,
    @Body() assignSubjectsDto: AssignSubjectsDto
  ) {
    return this.teachersService.assignSubjects(id, assignSubjectsDto)
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.teachersService.remove(id)
  }
}
