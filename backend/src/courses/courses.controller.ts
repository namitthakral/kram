import {
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Query,
  UseGuards,
} from '@nestjs/common'
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { CoursesService } from './courses.service'
import {
  CourseQueryDto,
  CoursesWithSectionsQueryDto,
} from './dto/course-query.dto'

@Controller('courses')
@UseGuards(JwtAuthGuard, RolesGuard)
export class CoursesController {
  constructor(private readonly coursesService: CoursesService) {}

  /**
   * Get all courses/programs
   * Query params: institutionId, status, degreeType
   */
  @Get()
  @Roles('super_admin', 'admin', 'teacher')
  async findAll(@Query() query: CourseQueryDto) {
    return this.coursesService.findAll({
      institutionId: query.institutionId,
      status: query.status,
      degreeType: query.degreeType,
    })
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
  async getCoursesWithSections(@Query() query: CoursesWithSectionsQueryDto) {
    return this.coursesService.getCoursesWithSections(query.institutionId)
  }

  /**
   * Get a single course by ID with its subjects
   */
  @Get(':id')
  @Roles('super_admin', 'admin', 'teacher', 'student')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.coursesService.findOne(id)
  }

  /**
   * Get sections for a specific course
   * Returns detailed breakdown by section with student counts
   */
  @Get(':id/sections')
  @Roles('super_admin', 'admin', 'teacher')
  async getCourseSections(@Param('id', ParseIntPipe) id: number) {
    return this.coursesService.getCourseSections(id)
  }
}
