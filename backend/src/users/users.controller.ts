import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common'
import { CurrentUser } from '../auth/decorators/current-user.decorator'
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { UserWithRelations } from '../types/auth.types'
import { CreateUserDto, UpdateUserDto, UserQueryDto } from './dto/user.dto'
import { UsersService } from './users.service'

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto)
  }

  @Get()
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  findAll(@Query() query: UserQueryDto) {
    return this.usersService.findAll(query)
  }

  @Get('stats')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  getStats() {
    return this.usersService.getUsersStats()
  }

  @Get('role/:roleId')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  getUsersByRole(
    @Param('roleId', ParseIntPipe) roleId: number,
    @Query() query: UserQueryDto
  ) {
    return this.usersService.getUsersByRole(roleId, query)
  }

  @Get('profile')
  getProfile(@CurrentUser() user: UserWithRelations) {
    return this.usersService.findOne(user.id)
  }

  @Get(':user_uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  findOne(@Param('user_uuid') userUuid: string) {
    return this.usersService.findByUuid(userUuid)
  }

  @Patch('profile')
  updateProfile(
    @CurrentUser() user: UserWithRelations,
    @Body() updateUserDto: UpdateUserDto
  ) {
    return this.usersService.update(user.id, updateUserDto)
  }

  @Patch(':user_uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  update(
    @Param('user_uuid') userUuid: string,
    @Body() updateUserDto: UpdateUserDto
  ) {
    return this.usersService.updateByUuid(userUuid, updateUserDto)
  }

  @Delete(':user_uuid')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('user_uuid') userUuid: string) {
    return this.usersService.removeByUuid(userUuid)
  }

  @Delete(':user_uuid/hard')
  @UseGuards(RolesGuard)
  @Roles('super_admin')
  @HttpCode(HttpStatus.NO_CONTENT)
  hardDelete(@Param('user_uuid') userUuid: string) {
    return this.usersService.hardDeleteByUuid(userUuid)
  }
}
