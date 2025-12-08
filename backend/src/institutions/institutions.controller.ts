import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common'
import { Roles } from '../auth/decorators/roles.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { CreateInstitutionDto } from './dto/institution.dto'
import { InstitutionsService } from './institutions.service'

@Controller('institutions')
export class InstitutionsController {
  constructor(private readonly institutionsService: InstitutionsService) {}

  /**
   * Create a new institution
   * Only super_admin can create institutions
   * Code is optional - if not provided, it will be auto-generated
   */
  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('super_admin')
  async create(@Body() createInstitutionDto: CreateInstitutionDto) {
    return this.institutionsService.create(createInstitutionDto)
  }

  /**
   * Get all public institutions (for registration dropdown)
   * No authentication required
   */
  @Get('public')
  async getPublicInstitutions() {
    return this.institutionsService.getPublicInstitutions()
  }
}
