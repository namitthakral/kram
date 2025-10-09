import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
  ParseIntPipe,
} from '@nestjs/common'
import { StudentsService } from './students.service'
import {
  CreateStudentDto,
  UpdateStudentDto,
  PaginationDto,
} from './dto/student.dto'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { Roles } from '../auth/decorators/roles.decorator'
import { CurrentUser } from '../auth/decorators/current-user.decorator'
import { UserWithRelations } from '../types/auth.types'

@Controller('students')
@UseGuards(JwtAuthGuard)
export class StudentsController {
  constructor(private readonly studentsService: StudentsService) {}

  @Get()
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin', 'teacher')
  async findAll(
    @Query() paginationDto: PaginationDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.findAll(paginationDto, user)
  }

  @Get(':id')
  async findOne(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.findOne(id, user)
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  async create(@Body() createStudentDto: CreateStudentDto) {
    return this.studentsService.create(createStudentDto)
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateStudentDto: UpdateStudentDto
  ) {
    return this.studentsService.update(id, updateStudentDto)
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.studentsService.remove(id)
  }

  @Get(':id/academic-records')
  async getAcademicRecords(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.getAcademicRecords(id, user)
  }

  @Get(':id/attendance')
  async getAttendance(
    @Param('id', ParseIntPipe) id: number,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @CurrentUser() user?: UserWithRelations
  ) {
    return this.studentsService.getAttendance(id, startDate, endDate, user)
  }
}
