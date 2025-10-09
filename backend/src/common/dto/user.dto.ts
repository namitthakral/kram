import {
  IsEmail,
  IsString,
  IsOptional,
  IsEnum,
  IsDateString,
  IsBoolean,
  IsInt,
  MinLength,
  Matches,
} from 'class-validator'
import { Transform } from 'class-transformer'
import { UserStatus } from '@prisma/client'

export class CreateUserDto {
  @IsString()
  @MinLength(2)
  firstName: string

  @IsString()
  @MinLength(2)
  lastName: string

  @IsEmail()
  email: string

  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/, {
    message:
      'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character',
  })
  password: string

  @IsInt()
  @Transform(({ value }) => Number(value))
  roleId: number

  @IsOptional()
  @IsString()
  phoneNumber?: string

  @IsOptional()
  @IsString()
  address?: string

  @IsOptional()
  @IsString()
  city?: string

  @IsOptional()
  @IsString()
  state?: string

  @IsOptional()
  @IsString()
  zipCode?: string

  @IsOptional()
  @IsString()
  country?: string

  @IsOptional()
  @IsDateString()
  dateOfBirth?: string

  @IsOptional()
  @IsString()
  gender?: string

  @IsOptional()
  @IsString()
  profilePicture?: string

  @IsOptional()
  @IsBoolean()
  isVerified?: boolean

  @IsOptional()
  @IsBoolean()
  accountLocked?: boolean

  @IsOptional()
  @IsEnum(UserStatus)
  status?: UserStatus
}

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  @MinLength(2)
  firstName?: string

  @IsOptional()
  @IsString()
  @MinLength(2)
  lastName?: string

  @IsOptional()
  @IsEmail()
  email?: string

  @IsOptional()
  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/, {
    message:
      'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character',
  })
  password?: string

  @IsOptional()
  @IsInt()
  @Transform(({ value }) => Number(value))
  roleId?: number

  @IsOptional()
  @IsString()
  phoneNumber?: string

  @IsOptional()
  @IsString()
  address?: string

  @IsOptional()
  @IsString()
  city?: string

  @IsOptional()
  @IsString()
  state?: string

  @IsOptional()
  @IsString()
  zipCode?: string

  @IsOptional()
  @IsString()
  country?: string

  @IsOptional()
  @IsDateString()
  dateOfBirth?: string

  @IsOptional()
  @IsString()
  gender?: string

  @IsOptional()
  @IsString()
  profilePicture?: string

  @IsOptional()
  @IsBoolean()
  isVerified?: boolean

  @IsOptional()
  @IsBoolean()
  accountLocked?: boolean

  @IsOptional()
  @IsEnum(UserStatus)
  status?: UserStatus
}

export class UserQueryDto {
  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsInt()
  page?: number = 1

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsInt()
  limit?: number = 10

  @IsOptional()
  @IsString()
  search?: string

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsInt()
  roleId?: number

  @IsOptional()
  @IsEnum(UserStatus)
  status?: UserStatus

  @IsOptional()
  @IsString()
  sortBy?: string = 'createdAt'

  @IsOptional()
  @IsString()
  sortOrder?: 'asc' | 'desc' = 'desc'
}
