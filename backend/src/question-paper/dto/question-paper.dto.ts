import { Type } from 'class-transformer'
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator'

// Enums matching Prisma schema
export enum QuestionPaperStatus {
  DRAFT = 'DRAFT',
  READY = 'READY',
  PUBLISHED = 'PUBLISHED',
  ARCHIVED = 'ARCHIVED',
}

export enum QuestionType {
  MCQ = 'MCQ',
  MCQ_MULTI = 'MCQ_MULTI',
  TRUE_FALSE = 'TRUE_FALSE',
  FILL_BLANK = 'FILL_BLANK',
  SHORT_ANSWER = 'SHORT_ANSWER',
  LONG_ANSWER = 'LONG_ANSWER',
  NUMERICAL = 'NUMERICAL',
  MATCH_FOLLOWING = 'MATCH_FOLLOWING',
}

export enum DifficultyLevel {
  EASY = 'EASY',
  MEDIUM = 'MEDIUM',
  HARD = 'HARD',
}

// ============ Question Paper DTOs ============

export class CreateQuestionPaperDto {
  @IsNumber()
  @IsPositive()
  examinationId: number

  @IsString()
  @MinLength(1)
  @MaxLength(200)
  title: string

  @IsOptional()
  @IsString()
  instructions?: string

  @IsNumber()
  @Min(0)
  totalMarks: number
}

export class UpdateQuestionPaperDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  title?: string

  @IsOptional()
  @IsString()
  instructions?: string

  @IsOptional()
  @IsNumber()
  @Min(0)
  totalMarks?: number

  @IsOptional()
  @IsEnum(QuestionPaperStatus)
  status?: QuestionPaperStatus
}

// ============ Question Section DTOs ============

export class CreateSectionDto {
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  sectionName: string

  @IsOptional()
  @IsString()
  instructions?: string

  @IsOptional()
  @IsNumber()
  @Min(0)
  totalMarks?: number

  @IsOptional()
  @IsNumber()
  sortOrder?: number
}

export class UpdateSectionDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  sectionName?: string

  @IsOptional()
  @IsString()
  instructions?: string

  @IsOptional()
  @IsNumber()
  @Min(0)
  totalMarks?: number

  @IsOptional()
  @IsNumber()
  sortOrder?: number
}

// ============ Question Option DTOs ============

export class CreateOptionDto {
  @IsString()
  @MinLength(1)
  optionText: string

  @IsString()
  @MaxLength(5)
  optionLabel: string // A, B, C, D

  @IsOptional()
  @IsBoolean()
  isCorrect?: boolean

  @IsOptional()
  @IsNumber()
  sortOrder?: number
}

export class UpdateOptionDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  optionText?: string

  @IsOptional()
  @IsString()
  @MaxLength(5)
  optionLabel?: string

  @IsOptional()
  @IsBoolean()
  isCorrect?: boolean

  @IsOptional()
  @IsNumber()
  sortOrder?: number
}

// ============ Question DTOs ============

export class CreateQuestionDto {
  @IsString()
  @MinLength(1)
  questionText: string

  @IsEnum(QuestionType)
  questionType: QuestionType

  @IsNumber()
  @Min(0)
  marks: number

  @IsOptional()
  @IsNumber()
  @Min(0)
  negativeMarks?: number

  @IsOptional()
  @IsEnum(DifficultyLevel)
  difficultyLevel?: DifficultyLevel

  @IsOptional()
  @IsString()
  correctAnswer?: string // For non-MCQ questions or MCQ single answer (option label)

  @IsOptional()
  @IsString()
  answerHint?: string

  @IsOptional()
  @IsString()
  @MaxLength(500)
  imageUrl?: string

  @IsOptional()
  @IsNumber()
  sortOrder?: number

  // For MCQ questions, include options
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateOptionDto)
  options?: CreateOptionDto[]
}

export class UpdateQuestionDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  questionText?: string

  @IsOptional()
  @IsEnum(QuestionType)
  questionType?: QuestionType

  @IsOptional()
  @IsNumber()
  @Min(0)
  marks?: number

  @IsOptional()
  @IsNumber()
  @Min(0)
  negativeMarks?: number

  @IsOptional()
  @IsEnum(DifficultyLevel)
  difficultyLevel?: DifficultyLevel

  @IsOptional()
  @IsString()
  correctAnswer?: string

  @IsOptional()
  @IsString()
  answerHint?: string

  @IsOptional()
  @IsString()
  @MaxLength(500)
  imageUrl?: string

  @IsOptional()
  @IsNumber()
  sortOrder?: number
}

// ============ Bulk Operations DTOs ============

export class BulkCreateQuestionsDto {
  @IsArray()
  @ValidateNested({ each: true })
  @ArrayMinSize(1)
  @Type(() => CreateQuestionDto)
  questions: CreateQuestionDto[]
}

// Full question paper creation with sections and questions
export class CreateFullQuestionPaperDto {
  @IsNumber()
  @IsPositive()
  examinationId: number

  @IsString()
  @MinLength(1)
  @MaxLength(200)
  title: string

  @IsOptional()
  @IsString()
  instructions?: string

  @IsArray()
  @ValidateNested({ each: true })
  @ArrayMinSize(1)
  @Type(() => SectionWithQuestionsDto)
  sections: SectionWithQuestionsDto[]
}

export class SectionWithQuestionsDto {
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  sectionName: string

  @IsOptional()
  @IsString()
  instructions?: string

  @IsOptional()
  @IsNumber()
  sortOrder?: number

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateQuestionDto)
  questions: CreateQuestionDto[]
}
