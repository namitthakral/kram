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
import { CurrentUser } from '../auth/decorators/current-user.decorator'
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { UserWithRelations } from '../types/auth.types'
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
  createInstitutionalUser(
    @Body() createUserDto: CreateUserDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.createInstitutionalUser(
      createUserDto,
      this.resolveInstitutionId(user)
    )
  }

  @Get('users')
  getAllUsers(
    @Query() query: UserQueryDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.getAllUsers(query, this.resolveInstitutionId(user))
  }

  @Get('users/stats')
  getUsersStats(@CurrentUser() user: UserWithRelations) {
    return this.adminService.getUsersStats(this.resolveInstitutionId(user))
  }

  @Get('users/role/:roleId')
  getUsersByRole(
    @Param('roleId') roleId: string,
    @Query() query: UserQueryDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.getUsersByRole(
      parseInt(roleId),
      query,
      this.resolveInstitutionId(user)
    )
  }

  @Get('users/kramid/:kramid')
  getUserByKramId(
    @Param('kramid') kramid: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.getUserByKramId(
      kramid,
      this.resolveInstitutionId(user)
    )
  }

  @Get('users/:user_uuid')
  getUser(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.getUserByUuid(
      userUuid,
      this.resolveInstitutionId(user)
    )
  }

  @Patch('users/:user_uuid')
  updateUser(
    @Param('user_uuid') userUuid: string,
    @Body() updateUserDto: UpdateUserDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.updateUserByUuid(
      userUuid,
      updateUserDto,
      this.resolveInstitutionId(user)
    )
  }

  @Delete('users/:user_uuid')
  @HttpCode(HttpStatus.NO_CONTENT)
  deleteUser(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.deleteUserByUuid(
      userUuid,
      this.resolveInstitutionId(user)
    )
  }

  @Delete('users/:user_uuid/hard')
  @Roles('super_admin') // Only super admin can hard delete
  @HttpCode(HttpStatus.NO_CONTENT)
  hardDeleteUser(@Param('user_uuid') userUuid: string) {
    return this.adminService.hardDeleteUserByUuid(userUuid)
  }

  @Post('users/bulk-import')
  bulkImportUsers(
    @Body() users: CreateUserDto[],
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.bulkImportUsers(
      users,
      this.resolveInstitutionId(user)
    )
  }

  @Post('users/:user_uuid/unlock')
  @HttpCode(HttpStatus.OK)
  unlockAccount(
    @Param('user_uuid') userUuid: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.unlockAccount(
      userUuid,
      this.resolveInstitutionId(user)
    )
  }

  // Institution profile (school info) for settings
  @Get('institutions/:institutionId')
  getInstitutionProfile(
    @Param('institutionId') institutionId: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.getInstitutionProfile(
      +institutionId,
      this.resolveInstitutionId(user)
    )
  }

  @Put('institutions/:institutionId')
  updateInstitutionProfile(
    @Param('institutionId') institutionId: string,
    @Body() updateDto: UpdateInstitutionDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.updateInstitutionProfile(
      +institutionId,
      updateDto,
      this.resolveInstitutionId(user)
    )
  }

  // Grading Configuration Endpoints
  @Get('institutions/:institutionId/grading-config')
  getGradingConfig(
    @Param('institutionId') institutionId: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.getGradingConfig(
      +institutionId,
      this.resolveInstitutionId(user)
    )
  }

  @Put('institutions/:institutionId/grading-config')
  updateGradingConfig(
    @Param('institutionId') institutionId: string,
    @Body() updateDto: UpdateGradingConfigDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.updateGradingConfig(
      +institutionId,
      updateDto,
      this.resolveInstitutionId(user)
    )
  }

  @Post('institutions/:institutionId/grading-config/reset')
  @HttpCode(HttpStatus.OK)
  resetGradingConfig(
    @Param('institutionId') institutionId: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.resetGradingConfig(
      +institutionId,
      this.resolveInstitutionId(user)
    )
  }

  // Dashboard Analytics Endpoints
  @Get('dashboard-stats')
  getDashboardStats(@CurrentUser() user: UserWithRelations) {
    const institutionId = this.resolveInstitutionId(user)
    return this.adminService.getDashboardStats(institutionId)
  }

  @Get('teacher-performance')
  getTeacherPerformance(
    @CurrentUser() user: UserWithRelations,
    @Query('limit') limit?: string
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.adminService.getTeacherPerformance(
      limit ? parseInt(limit) : 10,
      institutionId
    )
  }

  @Get('attendance-trends')
  getAttendanceTrends(
    @CurrentUser() user: UserWithRelations,
    @Query('period') period?: string
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.adminService.getAttendanceTrends(period, institutionId)
  }

  @Get('grade-distribution')
  getGradeDistribution(@CurrentUser() user: UserWithRelations) {
    const institutionId = this.resolveInstitutionId(user)
    return this.adminService.getGradeDistribution(institutionId)
  }

  @Get('class-performance')
  getClassPerformance(@CurrentUser() user: UserWithRelations) {
    const institutionId = this.resolveInstitutionId(user)
    return this.adminService.getClassPerformance(institutionId)
  }

  @Get('financial-overview')
  getFinancialOverview(
    @CurrentUser() user: UserWithRelations,
    @Query('period') period?: string
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.adminService.getFinancialOverview(period, institutionId)
  }

  @Get('system-alerts')
  getSystemAlerts(
    @CurrentUser() user: UserWithRelations,
    @Query('severity') severity?: string,
    @Query('limit') limit?: string
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.adminService.getSystemAlerts(
      severity,
      limit ? parseInt(limit) : 20,
      institutionId
    )
  }

  /** Resolve institutionId from the logged-in user across all possible relations */
  private resolveInstitutionId(user: UserWithRelations): number | null {
    return (
      user.institutionId ??
      user.staff?.institutionId ??
      user.teacher?.institutionId ??
      user.student?.institutionId ??
      null
    )
  }
}
