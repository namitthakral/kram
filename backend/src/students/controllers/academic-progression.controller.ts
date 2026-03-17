import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common'
import { CurrentUser } from '../../auth/decorators/current-user.decorator'
import { Roles } from '../../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../../auth/guards/roles.guard'
import { UserWithRelations } from '../../types/auth.types'
import {
  BulkPromotionDto,
  CreateStudentAcademicYearDto,
  PromoteStudentDto,
  StudentAcademicHistoryQueryDto,
  UpdateStudentAcademicYearDto,
} from '../dto/academic-year.dto'
import { AcademicProgressionService } from '../services/academic-progression.service'
import { StudentsService } from '../students.service'

@Controller('students/academic-progression')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AcademicProgressionController {
  constructor(
    private readonly academicProgressionService: AcademicProgressionService,
    private readonly studentsService: StudentsService
  ) {}

  // ============================================================================
  // STUDENT ACADEMIC YEAR MANAGEMENT
  // ============================================================================

  /**
   * Create a new academic year record for a student
   * POST /students/academic-progression/enroll
   */
  @Post('enroll')
  @Roles('super_admin', 'admin')
  async enrollStudent(@Body() createDto: CreateStudentAcademicYearDto) {
    return this.academicProgressionService.createStudentAcademicYear(createDto)
  }

  /**
   * Update an existing academic year record
   * PUT /students/academic-progression/:id
   */
  @Put(':id')
  @Roles('super_admin', 'admin')
  async updateAcademicYear(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateStudentAcademicYearDto
  ) {
    return this.academicProgressionService.updateStudentAcademicYear(
      id,
      updateDto
    )
  }

  /**
   * Delete an academic year record
   * DELETE /students/academic-progression/:id
   */
  @Delete(':id')
  @Roles('super_admin', 'admin')
  async deleteAcademicYear(@Param('id', ParseIntPipe) _id: number) {
    // TODO: Implement soft delete in service
    return {
      success: true,
      message: 'Academic year record deletion not yet implemented',
    }
  }

  // ============================================================================
  // STUDENT ACADEMIC HISTORY
  // ============================================================================

  /**
   * Get academic history for a specific student
   * GET /students/academic-progression/student/:studentId/history
   */
  @Get('student/:studentId/history')
  @Roles('super_admin', 'admin', 'teacher', 'student', 'parent')
  async getStudentAcademicHistory(
    @Param('studentId', ParseIntPipe) studentId: number,
    @Query() query: StudentAcademicHistoryQueryDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.getAcademicHistory(studentId, user)
  }

  /**
   * Get current academic year for a student
   * GET /students/academic-progression/student/:studentId/current
   */
  @Get('student/:studentId/current')
  @Roles('super_admin', 'admin', 'teacher', 'student', 'parent')
  async getCurrentAcademicYear(
    @Param('studentId', ParseIntPipe) studentId: number,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.getCurrentAcademicYear(studentId, user)
  }

  // ============================================================================
  // STUDENT PROMOTIONS
  // ============================================================================

  /**
   * Promote a student to the next academic year
   * POST /students/academic-progression/student/:studentId/promote
   */
  @Post('student/:studentId/promote')
  @Roles('super_admin', 'admin', 'teacher')
  async promoteStudent(
    @Param('studentId', ParseIntPipe) studentId: number,
    @Body() promotionDto: PromoteStudentDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.promoteStudent(studentId, promotionDto, user)
  }

  /**
   * Bulk promote multiple students
   * POST /students/academic-progression/bulk-promote
   */
  @Post('bulk-promote')
  @Roles('super_admin', 'admin', 'teacher')
  async bulkPromoteStudents(@Body() bulkPromotionDto: BulkPromotionDto) {
    return this.academicProgressionService.bulkPromoteStudents(bulkPromotionDto)
  }

  // ============================================================================
  // ACADEMIC YEAR CLASS MANAGEMENT
  // ============================================================================

  /**
   * Get all students in a specific academic year and class
   * GET /students/academic-progression/academic-year/:academicYearId/students
   */
  @Get('academic-year/:academicYearId/students')
  @Roles('super_admin', 'admin', 'teacher')
  async getStudentsByAcademicYear(
    @Param('academicYearId', ParseIntPipe) academicYearId: number,
    @CurrentUser() user: UserWithRelations,
    @Query('classLevel') classLevel?: string,
    @Query('classDivisionId') classDivisionId?: string
  ) {
    return this.studentsService.getStudentsByAcademicYear(
      academicYearId,
      classLevel ? parseInt(classLevel) : undefined,
      classDivisionId ? parseInt(classDivisionId) : undefined,
      user
    )
  }

  /**
   * Get students eligible for promotion from a specific academic year
   * GET /students/academic-progression/academic-year/:academicYearId/promotion-eligible
   */
  @Get('academic-year/:academicYearId/promotion-eligible')
  @Roles('super_admin', 'admin', 'teacher')
  async getPromotionEligibleStudents(
    @Param('academicYearId', ParseIntPipe) academicYearId: number,
    @CurrentUser() user: UserWithRelations,
    @Query('classLevel') classLevel?: string,
    @Query('classDivisionId') classDivisionId?: string
  ) {
    // Get students with COMPLETED or IN_PROGRESS status
    const result = await this.studentsService.getStudentsByAcademicYear(
      academicYearId,
      classLevel ? parseInt(classLevel) : undefined,
      classDivisionId ? parseInt(classDivisionId) : undefined,
      user
    )

    // Filter for promotion eligible students
    const eligibleStudents = result.data.filter(
      studentRecord =>
        studentRecord.promotionStatus === 'COMPLETED' ||
        studentRecord.promotionStatus === 'IN_PROGRESS'
    )

    return {
      success: true,
      data: eligibleStudents,
    }
  }

  // ============================================================================
  // ENROLLMENT MANAGEMENT
  // ============================================================================

  /**
   * Enroll a student in a new academic year
   * POST /students/academic-progression/student/:studentId/enroll
   */
  @Post('student/:studentId/enroll')
  @Roles('super_admin', 'admin')
  async enrollStudentInAcademicYear(
    @Param('studentId', ParseIntPipe) studentId: number,
    @Body()
    enrollmentData: {
      academicYearId: number
      classLevel: number
      section?: string
      rollNumber?: string
      classDivisionId?: number
      classTeacherId?: number
    },
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.enrollInAcademicYear(
      studentId,
      enrollmentData,
      user
    )
  }

  // ============================================================================
  // ACADEMIC YEAR STATISTICS
  // ============================================================================

  /**
   * Get academic year statistics and summaries
   * GET /students/academic-progression/academic-year/:academicYearId/stats
   */
  @Get('academic-year/:academicYearId/stats')
  @Roles('super_admin', 'admin', 'teacher')
  async getAcademicYearStats(
    @Param('academicYearId', ParseIntPipe) academicYearId: number,
    @CurrentUser() user: UserWithRelations
  ) {
    const studentsResult = await this.studentsService.getStudentsByAcademicYear(
      academicYearId,
      undefined,
      undefined,
      user
    )

    const students = studentsResult.data
    const totalStudents = students.length

    // Calculate statistics
    const stats = {
      totalStudents,
      byPromotionStatus: {
        inProgress: students.filter(s => s.promotionStatus === 'IN_PROGRESS')
          .length,
        completed: students.filter(s => s.promotionStatus === 'COMPLETED')
          .length,
        promoted: students.filter(s => s.promotionStatus === 'PROMOTED').length,
        failed: students.filter(s => s.promotionStatus === 'FAILED').length,
        repeated: students.filter(s => s.promotionStatus === 'REPEATED').length,
        transferred: students.filter(s => s.promotionStatus === 'TRANSFERRED')
          .length,
      },
      byClassLevel: students.reduce(
        (acc, student) => {
          const level = student.classLevel
          acc[level] = (acc[level] || 0) + 1
          return acc
        },
        {} as Record<number, number>
      ),
      averageAttendance:
        students.length > 0
          ? students
              .filter(s => s.attendancePercentage !== null)
              .reduce((sum, s) => sum + (s.attendancePercentage || 0), 0) /
            students.filter(s => s.attendancePercentage !== null).length
          : 0,
      averageFinalPercentage:
        students.length > 0
          ? students
              .filter(s => s.finalPercentage !== null)
              .reduce((sum, s) => sum + (s.finalPercentage || 0), 0) /
            students.filter(s => s.finalPercentage !== null).length
          : 0,
    }

    return {
      success: true,
      data: {
        academicYearId,
        statistics: stats,
        lastUpdated: new Date().toISOString(),
      },
    }
  }
}
