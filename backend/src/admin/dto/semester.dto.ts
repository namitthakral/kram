import { IsDateString, IsInt, IsNotEmpty, IsOptional, IsString, Min } from 'class-validator'

export class CreateSemesterDto {
  @IsInt()
  @IsNotEmpty()
  academicYearId: number

  @IsString()
  @IsNotEmpty()
  semesterName: string

  @IsInt()
  @Min(1)
  @IsNotEmpty()
  semesterNumber: number

  @IsDateString()
  @IsNotEmpty()
  startDate: string

  @IsDateString()
  @IsNotEmpty()
  endDate: string

  @IsDateString()
  @IsOptional()
  registrationStart?: string

  @IsDateString()
  @IsOptional()
  registrationEnd?: string
}

export class UpdateSemesterDto {
  @IsString()
  @IsOptional()
  semesterName?: string

  @IsInt()
  @Min(1)
  @IsOptional()
  semesterNumber?: number

  @IsDateString()
  @IsOptional()
  startDate?: string

  @IsDateString()
  @IsOptional()
  endDate?: string

  @IsDateString()
  @IsOptional()
  registrationStart?: string

  @IsDateString()
  @IsOptional()
  registrationEnd?: string

  @IsString()
  @IsOptional()
  status?: 'UPCOMING' | 'ACTIVE' | 'COMPLETED'
}
