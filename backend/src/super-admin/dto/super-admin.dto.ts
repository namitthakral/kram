import { IsOptional, IsString, IsIn, IsNumber, Min, Max } from 'class-validator'
import { Transform } from 'class-transformer'

/**
 * Query parameters for institution overview
 */
export class InstitutionOverviewQueryDto {
  @IsOptional()
  @IsString()
  @IsIn(['ACTIVE', 'INACTIVE'])
  status?: 'ACTIVE' | 'INACTIVE'

  @IsOptional()
  @IsString()
  @IsIn(['SCHOOL', 'COLLEGE', 'UNIVERSITY', 'INSTITUTE'])
  type?: 'SCHOOL' | 'COLLEGE' | 'UNIVERSITY' | 'INSTITUTE'

  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number = 20

  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsNumber()
  @Min(0)
  offset?: number = 0

  @IsOptional()
  @IsString()
  search?: string
}

/**
 * Query parameters for user growth trends
 */
export class UserGrowthQueryDto {
  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsNumber()
  @Min(1)
  @Max(24)
  months?: number = 12
}

/**
 * Query parameters for recent activity
 */
export class RecentActivityQueryDto {
  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number = 20

  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsNumber()
  @Min(1)
  @Max(30)
  days?: number = 7
}