import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common'
import { User } from '../types'
import { AuthService } from './auth.service'
import { CurrentUser } from './decorators/current-user.decorator'
import { Public } from './decorators/public.decorator'
import {
  ActivateAccountDto,
  ChangePasswordDto,
  LoginDto,
  ParentChildMappingDto,
  SelfRegistrationDto,
} from './dto/auth.dto'
import { JwtAuthGuard } from './guards/jwt-auth.guard'

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Public()
  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto)
  }

  @Public()
  @Post('register')
  async register(
    @Body() selfRegistrationDto: SelfRegistrationDto,
    @Query('inst') institutionCode?: string
  ) {
    return this.authService.selfRegister(selfRegistrationDto, institutionCode)
  }

  @UseGuards(JwtAuthGuard)
  @Post('refresh')
  async refresh(@CurrentUser() user: User) {
    return this.authService.refreshToken(user.id)
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
