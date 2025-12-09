import { Transform } from 'class-transformer'
import { IsEnum, IsNumber, IsOptional, IsString } from 'class-validator'

export enum SubjectQueryStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
}

/**
 * Query DTO for filtering subjects
 */
export class SubjectQueryDto {
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
  institutionId?: number

  @IsOptional()
  @IsString()
  @IsEnum(SubjectQueryStatus)
  status?: string
}

/**
 * Query DTO for subject stats
 */
export class SubjectStatsQueryDto {
  @IsOptional()
  @Transform(({ value }) => {
    if (value === '' || value === undefined || value === null) return undefined
    const parsed = parseInt(value, 10)
    return isNaN(parsed) ? undefined : parsed
  })
  @IsNumber()
  institutionId?: number
}
