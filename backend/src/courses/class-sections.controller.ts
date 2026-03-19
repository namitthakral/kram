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
  UseGuards 
} from '@nestjs/common'
import { CurrentUser } from '../auth/decorators/current-user.decorator'
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { UserWithRelations } from '../types/auth.types'
import { CoursesService, ClassSectionDetailedResult } from './courses.service'
import { ClassSectionQueryDto } from './dto/class-section.dto'
import { CreateClassSectionDto } from './dto/create-class-section.dto'
import { UpdateClassSectionDto } from './dto/update-class-section.dto'

/**
 * Class Sections Controller
 *
 * Manages subject-based class sections (ClassSection model).
 * These are sections for specific subjects in a semester,
 * assigned to a teacher with capacity and schedule.
 *
 * Example: "Data Structures - Section A" with Teacher Dr. Sharma
 */
@Controller('class-sections')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ClassSectionsController {
  constructor(private readonly coursesService: CoursesService) {}

  private async resolveInstitutionId(user: UserWithRelations): Promise<number | null> {
    let id = (
      user.institutionId ??
      user.staff?.institutionId ??
      user.teacher?.institutionId ??
      user.student?.institutionId ??
      null
    )

    // Fallback for admins who don't have an institutionId set
    if (
      id == null &&
      (user.role?.roleName === 'super_admin' || user.role?.roleName === 'admin')
    ) {
      // For admin users without institutionId, use the first institution as fallback
      // This handles legacy admin accounts that weren't created with institutionId
      const firstInstitution = await this.coursesService.getFirstInstitution()
      id = firstInstitution?.id ?? null
    }

    return id
  }

  /**
   * Get all class sections - OPTIMIZED VERSION
   *
   * Query params:
   * - institutionId: Filter by institution
   * - semesterId: Filter by semester
   * - courseId: Filter by course/program
   * - teacherId: Filter by teacher
   * - status: Filter by status (ACTIVE, INACTIVE)
   *
   * Performance optimized with single database query using view
   * Target execution time: < 100ms
   *
   * Example response:
   * {
   *   "success": true,
   *   "data": [{
   *     "id": 1,
   *     "sectionName": "A",
   *     "maxCapacity": 60,
   *     "currentEnrollment": 55,
   *     "subject": { "name": "Data Structures", "code": "CS201" },
   *     "course": { "name": "B.Sc. Computer Science" },
   *     "semester": { "name": "Semester 3" },
   *     "teacher": { "name": "Dr. Sharma" },
   *     "academicYear": { "name": "2024-25" },
   *     "institution": { "name": "ABC College" }
   *   }],
   *   "count": 25,
   *   "executionTime": 45
   * }
   */
  @Get()
  @Roles('super_admin', 'admin', 'teacher')
  async findAll(
    @Query() query: ClassSectionQueryDto,
    @CurrentUser() user: UserWithRelations
  ): Promise<{
    success: boolean
    data: ClassSectionDetailedResult[]
    count: number
    executionTime: number
  }> {
    const institutionId = await this.resolveInstitutionId(user)
    return this.coursesService.getClassSectionsOptimized(
      {
        institutionId: query.institutionId,
        semesterId: query.semesterId,
        courseId: query.courseId,
        teacherId: query.teacherId,
        status: query.status,
      },
      institutionId
    )
  }

  /**
   * Get students enrolled in a specific class section
   *
   * Returns only students who are enrolled in the subject taught by this section
   * This is useful for marking attendance, as only enrolled students can be marked
   *
   * @param sectionId - The ClassSection ID
   * @returns List of enrolled students with their details
   */
  @Get(':sectionId/students')
  @Roles('super_admin', 'admin', 'teacher')
  async getEnrolledStudents(@Param('sectionId') sectionId: string) {
    return this.coursesService.getClassSectionStudents(parseInt(sectionId, 10))
  }

  /**
   * Get attendance records for a specific class section and date
   *
   * Returns attendance records for all students in the section on the specified date
   *
   * @param sectionId - The ClassSection ID
   * @param date - Date in YYYY-MM-DD format (query parameter)
   * @returns List of attendance records with student details
   */
  @Get(':sectionId/attendance')
  @Roles('super_admin', 'admin', 'teacher')
  async getAttendanceByDate(
    @Param('sectionId') sectionId: string,
    @Query('date') date: string,
  ) {
    return this.coursesService.getClassSectionAttendance(
      parseInt(sectionId, 10),
      date,
    )
  }

  /**
   * Create a new class section
   */
  @Post()
  @Roles('super_admin', 'admin')
  async create(
    @Body() createClassSectionDto: CreateClassSectionDto,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = await this.resolveInstitutionId(user)
    return this.coursesService.createClassSection(createClassSectionDto, institutionId)
  }

  /**
   * Update an existing class section
   */
  @Put(':id')
  @Roles('super_admin', 'admin')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateClassSectionDto: UpdateClassSectionDto,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = await this.resolveInstitutionId(user)
    return this.coursesService.updateClassSection(id, updateClassSectionDto, institutionId)
  }

  /**
   * Delete a class section (soft delete)
   */
  @Delete(':id')
  @Roles('super_admin', 'admin')
  @HttpCode(HttpStatus.OK)
  async remove(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = await this.resolveInstitutionId(user)
    return this.coursesService.deleteClassSection(id, institutionId)
  }
}
