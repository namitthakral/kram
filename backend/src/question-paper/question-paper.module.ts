import { Module } from '@nestjs/common'
import { QuestionPaperController } from './question-paper.controller'
import { QuestionPaperService } from './question-paper.service'

/**
 * Question Paper Module
 *
 * Manages:
 * - Question Papers (linked to Examinations)
 * - Sections (groupings within a paper like "Section A - MCQ")
 * - Questions (various types: MCQ, short answer, etc.)
 * - Options (for MCQ questions)
 *
 * Features:
 * - Create full question papers with sections and questions
 * - Different question types (MCQ, True/False, Short Answer, etc.)
 * - Difficulty levels (Easy, Medium, Hard)
 * - Negative marking support
 * - Draft/Ready/Published/Archived status workflow
 * - Student view with hidden answers
 */
@Module({
  controllers: [QuestionPaperController],
  providers: [QuestionPaperService],
  exports: [QuestionPaperService],
})
export class QuestionPaperModule {}
