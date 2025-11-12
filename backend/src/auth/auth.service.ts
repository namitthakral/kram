import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { JwtService } from '@nestjs/jwt'
import * as bcrypt from 'bcryptjs'
import { PrismaService } from '../prisma/prisma.service'
import { UserWithRelations } from '../types/auth.types'
import {
  generateEdVerseId,
  generateTemporaryPassword,
} from '../utils/edverse-id.util'
import {
  ActivateAccountDto,
  ChangePasswordDto,
  LoginDto,
  SelfRegistrationDto,
} from './dto/auth.dto'

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService
  ) {}

  async validateUser(loginDto: LoginDto): Promise<UserWithRelations | null> {
    let user: UserWithRelations | null = null

    // Try to find user by EdVerse ID, email, or phone
    if (loginDto.edverseId) {
      user = await this.prisma.user.findUnique({
        where: { edverseId: loginDto.edverseId },
        include: {
          role: true,
          student: true,
          teacher: true,
          parent: true,
        },
      })
    } else if (loginDto.email) {
      user = await this.prisma.user.findUnique({
        where: { email: loginDto.email },
        include: {
          role: true,
          student: true,
          teacher: true,
          parent: true,
        },
      })
    } else if (loginDto.phone) {
      user = await this.prisma.user.findFirst({
        where: { phone: loginDto.phone },
        include: {
          role: true,
          student: true,
          teacher: true,
          parent: true,
        },
      })
    }

    if (!user) {
      return null
    }

    const isPasswordValid = await bcrypt.compare(
      loginDto.password,
      user.passwordHash
    )
    if (!isPasswordValid) {
      return null
    }

    return user
  }

  async login(loginDto: LoginDto) {
    const user = await this.validateUser(loginDto)

    if (!user) {
      // Handle failed login attempt - increment loginAttempts
      await this.handleFailedLogin(loginDto)
      throw new UnauthorizedException('Invalid credentials')
    }

    // Check if account is locked
    if (user.accountLocked) {
      throw new UnauthorizedException(
        'Account is locked due to too many failed login attempts. Please contact support to unlock your account.'
      )
    }

    // Allow login even if INACTIVE (for users with temporary passwords)
    // Frontend will handle forcing password change based on requiresPasswordChange flag
    // Only block SUSPENDED accounts
    if (user.status === 'SUSPENDED') {
      throw new UnauthorizedException(
        'Account has been suspended. Please contact support.'
      )
    }

    const payload = {
      userId: user.id,
      email: user.email,
      roleId: user.roleId,
    }

    const accessToken = this.jwtService.sign(payload)
    const refreshToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      expiresIn: '7d',
    })

    // Update last login and reset login attempts on successful login
    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        lastLogin: new Date(),
        loginAttempts: 0, // Reset failed attempts counter
      },
    })

    return {
      user: {
        id: user.id,
        uuid: user.uuid,
        edverseId: user.edverseId,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        student: user.student,
        teacher: user.teacher,
        parent: user.parent,
        status: user.status,
        mustChangePassword: user.mustChangePassword, // Frontend checks this flag
        isTemporaryPassword: user.isTemporaryPassword, // For context/audit
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
      tokens: {
        accessToken,
        refreshToken,
        expiresIn: 3600, // 1 hour (matches JWT_EXPIRES_IN in auth.module.ts)
      },
    }
  }

  /**
   * Handle failed login attempt - increment loginAttempts and lock account if threshold reached
   */
  private async handleFailedLogin(loginDto: LoginDto) {
    const MAX_LOGIN_ATTEMPTS = 5

    // Find user by email, phone, or edverseId
    let userToUpdate = null

    if (loginDto.email) {
      userToUpdate = await this.prisma.user.findUnique({
        where: { email: loginDto.email },
      })
    } else if (loginDto.phone) {
      userToUpdate = await this.prisma.user.findFirst({
        where: { phone: loginDto.phone },
      })
    } else if (loginDto.edverseId) {
      userToUpdate = await this.prisma.user.findUnique({
        where: { edverseId: loginDto.edverseId },
      })
    }

    // If user exists, increment login attempts
    if (userToUpdate) {
      const newAttempts = userToUpdate.loginAttempts + 1
      const shouldLock = newAttempts >= MAX_LOGIN_ATTEMPTS

      await this.prisma.user.update({
        where: { id: userToUpdate.id },
        data: {
          loginAttempts: newAttempts,
          accountLocked: shouldLock,
        },
      })

      // Log the failed attempt for security monitoring
      console.warn(
        `Failed login attempt for user ${userToUpdate.email || userToUpdate.phone || userToUpdate.edverseId}. ` +
          `Attempts: ${newAttempts}/${MAX_LOGIN_ATTEMPTS}${shouldLock ? ' - Account LOCKED' : ''}`
      )
    }
  }

  async refreshToken(userId: number) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        role: true,
        student: true,
        teacher: true,
        parent: true,
      },
    })

    if (!user || user.status !== 'ACTIVE') {
      throw new UnauthorizedException('User not found or inactive')
    }

    const payload = {
      userId: user.id,
      email: user.email,
      roleId: user.roleId,
    }

    // Generate new access token
    const accessToken = this.jwtService.sign(payload)

    // Generate new refresh token (token rotation for security)
    const refreshToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      expiresIn: '7d',
    })

    return {
      tokens: {
        accessToken,
        refreshToken,
        expiresIn: 3600, // 1 hour (matches JWT_EXPIRES_IN in auth.module.ts)
      },
    }
  }

  async selfRegister(
    selfRegistrationDto: SelfRegistrationDto,
    institutionCode?: string
  ) {
    // Check if user already exists
    const existingUser = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: selfRegistrationDto.email },
          { phone: selfRegistrationDto.phoneNumber },
        ],
      },
    })

    if (existingUser) {
      throw new ConflictException(
        'User with this email or phone already exists'
      )
    }

    // Get role by ID
    const role = await this.prisma.role.findUnique({
      where: { id: selfRegistrationDto.roleId },
    })

    if (!role) {
      throw new ConflictException('Invalid role ID')
    }

    // Restrict certain roles from self-registration
    const restrictedRoles = ['super_admin', 'admin', 'staff', 'librarian']
    if (restrictedRoles.includes(role.roleName)) {
      throw new ConflictException(
        `The ${role.roleName} role cannot be self-registered. Please contact your institution administrator.`
      )
    }

    // Determine institution ID
    let institutionId = selfRegistrationDto.institutionId

    // If institution code provided in query parameter, look it up
    if (institutionCode && !institutionId) {
      const instByCode = await this.prisma.institution.findUnique({
        where: { code: institutionCode.toUpperCase() },
        select: { id: true },
      })

      if (instByCode) {
        institutionId = instByCode.id
      }
    }

    // If still no institution ID, default to 1 (for backward compatibility)
    if (!institutionId) {
      institutionId = 1
      console.warn(
        '⚠️  No institutionId or code provided, defaulting to institution ID 1'
      )
    }

    // Get institution to generate EdVerse ID with institution code
    const institution = await this.prisma.institution.findUnique({
      where: { id: institutionId },
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

    // Hash password
    const hashedPassword = await bcrypt.hash(selfRegistrationDto.password, 12)

    // Combine firstName and lastName into name
    const fullName =
      `${selfRegistrationDto.firstName} ${selfRegistrationDto.lastName}`.trim()

    // Create user with ACTIVE status (self-registered users are active immediately)
    const user = await this.prisma.user.create({
      data: {
        firstName: selfRegistrationDto.firstName,
        lastName: selfRegistrationDto.lastName,
        name: fullName,
        email: selfRegistrationDto.email,
        phone: selfRegistrationDto.phoneNumber,
        passwordHash: hashedPassword,
        roleId: role.id,
        edverseId,
        status: 'ACTIVE', // Self-registered users are active immediately
        isTemporaryPassword: false, // Self-registered users set their own password
        mustChangePassword: false,
      },
      include: {
        role: true,
      },
    })

    // Create role-specific record
    await this.createRoleSpecificRecord(user, role.roleName)

    // Handle parent-child mapping if provided
    if (role.roleName === 'parent' && selfRegistrationDto.childEdverseId) {
      await this.mapParentToChild(user.id, selfRegistrationDto.childEdverseId)
    }

    return {
      success: true,
      message: 'User registered successfully',
      data: {
        id: user.id,
        uuid: user.uuid,
        edverseId: user.edverseId,
        firstName: user.firstName,
        lastName: user.lastName,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        status: user.status,
        createdAt: user.createdAt,
      },
    }
  }

  async activateAccount(activateAccountDto: ActivateAccountDto) {
    // Find user by EdVerse ID
    const user = await this.prisma.user.findUnique({
      where: { edverseId: activateAccountDto.edverseId },
      include: { role: true },
    })

    if (!user) {
      throw new UnauthorizedException('Invalid EdVerse ID')
    }

    // Check if user has a temporary password
    if (!user.isTemporaryPassword) {
      throw new UnauthorizedException(
        'This account does not have a temporary password. Please use the regular login.'
      )
    }

    // Verify temporary password
    const isTemporaryPasswordValid = await bcrypt.compare(
      activateAccountDto.temporaryPassword,
      user.passwordHash
    )

    if (!isTemporaryPasswordValid) {
      throw new UnauthorizedException('Invalid temporary password')
    }

    // Hash new password
    const hashedNewPassword = await bcrypt.hash(
      activateAccountDto.newPassword,
      12
    )

    // Update password, activate account, and clear temporary flags
    const updatedUser = await this.prisma.user.update({
      where: { id: user.id },
      data: {
        passwordHash: hashedNewPassword,
        status: 'ACTIVE', // Activate the account
        isTemporaryPassword: false,
        mustChangePassword: false,
      },
      include: { role: true },
    })

    return {
      success: true,
      message:
        'Account activated successfully. You can now login with your new password.',
      data: {
        id: updatedUser.id,
        uuid: updatedUser.uuid,
        edverseId: updatedUser.edverseId,
        email: updatedUser.email,
        status: updatedUser.status,
      },
    }
  }

  async changePassword(userId: number, changePasswordDto: ChangePasswordDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    })

    if (!user) {
      throw new UnauthorizedException('User not found')
    }

    // Verify current password
    const isCurrentPasswordValid = await bcrypt.compare(
      changePasswordDto.currentPassword,
      user.passwordHash
    )

    if (!isCurrentPasswordValid) {
      throw new UnauthorizedException('Current password is incorrect')
    }

    // Hash new password
    const hashedNewPassword = await bcrypt.hash(
      changePasswordDto.newPassword,
      12
    )

    // Update password and clear temporary flags
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        passwordHash: hashedNewPassword,
        isTemporaryPassword: false,
        mustChangePassword: false,
        status: 'ACTIVE', // Also activate if they were inactive
      },
    })

    return {
      success: true,
      message: 'Password changed successfully',
    }
  }

  async mapParentToChild(parentUserId: number, childEdverseId: string) {
    // Find the child student
    const childUser = await this.prisma.user.findUnique({
      where: { edverseId: childEdverseId },
      include: { student: true },
    })

    if (!childUser || !childUser.student) {
      throw new ConflictException(
        'Student not found with the provided EdVerse ID'
      )
    }

    // Check if parent record exists
    const parentRecord = await this.prisma.parent.findUnique({
      where: { userId: parentUserId },
    })

    if (parentRecord) {
      // Update existing parent record
      await this.prisma.parent.update({
        where: { userId: parentUserId },
        data: { studentId: childUser.student.id },
      })
    } else {
      // Create new parent record
      await this.prisma.parent.create({
        data: {
          userId: parentUserId,
          studentId: childUser.student.id,
          relation: 'GUARDIAN', // Default relation
          isPrimaryContact: true,
        },
      })
    }

    return {
      success: true,
      message: 'Parent-child mapping created successfully',
    }
  }

  private async createRoleSpecificRecord(
    user: { id: number },
    roleName: string
  ) {
    switch (roleName) {
      case 'student':
        // Create student record - will need institution and program info
        // For now, we'll create a basic record
        await this.prisma.student.create({
          data: {
            userId: user.id,
            institutionId: 1, // Default institution - should be configurable
            admissionNumber: `ADM${Date.now()}`, // Generate unique admission number
            studentType: 'REGULAR',
            residentialStatus: 'DAY_SCHOLAR',
          },
        })
        break

      case 'teacher':
        // Create teacher record
        await this.prisma.teacher.create({
          data: {
            userId: user.id,
            institutionId: 1, // Default institution
            employeeId: `EMP${Date.now()}`, // Generate unique employee ID
            employmentType: 'FULL_TIME',
          },
        })
        break

      case 'staff':
        // Create staff record
        await this.prisma.staff.create({
          data: {
            userId: user.id,
            institutionId: 1, // Default institution
            employeeId: `STAFF${Date.now()}`, // Generate unique employee ID
            staffType: 'ADMINISTRATIVE',
            designation: 'Staff Member',
            employmentType: 'FULL_TIME',
          },
        })
        break

      case 'parent':
        // Parent record will be created when mapping to child
        break
    }
  }

  async createUserWithTemporaryPassword(userData: {
    firstName: string
    lastName: string
    email?: string
    phone?: string
    roleId: number
    institutionId?: number
  }) {
    // Generate temporary password
    const tempPassword = generateTemporaryPassword(
      userData.firstName,
      userData.lastName
    )
    const hashedPassword = await bcrypt.hash(tempPassword, 12)

    // Get role for EdVerse ID generation
    const role = await this.prisma.role.findUnique({
      where: { id: userData.roleId },
    })

    if (!role) {
      throw new ConflictException('Invalid role ID')
    }

    // Get institution to generate EdVerse ID with institution code
    const institution = await this.prisma.institution.findUnique({
      where: { id: userData.institutionId },
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

    // Create user
    const user = await this.prisma.user.create({
      data: {
        firstName: userData.firstName,
        lastName: userData.lastName,
        name: `${userData.firstName} ${userData.lastName}`.trim(),
        email: userData.email,
        phone: userData.phone,
        passwordHash: hashedPassword,
        roleId: userData.roleId,
        edverseId,
        isTemporaryPassword: true,
        mustChangePassword: true,
      },
      include: {
        role: true,
      },
    })

    return {
      user,
      temporaryPassword: tempPassword,
    }
  }
}
