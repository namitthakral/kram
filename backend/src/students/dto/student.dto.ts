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
  IsEmail,
} from 'class-validator'
import { Transform } from 'class-transformer'
import { StudentType, ResidentialStatus } from '../../types'

export class CreateStudentDto {
  // User fields - will be used to create the user automatically
  @IsString()
  @MinLength(1)
  firstName: string

  @IsString()
  @MinLength(1)
  lastName: string

  @IsEmail()
  email: string

  @IsString()
  @MinLength(10)
  phone: string

  @IsOptional()
  @IsString()
  @MinLength(6)
  password?: string

  // Student-specific fields
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
  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  page?: number = 1

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
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
