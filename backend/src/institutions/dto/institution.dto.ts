import { InstitutionType } from '@prisma/client'
import { Transform } from 'class-transformer'
import {
  IsEmail,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator'

export class CreateInstitutionDto {
  @IsString()
  @MinLength(2)
  @MaxLength(200)
  name: string

  @IsEnum(InstitutionType)
  type: InstitutionType

  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(4)
  @Matches(/^[A-Z0-9]+$/, {
    message: 'Code must be 2-4 uppercase alphanumeric characters',
  })
  code?: string

  @IsOptional()
  @IsString()
  @MaxLength(500)
  address?: string

  @IsOptional()
  @IsString()
  @MaxLength(100)
  city?: string

  @IsOptional()
  @IsString()
  @MaxLength(100)
  state?: string

  @IsOptional()
  @IsString()
  @MaxLength(100)
  country?: string

  @IsOptional()
  @IsString()
  @MaxLength(20)
  postalCode?: string

  @IsOptional()
  @IsString()
  @MaxLength(15)
  phone?: string

  @IsOptional()
  @IsEmail()
  @MaxLength(100)
  @Transform(({ value }) => value?.toLowerCase().trim())
  email?: string

  @IsOptional()
  @IsString()
  @MaxLength(200)
  website?: string

  @IsOptional()
  @IsInt()
  establishedYear?: number

  @IsOptional()
  @IsString()
  @MaxLength(100)
  accreditation?: string
}

export class UpdateInstitutionDto {
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(200)
  name?: string

  @IsOptional()
  @IsEnum(InstitutionType)
  type?: InstitutionType

  @IsOptional()
  @IsString()
  @MaxLength(500)
  address?: string

  @IsOptional()
  @IsString()
  @MaxLength(100)
  city?: string

  @IsOptional()
  @IsString()
  @MaxLength(100)
  state?: string

  @IsOptional()
  @IsString()
  @MaxLength(100)
  country?: string

  @IsOptional()
  @IsString()
  @MaxLength(20)
  postalCode?: string

  @IsOptional()
  @IsString()
  @MaxLength(15)
  phone?: string

  @IsOptional()
  @IsEmail()
  @MaxLength(100)
  @Transform(({ value }) => value?.toLowerCase().trim())
  email?: string

  @IsOptional()
  @IsString()
  @MaxLength(200)
  website?: string

  @IsOptional()
  @IsInt()
  establishedYear?: number

  @IsOptional()
  @IsString()
  @MaxLength(100)
  accreditation?: string
}
