import { Type } from 'class-transformer'
import {
  ArrayMinSize,
  IsArray,
  IsDateString,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator'

export enum AttendanceStatus {
  PRESENT = 'PRESENT',
  ABSENT = 'ABSENT',
  LATE = 'LATE',
  EXCUSED = 'EXCUSED',
}

export class MarkAttendanceDto {
  @IsInt()
  @IsNotEmpty()
  studentId: number

  @IsInt()
  @IsNotEmpty()
  sectionId: number

  @IsDateString()
  @IsNotEmpty()
  date: string

  @IsEnum(AttendanceStatus)
  @IsNotEmpty()
  status: AttendanceStatus

  @IsString()
  @IsOptional()
  remarks?: string
}

export class AttendanceRecordDto {
  @IsInt()
  @IsNotEmpty()
  studentId: number

  @IsEnum(AttendanceStatus)
  @IsNotEmpty()
  status: AttendanceStatus

  @IsString()
  @IsOptional()
  remarks?: string
}

export class BulkMarkAttendanceDto {
  @IsInt()
  @IsNotEmpty()
  sectionId: number

  @IsDateString()
  @IsNotEmpty()
  date: string

  @IsArray()
  @ValidateNested({ each: true })
  @ArrayMinSize(1)
  @Type(() => AttendanceRecordDto)
  attendanceRecords: AttendanceRecordDto[]
}

export class UpdateAttendanceDto {
  @IsEnum(AttendanceStatus)
  @IsOptional()
  status?: AttendanceStatus

  @IsString()
  @IsOptional()
  remarks?: string
}

export class AttendanceQueryDto {
  @IsInt()
  @IsOptional()
  @Type(() => Number)
  sectionId?: number

  @IsInt()
  @IsOptional()
  @Type(() => Number)
  studentId?: number

  @IsDateString()
  @IsOptional()
  startDate?: string

  @IsDateString()
  @IsOptional()
  endDate?: string

  @IsEnum(AttendanceStatus)
  @IsOptional()
  status?: AttendanceStatus

  @IsInt()
  @IsOptional()
  @Type(() => Number)
  limit?: number = 50

  @IsInt()
  @IsOptional()
  @Type(() => Number)
  offset?: number = 0

  @IsString()
  @IsOptional()
  sortBy?: 'date' | 'student' | 'section' | 'status' = 'date'

  @IsString()
  @IsOptional()
  sortOrder?: 'asc' | 'desc' = 'desc'
}
