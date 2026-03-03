import { IsNotEmpty, IsOptional, IsString, IsInt, IsEnum, Min } from 'class-validator'
import { Transform } from 'class-transformer'

export class CreateClassSectionDto {
  @IsNotEmpty()
  @IsString()
  sectionName: string

  @IsNotEmpty()
  @Transform(({ value }) => parseInt(value))
  @IsInt()
  subjectId: number

  @IsNotEmpty()
  @Transform(({ value }) => parseInt(value))
  @IsInt()
  semesterId: number

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
  schedule?: string

  @IsOptional()
  @IsString()
  room?: string

  @IsOptional()
  @IsEnum(['ACTIVE', 'INACTIVE'])
  status?: 'ACTIVE' | 'INACTIVE'
}