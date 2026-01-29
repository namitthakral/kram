import { Type } from 'class-transformer';
import { IsBoolean, IsEnum, IsInt, IsOptional, IsString } from 'class-validator';
import { CommunicationPriority, CommunicationType } from './create-communication.dto';

export class CommunicationQueryDto {
  @IsOptional()
  @IsEnum(CommunicationType)
  type?: CommunicationType;

  @IsOptional()
  @IsEnum(CommunicationPriority)
  priority?: CommunicationPriority;

  @IsOptional()
  @IsString()
  targetAudience?: string; // Single role filter (e.g., 'student')

  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  isEmergency?: boolean;

  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  isPinned?: boolean;

  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  isActive?: boolean;

  @IsOptional()
  @IsInt()
  @Type(() => Number)
  institutionId?: number;

  @IsOptional()
  @IsString()
  search?: string; // Search in title and content

  // Pagination
  @IsOptional()
  @IsInt()
  @Type(() => Number)
  page?: number = 1;

  @IsOptional()
  @IsInt()
  @Type(() => Number)
  limit?: number = 10;

  // Date range filters
  @IsOptional()
  @IsString()
  startDate?: string;

  @IsOptional()
  @IsString()
  endDate?: string;
}

