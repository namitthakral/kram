import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'
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

@Injectable()
export class QuestionPaperService {
  constructor(private readonly prisma: PrismaService) {}

  // ============ Question Paper Methods ============

  async createQuestionPaper(userUuid: string, dto: CreateQuestionPaperDto) {
    const teacher = await this.getTeacherByUuid(userUuid)

    // Verify examination exists and belongs to this teacher
    const examination = await this.prisma.examination.findUnique({
      where: { id: dto.examinationId },
    })

    if (!examination) {
      throw new NotFoundException(
        `Examination with ID ${dto.examinationId} not found`
      )
    }

    if (examination.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You can only create question papers for your own examinations'
      )
    }

    // Check if question paper already exists for this examination
    const existing = await this.prisma.questionPaper.findUnique({
      where: { examinationId: dto.examinationId },
    })

    if (existing) {
      throw new ConflictException(
        'A question paper already exists for this examination'
      )
    }

    const questionPaper = await this.prisma.questionPaper.create({
      data: {
        examinationId: dto.examinationId,
        title: dto.title,
        instructions: dto.instructions,
        totalMarks: dto.totalMarks,
        totalQuestions: 0,
        createdBy: teacher.id,
        status: 'DRAFT',
      },
      include: this.getQuestionPaperIncludes(),
    })

    return {
      success: true,
      message: 'Question paper created successfully',
      data: questionPaper,
    }
  }

  async createFullQuestionPaper(
    userUuid: string,
    dto: CreateFullQuestionPaperDto
  ) {
    const teacher = await this.getTeacherByUuid(userUuid)

    // Verify examination exists and belongs to this teacher
    const examination = await this.prisma.examination.findUnique({
      where: { id: dto.examinationId },
    })

    if (!examination) {
      throw new NotFoundException(
        `Examination with ID ${dto.examinationId} not found`
      )
    }

    if (examination.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You can only create question papers for your own examinations'
      )
    }

    // Check if question paper already exists
    const existing = await this.prisma.questionPaper.findUnique({
      where: { examinationId: dto.examinationId },
    })

    if (existing) {
      throw new ConflictException(
        'A question paper already exists for this examination'
      )
    }

    // Calculate totals
    let totalQuestions = 0
    let totalMarks = 0

    for (const section of dto.sections) {
      totalQuestions += section.questions.length
      totalMarks += section.questions.reduce((sum, q) => sum + q.marks, 0)
    }

    // Create question paper with sections and questions in a transaction
    const questionPaper = await this.prisma.$transaction(async (tx: PrismaService) => {
      // Create question paper
      const paper = await tx.questionPaper.create({
        data: {
          examinationId: dto.examinationId,
          title: dto.title,
          instructions: dto.instructions,
          totalMarks,
          totalQuestions,
          createdBy: teacher.id,
          status: 'DRAFT',
        },
      })

      // Create sections and questions
      for (let sIdx = 0; sIdx < dto.sections.length; sIdx++) {
        const sectionDto = dto.sections[sIdx]
        const sectionMarks = sectionDto.questions.reduce(
          (sum, q) => sum + q.marks,
          0
        )

        const section = await tx.questionSection.create({
          data: {
            questionPaperId: paper.id,
            sectionName: sectionDto.sectionName,
            instructions: sectionDto.instructions,
            totalMarks: sectionMarks,
            sortOrder: sectionDto.sortOrder ?? sIdx,
          },
        })

        // Create questions for this section
        for (let qIdx = 0; qIdx < sectionDto.questions.length; qIdx++) {
          const questionDto = sectionDto.questions[qIdx]

          const question = await tx.question.create({
            data: {
              sectionId: section.id,
              questionText: questionDto.questionText,
              questionType: questionDto.questionType,
              marks: questionDto.marks,
              negativeMarks: questionDto.negativeMarks,
              difficultyLevel: questionDto.difficultyLevel ?? 'MEDIUM',
              correctAnswer: questionDto.correctAnswer,
              answerHint: questionDto.answerHint,
              imageUrl: questionDto.imageUrl,
              sortOrder: questionDto.sortOrder ?? qIdx,
            },
          })

          // Create options if provided (for MCQ questions)
          if (questionDto.options && questionDto.options.length > 0) {
            await tx.questionOption.createMany({
              data: questionDto.options.map((opt, optIdx) => ({
                questionId: question.id,
                optionText: opt.optionText,
                optionLabel: opt.optionLabel,
                isCorrect: opt.isCorrect ?? false,
                sortOrder: opt.sortOrder ?? optIdx,
              })),
            })
          }
        }
      }

      return paper
    })

    // Fetch the complete question paper with all relations
    const fullPaper = await this.prisma.questionPaper.findUnique({
      where: { id: questionPaper.id },
      include: this.getQuestionPaperIncludes(),
    })

    return {
      success: true,
      message:
        'Question paper created successfully with all sections and questions',
      data: fullPaper,
    }
  }

  async getQuestionPaper(userUuid: string, examinationId: number) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const questionPaper = await this.prisma.questionPaper.findUnique({
      where: { examinationId },
      include: this.getQuestionPaperIncludes(),
    })

    if (!questionPaper) {
      throw new NotFoundException(
        `Question paper for examination ${examinationId} not found`
      )
    }

    // Verify access - teacher must be the creator
    if (questionPaper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to view this question paper'
      )
    }

    return {
      success: true,
      data: questionPaper,
    }
  }

  async getQuestionPaperById(userUuid: string, paperId: number) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const questionPaper = await this.prisma.questionPaper.findUnique({
      where: { id: paperId },
      include: this.getQuestionPaperIncludes(),
    })

    if (!questionPaper) {
      throw new NotFoundException(`Question paper with ID ${paperId} not found`)
    }

    if (questionPaper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to view this question paper'
      )
    }

    return {
      success: true,
      data: questionPaper,
    }
  }

  async updateQuestionPaper(
    userUuid: string,
    paperId: number,
    dto: UpdateQuestionPaperDto
  ) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const paper = await this.prisma.questionPaper.findUnique({
      where: { id: paperId },
    })

    if (!paper) {
      throw new NotFoundException(`Question paper with ID ${paperId} not found`)
    }

    if (paper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to update this question paper'
      )
    }

    if (paper.status === 'PUBLISHED' && dto.status !== 'ARCHIVED') {
      throw new BadRequestException(
        'Cannot modify a published question paper. Archive it first.'
      )
    }

    const updated = await this.prisma.questionPaper.update({
      where: { id: paperId },
      data: dto,
      include: this.getQuestionPaperIncludes(),
    })

    return {
      success: true,
      message: 'Question paper updated successfully',
      data: updated,
    }
  }

  async publishQuestionPaper(userUuid: string, paperId: number) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const paper = await this.prisma.questionPaper.findUnique({
      where: { id: paperId },
      include: { sections: { include: { questions: true } } },
    })

    if (!paper) {
      throw new NotFoundException(`Question paper with ID ${paperId} not found`)
    }

    if (paper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to publish this question paper'
      )
    }

    if (paper.status === 'PUBLISHED') {
      throw new BadRequestException('Question paper is already published')
    }

    // Validate paper has at least one section with questions
    if (paper.sections.length === 0) {
      throw new BadRequestException(
        'Cannot publish: Question paper must have at least one section'
      )
    }

    const hasQuestions = paper.sections.some(s => s.questions.length > 0)
    if (!hasQuestions) {
      throw new BadRequestException(
        'Cannot publish: Question paper must have at least one question'
      )
    }

    const updated = await this.prisma.questionPaper.update({
      where: { id: paperId },
      data: { status: 'PUBLISHED' },
      include: this.getQuestionPaperIncludes(),
    })

    return {
      success: true,
      message: 'Question paper published successfully',
      data: updated,
    }
  }

  async deleteQuestionPaper(userUuid: string, paperId: number) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const paper = await this.prisma.questionPaper.findUnique({
      where: { id: paperId },
    })

    if (!paper) {
      throw new NotFoundException(`Question paper with ID ${paperId} not found`)
    }

    if (paper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to delete this question paper'
      )
    }

    if (paper.status === 'PUBLISHED') {
      throw new BadRequestException(
        'Cannot delete a published question paper. Archive it first.'
      )
    }

    await this.prisma.questionPaper.delete({ where: { id: paperId } })

    return {
      success: true,
      message: 'Question paper deleted successfully',
    }
  }

  // ============ Section Methods ============

  async addSection(userUuid: string, paperId: number, dto: CreateSectionDto) {
    const teacher = await this.getTeacherByUuid(userUuid)
    const paper = await this.verifyPaperAccess(paperId, teacher.id)

    if (paper.status === 'PUBLISHED') {
      throw new BadRequestException('Cannot modify a published question paper')
    }

    // Get max sort order
    const maxSort = await this.prisma.questionSection.aggregate({
      where: { questionPaperId: paperId },
      _max: { sortOrder: true },
    })

    const section = await this.prisma.questionSection.create({
      data: {
        questionPaperId: paperId,
        sectionName: dto.sectionName,
        instructions: dto.instructions,
        totalMarks: dto.totalMarks ?? 0,
        sortOrder: dto.sortOrder ?? (maxSort._max.sortOrder ?? 0) + 1,
      },
      include: { questions: true },
    })

    return {
      success: true,
      message: 'Section added successfully',
      data: section,
    }
  }

  async updateSection(
    userUuid: string,
    sectionId: number,
    dto: UpdateSectionDto
  ) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const section = await this.prisma.questionSection.findUnique({
      where: { id: sectionId },
      include: { questionPaper: true },
    })

    if (!section) {
      throw new NotFoundException(`Section with ID ${sectionId} not found`)
    }

    if (section.questionPaper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to update this section'
      )
    }

    if (section.questionPaper.status === 'PUBLISHED') {
      throw new BadRequestException('Cannot modify a published question paper')
    }

    const updated = await this.prisma.questionSection.update({
      where: { id: sectionId },
      data: dto,
      include: { questions: { include: { options: true } } },
    })

    return {
      success: true,
      message: 'Section updated successfully',
      data: updated,
    }
  }

  async deleteSection(userUuid: string, sectionId: number) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const section = await this.prisma.questionSection.findUnique({
      where: { id: sectionId },
      include: { questionPaper: true, questions: true },
    })

    if (!section) {
      throw new NotFoundException(`Section with ID ${sectionId} not found`)
    }

    if (section.questionPaper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to delete this section'
      )
    }

    if (section.questionPaper.status === 'PUBLISHED') {
      throw new BadRequestException('Cannot modify a published question paper')
    }

    // Delete section (cascade will delete questions and options)
    await this.prisma.questionSection.delete({ where: { id: sectionId } })

    // Update paper totals
    await this.updatePaperTotals(section.questionPaperId)

    return {
      success: true,
      message: 'Section deleted successfully',
    }
  }

  // ============ Question Methods ============

  async addQuestion(
    userUuid: string,
    sectionId: number,
    dto: CreateQuestionDto
  ) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const section = await this.prisma.questionSection.findUnique({
      where: { id: sectionId },
      include: { questionPaper: true },
    })

    if (!section) {
      throw new NotFoundException(`Section with ID ${sectionId} not found`)
    }

    if (section.questionPaper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to add questions to this section'
      )
    }

    if (section.questionPaper.status === 'PUBLISHED') {
      throw new BadRequestException('Cannot modify a published question paper')
    }

    // Get max sort order
    const maxSort = await this.prisma.question.aggregate({
      where: { sectionId },
      _max: { sortOrder: true },
    })

    const question = await this.prisma.question.create({
      data: {
        sectionId,
        questionText: dto.questionText,
        questionType: dto.questionType,
        marks: dto.marks,
        negativeMarks: dto.negativeMarks,
        difficultyLevel: dto.difficultyLevel ?? 'MEDIUM',
        correctAnswer: dto.correctAnswer,
        answerHint: dto.answerHint,
        imageUrl: dto.imageUrl,
        sortOrder: dto.sortOrder ?? (maxSort._max.sortOrder ?? 0) + 1,
      },
    })

    // Create options if provided
    if (dto.options && dto.options.length > 0) {
      await this.prisma.questionOption.createMany({
        data: dto.options.map((opt, idx) => ({
          questionId: question.id,
          optionText: opt.optionText,
          optionLabel: opt.optionLabel,
          isCorrect: opt.isCorrect ?? false,
          sortOrder: opt.sortOrder ?? idx,
        })),
      })
    }

    // Update totals
    await this.updateSectionTotals(sectionId)
    await this.updatePaperTotals(section.questionPaperId)

    const questionWithOptions = await this.prisma.question.findUnique({
      where: { id: question.id },
      include: { options: { orderBy: { sortOrder: 'asc' } } },
    })

    return {
      success: true,
      message: 'Question added successfully',
      data: questionWithOptions,
    }
  }

  async bulkAddQuestions(
    userUuid: string,
    sectionId: number,
    dto: BulkCreateQuestionsDto
  ) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const section = await this.prisma.questionSection.findUnique({
      where: { id: sectionId },
      include: { questionPaper: true },
    })

    if (!section) {
      throw new NotFoundException(`Section with ID ${sectionId} not found`)
    }

    if (section.questionPaper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to add questions to this section'
      )
    }

    if (section.questionPaper.status === 'PUBLISHED') {
      throw new BadRequestException('Cannot modify a published question paper')
    }

    const results = {
      created: 0,
      failed: 0,
      errors: [] as string[],
    }

    // Get current max sort order
    const maxSort = await this.prisma.question.aggregate({
      where: { sectionId },
      _max: { sortOrder: true },
    })
    let currentSort = (maxSort._max.sortOrder ?? 0) + 1

    for (const questionDto of dto.questions) {
      try {
        const question = await this.prisma.question.create({
          data: {
            sectionId,
            questionText: questionDto.questionText,
            questionType: questionDto.questionType,
            marks: questionDto.marks,
            negativeMarks: questionDto.negativeMarks,
            difficultyLevel: questionDto.difficultyLevel ?? 'MEDIUM',
            correctAnswer: questionDto.correctAnswer,
            answerHint: questionDto.answerHint,
            imageUrl: questionDto.imageUrl,
            sortOrder: questionDto.sortOrder ?? currentSort++,
          },
        })

        if (questionDto.options && questionDto.options.length > 0) {
          await this.prisma.questionOption.createMany({
            data: questionDto.options.map((opt, idx) => ({
              questionId: question.id,
              optionText: opt.optionText,
              optionLabel: opt.optionLabel,
              isCorrect: opt.isCorrect ?? false,
              sortOrder: opt.sortOrder ?? idx,
            })),
          })
        }

        results.created++
      } catch (error) {
        results.failed++
        results.errors.push(
          `Question "${questionDto.questionText.substring(0, 30)}...": ${error.message}`
        )
      }
    }

    // Update totals
    await this.updateSectionTotals(sectionId)
    await this.updatePaperTotals(section.questionPaperId)

    return {
      success: true,
      message: `Added ${results.created} questions, ${results.failed} failed`,
      data: results,
    }
  }

  async updateQuestion(
    userUuid: string,
    questionId: number,
    dto: UpdateQuestionDto
  ) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const question = await this.prisma.question.findUnique({
      where: { id: questionId },
      include: { section: { include: { questionPaper: true } } },
    })

    if (!question) {
      throw new NotFoundException(`Question with ID ${questionId} not found`)
    }

    if (question.section.questionPaper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to update this question'
      )
    }

    if (question.section.questionPaper.status === 'PUBLISHED') {
      throw new BadRequestException('Cannot modify a published question paper')
    }

    const updated = await this.prisma.question.update({
      where: { id: questionId },
      data: dto,
      include: { options: { orderBy: { sortOrder: 'asc' } } },
    })

    // Update totals if marks changed
    if (dto.marks !== undefined) {
      await this.updateSectionTotals(question.sectionId)
      await this.updatePaperTotals(question.section.questionPaperId)
    }

    return {
      success: true,
      message: 'Question updated successfully',
      data: updated,
    }
  }

  async deleteQuestion(userUuid: string, questionId: number) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const question = await this.prisma.question.findUnique({
      where: { id: questionId },
      include: { section: { include: { questionPaper: true } } },
    })

    if (!question) {
      throw new NotFoundException(`Question with ID ${questionId} not found`)
    }

    if (question.section.questionPaper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to delete this question'
      )
    }

    if (question.section.questionPaper.status === 'PUBLISHED') {
      throw new BadRequestException('Cannot modify a published question paper')
    }

    const sectionId = question.sectionId
    const paperId = question.section.questionPaperId

    await this.prisma.question.delete({ where: { id: questionId } })

    // Update totals
    await this.updateSectionTotals(sectionId)
    await this.updatePaperTotals(paperId)

    return {
      success: true,
      message: 'Question deleted successfully',
    }
  }

  // ============ Option Methods ============

  async addOption(userUuid: string, questionId: number, dto: CreateOptionDto) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const question = await this.prisma.question.findUnique({
      where: { id: questionId },
      include: { section: { include: { questionPaper: true } } },
    })

    if (!question) {
      throw new NotFoundException(`Question with ID ${questionId} not found`)
    }

    if (question.section.questionPaper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to add options to this question'
      )
    }

    if (question.section.questionPaper.status === 'PUBLISHED') {
      throw new BadRequestException('Cannot modify a published question paper')
    }

    const maxSort = await this.prisma.questionOption.aggregate({
      where: { questionId },
      _max: { sortOrder: true },
    })

    const option = await this.prisma.questionOption.create({
      data: {
        questionId,
        optionText: dto.optionText,
        optionLabel: dto.optionLabel,
        isCorrect: dto.isCorrect ?? false,
        sortOrder: dto.sortOrder ?? (maxSort._max.sortOrder ?? 0) + 1,
      },
    })

    return {
      success: true,
      message: 'Option added successfully',
      data: option,
    }
  }

  async updateOption(userUuid: string, optionId: number, dto: UpdateOptionDto) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const option = await this.prisma.questionOption.findUnique({
      where: { id: optionId },
      include: {
        question: {
          include: { section: { include: { questionPaper: true } } },
        },
      },
    })

    if (!option) {
      throw new NotFoundException(`Option with ID ${optionId} not found`)
    }

    if (option.question.section.questionPaper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to update this option'
      )
    }

    if (option.question.section.questionPaper.status === 'PUBLISHED') {
      throw new BadRequestException('Cannot modify a published question paper')
    }

    const updated = await this.prisma.questionOption.update({
      where: { id: optionId },
      data: dto,
    })

    return {
      success: true,
      message: 'Option updated successfully',
      data: updated,
    }
  }

  async deleteOption(userUuid: string, optionId: number) {
    const teacher = await this.getTeacherByUuid(userUuid)

    const option = await this.prisma.questionOption.findUnique({
      where: { id: optionId },
      include: {
        question: {
          include: { section: { include: { questionPaper: true } } },
        },
      },
    })

    if (!option) {
      throw new NotFoundException(`Option with ID ${optionId} not found`)
    }

    if (option.question.section.questionPaper.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to delete this option'
      )
    }

    if (option.question.section.questionPaper.status === 'PUBLISHED') {
      throw new BadRequestException('Cannot modify a published question paper')
    }

    await this.prisma.questionOption.delete({ where: { id: optionId } })

    return {
      success: true,
      message: 'Option deleted successfully',
    }
  }

  // ============ Student View ============

  async getPublishedQuestionPaper(studentUuid: string, examinationId: number) {
    // Verify student exists
    const student = await this.prisma.student.findFirst({
      where: { user: { uuid: studentUuid } },
    })

    if (!student) {
      throw new NotFoundException(`Student with UUID ${studentUuid} not found`)
    }

    const questionPaper = await this.prisma.questionPaper.findUnique({
      where: { examinationId },
      include: {
        examination: {
          select: {
            id: true,
            examName: true,
            examDate: true,
            startTime: true,
            durationMinutes: true,
            totalMarks: true,
            instructions: true,
            venue: true,
          },
        },
        sections: {
          orderBy: { sortOrder: 'asc' },
          include: {
            questions: {
              orderBy: { sortOrder: 'asc' },
              include: {
                options: { orderBy: { sortOrder: 'asc' } },
              },
            },
          },
        },
      },
    })

    if (!questionPaper) {
      throw new NotFoundException(
        `Question paper for examination ${examinationId} not found`
      )
    }

    if (questionPaper.status !== 'PUBLISHED') {
      throw new ForbiddenException('Question paper is not yet published')
    }

    // Hide correct answers and hints for students
    const sanitizedPaper = {
      ...questionPaper,
      sections: questionPaper.sections.map(section => ({
        ...section,
        questions: section.questions.map(question => ({
          id: question.id,
          questionText: question.questionText,
          questionType: question.questionType,
          marks: question.marks,
          negativeMarks: question.negativeMarks,
          difficultyLevel: question.difficultyLevel,
          imageUrl: question.imageUrl,
          sortOrder: question.sortOrder,
          options: question.options.map(opt => ({
            id: opt.id,
            optionText: opt.optionText,
            optionLabel: opt.optionLabel,
            sortOrder: opt.sortOrder,
            // isCorrect is hidden
          })),
          // correctAnswer and answerHint are hidden
        })),
      })),
    }

    return {
      success: true,
      data: sanitizedPaper,
    }
  }

  // ============ Helper Methods ============

  private async getTeacherByUuid(userUuid: string) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    return teacher
  }

  private async verifyPaperAccess(paperId: number, teacherId: number) {
    const paper = await this.prisma.questionPaper.findUnique({
      where: { id: paperId },
    })

    if (!paper) {
      throw new NotFoundException(`Question paper with ID ${paperId} not found`)
    }

    if (paper.createdBy !== teacherId) {
      throw new ForbiddenException(
        'You do not have permission to access this question paper'
      )
    }

    return paper
  }

  private getQuestionPaperIncludes() {
    return {
      examination: {
        select: {
          id: true,
          examName: true,
          examType: true,
          examDate: true,
          totalMarks: true,
          subject: { select: { subjectName: true, subjectCode: true } },
        },
      },
      creator: {
        select: {
          id: true,
          employeeId: true,
          user: { select: { name: true, email: true } },
        },
      },
      sections: {
        orderBy: { sortOrder: 'asc' as const },
        include: {
          questions: {
            orderBy: { sortOrder: 'asc' as const },
            include: {
              options: { orderBy: { sortOrder: 'asc' as const } },
            },
          },
        },
      },
    }
  }

  private async updateSectionTotals(sectionId: number) {
    const totals = await this.prisma.question.aggregate({
      where: { sectionId },
      _sum: { marks: true },
    })

    await this.prisma.questionSection.update({
      where: { id: sectionId },
      data: { totalMarks: totals._sum.marks ?? 0 },
    })
  }

  private async updatePaperTotals(paperId: number) {
    const sections = await this.prisma.questionSection.findMany({
      where: { questionPaperId: paperId },
      include: { _count: { select: { questions: true } } },
    })

    const totalQuestions = sections.reduce(
      (sum, s) => sum + s._count.questions,
      0
    )
    const totalMarks = sections.reduce((sum, s) => sum + s.totalMarks, 0)

    await this.prisma.questionPaper.update({
      where: { id: paperId },
      data: { totalQuestions, totalMarks },
    })
  }
}
