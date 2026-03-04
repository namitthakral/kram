import { Module } from '@nestjs/common'
import { IdGenerationModule } from '../id-generation/id-generation.module'
import { StudentsService } from './students.service'
import { StudentsController } from './students.controller'
import { ProgressUpdaterService } from './services/progress-updater.service'

@Module({
  imports: [IdGenerationModule],
  controllers: [StudentsController],
  providers: [StudentsService, ProgressUpdaterService],
  exports: [ProgressUpdaterService], // Export so other modules can use it
})
export class StudentsModule {}
