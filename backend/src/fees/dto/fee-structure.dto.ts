import {
  IsBoolean,
  IsDateString,
  IsDecimal,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

export enum FeeType {
  TUITION = 'TUITION',
  ADMISSION = 'ADMISSION',
  EXAMINATION = 'EXAMINATION',
  LIBRARY = 'LIBRARY',
  LABORATORY = 'LABORATORY',
  TRANSPORT = 'TRANSPORT',
  HOSTEL = 'HOSTEL',
  SPORTS = 'SPORTS',
  DEVELOPMENT = 'DEVELOPMENT',
  MISCELLANEOUS = 'MISCELLANEOUS',
}

export enum RecurringFrequency {
  MONTHLY = 'MONTHLY',
  QUARTERLY = 'QUARTERLY',
  SEMESTER = 'SEMESTER',
  ANNUAL = 'ANNUAL',
}

export enum FeeStructureStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  ARCHIVED = 'ARCHIVED',
}

export class CreateFeeStructureDto {
  @IsInt()
  institutionId: number;

  @IsInt()
  @IsOptional()
  courseId?: number;

  @IsInt()
  academicYearId: number;

  @IsEnum(FeeType)
  feeType: FeeType;

  @IsString()
  @MaxLength(100)
  feeName: string;

  @Type(() => Number)
  @IsDecimal({ decimal_digits: '2' })
  @Min(0)
  amount: number;

  @IsDateString()
  @IsOptional()
  dueDate?: string;

  @Type(() => Number)
  @IsDecimal({ decimal_digits: '2' })
  @IsOptional()
  @Min(0)
  lateFeeAmount?: number;

  @IsInt()
  @IsOptional()
  @Min(1)
  lateFeeAfterDays?: number;

  @IsBoolean()
  @IsOptional()
  isRecurring?: boolean;

  @IsEnum(RecurringFrequency)
  @IsOptional()
  recurringFrequency?: RecurringFrequency;

  @IsString()
  @IsOptional()
  description?: string;

  @IsEnum(FeeStructureStatus)
  @IsOptional()
  status?: FeeStructureStatus;
}

export class UpdateFeeStructureDto {
  @IsInt()
  @IsOptional()
  courseId?: number;

  @IsEnum(FeeType)
  @IsOptional()
  feeType?: FeeType;

  @IsString()
  @MaxLength(100)
  @IsOptional()
  feeName?: string;

  @Type(() => Number)
  @IsDecimal({ decimal_digits: '2' })
  @IsOptional()
  @Min(0)
  amount?: number;

  @IsDateString()
  @IsOptional()
  dueDate?: string;

  @Type(() => Number)
  @IsDecimal({ decimal_digits: '2' })
  @IsOptional()
  @Min(0)
  lateFeeAmount?: number;

  @IsInt()
  @IsOptional()
  @Min(1)
  lateFeeAfterDays?: number;

  @IsBoolean()
  @IsOptional()
  isRecurring?: boolean;

  @IsEnum(RecurringFrequency)
  @IsOptional()
  recurringFrequency?: RecurringFrequency;

  @IsString()
  @IsOptional()
  description?: string;

  @IsEnum(FeeStructureStatus)
  @IsOptional()
  status?: FeeStructureStatus;
}

export class FeeStructureQueryDto {
  @IsInt()
  @Type(() => Number)
  @IsOptional()
  institutionId?: number;

  @IsInt()
  @Type(() => Number)
  @IsOptional()
  courseId?: number;

  @IsInt()
  @Type(() => Number)
  @IsOptional()
  academicYearId?: number;

  @IsEnum(FeeType)
  @IsOptional()
  feeType?: FeeType;

  @IsEnum(FeeStructureStatus)
  @IsOptional()
  status?: FeeStructureStatus;

  @IsInt()
  @Type(() => Number)
  @IsOptional()
  page?: number = 1;

  @IsInt()
  @Type(() => Number)
  @IsOptional()
  limit?: number = 10;
}
