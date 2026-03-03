import { IsNotEmpty, IsOptional, IsString, IsInt, IsEnum, Min } from 'class-validator'
import { Transform } from 'class-transformer'

export class CreateClassDivisionDto {
  @IsNotEmpty()
  @Transform(({ value }) => parseInt(value))
  @IsInt()
  courseId: number

  @IsNotEmpty()
  @IsString()
  sectionName: string

  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsInt()
  teacherId?: number

  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsInt()
  @Min(1)
  maxCapacity?: number

  @IsOptional()
  @IsString()
  roomNumber?: string

  @IsOptional()
  @IsString()
  schedule?: string

  @IsOptional()
  @IsEnum(['ACTIVE', 'INACTIVE'])
  status?: 'ACTIVE' | 'INACTIVE'
}