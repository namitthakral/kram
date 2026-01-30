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
import { CommunicationsService } from './communications.service';
import { CommunicationQueryDto } from './dto/communication-query.dto';
import { CreateCommunicationDto } from './dto/create-communication.dto';
import { UpdateCommunicationDto } from './dto/update-communication.dto';

@Controller('communications')
@UseGuards(JwtAuthGuard)
export class CommunicationsController {
  constructor(private readonly communicationsService: CommunicationsService) {}

  /**
   * Create a new communication
   * POST /communications
   */
  @Post()
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
  findAll(@Query() query: CommunicationQueryDto) {
    return this.communicationsService.findAll(query);
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
   */
  @Put(':id')
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
   */
  @Delete(':id')
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
   */
  @Get(':id/stats')
  getReadStats(@Param('id', ParseIntPipe) id: number) {
    return this.communicationsService.getReadStats(id);
  }
}

