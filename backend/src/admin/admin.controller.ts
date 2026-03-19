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
  Put,
  Query,
  UseGuards,
} from '@nestjs/common'
import { CurrentUser } from '../auth/decorators/current-user.decorator'
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import {
  CreateUserDto,
  UpdateUserDto,
  UserQueryDto,
} from '../common/dto/user.dto'
import { UpdateInstitutionDto } from '../institutions/dto/institution.dto'
import { UserWithRelations } from '../types/auth.types'
import { AdminService } from './admin.service'
import { UpdateExaminationPolicyDto } from './dto/examination-policy.dto'
import { UpdateGradingConfigDto } from './dto/grading-config.dto'
import { CreateSemesterDto, UpdateSemesterDto } from './dto/semester.dto'

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('super_admin', 'admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('academic-years')
  getAcademicYears(@CurrentUser() user: UserWithRelations) {
    return this.adminService.getAcademicYears(this.resolveInstitutionId(user))
  }

  @Post('academic-years')
  @Roles('super_admin', 'admin')
  createAcademicYear(
    @Body() createAcademicYearDto: any,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.createAcademicYear(
      createAcademicYearDto,
      this.resolveInstitutionId(user)
    )
  }

  @Put('academic-years/:id')
  @Roles('super_admin', 'admin')
  updateAcademicYear(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateAcademicYearDto: any,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.updateAcademicYear(
      id,
      updateAcademicYearDto,
      this.resolveInstitutionId(user)
    )
  }

  @Delete('academic-years/:id')
  @Roles('super_admin', 'admin')
  deleteAcademicYear(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.deleteAcademicYear(
      id,
      this.resolveInstitutionId(user)
    )
  }

  @Get('semesters/:academicYearId')
  getSemesters(@Param('academicYearId') academicYearId: string) {
    return this.adminService.getSemesters(+academicYearId)
  }

  @Post('semesters')
  createSemester(
    @Body() dto: CreateSemesterDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.createSemester(
      dto,
      this.resolveInstitutionId(user)
    )
  }

  @Patch('semesters/:id')
  updateSemester(
    @Param('id') id: string,
    @Body() dto: UpdateSemesterDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.updateSemester(
      +id,
      dto,
      this.resolveInstitutionId(user)
    )
  }

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

  @Get('institutions/:institutionId/info')
  getInstitutionInfo(
    @Param('institutionId') institutionId: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.getInstitutionInfo(
      +institutionId,
      this.resolveInstitutionId(user)
    )
  }

  // ID Configuration Endpoints
  @Get('institutions/:institutionId/id-config')
  getIdConfig(
    @Param('institutionId') institutionId: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.getIdConfig(
      +institutionId,
      this.resolveInstitutionId(user)
    )
  }

  @Put('institutions/:institutionId/id-config')
  updateIdConfig(
    @Param('institutionId') institutionId: string,
    @Body() updates: any,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.updateIdConfig(
      +institutionId,
      updates,
      this.resolveInstitutionId(user)
    )
  }

  @Post('institutions/:institutionId/id-config/preview')
  previewId(
    @Param('institutionId') institutionId: string,
    @Body() dto: { template: string; context: any },
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.previewId(
      +institutionId,
      dto,
      this.resolveInstitutionId(user)
    )
  }

  @Get('institutions/:institutionId/grading-restriction')
  checkGradingRestriction(
    @Param('institutionId') institutionId: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.checkGradingRestrictionStatus(
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

  // Examination Oversight Endpoints (Admin Read-Only)
  @Get('examinations/schedule')
  getExaminationSchedule(
    @CurrentUser() user: UserWithRelations,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('status') status?: string,
    @Query('examType') examType?: string,
    @Query('subjectId') subjectId?: string,
    @Query('limit') limit?: string,
    @Query('page') page?: string
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.adminService.getExaminationSchedule(institutionId, {
      startDate,
      endDate,
      status,
      examType,
      subjectId: subjectId ? parseInt(subjectId) : undefined,
      limit: limit ? parseInt(limit) : undefined,
      page: page ? parseInt(page) : undefined,
    })
  }

  @Get('examinations/completion-stats')
  getExaminationCompletionStats(@CurrentUser() user: UserWithRelations) {
    const institutionId = this.resolveInstitutionId(user)
    return this.adminService.getExaminationCompletionStats(institutionId)
  }

  @Get('examinations/analytics')
  getExaminationAnalytics(
    @CurrentUser() user: UserWithRelations,
    @Query('period') period?: 'week' | 'month' | 'semester' | 'year'
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.adminService.getExaminationAnalytics(institutionId, period)
  }

  // Examination Policy Configuration Endpoints
  @Get('institutions/:institutionId/examination-policy')
  getExaminationPolicy(
    @Param('institutionId') institutionId: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.getExaminationPolicy(
      +institutionId,
      this.resolveInstitutionId(user)
    )
  }

  @Put('institutions/:institutionId/examination-policy')
  updateExaminationPolicy(
    @Param('institutionId') institutionId: string,
    @Body() updateDto: UpdateExaminationPolicyDto,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.updateExaminationPolicy(
      +institutionId,
      updateDto,
      this.resolveInstitutionId(user)
    )
  }

  @Post('institutions/:institutionId/examination-policy/reset')
  @HttpCode(HttpStatus.OK)
  resetExaminationPolicy(
    @Param('institutionId') institutionId: string,
    @CurrentUser() user: UserWithRelations
  ) {
    return this.adminService.resetExaminationPolicy(
      +institutionId,
      this.resolveInstitutionId(user)
    )
  }

  @Get('examinations/compliance-report')
  getExaminationComplianceReport(
    @CurrentUser() user: UserWithRelations,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string
  ) {
    const institutionId = this.resolveInstitutionId(user)
    return this.adminService.getExaminationComplianceReport(
      institutionId,
      startDate,
      endDate
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
