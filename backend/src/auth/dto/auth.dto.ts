import { Transform } from 'class-transformer'
import {
  IsDateString,
  IsEmail,
  IsInt,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator'

export class LoginDto {
  @IsOptional()
  @IsEmail()
  email?: string

  @IsOptional()
  @IsString()
  phone?: string

  @IsOptional()
  @IsString()
  kramid?: string

  @IsString()
  @MinLength(1)
  password: string
}

export class SelfRegistrationDto {
  @IsString()
  firstName: string

  @IsString()
  lastName: string

  @IsOptional()
  @IsEmail()
  email?: string

  @IsOptional()
  @IsString()
  phoneNumber?: string

  @IsString()
  @MinLength(6)
  password: string

  @IsInt()
  @Transform(({ value }) => Number(value))
  roleId: number

  @IsOptional()
  @IsInt()
  @Transform(({ value }) => Number(value))
  institutionId?: number

  @IsOptional()
  @IsString()
  childKramid?: string // For parents mapping to existing students

  @IsOptional()
  @IsDateString()
  dateOfBirth?: string
}

export class ChangePasswordDto {
  @IsString()
  currentPassword: string

  @IsString()
  @MinLength(6)
  newPassword: string
}

export class ParentChildMappingDto {
  @IsString()
  childKramid: string
}

export class ActivateAccountDto {
  @IsString()
  kramid: string

  @IsString()
  temporaryPassword: string

  @IsString()
  @MinLength(6)
  newPassword: string
}

// Re-export the unified CreateUserDto
export { CreateUserDto } from '../../common/dto/user.dto'
