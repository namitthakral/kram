import {
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

export enum PaymentMethod {
  CASH = 'CASH',
  CHEQUE = 'CHEQUE',
  BANK_TRANSFER = 'BANK_TRANSFER',
  ONLINE = 'ONLINE',
  UPI = 'UPI',
  CARD = 'CARD',
}

export enum PaymentMode {
  OFFLINE = 'OFFLINE',
  ONLINE = 'ONLINE',
}

export enum PaymentStatus {
  PENDING = 'PENDING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
  CANCELLED = 'CANCELLED',
  REFUNDED = 'REFUNDED',
}

export class CreatePaymentDto {
  @IsInt()
  studentId: number;

  @IsInt()
  @IsOptional()
  studentFeeId?: number;

  @Type(() => Number)
  @IsDecimal({ decimal_digits: '2' })
  @Min(0)
  amount: number;

  @IsEnum(PaymentMethod)
  paymentMethod: PaymentMethod;

  @IsEnum(PaymentMode)
  paymentMode: PaymentMode;

  @IsString()
  @MaxLength(100)
  @IsOptional()
  transactionId?: string;

  @IsString()
  @MaxLength(100)
  @IsOptional()
  referenceNumber?: string;

  @IsString()
  @MaxLength(100)
  @IsOptional()
  bankName?: string;

  @IsString()
  @MaxLength(50)
  @IsOptional()
  chequeNumber?: string;

  @IsDateString()
  @IsOptional()
  chequeDate?: string;

  @IsDateString()
  @IsOptional()
  paymentDate?: string;

  @IsString()
  @IsOptional()
  remarks?: string;
}

export class UpdatePaymentDto {
  @IsEnum(PaymentStatus)
  @IsOptional()
  status?: PaymentStatus;

  @IsString()
  @MaxLength(100)
  @IsOptional()
  transactionId?: string;

  @IsString()
  @MaxLength(100)
  @IsOptional()
  referenceNumber?: string;

  @IsString()
  @IsOptional()
  remarks?: string;
}

export class PaymentQueryDto {
  @IsInt()
  @Type(() => Number)
  @IsOptional()
  studentId?: number;

  @IsInt()
  @Type(() => Number)
  @IsOptional()
  institutionId?: number;

  @IsEnum(PaymentStatus)
  @IsOptional()
  status?: PaymentStatus;

  @IsEnum(PaymentMethod)
  @IsOptional()
  paymentMethod?: PaymentMethod;

  @IsDateString()
  @IsOptional()
  startDate?: string;

  @IsDateString()
  @IsOptional()
  endDate?: string;

  @IsInt()
  @Type(() => Number)
  @IsOptional()
  page?: number = 1;

  @IsInt()
  @Type(() => Number)
  @IsOptional()
  limit?: number = 10;
}

export class ProcessPaymentDto extends CreatePaymentDto {
  @IsInt()
  processedBy: number;
}
