import {
  IsDateString,
  IsDecimal,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

export enum FeeStatus {
  PENDING = 'PENDING',
  PARTIAL = 'PARTIAL',
  PAID = 'PAID',
  OVERDUE = 'OVERDUE',
  WAIVED = 'WAIVED',
}

export class CreateStudentFeeDto {
  @IsInt()
  studentId: number;

  @IsInt()
  feeStructureId: number;

  @IsInt()
  @IsOptional()
  semesterId?: number;

  @Type(() => Number)
  @IsDecimal({ decimal_digits: '2' })
  @Min(0)
  amountDue: number;

  @Type(() => Number)
  @IsDecimal({ decimal_digits: '2' })
  @IsOptional()
  @Min(0)
  discount?: number;

  @IsDateString()
  dueDate: string;

  @IsString()
  @IsOptional()
  remarks?: string;
}

export class UpdateStudentFeeDto {
  @Type(() => Number)
  @IsDecimal({ decimal_digits: '2' })
  @IsOptional()
  @Min(0)
  amountDue?: number;

  @Type(() => Number)
  @IsDecimal({ decimal_digits: '2' })
  @IsOptional()
  @Min(0)
  discount?: number;

  @IsDateString()
  @IsOptional()
  dueDate?: string;

  @IsEnum(FeeStatus)
  @IsOptional()
  status?: FeeStatus;

  @IsString()
  @IsOptional()
  remarks?: string;
}

export class StudentFeeQueryDto {
  @IsInt()
  @Type(() => Number)
  @IsOptional()
  studentId?: number;

  @IsInt()
  @Type(() => Number)
  @IsOptional()
  institutionId?: number;

  @IsInt()
  @Type(() => Number)
  @IsOptional()
  semesterId?: number;

  @IsInt()
  @Type(() => Number)
  @IsOptional()
  courseId?: number;

  @IsEnum(FeeStatus)
  @IsOptional()
  status?: FeeStatus;

  @IsInt()
  @Type(() => Number)
  @IsOptional()
  page?: number = 1;

  @IsInt()
  @Type(() => Number)
  @IsOptional()
  limit?: number = 10;
}

export class BulkCreateStudentFeesDto {
  @IsInt({ each: true })
  studentIds: number[];

  @IsInt()
  feeStructureId: number;

  @IsInt()
  @IsOptional()
  semesterId?: number;

  @Type(() => Number)
  @IsDecimal({ decimal_digits: '2' })
  @IsOptional()
  @Min(0)
  discount?: number;

  @IsString()
  @IsOptional()
  remarks?: string;
}
