import {
  IsString,
  IsInt,
  IsOptional,
  IsEnum,
  IsArray,
  Min,
  MaxLength,
  MinLength,
} from 'class-validator'

/**
 * Subject Type Enum
 * In Indian context: Type of subject
 */
export enum SubjectType {
  CORE = 'CORE',
  ELECTIVE = 'ELECTIVE',
  MINOR = 'MINOR',
  MAJOR = 'MAJOR',
}

export enum SubjectStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
}

/**
 * Create Subject DTO
 * 
 * Used for creating new subjects (papers that students study)
 * Examples: Data Structures, English, Physics, Chemistry
 */
export class CreateSubjectDto {
  @IsOptional()
  @IsInt()
  courseId?: number // Optional - can be null for general subjects not tied to a course/program

  @IsString()
  @MinLength(2)
  @MaxLength(200)
  subjectName: string // e.g., "Data Structures", "English Literature", "Physics"

  @IsString()
  @MinLength(2)
  @MaxLength(20)
  subjectCode: string // e.g., "CS201", "ENG101", "PHY10"

  @IsInt()
  @Min(1)
  credits: number // For colleges: credit hours; For schools: marks total

  @IsOptional()
  @IsInt()
  @Min(0)
  theoryHours?: number // Lecture/theory hours per week

  @IsOptional()
  @IsInt()
  @Min(0)
  practicalHours?: number // Lab/practical hours per week

  @IsOptional()
  @IsInt()
  @Min(0)
  tutorialHours?: number

  @IsOptional()
  @IsEnum(SubjectType)
  subjectType?: SubjectType // CORE, ELECTIVE, etc.

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  prerequisites?: number[] // Array of subject IDs that are prerequisites

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  description?: string

  @IsOptional()
  @IsString()
  syllabus?: string // Detailed syllabus content
}

/**
 * Update Subject DTO
 * 
 * All fields are optional for partial updates
 */
export class UpdateSubjectDto {
  @IsOptional()
  @IsInt()
  courseId?: number

  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(200)
  subjectName?: string

  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(20)
  subjectCode?: string

  @IsOptional()
  @IsInt()
  @Min(1)
  credits?: number

  @IsOptional()
  @IsInt()
  @Min(0)
  theoryHours?: number

  @IsOptional()
  @IsInt()
  @Min(0)
  practicalHours?: number

  @IsOptional()
  @IsInt()
  @Min(0)
  tutorialHours?: number

  @IsOptional()
  @IsEnum(SubjectType)
  subjectType?: SubjectType

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  prerequisites?: number[]

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  description?: string

  @IsOptional()
  @IsString()
  syllabus?: string

  @IsOptional()
  @IsEnum(SubjectStatus)
  status?: SubjectStatus
}

