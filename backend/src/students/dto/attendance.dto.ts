import { Transform } from 'class-transformer'
import {
  IsArray,
  IsDateString,
  IsEnum,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  ValidateNested,
} from 'class-validator'
import { Type } from 'class-transformer'
import { AttendanceStatus, AttendanceType } from '@prisma/client'

export class RecordAttendanceDto {
  @IsNumber()
  @IsPositive()
  studentId: number

  @IsDateString()
  date: string

  @IsEnum(AttendanceStatus)
  status: AttendanceStatus

  @IsEnum(AttendanceType)
  @IsOptional()
  attendanceType?: AttendanceType

  @IsNumber()
  @IsOptional()
  sectionId?: number

  @IsString()
  @IsOptional()
  remarks?: string
}

export class BulkAttendanceRecordDto {
  @IsNumber()
  @IsPositive()
  studentId: number

  @IsEnum(AttendanceStatus)
  status: AttendanceStatus

  @IsString()
  @IsOptional()
  remarks?: string
}

export class BulkAttendanceDto {
  @IsDateString()
  date: string

  @IsEnum(AttendanceType)
  @IsOptional()
  attendanceType?: AttendanceType

  @IsNumber()
  @IsOptional()
  sectionId?: number

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => BulkAttendanceRecordDto)
  records: BulkAttendanceRecordDto[]
}

export class AttendanceQueryDto {
  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  studentId?: number

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  academicYearId?: number

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  classLevel?: number

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  sectionId?: number

  @IsEnum(AttendanceType)
  @IsOptional()
  attendanceType?: AttendanceType

  @IsDateString()
  @IsOptional()
  startDate?: string

  @IsDateString()
  @IsOptional()
  endDate?: string

  @IsEnum(AttendanceStatus)
  @IsOptional()
  status?: AttendanceStatus

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  limit?: number = 50

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  offset?: number = 0
}