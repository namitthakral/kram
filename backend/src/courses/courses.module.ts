import { Module } from '@nestjs/common'
import { ClassSectionsController } from './class-sections.controller'
import { ClassDivisionsController } from './class-divisions.controller'
import { CoursesController } from './courses.controller'
import { CoursesService } from './courses.service'
import { SubjectsController } from './subjects.controller'
import { SubjectsService } from './subjects.service'

/**
 * Courses Module
 *
 * Manages:
 * - Courses/Programs (e.g., B.Sc. Computer Science, Class 10)
 * - Subjects/Papers (e.g., Data Structures, Physics)
 * - Class Sections (subject-based sections with teachers)
 * - Class Divisions (simple class organization, e.g., "Class I - Section A")
 */
@Module({
  controllers: [CoursesController, ClassSectionsController, ClassDivisionsController, SubjectsController],
  providers: [CoursesService, SubjectsService],
  exports: [CoursesService, SubjectsService],
})
export class CoursesModule {}
