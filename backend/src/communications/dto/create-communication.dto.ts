import {
    IsArray,
    IsBoolean,
    IsDateString,
    IsEnum,
    IsInt,
    IsOptional,
    IsString,
    MaxLength,
} from 'class-validator';

export enum CommunicationType {
  GENERAL = 'GENERAL',
  ACADEMIC = 'ACADEMIC',
  EXAMINATION = 'EXAMINATION',
  ADMISSION = 'ADMISSION',
  EVENT = 'EVENT',
  HOLIDAY = 'HOLIDAY',
  EMERGENCY = 'EMERGENCY',
  MAINTENANCE = 'MAINTENANCE',
  ACHIEVEMENT = 'ACHIEVEMENT',
  ALERT = 'ALERT',
}

export enum CommunicationPriority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  URGENT = 'URGENT',
}

export class CreateCommunicationDto {
  @IsInt()
  institutionId: number;

  @IsString()
  @MaxLength(200)
  title: string;

  @IsString()
  content: string;

  @IsEnum(CommunicationType)
  communicationType: CommunicationType;

  @IsEnum(CommunicationPriority)
  @IsOptional()
  priority?: CommunicationPriority = CommunicationPriority.MEDIUM;

  @IsArray()
  @IsString({ each: true })
  targetAudience: string[]; // e.g., ['student', 'teacher', 'parent']

  @IsArray()
  @IsInt({ each: true })
  @IsOptional()
  departmentIds?: number[] = [];

  @IsArray()
  @IsInt({ each: true })
  @IsOptional()
  programIds?: number[] = [];

  @IsArray()
  @IsInt({ each: true })
  @IsOptional()
  classIds?: number[] = [];

  @IsBoolean()
  @IsOptional()
  isEmergency?: boolean = false;

  @IsBoolean()
  @IsOptional()
  isPinned?: boolean = false;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean = true;

  @IsString()
  @IsOptional()
  @MaxLength(500)
  attachmentUrl?: string;

  @IsDateString()
  @IsOptional()
  publishDate?: string;

  @IsDateString()
  @IsOptional()
  expiryDate?: string;

  @IsInt()
  createdBy: number;
}

