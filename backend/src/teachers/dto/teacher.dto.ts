import { EmploymentType, TeacherEmploymentStatus, UserAccountStatus } from '@prisma/client'
import { Transform } from 'class-transformer'
import {
  IsArray,
  IsDateString,
  IsDecimal,
  IsEmail,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator'

export class CreateTeacherDto {
  // User fields - will be used to create the user automatically
  @IsString()
  @MinLength(1)
  firstName: string

  @IsString()
  @MinLength(1)
  lastName: string

  @IsEmail()
  @Transform(({ value }) => value?.toLowerCase().trim())
  email: string

  @IsString()
  @MinLength(10)
  phone: string

  @IsOptional()
  @IsString()
  @MinLength(6)
  password?: string

  // Teacher-specific fields
  @IsInt()
  institutionId: number

  @IsString()
  employeeId: string

  @IsOptional()
  @IsString()
  designation?: string

  @IsOptional()
  @IsString()
  specialization?: string

  @IsOptional()
  @IsString()
  qualification?: string

  @IsOptional()
  @IsInt()
  experienceYears?: number

  @IsOptional()
  @IsDateString()
  joinDate?: string

  @IsOptional()
  @IsDecimal()
  salary?: number

  @IsOptional()
  @IsEnum(EmploymentType)
  employmentType?: EmploymentType

  @IsOptional()
  @IsString()
  officeLocation?: string

  @IsOptional()
  @IsString()
  officeHours?: string

  @IsOptional()
  @IsString()
  researchInterests?: string

  @IsOptional()
  @IsString()
  publications?: string

  @IsOptional()
  @IsEnum(TeacherEmploymentStatus)
  employmentStatus?: TeacherEmploymentStatus
}

export class UpdateTeacherDto {
  @IsOptional()
  @IsString()
  employeeId?: string

  @IsOptional()
  @IsString()
  designation?: string

  @IsOptional()
  @IsString()
  specialization?: string

  @IsOptional()
  @IsString()
  qualification?: string

  @IsOptional()
  @IsInt()
  experienceYears?: number

  @IsOptional()
  @IsDateString()
  joinDate?: string

  @IsOptional()
  @IsDecimal()
  salary?: number

  @IsOptional()
  @IsEnum(EmploymentType)
  employmentType?: EmploymentType

  @IsOptional()
  @IsString()
  officeLocation?: string

  @IsOptional()
  @IsString()
  officeHours?: string

  @IsOptional()
  @IsString()
  researchInterests?: string

  @IsOptional()
  @IsString()
  publications?: string

  @IsOptional()
  @IsEnum(TeacherEmploymentStatus)
  employmentStatus?: TeacherEmploymentStatus

  // Controls the linked User's account status (ACTIVE / INACTIVE)
  @IsOptional()
  @IsEnum(UserAccountStatus)
  userAccountStatus?: UserAccountStatus

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  subjectIds?: number[]

  @IsOptional()
  @IsInt()
  academicYearId?: number
}

export class TeacherQueryDto {
  @IsOptional()
  @Transform(({ value }) => (value ? parseInt(value, 10) : 1))
  @IsInt()
  page?: number = 1

  @IsOptional()
  @Transform(({ value }) => (value ? parseInt(value, 10) : 10))
  @IsInt()
  limit?: number = 10

  @IsOptional()
  @IsString()
  search?: string

  @IsOptional()
  @Transform(({ value }) =>
    value === '' || value === null || value === undefined
      ? undefined
      : parseInt(value, 10)
  )
  @IsInt()
  institutionId?: number

  @IsOptional()
  @Transform(({ value }) =>
    value === '' || value === null || value === undefined ? undefined : value
  )
  @IsEnum(EmploymentType)
  employmentType?: EmploymentType

  @IsOptional()
  @Transform(({ value }) =>
    value === '' || value === null || value === undefined ? undefined : value
  )
  @IsEnum(TeacherEmploymentStatus)
  employmentStatus?: TeacherEmploymentStatus

  @IsOptional()
  @IsString()
  sortBy?: string = 'createdAt'

  @IsOptional()
  @IsEnum(['asc', 'desc'])
  sortOrder?: 'asc' | 'desc' = 'desc'
}

export class AssignSubjectsDto {
  @IsArray()
  @IsInt({ each: true })
  subjectIds: number[]

  @IsInt()
  academicYearId: number
}

export class BatchReportCardDto {
  @IsOptional()
  @IsInt()
  sectionId?: number

  @IsOptional()
  @IsInt()
  courseId?: number

  @IsOptional()
  @IsInt()
  semesterId?: number

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  studentIds?: number[]

  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  includeExamDetails?: boolean = true
}
