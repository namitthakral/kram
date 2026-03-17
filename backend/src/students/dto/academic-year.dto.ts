import { Transform } from 'class-transformer'
import {
  IsBoolean,
  IsDateString,
  IsDecimal,
  IsEnum,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator'
import { PromotionStatus } from '@prisma/client'

export class CreateStudentAcademicYearDto {
  @IsNumber()
  @IsPositive()
  studentId: number

  @IsNumber()
  @IsPositive()
  academicYearId: number

  @IsNumber()
  @IsPositive()
  classLevel: number

  @IsString()
  @MaxLength(10)
  @IsOptional()
  section?: string

  @IsString()
  @MinLength(1)
  @MaxLength(50)
  rollNumber: string

  @IsNumber()
  @IsOptional()
  classDivisionId?: number

  @IsNumber()
  @IsOptional()
  classTeacherId?: number

  @IsString()
  @MaxLength(50)
  @IsOptional()
  currentRollNumber?: string

  @IsString()
  @MaxLength(50)
  @IsOptional()
  boardRollNumber?: string

  @IsEnum(PromotionStatus)
  @IsOptional()
  promotionStatus?: PromotionStatus = PromotionStatus.IN_PROGRESS

  @IsString()
  @MaxLength(5)
  @IsOptional()
  finalGrade?: string

  @IsDecimal()
  @IsOptional()
  finalPercentage?: number

  @IsDecimal()
  @IsOptional()
  attendancePercentage?: number

  @IsNumber()
  @IsOptional()
  totalWorkingDays?: number = 0

  @IsNumber()
  @IsOptional()
  totalDaysPresent?: number = 0

  @IsDateString()
  enrollmentDate: string

  @IsDateString()
  @IsOptional()
  completionDate?: string
}

export class UpdateStudentAcademicYearDto {
  @IsNumber()
  @IsPositive()
  @IsOptional()
  classLevel?: number

  @IsString()
  @MaxLength(10)
  @IsOptional()
  section?: string

  @IsString()
  @MinLength(1)
  @MaxLength(50)
  @IsOptional()
  rollNumber?: string

  @IsNumber()
  @IsOptional()
  classDivisionId?: number

  @IsNumber()
  @IsOptional()
  classTeacherId?: number

  @IsString()
  @MaxLength(50)
  @IsOptional()
  currentRollNumber?: string

  @IsString()
  @MaxLength(50)
  @IsOptional()
  boardRollNumber?: string

  @IsEnum(PromotionStatus)
  @IsOptional()
  promotionStatus?: PromotionStatus

  @IsString()
  @MaxLength(5)
  @IsOptional()
  finalGrade?: string

  @IsDecimal()
  @IsOptional()
  finalPercentage?: number

  @IsDecimal()
  @IsOptional()
  attendancePercentage?: number

  @IsNumber()
  @IsOptional()
  totalWorkingDays?: number

  @IsNumber()
  @IsOptional()
  totalDaysPresent?: number

  @IsDateString()
  @IsOptional()
  enrollmentDate?: string

  @IsDateString()
  @IsOptional()
  completionDate?: string
}

export class PromoteStudentDto {
  @IsNumber()
  @IsPositive()
  currentAcademicYearId: number

  @IsNumber()
  @IsPositive()
  nextAcademicYearId: number

  @IsNumber()
  @IsPositive()
  nextClassLevel: number

  @IsString()
  @MaxLength(10)
  @IsOptional()
  nextSection?: string

  @IsString()
  @MinLength(1)
  @MaxLength(50)
  @IsOptional()
  nextRollNumber?: string

  @IsNumber()
  @IsOptional()
  nextClassDivisionId?: number

  @IsNumber()
  @IsOptional()
  nextClassTeacherId?: number

  @IsString()
  @MaxLength(5)
  @IsOptional()
  finalGrade?: string

  @IsDecimal()
  @IsOptional()
  finalPercentage?: number

  @IsDecimal()
  @IsOptional()
  finalAttendancePercentage?: number

  @IsString()
  @IsOptional()
  remarks?: string
}

export class StudentAcademicHistoryQueryDto {
  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  academicYearId?: number

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  classLevel?: number

  @IsOptional()
  @IsEnum(PromotionStatus)
  promotionStatus?: PromotionStatus

  @IsOptional()
  @Transform(({ value }) => value === 'true')
  @IsBoolean()
  includeCurrentYear?: boolean = true

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  limit?: number = 10
}

export class BulkPromotionDto {
  @IsNumber()
  @IsPositive()
  currentAcademicYearId: number

  @IsNumber()
  @IsPositive()
  nextAcademicYearId: number

  @IsNumber({}, { each: true })
  @IsPositive({ each: true })
  studentIds: number[]

  @IsNumber()
  @IsPositive()
  @IsOptional()
  nextClassDivisionId?: number

  @IsNumber()
  @IsOptional()
  nextClassTeacherId?: number

  @IsBoolean()
  @IsOptional()
  autoGenerateRollNumbers?: boolean = true
}