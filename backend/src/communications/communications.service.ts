import {
    BadRequestException,
    ForbiddenException,
    Injectable,
    NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CommunicationQueryDto } from './dto/communication-query.dto';
import {
    CreateCommunicationDto
} from './dto/create-communication.dto';
import { UpdateCommunicationDto } from './dto/update-communication.dto';

@Injectable()
export class CommunicationsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Create a new communication
   */
  async create(createDto: CreateCommunicationDto) {
    const { publishDate, expiryDate, ...rest } = createDto;

    return this.prisma.communication.create({
      data: {
        ...rest,
        publishDate: publishDate ? new Date(publishDate) : new Date(),
        expiryDate: expiryDate ? new Date(expiryDate) : null,
      },
      include: {
        institution: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
        creator: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });
  }

  /**
   * Get all communications with filtering and pagination
   */
  async findAll(query: CommunicationQueryDto) {
    const {
      type,
      priority,
      targetAudience,
      isEmergency,
      isPinned,
      isActive,
      institutionId,
      search,
      page = 1,
      limit = 10,
      startDate,
      endDate,
    } = query;

    const skip = (page - 1) * limit;

    // Build where clause
    const where: Prisma.CommunicationWhereInput = {};

    if (type) {
      where.communicationType = type;
    }

    if (priority) {
      where.priority = priority;
    }

    if (targetAudience) {
      where.targetAudience = {
        has: targetAudience,
      };
    }

    if (isEmergency !== undefined) {
      where.isEmergency = isEmergency;
    }

    if (isPinned !== undefined) {
      where.isPinned = isPinned;
    }

    if (isActive !== undefined) {
      where.isActive = isActive;
    } else {
      // Default to active only
      where.isActive = true;
    }

    if (institutionId) {
      where.institutionId = institutionId;
    }

    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { content: { contains: search, mode: 'insensitive' } },
      ];
    }

    if (startDate || endDate) {
      where.publishDate = {};
      if (startDate) {
        where.publishDate.gte = new Date(startDate);
      }
      if (endDate) {
        where.publishDate.lte = new Date(endDate);
      }
    }

    // Get total count
    const total = await this.prisma.communication.count({ where });

    // Get communications
    const communications = await this.prisma.communication.findMany({
      where,
      skip,
      take: limit,
      orderBy: [
        { isPinned: 'desc' }, // Pinned first
        { isEmergency: 'desc' }, // Emergency next
        { publishDate: 'desc' }, // Most recent
      ],
      include: {
        institution: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
        creator: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        _count: {
          select: {
            readReceipts: true,
          },
        },
      },
    });

    return {
      data: communications,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get a single communication by ID
   */
  async findOne(id: number, userId?: number) {
    const communication = await this.prisma.communication.findUnique({
      where: { id },
      include: {
        institution: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
        creator: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        readReceipts: userId
          ? {
              where: { userId },
              select: {
                id: true,
                readAt: true,
              },
            }
          : false,
        _count: {
          select: {
            readReceipts: true,
          },
        },
      },
    });

    if (!communication) {
      throw new NotFoundException(`Communication with ID ${id} not found`);
    }

    return communication;
  }

  /**
   * Update a communication
   */
  async update(id: number, updateDto: UpdateCommunicationDto, userId: number) {
    // Check if communication exists
    const existing = await this.prisma.communication.findUnique({
      where: { id },
      select: { createdBy: true },
    });

    if (!existing) {
      throw new NotFoundException(`Communication with ID ${id} not found`);
    }

    // Only creator can update (or add role-based check here)
    if (existing.createdBy !== userId) {
      throw new ForbiddenException(
        'You do not have permission to update this communication',
      );
    }

    // Build update data object with proper typing
    const updateData: Prisma.CommunicationUpdateInput = {};

    // Copy all properties from updateDto
    Object.entries(updateDto).forEach(([key, value]) => {
      if (value !== undefined && key !== 'publishDate' && key !== 'expiryDate') {
        (updateData as Record<string, unknown>)[key] = value;
      }
    });

    // Handle date conversions if present
    if ('publishDate' in updateDto && updateDto.publishDate) {
      updateData.publishDate = new Date(updateDto.publishDate as string);
    }
    if ('expiryDate' in updateDto && updateDto.expiryDate) {
      updateData.expiryDate = new Date(updateDto.expiryDate as string);
    }

    return this.prisma.communication.update({
      where: { id },
      data: updateData,
      include: {
        institution: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
        creator: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });
  }

  /**
   * Delete a communication
   */
  async remove(id: number, userId: number) {
    // Check if communication exists
    const existing = await this.prisma.communication.findUnique({
      where: { id },
      select: { createdBy: true },
    });

    if (!existing) {
      throw new NotFoundException(`Communication with ID ${id} not found`);
    }

    // Only creator can delete (or add role-based check here)
    if (existing.createdBy !== userId) {
      throw new ForbiddenException(
        'You do not have permission to delete this communication',
      );
    }

    return this.prisma.communication.delete({
      where: { id },
    });
  }

  /**
   * Mark communication as read for a user
   */
  async markAsRead(communicationId: number, userId: number) {
    // Check if communication exists
    const communication = await this.prisma.communication.findUnique({
      where: { id: communicationId },
    });

    if (!communication) {
      throw new NotFoundException(
        `Communication with ID ${communicationId} not found`,
      );
    }

    // Check if already read
    const existing = await this.prisma.communicationReadReceipt.findUnique({
      where: {
        unique_communication_read: {
          communicationId,
          userId,
        },
      },
    });

    if (existing) {
      return {
        message: 'Already marked as read',
        readReceipt: existing,
      };
    }

    // Create read receipt
    const readReceipt = await this.prisma.communicationReadReceipt.create({
      data: {
        communicationId,
        userId,
      },
      include: {
        communication: {
          select: {
            id: true,
            title: true,
          },
        },
        user: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    return {
      message: 'Marked as read',
      readReceipt,
    };
  }

  /**
   * Get unread communications for a user
   */
  async getUnread(userId: number, institutionId?: number) {
    // Get user to determine their role
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        role: true,
        student: {
          select: {
            institutionId: true,
          },
        },
        teacher: {
          select: {
            institutionId: true,
          },
        },
        staff: {
          select: {
            institutionId: true,
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Determine institution if not provided
    const userInstitutionId =
      institutionId ||
      user.student?.institutionId ||
      user.teacher?.institutionId ||
      user.staff?.institutionId;

    if (!userInstitutionId) {
      throw new BadRequestException('Institution ID is required');
    }

    const roleName = user.role.roleName;

    // Get all communications for this user's role
    const communications = await this.prisma.communication.findMany({
      where: {
        institutionId: userInstitutionId,
        isActive: true,
        targetAudience: {
          has: roleName,
        },
        // Not expired
        OR: [{ expiryDate: null }, { expiryDate: { gte: new Date() } }],
        // Not yet read by this user
        readReceipts: {
          none: {
            userId,
          },
        },
      },
      orderBy: [
        { isPinned: 'desc' },
        { isEmergency: 'desc' },
        { publishDate: 'desc' },
      ],
      include: {
        creator: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    return {
      count: communications.length,
      data: communications,
    };
  }

  /**
   * Get read statistics for a communication
   */
  async getReadStats(communicationId: number) {
    const communication = await this.prisma.communication.findUnique({
      where: { id: communicationId },
      include: {
        _count: {
          select: {
            readReceipts: true,
          },
        },
        readReceipts: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
              },
            },
          },
        },
      },
    });

    if (!communication) {
      throw new NotFoundException(
        `Communication with ID ${communicationId} not found`,
      );
    }

    return {
      communicationId,
      title: communication.title,
      totalReads: communication._count.readReceipts,
      readBy: communication.readReceipts,
    };
  }
}

