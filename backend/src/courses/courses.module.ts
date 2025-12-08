import { Module } from '@nestjs/common'
import { ClassSectionsController } from './class-sections.controller'
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
 */
@Module({
  controllers: [CoursesController, ClassSectionsController, SubjectsController],
  providers: [CoursesService, SubjectsService],
  exports: [CoursesService, SubjectsService],
})
export class CoursesModule {}
