import {
    Body,
    Controller,
    Delete,
    Get,
    Param,
    ParseIntPipe,
    Post,
    Put,
    Query,
    Request,
    UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CommunicationsService } from './communications.service';
import { CommunicationQueryDto } from './dto/communication-query.dto';
import { CreateCommunicationDto } from './dto/create-communication.dto';
import { UpdateCommunicationDto } from './dto/update-communication.dto';

@Controller('communications')
@UseGuards(JwtAuthGuard, RolesGuard)
export class CommunicationsController {
  constructor(private readonly communicationsService: CommunicationsService) {}

  /**
   * Create a new communication
   * POST /communications
   * Only super_admin, admin, and teacher can create communications
   */
  @Post()
  @Roles('super_admin', 'admin', 'teacher')
  create(@Body() createDto: CreateCommunicationDto, @Request() req) {
    // Set creator from authenticated user
    createDto.createdBy = req.user.id;
    return this.communicationsService.create(createDto);
  }

  /**
   * Get all communications with filtering
   * GET /communications
   */
  @Get()
  findAll(@Query() query: CommunicationQueryDto, @Request() req) {
    return this.communicationsService.findAll(query, req.user.id);
  }

  /**
   * Get unread communications for current user
   * GET /communications/unread
   */
  @Get('unread')
  getUnread(@Request() req, @Query('institutionId') institutionId?: number) {
    return this.communicationsService.getUnread(req.user.id, institutionId);
  }

  /**
   * Get a single communication
   * GET /communications/:id
   */
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number, @Request() req) {
    return this.communicationsService.findOne(id, req.user.id);
  }

  /**
   * Update a communication
   * PUT /communications/:id
   * Only super_admin, admin, and teacher can update communications
   */
  @Put(':id')
  @Roles('super_admin', 'admin', 'teacher')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDto: UpdateCommunicationDto,
    @Request() req,
  ) {
    return this.communicationsService.update(id, updateDto, req.user.id);
  }

  /**
   * Delete a communication
   * DELETE /communications/:id
   * Only super_admin, admin, and teacher can delete communications
   */
  @Delete(':id')
  @Roles('super_admin', 'admin', 'teacher')
  remove(@Param('id', ParseIntPipe) id: number, @Request() req) {
    return this.communicationsService.remove(id, req.user.id);
  }

  /**
   * Mark communication as read
   * POST /communications/:id/read
   */
  @Post(':id/read')
  markAsRead(@Param('id', ParseIntPipe) id: number, @Request() req) {
    return this.communicationsService.markAsRead(id, req.user.id);
  }

  /**
   * Get read statistics for a communication
   * GET /communications/:id/stats
   * Only super_admin, admin, and teacher can view read statistics
   */
  @Get(':id/stats')
  @Roles('super_admin', 'admin', 'teacher')
  getReadStats(@Param('id', ParseIntPipe) id: number) {
    return this.communicationsService.getReadStats(id);
  }

  /**
   * Get communication analytics (OPTIMIZED)
   * GET /communications/analytics/institution
   * Only super_admin and admin can view analytics
   */
  @Get('analytics/institution')
  @Roles('super_admin', 'admin')
  getCommunicationAnalytics(
    @Query('institutionId', ParseIntPipe) institutionId: number,
    @Query('startMonth') startMonth?: string,
    @Query('endMonth') endMonth?: string,
  ) {
    return this.communicationsService.getCommunicationAnalytics(
      institutionId,
      startMonth,
      endMonth,
    );
  }

  /**
   * Get communication statistics with read counts (OPTIMIZED)
   * GET /communications/statistics
   * Only super_admin, admin, and teacher can view statistics
   */
  @Get('statistics')
  @Roles('super_admin', 'admin', 'teacher')
  getCommunicationStatistics(
    @Query('institutionId') institutionId?: number,
    @Query('communicationType') communicationType?: string,
    @Query('isActive') isActive?: boolean,
  ) {
    return this.communicationsService.getCommunicationStatistics({
      institutionId: institutionId ? Number(institutionId) : undefined,
      communicationType,
      isActive: isActive !== undefined ? Boolean(isActive) : undefined,
    });
  }
}

