import {
  IsBoolean,
  IsDateString,
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator'

export class CreateAssignmentDto {
  @IsString()
  title: string

  @IsString()
  @IsOptional()
  description?: string

  @IsString()
  @IsOptional()
  instructions?: string

  @IsNumber()
  subjectId: number

  @IsNumber()
  @IsOptional()
  sectionId?: number

  @IsNumber()
  @Min(0)
  @IsOptional()
  maxMarks?: number = 100

  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  weightagePercentage?: number

  @IsDateString()
  dueDate: string

  @IsBoolean()
  @IsOptional()
  lateSubmissionAllowed?: boolean = true

  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  latePenaltyPercentage?: number = 0

  @IsString()
  @IsOptional()
  attachmentUrl?: string

  @IsEnum(['DRAFT', 'PUBLISHED', 'CLOSED'])
  @IsOptional()
  status?: string = 'DRAFT'
}

export class UpdateAssignmentDto {
  @IsString()
  @IsOptional()
  title?: string

  @IsString()
  @IsOptional()
  description?: string

  @IsString()
  @IsOptional()
  instructions?: string

  @IsNumber()
  @IsOptional()
  subjectId?: number

  @IsNumber()
  @IsOptional()
  sectionId?: number

  @IsNumber()
  @Min(0)
  @IsOptional()
  maxMarks?: number

  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  weightagePercentage?: number

  @IsDateString()
  @IsOptional()
  dueDate?: string

  @IsBoolean()
  @IsOptional()
  lateSubmissionAllowed?: boolean

  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  latePenaltyPercentage?: number

  @IsString()
  @IsOptional()
  attachmentUrl?: string

  @IsEnum(['DRAFT', 'PUBLISHED', 'CLOSED'])
  @IsOptional()
  status?: string
}
