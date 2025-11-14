import { Prisma } from '.prisma/client'
import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'
import * as bcrypt from 'bcryptjs'
import { PrismaService } from '../prisma/prisma.service'
import { CreateUserDto, UpdateUserDto, UserQueryDto } from './dto/user.dto'

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async create(createUserDto: CreateUserDto) {
    // Check if email already exists
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

    // Hash password
    const hashedPassword = await bcrypt.hash(createUserDto.password, 12)

    // Create user
    const user = await this.prisma.user.create({
      data: {
        roleId: createUserDto.roleId,
        email: createUserDto.email,
        passwordHash: hashedPassword,
        phone: createUserDto.phoneNumber,
        firstName: createUserDto.firstName,
        lastName: createUserDto.lastName,
        name: `${createUserDto.firstName} ${createUserDto.lastName}`,
        emailVerified: createUserDto.isVerified || false,
        accountLocked: createUserDto.accountLocked || false,
        status: createUserDto.status || 'ACTIVE',
      },
      include: {
        role: true,
        student: true,
        teacher: true,
        parent: true,
        staff: true,
      },
    })

    // Remove passwordHash from response
    delete user.passwordHash
    return user
  }

  async findAll(query: UserQueryDto) {
    const { page, limit, search, roleId, status, sortBy, sortOrder } = query
    const skip = (page - 1) * limit

    // Build where clause with proper Prisma typing
    const where: Prisma.UserWhereInput = {
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { firstName: { contains: search, mode: 'insensitive' } },
          { lastName: { contains: search, mode: 'insensitive' } },
          { email: { contains: search, mode: 'insensitive' } },
          { phone: { contains: search, mode: 'insensitive' } },
        ],
      }),
      ...(roleId && { roleId }),
      ...(status && { status }),
    }

    // Build orderBy clause with proper typing
    const orderBy: Prisma.UserOrderByWithRelationInput = {
      [sortBy]: sortOrder,
    }

    // Get users with pagination
    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        include: {
          role: true,
          student: true,
          teacher: true,
          parent: true,
          staff: true,
        },
      }),
      this.prisma.user.count({ where }),
    ])

    // Remove passwordHash from response
    const usersWithoutPasswords = users.map(user => {
      delete user.passwordHash
      return user
    })

    return {
      data: usersWithoutPasswords,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    }
  }

  async findOne(id: number) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        role: true,
        student: {
          include: {
            institution: true,
            course: true,
            parents: {
              include: {
                user: true,
              },
            },
          },
        },
        teacher: {
          include: {
            institution: true,
          },
        },
        parent: {
          include: {
            student: {
              include: {
                user: true,
                institution: true,
                course: true,
              },
            },
          },
        },
        staff: {
          include: {
            institution: true,
          },
        },
      },
    })

    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`)
    }

    // Remove passwordHash from response
    delete user.passwordHash
    return user
  }

  async findByEmail(email: string) {
    const user = await this.prisma.user.findUnique({
      where: { email },
      include: {
        role: true,
        student: true,
        teacher: true,
        parent: true,
        staff: true,
      },
    })

    if (!user) {
      throw new NotFoundException(`User with email ${email} not found`)
    }

    return user
  }

  async update(id: number, updateUserDto: UpdateUserDto) {
    // Check if user exists
    const existingUser = await this.prisma.user.findUnique({
      where: { id },
    })

    if (!existingUser) {
      throw new NotFoundException(`User with ID ${id} not found`)
    }

    // Check if email already exists (if being updated)
    if (updateUserDto.email && updateUserDto.email !== existingUser.email) {
      const emailExists = await this.prisma.user.findUnique({
        where: { email: updateUserDto.email },
      })

      if (emailExists) {
        throw new ConflictException('User with this email already exists')
      }
    }

    // Check if phone number already exists (if being updated)
    if (
      updateUserDto.phoneNumber &&
      updateUserDto.phoneNumber !== existingUser.phone
    ) {
      const phoneExists = await this.prisma.user.findFirst({
        where: { phone: updateUserDto.phoneNumber },
      })

      if (phoneExists) {
        throw new ConflictException(
          'User with this phone number already exists'
        )
      }
    }

    // Build update data with proper typing
    const updateData: Prisma.UserUpdateInput = {
      ...(updateUserDto.roleId && { roleId: updateUserDto.roleId }),
      ...(updateUserDto.email && { email: updateUserDto.email }),
      ...(updateUserDto.phoneNumber && { phone: updateUserDto.phoneNumber }),
      // Handle firstName and lastName updates
      ...(updateUserDto.firstName && { firstName: updateUserDto.firstName }),
      ...(updateUserDto.lastName && { lastName: updateUserDto.lastName }),
      // Update the combined name field for backward compatibility
      ...(updateUserDto.firstName || updateUserDto.lastName
        ? {
            name: (() => {
              const firstName =
                updateUserDto.firstName || existingUser.firstName || ''
              const lastName =
                updateUserDto.lastName || existingUser.lastName || ''
              return `${firstName} ${lastName}`.trim()
            })(),
          }
        : {}),
      ...(updateUserDto.isVerified !== undefined && {
        emailVerified: updateUserDto.isVerified,
      }),
      ...(updateUserDto.accountLocked !== undefined && {
        accountLocked: updateUserDto.accountLocked,
      }),
      ...(updateUserDto.status && { status: updateUserDto.status }),
    }

    // Hash password if being updated
    if (updateUserDto.password) {
      updateData.passwordHash = await bcrypt.hash(updateUserDto.password, 12)
    }

    // Update user
    const user = await this.prisma.user.update({
      where: { id },
      data: updateData,
      include: {
        role: true,
        student: true,
        teacher: true,
        parent: true,
        staff: true,
      },
    })

    // Remove passwordHash from response
    delete user.passwordHash
    return user
  }

  async remove(id: number) {
    // Check if user exists
    const existingUser = await this.prisma.user.findUnique({
      where: { id },
    })

    if (!existingUser) {
      throw new NotFoundException(`User with ID ${id} not found`)
    }

    // Soft delete by updating status
    const user = await this.prisma.user.update({
      where: { id },
      data: { status: 'INACTIVE' },
      include: {
        role: true,
      },
    })

    // Remove passwordHash from response
    delete user.passwordHash
    return user
  }

  async hardDelete(id: number) {
    // Check if user exists
    const existingUser = await this.prisma.user.findUnique({
      where: { id },
    })

    if (!existingUser) {
      throw new NotFoundException(`User with ID ${id} not found`)
    }

    // Hard delete user
    await this.prisma.user.delete({
      where: { id },
    })

    return { message: 'User deleted successfully' }
  }

  async getUsersByRole(roleId: number, query: UserQueryDto) {
    const { page, limit, search, status, sortBy, sortOrder } = query
    const skip = (page - 1) * limit

    // Build where clause with proper Prisma typing
    const where: Prisma.UserWhereInput = {
      roleId,
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { email: { contains: search, mode: 'insensitive' } },
          { phone: { contains: search, mode: 'insensitive' } },
        ],
      }),
      ...(status && { status }),
    }

    // Build orderBy clause with proper typing
    const orderBy: Prisma.UserOrderByWithRelationInput = {
      [sortBy]: sortOrder,
    }

    // Get users with pagination
    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        include: {
          role: true,
          student: true,
          teacher: true,
          parent: true,
          staff: true,
        },
      }),
      this.prisma.user.count({ where }),
    ])

    // Remove passwordHash from response
    const usersWithoutPasswords = users.map(user => {
      delete user.passwordHash
      return user
    })

    return {
      data: usersWithoutPasswords,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    }
  }

  async getUsersStats() {
    const [totalUsers, activeUsers, inactiveUsers, usersByRole] =
      await Promise.all([
        this.prisma.user.count(),
        this.prisma.user.count({ where: { status: 'ACTIVE' } }),
        this.prisma.user.count({ where: { status: 'INACTIVE' } }),
        this.prisma.user.groupBy({
          by: ['roleId'],
          _count: { id: true },
        }),
      ])

    // Get role names separately
    const roleIds = usersByRole.map(item => item.roleId)
    const roles = await this.prisma.role.findMany({
      where: { id: { in: roleIds } },
      select: { id: true, roleName: true },
    })

    const roleMap = new Map(roles.map(role => [role.id, role.roleName]))

    return {
      totalUsers,
      activeUsers,
      inactiveUsers,
      suspendedUsers: totalUsers - activeUsers - inactiveUsers,
      usersByRole: usersByRole.map(({ roleId, _count }) => ({
        roleId,
        count: _count.id,
        roleName: roleMap.get(roleId) || 'Unknown',
      })),
    }
  }

  // UUID-based methods
  async findByUuid(uuid: string) {
    const user = await this.prisma.user.findUnique({
      where: { uuid },
      include: {
        role: true,
        student: {
          include: {
            institution: true,
            course: true,
            parents: {
              include: {
                user: true,
              },
            },
          },
        },
        teacher: {
          include: {
            institution: true,
          },
        },
        parent: {
          include: {
            student: {
              include: {
                user: true,
                institution: true,
                course: true,
              },
            },
          },
        },
        staff: {
          include: {
            institution: true,
          },
        },
      },
    })

    if (!user) {
      throw new NotFoundException(`User with UUID ${uuid} not found`)
    }

    // Remove passwordHash from response
    delete user.passwordHash
    return user
  }

  async updateByUuid(uuid: string, updateUserDto: UpdateUserDto) {
    // Check if user exists
    const existingUser = await this.prisma.user.findUnique({
      where: { uuid },
    })

    if (!existingUser) {
      throw new NotFoundException(`User with UUID ${uuid} not found`)
    }

    // Check if email already exists (if being updated)
    if (updateUserDto.email && updateUserDto.email !== existingUser.email) {
      const emailExists = await this.prisma.user.findUnique({
        where: { email: updateUserDto.email },
      })

      if (emailExists) {
        throw new ConflictException('User with this email already exists')
      }
    }

    // Check if phone number already exists (if being updated)
    if (
      updateUserDto.phoneNumber &&
      updateUserDto.phoneNumber !== existingUser.phone
    ) {
      const phoneExists = await this.prisma.user.findFirst({
        where: { phone: updateUserDto.phoneNumber },
      })

      if (phoneExists) {
        throw new ConflictException(
          'User with this phone number already exists'
        )
      }
    }

    // Build update data with proper typing
    const updateData: Prisma.UserUpdateInput = {
      ...(updateUserDto.roleId && { roleId: updateUserDto.roleId }),
      ...(updateUserDto.email && { email: updateUserDto.email }),
      ...(updateUserDto.phoneNumber && { phone: updateUserDto.phoneNumber }),
      // Handle firstName and lastName updates
      ...(updateUserDto.firstName && { firstName: updateUserDto.firstName }),
      ...(updateUserDto.lastName && { lastName: updateUserDto.lastName }),
      // Update the combined name field for backward compatibility
      ...(updateUserDto.firstName || updateUserDto.lastName
        ? {
            name: (() => {
              const firstName =
                updateUserDto.firstName || existingUser.firstName || ''
              const lastName =
                updateUserDto.lastName || existingUser.lastName || ''
              return `${firstName} ${lastName}`.trim()
            })(),
          }
        : {}),
      ...(updateUserDto.isVerified !== undefined && {
        emailVerified: updateUserDto.isVerified,
      }),
      ...(updateUserDto.accountLocked !== undefined && {
        accountLocked: updateUserDto.accountLocked,
      }),
      ...(updateUserDto.status && { status: updateUserDto.status }),
    }

    // Hash password if being updated
    if (updateUserDto.password) {
      updateData.passwordHash = await bcrypt.hash(updateUserDto.password, 12)
    }

    // Update user
    const user = await this.prisma.user.update({
      where: { uuid },
      data: updateData,
      include: {
        role: true,
        student: true,
        teacher: true,
        parent: true,
        staff: true,
      },
    })

    // Remove passwordHash from response
    delete user.passwordHash
    return user
  }

  async removeByUuid(uuid: string) {
    // Check if user exists
    const existingUser = await this.prisma.user.findUnique({
      where: { uuid },
    })

    if (!existingUser) {
      throw new NotFoundException(`User with UUID ${uuid} not found`)
    }

    // Soft delete by updating status
    const user = await this.prisma.user.update({
      where: { uuid },
      data: { status: 'INACTIVE' },
      include: {
        role: true,
      },
    })

    // Remove passwordHash from response
    delete user.passwordHash
    return user
  }

  async hardDeleteByUuid(uuid: string) {
    // Check if user exists
    const existingUser = await this.prisma.user.findUnique({
      where: { uuid },
    })

    if (!existingUser) {
      throw new NotFoundException(`User with UUID ${uuid} not found`)
    }

    // Hard delete user
    await this.prisma.user.delete({
      where: { uuid },
    })

    return { message: 'User deleted successfully' }
  }
}
