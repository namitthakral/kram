import { Module } from '@nestjs/common'
import { SubjectsController } from './subjects.controller'
import { SubjectsService } from './subjects.service'

/**
 * Courses Module
 * 
 * Note: "Courses" in database = "Subjects" in Indian education context
 * This module provides Subject CRUD APIs for managing academic subjects
 */
@Module({
  controllers: [SubjectsController],
  providers: [SubjectsService],
  exports: [SubjectsService],
})
export class CoursesModule {}
