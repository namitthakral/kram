import {
  IsString,
  IsNumber,
  IsOptional,
  IsBoolean,
  IsDateString,
  IsEnum,
  MinLength,
  MaxLength,
  IsPositive,
} from 'class-validator'
import { StudentType, ResidentialStatus } from '../../types'

export class CreateStudentDto {
  @IsNumber()
  @IsPositive()
  userId: number

  @IsNumber()
  @IsPositive()
  institutionId: number

  @IsNumber()
  @IsPositive()
  @IsOptional()
  programId?: number

  @IsString()
  @MinLength(1)
  @MaxLength(50)
  admissionNumber: string

  @IsString()
  @MaxLength(50)
  @IsOptional()
  rollNumber?: string

  @IsDateString()
  @IsOptional()
  admissionDate?: string

  @IsNumber()
  @IsOptional()
  currentSemester?: number

  @IsNumber()
  @IsOptional()
  currentYear?: number

  @IsString()
  @MaxLength(20)
  @IsOptional()
  gradeLevel?: string

  @IsString()
  @MaxLength(10)
  @IsOptional()
  section?: string

  @IsEnum(StudentType)
  @IsOptional()
  studentType?: StudentType

  @IsEnum(ResidentialStatus)
  @IsOptional()
  residentialStatus?: ResidentialStatus

  @IsBoolean()
  @IsOptional()
  transportRequired?: boolean

  @IsString()
  @MaxLength(100)
  @IsOptional()
  emergencyContactName?: string

  @IsString()
  @IsOptional()
  emergencyContactPhone?: string

  @IsString()
  @MaxLength(5)
  @IsOptional()
  bloodGroup?: string

  @IsString()
  @IsOptional()
  medicalConditions?: string
}

export class UpdateStudentDto {
  @IsString()
  @MaxLength(50)
  @IsOptional()
  rollNumber?: string

  @IsDateString()
  @IsOptional()
  admissionDate?: string

  @IsNumber()
  @IsOptional()
  currentSemester?: number

  @IsNumber()
  @IsOptional()
  currentYear?: number

  @IsString()
  @MaxLength(20)
  @IsOptional()
  gradeLevel?: string

  @IsString()
  @MaxLength(10)
  @IsOptional()
  section?: string

  @IsEnum(StudentType)
  @IsOptional()
  studentType?: StudentType

  @IsEnum(ResidentialStatus)
  @IsOptional()
  residentialStatus?: ResidentialStatus

  @IsBoolean()
  @IsOptional()
  transportRequired?: boolean

  @IsString()
  @MaxLength(100)
  @IsOptional()
  emergencyContactName?: string

  @IsString()
  @IsOptional()
  emergencyContactPhone?: string

  @IsString()
  @MaxLength(5)
  @IsOptional()
  bloodGroup?: string

  @IsString()
  @IsOptional()
  medicalConditions?: string
}

export class PaginationDto {
  @IsNumber()
  @IsOptional()
  page?: number = 1

  @IsNumber()
  @IsOptional()
  limit?: number = 10

  @IsString()
  @IsOptional()
  sortBy?: string = 'createdAt'

  @IsString()
  @IsOptional()
  sortOrder?: 'asc' | 'desc' = 'desc'

  @IsString()
  @IsOptional()
  search?: string
}
