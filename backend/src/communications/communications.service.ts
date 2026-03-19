import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'
import { Prisma } from '@prisma/client'
import { PrismaService } from '../prisma/prisma.service'
import { CommunicationQueryDto } from './dto/communication-query.dto'
import { CreateCommunicationDto } from './dto/create-communication.dto'
import { UpdateCommunicationDto } from './dto/update-communication.dto'

@Injectable()
export class CommunicationsService {
  constructor(private prisma: PrismaService) {}

  // ==================== OPTIMIZED HELPER METHODS ====================

  /**
   * Get communication statistics from optimized database view
   * Uses communication_statistics view for better performance
   */
  private async getCommunicationStatisticsFromView(filters?: {
    institutionId?: number
    communicationType?: string
    isActive?: boolean
  }) {
    let query = 'SELECT * FROM communication_statistics WHERE 1=1'

    if (filters?.institutionId) {
      query += ` AND institution_id = ${filters.institutionId}`
    }
    if (filters?.communicationType) {
      query += ` AND communication_type = '${filters.communicationType}'`
    }
    if (filters?.isActive !== undefined) {
      query += ` AND is_active = ${filters.isActive}`
    }

    query += ' ORDER BY is_emergency DESC, is_pinned DESC, publish_date DESC'

    return this.prisma.$queryRawUnsafe(query)
  }

  /**
   * Get unread communications summary from optimized database view
   * Uses unread_communications_summary view for better performance
   */
  private async getUnreadCommunicationsFromView(institutionId: number) {
    return this.prisma.$queryRawUnsafe(`
      SELECT * FROM unread_communications_summary
      WHERE institution_id = ${institutionId}
      ORDER BY is_emergency DESC, is_pinned DESC, publish_date DESC
    `)
  }

  /**
   * Get communication analytics from optimized database view
   * Uses communication_analytics view for reporting
   */
  private async getCommunicationAnalyticsFromView(
    institutionId: number,
    startMonth?: Date,
    endMonth?: Date
  ) {
    let query = `
      SELECT * FROM communication_analytics
      WHERE institution_id = ${institutionId}
    `

    if (startMonth) {
      query += ` AND publish_month >= '${startMonth.toISOString()}'`
    }
    if (endMonth) {
      query += ` AND publish_month <= '${endMonth.toISOString()}'`
    }

    query += ' ORDER BY publish_month DESC'

    return this.prisma.$queryRawUnsafe(query)
  }

  // ==================== CRUD METHODS ====================

  /**
   * Create a new communication
   */
  async create(createDto: CreateCommunicationDto) {
    const { publishDate, expiryDate, ...rest } = createDto

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
            firstName: true,
            lastName: true,
            email: true,
          },
        },
      },
    })
  }

  /**
   * Get all communications with filtering and pagination
   * @param institutionId - When provided (admin), scope to this institution. When null (super_admin), no scope.
   */
  async findAll(
    query: CommunicationQueryDto,
    userId?: number,
    institutionId?: number | null
  ) {
    const {
      type,
      priority,
      targetAudience,
      isEmergency,
      isPinned,
      isActive,
      institutionId: queryInstitutionId,
      search,
      page = 1,
      limit = 10,
      startDate,
      endDate,
    } = query

    // Get user details if userId is provided (for non-admin role filtering)
    let userRole = ''
    let userInstitutionId: number | null = null

    if (userId) {
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
        select: {
          role: { select: { roleName: true } },
          student: { select: { institutionId: true } },
          teacher: { select: { institutionId: true } },
          staff: { select: { institutionId: true } },
          parents: {
            select: {
              student: {
                select: {
                  institutionId: true,
                },
              },
            },
          },
          roleId: true,
        },
      })

      if (user) {
        userRole = user.role.roleName
        userInstitutionId =
          user.student?.institutionId ??
          user.teacher?.institutionId ??
          user.staff?.institutionId ??
          user.parents?.[0]?.student?.institutionId ??
          null
      }
    }

    const skip = (page - 1) * limit

    // Build where clause
    const where: Prisma.CommunicationWhereInput = {}

    if (type) {
      where.communicationType = type
    }

    if (priority) {
      where.priority = priority
    }

    if (targetAudience) {
      where.targetAudience = {
        has: targetAudience,
      }
    }

    if (isEmergency !== undefined) {
      where.isEmergency = isEmergency
    }

    if (isPinned !== undefined) {
      where.isPinned = isPinned
    }

    if (isActive !== undefined) {
      where.isActive = isActive
    } else {
      where.isActive = true
    }

    // Institution scoping: admin's institutionId takes precedence
    if (institutionId) {
      where.institutionId = institutionId
    } else if (queryInstitutionId) {
      where.institutionId = queryInstitutionId
    }

    // Role-based filtering for non-admins (students, teachers, etc.)
    const isAdmin = ['super_admin', 'admin'].includes(userRole)

    if (!isAdmin && userInstitutionId) {
      where.institutionId = userInstitutionId

      if (!targetAudience) {
        where.OR = [
          {
            targetAudience: {
              hasSome: [
                userRole,
                userRole.toLowerCase(),
                userRole.charAt(0).toUpperCase() +
                  userRole.slice(1).toLowerCase(),
              ],
            },
          },
        ]
      } else if (targetAudience) {
        const roleLower = userRole.toLowerCase()
        const roleCapitalized =
          userRole.charAt(0).toUpperCase() + userRole.slice(1).toLowerCase()

        where.targetAudience = {
          hasSome: [userRole, roleLower, roleCapitalized],
        }
      }
    }

    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { content: { contains: search, mode: 'insensitive' } },
      ]
    }

    if (startDate || endDate) {
      where.publishDate = {}
      if (startDate) {
        where.publishDate.gte = new Date(startDate)
      }
      if (endDate) {
        where.publishDate.lte = new Date(endDate)
      }
    }

    // Get total count
    const total = await this.prisma.communication.count({ where })

    // Get communications with selective loading (OPTIMIZED)
    const communications = await this.prisma.communication.findMany({
      where,
      skip,
      take: limit,
      select: {
        id: true,
        institutionId: true,
        title: true,
        content: true,
        communicationType: true,
        priority: true,
        targetAudience: true,
        isEmergency: true,
        isPinned: true,
        isActive: true,
        publishDate: true,
        expiryDate: true,
        attachmentUrl: true,
        createdBy: true,
        createdAt: true,
        updatedAt: true,
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
            firstName: true,
            lastName: true,
            email: true,
          },
        },
        _count: {
          select: {
            readReceipts: true,
          },
        },
      },
      orderBy: [
        { isPinned: 'desc' }, // Pinned first
        { isEmergency: 'desc' }, // Emergency next
        { publishDate: 'desc' }, // Most recent
      ],
    })

    return {
      data: communications,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    }
  }

  /**
   * Get a single communication by ID (OPTIMIZED)
   * @param adminInstitutionId - When provided (admin), verify ownership. When null (super_admin), allow any.
   */
  async findOne(
    id: number,
    userId?: number,
    adminInstitutionId?: number | null
  ) {
    const communication = await this.prisma.communication.findUnique({
      where: { id },
      select: {
        id: true,
        institutionId: true,
        title: true,
        content: true,
        communicationType: true,
        priority: true,
        targetAudience: true,
        departmentIds: true,
        programIds: true,
        classIds: true,
        isEmergency: true,
        isPinned: true,
        isActive: true,
        publishDate: true,
        expiryDate: true,
        attachmentUrl: true,
        createdBy: true,
        createdAt: true,
        updatedAt: true,
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
            firstName: true,
            lastName: true,
            email: true,
          },
        },
        readReceipts: userId
          ? {
              where: { userId },
              select: {
                id: true,
                readAt: true,
                user: {
                  select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                  },
                },
              },
              take: 1,
            }
          : false,
        _count: {
          select: {
            readReceipts: true,
          },
        },
      },
    })

    if (!communication) {
      throw new NotFoundException(`Communication with ID ${id} not found`)
    }

    if (
      adminInstitutionId != null &&
      communication.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException(
        'You do not have access to this communication'
      )
    }

    return communication
  }

  /**
   * Update a communication
   */
  async update(id: number, updateDto: UpdateCommunicationDto, userId: number) {
    // Check if communication exists
    const existing = await this.prisma.communication.findUnique({
      where: { id },
      select: { createdBy: true },
    })

    if (!existing) {
      throw new NotFoundException(`Communication with ID ${id} not found`)
    }

    // Only creator can update (or add role-based check here)
    if (existing.createdBy !== userId) {
      throw new ForbiddenException(
        'You do not have permission to update this communication'
      )
    }

    // Build update data object with proper typing
    const updateData: Prisma.CommunicationUpdateInput = {}

    // Copy all properties from updateDto
    Object.entries(updateDto).forEach(([key, value]) => {
      if (
        value !== undefined &&
        key !== 'publishDate' &&
        key !== 'expiryDate'
      ) {
        ;(updateData as Record<string, unknown>)[key] = value
      }
    })

    // Handle date conversions if present
    if ('publishDate' in updateDto && updateDto.publishDate) {
      updateData.publishDate = new Date(updateDto.publishDate as string)
    }
    if ('expiryDate' in updateDto && updateDto.expiryDate) {
      updateData.expiryDate = new Date(updateDto.expiryDate as string)
    }

    return this.prisma.communication.update({
      where: { id },
      data: updateData,
      select: {
        id: true,
        institutionId: true,
        title: true,
        content: true,
        communicationType: true,
        priority: true,
        targetAudience: true,
        isEmergency: true,
        isPinned: true,
        isActive: true,
        publishDate: true,
        expiryDate: true,
        createdBy: true,
        createdAt: true,
        updatedAt: true,
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
            firstName: true,
            lastName: true,
            email: true,
          },
        },
      },
    })
  }

  /**
   * Delete a communication
   */
  async remove(id: number, userId: number) {
    // Check if communication exists
    const existing = await this.prisma.communication.findUnique({
      where: { id },
      select: { createdBy: true },
    })

    if (!existing) {
      throw new NotFoundException(`Communication with ID ${id} not found`)
    }

    // Only creator can delete (or add role-based check here)
    if (existing.createdBy !== userId) {
      throw new ForbiddenException(
        'You do not have permission to delete this communication'
      )
    }

    return this.prisma.communication.delete({
      where: { id },
    })
  }

  /**
   * Mark communication as read for a user
   */
  async markAsRead(communicationId: number, userId: number) {
    // Check if communication exists
    const communication = await this.prisma.communication.findUnique({
      where: { id: communicationId },
    })

    if (!communication) {
      throw new NotFoundException(
        `Communication with ID ${communicationId} not found`
      )
    }

    // Check if already read
    const existing = await this.prisma.communicationReadReceipt.findUnique({
      where: {
        unique_communication_read: {
          communicationId,
          userId,
        },
      },
    })

    if (existing) {
      return {
        message: 'Already marked as read',
        readReceipt: existing,
      }
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
            firstName: true,
            lastName: true,
          },
        },
      },
    })

    return {
      message: 'Marked as read',
      readReceipt,
    }
  }

  /**
   * Get unread communications for a user (OPTIMIZED)
   */
  async getUnread(userId: number, institutionId?: number) {
    // Get user to determine their role (selective loading)
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        role: {
          select: {
            id: true,
            roleName: true,
          },
        },
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
    })

    if (!user) {
      throw new NotFoundException('User not found')
    }

    // Determine institution if not provided
    const userInstitutionId =
      institutionId ??
      user.student?.institutionId ??
      user.teacher?.institutionId ??
      user.staff?.institutionId

    // When user has no institution (e.g. some admin accounts), return empty list instead of 400
    if (!userInstitutionId) {
      return { count: 0, data: [] }
    }

    const roleName = user.role.roleName

    // Get all communications for this user's role (selective loading)
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
      select: {
        id: true,
        title: true,
        content: true,
        communicationType: true,
        priority: true,
        isEmergency: true,
        isPinned: true,
        publishDate: true,
        expiryDate: true,
        attachmentUrl: true,
        createdBy: true,
        createdAt: true,
        creator: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
          },
        },
      },
      orderBy: [
        { isPinned: 'desc' },
        { isEmergency: 'desc' },
        { publishDate: 'desc' },
      ],
    })

    return {
      count: communications.length,
      data: communications,
    }
  }

  /**
   * Get read statistics for a communication (OPTIMIZED)
   * @param adminInstitutionId - When provided (admin), verify ownership. When null (super_admin), allow any.
   */
  async getReadStats(
    communicationId: number,
    adminInstitutionId?: number | null
  ) {
    const communication = await this.prisma.communication.findUnique({
      where: { id: communicationId },
      select: {
        id: true,
        title: true,
        targetAudience: true,
        institutionId: true,
        publishDate: true,
        _count: {
          select: {
            readReceipts: true,
          },
        },
        readReceipts: {
          select: {
            id: true,
            readAt: true,
            user: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                email: true,
                kramid: true,
              },
            },
          },
          orderBy: {
            readAt: 'desc',
          },
        },
      },
    })

    if (!communication) {
      throw new NotFoundException(
        `Communication with ID ${communicationId} not found`
      )
    }

    if (
      adminInstitutionId != null &&
      communication.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException(
        'You do not have access to this communication'
      )
    }

    return {
      communicationId,
      title: communication.title,
      totalReads: communication._count.readReceipts,
      readBy: communication.readReceipts,
      publishDate: communication.publishDate,
      targetAudience: communication.targetAudience,
    }
  }

  /**
   * Get communication analytics (OPTIMIZED)
   * Uses communication_analytics view for better performance
   */
  async getCommunicationAnalytics(
    institutionId: number,
    startMonth?: string,
    endMonth?: string
  ) {
    const start = startMonth ? new Date(startMonth) : undefined
    const end = endMonth ? new Date(endMonth) : undefined

    const analytics = await this.getCommunicationAnalyticsFromView(
      institutionId,
      start,
      end
    )

    return {
      institutionId,
      analytics,
      metadata: {
        startMonth: start?.toISOString().slice(0, 7),
        endMonth: end?.toISOString().slice(0, 7),
        generatedAt: new Date(),
      },
    }
  }

  /**
   * Get communication statistics with read counts (OPTIMIZED)
   * Uses communication_statistics view for better performance
   */
  async getCommunicationStatistics(filters?: {
    institutionId?: number
    communicationType?: string
    isActive?: boolean
  }) {
    return this.getCommunicationStatisticsFromView(filters)
  }
}
