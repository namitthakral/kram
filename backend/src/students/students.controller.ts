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

  @Get(':uuid')
  async findByUuid(
    @Param('uuid') uuid: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.findByUuid(uuid, user)
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  async create(@Body() createStudentDto: CreateStudentDto) {
    return this.studentsService.create(createStudentDto)
  }

  @Patch(':uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  async update(
    @Param('uuid') uuid: string,
    @Body() updateStudentDto: UpdateStudentDto
  ) {
    return this.studentsService.updateByUuid(uuid, updateStudentDto)
  }

  @Delete(':uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  async remove(@Param('uuid') uuid: string) {
    return this.studentsService.removeByUuid(uuid)
  }

  @Get(':uuid/academic-records')
  async getAcademicRecords(
    @Param('uuid') uuid: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.studentsService.getAcademicRecordsByUuid(uuid, user)
  }

  @Get(':uuid/attendance')
  async getAttendance(
    @Param('uuid') uuid: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @CurrentUser() user?: UserWithRelations
  ) {
    return this.studentsService.getAttendanceByUuid(
      uuid,
      startDate,
      endDate,
      user
    )
  }
}
