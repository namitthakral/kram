import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { JwtService } from '@nestjs/jwt'
import { UserAccountStatus } from '@prisma/client'
import * as bcrypt from 'bcryptjs'
import { PrismaService } from '../prisma/prisma.service'
import { UserWithRelations } from '../types/auth.types'
import { UserHelpers } from '../types/user.types'
import { generateTemporaryPassword } from '../utils/kramid.util'
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

  /**
   * Find user by credentials without password validation
   */
  private async findUserByCredentials(
    loginDto: LoginDto
  ): Promise<UserWithRelations | null> {
    let user: UserWithRelations | null = null

    // Try to find user by Kram ID, email, or phone
    if (loginDto.kramid) {
      user = await this.prisma.user.findUnique({
        where: { kramid: loginDto.kramid },
        include: {
          role: true,
          student: true,
          teacher: true,
          parents: true,
          staff: true,
        },
      })
    } else if (loginDto.email) {
      user = await this.prisma.user.findUnique({
        where: { email: loginDto.email.toLowerCase() },
        include: {
          role: true,
          student: true,
          teacher: true,
          parents: true,
          staff: true,
        },
      })
    } else if (loginDto.phone) {
      user = await this.prisma.user.findFirst({
        where: { phone: loginDto.phone },
        include: {
          role: true,
          student: true,
          teacher: true,
          parents: true,
          staff: true,
        },
      })
    }

    if (user) {
      // Debug logging
      console.log('User found:', {
        id: user.id,
        email: user.email,
        accountStatus: user.accountStatus,
        loginAttempts: user.loginAttempts,
        student: user.student?.id,
        teacher: user.teacher?.id,
        staff: user.staff?.id,
      })
    }

    return user
  }

  async validateUser(loginDto: LoginDto): Promise<UserWithRelations | null> {
    const user = await this.findUserByCredentials(loginDto)

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

  /**
   * Resolve institutionId for a user.
   * Checks user.institutionId first (set directly for admins and all new users),
   * then falls back to sub-model records for backward compatibility.
   */
  private resolveInstitutionId(user: {
    institutionId?: number | null
    student?: { institutionId: number } | null
    teacher?: { institutionId: number } | null
    staff?: { institutionId: number } | null
  }): number | null {
    return (
      user.institutionId ??
      user.student?.institutionId ??
      user.teacher?.institutionId ??
      user.staff?.institutionId ??
      null
    )
  }

  /**
   * Resolve institution (id + name) for a user.
   */
  private async resolveInstitution(user: UserWithRelations) {
    let id = this.resolveInstitutionId(user)

    // Fallback for admins who don't have an institutionId set
    if (
      id == null &&
      (user.role?.roleName === 'super_admin' || user.role?.roleName === 'admin')
    ) {
      const firstInstitution = await this.prisma.institution.findFirst({
        orderBy: { id: 'asc' },
        select: { id: true },
      })
      id = firstInstitution?.id ?? null
    }

    if (id == null) return null

    const institution = await this.prisma.institution.findUnique({
      where: { id },
      select: { id: true, name: true, type: true },
    })

    return institution
      ? { ...institution, type: institution.type.toString() }
      : null
  }

  /**
   * Get profile for API response (includes institutionId and omits passwordHash).
   * Uses resolveInstitutionId so admin/super_admin get first institution when they have no Staff.
   */
  async getProfileForResponse(userId: number) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        role: true,
        student: true,
        teacher: true,
        parents: true,
        staff: true,
      },
    })
    if (!user) throw new UnauthorizedException('User not found')
    const institution = await this.resolveInstitution(user)
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { passwordHash, ...safeUser } = user
    return {
      success: true,
      data: {
        ...safeUser,
        institutionId: institution?.id ?? null,
        institution,
      },
    }
  }

  async login(loginDto: LoginDto) {
    // First, find the user without validating password
    const user = await this.findUserByCredentials(loginDto)

    if (!user) {
      throw new UnauthorizedException('Invalid credentials')
    }

    // Check if account is blocked from login
    if (UserHelpers.isBlocked(user.accountStatus)) {
      const statusDescription = UserHelpers.getStatusDescription(
        user.accountStatus
      )
      throw new UnauthorizedException(
        `Login denied: ${statusDescription}. Please contact support.`
      )
    }

    // Now validate the password
    const isPasswordValid = await bcrypt.compare(
      loginDto.password,
      user.passwordHash
    )

    if (!isPasswordValid) {
      // Handle failed login attempt - increment loginAttempts
      await this.handleFailedLogin(loginDto)
      throw new UnauthorizedException('Invalid credentials')
    }

    // Allow login for ACTIVE and PENDING_ACTIVATION users
    // Frontend will handle password change requirement for PENDING_ACTIVATION
    if (!UserHelpers.canLogin(user.accountStatus)) {
      const statusDescription = UserHelpers.getStatusDescription(
        user.accountStatus
      )
      throw new UnauthorizedException(
        `Login denied: ${statusDescription}. Please contact support.`
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
        // If user was locked, set to active (unless they need password change)
        ...(user.accountStatus === ('LOCKED' as UserAccountStatus) && {
          accountStatus: UserHelpers.needsPasswordChange(user.accountStatus)
            ? ('PENDING_ACTIVATION' as UserAccountStatus)
            : ('ACTIVE' as UserAccountStatus),
        }),
      },
    })

    const institution = await this.resolveInstitution(user)

    return {
      user: {
        id: user.id,
        uuid: user.uuid,
        kramid: user.kramid,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phone: user.phone,
        role: user.role,
        student: user.student,
        teacher: user.teacher,
        parent: user.parent,
        staff: user.staff,
        institutionId: institution?.id ?? null,
        institution,
        accountStatus: user.accountStatus,
        mustChangePassword: UserHelpers.needsPasswordChange(user.accountStatus), // Frontend checks this flag
        statusDescription: UserHelpers.getStatusDescription(user.accountStatus),
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

    // Find user by email, phone, or kramid
    let userToUpdate = null

    if (loginDto.email) {
      userToUpdate = await this.prisma.user.findUnique({
        where: { email: loginDto.email.toLowerCase() },
      })
    } else if (loginDto.phone) {
      userToUpdate = await this.prisma.user.findFirst({
        where: { phone: loginDto.phone },
      })
    } else if (loginDto.kramid) {
      userToUpdate = await this.prisma.user.findUnique({
        where: { kramid: loginDto.kramid },
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
          // Lock account if max attempts reached (unless already suspended)
          ...(shouldLock &&
            userToUpdate.accountStatus !==
              ('SUSPENDED' as UserAccountStatus) && {
              accountStatus: 'LOCKED' as UserAccountStatus,
            }),
        },
      })

      // Log the failed attempt for security monitoring
      console.warn(
        `Failed login attempt for user ${userToUpdate.email || userToUpdate.phone || userToUpdate.kramid}. ` +
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
        parents: true,
      },
    })

    if (!user || user.accountStatus !== 'ACTIVE') {
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
          { email: selfRegistrationDto.email.toLowerCase() },
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

    // Get institution for validation (Kram ID is auto-generated by database)
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

    // Note: Kram ID is auto-generated by database trigger
    // No need to manually generate it here

    // Hash password
    const hashedPassword = await bcrypt.hash(selfRegistrationDto.password, 12)

    // Create user with ACTIVE status (self-registered users are active immediately)
    const user = await this.prisma.user.create({
      data: {
        firstName: selfRegistrationDto.firstName,
        lastName: selfRegistrationDto.lastName,
        email: selfRegistrationDto.email.toLowerCase(),
        phone: selfRegistrationDto.phoneNumber,
        passwordHash: hashedPassword,
        roleId: role.id,
        // kramid is auto-generated by database trigger
        accountStatus: 'ACTIVE', // Self-registered users are active immediately
      },
      include: {
        role: true,
      },
    })

    // Create role-specific record
    await this.createRoleSpecificRecord(user, role.roleName)

    // Handle parent-child mapping if provided
    if (role.roleName === 'parent' && selfRegistrationDto.childKramid) {
      await this.mapParentToChild(user.id, selfRegistrationDto.childKramid)
    }

    return {
      success: true,
      message: 'User registered successfully',
      data: {
        id: user.id,
        uuid: user.uuid,
        kramid: user.kramid,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phone: user.phone,
        role: user.role,
        accountStatus: user.accountStatus,
        createdAt: user.createdAt,
      },
    }
  }

  async activateAccount(activateAccountDto: ActivateAccountDto) {
    // Find user by Kram ID
    const user = await this.prisma.user.findUnique({
      where: { kramid: activateAccountDto.kramid },
      include: { role: true },
    })

    if (!user) {
      throw new UnauthorizedException('Invalid Kram ID')
    }

    // Check if user needs password change
    if (!UserHelpers.needsPasswordChange(user.accountStatus)) {
      throw new UnauthorizedException(
        'This account does not require password change. Please use the regular login.'
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
        accountStatus: 'ACTIVE', // Activate the account
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
        kramid: updatedUser.kramid,
        email: updatedUser.email,
        accountStatus: updatedUser.accountStatus,
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
        accountStatus: 'ACTIVE', // Also activate if they were inactive
      },
    })

    return {
      success: true,
      message: 'Password changed successfully',
    }
  }

  async mapParentToChild(parentUserId: number, childKramid: string) {
    // Find the child student
    const childUser = await this.prisma.user.findUnique({
      where: { kramid: childKramid },
      include: { student: true },
    })

    if (!childUser || !childUser.student) {
      throw new ConflictException('Student not found with the provided Kram ID')
    }

    // Check if parent record exists for this user and student
    const parentRecord = await this.prisma.parent.findFirst({
      where: {
        userId: parentUserId,
        studentId: childUser.student.id,
      },
    })

    if (!parentRecord) {
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

    // Get role for validation
    const role = await this.prisma.role.findUnique({
      where: { id: userData.roleId },
    })

    if (!role) {
      throw new ConflictException('Invalid role ID')
    }

    // Get institution for validation (Kram ID is auto-generated by database)
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

    // Note: Kram ID is auto-generated by database trigger
    // No need to manually generate it here

    // Create user
    const user = await this.prisma.user.create({
      data: {
        firstName: userData.firstName,
        lastName: userData.lastName,
        email: userData.email?.toLowerCase(),
        phone: userData.phone,
        passwordHash: hashedPassword,
        roleId: userData.roleId,
        // kramid is auto-generated by database trigger
        accountStatus: 'PENDING_ACTIVATION' as UserAccountStatus, // User must change password before becoming active
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
