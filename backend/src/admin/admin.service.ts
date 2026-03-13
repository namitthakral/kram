import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
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
import { IdGenerationService } from '../id-generation/id-generation.service'
import { UpdateInstitutionDto } from '../institutions/dto/institution.dto'
import { PrismaService } from '../prisma/prisma.service'
import { generateTemporaryPassword } from '../utils/kramid.util'
import { UpdateGradingConfigDto } from './dto/grading-config.dto'
import { CreateSemesterDto, UpdateSemesterDto } from './dto/semester.dto'

@Injectable()
export class AdminService {
  constructor(
    private prisma: PrismaService,
    private idGeneration: IdGenerationService
  ) {}

  async getAcademicYears(institutionId: number | null) {
    return this.prisma.academicYear.findMany({
      where: {
        ...(institutionId !== null && { institutionId }),
      },
      orderBy: {
        startDate: 'desc',
      },
    })
  }

  async getSemesters(academicYearId: number) {
    return this.prisma.semester.findMany({
      where: {
        academicYearId,
      },
      orderBy: {
        semesterNumber: 'asc',
      },
    })
  }

  async createSemester(dto: CreateSemesterDto, institutionId: number | null) {
    // Verify academic year belongs to the institution
    const academicYear = await this.prisma.academicYear.findUnique({
      where: { id: dto.academicYearId },
    })

    if (!academicYear) {
      throw new NotFoundException('Academic year not found')
    }

    if (institutionId !== null && academicYear.institutionId !== institutionId) {
      throw new ForbiddenException(
        'You can only create semesters for your own institution'
      )
    }

    // Check if semester number already exists for this academic year
    const existingSemester = await this.prisma.semester.findFirst({
      where: {
        academicYearId: dto.academicYearId,
        semesterNumber: dto.semesterNumber,
      },
    })

    if (existingSemester) {
      throw new ConflictException(
        `Semester number ${dto.semesterNumber} already exists for this academic year`
      )
    }

    return this.prisma.semester.create({
      data: {
        academicYearId: dto.academicYearId,
        semesterName: dto.semesterName,
        semesterNumber: dto.semesterNumber,
        startDate: new Date(dto.startDate),
        endDate: new Date(dto.endDate),
        registrationStart: dto.registrationStart
          ? new Date(dto.registrationStart)
          : null,
        registrationEnd: dto.registrationEnd
          ? new Date(dto.registrationEnd)
          : null,
      },
    })
  }

  async updateSemester(
    id: number,
    dto: UpdateSemesterDto,
    institutionId: number | null
  ) {
    const semester = await this.prisma.semester.findUnique({
      where: { id },
      include: { academicYear: true },
    })

    if (!semester) {
      throw new NotFoundException('Semester not found')
    }

    if (
      institutionId !== null &&
      semester.academicYear.institutionId !== institutionId
    ) {
      throw new ForbiddenException(
        'You can only update semesters for your own institution'
      )
    }

    if (dto.status === 'ACTIVE') {
      // Find all active semesters for this institution and set them to COMPLETED
      // Semesters are linked to AcademicYears which are linked to Institutions
      await this.prisma.semester.updateMany({
        where: {
          status: 'ACTIVE',
          academicYear: {
            institutionId: semester.academicYear.institutionId,
          },
          id: { not: id },
        },
        data: {
          status: 'COMPLETED',
        },
      })
    }

    return this.prisma.semester.update({
      where: { id },
      data: {
        ...(dto.semesterName && { semesterName: dto.semesterName }),
        ...(dto.semesterNumber && { semesterNumber: dto.semesterNumber }),
        ...(dto.startDate && { startDate: new Date(dto.startDate) }),
        ...(dto.endDate && { endDate: new Date(dto.endDate) }),
        ...(dto.registrationStart !== undefined && {
          registrationStart: dto.registrationStart
            ? new Date(dto.registrationStart)
            : null,
        }),
        ...(dto.registrationEnd !== undefined && {
          registrationEnd: dto.registrationEnd
            ? new Date(dto.registrationEnd)
            : null,
        }),
        ...(dto.status && { status: dto.status }),
      },
    })
  }

  async createInstitutionalUser(
    createUserDto: CreateUserDto,
    adminInstitutionId: number | null
  ) {
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

    // Get role to determine Kram ID prefix
    const role = await this.prisma.role.findUnique({
      where: { id: createUserDto.roleId },
    })

    if (!role) {
      throw new ConflictException('Invalid role ID')
    }

    // Get institution to generate Kram ID with institution code
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

    if (
      adminInstitutionId !== null &&
      createUserDto.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException(
        'You can only create users for your own institution'
      )
    }

    // Note: Kram ID is auto-generated by database trigger
    // No need to manually generate it here

    // Use custom password if provided, otherwise auto-generate from name
    const temporaryPassword = createUserDto.password?.trim()
      ? createUserDto.password.trim()
      : generateTemporaryPassword(
          createUserDto.firstName,
          createUserDto.lastName
        )

    // Log which password method was used for debugging
    console.log(`Creating user ${createUserDto.email}:`, {
      firstName: createUserDto.firstName,
      lastName: createUserDto.lastName,
      customPasswordProvided: !!createUserDto.password?.trim(),
      generatedPassword: !createUserDto.password?.trim()
        ? temporaryPassword
        : '[CUSTOM]',
    })

    const hashedPassword = await bcrypt.hash(temporaryPassword, 12)

    // Combine firstName and lastName into name for database compatibility
    const fullName =
      `${createUserDto.firstName} ${createUserDto.lastName}`.trim()

    // Create user with INACTIVE status (requires password change to become active)
    const userData: Prisma.UserUncheckedCreateInput = {
      firstName: createUserDto.firstName,
      lastName: createUserDto.lastName,
      name: fullName,
      email: createUserDto.email,
      phone: createUserDto.phoneNumber,
      passwordHash: hashedPassword,
      roleId: createUserDto.roleId,
      institutionId: createUserDto.institutionId,
      // kramid is auto-generated by database trigger
      status: 'INACTIVE', // User must change password before becoming active
      isTemporaryPassword: true,
      mustChangePassword: true,
    }
    const user = await this.prisma.user.create({
      data: userData,
      include: {
        role: true,
      },
    })

    // Create role-specific profile when data is provided
    const roleName = role.roleName?.toLowerCase() ?? ''
    if (roleName === 'student' && createUserDto.studentData) {
      const sd = createUserDto.studentData
      let courseCode: string | undefined
      if (sd.courseId) {
        const course = await this.prisma.course.findUnique({
          where: { id: sd.courseId },
          select: { code: true },
        })
        courseCode = course?.code ?? undefined
      }
      const admissionNumber = await this.idGeneration.generateAdmissionNumber({
        institutionId: createUserDto.institutionId,
        courseCode: courseCode ?? 'GEN',
        section: sd.section ?? undefined,
      })
      let rollNumber: string | null = sd.rollNumber ?? null
      if (!rollNumber && sd.section) {
        rollNumber = await this.idGeneration.generateRollNumber({
          institutionId: createUserDto.institutionId,
          courseCode: courseCode ?? 'GEN',
          section: sd.section ?? 'A',
        })
      }
      const student = await this.prisma.student.create({
        data: {
          userId: user.id,
          institutionId: createUserDto.institutionId,
          admissionNumber,
          rollNumber,
          courseId: sd.courseId ?? undefined,
          section: sd.section ?? undefined,
          admissionDate: sd.admissionDate
            ? new Date(sd.admissionDate)
            : new Date(),
          studentType: sd.studentType ?? 'REGULAR',
          residentialStatus: sd.residentialStatus ?? 'DAY_SCHOLAR',
          transportRequired: sd.transportRequired ?? false,
        },
      })

      // Create parent records based on provided parent information
      await this.createParentRecords(student.id, sd, adminInstitutionId)
    } else if (roleName === 'teacher' && createUserDto.teacherData) {
      const td = createUserDto.teacherData
      const employeeId =
        td.employeeId ??
        (await this.idGeneration.generateTeacherEmployeeId({
          institutionId: createUserDto.institutionId,
        }))
      await this.prisma.teacher.create({
        data: {
          userId: user.id,
          institutionId: createUserDto.institutionId,
          employeeId,
          designation: td.designation ?? undefined,
          specialization: td.specialization ?? undefined,
          qualification: td.qualification ?? undefined,
          experienceYears: td.experienceYears ?? 0,
          joinDate: td.joinDate ? new Date(td.joinDate) : new Date(),
          employmentType: td.employmentType ?? 'FULL_TIME',
          officeLocation: td.officeLocation ?? undefined,
          officeHours: td.officeHours ?? undefined,
        },
      })
    } else if (roleName === 'parent' && createUserDto.parentData) {
      const pd = createUserDto.parentData
      
      if (!pd.childKramid || pd.childKramid.trim() === '') {
        throw new BadRequestException(
          'parentData with valid childKramid is required for parent role'
        )
      }

      // Find the child student by Kram ID
      const childUser = await this.prisma.user.findUnique({
        where: { kramid: pd.childKramid.trim() },
        include: { student: true },
      })

      if (!childUser || !childUser.student) {
        throw new NotFoundException(
          `Student not found with Kram ID: ${pd.childKramid}`
        )
      }

      await this.prisma.parent.create({
        data: {
          userId: user.id,
          studentId: childUser.student.id,
          relation: (pd.relation as 'FATHER' | 'MOTHER' | 'GUARDIAN' | 'OTHER') || 'GUARDIAN',
          isPrimaryContact: pd.isPrimaryContact ?? true,
          occupation: pd.occupation ?? undefined,
          annualIncome: pd.annualIncome ?? undefined,
          educationLevel: pd.educationLevel ?? undefined,
        },
      })
    }

    // The DB trigger fires on INSERT but child records (student/teacher/staff)
    // don't exist yet at that point, so kramid is always null after INSERT.
    // For roles without child records (admin, parent), the trigger can never
    // resolve the institution. Explicitly assign kramid here using the DB function.
    let kramid = user.kramid
    if (!kramid) {
      const result = await this.prisma.$queryRawUnsafe<{ kramid: string }[]>(
        `SELECT generate_kramid($1, $2) as kramid`,
        institution.code,
        role.roleName
      )
      kramid = result[0]?.kramid ?? null
      if (kramid) {
        await this.prisma.user.update({
          where: { id: user.id },
          data: { kramid },
        })
      }
    }

    return {
      success: true,
      message: 'Institutional user created successfully',
      data: {
        id: user.id,
        uuid: user.uuid,
        kramid,
        firstName: createUserDto.firstName,
        lastName: createUserDto.lastName,
        name: user.name,
        email: user.email,
        phoneNumber: user.phone,
        role: user.role,
        status: user.status,
        isTemporaryPassword: !createUserDto.password?.trim(),
        temporaryPassword: !createUserDto.password?.trim()
          ? temporaryPassword
          : undefined,
        mustChangePassword: user.mustChangePassword,
        createdAt: user.createdAt,
      },
    }
  }

  async getAllUsers(query: UserQueryDto, institutionId: number | null) {
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
        { kramid: { contains: search, mode: 'insensitive' } },
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

    if (institutionId) {
      where.institutionId = institutionId
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

  async getUsersStats(institutionId: number | null) {
    const instWhere = institutionId ? { institutionId } : {}
    const [
      totalUsers,
      activeUsers,
      inactiveUsers,
      suspendedUsers,
      usersByRoleData,
      recentUsers,
    ] = await Promise.all([
      this.prisma.user.count({ where: instWhere }),
      this.prisma.user.count({
        where: { ...instWhere, status: 'ACTIVE' },
      }),
      this.prisma.user.count({
        where: { ...instWhere, status: 'INACTIVE' },
      }),
      this.prisma.user.count({
        where: { ...instWhere, status: 'SUSPENDED' },
      }),
      this.prisma.user.groupBy({
        by: ['roleId'],
        _count: { id: true },
        where: instWhere,
      }),
      this.prisma.user.findMany({
        where: instWhere,
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

  async getUsersByRole(
    roleId: number,
    query: UserQueryDto,
    institutionId: number | null
  ) {
    const { page = 1, limit = 10, search, status } = query
    const skip = (page - 1) * limit
    const where: Prisma.UserWhereInput = { roleId }
    if (institutionId) {
      where.institutionId = institutionId
    }

    if (search) {
      where.OR = [
        { firstName: { contains: search, mode: 'insensitive' } },
        { lastName: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
        { kramid: { contains: search, mode: 'insensitive' } },
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

  async getUserByUuid(uuid: string, adminInstitutionId: number | null) {
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

    if (
      adminInstitutionId !== null &&
      user.institutionId !== null &&
      user.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException('Access denied to this user')
    }

    return {
      success: true,
      data: user,
    }
  }

  async getUserByKramId(kramid: string, adminInstitutionId: number | null) {
    const user = await this.prisma.user.findUnique({
      where: { kramid },
      include: {
        role: true,
        student: true,
        teacher: true,
        parent: true,
      },
    })

    if (!user) {
      throw new NotFoundException(`User not found with Kram ID: ${kramid}`)
    }

    if (
      adminInstitutionId !== null &&
      user.institutionId !== null &&
      user.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException('Access denied to this user')
    }

    return {
      success: true,
      data: user,
    }
  }

  async updateUserByUuid(
    uuid: string,
    updateUserDto: UpdateUserDto,
    adminInstitutionId: number | null
  ) {
    const existingUser = await this.prisma.user.findUnique({
      where: { uuid },
    })

    if (!existingUser) {
      throw new NotFoundException('User not found')
    }

    if (
      adminInstitutionId !== null &&
      existingUser.institutionId !== null &&
      existingUser.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException('Access denied to this user')
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

  async deleteUserByUuid(uuid: string, adminInstitutionId: number | null) {
    const user = await this.prisma.user.findUnique({
      where: { uuid },
    })

    if (!user) {
      throw new NotFoundException('User not found')
    }

    if (
      adminInstitutionId !== null &&
      user.institutionId !== null &&
      user.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException('Access denied to this user')
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

  async bulkImportUsers(
    users: CreateUserDto[],
    adminInstitutionId: number | null
  ) {
    const results = {
      successful: 0,
      failed: 0,
      errors: [] as string[],
    }

    for (const userData of users) {
      try {
        await this.createInstitutionalUser(userData, adminInstitutionId)
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
  async unlockAccount(userUuid: string, adminInstitutionId: number | null) {
    const user = await this.prisma.user.findFirst({
      where: { uuid: userUuid },
    })

    if (!user) {
      throw new NotFoundException(`User with UUID ${userUuid} not found`)
    }

    if (
      adminInstitutionId !== null &&
      user.institutionId !== null &&
      user.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException('Access denied to this user')
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

  /**
   * Get institution profile (school info) for settings
   */
  async getInstitutionProfile(
    institutionId: number,
    adminInstitutionId: number | null
  ) {
    const institution = await this.prisma.institution.findUnique({
      where: { id: institutionId },
      select: {
        id: true,
        code: true,
        name: true,
        type: true,
        address: true,
        city: true,
        state: true,
        country: true,
        postalCode: true,
        phone: true,
        email: true,
        website: true,
        establishedYear: true,
        accreditation: true,
        status: true,
      },
    })
    if (!institution) {
      throw new NotFoundException(
        `Institution with ID ${institutionId} not found`
      )
    }
    if (adminInstitutionId !== null && institutionId !== adminInstitutionId) {
      throw new ForbiddenException('Access denied to this institution')
    }
    return { data: institution }
  }

  /**
   * Update institution profile (school info)
   */
  async updateInstitutionProfile(
    institutionId: number,
    dto: UpdateInstitutionDto,
    adminInstitutionId: number | null
  ) {
    await this.prisma.institution.findUniqueOrThrow({
      where: { id: institutionId },
    })
    if (adminInstitutionId !== null && institutionId !== adminInstitutionId) {
      throw new ForbiddenException('Access denied to this institution')
    }
    const updated = await this.prisma.institution.update({
      where: { id: institutionId },
      data: {
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.type !== undefined && { type: dto.type }),
        ...(dto.address !== undefined && { address: dto.address }),
        ...(dto.city !== undefined && { city: dto.city }),
        ...(dto.state !== undefined && { state: dto.state }),
        ...(dto.country !== undefined && { country: dto.country }),
        ...(dto.postalCode !== undefined && { postalCode: dto.postalCode }),
        ...(dto.phone !== undefined && { phone: dto.phone }),
        ...(dto.email !== undefined && { email: dto.email }),
        ...(dto.website !== undefined && { website: dto.website }),
        ...(dto.establishedYear !== undefined && {
          establishedYear: dto.establishedYear,
        }),
        ...(dto.accreditation !== undefined && {
          accreditation: dto.accreditation,
        }),
      },
    })
    return { data: updated }
  }

  /**
   * Get grading configuration for an institution
   */
  async getGradingConfig(
    institutionId: number,
    adminInstitutionId: number | null
  ) {
    // Verify institution exists
    const institution = await this.prisma.institution.findUnique({
      where: { id: institutionId },
    })

    if (!institution) {
      throw new NotFoundException(
        `Institution with ID ${institutionId} not found`
      )
    }
    if (adminInstitutionId !== null && institutionId !== adminInstitutionId) {
      throw new ForbiddenException('Access denied to this institution')
    }

    // Get grading config
    const config = await this.prisma.institutionGradingConfig.findUnique({
      where: { institutionId },
    })

    if (!config) {
      return {
        success: true,
        message:
          'No custom grading configuration found. Using default settings.',
        data: null,
      }
    }

    return {
      success: true,
      message: 'Grading configuration retrieved successfully',
      data: config,
    }
  }

  /**
   * Update or create grading configuration for an institution
   */
  async updateGradingConfig(
    institutionId: number,
    updateDto: UpdateGradingConfigDto,
    adminInstitutionId: number | null
  ) {
    // Verify institution exists and get type for restriction logic
    const institution = await this.prisma.institution.findUnique({
      where: { id: institutionId },
      select: { id: true, type: true, name: true }
    })

    if (!institution) {
      throw new NotFoundException(
        `Institution with ID ${institutionId} not found`
      )
    }
    if (adminInstitutionId !== null && institutionId !== adminInstitutionId) {
      throw new ForbiddenException('Access denied to this institution')
    }

    // Check for active term/semester restriction
    const restrictionInfo = await this.checkGradingRestriction(institutionId, institution.type)
    
    if (restrictionInfo.isRestricted) {
      throw new ForbiddenException({
        message: restrictionInfo.message,
        error: 'ACTIVE_PERIOD_RESTRICTION',
        details: restrictionInfo.details
      })
    }

    // Validate that weights sum to 100 if all are provided
    const {
      attendanceWeight,
      assignmentWeight,
      examWeight,
      participationWeight,
    } = updateDto

    if (
      attendanceWeight !== undefined ||
      assignmentWeight !== undefined ||
      examWeight !== undefined ||
      participationWeight !== undefined
    ) {
      // Get current config or defaults
      const currentConfig =
        await this.prisma.institutionGradingConfig.findUnique({
          where: { institutionId },
        })

      const finalAttendance =
        attendanceWeight ?? currentConfig?.attendanceWeight ?? 10
      const finalAssignment =
        assignmentWeight ?? currentConfig?.assignmentWeight ?? 30
      const finalExam = examWeight ?? currentConfig?.examWeight ?? 50
      const finalParticipation =
        participationWeight ?? currentConfig?.participationWeight ?? 10

      const totalWeight =
        Number(finalAttendance) +
        Number(finalAssignment) +
        Number(finalExam) +
        Number(finalParticipation)

      if (Math.abs(totalWeight - 100) > 0.01) {
        throw new BadRequestException(
          `Grading weights must sum to 100. Current sum: ${totalWeight}`
        )
      }
    }

    // Upsert grading config
    const config = await this.prisma.institutionGradingConfig.upsert({
      where: { institutionId },
      update: updateDto,
      create: {
        institutionId,
        ...updateDto,
      },
    })

    return {
      success: true,
      message: 'Grading configuration updated successfully',
      data: config,
    }
  }

  /**
   * Reset grading configuration to defaults
   */
  async resetGradingConfig(
    institutionId: number,
    adminInstitutionId: number | null
  ) {
    // Verify institution exists and get type for restriction logic
    const institution = await this.prisma.institution.findUnique({
      where: { id: institutionId },
      select: { id: true, type: true, name: true }
    })

    if (!institution) {
      throw new NotFoundException(
        `Institution with ID ${institutionId} not found`
      )
    }
    if (adminInstitutionId !== null && institutionId !== adminInstitutionId) {
      throw new ForbiddenException('Access denied to this institution')
    }

    // Check for active term/semester restriction
    const restrictionInfo = await this.checkGradingRestriction(institutionId, institution.type)
    
    if (restrictionInfo.isRestricted) {
      throw new ForbiddenException({
        message: restrictionInfo.message,
        error: 'ACTIVE_PERIOD_RESTRICTION',
        details: restrictionInfo.details
      })
    }

    // Delete existing config (will use defaults)
    await this.prisma.institutionGradingConfig.deleteMany({
      where: { institutionId },
    })

    return {
      success: true,
      message: 'Grading configuration reset to default values successfully',
    }
  }

  /**
   * Get comprehensive dashboard statistics
   */
  async getDashboardStats(institutionId: number | null) {
    const [
      stats,
      teacherPerformance,
      attendanceTrends,
      gradeDistribution,
      classPerformance,
      financialOverview,
      systemAlerts,
    ] = await Promise.all([
      this.getBasicStats(institutionId),
      this.getTeacherPerformanceData(10, institutionId),
      this.getAttendanceTrendsData(institutionId),
      this.getGradeDistributionData(institutionId),
      this.getClassPerformanceData(institutionId),
      this.getFinancialOverviewData(institutionId),
      this.getSystemAlertsData(undefined, 20, institutionId),
    ])

    return {
      stats,
      teacher_performance: teacherPerformance,
      attendance_trends: attendanceTrends,
      grade_distribution: gradeDistribution,
      class_performance: classPerformance,
      financial_overview: financialOverview,
      system_alerts: systemAlerts,
    }
  }

  /**
   * Get basic statistics for dashboard
   */
  private async getBasicStats(institutionId: number | null) {
    const instFilter = institutionId ? { institutionId } : {}
    const [
      totalStudents,
      activeStudents,
      inactiveStudents,
      totalTeachers,
      totalStaff,
      totalClasses,
      attendanceRecords,
      feeStats,
    ] = await Promise.all([
      this.prisma.student.count({ where: instFilter }),
      this.prisma.student.count({
        where: {
          ...instFilter,
          user: { status: 'ACTIVE' },
        },
      }),
      this.prisma.student.count({
        where: {
          ...instFilter,
          user: { status: { not: 'ACTIVE' } },
        },
      }),
      this.prisma.teacher.count({ where: instFilter }),
      this.prisma.staff.count({ where: instFilter }),
      // Count both complex class sections and simple class divisions
      Promise.all([
        this.prisma.classSection.count({
          where: institutionId ? { teacher: { institutionId } } : {},
        }),
        this.prisma.classDivision.count({
          where: institutionId ? { course: { institutionId } } : {},
        }),
      ]).then(
        ([complexSections, simpleDivisions]) =>
          complexSections + simpleDivisions
      ),
      this.prisma.attendance.groupBy({
        by: ['status'],
        _count: { id: true },
        ...(institutionId ? { where: { student: { institutionId } } } : {}),
      }),
      this.prisma.payment.aggregate({
        _sum: { amount: true },
        where: {
          status: 'COMPLETED',
          ...(institutionId ? { student: { institutionId } } : {}),
        },
      }),
    ])

    // Calculate attendance rate
    const totalAttendance = attendanceRecords.reduce(
      (sum, record) => sum + record._count.id,
      0
    )
    const presentCount =
      attendanceRecords.find(r => r.status === 'PRESENT')?._count.id || 0
    const attendanceRate =
      totalAttendance > 0 ? (presentCount / totalAttendance) * 100 : 0

    // Get pending fees
    const pendingFeesData = await this.prisma.studentFee.aggregate({
      _sum: { amountDue: true, amountPaid: true },
      where: {
        status: { in: ['PENDING', 'OVERDUE'] },
        ...(institutionId ? { student: { institutionId } } : {}),
      },
    })

    const pendingFees =
      Number(pendingFeesData._sum.amountDue || 0) -
      Number(pendingFeesData._sum.amountPaid || 0)

    return {
      total_students: totalStudents,
      active_students: activeStudents,
      inactive_students: inactiveStudents,
      total_teachers: totalTeachers,
      total_staff: totalStaff,
      total_classes: totalClasses,
      attendance_rate: Math.round(attendanceRate * 100) / 100,
      fee_collection: feeStats._sum.amount || 0,
      pending_fees: Math.max(0, pendingFees),
    }
  }

  /**
   * Get teacher performance data
   */
  async getTeacherPerformance(
    limit: number = 10,
    institutionId: number | null = null
  ) {
    return this.getTeacherPerformanceData(limit, institutionId)
  }

  private async getTeacherPerformanceData(
    limit: number = 10,
    institutionId: number | null = null
  ) {
    // Optimized: Use raw SQL with JOINs and GROUP BY to eliminate N+1 queries
    const performanceData = await this.prisma.$queryRaw<
      Array<{
        teacher_id: number
        teacher_name: string
        subject_name: string
        student_count: bigint
        avg_grade: number
      }>
    >`
      SELECT 
        t.id as teacher_id,
        u.name as teacher_name,
        COALESCE(s.subject_name, 'Multiple Subjects') as subject_name,
        COUNT(DISTINCT cs.id) as student_count,
        COALESCE(
          ROUND(
            AVG(
              CASE 
                WHEN er.marks_obtained IS NOT NULL AND e.total_marks > 0 
                THEN (er.marks_obtained::DECIMAL / e.total_marks) * 100
                ELSE NULL
              END
            ), 
            2
          ), 
          0
        ) as avg_grade
      FROM teachers t
      JOIN users u ON t.user_id = u.id
      LEFT JOIN teacher_subjects ts ON t.id = ts.teacher_id
      LEFT JOIN subjects s ON ts.subject_id = s.id
      LEFT JOIN class_sections cs ON t.id = cs.teacher_id
      LEFT JOIN exam_results er ON t.id = er.evaluated_by
      LEFT JOIN examinations e ON er.exam_id = e.id
      WHERE (${institutionId}::int IS NULL OR t.institution_id = ${institutionId})
      GROUP BY t.id, u.name, s.subject_name
      ORDER BY t.id DESC
      LIMIT ${limit}
    `

    return performanceData.map(data => ({
      teacher_name: data.teacher_name,
      subject: data.subject_name,
      students: Number(data.student_count),
      avg_grade: data.avg_grade,
      rating: 4.5, // Placeholder - implement rating system later
    }))
  }

  /**
   * Get attendance trends
   */
  async getAttendanceTrends(
    _period?: string,
    institutionId: number | null = null
  ) {
    return this.getAttendanceTrendsData(institutionId)
  }

  private async getAttendanceTrendsData(institutionId: number | null = null) {
    // Get attendance data for the last 6 months
    const sixMonthsAgo = new Date()
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6)

    const attendanceData = await this.prisma.attendance.findMany({
      where: {
        date: { gte: sixMonthsAgo },
        ...(institutionId ? { student: { institutionId } } : {}),
      },
      select: {
        date: true,
        status: true,
      },
    })

    // Group by month
    const monthlyData = new Map<string, { present: number; total: number }>()

    attendanceData.forEach(record => {
      const monthKey = record.date.toISOString().substring(0, 7) // YYYY-MM
      if (!monthlyData.has(monthKey)) {
        monthlyData.set(monthKey, { present: 0, total: 0 })
      }
      const data = monthlyData.get(monthKey)!
      data.total++
      if (record.status === 'PRESENT') {
        data.present++
      }
    })

    // Convert to array and format
    const trends = Array.from(monthlyData.entries())
      .sort((a, b) => a[0].localeCompare(b[0]))
      .map(([month, data]) => ({
        month: new Date(month + '-01').toLocaleDateString('en-US', {
          month: 'short',
          year: 'numeric',
        }),
        actual_attendance:
          data.total > 0
            ? Math.round((data.present / data.total) * 100 * 100) / 100
            : 0,
        target_attendance: 95,
      }))

    return trends
  }

  /**
   * Get grade distribution
   */
  async getGradeDistribution(institutionId: number | null = null) {
    return this.getGradeDistributionData(institutionId)
  }

  private async getGradeDistributionData(institutionId: number | null = null) {
    const grades = await this.prisma.academicRecord.findMany({
      where: institutionId ? { student: { institutionId } } : {},
      select: { grade: true },
    })

    // Count occurrences of each grade
    const distribution = new Map<string, number>()
    grades.forEach(record => {
      if (record.grade) {
        distribution.set(
          record.grade,
          (distribution.get(record.grade) || 0) + 1
        )
      }
    })

    // Convert to array and sort by grade
    const gradeOrder = ['A+', 'A', 'B+', 'B', 'C+', 'C', 'D', 'F']
    return gradeOrder
      .filter(grade => distribution.has(grade))
      .map(grade => ({
        grade,
        count: distribution.get(grade) || 0,
      }))
  }

  /**
   * Get class performance
   */
  async getClassPerformance(institutionId: number | null = null) {
    return this.getClassPerformanceData(institutionId)
  }

  private async getClassPerformanceData(institutionId: number | null = null) {
    // Optimized: Use raw SQL with JOINs and GROUP BY to eliminate N+1 queries
    const performanceData = await this.prisma.$queryRaw<
      Array<{
        class_name: string
        student_count: bigint
        avg_grade: number
        attendance_rate: number
      }>
    >`
      SELECT 
        CONCAT(s.subject_name, ' (', cs.section_name, ')') as class_name,
        COUNT(DISTINCT e.student_id) as student_count,
        COALESCE(
          ROUND(
            AVG(
              CASE 
                WHEN ar.marks_obtained IS NOT NULL AND ar.max_marks > 0 
                THEN (ar.marks_obtained::DECIMAL / ar.max_marks) * 100
                ELSE NULL
              END
            ), 
            2
          ), 
          0
        ) as avg_grade,
        COALESCE(
          ROUND(
            (COUNT(*) FILTER (WHERE a.status = 'PRESENT')::DECIMAL / NULLIF(COUNT(a.id), 0)) * 100,
            2
          ),
          0
        ) as attendance_rate
      FROM class_sections cs
      JOIN subjects s ON cs.subject_id = s.id
      JOIN teachers t ON cs.teacher_id = t.id
      LEFT JOIN enrollments e ON cs.subject_id = e.subject_id AND cs.semester_id = e.semester_id
      LEFT JOIN academic_records ar ON cs.subject_id = ar.subject_id AND cs.semester_id = ar.semester_id
      LEFT JOIN attendance a ON cs.id = a.section_id
      WHERE cs.status = 'ACTIVE'
        AND (${institutionId}::int IS NULL OR t.institution_id = ${institutionId})
      GROUP BY cs.id, s.subject_name, cs.section_name
      ORDER BY cs.id DESC
      LIMIT 20
    `

    return performanceData.map(data => ({
      class_name: data.class_name,
      student_count: Number(data.student_count),
      avg_grade: data.avg_grade,
      attendance_rate: data.attendance_rate,
    }))
  }

  /**
   * Get financial overview
   */
  async getFinancialOverview(
    _period?: string,
    institutionId: number | null = null
  ) {
    return this.getFinancialOverviewData(institutionId)
  }

  private async getFinancialOverviewData(institutionId: number | null = null) {
    // Get fee collection data for the last 6 months
    const sixMonthsAgo = new Date()
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6)

    const payments = await this.prisma.payment.findMany({
      where: {
        paymentDate: { gte: sixMonthsAgo },
        status: 'COMPLETED',
        ...(institutionId ? { student: { institutionId } } : {}),
      },
      select: {
        paymentDate: true,
        amount: true,
      },
    })

    // Group by month
    const monthlyData = new Map<string, number>()

    payments.forEach(payment => {
      const monthKey = payment.paymentDate.toISOString().substring(0, 7)
      monthlyData.set(
        monthKey,
        (monthlyData.get(monthKey) || 0) + Number(payment.amount)
      )
    })

    // Convert to array and format
    const overview = Array.from(monthlyData.entries())
      .sort((a, b) => a[0].localeCompare(b[0]))
      .map(([month, feeCollection]) => ({
        month: new Date(month + '-01').toLocaleDateString('en-US', {
          month: 'short',
          year: 'numeric',
        }),
        expenses: 0, // Placeholder - implement expense tracking
        fee_collection: feeCollection,
        profit: feeCollection, // Simplified - should subtract expenses
      }))

    return overview
  }

  /**
   * Get system alerts
   */
  async getSystemAlerts(
    severity?: string,
    limit: number = 20,
    institutionId: number | null = null
  ) {
    return this.getSystemAlertsData(severity, limit, institutionId)
  }

  private async getSystemAlertsData(
    severity?: string,
    limit: number = 20,
    institutionId: number | null = null
  ) {
    const alerts: Array<{
      category: string
      message: string
      severity: string
      timestamp: Date
    }> = []

    // Optimized: Use raw SQL to get low attendance sections in one query
    const lowAttendanceSections = await this.prisma.$queryRaw<
      Array<{
        subject_name: string
        section_name: string
        attendance_rate: number
      }>
    >`
      SELECT 
        s.subject_name,
        cs.section_name,
        ROUND(
          (COUNT(*) FILTER (WHERE a.status = 'PRESENT')::DECIMAL / NULLIF(COUNT(a.id), 0)) * 100,
          1
        ) as attendance_rate
      FROM class_sections cs
      JOIN subjects s ON cs.subject_id = s.id
      JOIN teachers t ON cs.teacher_id = t.id
      LEFT JOIN attendance a ON cs.id = a.section_id
      WHERE cs.status = 'ACTIVE'
        AND a.date >= CURRENT_DATE - INTERVAL '7 days'
        AND (${institutionId}::int IS NULL OR t.institution_id = ${institutionId})
      GROUP BY cs.id, s.subject_name, cs.section_name
      HAVING 
        COUNT(a.id) > 0 
        AND ROUND((COUNT(*) FILTER (WHERE a.status = 'PRESENT')::DECIMAL / NULLIF(COUNT(a.id), 0)) * 100, 1) < 78
      LIMIT 50
    `

    // Add low attendance alerts
    lowAttendanceSections.forEach(section => {
      alerts.push({
        category: 'Attendance',
        message: `${section.subject_name} (${section.section_name}) has ${section.attendance_rate}% attendance this week`,
        severity: 'high',
        timestamp: new Date(),
      })
    })

    // Check for pending fees
    const overdueFees = await this.prisma.studentFee.count({
      where: {
        status: 'OVERDUE',
        ...(institutionId ? { student: { institutionId } } : {}),
      },
    })

    if (overdueFees > 0) {
      alerts.push({
        category: 'Finance',
        message: `${overdueFees} fee payments are overdue`,
        severity: 'medium',
        timestamp: new Date(),
      })
    }

    // Filter by severity if provided
    const filteredAlerts = severity
      ? alerts.filter(alert => alert.severity === severity)
      : alerts

    return filteredAlerts.slice(0, limit)
  }

  /**
   * Create parent records for a student based on provided parent information
   */
  private async createParentRecords(
    studentId: number,
    studentData: {
      fatherInfo?: { name?: string; email?: string; mobile?: string }
      motherInfo?: { name?: string; email?: string; mobile?: string }
      guardianInfo?: { name?: string; email?: string; mobile?: string }
      guardianSameAsParent?: boolean
      guardianParentType?: 'father' | 'mother'
    },
    adminInstitutionId: number | null
  ) {
    const parentRole = await this.prisma.role.findFirst({
      where: { roleName: { equals: 'parent', mode: 'insensitive' } },
    })

    if (!parentRole) {
      console.warn('Parent role not found, skipping parent creation')
      return
    }

    const createdParents: Array<{
      type: string
      user: { id: number }
      parent: { id: number }
    }> = []

    // Create Father record if provided
    if (studentData.fatherInfo?.name?.trim()) {
      const fatherUser = await this.createParentUser(
        {
          name: studentData.fatherInfo.name,
          email: studentData.fatherInfo.email,
          mobile: studentData.fatherInfo.mobile,
        },
        parentRole.id,
        adminInstitutionId
      )
      if (fatherUser) {
        const fatherParent = await this.prisma.parent.create({
          data: {
            userId: fatherUser.id,
            studentId,
            relation: 'FATHER',
            isPrimaryContact: false, // Will be updated later based on guardian logic
          },
        })
        createdParents.push({ type: 'father', user: fatherUser, parent: fatherParent })
      }
    }

    // Create Mother record if provided
    if (studentData.motherInfo?.name?.trim()) {
      const motherUser = await this.createParentUser(
        {
          name: studentData.motherInfo.name,
          email: studentData.motherInfo.email,
          mobile: studentData.motherInfo.mobile,
        },
        parentRole.id,
        adminInstitutionId
      )
      if (motherUser) {
        const motherParent = await this.prisma.parent.create({
          data: {
            userId: motherUser.id,
            studentId,
            relation: 'MOTHER',
            isPrimaryContact: false, // Will be updated later based on guardian logic
          },
        })
        createdParents.push({ type: 'mother', user: motherUser, parent: motherParent })
      }
    }

    // Handle Guardian logic
    if (studentData.guardianSameAsParent && studentData.guardianParentType) {
      // Guardian is same as father or mother - mark that parent as primary contact
      const guardianParent = createdParents.find(p => p.type === studentData.guardianParentType)
      if (guardianParent) {
        await this.prisma.parent.update({
          where: { id: guardianParent.parent.id },
          data: { isPrimaryContact: true },
        })
      }
    } else if (studentData.guardianInfo?.name?.trim()) {
      // Create separate Guardian record
      const guardianUser = await this.createParentUser(
        {
          name: studentData.guardianInfo.name,
          email: studentData.guardianInfo.email,
          mobile: studentData.guardianInfo.mobile,
        },
        parentRole.id,
        adminInstitutionId
      )
      if (guardianUser) {
        await this.prisma.parent.create({
          data: {
            userId: guardianUser.id,
            studentId,
            relation: 'GUARDIAN',
            isPrimaryContact: true,
          },
        })
      }
    } else if (createdParents.length > 0) {
      // No explicit guardian, make first parent the primary contact
      await this.prisma.parent.update({
        where: { id: createdParents[0].parent.id },
        data: { isPrimaryContact: true },
      })
    }
  }

  /**
   * Create a parent user account
   */
  private async createParentUser(
    parentInfo: { name: string; email?: string; mobile?: string },
    parentRoleId: number,
    adminInstitutionId: number | null
  ) {
    const name = parentInfo.name.trim()
    const email = parentInfo.email?.trim()
    const mobile = parentInfo.mobile?.trim()

    // Skip if no email provided (we need email for user account)
    if (!email) {
      console.warn(`Skipping parent creation for ${name} - no email provided`)
      return null
    }

    // Check if user already exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    })

    if (existingUser) {
      console.log(`Parent user already exists for email: ${email}`)
      return existingUser
    }

    // Parse name into first and last name
    const [first = name, ...rest] = name.split(/\s+/)
    const lastName = rest.length > 0 ? rest.join(' ') : first

    // Generate temporary password
    const tempPassword = generateTemporaryPassword(first, lastName)
    const hashedPassword = await bcrypt.hash(tempPassword, 12)

    // Create parent user
    const parentUser = await this.prisma.user.create({
      data: {
        firstName: first,
        lastName,
        name,
        email,
        phone: mobile,
        passwordHash: hashedPassword,
        roleId: parentRoleId,
        institutionId: adminInstitutionId,
        status: 'INACTIVE',
        isTemporaryPassword: true,
        mustChangePassword: true,
      },
    })

    console.log(`Created parent user: ${name} (${email}) with temp password: ${tempPassword}`)
    
    // Generate Kram ID for parent user
    const kramid = await this.generateKramIdForUser(parentUser.id, adminInstitutionId, 'parent')
    
    return { ...parentUser, kramid }
  }

  /**
   * Generate Kram ID for a user
   */
  private async generateKramIdForUser(
    userId: number,
    institutionId: number | null,
    roleName: string
  ): Promise<string | null> {
    if (!institutionId) {
      console.warn(`Cannot generate Kram ID - no institution ID provided`)
      return null
    }

    const institution = await this.prisma.institution.findUnique({
      where: { id: institutionId },
      select: { code: true }
    })

    if (!institution?.code) {
      console.warn(`Cannot generate Kram ID - institution code not found for ID: ${institutionId}`)
      return null
    }

    try {
      const result = await this.prisma.$queryRawUnsafe<{ kramid: string }[]>(
        `SELECT generate_kramid($1, $2) as kramid`,
        institution.code,
        roleName
      )

      const kramid = result[0]?.kramid ?? null
      if (kramid) {
        await this.prisma.user.update({
          where: { id: userId },
          data: { kramid },
        })
        console.log(`Generated Kram ID ${kramid} for user ${userId}`)
      }

      return kramid
    } catch (error) {
      console.error(`Failed to generate Kram ID for user ${userId}:`, error)
      return null
    }
  }

  /**
   * Check if grading configuration changes are restricted due to active term/semester
   */
  private async checkGradingRestriction(institutionId: number, institutionType: string) {
    // Check for active semester/term (unified logic for both schools and colleges)
    const activePeriod = await this.prisma.semester.findFirst({
      where: { 
        academicYear: { institutionId },
        status: 'ACTIVE' 
      },
      select: {
        id: true,
        semesterName: true,
        startDate: true,
        endDate: true,
        academicYear: {
          select: { yearName: true }
        }
      }
    })

    if (activePeriod) {
      // Adaptive terminology based on institution type
      const periodType = institutionType === 'SCHOOL' ? 'term' : 'semester'
      
      return {
        isRestricted: true,
        message: `Cannot modify grading configuration during active ${periodType}`,
        details: {
          institutionType,
          periodType,
          activePeriod: activePeriod.semesterName,
          academicYear: activePeriod.academicYear.yearName,
          startDate: activePeriod.startDate,
          endDate: activePeriod.endDate,
          suggestion: `Grading configuration can be modified after the ${periodType} ends`,
          explanation: `This ensures consistent grading standards throughout the ${periodType}`
        }
      }
    }

    return { isRestricted: false }
  }

  /**
   * Get institution information including type
   */
  async getInstitutionInfo(institutionId: number, adminInstitutionId: number | null) {
    if (adminInstitutionId !== null && institutionId !== adminInstitutionId) {
      throw new ForbiddenException('Access denied to this institution')
    }

    const institution = await this.prisma.institution.findUnique({
      where: { id: institutionId },
      select: {
        id: true,
        name: true,
        type: true,
        code: true
      }
    })

    if (!institution) {
      throw new NotFoundException('Institution not found')
    }

    return { 
      success: true, 
      data: institution 
    }
  }

  /**
   * Check grading restriction status for an institution
   */
  async checkGradingRestrictionStatus(institutionId: number, adminInstitutionId: number | null) {
    if (adminInstitutionId !== null && institutionId !== adminInstitutionId) {
      throw new ForbiddenException('Access denied to this institution')
    }

    const institution = await this.prisma.institution.findUnique({
      where: { id: institutionId },
      select: { type: true }
    })

    if (!institution) {
      throw new NotFoundException('Institution not found')
    }

    const restrictionInfo = await this.checkGradingRestriction(institutionId, institution.type)
    
    return {
      success: true,
      data: restrictionInfo
    }
  }
}
