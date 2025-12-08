import { Module } from '@nestjs/common'
import { TimetableController } from './timetable.controller'
import { TimetableService } from './timetable.service'

/**
 * Timetable Module
 *
 * Manages:
 * - Time Slots (periods like 9:00-9:45 AM)
 * - Rooms (classrooms, labs, etc.)
 * - Timetable Entries (which class, which subject, which teacher, when)
 *
 * Features:
 * - Conflict detection (teacher, room, class conflicts)
 * - Bulk timetable creation
 * - View by class/teacher/room
 */
@Module({
  controllers: [TimetableController],
  providers: [TimetableService],
  exports: [TimetableService],
})
export class TimetableModule {}
