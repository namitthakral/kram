import { IsNotEmpty, IsOptional, IsString, IsInt, IsEnum, Min, Max } from 'class-validator'
import { Transform } from 'class-transformer'

export class CreateCourseDto {
  @IsNotEmpty()
  @IsString()
  name: string

  @IsOptional()
  @IsString()
  code?: string

  @IsOptional()
  @IsString()
  description?: string

  @IsNotEmpty()
  @IsEnum(['BACHELORS', 'MASTERS', 'DIPLOMA', 'CERTIFICATE', 'PHD', 'OTHER', 'SCHOOL'])
  degreeType: 'BACHELORS' | 'MASTERS' | 'DIPLOMA' | 'CERTIFICATE' | 'PHD' | 'OTHER' | 'SCHOOL'

  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsInt()
  @Min(1)
  @Max(10)
  duration?: number

  @IsOptional()
  @IsString()
  durationUnit?: string

  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsInt()
  @Min(1)
  totalSemesters?: number

  @IsNotEmpty()
  @Transform(({ value }) => parseInt(value))
  @IsInt()
  institutionId: number

  @IsOptional()
  @IsEnum(['ACTIVE', 'INACTIVE'])
  status?: 'ACTIVE' | 'INACTIVE'
}