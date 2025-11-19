import {
  BadRequestException,
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
import { UpdateGradingConfigDto } from './dto/grading-config.dto'

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

  /**
   * Get grading configuration for an institution
   */
  async getGradingConfig(institutionId: number) {
    // Verify institution exists
    const institution = await this.prisma.institution.findUnique({
      where: { id: institutionId },
    })

    if (!institution) {
      throw new NotFoundException(
        `Institution with ID ${institutionId} not found`
      )
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
    updateDto: UpdateGradingConfigDto
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
  async resetGradingConfig(institutionId: number) {
    // Verify institution exists
    const institution = await this.prisma.institution.findUnique({
      where: { id: institutionId },
    })

    if (!institution) {
      throw new NotFoundException(
        `Institution with ID ${institutionId} not found`
      )
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
  async getDashboardStats() {
    const [
      stats,
      teacherPerformance,
      attendanceTrends,
      gradeDistribution,
      classPerformance,
      financialOverview,
      systemAlerts,
    ] = await Promise.all([
      this.getBasicStats(),
      this.getTeacherPerformanceData(10),
      this.getAttendanceTrendsData(),
      this.getGradeDistributionData(),
      this.getClassPerformanceData(),
      this.getFinancialOverviewData(),
      this.getSystemAlertsData(undefined, 20),
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
  private async getBasicStats() {
    const [
      totalStudents,
      totalTeachers,
      totalClasses,
      attendanceRecords,
      feeStats,
    ] = await Promise.all([
      this.prisma.student.count(),
      this.prisma.teacher.count(),
      this.prisma.classSection.count(),
      this.prisma.attendance.groupBy({
        by: ['status'],
        _count: { id: true },
      }),
      this.prisma.payment.aggregate({
        _sum: { amount: true },
        where: {
          status: 'COMPLETED',
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
      },
    })

    const pendingFees =
      Number(pendingFeesData._sum.amountDue || 0) -
      Number(pendingFeesData._sum.amountPaid || 0)

    return {
      total_students: totalStudents,
      total_teachers: totalTeachers,
      total_classes: totalClasses,
      attendance_rate: Math.round(attendanceRate * 100) / 100,
      fee_collection: feeStats._sum.amount || 0,
      pending_fees: Math.max(0, pendingFees),
    }
  }

  /**
   * Get teacher performance data
   */
  async getTeacherPerformance(limit: number = 10) {
    return this.getTeacherPerformanceData(limit)
  }

  private async getTeacherPerformanceData(limit: number = 10) {
    const teachers = await this.prisma.teacher.findMany({
      take: limit,
      include: {
        user: true,
        teacherSubjects: {
          include: {
            subject: true,
          },
        },
      },
    })

    const performanceData = await Promise.all(
      teachers.map(async teacher => {
        // Get number of students taught through class sections
        const studentCount = await this.prisma.classSection.count({
          where: {
            teacherId: teacher.id,
          },
        })

        // Get average exam results for students taught by this teacher
        const examResults = await this.prisma.examResult.findMany({
          where: {
            evaluatedBy: teacher.id,
          },
          select: {
            marksObtained: true,
            exam: {
              select: {
                totalMarks: true,
              },
            },
          },
        })

        const avgGrade =
          examResults.length > 0
            ? examResults.reduce((sum, result) => {
                const marks = Number(result.marksObtained || 0)
                const total = result.exam.totalMarks
                return sum + (total > 0 ? (marks / total) * 100 : 0)
              }, 0) / examResults.length
            : 0

        return {
          teacher_name: teacher.user.name,
          subject:
            teacher.teacherSubjects[0]?.subject.subjectName ||
            'Multiple Subjects',
          students: studentCount,
          avg_grade: Math.round(avgGrade * 100) / 100,
          rating: 4.5, // Placeholder - implement rating system later
        }
      })
    )

    return performanceData
  }

  /**
   * Get attendance trends
   */
  async getAttendanceTrends(_period?: string) {
    return this.getAttendanceTrendsData()
  }

  private async getAttendanceTrendsData() {
    // Get attendance data for the last 6 months
    const sixMonthsAgo = new Date()
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6)

    const attendanceData = await this.prisma.attendance.findMany({
      where: {
        date: {
          gte: sixMonthsAgo,
        },
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
  async getGradeDistribution() {
    return this.getGradeDistributionData()
  }

  private async getGradeDistributionData() {
    const grades = await this.prisma.academicRecord.findMany({
      select: {
        grade: true,
      },
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
  async getClassPerformance() {
    return this.getClassPerformanceData()
  }

  private async getClassPerformanceData() {
    const sections = await this.prisma.classSection.findMany({
      take: 20,
      include: {
        subject: true,
        semester: true,
      },
    })

    const performanceData = await Promise.all(
      sections.map(async section => {
        // Get number of enrollments for this section
        const studentCount = await this.prisma.enrollment.count({
          where: {
            subjectId: section.subjectId,
            semesterId: section.semesterId,
          },
        })

        // Get average academic record grades for this section's subject
        const academicRecords = await this.prisma.academicRecord.findMany({
          where: {
            subjectId: section.subjectId,
            semesterId: section.semesterId,
          },
          select: {
            marksObtained: true,
            maxMarks: true,
          },
        })

        const avgGrade =
          academicRecords.length > 0
            ? academicRecords.reduce((sum, record) => {
                const marks = Number(record.marksObtained || 0)
                const max = Number(record.maxMarks || 1)
                return sum + (max > 0 ? (marks / max) * 100 : 0)
              }, 0) / academicRecords.length
            : 0

        // Get attendance rate for this section
        const attendanceData = await this.prisma.attendance.groupBy({
          by: ['status'],
          where: {
            sectionId: section.id,
          },
          _count: { id: true },
        })

        const totalAttendance = attendanceData.reduce(
          (sum, record) => sum + record._count.id,
          0
        )
        const presentCount =
          attendanceData.find(r => r.status === 'PRESENT')?._count.id || 0
        const attendanceRate =
          totalAttendance > 0 ? (presentCount / totalAttendance) * 100 : 0

        return {
          class_name: `${section.subject.subjectName} (${section.sectionName})`,
          student_count: studentCount,
          avg_grade: Math.round(avgGrade * 100) / 100,
          attendance_rate: Math.round(attendanceRate * 100) / 100,
        }
      })
    )

    return performanceData
  }

  /**
   * Get financial overview
   */
  async getFinancialOverview(_period?: string) {
    return this.getFinancialOverviewData()
  }

  private async getFinancialOverviewData() {
    // Get fee collection data for the last 6 months
    const sixMonthsAgo = new Date()
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6)

    const payments = await this.prisma.payment.findMany({
      where: {
        paymentDate: {
          gte: sixMonthsAgo,
        },
        status: 'COMPLETED',
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
  async getSystemAlerts(severity?: string, limit: number = 20) {
    return this.getSystemAlertsData(severity, limit)
  }

  private async getSystemAlertsData(severity?: string, limit: number = 20) {
    const alerts: Array<{
      category: string
      message: string
      severity: string
      timestamp: Date
    }> = []

    // Check for low attendance in sections
    const sections = await this.prisma.classSection.findMany({
      take: 50,
      include: {
        subject: true,
      },
    })

    for (const section of sections) {
      const attendanceData = await this.prisma.attendance.groupBy({
        by: ['status'],
        where: {
          sectionId: section.id,
          date: {
            gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // Last 7 days
          },
        },
        _count: { id: true },
      })

      const totalAttendance = attendanceData.reduce(
        (sum, record) => sum + record._count.id,
        0
      )
      const presentCount =
        attendanceData.find(r => r.status === 'PRESENT')?._count.id || 0
      const attendanceRate =
        totalAttendance > 0 ? (presentCount / totalAttendance) * 100 : 0

      if (attendanceRate < 78 && totalAttendance > 0) {
        alerts.push({
          category: 'Attendance',
          message: `${section.subject.subjectName} (${section.sectionName}) has ${attendanceRate.toFixed(1)}% attendance this week`,
          severity: 'high',
          timestamp: new Date(),
        })
      }
    }

    // Check for pending fees
    const overdueFees = await this.prisma.studentFee.count({
      where: {
        status: 'OVERDUE',
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
}
