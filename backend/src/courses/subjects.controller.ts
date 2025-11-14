import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  ParseIntPipe,
  Query,
  UseGuards,
  HttpStatus,
  HttpCode,
} from '@nestjs/common'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { Roles } from '../auth/decorators/roles.decorator'
import { SubjectsService } from './subjects.service'
import { CreateSubjectDto, UpdateSubjectDto } from './dto/subject.dto'

/**
 * Subjects Controller
 * 
 * In Indian education system terminology:
 * - Subject/Paper = Individual academic subject (e.g., Data Structures, English, Physics)
 * - This controller manages subjects that students study
 * 
 * Database: Works with the 'courses' table
 * API: Exposes as 'subjects' for better UX in Indian context
 */
@Controller('subjects')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SubjectsController {
  constructor(private readonly subjectsService: SubjectsService) {}

  /**
   * Get all subjects
   * Query params: courseId (optional), institutionId (optional), status (optional)
   */
  @Get()
  @Roles('super_admin', 'admin', 'teacher')
  async findAll(
    @Query('courseId', new ParseIntPipe({ optional: true })) courseId?: number,
    @Query('institutionId', new ParseIntPipe({ optional: true })) institutionId?: number,
    @Query('status') status?: string,
  ) {
    return this.subjectsService.findAll({ courseId, institutionId, status })
  }

  /**
   * Get subject by ID
   */
  @Get(':id')
  @Roles('super_admin', 'admin', 'teacher')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.subjectsService.findOne(id)
  }

  /**
   * Get subjects for a specific course (program/stream)
   * Example: Get all subjects for "B.Sc. Computer Science" or "Science - Medical Stream"
   */
  @Get('course/:courseId')
  @Roles('admin', 'teacher', 'student')
  async findByCourse(@Param('courseId', ParseIntPipe) courseId: number) {
    return this.subjectsService.findByCourse(courseId)
  }

  /**
   * Create a new subject
   * Admin only
   */
  @Post()
  @Roles('super_admin', 'admin')
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createSubjectDto: CreateSubjectDto) {
    return this.subjectsService.create(createSubjectDto)
  }

  /**
   * Update a subject
   * Admin only
   */
  @Patch(':id')
  @Roles('super_admin', 'admin')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateSubjectDto: UpdateSubjectDto,
  ) {
    return this.subjectsService.update(id, updateSubjectDto)
  }

  /**
   * Delete a subject (soft delete by setting status to INACTIVE)
   * Admin only
   */
  @Delete(':id')
  @Roles('super_admin', 'admin')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id', ParseIntPipe) id: number) {
    await this.subjectsService.remove(id)
  }

  /**
   * Get subjects statistics
   * Admin only
   */
  @Get('stats/overview')
  @Roles('super_admin', 'admin')
  async getStats(@Query('institutionId', ParseIntPipe) institutionId?: number) {
    return this.subjectsService.getStats(institutionId)
  }
}

