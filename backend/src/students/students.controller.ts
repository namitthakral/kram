import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common'
import { CurrentUser } from '../auth/decorators/current-user.decorator'
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { UserWithRelations } from '../types/auth.types'
import {
  CreateStudentDto,
  PaginationDto,
  UpdateStudentDto,
} from './dto/student.dto'
import { StudentsService } from './students.service'

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

  @Get(':user_uuid')
  async findByUuid(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.findByUuid(userUuid, user)
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  async create(@Body() createStudentDto: CreateStudentDto) {
    return this.studentsService.create(createStudentDto)
  }

  @Patch(':user_uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  async update(
    @Param('user_uuid') userUuid: string,
    @Body() updateStudentDto: UpdateStudentDto
  ) {
    return this.studentsService.updateByUuid(userUuid, updateStudentDto)
  }

  @Delete(':user_uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  async remove(@Param('user_uuid') userUuid: string) {
    return this.studentsService.removeByUuid(userUuid)
  }

  @Get(':user_uuid/academic-records')
  async getAcademicRecords(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.getAcademicRecordsByUuid(userUuid, user)
  }

  @Get(':user_uuid/attendance')
  async getAttendance(
    @Param('user_uuid') userUuid: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @CurrentUser() user?: UserWithRelations
  ) {
    return this.studentsService.getAttendanceByUuid(
      userUuid,
      startDate,
      endDate,
      user
    )
  }
}
