import { Controller, Get, Query, UseGuards } from '@nestjs/common'
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { CoursesService } from './courses.service'
import { ClassSectionQueryDto } from './dto/class-section.dto'

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

  /**
   * Get all class sections
   *
   * Query params:
   * - institutionId: Filter by institution
   * - semesterId: Filter by semester
   * - courseId: Filter by course/program
   * - teacherId: Filter by teacher
   * - status: Filter by status (ACTIVE, INACTIVE)
   *
   * Example response:
   * {
   *   "id": 1,
   *   "sectionName": "A",
   *   "maxCapacity": 60,
   *   "currentEnrollment": 55,
   *   "subject": { "name": "Data Structures", "code": "CS201" },
   *   "course": { "name": "B.Sc. Computer Science" },
   *   "semester": { "name": "Semester 3" },
   *   "teacher": { "name": "Dr. Sharma" }
   * }
   */
  @Get()
  @Roles('super_admin', 'admin', 'teacher')
  async findAll(@Query() query: ClassSectionQueryDto) {
    return this.coursesService.getClassSections({
      institutionId: query.institutionId,
      semesterId: query.semesterId,
      courseId: query.courseId,
      teacherId: query.teacherId,
      status: query.status,
    })
  }
}
