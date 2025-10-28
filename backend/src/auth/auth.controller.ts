import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common'
import { User } from '../types'
import { AuthService } from './auth.service'
import { CurrentUser } from './decorators/current-user.decorator'
import { Public } from './decorators/public.decorator'
import { Roles } from './decorators/roles.decorator'
import {
  ActivateAccountDto,
  ChangePasswordDto,
  CreateUserDto,
  LoginDto,
  ParentChildMappingDto,
  SelfRegistrationDto,
} from './dto/auth.dto'
import { JwtAuthGuard } from './guards/jwt-auth.guard'
import { RolesGuard } from './guards/roles.guard'

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Public()
  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto)
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('super_admin', 'admin')
  @Post('register')
  async register(@Body() createUserDto: CreateUserDto) {
    return this.authService.register(createUserDto)
  }

  @UseGuards(JwtAuthGuard)
  @Post('refresh')
  async refresh(@CurrentUser() user: User) {
    return this.authService.refreshToken(user.id)
  }

  @Public()
  @Post('self-register')
  async selfRegister(@Body() selfRegistrationDto: SelfRegistrationDto) {
    return this.authService.selfRegister(selfRegistrationDto)
  }

  @Public()
  @Post('activate-account')
  async activateAccount(@Body() activateAccountDto: ActivateAccountDto) {
    return this.authService.activateAccount(activateAccountDto)
  }

  @UseGuards(JwtAuthGuard)
  @Post('change-password')
  async changePassword(
    @CurrentUser() user: User,
    @Body() changePasswordDto: ChangePasswordDto
  ) {
    return this.authService.changePassword(user.id, changePasswordDto)
  }

  @UseGuards(JwtAuthGuard)
  @Post('map-parent-child')
  async mapParentToChild(
    @CurrentUser() user: User,
    @Body() mappingDto: ParentChildMappingDto
  ) {
    return this.authService.mapParentToChild(user.id, mappingDto.childEdverseId)
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  async getProfile(@CurrentUser() user: User) {
    return {
      success: true,
      data: user,
    }
  }
}
