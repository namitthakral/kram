import {
  IsDateString,
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator'

export class CreateExaminationDto {
  @IsString()
  examName: string

  @IsNumber()
  subjectId: number

  @IsNumber()
  semesterId: number

  @IsEnum(['QUIZ', 'MIDTERM', 'FINAL', 'ASSIGNMENT'])
  examType: string

  @IsDateString()
  examDate: string

  @IsString()
  @IsOptional()
  startTime?: string

  @IsNumber()
  @Min(0)
  @IsOptional()
  durationMinutes?: number = 120

  @IsNumber()
  @Min(0)
  @IsOptional()
  totalMarks?: number = 100

  @IsNumber()
  @Min(0)
  @IsOptional()
  passingMarks?: number = 40

  @IsString()
  @IsOptional()
  venue?: string

  @IsString()
  @IsOptional()
  instructions?: string

  @IsString()
  @IsOptional()
  syllabus?: string

  @IsEnum(['DRAFT', 'SCHEDULED', 'ONGOING', 'COMPLETED', 'CANCELLED'])
  @IsOptional()
  status?: string = 'SCHEDULED'
}

export class UpdateExaminationDto {
  @IsString()
  @IsOptional()
  examName?: string

  @IsNumber()
  @IsOptional()
  subjectId?: number

  @IsNumber()
  @IsOptional()
  semesterId?: number

  @IsEnum(['QUIZ', 'MIDTERM', 'FINAL', 'ASSIGNMENT'])
  @IsOptional()
  examType?: string

  @IsDateString()
  @IsOptional()
  examDate?: string

  @IsString()
  @IsOptional()
  startTime?: string

  @IsNumber()
  @Min(0)
  @IsOptional()
  durationMinutes?: number

  @IsNumber()
  @Min(0)
  @IsOptional()
  totalMarks?: number

  @IsNumber()
  @Min(0)
  @IsOptional()
  passingMarks?: number

  @IsString()
  @IsOptional()
  venue?: string

  @IsString()
  @IsOptional()
  instructions?: string

  @IsString()
  @IsOptional()
  syllabus?: string

  @IsEnum(['DRAFT', 'SCHEDULED', 'ONGOING', 'COMPLETED', 'CANCELLED'])
  @IsOptional()
  status?: string
}
