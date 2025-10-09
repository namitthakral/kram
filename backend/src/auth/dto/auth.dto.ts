import { IsEmail, IsString, MinLength } from 'class-validator'

export class LoginDto {
  @IsEmail()
  email: string

  @IsString()
  @MinLength(1)
  password: string
}

// Re-export the unified CreateUserDto
export { CreateUserDto } from '../../common/dto/user.dto'
