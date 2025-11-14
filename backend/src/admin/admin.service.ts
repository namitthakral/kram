import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'
import { Prisma } from '@prisma/client'
import * as bcrypt from 'bcryptjs'
import {
  CreateUserDto,
  UpdateUserDto,
  UserQueryDto,
} from '../common/dto/user.dto'
import { PrismaService } from '../prisma/prisma.service'
import {
  generateEdVerseId,
  generateTemporaryPassword,
} from '../utils/edverse-id.util'

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  async createInstitutionalUser(createUserDto: CreateUserDto) {
    // This method creates institutional users (students, teachers, staff)
    // with temporary passwords that must be changed on first login

    // Check if user already exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email: createUserDto.email },
    })

    if (existingUser) {
      throw new ConflictException('User with this email already exists')
    }

    // Check if phone number already exists (if provided)
    if (createUserDto.phoneNumber) {
      const existingPhoneUser = await this.prisma.user.findFirst({
        where: { phone: createUserDto.phoneNumber },
      })

      if (existingPhoneUser) {
        throw new ConflictException(
          'User with this phone number already exists'
        )
      }
    }

    // Get role to determine EdVerse ID prefix
    const role = await this.prisma.role.findUnique({
      where: { id: createUserDto.roleId },
    })

    if (!role) {
      throw new ConflictException('Invalid role ID')
    }

    // Get institution to generate EdVerse ID with institution code
    const institution = await this.prisma.institution.findUnique({
      where: { id: createUserDto.institutionId },
      select: { code: true },
    })

    if (!institution) {
      throw new ConflictException('Institution not found')
    }

    if (!institution.code) {
      throw new ConflictException(
        'Institution code not configured. Please contact administrator.'
      )
    }

    // Generate EdVerse ID with institution code
    const currentYear = new Date().getFullYear()
    const edverseId = generateEdVerseId(
      institution.code,
      role.roleName,
      currentYear
    )

    // Generate temporary password based on user's name
    const temporaryPassword = generateTemporaryPassword(
      createUserDto.firstName,
      createUserDto.lastName
    )

    // Hash the temporary password
    const hashedPassword = await bcrypt.hash(temporaryPassword, 12)

    // Combine firstName and lastName into name for database compatibility
    const fullName =
      `${createUserDto.firstName} ${createUserDto.lastName}`.trim()

    // Create user with INACTIVE status (requires password change to become active)
    const user = await this.prisma.user.create({
      data: {
        firstName: createUserDto.firstName,
        lastName: createUserDto.lastName,
        name: fullName,
        email: createUserDto.email,
        phone: createUserDto.phoneNumber,
        passwordHash: hashedPassword,
        roleId: createUserDto.roleId,
        edverseId,
        status: 'INACTIVE', // User must change password before becoming active
        isTemporaryPassword: true,
        mustChangePassword: true,
      },
      include: {
        role: true,
      },
    })

    return {
      success: true,
      message: 'Institutional user created successfully',
      data: {
        id: user.id,
        uuid: user.uuid,
        edverseId: user.edverseId,
        firstName: createUserDto.firstName,
        lastName: createUserDto.lastName,
        name: user.name,
        email: user.email,
        phoneNumber: user.phone,
        role: user.role,
        status: user.status,
        temporaryPassword, // Return this so admin can share with user
        mustChangePassword: user.mustChangePassword,
        createdAt: user.createdAt,
      },
    }
  }

  async getAllUsers(query: UserQueryDto) {
    const {
      page = 1,
      limit = 10,
      search,
      roleId,
      status,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = query

    const skip = (page - 1) * limit
    const where: Prisma.UserWhereInput = {}

    // Add search filter
    if (search) {
      where.OR = [
        { firstName: { contains: search, mode: 'insensitive' } },
        { lastName: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
        { edverseId: { contains: search, mode: 'insensitive' } },
      ]
    }

    // Add role filter
    if (roleId) {
      where.roleId = parseInt(roleId.toString())
    }

    // Add status filter
    if (status) {
      where.status = status
    }

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        include: {
          role: true,
          student: true,
          teacher: true,
          parent: true,
        },
        skip,
        take: limit,
        orderBy: { [sortBy]: sortOrder },
      }),
      this.prisma.user.count({ where }),
    ])

    return {
      success: true,
      data: {
        users,
        pagination: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit),
        },
      },
    }
  }

  async getUsersStats() {
    const [
      totalUsers,
      activeUsers,
      inactiveUsers,
      suspendedUsers,
      usersByRoleData,
      recentUsers,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.user.count({ where: { status: 'ACTIVE' } }),
      this.prisma.user.count({ where: { status: 'INACTIVE' } }),
      this.prisma.user.count({ where: { status: 'SUSPENDED' } }),
      this.prisma.user.groupBy({
        by: ['roleId'],
        _count: { id: true },
      }),
      this.prisma.user.findMany({
        take: 10,
        orderBy: { createdAt: 'desc' },
        include: { role: true },
      }),
    ])

    // Get role names for the grouped data
    const roles = await this.prisma.role.findMany({
      select: { id: true, roleName: true },
    })

    const usersByRole = usersByRoleData.map(item => {
      const role = roles.find(r => r.id === item.roleId)
      return {
        roleId: item.roleId,
        roleName: role?.roleName || 'Unknown',
        count: item._count.id,
      }
    })

    return {
      success: true,
      data: {
        overview: {
          totalUsers,
          activeUsers,
          inactiveUsers,
          suspendedUsers,
        },
        usersByRole,
        recentUsers,
      },
    }
  }

  async getUsersByRole(roleId: number, query: UserQueryDto) {
    const { page = 1, limit = 10, search, status } = query
    const skip = (page - 1) * limit
    const where: Prisma.UserWhereInput = { roleId }

    if (search) {
      where.OR = [
        { firstName: { contains: search, mode: 'insensitive' } },
        { lastName: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
        { edverseId: { contains: search, mode: 'insensitive' } },
      ]
    }

    if (status) {
      where.status = status
    }

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        include: {
          role: true,
          student: true,
          teacher: true,
          parent: true,
        },
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.user.count({ where }),
    ])

    return {
      success: true,
      data: {
        users,
        pagination: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit),
        },
      },
    }
  }

  async getUserByUuid(uuid: string) {
    const user = await this.prisma.user.findUnique({
      where: { uuid },
      include: {
        role: true,
        student: true,
        teacher: true,
        parent: true,
      },
    })

    if (!user) {
      throw new NotFoundException('User not found')
    }

    return {
      success: true,
      data: user,
    }
  }

  async updateUserByUuid(uuid: string, updateUserDto: UpdateUserDto) {
    const existingUser = await this.prisma.user.findUnique({
      where: { uuid },
    })

    if (!existingUser) {
      throw new NotFoundException('User not found')
    }

    // Check if email is being changed and if it already exists
    if (updateUserDto.email && updateUserDto.email !== existingUser.email) {
      const emailExists = await this.prisma.user.findUnique({
        where: { email: updateUserDto.email },
      })

      if (emailExists) {
        throw new ConflictException('Email already exists')
      }
    }

    // Update name if firstName or lastName is changed
    const updateData: Prisma.UserUpdateInput = { ...updateUserDto }
    if (updateUserDto.firstName || updateUserDto.lastName) {
      const firstName = updateUserDto.firstName || existingUser.firstName
      const lastName = updateUserDto.lastName || existingUser.lastName
      updateData.name = `${firstName} ${lastName}`.trim()
    }

    const updatedUser = await this.prisma.user.update({
      where: { uuid },
      data: updateData,
      include: {
        role: true,
        student: true,
        teacher: true,
        parent: true,
      },
    })

    return {
      success: true,
      message: 'User updated successfully',
      data: updatedUser,
    }
  }

  async deleteUserByUuid(uuid: string) {
    const user = await this.prisma.user.findUnique({
      where: { uuid },
    })

    if (!user) {
      throw new NotFoundException('User not found')
    }

    // Soft delete - set status to SUSPENDED
    await this.prisma.user.update({
      where: { uuid },
      data: { status: 'SUSPENDED' },
    })

    return {
      success: true,
      message: 'User deleted successfully',
    }
  }

  async hardDeleteUserByUuid(uuid: string) {
    const user = await this.prisma.user.findUnique({
      where: { uuid },
    })

    if (!user) {
      throw new NotFoundException('User not found')
    }

    // Hard delete - permanently remove from database
    await this.prisma.user.delete({
      where: { uuid },
    })

    return {
      success: true,
      message: 'User permanently deleted',
    }
  }

  async bulkImportUsers(users: CreateUserDto[]) {
    const results = {
      successful: 0,
      failed: 0,
      errors: [] as string[],
    }

    for (const userData of users) {
      try {
        await this.createInstitutionalUser(userData)
        results.successful++
      } catch (error) {
        results.failed++
        results.errors.push(
          `Failed to create user ${userData.email}: ${error.message}`
        )
      }
    }

    return {
      success: true,
      message: `Bulk import completed. ${results.successful} successful, ${results.failed} failed.`,
      data: results,
    }
  }

  /**
   * Unlock a user account that was locked due to failed login attempts
   */
  async unlockAccount(userUuid: string) {
    const user = await this.prisma.user.findFirst({
      where: { uuid: userUuid },
    })

    if (!user) {
      throw new NotFoundException(`User with UUID ${userUuid} not found`)
    }

    // Reset login attempts and unlock account
    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        loginAttempts: 0,
        accountLocked: false,
      },
    })

    return {
      success: true,
      message: `Account for ${user.email} has been unlocked successfully`,
      data: {
        email: user.email,
        name: user.name,
        loginAttempts: 0,
        accountLocked: false,
      },
    }
  }
}
