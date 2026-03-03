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
import { CreateClassDivisionDto } from './dto/create-class-division.dto'
import { UpdateClassDivisionDto } from './dto/update-class-division.dto'

/**
 * Class Divisions Controller
 * 
 * Manages simple class divisions for basic school organization (e.g., "Class I - Section A").
 * This is separate from ClassSections which are subject-specific and semester-specific.
 * 
 * Class divisions are used for:
 * - Basic student organization
 * - Class teacher assignments
 * - Simple attendance tracking
 */
@Controller('class-divisions')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ClassDivisionsController {
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
   * Get all class divisions for a course (with pagination)
   */
  @Get('course/:courseId')
  @Roles('super_admin', 'admin', 'teacher')
  async getClassDivisions(
    @Param('courseId', ParseIntPipe) courseId: number,
    @CurrentUser() user: UserWithRelations,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const institutionId = this.resolveInstitutionId(user)
    const pageNum = page ? parseInt(page, 10) : 1
    const limitNum = limit ? parseInt(limit, 10) : 50
    return this.coursesService.getClassDivisions(courseId, institutionId, pageNum, limitNum)
  }

  /**
   * Create a new class division
   */
  @Post()
  @Roles('super_admin', 'admin')
  async createClassDivision(
    @Body() createClassDivisionDto: CreateClassDivisionDto,
    @CurrentUser() user: UserWithRelations,
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.coursesService.createClassDivision(createClassDivisionDto, institutionId)
  }

  /**
   * Update an existing class division
   */
  @Put(':id')
  @Roles('super_admin', 'admin')
  async updateClassDivision(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateClassDivisionDto: UpdateClassDivisionDto,
    @CurrentUser() user: UserWithRelations,
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.coursesService.updateClassDivision(id, updateClassDivisionDto, institutionId)
  }

  /**
   * Delete a class division (soft delete)
   */
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @Roles('super_admin', 'admin')
  async deleteClassDivision(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations,
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.coursesService.deleteClassDivision(id, institutionId)
  }
}