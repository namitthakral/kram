import { Module } from '@nestjs/common'
import { IdGenerationModule } from '../id-generation/id-generation.module'
import { AcademicProgressionController } from './controllers/academic-progression.controller'
import { AttendanceController } from './controllers/attendance.controller'
import { AcademicProgressionService } from './services/academic-progression.service'
import { AttendanceService } from './services/attendance.service'
import { ProgressUpdaterService } from './services/progress-updater.service'
import { StudentsController } from './students.controller'
import { StudentsService } from './students.service'

@Module({
  imports: [IdGenerationModule],
  controllers: [
    StudentsController,
    AcademicProgressionController,
    AttendanceController,
  ],
  providers: [
    StudentsService,
    ProgressUpdaterService,
    AcademicProgressionService,
    AttendanceService,
  ],
  exports: [
    StudentsService,
    ProgressUpdaterService,
    AcademicProgressionService,
    AttendanceService,
  ], // Export so other modules can use them
})
export class StudentsModule {}
