import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Post,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common'
import { CurrentUser } from '../auth/decorators/current-user.decorator'
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { UserWithRelations } from '../types/auth.types'
import { CoursesService } from './courses.service'
import {
  CourseQueryDto,
  CoursesWithSectionsQueryDto,
} from './dto/course-query.dto'
import { CreateCourseDto } from './dto/create-course.dto'
import { UpdateCourseDto } from './dto/update-course.dto'
import { CourseAttendanceDto } from './dto/course-attendance.dto'

@Controller('courses')
@UseGuards(JwtAuthGuard, RolesGuard)
export class CoursesController {
  constructor(private readonly coursesService: CoursesService) {}

  private resolveInstitutionId(user: UserWithRelations): number | null {
    return (
      user.institutionId ??
      user.staff?.institutionId ??
      user.teacher?.institutionId ??
      user.student?.institutionId ??
      null
    )
  }

  /**
   * Get all courses/programs
   * Query params: institutionId, status, degreeType
   */
  @Get()
  @Roles('super_admin', 'admin', 'teacher')
  async findAll(
    @Query() query: CourseQueryDto,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.coursesService.findAll(
      {
        institutionId: query.institutionId,
        status: query.status,
        degreeType: query.degreeType,
      },
      institutionId
    )
  }

  /**
   * Get all courses with their sections (student groupings)
   * Returns courses with sections derived from enrolled students
   *
   * Example response:
   * {
   *   "courseId": 1,
   *   "courseName": "B.Sc. Computer Science",
   *   "sections": [
   *     { "sectionName": "A", "studentCount": 60, "classTeacher": "Dr. Sharma" },
   *     { "sectionName": "B", "studentCount": 55, "classTeacher": "Mr. Kumar" }
   *   ]
   * }
   */
  @Get('with-sections')
  @Roles('super_admin', 'admin', 'teacher')
  async getCoursesWithSections(
    @Query() query: CoursesWithSectionsQueryDto,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId =
      this.resolveInstitutionId(user) ?? query.institutionId ?? null
    return this.coursesService.getCoursesWithSections(institutionId)
  }

  /**
   * Get a single course by ID with its subjects
   */
  @Get(':id')
  @Roles('super_admin', 'admin', 'teacher', 'student')
  async findOne(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.coursesService.findOne(id, institutionId)
  }

  /**
   * Get students enrolled in a specific course section
   * 
   * @param courseId - The course ID
   * @param sectionName - The section name (e.g., 'A', 'B')
   */
  @Get(':courseId/sections/:sectionName/students')
  @Roles('super_admin', 'admin', 'teacher')
  async getCourseSectionStudents(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('sectionName') sectionName: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.coursesService.getCourseStudents(courseId, sectionName)
  }

  /**
   * Get sections for a specific course
   * Returns detailed breakdown by section with student counts
   */
  @Get(':id/sections')
  @Roles('super_admin', 'admin', 'teacher')
  async getCourseSections(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    await this.coursesService.findOne(id, institutionId)
    return this.coursesService.getCourseSections(id)
  }

  /**
   * Create a new course
   */
  @Post()
  @Roles('super_admin', 'admin')
  async create(
    @Body() createCourseDto: CreateCourseDto,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.coursesService.createCourse(createCourseDto, institutionId)
  }

  /**
   * Update an existing course
   */
  @Put(':id')
  @Roles('super_admin', 'admin')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateCourseDto: UpdateCourseDto,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.coursesService.updateCourse(id, updateCourseDto, institutionId)
  }

  /**
   * Delete a course (soft delete)
   */
  @Delete(':id')
  @Roles('super_admin', 'admin')
  @HttpCode(HttpStatus.OK)
  async remove(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.coursesService.deleteCourse(id, institutionId)
  }

  /**
   * Get all students in a course (across all sections)
   * GET /courses/:courseId/students
   */
  @Get(':courseId/students')
  @Roles('super_admin', 'admin', 'teacher')
  async getAllCourseStudents(
    @Param('courseId', ParseIntPipe) courseId: number,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = await this.resolveInstitutionId(user)
    return this.coursesService.getAllCourseStudents(courseId, institutionId)
  }

  /**
   * Mark attendance for a course section (School Mode)
   * POST /courses/:courseId/sections/:sectionName/attendance
   */
  @Post(':courseId/sections/:sectionName/attendance')
  @Roles('super_admin', 'admin', 'teacher')
  @HttpCode(HttpStatus.CREATED)
  async markCourseAttendance(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('sectionName') sectionName: string,
    @Body() attendanceDto: CourseAttendanceDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.coursesService.markCourseAttendance(
      courseId,
      sectionName,
      attendanceDto,
      user
    )
  }
}
