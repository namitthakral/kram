import { Transform } from 'class-transformer'
import { IsEnum, IsNumber, IsOptional, IsString } from 'class-validator'

export enum ClassSectionStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
}

/**
 * Query DTO for filtering class sections
 *
 * Uses Transform to safely convert string query params to numbers
 * Empty strings are converted to undefined (skipped in filter)
 */
export class ClassSectionQueryDto {
  @IsOptional()
  @Transform(({ value }) => {
    if (value === '' || value === undefined || value === null) return undefined
    const parsed = parseInt(value, 10)
    return isNaN(parsed) ? undefined : parsed
  })
  @IsNumber()
  institutionId?: number

  @IsOptional()
  @Transform(({ value }) => {
    if (value === '' || value === undefined || value === null) return undefined
    const parsed = parseInt(value, 10)
    return isNaN(parsed) ? undefined : parsed
  })
  @IsNumber()
  semesterId?: number

  @IsOptional()
  @Transform(({ value }) => {
    if (value === '' || value === undefined || value === null) return undefined
    const parsed = parseInt(value, 10)
    return isNaN(parsed) ? undefined : parsed
  })
  @IsNumber()
  courseId?: number

  @IsOptional()
  @Transform(({ value }) => {
    if (value === '' || value === undefined || value === null) return undefined
    const parsed = parseInt(value, 10)
    return isNaN(parsed) ? undefined : parsed
  })
  @IsNumber()
  teacherId?: number

  @IsOptional()
  @IsString()
  @IsEnum(ClassSectionStatus)
  status?: string
}
