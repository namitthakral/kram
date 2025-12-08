import { Transform } from 'class-transformer'
import {
  IsArray,
  IsBoolean,
  IsEnum,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator'

// Enums matching Prisma schema
export enum DayOfWeek {
  MONDAY = 'MONDAY',
  TUESDAY = 'TUESDAY',
  WEDNESDAY = 'WEDNESDAY',
  THURSDAY = 'THURSDAY',
  FRIDAY = 'FRIDAY',
  SATURDAY = 'SATURDAY',
  SUNDAY = 'SUNDAY',
}

export enum SlotType {
  LECTURE = 'LECTURE',
  PRACTICAL = 'PRACTICAL',
  TUTORIAL = 'TUTORIAL',
  BREAK = 'BREAK',
  LUNCH = 'LUNCH',
  ASSEMBLY = 'ASSEMBLY',
  SPORTS = 'SPORTS',
  LIBRARY = 'LIBRARY',
  STUDY_HALL = 'STUDY_HALL',
}

export enum RoomType {
  CLASSROOM = 'CLASSROOM',
  LABORATORY = 'LABORATORY',
  LIBRARY = 'LIBRARY',
  AUDITORIUM = 'AUDITORIUM',
  SPORTS_ROOM = 'SPORTS_ROOM',
  COMPUTER_LAB = 'COMPUTER_LAB',
  CONFERENCE_ROOM = 'CONFERENCE_ROOM',
  STAFF_ROOM = 'STAFF_ROOM',
  PRINCIPAL_OFFICE = 'PRINCIPAL_OFFICE',
  MEDICAL_ROOM = 'MEDICAL_ROOM',
}

// ============ TimeSlot DTOs ============

export class CreateTimeSlotDto {
  @IsNumber()
  @IsPositive()
  institutionId: number

  @IsString()
  @MinLength(1)
  @MaxLength(50)
  slotName: string

  @IsString()
  startTime: string // Format: "HH:mm" e.g., "09:00"

  @IsString()
  endTime: string // Format: "HH:mm" e.g., "09:45"

  @IsEnum(SlotType)
  slotType: SlotType

  @IsNumber()
  @IsPositive()
  duration: number // in minutes

  @IsNumber()
  sortOrder: number

  @IsOptional()
  @IsBoolean()
  isActive?: boolean = true
}

export class UpdateTimeSlotDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  slotName?: string

  @IsOptional()
  @IsString()
  startTime?: string

  @IsOptional()
  @IsString()
  endTime?: string

  @IsOptional()
  @IsEnum(SlotType)
  slotType?: SlotType

  @IsOptional()
  @IsNumber()
  @IsPositive()
  duration?: number

  @IsOptional()
  @IsNumber()
  sortOrder?: number

  @IsOptional()
  @IsBoolean()
  isActive?: boolean
}

// ============ Room DTOs ============

export class CreateRoomDto {
  @IsNumber()
  @IsPositive()
  institutionId: number

  @IsString()
  @MinLength(1)
  @MaxLength(20)
  roomNumber: string

  @IsOptional()
  @IsString()
  @MaxLength(100)
  roomName?: string

  @IsEnum(RoomType)
  roomType: RoomType

  @IsOptional()
  @IsString()
  @MaxLength(100)
  building?: string

  @IsOptional()
  @IsString()
  @MaxLength(20)
  floor?: string

  @IsOptional()
  @IsNumber()
  @IsPositive()
  capacity?: number

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  facilities?: string[]

  @IsOptional()
  @IsBoolean()
  isActive?: boolean = true
}

export class UpdateRoomDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(20)
  roomNumber?: string

  @IsOptional()
  @IsString()
  @MaxLength(100)
  roomName?: string

  @IsOptional()
  @IsEnum(RoomType)
  roomType?: RoomType

  @IsOptional()
  @IsString()
  @MaxLength(100)
  building?: string

  @IsOptional()
  @IsString()
  @MaxLength(20)
  floor?: string

  @IsOptional()
  @IsNumber()
  @IsPositive()
  capacity?: number

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  facilities?: string[]

  @IsOptional()
  @IsBoolean()
  isActive?: boolean
}

// ============ Timetable DTOs ============

export class CreateTimetableEntryDto {
  @IsNumber()
  @IsPositive()
  institutionId: number

  @IsNumber()
  @IsPositive()
  academicYearId: number

  @IsNumber()
  @IsPositive()
  semesterId: number

  @IsOptional()
  @IsNumber()
  @IsPositive()
  courseId?: number

  @IsOptional()
  @IsString()
  @MaxLength(10)
  section?: string

  @IsEnum(DayOfWeek)
  dayOfWeek: DayOfWeek

  @IsNumber()
  @IsPositive()
  timeSlotId: number

  @IsNumber()
  @IsPositive()
  subjectId: number

  @IsNumber()
  @IsPositive()
  teacherId: number

  @IsOptional()
  @IsNumber()
  @IsPositive()
  roomId?: number

  @IsOptional()
  @IsBoolean()
  isActive?: boolean = true
}

export class UpdateTimetableEntryDto {
  @IsOptional()
  @IsNumber()
  @IsPositive()
  courseId?: number

  @IsOptional()
  @IsString()
  @MaxLength(10)
  section?: string

  @IsOptional()
  @IsEnum(DayOfWeek)
  dayOfWeek?: DayOfWeek

  @IsOptional()
  @IsNumber()
  @IsPositive()
  timeSlotId?: number

  @IsOptional()
  @IsNumber()
  @IsPositive()
  subjectId?: number

  @IsOptional()
  @IsNumber()
  @IsPositive()
  teacherId?: number

  @IsOptional()
  @IsNumber()
  @IsPositive()
  roomId?: number

  @IsOptional()
  @IsBoolean()
  isActive?: boolean
}

// Bulk create for efficiency
export class BulkCreateTimetableDto {
  @IsNumber()
  @IsPositive()
  institutionId: number

  @IsNumber()
  @IsPositive()
  academicYearId: number

  @IsNumber()
  @IsPositive()
  semesterId: number

  @IsArray()
  entries: Omit<
    CreateTimetableEntryDto,
    'institutionId' | 'academicYearId' | 'semesterId'
  >[]
}

// ============ Query DTOs ============

export class TimetableQueryDto {
  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  institutionId?: number

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  academicYearId?: number

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  semesterId?: number

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  courseId?: number

  @IsOptional()
  @IsString()
  section?: string

  @IsOptional()
  @IsEnum(DayOfWeek)
  dayOfWeek?: DayOfWeek

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  teacherId?: number

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  subjectId?: number

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  roomId?: number
}

export class TimeSlotQueryDto {
  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  institutionId?: number

  @IsOptional()
  @IsEnum(SlotType)
  slotType?: SlotType

  @IsOptional()
  @Transform(({ value }) => value === 'true')
  @IsBoolean()
  isActive?: boolean
}

export class RoomQueryDto {
  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsNumber()
  institutionId?: number

  @IsOptional()
  @IsEnum(RoomType)
  roomType?: RoomType

  @IsOptional()
  @Transform(({ value }) => value === 'true')
  @IsBoolean()
  isActive?: boolean

  @IsOptional()
  @IsString()
  building?: string
}
