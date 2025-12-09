import { Transform } from 'class-transformer'
import { IsEnum, IsNumber, IsOptional, IsString } from 'class-validator'

export enum CourseStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
}

/**
 * Query DTO for filtering courses
 */
export class CourseQueryDto {
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
  @IsEnum(CourseStatus)
  status?: string

  @IsOptional()
  @IsString()
  degreeType?: string
}

/**
 * Query DTO for courses with sections
 */
export class CoursesWithSectionsQueryDto {
  @IsOptional()
  @Transform(({ value }) => {
    if (value === '' || value === undefined || value === null) return undefined
    const parsed = parseInt(value, 10)
    return isNaN(parsed) ? undefined : parsed
  })
  @IsNumber()
  institutionId?: number
}
