import {
  IsEmail,
  IsEnum,
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
  edverseId?: string

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
  phone?: string

  @IsString()
  @MinLength(6)
  password: string

  @IsEnum(['student', 'teacher', 'parent', 'staff'])
  role: string

  @IsOptional()
  @IsString()
  childEdverseId?: string // For parents mapping to existing students
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
  childEdverseId: string
}

export class ActivateAccountDto {
  @IsString()
  edverseId: string

  @IsString()
  temporaryPassword: string

  @IsString()
  @MinLength(6)
  newPassword: string
}

// Re-export the unified CreateUserDto
export { CreateUserDto } from '../../common/dto/user.dto'
