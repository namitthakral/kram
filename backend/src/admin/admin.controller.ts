import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common'
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import {
  CreateUserDto,
  UpdateUserDto,
  UserQueryDto,
} from '../common/dto/user.dto'
import { UpdateInstitutionDto } from '../institutions/dto/institution.dto'
import { AdminService } from './admin.service'
import { UpdateGradingConfigDto } from './dto/grading-config.dto'

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('super_admin', 'admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Post('users')
  createInstitutionalUser(@Body() createUserDto: CreateUserDto) {
    return this.adminService.createInstitutionalUser(createUserDto)
  }

  @Get('users')
  getAllUsers(@Query() query: UserQueryDto) {
    return this.adminService.getAllUsers(query)
  }

  @Get('users/stats')
  getUsersStats() {
    return this.adminService.getUsersStats()
  }

  @Get('users/role/:roleId')
  getUsersByRole(
    @Param('roleId') roleId: string,
    @Query() query: UserQueryDto
  ) {
    return this.adminService.getUsersByRole(parseInt(roleId), query)
  }

  @Get('users/kramid/:kramid')
  getUserByKramId(@Param('kramid') kramid: string) {
    return this.adminService.getUserByKramId(kramid)
  }

  @Get('users/:user_uuid')
  getUser(@Param('user_uuid') userUuid: string) {
    return this.adminService.getUserByUuid(userUuid)
  }

  @Patch('users/:user_uuid')
  updateUser(
    @Param('user_uuid') userUuid: string,
    @Body() updateUserDto: UpdateUserDto
  ) {
    return this.adminService.updateUserByUuid(userUuid, updateUserDto)
  }

  @Delete('users/:user_uuid')
  @HttpCode(HttpStatus.NO_CONTENT)
  deleteUser(@Param('user_uuid') userUuid: string) {
    return this.adminService.deleteUserByUuid(userUuid)
  }

  @Delete('users/:user_uuid/hard')
  @Roles('super_admin') // Only super admin can hard delete
  @HttpCode(HttpStatus.NO_CONTENT)
  hardDeleteUser(@Param('user_uuid') userUuid: string) {
    return this.adminService.hardDeleteUserByUuid(userUuid)
  }

  @Post('users/bulk-import')
  bulkImportUsers(@Body() users: CreateUserDto[]) {
    return this.adminService.bulkImportUsers(users)
  }

  @Post('users/:user_uuid/unlock')
  @HttpCode(HttpStatus.OK)
  unlockAccount(@Param('user_uuid') userUuid: string) {
    return this.adminService.unlockAccount(userUuid)
  }

  // Institution profile (school info) for settings
  @Get('institutions/:institutionId')
  getInstitutionProfile(@Param('institutionId') institutionId: string) {
    return this.adminService.getInstitutionProfile(+institutionId)
  }

  @Put('institutions/:institutionId')
  updateInstitutionProfile(
    @Param('institutionId') institutionId: string,
    @Body() updateDto: UpdateInstitutionDto
  ) {
    return this.adminService.updateInstitutionProfile(+institutionId, updateDto)
  }

  // Grading Configuration Endpoints
  @Get('institutions/:institutionId/grading-config')
  getGradingConfig(@Param('institutionId') institutionId: string) {
    return this.adminService.getGradingConfig(+institutionId)
  }

  @Put('institutions/:institutionId/grading-config')
  updateGradingConfig(
    @Param('institutionId') institutionId: string,
    @Body() updateDto: UpdateGradingConfigDto
  ) {
    return this.adminService.updateGradingConfig(+institutionId, updateDto)
  }

  @Post('institutions/:institutionId/grading-config/reset')
  @HttpCode(HttpStatus.OK)
  resetGradingConfig(@Param('institutionId') institutionId: string) {
    return this.adminService.resetGradingConfig(+institutionId)
  }

  // Dashboard Analytics Endpoints
  @Get('dashboard-stats')
  getDashboardStats() {
    return this.adminService.getDashboardStats()
  }

  @Get('teacher-performance')
  getTeacherPerformance(@Query('limit') limit?: string) {
    return this.adminService.getTeacherPerformance(limit ? parseInt(limit) : 10)
  }

  @Get('attendance-trends')
  getAttendanceTrends(@Query('period') period?: string) {
    return this.adminService.getAttendanceTrends(period)
  }

  @Get('grade-distribution')
  getGradeDistribution() {
    return this.adminService.getGradeDistribution()
  }

  @Get('class-performance')
  getClassPerformance() {
    return this.adminService.getClassPerformance()
  }

  @Get('financial-overview')
  getFinancialOverview(@Query('period') period?: string) {
    return this.adminService.getFinancialOverview(period)
  }

  @Get('system-alerts')
  getSystemAlerts(
    @Query('severity') severity?: string,
    @Query('limit') limit?: string
  ) {
    return this.adminService.getSystemAlerts(
      severity,
      limit ? parseInt(limit) : 20
    )
  }
}
