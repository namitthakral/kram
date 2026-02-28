import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
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
  BulkCreateTimetableDto,
  CreateRoomDto,
  CreateTimeSlotDto,
  CreateTimetableEntryDto,
  RoomQueryDto,
  TimeSlotQueryDto,
  TimetableQueryDto,
  TimetableViewQueryDto,
  UpdateRoomDto,
  UpdateTimeSlotDto,
  UpdateTimetableEntryDto,
} from './dto/timetable.dto'
import { TimetableService } from './timetable.service'

@Controller('timetable')
@UseGuards(JwtAuthGuard, RolesGuard)
export class TimetableController {
  constructor(private readonly timetableService: TimetableService) {}

  private resolveInstitutionId(user: UserWithRelations): number | null {
    return (
      user.institutionId ??
      user.staff?.institutionId ??
      user.teacher?.institutionId ??
      user.student?.institutionId ??
      null
    )
  }

  // ============ Time Slot Endpoints ============

  /**
   * Create a new time slot
   */
  @Post('time-slots')
  @Roles('super_admin', 'admin')
  async createTimeSlot(@Body() dto: CreateTimeSlotDto) {
    return this.timetableService.createTimeSlot(dto)
  }

  /**
   * Get all time slots
   * Query params: institutionId, slotType, isActive
   */
  @Get('time-slots')
  @Roles('super_admin', 'admin', 'teacher')
  async findAllTimeSlots(
    @Query() query: TimeSlotQueryDto,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.timetableService.findAllTimeSlots(query, institutionId)
  }

  /**
   * Get a single time slot by ID
   */
  @Get('time-slots/:id')
  @Roles('super_admin', 'admin', 'teacher')
  async findOneTimeSlot(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.timetableService.findOneTimeSlot(id, institutionId)
  }

  /**
   * Update a time slot
   */
  @Patch('time-slots/:id')
  @Roles('super_admin', 'admin')
  async updateTimeSlot(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateTimeSlotDto,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.timetableService.updateTimeSlot(id, dto, institutionId)
  }

  /**
   * Delete a time slot
   */
  @Delete('time-slots/:id')
  @Roles('super_admin', 'admin')
  async deleteTimeSlot(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.timetableService.deleteTimeSlot(id, institutionId)
  }

  // ============ Room Endpoints ============

  /**
   * Create a new room
   */
  @Post('rooms')
  @Roles('super_admin', 'admin')
  async createRoom(@Body() dto: CreateRoomDto) {
    return this.timetableService.createRoom(dto)
  }

  /**
   * Get all rooms
   * Query params: institutionId, roomType, isActive, building
   */
  @Get('rooms')
  @Roles('super_admin', 'admin', 'teacher')
  async findAllRooms(
    @Query() query: RoomQueryDto,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.timetableService.findAllRooms(query, institutionId)
  }

  /**
   * Get a single room by ID
   */
  @Get('rooms/:id')
  @Roles('super_admin', 'admin', 'teacher')
  async findOneRoom(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.timetableService.findOneRoom(id, institutionId)
  }

  /**
   * Update a room
   */
  @Patch('rooms/:id')
  @Roles('super_admin', 'admin')
  async updateRoom(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateRoomDto,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.timetableService.updateRoom(id, dto, institutionId)
  }

  /**
   * Delete a room
   */
  @Delete('rooms/:id')
  @Roles('super_admin', 'admin')
  async deleteRoom(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.timetableService.deleteRoom(id, institutionId)
  }

  // ============ Timetable Entry Endpoints ============

  /**
   * Create a single timetable entry
   */
  @Post('entries')
  @Roles('super_admin', 'admin')
  async createTimetableEntry(@Body() dto: CreateTimetableEntryDto) {
    return this.timetableService.createTimetableEntry(dto)
  }

  /**
   * Bulk create timetable entries
   * Useful for setting up an entire week's schedule at once
   */
  @Post('entries/bulk')
  @Roles('super_admin', 'admin')
  async bulkCreateTimetable(@Body() dto: BulkCreateTimetableDto) {
    return this.timetableService.bulkCreateTimetable(dto)
  }

  /**
   * Get all timetable entries with filters
   * Query params: institutionId, academicYearId, semesterId, courseId, section, dayOfWeek, teacherId, subjectId, roomId
   */
  @Get('entries')
  @Roles('super_admin', 'admin', 'teacher', 'student', 'parent')
  async findAllTimetableEntries(
    @Query() query: TimetableQueryDto,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.timetableService.findAllTimetableEntries(query, institutionId)
  }

  /**
   * Get timetable for a specific class (course + section)
   * Returns weekly schedule grouped by day
   */
  @Get('class/:courseId/:section')
  @Roles('super_admin', 'admin', 'teacher', 'student', 'parent')
  async getTimetableByClass(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('section') section: string,
    @Query() query: TimetableViewQueryDto
  ) {
    return this.timetableService.getTimetableByClass(
      courseId,
      section,
      query.semesterId
    )
  }

  /**
   * Get timetable for a specific teacher
   * Returns weekly schedule grouped by day
   */
  @Get('teacher/:teacherId')
  @Roles('super_admin', 'admin', 'teacher')
  async getTimetableByTeacher(
    @Param('teacherId', ParseIntPipe) teacherId: number,
    @Query() query: TimetableViewQueryDto
  ) {
    return this.timetableService.getTimetableByTeacher(
      teacherId,
      query.semesterId
    )
  }

  /**
   * Get timetable for a specific room
   * Returns weekly schedule grouped by day showing room occupancy
   */
  @Get('room/:roomId')
  @Roles('super_admin', 'admin', 'teacher')
  async getTimetableByRoom(
    @Param('roomId', ParseIntPipe) roomId: number,
    @Query() query: TimetableViewQueryDto
  ) {
    return this.timetableService.getTimetableByRoom(roomId, query.semesterId)
  }

  /**
   * Get a single timetable entry by ID
   */
  @Get('entries/:id')
  @Roles('super_admin', 'admin', 'teacher')
  async findOneTimetableEntry(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.timetableService.findOneTimetableEntry(id, institutionId)
  }

  /**
   * Update a timetable entry
   */
  @Patch('entries/:id')
  @Roles('super_admin', 'admin')
  async updateTimetableEntry(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateTimetableEntryDto,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.timetableService.updateTimetableEntry(id, dto, institutionId)
  }

  /**
   * Delete a timetable entry
   */
  @Delete('entries/:id')
  @Roles('super_admin', 'admin')
  async deleteTimetableEntry(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.timetableService.deleteTimetableEntry(id, institutionId)
  }
}
