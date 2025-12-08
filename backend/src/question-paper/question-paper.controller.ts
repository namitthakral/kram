import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common'
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import {
  BulkCreateQuestionsDto,
  CreateFullQuestionPaperDto,
  CreateOptionDto,
  CreateQuestionDto,
  CreateQuestionPaperDto,
  CreateSectionDto,
  UpdateOptionDto,
  UpdateQuestionDto,
  UpdateQuestionPaperDto,
  UpdateSectionDto,
} from './dto/question-paper.dto'
import { QuestionPaperService } from './question-paper.service'

@Controller()
@UseGuards(JwtAuthGuard, RolesGuard)
export class QuestionPaperController {
  constructor(private readonly questionPaperService: QuestionPaperService) {}

  // ============ Question Paper Endpoints ============

  /**
   * Create an empty question paper for an examination
   */
  @Post('teachers/:user_uuid/examinations/:examId/question-paper')
  @Roles('teacher', 'super_admin', 'admin')
  async createQuestionPaper(
    @Param('user_uuid') userUuid: string,
    @Param('examId', ParseIntPipe) examId: number,
    @Body() dto: Omit<CreateQuestionPaperDto, 'examinationId'>
  ) {
    return this.questionPaperService.createQuestionPaper(userUuid, {
      ...dto,
      examinationId: examId,
    } as CreateQuestionPaperDto)
  }

  /**
   * Create a complete question paper with sections and questions
   */
  @Post('teachers/:user_uuid/question-papers/full')
  @Roles('teacher', 'super_admin', 'admin')
  async createFullQuestionPaper(
    @Param('user_uuid') userUuid: string,
    @Body() dto: CreateFullQuestionPaperDto
  ) {
    return this.questionPaperService.createFullQuestionPaper(userUuid, dto)
  }

  /**
   * Get question paper by examination ID
   */
  @Get('teachers/:user_uuid/examinations/:examId/question-paper')
  @Roles('teacher', 'super_admin', 'admin')
  async getQuestionPaper(
    @Param('user_uuid') userUuid: string,
    @Param('examId', ParseIntPipe) examId: number
  ) {
    return this.questionPaperService.getQuestionPaper(userUuid, examId)
  }

  /**
   * Get question paper by ID
   */
  @Get('teachers/:user_uuid/question-papers/:paperId')
  @Roles('teacher', 'super_admin', 'admin')
  async getQuestionPaperById(
    @Param('user_uuid') userUuid: string,
    @Param('paperId', ParseIntPipe) paperId: number
  ) {
    return this.questionPaperService.getQuestionPaperById(userUuid, paperId)
  }

  /**
   * Update question paper details
   */
  @Patch('teachers/:user_uuid/question-papers/:paperId')
  @Roles('teacher', 'super_admin', 'admin')
  async updateQuestionPaper(
    @Param('user_uuid') userUuid: string,
    @Param('paperId', ParseIntPipe) paperId: number,
    @Body() dto: UpdateQuestionPaperDto
  ) {
    return this.questionPaperService.updateQuestionPaper(userUuid, paperId, dto)
  }

  /**
   * Publish a question paper (makes it visible to students)
   */
  @Patch('teachers/:user_uuid/question-papers/:paperId/publish')
  @Roles('teacher', 'super_admin', 'admin')
  async publishQuestionPaper(
    @Param('user_uuid') userUuid: string,
    @Param('paperId', ParseIntPipe) paperId: number
  ) {
    return this.questionPaperService.publishQuestionPaper(userUuid, paperId)
  }

  /**
   * Delete a question paper (only if not published)
   */
  @Delete('teachers/:user_uuid/question-papers/:paperId')
  @Roles('teacher', 'super_admin', 'admin')
  async deleteQuestionPaper(
    @Param('user_uuid') userUuid: string,
    @Param('paperId', ParseIntPipe) paperId: number
  ) {
    return this.questionPaperService.deleteQuestionPaper(userUuid, paperId)
  }

  // ============ Section Endpoints ============

  /**
   * Add a section to a question paper
   */
  @Post('teachers/:user_uuid/question-papers/:paperId/sections')
  @Roles('teacher', 'super_admin', 'admin')
  async addSection(
    @Param('user_uuid') userUuid: string,
    @Param('paperId', ParseIntPipe) paperId: number,
    @Body() dto: CreateSectionDto
  ) {
    return this.questionPaperService.addSection(userUuid, paperId, dto)
  }

  /**
   * Update a section
   */
  @Patch('teachers/:user_uuid/sections/:sectionId')
  @Roles('teacher', 'super_admin', 'admin')
  async updateSection(
    @Param('user_uuid') userUuid: string,
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Body() dto: UpdateSectionDto
  ) {
    return this.questionPaperService.updateSection(userUuid, sectionId, dto)
  }

  /**
   * Delete a section (and all its questions)
   */
  @Delete('teachers/:user_uuid/sections/:sectionId')
  @Roles('teacher', 'super_admin', 'admin')
  async deleteSection(
    @Param('user_uuid') userUuid: string,
    @Param('sectionId', ParseIntPipe) sectionId: number
  ) {
    return this.questionPaperService.deleteSection(userUuid, sectionId)
  }

  // ============ Question Endpoints ============

  /**
   * Add a question to a section
   */
  @Post('teachers/:user_uuid/sections/:sectionId/questions')
  @Roles('teacher', 'super_admin', 'admin')
  async addQuestion(
    @Param('user_uuid') userUuid: string,
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Body() dto: CreateQuestionDto
  ) {
    return this.questionPaperService.addQuestion(userUuid, sectionId, dto)
  }

  /**
   * Bulk add questions to a section
   */
  @Post('teachers/:user_uuid/sections/:sectionId/questions/bulk')
  @Roles('teacher', 'super_admin', 'admin')
  async bulkAddQuestions(
    @Param('user_uuid') userUuid: string,
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Body() dto: BulkCreateQuestionsDto
  ) {
    return this.questionPaperService.bulkAddQuestions(userUuid, sectionId, dto)
  }

  /**
   * Update a question
   */
  @Patch('teachers/:user_uuid/questions/:questionId')
  @Roles('teacher', 'super_admin', 'admin')
  async updateQuestion(
    @Param('user_uuid') userUuid: string,
    @Param('questionId', ParseIntPipe) questionId: number,
    @Body() dto: UpdateQuestionDto
  ) {
    return this.questionPaperService.updateQuestion(userUuid, questionId, dto)
  }

  /**
   * Delete a question
   */
  @Delete('teachers/:user_uuid/questions/:questionId')
  @Roles('teacher', 'super_admin', 'admin')
  async deleteQuestion(
    @Param('user_uuid') userUuid: string,
    @Param('questionId', ParseIntPipe) questionId: number
  ) {
    return this.questionPaperService.deleteQuestion(userUuid, questionId)
  }

  // ============ Option Endpoints ============

  /**
   * Add an option to a question (for MCQ)
   */
  @Post('teachers/:user_uuid/questions/:questionId/options')
  @Roles('teacher', 'super_admin', 'admin')
  async addOption(
    @Param('user_uuid') userUuid: string,
    @Param('questionId', ParseIntPipe) questionId: number,
    @Body() dto: CreateOptionDto
  ) {
    return this.questionPaperService.addOption(userUuid, questionId, dto)
  }

  /**
   * Update an option
   */
  @Patch('teachers/:user_uuid/options/:optionId')
  @Roles('teacher', 'super_admin', 'admin')
  async updateOption(
    @Param('user_uuid') userUuid: string,
    @Param('optionId', ParseIntPipe) optionId: number,
    @Body() dto: UpdateOptionDto
  ) {
    return this.questionPaperService.updateOption(userUuid, optionId, dto)
  }

  /**
   * Delete an option
   */
  @Delete('teachers/:user_uuid/options/:optionId')
  @Roles('teacher', 'super_admin', 'admin')
  async deleteOption(
    @Param('user_uuid') userUuid: string,
    @Param('optionId', ParseIntPipe) optionId: number
  ) {
    return this.questionPaperService.deleteOption(userUuid, optionId)
  }

  // ============ Student View Endpoints ============

  /**
   * Get published question paper for a student
   * (Hides correct answers and hints)
   */
  @Get('students/:user_uuid/examinations/:examId/question-paper')
  @Roles('student', 'super_admin', 'admin')
  async getPublishedQuestionPaper(
    @Param('user_uuid') userUuid: string,
    @Param('examId', ParseIntPipe) examId: number
  ) {
    return this.questionPaperService.getPublishedQuestionPaper(userUuid, examId)
  }
}
