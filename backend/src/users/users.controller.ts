import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common'
import { UsersService } from './users.service'
import { CreateUserDto, UpdateUserDto, UserQueryDto } from './dto/user.dto'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { Roles } from '../auth/decorators/roles.decorator'
import { CurrentUser } from '../auth/decorators/current-user.decorator'
import { UserWithRelations } from '../types/auth.types'

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

  @Get(':id')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.findOne(id)
  }

  @Patch('profile')
  updateProfile(
    @CurrentUser() user: UserWithRelations,
    @Body() updateUserDto: UpdateUserDto
  ) {
    return this.usersService.update(user.id, updateUserDto)
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateUserDto: UpdateUserDto
  ) {
    return this.usersService.update(id, updateUserDto)
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.remove(id)
  }

  @Delete(':id/hard')
  @UseGuards(RolesGuard)
  @Roles('super_admin')
  @HttpCode(HttpStatus.NO_CONTENT)
  hardDelete(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.hardDelete(id)
  }
}
