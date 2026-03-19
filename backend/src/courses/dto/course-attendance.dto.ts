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

export class CourseAttendanceRecordDto {
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

export class CourseAttendanceDto {
  @IsDateString()
  @IsNotEmpty()
  date: string

  @IsArray()
  @ValidateNested({ each: true })
  @ArrayMinSize(1)
  @Type(() => CourseAttendanceRecordDto)
  attendanceRecords: CourseAttendanceRecordDto[]
}