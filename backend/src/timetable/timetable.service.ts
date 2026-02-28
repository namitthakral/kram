import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'
import { Prisma } from '@prisma/client'
import { PrismaService } from '../prisma/prisma.service'
import {
  BulkCreateTimetableDto,
  CreateRoomDto,
  CreateTimeSlotDto,
  CreateTimetableEntryDto,
  RoomQueryDto,
  TimeSlotQueryDto,
  TimetableQueryDto,
  UpdateRoomDto,
  UpdateTimeSlotDto,
  UpdateTimetableEntryDto,
} from './dto/timetable.dto'

@Injectable()
export class TimetableService {
  constructor(private readonly prisma: PrismaService) {}

  // ============ TimeSlot Methods ============

  async createTimeSlot(dto: CreateTimeSlotDto) {
    // Parse time strings to Date objects (time only)
    const startTime = this.parseTimeString(dto.startTime)
    const endTime = this.parseTimeString(dto.endTime)

    if (startTime >= endTime) {
      throw new BadRequestException('Start time must be before end time')
    }

    const timeSlot = await this.prisma.timeSlot.create({
      data: {
        institutionId: dto.institutionId,
        slotName: dto.slotName,
        startTime,
        endTime,
        slotType: dto.slotType,
        duration: dto.duration,
        sortOrder: dto.sortOrder,
        isActive: dto.isActive ?? true,
      },
    })

    return {
      success: true,
      message: 'Time slot created successfully',
      data: this.formatTimeSlot(timeSlot),
    }
  }

  async findAllTimeSlots(
    query: TimeSlotQueryDto,
    institutionId: number | null
  ) {
    const where: Prisma.TimeSlotWhereInput = {}

    if (institutionId) {
      where.institutionId = institutionId
    } else if (query.institutionId) {
      where.institutionId = query.institutionId
    }
    if (query.slotType) {
      where.slotType = query.slotType
    }
    if (query.isActive !== undefined) {
      where.isActive = query.isActive
    }

    const timeSlots = await this.prisma.timeSlot.findMany({
      where,
      orderBy: { sortOrder: 'asc' },
      include: {
        institution: {
          select: { id: true, name: true, code: true },
        },
      },
    })

    return {
      success: true,
      data: timeSlots.map(this.formatTimeSlot.bind(this)),
      count: timeSlots.length,
    }
  }

  async findOneTimeSlot(id: number, adminInstitutionId: number | null) {
    const timeSlot = await this.prisma.timeSlot.findUnique({
      where: { id },
      select: {
        id: true,
        institutionId: true,
        slotName: true,
        startTime: true,
        endTime: true,
        slotType: true,
        duration: true,
        sortOrder: true,
        isActive: true,
        createdAt: true,
        institution: {
          select: { id: true, name: true, code: true },
        },
      },
    })

    if (!timeSlot) {
      throw new NotFoundException(`Time slot with ID ${id} not found`)
    }

    if (
      adminInstitutionId != null &&
      timeSlot.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException(
        'You do not have access to this time slot'
      )
    }

    return {
      success: true,
      data: this.formatTimeSlot(timeSlot),
    }
  }

  async updateTimeSlot(
    id: number,
    dto: UpdateTimeSlotDto,
    adminInstitutionId: number | null
  ) {
    await this.findOneTimeSlot(id, adminInstitutionId)

    const updateData: any = { ...dto }

    if (dto.startTime) {
      updateData.startTime = this.parseTimeString(dto.startTime)
    }
    if (dto.endTime) {
      updateData.endTime = this.parseTimeString(dto.endTime)
    }

    const timeSlot = await this.prisma.timeSlot.update({
      where: { id },
      data: updateData,
    })

    return {
      success: true,
      message: 'Time slot updated successfully',
      data: this.formatTimeSlot(timeSlot),
    }
  }

  async deleteTimeSlot(id: number, adminInstitutionId: number | null) {
    await this.findOneTimeSlot(id, adminInstitutionId)

    // Check if time slot is used in any timetable
    const usedInTimetable = await this.prisma.timeTable.findFirst({
      where: { timeSlotId: id },
    })

    if (usedInTimetable) {
      throw new ConflictException(
        'Cannot delete time slot as it is used in timetable entries. Deactivate it instead.'
      )
    }

    await this.prisma.timeSlot.delete({ where: { id } })

    return {
      success: true,
      message: 'Time slot deleted successfully',
    }
  }

  // ============ Room Methods ============

  async createRoom(dto: CreateRoomDto) {
    // Check for duplicate room number in institution
    const existing = await this.prisma.room.findFirst({
      where: {
        institutionId: dto.institutionId,
        roomNumber: dto.roomNumber,
      },
    })

    if (existing) {
      throw new ConflictException(
        `Room number ${dto.roomNumber} already exists in this institution`
      )
    }

    const room = await this.prisma.room.create({
      data: {
        institutionId: dto.institutionId,
        roomNumber: dto.roomNumber,
        roomName: dto.roomName,
        roomType: dto.roomType,
        building: dto.building,
        floor: dto.floor,
        capacity: dto.capacity,
        facilities: dto.facilities || [],
        isActive: dto.isActive ?? true,
      },
    })

    return {
      success: true,
      message: 'Room created successfully',
      data: room,
    }
  }

  async findAllRooms(query: RoomQueryDto, institutionId: number | null) {
    const where: Prisma.RoomWhereInput = {}

    if (institutionId) {
      where.institutionId = institutionId
    } else if (query.institutionId) {
      where.institutionId = query.institutionId
    }
    if (query.roomType) {
      where.roomType = query.roomType
    }
    if (query.isActive !== undefined) {
      where.isActive = query.isActive
    }
    if (query.building) {
      where.building = query.building
    }

    const rooms = await this.prisma.room.findMany({
      where,
      orderBy: [{ building: 'asc' }, { roomNumber: 'asc' }],
      include: {
        institution: {
          select: { id: true, name: true, code: true },
        },
      },
    })

    return {
      success: true,
      data: rooms,
      count: rooms.length,
    }
  }

  async findOneRoom(id: number, adminInstitutionId: number | null) {
    const room = await this.prisma.room.findUnique({
      where: { id },
      select: {
        id: true,
        institutionId: true,
        roomNumber: true,
        roomName: true,
        building: true,
        floor: true,
        capacity: true,
        roomType: true,
        facilities: true,
        isActive: true,
        createdAt: true,
        institution: {
          select: { id: true, name: true, code: true },
        },
      },
    })

    if (!room) {
      throw new NotFoundException(`Room with ID ${id} not found`)
    }

    if (
      adminInstitutionId != null &&
      room.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException('You do not have access to this room')
    }

    return {
      success: true,
      data: room,
    }
  }

  async updateRoom(
    id: number,
    dto: UpdateRoomDto,
    adminInstitutionId: number | null
  ) {
    const room = await this.findOneRoom(id, adminInstitutionId)

    // Check for duplicate room number if changing
    if (dto.roomNumber && dto.roomNumber !== room.data.roomNumber) {
      const existing = await this.prisma.room.findFirst({
        where: {
          institutionId: room.data.institutionId,
          roomNumber: dto.roomNumber,
          id: { not: id },
        },
      })

      if (existing) {
        throw new ConflictException(
          `Room number ${dto.roomNumber} already exists in this institution`
        )
      }
    }

    const updated = await this.prisma.room.update({
      where: { id },
      data: dto,
    })

    return {
      success: true,
      message: 'Room updated successfully',
      data: updated,
    }
  }

  async deleteRoom(id: number, adminInstitutionId: number | null) {
    await this.findOneRoom(id, adminInstitutionId)

    // Check if room is used in any timetable
    const usedInTimetable = await this.prisma.timeTable.findFirst({
      where: { roomId: id },
    })

    if (usedInTimetable) {
      throw new ConflictException(
        'Cannot delete room as it is used in timetable entries. Deactivate it instead.'
      )
    }

    await this.prisma.room.delete({ where: { id } })

    return {
      success: true,
      message: 'Room deleted successfully',
    }
  }

  // ============ Timetable Methods ============

  async createTimetableEntry(dto: CreateTimetableEntryDto) {
    // Validate references exist
    await this.validateTimetableReferences(dto)

    // Check for conflicts (same slot, same room OR same teacher)
    await this.checkTimetableConflicts(dto)

    const entry = await this.prisma.timeTable.create({
      data: {
        institutionId: dto.institutionId,
        academicYearId: dto.academicYearId,
        semesterId: dto.semesterId,
        courseId: dto.courseId,
        section: dto.section,
        dayOfWeek: dto.dayOfWeek,
        timeSlotId: dto.timeSlotId,
        subjectId: dto.subjectId,
        teacherId: dto.teacherId,
        roomId: dto.roomId,
        isActive: dto.isActive ?? true,
      },
      select: this.getTimetableSelect(),
    })

    return {
      success: true,
      message: 'Timetable entry created successfully',
      data: this.formatTimetableEntry(entry),
    }
  }

  async bulkCreateTimetable(dto: BulkCreateTimetableDto) {
    const results = {
      created: 0,
      failed: 0,
      errors: [] as string[],
    }

    for (const entry of dto.entries) {
      try {
        await this.createTimetableEntry({
          institutionId: dto.institutionId,
          academicYearId: dto.academicYearId,
          semesterId: dto.semesterId,
          ...entry,
        })
        results.created++
      } catch (error) {
        results.failed++
        results.errors.push(
          `Entry for ${entry.dayOfWeek} slot ${entry.timeSlotId}: ${error.message}`
        )
      }
    }

    return {
      success: true,
      message: `Created ${results.created} entries, ${results.failed} failed`,
      data: results,
    }
  }

  async findAllTimetableEntries(
    query: TimetableQueryDto,
    institutionId: number | null
  ) {
    const where: Prisma.TimeTableWhereInput = { isActive: true }

    if (institutionId) {
      where.institutionId = institutionId
    } else if (query.institutionId) {
      where.institutionId = query.institutionId
    }
    if (query.academicYearId) where.academicYearId = query.academicYearId
    if (query.semesterId) where.semesterId = query.semesterId
    if (query.courseId) where.courseId = query.courseId
    if (query.section) where.section = query.section
    if (query.dayOfWeek) where.dayOfWeek = query.dayOfWeek
    if (query.teacherId) where.teacherId = query.teacherId
    if (query.subjectId) where.subjectId = query.subjectId
    if (query.roomId) where.roomId = query.roomId

    const entries = await this.prisma.timeTable.findMany({
      where,
      select: this.getTimetableSelect(),
      orderBy: [{ dayOfWeek: 'asc' }, { timeSlot: { sortOrder: 'asc' } }],
    })

    return {
      success: true,
      data: entries.map(this.formatTimetableEntry.bind(this)),
      count: entries.length,
    }
  }

  async getTimetableByClass(
    courseId: number,
    section: string,
    semesterId: number
  ) {
    const entries = await this.prisma.timeTable.findMany({
      where: {
        courseId,
        section,
        semesterId,
        isActive: true,
      },
      select: this.getTimetableSelect(),
      orderBy: [{ dayOfWeek: 'asc' }, { timeSlot: { sortOrder: 'asc' } }],
    })

    // Group by day
    const grouped = this.groupByDay(entries)

    return {
      success: true,
      data: {
        courseId,
        section,
        semesterId,
        schedule: grouped,
      },
    }
  }

  async getTimetableByTeacher(teacherId: number, semesterId: number) {
    const teacher = await this.prisma.teacher.findUnique({
      where: { id: teacherId },
      select: {
        id: true,
        employeeId: true,
        designation: true,
        institutionId: true,
        user: { 
          select: { 
            id: true,
            name: true, 
            email: true,
            phone: true,
          } 
        },
      },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with ID ${teacherId} not found`)
    }

    const entries = await this.prisma.timeTable.findMany({
      where: {
        teacherId,
        semesterId,
        isActive: true,
      },
      select: this.getTimetableSelect(),
      orderBy: [{ dayOfWeek: 'asc' }, { timeSlot: { sortOrder: 'asc' } }],
    })

    const grouped = this.groupByDay(entries)

    return {
      success: true,
      data: {
        teacher: {
          id: teacher.id,
          name: teacher.user.name,
          email: teacher.user.email,
          employeeId: teacher.employeeId,
        },
        semesterId,
        schedule: grouped,
      },
    }
  }

  async getTimetableByRoom(roomId: number, semesterId: number) {
    const room = await this.prisma.room.findUnique({
      where: { id: roomId },
    })

    if (!room) {
      throw new NotFoundException(`Room with ID ${roomId} not found`)
    }

    const entries = await this.prisma.timeTable.findMany({
      where: {
        roomId,
        semesterId,
        isActive: true,
      },
      select: this.getTimetableSelect(),
      orderBy: [{ dayOfWeek: 'asc' }, { timeSlot: { sortOrder: 'asc' } }],
    })

    const grouped = this.groupByDay(entries)

    return {
      success: true,
      data: {
        room: {
          id: room.id,
          roomNumber: room.roomNumber,
          roomName: room.roomName,
          building: room.building,
        },
        semesterId,
        schedule: grouped,
      },
    }
  }

  async findOneTimetableEntry(
    id: number,
    adminInstitutionId: number | null
  ) {
    const entry = await this.prisma.timeTable.findUnique({
      where: { id },
      select: this.getTimetableSelect(),
    })

    if (!entry) {
      throw new NotFoundException(`Timetable entry with ID ${id} not found`)
    }

    if (
      adminInstitutionId != null &&
      entry.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException(
        'You do not have access to this timetable entry'
      )
    }

    return {
      success: true,
      data: this.formatTimetableEntry(entry),
    }
  }

  async updateTimetableEntry(
    id: number,
    dto: UpdateTimetableEntryDto,
    adminInstitutionId: number | null
  ) {
    const existing = await this.findOneTimetableEntry(id, adminInstitutionId)

    // If changing slot/room/teacher, check for conflicts
    if (dto.dayOfWeek || dto.timeSlotId || dto.teacherId || dto.roomId) {
      const checkDto = {
        institutionId: existing.data.institution.id,
        academicYearId: existing.data.academicYear.id,
        semesterId: existing.data.semester.id,
        dayOfWeek: dto.dayOfWeek || existing.data.dayOfWeek,
        timeSlotId: dto.timeSlotId || existing.data.timeSlot.id,
        teacherId: dto.teacherId || existing.data.teacher.id,
        roomId: dto.roomId || existing.data.room?.id,
        courseId: dto.courseId || existing.data.course?.id,
        section: dto.section || existing.data.section,
        subjectId: dto.subjectId || existing.data.subject.id,
      }
      await this.checkTimetableConflicts(checkDto as any, id)
    }

    const updated = await this.prisma.timeTable.update({
      where: { id },
      data: dto,
      select: this.getTimetableSelect(),
    })

    return {
      success: true,
      message: 'Timetable entry updated successfully',
      data: this.formatTimetableEntry(updated),
    }
  }

  async deleteTimetableEntry(id: number, adminInstitutionId: number | null) {
    await this.findOneTimetableEntry(id, adminInstitutionId)

    await this.prisma.timeTable.delete({ where: { id } })

    return {
      success: true,
      message: 'Timetable entry deleted successfully',
    }
  }

  // ============ Helper Methods ============

  private parseTimeString(timeStr: string): Date {
    // Parse "HH:mm" format to a Date object (date part will be arbitrary)
    const [hours, minutes] = timeStr.split(':').map(Number)
    const date = new Date()
    date.setHours(hours, minutes, 0, 0)
    return date
  }

  private formatTimeSlot(timeSlot: any) {
    return {
      ...timeSlot,
      startTime: this.formatTime(timeSlot.startTime),
      endTime: this.formatTime(timeSlot.endTime),
    }
  }

  private formatTime(date: Date): string {
    return date.toTimeString().slice(0, 5) // "HH:mm"
  }

  /**
   * Get optimized select fields for timetable queries
   * Uses selective loading for better performance
   */
  private getTimetableSelect() {
    return {
      id: true,
      institutionId: true,
      academicYearId: true,
      semesterId: true,
      courseId: true,
      section: true,
      subjectId: true,
      teacherId: true,
      roomId: true,
      timeSlotId: true,
      dayOfWeek: true,
      isActive: true,
      createdAt: true,
      updatedAt: true,
      institution: { 
        select: { id: true, name: true, code: true } 
      },
      academicYear: { 
        select: { id: true, yearName: true } 
      },
      semester: {
        select: { id: true, semesterName: true, semesterNumber: true },
      },
      course: { 
        select: { id: true, name: true, code: true } 
      },
      subject: { 
        select: { id: true, subjectName: true, subjectCode: true } 
      },
      teacher: {
        select: {
          id: true,
          employeeId: true,
          user: { 
            select: { id: true, name: true, email: true } 
          },
        },
      },
      room: {
        select: {
          id: true,
          roomNumber: true,
          roomName: true,
          building: true,
          capacity: true,
        },
      },
      timeSlot: {
        select: {
          id: true,
          slotName: true,
          startTime: true,
          endTime: true,
          slotType: true,
          duration: true,
          sortOrder: true,
        },
      },
    }
  }

  private formatTimetableEntry(entry: any) {
    return {
      id: entry.id,
      dayOfWeek: entry.dayOfWeek,
      isActive: entry.isActive,
      institution: entry.institution,
      academicYear: entry.academicYear,
      semester: entry.semester,
      course: entry.course,
      section: entry.section,
      subject: entry.subject,
      teacher: entry.teacher
        ? {
            id: entry.teacher.id,
            employeeId: entry.teacher.employeeId,
            name: entry.teacher.user?.name,
            email: entry.teacher.user?.email,
          }
        : null,
      room: entry.room,
      timeSlot: entry.timeSlot
        ? {
            ...entry.timeSlot,
            startTime: this.formatTime(entry.timeSlot.startTime),
            endTime: this.formatTime(entry.timeSlot.endTime),
          }
        : null,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    }
  }

  private groupByDay(entries: any[]) {
    const days = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ]

    const grouped: Record<string, any[]> = {}

    for (const day of days) {
      grouped[day] = entries
        .filter(e => e.dayOfWeek === day)
        .map(this.formatTimetableEntry.bind(this))
    }

    return grouped
  }

  private async validateTimetableReferences(dto: CreateTimetableEntryDto) {
    // Validate institution
    const institution = await this.prisma.institution.findUnique({
      where: { id: dto.institutionId },
    })
    if (!institution) {
      throw new NotFoundException(
        `Institution with ID ${dto.institutionId} not found`
      )
    }

    // Validate academic year
    const academicYear = await this.prisma.academicYear.findUnique({
      where: { id: dto.academicYearId },
    })
    if (!academicYear) {
      throw new NotFoundException(
        `Academic year with ID ${dto.academicYearId} not found`
      )
    }

    // Validate semester
    const semester = await this.prisma.semester.findUnique({
      where: { id: dto.semesterId },
    })
    if (!semester) {
      throw new NotFoundException(
        `Semester with ID ${dto.semesterId} not found`
      )
    }

    // Validate time slot
    const timeSlot = await this.prisma.timeSlot.findUnique({
      where: { id: dto.timeSlotId },
    })
    if (!timeSlot) {
      throw new NotFoundException(
        `Time slot with ID ${dto.timeSlotId} not found`
      )
    }

    // Validate subject
    const subject = await this.prisma.subject.findUnique({
      where: { id: dto.subjectId },
    })
    if (!subject) {
      throw new NotFoundException(`Subject with ID ${dto.subjectId} not found`)
    }

    // Validate teacher
    const teacher = await this.prisma.teacher.findUnique({
      where: { id: dto.teacherId },
    })
    if (!teacher) {
      throw new NotFoundException(`Teacher with ID ${dto.teacherId} not found`)
    }

    // Validate room if provided
    if (dto.roomId) {
      const room = await this.prisma.room.findUnique({
        where: { id: dto.roomId },
      })
      if (!room) {
        throw new NotFoundException(`Room with ID ${dto.roomId} not found`)
      }
    }

    // Validate course if provided
    if (dto.courseId) {
      const course = await this.prisma.course.findUnique({
        where: { id: dto.courseId },
      })
      if (!course) {
        throw new NotFoundException(`Course with ID ${dto.courseId} not found`)
      }
    }
  }

  private async checkTimetableConflicts(
    dto: CreateTimetableEntryDto,
    excludeId?: number
  ) {
    // Check for teacher conflict (same teacher, same day, same slot)
    const teacherConflict = await this.prisma.timeTable.findFirst({
      where: {
        teacherId: dto.teacherId,
        dayOfWeek: dto.dayOfWeek,
        timeSlotId: dto.timeSlotId,
        semesterId: dto.semesterId,
        isActive: true,
        ...(excludeId && { id: { not: excludeId } }),
      },
      include: {
        course: { select: { name: true } },
        subject: { select: { subjectName: true } },
      },
    })

    if (teacherConflict) {
      throw new ConflictException(
        `Teacher already has a class at this time: ${teacherConflict.subject?.subjectName} for ${teacherConflict.course?.name || 'Unknown'}`
      )
    }

    // Check for room conflict (same room, same day, same slot)
    if (dto.roomId) {
      const roomConflict = await this.prisma.timeTable.findFirst({
        where: {
          roomId: dto.roomId,
          dayOfWeek: dto.dayOfWeek,
          timeSlotId: dto.timeSlotId,
          semesterId: dto.semesterId,
          isActive: true,
          ...(excludeId && { id: { not: excludeId } }),
        },
        include: {
          course: { select: { name: true } },
          subject: { select: { subjectName: true } },
        },
      })

      if (roomConflict) {
        throw new ConflictException(
          `Room is already booked at this time for: ${roomConflict.subject?.subjectName}`
        )
      }
    }

    // Check for class conflict (same course+section, same day, same slot)
    if (dto.courseId && dto.section) {
      const classConflict = await this.prisma.timeTable.findFirst({
        where: {
          courseId: dto.courseId,
          section: dto.section,
          dayOfWeek: dto.dayOfWeek,
          timeSlotId: dto.timeSlotId,
          semesterId: dto.semesterId,
          isActive: true,
          ...(excludeId && { id: { not: excludeId } }),
        },
        include: {
          subject: { select: { subjectName: true } },
        },
      })

      if (classConflict) {
        throw new ConflictException(
          `Class already has a subject at this time: ${classConflict.subject?.subjectName}`
        )
      }
    }
  }
}
