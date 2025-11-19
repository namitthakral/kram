import { Prisma } from '.prisma/client'
import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'
import { EventEmitter2 } from '@nestjs/event-emitter'
import * as bcrypt from 'bcrypt'
import { PrismaService } from '../prisma/prisma.service'
import { ProgressUpdaterService } from '../students/services/progress-updater.service'
import {
  AttendanceTrendsData,
  DailyAttendanceDetail,
  DailyAttendancePreview,
  EnhancedTeacherDashboardStats,
  GradeDistributionData,
  SubjectPerformanceData,
  TeacherAttendanceSummary,
  TeacherDashboardStats,
  TeacherStudentActivity,
} from '../types/teacher.types'
import { CreateAssignmentDto, UpdateAssignmentDto } from './dto/assignment.dto'
import {
  CreateExaminationDto,
  UpdateExaminationDto,
} from './dto/examination.dto'
import {
  AssignSubjectsDto,
  CreateTeacherDto,
  TeacherQueryDto,
  UpdateTeacherDto,
} from './dto/teacher.dto'

@Injectable()
export class TeachersService {
  constructor(
    private prisma: PrismaService,
    private eventEmitter: EventEmitter2,
    private progressUpdater: ProgressUpdaterService
  ) {}

  /**
   * Helper method to get UTC date at midnight to avoid timezone issues
   * when comparing with database DATE columns
   */
  private getUTCDate(date: Date = new Date()): Date {
    return new Date(
      Date.UTC(date.getFullYear(), date.getMonth(), date.getDate())
    )
  }

  async create(createTeacherDto: CreateTeacherDto) {
    const { firstName, lastName, email, phone, password, ...teacherData } =
      createTeacherDto

    // Check if employee ID already exists
    const existingTeacher = await this.prisma.teacher.findUnique({
      where: { employeeId: createTeacherDto.employeeId },
    })

    if (existingTeacher) {
      throw new ConflictException(
        'Teacher with this employee ID already exists'
      )
    }

    // Check if email already exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    })

    if (existingUser) {
      throw new ConflictException('User with this email already exists')
    }

    // Get teacher role ID
    const teacherRole = await this.prisma.role.findUnique({
      where: { roleName: 'teacher' },
    })

    if (!teacherRole) {
      throw new NotFoundException('Teacher role not found')
    }

    // Generate password if not provided
    const finalPassword = password || this.generateRandomPassword()
    const hashedPassword = await bcrypt.hash(finalPassword, 10)

    // Create user and teacher in a transaction
    const result = await this.prisma.$transaction(async tx => {
      // Create user first
      const user = await tx.user.create({
        data: {
          firstName,
          lastName,
          name: `${firstName} ${lastName}`,
          email,
          phone,
          passwordHash: hashedPassword,
          roleId: teacherRole.id,
          emailVerified: false,
          phoneVerified: false,
          status: 'ACTIVE',
        },
      })

      // Create teacher profile
      const teacher = await tx.teacher.create({
        data: {
          ...teacherData,
          userId: user.id,
          joinDate: teacherData.joinDate
            ? new Date(teacherData.joinDate)
            : null,
        },
        include: {
          user: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              name: true,
              email: true,
              phone: true,
              status: true,
            },
          },
          institution: {
            select: {
              id: true,
              name: true,
              type: true,
            },
          },
        },
      })

      return { teacher, generatedPassword: password ? null : finalPassword }
    })

    // Return teacher data with generated password if applicable
    return {
      ...result.teacher,
      ...(result.generatedPassword && {
        generatedPassword: result.generatedPassword,
      }),
    }
  }

  private generateRandomPassword(): string {
    const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*'
    let password = ''
    for (let i = 0; i < 12; i++) {
      password += chars.charAt(Math.floor(Math.random() * chars.length))
    }
    return password
  }

  async findAll(query: TeacherQueryDto) {
    const {
      page,
      limit,
      search,
      institutionId,
      employmentType,
      status,
      sortBy,
      sortOrder,
    } = query
    const skip = (page - 1) * limit

    // Build where clause with proper Prisma typing
    const where: Prisma.TeacherWhereInput = {
      status: { not: 'RESIGNED' }, // Exclude resigned teachers by default
      ...(search && {
        OR: [
          { employeeId: { contains: search, mode: 'insensitive' } },
          { designation: { contains: search, mode: 'insensitive' } },
          { specialization: { contains: search, mode: 'insensitive' } },
          { user: { name: { contains: search, mode: 'insensitive' } } },
          { user: { email: { contains: search, mode: 'insensitive' } } },
        ],
      }),
      ...(institutionId && { institutionId }),
      ...(employmentType && { employmentType }),
      ...(status && { status }), // This will override the default filter if provided
    }

    // Build orderBy clause with proper typing
    const orderBy: Prisma.TeacherOrderByWithRelationInput = {
      [sortBy]: sortOrder,
    }

    // Get teachers with pagination
    const [teachers, total] = await Promise.all([
      this.prisma.teacher.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        include: {
          user: {
            select: {
              id: true,
              uuid: true,
              edverseId: true,
              name: true,
              email: true,
              phone: true,
              status: true,
            },
          },
          institution: {
            select: {
              id: true,
              name: true,
              type: true,
            },
          },
        },
      }),
      this.prisma.teacher.count({ where }),
    ])

    return {
      data: teachers,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    }
  }

  async findOne(id: number) {
    const teacher = await this.prisma.teacher.findFirst({
      where: {
        id,
        status: { not: 'RESIGNED' }, // Exclude resigned teachers
      },
      include: {
        user: {
          select: {
            id: true,
            uuid: true,
            edverseId: true,
            name: true,
            email: true,
            phone: true,
            status: true,
          },
        },
        institution: true,
        classSections: {
          include: {
            subject: {
              select: {
                id: true,
                subjectName: true,
                subjectCode: true,
                credits: true,
              },
            },
            semester: {
              select: {
                id: true,
                semesterName: true,
                semesterNumber: true,
              },
            },
          },
        },
        teacherSubjects: {
          include: {
            subject: true,
            academicYear: true,
          },
        },
      },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with ID ${id} not found`)
    }

    return teacher
  }

  async findByUuid(uuid: string) {
    const teacher = await this.prisma.teacher.findFirst({
      where: {
        user: {
          uuid,
        },
        status: { not: 'RESIGNED' },
      },
      include: {
        user: {
          select: {
            id: true,
            uuid: true,
            edverseId: true,
            name: true,
            email: true,
            phone: true,
            status: true,
          },
        },
        institution: true,
        classSections: {
          include: {
            subject: {
              select: {
                id: true,
                subjectName: true,
                subjectCode: true,
                credits: true,
              },
            },
            semester: {
              select: {
                id: true,
                semesterName: true,
                semesterNumber: true,
              },
            },
          },
        },
        teacherSubjects: {
          include: {
            subject: true,
            academicYear: true,
          },
        },
      },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${uuid} not found`)
    }

    return teacher
  }

  async update(id: number, updateTeacherDto: UpdateTeacherDto) {
    // Check if teacher exists
    const existingTeacher = await this.prisma.teacher.findUnique({
      where: { id },
    })

    if (!existingTeacher) {
      throw new NotFoundException(`Teacher with ID ${id} not found`)
    }

    // Check if employee ID already exists (if being updated)
    if (
      updateTeacherDto.employeeId &&
      updateTeacherDto.employeeId !== existingTeacher.employeeId
    ) {
      const employeeIdExists = await this.prisma.teacher.findUnique({
        where: { employeeId: updateTeacherDto.employeeId },
      })

      if (employeeIdExists) {
        throw new ConflictException(
          'Teacher with this employee ID already exists'
        )
      }
    }

    // Build update data with proper typing
    const updateData: Prisma.TeacherUpdateInput = {
      ...(updateTeacherDto.employeeId && {
        employeeId: updateTeacherDto.employeeId,
      }),
      ...(updateTeacherDto.designation && {
        designation: updateTeacherDto.designation,
      }),
      ...(updateTeacherDto.specialization && {
        specialization: updateTeacherDto.specialization,
      }),
      ...(updateTeacherDto.qualification && {
        qualification: updateTeacherDto.qualification,
      }),
      ...(updateTeacherDto.experienceYears !== undefined && {
        experienceYears: updateTeacherDto.experienceYears,
      }),
      ...(updateTeacherDto.salary !== undefined && {
        salary: updateTeacherDto.salary,
      }),
      ...(updateTeacherDto.employmentType && {
        employmentType: updateTeacherDto.employmentType,
      }),
      ...(updateTeacherDto.officeLocation && {
        officeLocation: updateTeacherDto.officeLocation,
      }),
      ...(updateTeacherDto.officeHours && {
        officeHours: updateTeacherDto.officeHours,
      }),
      ...(updateTeacherDto.researchInterests && {
        researchInterests: updateTeacherDto.researchInterests,
      }),
      ...(updateTeacherDto.publications && {
        publications: updateTeacherDto.publications,
      }),
      ...(updateTeacherDto.status && { status: updateTeacherDto.status }),
    }

    // Handle joinDate separately
    if (updateTeacherDto.joinDate) {
      updateData.joinDate = new Date(updateTeacherDto.joinDate)
    }

    const teacher = await this.prisma.teacher.update({
      where: { id },
      data: updateData,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            phone: true,
            status: true,
          },
        },
        institution: {
          select: {
            id: true,
            name: true,
            type: true,
          },
        },
      },
    })

    return teacher
  }

  async remove(id: number) {
    // Check if teacher exists
    const existingTeacher = await this.prisma.teacher.findUnique({
      where: { id },
    })

    if (!existingTeacher) {
      throw new NotFoundException(`Teacher with ID ${id} not found`)
    }

    // Soft delete by updating status
    const teacher = await this.prisma.teacher.update({
      where: { id },
      data: { status: 'RESIGNED' },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    })

    return teacher
  }

  async assignSubjects(
    teacherId: number,
    assignSubjectsDto: AssignSubjectsDto
  ) {
    const { subjectIds, academicYearId } = assignSubjectsDto

    // Check if teacher exists
    const teacher = await this.prisma.teacher.findUnique({
      where: { id: teacherId },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with ID ${teacherId} not found`)
    }

    // Remove existing assignments for this teacher and academic year
    await this.prisma.teacherSubject.deleteMany({
      where: {
        teacherId,
        academicYearId,
      },
    })

    // Create new assignments
    const assignments = await Promise.all(
      subjectIds.map(subjectId =>
        this.prisma.teacherSubject.create({
          data: {
            teacherId,
            subjectId,
            academicYearId,
          },
          include: {
            subject: true,
            academicYear: true,
          },
        })
      )
    )

    return assignments
  }

  async getTeacherSubjects(teacherId: number, academicYearId?: number) {
    // Build where clause with proper typing
    const where: Prisma.TeacherSubjectWhereInput = {
      teacherId,
      ...(academicYearId && { academicYearId }),
    }

    const subjects = await this.prisma.teacherSubject.findMany({
      where,
      include: {
        subject: true,
        academicYear: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    })

    return subjects
  }

  async getTeacherClasses(teacherId: number, semesterId?: number) {
    // Build where clause with proper typing
    const where: Prisma.ClassSectionWhereInput = {
      teacherId,
      ...(semesterId && { semesterId }),
    }

    const classes = await this.prisma.classSection.findMany({
      where,
      include: {
        subject: {
          select: {
            id: true,
            subjectName: true,
            subjectCode: true,
            credits: true,
          },
        },
        semester: {
          select: {
            id: true,
            semesterName: true,
            semesterNumber: true,
          },
        },
        attendance: {
          select: {
            id: true,
            date: true,
            status: true,
          },
        },
      },
      orderBy: {
        subject: {
          subjectName: 'asc',
        },
      },
    })

    return classes
  }

  /**
   * Check if teacher has access to attendance statistics
   * Returns access status and reason if denied
   */
  private async checkAttendanceAccess(
    teacherId: number
  ): Promise<{ hasAccess: boolean; reason?: string }> {
    // Check if teacher exists and get their employment status
    const teacher = await this.prisma.teacher.findUnique({
      where: { id: teacherId },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with ID ${teacherId} not found`)
    }

    // Check if teacher is currently employed (not resigned/retired/on leave)
    if (teacher.status !== 'ACTIVE') {
      return {
        hasAccess: false,
        reason: `Not an active teacher (Status: ${teacher.status})`,
      }
    }

    // Check if teacher is a class teacher for the CURRENT academic year
    const classTeacherAssignment = await this.prisma.classTeacher.findFirst({
      where: {
        teacherId,
        academicYear: {
          status: 'CURRENT', // Only current academic year
        },
      },
      include: {
        academicYear: true,
        course: true,
      },
    })

    if (!classTeacherAssignment) {
      return {
        hasAccess: false,
        reason: 'Not a class teacher for the current academic year',
      }
    }

    return { hasAccess: true }
  }

  async getDashboardStats(teacherId: number): Promise<TeacherDashboardStats> {
    // Check if teacher has access
    const accessCheck = await this.checkAttendanceAccess(teacherId)

    if (!accessCheck.hasAccess) {
      throw new ForbiddenException(
        `Dashboard attendance stats are only available for active class teachers. Reason: ${accessCheck.reason}`
      )
    }

    // Use UTC dates to avoid timezone issues with date comparisons
    const now = new Date()
    const today = this.getUTCDate(now)
    const tomorrow = new Date(today)
    tomorrow.setUTCDate(tomorrow.getUTCDate() + 1)

    const startOfMonth = new Date(
      Date.UTC(now.getFullYear(), now.getMonth(), 1)
    )
    const endOfMonth = new Date(
      Date.UTC(now.getFullYear(), now.getMonth() + 1, 0)
    )

    // Get section IDs for this teacher
    const classSections = await this.prisma.classSection.findMany({
      where: {
        teacherId,
        status: 'ACTIVE',
      },
      select: { id: true },
    })
    const sectionIds = classSections.map(cs => cs.id)

    const [uniqueStudents, todayAttendance, monthlyAttendanceStats] =
      await Promise.all([
        // Get unique students who have attendance today in teacher's sections
        this.prisma.attendance.findMany({
          where: {
            sectionId: { in: sectionIds },
            date: {
              gte: today,
              lt: tomorrow,
            },
          },
          select: {
            studentId: true,
          },
          distinct: ['studentId'],
        }),

        // Today's attendance for teacher's classes
        this.prisma.attendance.findMany({
          where: {
            sectionId: { in: sectionIds },
            date: {
              gte: today,
              lt: tomorrow,
            },
          },
          select: {
            studentId: true,
            status: true,
          },
        }),

        // Monthly attendance statistics
        this.prisma.attendance.findMany({
          where: {
            sectionId: { in: sectionIds },
            date: {
              gte: startOfMonth,
              lte: endOfMonth,
            },
          },
          select: {
            status: true,
          },
        }),
      ])

    // Calculate attendance statistics
    const totalStudentsCount = uniqueStudents.length

    // Group today's attendance by student (to handle students with multiple sections)
    // Priority: PRESENT > LATE > EXCUSED > ABSENT
    const studentAttendanceMap = new Map<number, string>()
    const statusPriority = { PRESENT: 4, LATE: 3, EXCUSED: 2, ABSENT: 1 }

    todayAttendance.forEach(record => {
      const currentStatus = studentAttendanceMap.get(record.studentId)
      const currentPriority = currentStatus
        ? statusPriority[currentStatus as keyof typeof statusPriority] || 0
        : 0
      const newPriority =
        statusPriority[record.status as keyof typeof statusPriority] || 0

      // Keep the "best" status if student has multiple attendance records
      if (newPriority > currentPriority) {
        studentAttendanceMap.set(record.studentId, record.status)
      }
    })

    // Count unique students by their final status
    const statusCounts = { PRESENT: 0, ABSENT: 0, LATE: 0, EXCUSED: 0 }
    studentAttendanceMap.forEach(status => {
      if (status in statusCounts) {
        statusCounts[status as keyof typeof statusCounts]++
      }
    })

    const presentToday = statusCounts.PRESENT
    const absentToday = statusCounts.ABSENT
    const lateToday = statusCounts.LATE

    // Calculate monthly average
    const totalMonthlyRecords = monthlyAttendanceStats.length
    const presentMonthly = monthlyAttendanceStats.filter(
      a => a.status === 'PRESENT' || a.status === 'LATE'
    ).length

    const avgAttendanceThisMonth =
      totalMonthlyRecords > 0
        ? Math.round((presentMonthly / totalMonthlyRecords) * 100 * 10) / 10
        : 0

    const attendancePercentageToday =
      totalStudentsCount > 0
        ? Math.round((presentToday / totalStudentsCount) * 100 * 10) / 10
        : 0

    return {
      totalStudents: totalStudentsCount,
      presentToday,
      absentToday,
      lateToday,
      attendancePercentageToday,
      avgAttendanceThisMonth,
    }
  }

  async getRecentStudentActivity(
    teacherId: number,
    limit: number = 10
  ): Promise<TeacherStudentActivity[]> {
    // Check if teacher exists
    const teacher = await this.prisma.teacher.findUnique({
      where: { id: teacherId },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with ID ${teacherId} not found`)
    }

    // Get class section IDs for this teacher
    const classSections = await this.prisma.classSection.findMany({
      where: {
        teacherId,
        status: 'ACTIVE',
      },
      select: { id: true },
    })

    const sectionIds = classSections.map(cs => cs.id)

    if (sectionIds.length === 0) {
      return []
    }

    // Get students who have attendance records in teacher's sections
    const studentsWithActivity = await this.prisma.student.findMany({
      where: {
        attendance: {
          some: {
            sectionId: { in: sectionIds },
          },
        },
        status: 'ACTIVE',
      },
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            name: true,
            lastLogin: true,
          },
        },
        attendance: {
          where: {
            sectionId: { in: sectionIds },
          },
          orderBy: {
            date: 'desc',
          },
          take: 10,
          select: {
            date: true,
            status: true,
          },
        },
        submissions: {
          where: {
            assignment: {
              teacherId,
            },
          },
          orderBy: {
            submittedAt: 'desc',
          },
          take: 1,
          select: {
            submittedAt: true,
            marksObtained: true,
            assignment: {
              select: {
                maxMarks: true,
              },
            },
          },
        },
        examResults: {
          where: {
            exam: {
              createdBy: teacherId,
            },
          },
          orderBy: {
            createdAt: 'desc',
          },
          take: 5,
          select: {
            marksObtained: true,
            grade: true,
            exam: {
              select: {
                totalMarks: true,
              },
            },
          },
        },
      },
      take: limit,
      orderBy: {
        user: {
          lastLogin: 'desc',
        },
      },
    })

    // Format the response
    return studentsWithActivity.map(student => {
      // Calculate attendance percentage
      const totalAttendance = student.attendance.length
      const presentCount = student.attendance.filter(
        a => a.status === 'PRESENT' || a.status === 'LATE'
      ).length
      const attendancePercentage =
        totalAttendance > 0
          ? Math.round((presentCount / totalAttendance) * 100)
          : 0

      // Calculate average grade
      let averageGrade = 'N/A'
      let averagePercentage = 0

      if (student.examResults.length > 0) {
        const totalMarks = student.examResults.reduce((sum, result) => {
          const marks =
            typeof result.marksObtained === 'number'
              ? result.marksObtained
              : parseFloat(result.marksObtained?.toString() || '0')
          return sum + marks
        }, 0)

        const totalPossible = student.examResults.reduce((sum, result) => {
          return sum + result.exam.totalMarks
        }, 0)

        if (totalPossible > 0) {
          averagePercentage = Math.round((totalMarks / totalPossible) * 100)

          // Assign letter grade (A+, A, B+, B, C, D)
          if (averagePercentage >= 93) averageGrade = 'A+'
          else if (averagePercentage >= 85) averageGrade = 'A'
          else if (averagePercentage >= 77) averageGrade = 'B+'
          else if (averagePercentage >= 70) averageGrade = 'B'
          else if (averagePercentage >= 60) averageGrade = 'C'
          else averageGrade = 'D'
        }
      }

      // Get last active time
      const lastSubmission = student.submissions[0]?.submittedAt
      const lastLogin = student.user.lastLogin
      const lastActivity = lastSubmission || lastLogin

      let lastActiveText = 'No recent activity'
      if (lastActivity) {
        const diffMs = Date.now() - new Date(lastActivity).getTime()
        const diffMins = Math.floor(diffMs / 60000)
        const diffHours = Math.floor(diffMs / 3600000)
        const diffDays = Math.floor(diffMs / 86400000)

        if (diffMins < 60) {
          lastActiveText = `${diffMins} mins ago`
        } else if (diffHours < 24) {
          lastActiveText = `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`
        } else {
          lastActiveText = `${diffDays} day${diffDays > 1 ? 's' : ''} ago`
        }
      }

      return {
        id: student.id,
        name: student.user.name,
        firstName: student.user.firstName,
        lastName: student.user.lastName,
        initials: `${student.user.firstName[0]}${student.user.lastName[0]}`,
        lastActive: lastActiveText,
        lastActivityDate: lastActivity,
        grade: averageGrade,
        percentage: averagePercentage,
        attendancePercentage,
        admissionNumber: student.admissionNumber,
        rollNumber: student.rollNumber,
      }
    })
  }

  async getAttendanceSummary(
    teacherId: number,
    date?: string,
    period: 'daily' | 'weekly' | 'monthly' = 'daily'
  ): Promise<TeacherAttendanceSummary> {
    // Check if teacher exists
    const teacher = await this.prisma.teacher.findUnique({
      where: { id: teacherId },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with ID ${teacherId} not found`)
    }

    const targetDate = date ? new Date(date) : new Date()
    let startDate: Date
    let endDate: Date

    // Calculate date range based on period
    switch (period) {
      case 'daily':
        startDate = new Date(targetDate)
        startDate.setHours(0, 0, 0, 0)
        endDate = new Date(targetDate)
        endDate.setHours(23, 59, 59, 999)
        break

      case 'weekly':
        startDate = new Date(targetDate)
        startDate.setDate(targetDate.getDate() - targetDate.getDay())
        startDate.setHours(0, 0, 0, 0)
        endDate = new Date(startDate)
        endDate.setDate(startDate.getDate() + 6)
        endDate.setHours(23, 59, 59, 999)
        break

      case 'monthly':
        startDate = new Date(targetDate.getFullYear(), targetDate.getMonth(), 1)
        endDate = new Date(
          targetDate.getFullYear(),
          targetDate.getMonth() + 1,
          0,
          23,
          59,
          59,
          999
        )
        break
    }

    // Get attendance records
    const attendanceRecords = await this.prisma.attendance.findMany({
      where: {
        section: {
          teacherId,
          status: 'ACTIVE',
        },
        date: {
          gte: startDate,
          lte: endDate,
        },
      },
      include: {
        student: {
          include: {
            user: {
              select: {
                firstName: true,
                lastName: true,
                name: true,
              },
            },
          },
        },
        section: {
          include: {
            subject: {
              select: {
                subjectName: true,
                subjectCode: true,
              },
            },
          },
        },
      },
      orderBy: {
        date: 'desc',
      },
    })

    // Group by status
    const summary = attendanceRecords.reduce(
      (acc, record) => {
        acc[record.status.toLowerCase()] =
          (acc[record.status.toLowerCase()] || 0) + 1
        acc.total++
        return acc
      },
      { present: 0, absent: 0, late: 0, excused: 0, total: 0 }
    )

    // Calculate percentage
    const attendancePercentage =
      summary.total > 0
        ? Math.round(
            ((summary.present + summary.late) / summary.total) * 100 * 10
          ) / 10
        : 0

    return {
      period,
      startDate,
      endDate,
      summary,
      attendancePercentage,
      records: attendanceRecords.map(record => ({
        id: record.id,
        date: record.date,
        status: record.status,
        student: {
          id: record.student.id,
          name: record.student.user.name,
          admissionNumber: record.student.admissionNumber,
        },
        subject: {
          name: record.section.subject.subjectName,
          code: record.section.subject.subjectCode,
        },
        remarks: record.remarks,
      })),
    }
  }

  // UUID-based methods
  async updateByUuid(uuid: string, updateTeacherDto: UpdateTeacherDto) {
    // First find the teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: {
        user: { uuid },
      },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${uuid} not found`)
    }

    // Use the existing update method with the found teacher ID
    return this.update(teacher.id, updateTeacherDto)
  }

  async removeByUuid(uuid: string) {
    // First find the teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: {
        user: { uuid },
      },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${uuid} not found`)
    }

    // Use the existing remove method with the found teacher ID
    return this.remove(teacher.id)
  }

  async assignSubjectsByUuid(
    uuid: string,
    assignSubjectsDto: AssignSubjectsDto
  ) {
    // First find the teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: {
        user: { uuid },
      },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${uuid} not found`)
    }

    // Use the existing assignSubjects method with the found teacher ID
    return this.assignSubjects(teacher.id, assignSubjectsDto)
  }

  async getTeacherSubjectsByUuid(uuid: string, academicYearId?: number) {
    // First find the teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: {
        user: { uuid },
      },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${uuid} not found`)
    }

    // Use the existing getTeacherSubjects method with the found teacher ID
    return this.getTeacherSubjects(teacher.id, academicYearId)
  }

  async getTeacherClassesByUuid(uuid: string, semesterId?: number) {
    // First find the teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: {
        user: { uuid },
      },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${uuid} not found`)
    }

    // Use the existing getTeacherClasses method with the found teacher ID
    return this.getTeacherClasses(teacher.id, semesterId)
  }

  async getDashboardStatsByUuid(uuid: string): Promise<TeacherDashboardStats> {
    // First find the teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: {
        user: { uuid },
      },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${uuid} not found`)
    }

    // Use the existing getDashboardStats method with the found teacher ID
    return this.getDashboardStats(teacher.id)
  }

  async getRecentStudentActivityByUuid(
    uuid: string,
    limit: number = 10
  ): Promise<TeacherStudentActivity[]> {
    // First find the teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: {
        user: { uuid },
      },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${uuid} not found`)
    }

    // Use the existing getRecentStudentActivity method with the found teacher ID
    return this.getRecentStudentActivity(teacher.id, limit)
  }

  async getAttendanceSummaryByUuid(
    uuid: string,
    date?: string,
    period: 'daily' | 'weekly' | 'monthly' = 'daily'
  ): Promise<TeacherAttendanceSummary> {
    // First find the teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: {
        user: { uuid },
      },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${uuid} not found`)
    }

    // Use the existing getAttendanceSummary method with the found teacher ID
    return this.getAttendanceSummary(teacher.id, date, period)
  }

  // ============================================================================
  // ENHANCED DASHBOARD METHODS
  // ============================================================================

  /**
   * Get enhanced dashboard stats with tab summaries and daily preview
   */
  async getEnhancedDashboardStats(
    teacherId: number
  ): Promise<EnhancedTeacherDashboardStats> {
    // Check if teacher has access to attendance stats
    const accessCheck = await this.checkAttendanceAccess(teacherId)

    let basicStats: TeacherDashboardStats
    let weeklyPreview: DailyAttendancePreview[]

    if (accessCheck.hasAccess) {
      // Get basic dashboard stats (existing method)
      basicStats = await this.getDashboardStats(teacherId)
      weeklyPreview = await this.getWeeklyAttendancePreview(teacherId)
    } else {
      // Return empty/zero stats if no access
      basicStats = {
        totalStudents: 0,
        presentToday: 0,
        absentToday: 0,
        lateToday: 0,
        attendancePercentageToday: 0,
        avgAttendanceThisMonth: 0,
      }
      weeklyPreview = []
    }

    // Get additional metrics (these are available to all teachers)
    const [
      subjectCount,
      subjectPerformanceSummary,
      gradeDistSummary,
      currentSemesterClasses,
      recentAssignments,
      upcomingExaminations,
    ] = await Promise.all([
      this.getTeacherSubjectCount(teacherId),
      this.getSubjectPerformanceSummary(teacherId),
      this.getGradeDistributionSummary(teacherId),
      // Workload metrics (previously in /stats)
      this.prisma.classSection.count({
        where: {
          teacherId,
          semester: {
            status: 'ACTIVE',
          },
        },
      }),
      this.prisma.assignment.count({
        where: {
          teacherId,
          assignedDate: {
            gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // Last 30 days
          },
        },
      }),
      this.prisma.examination.count({
        where: {
          createdBy: teacherId,
          examDate: {
            gte: new Date(),
          },
        },
      }),
    ])

    return {
      ...basicStats,
      totalSubjects: subjectCount,
      overallClassAverage: subjectPerformanceSummary.overallAverage,
      studentsAtRisk: subjectPerformanceSummary.studentsAtRisk,
      hasAttendanceAccess: accessCheck.hasAccess,
      attendanceAccessReason: accessCheck.reason,
      currentSemesterClasses,
      recentAssignments,
      upcomingExaminations,
      tabSummaries: {
        attendanceTrends: {
          weeklyAverage: accessCheck.hasAccess
            ? Math.round(basicStats.avgAttendanceThisMonth)
            : 0,
          trend: accessCheck.hasAccess
            ? await this.getAttendanceTrend(teacherId)
            : 'stable',
          dailyPreview: weeklyPreview,
          lastUpdated: new Date().toISOString(),
        },
        subjectPerformance: {
          bestSubject: subjectPerformanceSummary.bestSubject,
          needsAttention: subjectPerformanceSummary.worstSubject,
          lastUpdated: new Date().toISOString(),
        },
        gradeDistribution: {
          topGrade: gradeDistSummary.mostCommonGrade,
          averageGrade: gradeDistSummary.averageGrade,
          lastUpdated: new Date().toISOString(),
        },
      },
    }
  }

  async getEnhancedDashboardStatsByUuid(
    uuid: string
  ): Promise<EnhancedTeacherDashboardStats> {
    // Find teacher without status filter so we can provide specific error messages
    const teacher = await this.prisma.teacher.findFirst({
      where: {
        user: {
          uuid,
        },
      },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${uuid} not found`)
    }

    return this.getEnhancedDashboardStats(teacher.id)
  }

  // ============================================================================
  // ATTENDANCE TRENDS - DETAILED DATA
  // ============================================================================

  /**
   * Get detailed attendance trends data for the Attendance Trends tab
   */
  async getAttendanceTrends(teacherId: number): Promise<AttendanceTrendsData> {
    const today = this.getUTCDate()
    const startOfWeek = this.getUTCDate()
    startOfWeek.setUTCDate(today.getUTCDate() - today.getUTCDay()) // Start of current week

    const endOfWeek = new Date(startOfWeek)
    endOfWeek.setUTCDate(startOfWeek.getUTCDate() + 6)
    endOfWeek.setUTCHours(23, 59, 59, 999)

    const [weeklyData, monthlyData, patterns] = await Promise.all([
      this.getWeeklyAttendanceData(teacherId, startOfWeek, endOfWeek),
      this.getMonthlyAttendanceData(teacherId),
      this.getAttendancePatterns(teacherId),
    ])

    return {
      weeklyOverview: weeklyData,
      monthlyTrends: monthlyData,
      attendancePatterns: patterns,
    }
  }

  async getAttendanceTrendsByUuid(uuid: string): Promise<AttendanceTrendsData> {
    const teacher = await this.findByUuid(uuid)
    return this.getAttendanceTrends(teacher.id)
  }

  private async getWeeklyAttendanceData(
    teacherId: number,
    startDate: Date,
    endDate: Date
  ) {
    const dailyAttendance: DailyAttendanceDetail[] = []
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

    for (
      let date = new Date(startDate);
      date <= endDate;
      date.setDate(date.getDate() + 1)
    ) {
      const currentDate = new Date(date)
      currentDate.setHours(0, 0, 0, 0)
      const nextDate = new Date(currentDate)
      nextDate.setDate(currentDate.getDate() + 1)

      const attendanceData = await this.prisma.attendance.groupBy({
        by: ['status'],
        where: {
          section: {
            teacherId,
            status: 'ACTIVE',
          },
          date: {
            gte: currentDate,
            lt: nextDate,
          },
        },
        _count: {
          status: true,
        },
      })

      const present =
        attendanceData.find(a => a.status === 'PRESENT')?._count.status || 0
      const absent =
        attendanceData.find(a => a.status === 'ABSENT')?._count.status || 0
      const late =
        attendanceData.find(a => a.status === 'LATE')?._count.status || 0
      const excused =
        attendanceData.find(a => a.status === 'EXCUSED')?._count.status || 0
      const total = present + absent + late + excused

      dailyAttendance.push({
        day: dayNames[currentDate.getDay()],
        date: currentDate.toISOString().split('T')[0],
        present,
        absent,
        late,
        excused,
        total,
        percentage: total > 0 ? Math.round((present / total) * 100) : 0,
      })
    }

    const weeklyAverage =
      dailyAttendance.length > 0
        ? Math.round(
            dailyAttendance.reduce((sum, day) => sum + day.percentage, 0) /
              dailyAttendance.length
          )
        : 0

    return {
      weekStartDate: startDate.toISOString().split('T')[0],
      weekEndDate: endDate.toISOString().split('T')[0],
      dailyAttendance,
      weeklyAverage,
    }
  }

  private async getMonthlyAttendanceData(teacherId: number) {
    const today = this.getUTCDate()
    const startOfMonth = new Date(
      Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), 1)
    )
    const endOfMonth = new Date(
      Date.UTC(today.getUTCFullYear(), today.getUTCMonth() + 1, 0)
    )

    // Get weekly breakdown for current month
    const weeklyBreakdown = []
    const weekStart = new Date(startOfMonth)
    let weekNumber = 1

    while (weekStart <= endOfMonth) {
      const weekEnd = new Date(weekStart)
      weekEnd.setDate(weekStart.getDate() + 6)
      if (weekEnd > endOfMonth) weekEnd.setTime(endOfMonth.getTime())

      const weekData = await this.getWeeklyAttendanceData(
        teacherId,
        weekStart,
        weekEnd
      )

      const totalStudents =
        weekData.dailyAttendance.length > 0
          ? Math.round(
              weekData.dailyAttendance.reduce(
                (sum, day) => sum + day.total,
                0
              ) / weekData.dailyAttendance.length
            )
          : 0

      weeklyBreakdown.push({
        weekNumber,
        weekStartDate: weekStart.toISOString().split('T')[0],
        averageAttendance: weekData.weeklyAverage,
        totalStudents,
      })

      weekStart.setDate(weekStart.getDate() + 7)
      weekNumber++
    }

    const monthlyAverage =
      weeklyBreakdown.length > 0
        ? Math.round(
            weeklyBreakdown.reduce(
              (sum, week) => sum + week.averageAttendance,
              0
            ) / weeklyBreakdown.length
          )
        : 0

    // Get previous month for comparison
    const prevMonthStart = new Date(
      today.getFullYear(),
      today.getMonth() - 1,
      1
    )
    const prevMonthEnd = new Date(today.getFullYear(), today.getMonth(), 0)
    const prevMonthAverage = await this.getMonthAttendanceAverage(
      teacherId,
      prevMonthStart,
      prevMonthEnd
    )

    const percentageChange =
      prevMonthAverage > 0
        ? ((monthlyAverage - prevMonthAverage) / prevMonthAverage) * 100
        : 0

    const trend: 'up' | 'down' | 'stable' =
      percentageChange > 2 ? 'up' : percentageChange < -2 ? 'down' : 'stable'

    return {
      monthYear: today.toLocaleDateString('en-US', {
        month: 'long',
        year: 'numeric',
      }),
      weeklyBreakdown,
      monthlyAverage,
      comparisonWithPreviousMonth: {
        previousMonth: prevMonthStart.toLocaleDateString('en-US', {
          month: 'long',
          year: 'numeric',
        }),
        percentageChange: Math.round(percentageChange * 100) / 100,
        trend,
      },
    }
  }

  private async getAttendancePatterns(teacherId: number) {
    const today = this.getUTCDate()
    const startOfMonth = new Date(
      Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), 1)
    )
    const endOfMonth = new Date(
      Date.UTC(today.getUTCFullYear(), today.getUTCMonth() + 1, 0)
    )

    // Get all attendance records for the month
    const attendanceRecords = await this.prisma.attendance.findMany({
      where: {
        section: {
          teacherId,
          status: 'ACTIVE',
        },
        date: {
          gte: startOfMonth,
          lte: endOfMonth,
        },
      },
      include: {
        student: true,
      },
    })

    // Calculate day-wise attendance
    const dayWiseAttendance: Record<
      string,
      { present: number; total: number }
    > = {}
    const dayNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ]

    attendanceRecords.forEach(record => {
      const dayName = dayNames[new Date(record.date).getDay()]
      if (!dayWiseAttendance[dayName]) {
        dayWiseAttendance[dayName] = { present: 0, total: 0 }
      }
      dayWiseAttendance[dayName].total++
      if (record.status === 'PRESENT' || record.status === 'LATE') {
        dayWiseAttendance[dayName].present++
      }
    })

    // Find best and worst days
    let bestDay = 'Monday'
    let worstDay = 'Monday'
    let bestPercentage = 0
    let worstPercentage = 100

    Object.entries(dayWiseAttendance).forEach(([day, data]) => {
      const percentage = (data.present / data.total) * 100
      if (percentage > bestPercentage) {
        bestPercentage = percentage
        bestDay = day
      }
      if (percentage < worstPercentage) {
        worstPercentage = percentage
        worstDay = day
      }
    })

    // Calculate student attendance patterns
    const studentAttendance: Record<
      number,
      { present: number; total: number }
    > = {}

    attendanceRecords.forEach(record => {
      if (!studentAttendance[record.studentId]) {
        studentAttendance[record.studentId] = { present: 0, total: 0 }
      }
      studentAttendance[record.studentId].total++
      if (record.status === 'PRESENT' || record.status === 'LATE') {
        studentAttendance[record.studentId].present++
      }
    })

    const consistentAttendees = Object.values(studentAttendance).filter(
      data => (data.present / data.total) * 100 >= 95
    ).length

    const irregularAttendees = Object.values(studentAttendance).filter(
      data => (data.present / data.total) * 100 < 75
    ).length

    return {
      bestAttendanceDay: bestDay,
      worstAttendanceDay: worstDay,
      consistentAttendees,
      irregularAttendees,
      improvingStudents: 0, // TODO: Implement trend analysis
      decliningStudents: 0, // TODO: Implement trend analysis
    }
  }

  // ============================================================================
  // SUBJECT PERFORMANCE - DETAILED DATA
  // ============================================================================

  /**
   * Get detailed subject performance data for the Subject Performance tab
   */
  async getSubjectPerformanceData(
    teacherId: number
  ): Promise<SubjectPerformanceData> {
    const teacherSubjects = await this.prisma.teacherSubject.findMany({
      where: { teacherId },
      include: {
        subject: true,
        academicYear: true,
      },
    })

    if (teacherSubjects.length === 0) {
      return {
        subjects: [],
        overallClassAverage: 0,
        bestPerformingSubject: { name: 'N/A', averageScore: 0 },
        subjectNeedingAttention: {
          name: 'N/A',
          averageScore: 0,
          studentsAtRisk: 0,
        },
        performanceComparison: {
          currentMonth: 0,
          previousMonth: 0,
          percentageChange: 0,
        },
      }
    }

    const subjects = await Promise.all(
      teacherSubjects.map(async ts => {
        const studentProgress = await this.prisma.studentProgress.findMany({
          where: {
            subjectId: ts.subjectId,
            academicYearId: ts.academicYearId,
          },
        })

        const averageScore =
          studentProgress.length > 0
            ? studentProgress.reduce(
                (sum, sp) => sum + (Number(sp.examScore) || 0),
                0
              ) / studentProgress.length
            : 0

        return {
          id: ts.subject.id,
          name: ts.subject.subjectName,
          code: ts.subject.subjectCode,
          averageScore: Math.round(averageScore * 100) / 100,
          totalStudents: studentProgress.length,
          performanceTrend: 'stable' as const, // TODO: Implement trend calculation
          lastUpdated: new Date().toISOString(),
        }
      })
    )

    const overallClassAverage =
      subjects.length > 0
        ? Math.round(
            (subjects.reduce((sum, subject) => sum + subject.averageScore, 0) /
              subjects.length) *
              100
          ) / 100
        : 0

    const bestPerforming = subjects.reduce(
      (best, current) =>
        current.averageScore > best.averageScore ? current : best,
      subjects[0]
    )

    const needingAttention = subjects.reduce(
      (worst, current) =>
        current.averageScore < worst.averageScore ? current : worst,
      subjects[0]
    )

    return {
      subjects,
      overallClassAverage,
      bestPerformingSubject: {
        name: bestPerforming.name,
        averageScore: bestPerforming.averageScore,
      },
      subjectNeedingAttention: {
        name: needingAttention.name,
        averageScore: needingAttention.averageScore,
        studentsAtRisk: 0, // TODO: Calculate students at risk
      },
      performanceComparison: {
        currentMonth: overallClassAverage,
        previousMonth: overallClassAverage, // TODO: Get previous month data
        percentageChange: 0,
      },
    }
  }

  async getSubjectPerformanceDataByUuid(
    uuid: string
  ): Promise<SubjectPerformanceData> {
    const teacher = await this.findByUuid(uuid)
    return this.getSubjectPerformanceData(teacher.id)
  }

  // ============================================================================
  // GRADE DISTRIBUTION - DETAILED DATA
  // ============================================================================

  /**
   * Get detailed grade distribution data for the Grade Distribution tab
   */
  async getGradeDistributionData(
    teacherId: number
  ): Promise<GradeDistributionData> {
    // Get all student progress records for teacher's subjects
    const teacherSubjects = await this.prisma.teacherSubject.findMany({
      where: { teacherId },
      select: { subjectId: true },
    })

    const subjectIds = teacherSubjects.map(ts => ts.subjectId)

    if (subjectIds.length === 0) {
      return {
        overallDistribution: {
          gradeBreakdown: {},
          percentageBreakdown: {},
          totalStudents: 0,
        },
        subjectWiseDistribution: [],
        gradeComparison: {
          currentSemester: {},
          previousSemester: {},
          improvement: [],
        },
        topPerformers: [],
      }
    }

    const studentProgress = await this.prisma.studentProgress.findMany({
      where: {
        subjectId: { in: subjectIds },
      },
      include: {
        student: {
          include: {
            user: {
              select: {
                uuid: true,
                firstName: true,
                lastName: true,
              },
            },
          },
        },
        subject: true,
      },
    })

    // Calculate overall grade distribution
    const gradeBreakdown: Record<string, number> = {}
    studentProgress.forEach(sp => {
      const grade = sp.overallGrade || 'No Grade'
      gradeBreakdown[grade] = (gradeBreakdown[grade] || 0) + 1
    })

    const totalStudents = studentProgress.length
    const percentageBreakdown: Record<string, number> = {}
    Object.entries(gradeBreakdown).forEach(([grade, count]) => {
      percentageBreakdown[grade] =
        totalStudents > 0 ? Math.round((count / totalStudents) * 100) : 0
    })

    // Subject-wise distribution
    const subjectWiseMap = new Map<number, typeof studentProgress>()
    studentProgress.forEach(sp => {
      if (!subjectWiseMap.has(sp.subjectId)) {
        subjectWiseMap.set(sp.subjectId, [])
      }
      subjectWiseMap.get(sp.subjectId)!.push(sp)
    })

    const subjectWiseDistribution = Array.from(subjectWiseMap.entries()).map(
      ([subjectId, records]) => {
        const subjectGrades: Record<string, number> = {}
        records.forEach(sp => {
          const grade = sp.overallGrade || 'No Grade'
          subjectGrades[grade] = (subjectGrades[grade] || 0) + 1
        })

        const grades = records
          .map(sp => sp.overallGrade)
          .filter(g => g !== null) as string[]
        const averageGrade = grades.length > 0 ? grades[0] : 'N/A' // Simplified

        return {
          subjectId,
          subjectName: records[0].subject.subjectName,
          gradeDistribution: subjectGrades,
          averageGrade,
          medianGrade: averageGrade, // Simplified
        }
      }
    )

    // Top performers
    const topPerformers = studentProgress
      .filter(sp => sp.overallGrade && ['A+', 'A'].includes(sp.overallGrade))
      .slice(0, 10)
      .map(sp => ({
        studentId: sp.student.user.uuid!,
        studentName: `${sp.student.user.firstName} ${sp.student.user.lastName}`,
        overallGrade: sp.overallGrade!,
        subjectGrades: { [sp.subject.subjectName]: sp.overallGrade! },
      }))

    return {
      overallDistribution: {
        gradeBreakdown,
        percentageBreakdown,
        totalStudents,
      },
      subjectWiseDistribution,
      gradeComparison: {
        currentSemester: gradeBreakdown,
        previousSemester: {}, // TODO: Get previous semester data
        improvement: [],
      },
      topPerformers,
    }
  }

  async getGradeDistributionDataByUuid(
    uuid: string
  ): Promise<GradeDistributionData> {
    const teacher = await this.findByUuid(uuid)
    return this.getGradeDistributionData(teacher.id)
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  private async getTeacherSubjectCount(teacherId: number): Promise<number> {
    return this.prisma.teacherSubject.count({
      where: { teacherId },
    })
  }

  private async getSubjectPerformanceSummary(teacherId: number) {
    const subjects = await this.prisma.teacherSubject.findMany({
      where: { teacherId },
      include: { subject: true },
    })

    if (subjects.length === 0) {
      return {
        overallAverage: 0,
        studentsAtRisk: 0,
        bestSubject: 'N/A',
        worstSubject: 'N/A',
      }
    }

    const subjectScores = await Promise.all(
      subjects.map(async ts => {
        const progress = await this.prisma.studentProgress.findMany({
          where: { subjectId: ts.subjectId },
        })

        const avgScore =
          progress.length > 0
            ? progress.reduce((sum, p) => sum + (Number(p.examScore) || 0), 0) /
              progress.length
            : 0

        return {
          name: ts.subject.subjectName,
          score: avgScore,
        }
      })
    )

    const overallAverage =
      subjectScores.reduce((sum, s) => sum + s.score, 0) / subjectScores.length

    const best = subjectScores.reduce((b, c) => (c.score > b.score ? c : b))
    const worst = subjectScores.reduce((w, c) => (c.score < w.score ? c : w))

    return {
      overallAverage: Math.round(overallAverage * 100) / 100,
      studentsAtRisk: 0, // TODO: Calculate
      bestSubject: `${best.name} (${Math.round(best.score)}%)`,
      worstSubject: `${worst.name} (${Math.round(worst.score)}%)`,
    }
  }

  private async getGradeDistributionSummary(teacherId: number) {
    const teacherSubjects = await this.prisma.teacherSubject.findMany({
      where: { teacherId },
      select: { subjectId: true },
    })

    const subjectIds = teacherSubjects.map(ts => ts.subjectId)

    if (subjectIds.length === 0) {
      return {
        mostCommonGrade: 'N/A',
        averageGrade: 'N/A',
      }
    }

    const progress = await this.prisma.studentProgress.findMany({
      where: { subjectId: { in: subjectIds } },
      select: { overallGrade: true },
    })

    const gradeCounts: Record<string, number> = {}
    progress.forEach(p => {
      if (p.overallGrade) {
        gradeCounts[p.overallGrade] = (gradeCounts[p.overallGrade] || 0) + 1
      }
    })

    const mostCommon = Object.entries(gradeCounts).reduce(
      (max, [grade, count]) => (count > max.count ? { grade, count } : max),
      { grade: 'N/A', count: 0 }
    )

    const percentage =
      progress.length > 0
        ? Math.round((mostCommon.count / progress.length) * 100)
        : 0

    return {
      mostCommonGrade: `${mostCommon.grade} (${percentage}%)`,
      averageGrade: mostCommon.grade,
    }
  }

  private async getWeeklyAttendancePreview(
    teacherId: number
  ): Promise<DailyAttendancePreview[]> {
    const today = this.getUTCDate()
    const startOfWeek = this.getUTCDate()
    startOfWeek.setUTCDate(today.getUTCDate() - today.getUTCDay())

    const endOfWeek = new Date(startOfWeek)
    endOfWeek.setUTCDate(startOfWeek.getUTCDate() + 6)

    const weekData = await this.getWeeklyAttendanceData(
      teacherId,
      startOfWeek,
      endOfWeek
    )

    return weekData.dailyAttendance.map(day => ({
      day: day.day,
      percentage: day.percentage,
    }))
  }

  private async getAttendanceTrend(
    teacherId: number
  ): Promise<'improving' | 'declining' | 'stable'> {
    const today = this.getUTCDate()
    const thisMonth = new Date(
      Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), 1)
    )
    const lastMonth = new Date(
      Date.UTC(today.getUTCFullYear(), today.getUTCMonth() - 1, 1)
    )
    const lastMonthEnd = new Date(
      Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), 0)
    )

    const [thisMonthAvg, lastMonthAvg] = await Promise.all([
      this.getMonthAttendanceAverage(teacherId, thisMonth, today),
      this.getMonthAttendanceAverage(teacherId, lastMonth, lastMonthEnd),
    ])

    const change = thisMonthAvg - lastMonthAvg

    if (change > 2) return 'improving'
    if (change < -2) return 'declining'
    return 'stable'
  }

  private async getMonthAttendanceAverage(
    teacherId: number,
    startDate: Date,
    endDate: Date
  ): Promise<number> {
    const attendance = await this.prisma.attendance.findMany({
      where: {
        section: {
          teacherId,
          status: 'ACTIVE',
        },
        date: {
          gte: startDate,
          lte: endDate,
        },
      },
      select: { status: true },
    })

    if (attendance.length === 0) return 0

    const present = attendance.filter(
      a => a.status === 'PRESENT' || a.status === 'LATE'
    ).length

    return Math.round((present / attendance.length) * 100)
  }

  // ==================== Assignment Management ====================

  async createAssignment(
    userUuid: string,
    createAssignmentDto: CreateAssignmentDto
  ) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
      include: { user: true },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    // Verify subject exists
    const subject = await this.prisma.subject.findUnique({
      where: { id: createAssignmentDto.subjectId },
    })

    if (!subject) {
      throw new NotFoundException(
        `Subject with ID ${createAssignmentDto.subjectId} not found`
      )
    }

    // Verify section exists if provided
    if (createAssignmentDto.sectionId) {
      const section = await this.prisma.classSection.findUnique({
        where: { id: createAssignmentDto.sectionId },
      })

      if (!section) {
        throw new NotFoundException(
          `Section with ID ${createAssignmentDto.sectionId} not found`
        )
      }
    }

    const { dueDate, status, ...rest } = createAssignmentDto

    const assignment = await this.prisma.assignment.create({
      data: {
        ...rest,
        teacherId: teacher.id,
        dueDate: new Date(dueDate),
        status: (status as 'DRAFT' | 'PUBLISHED' | 'CLOSED') || 'DRAFT',
      },
      include: {
        subject: { select: { subjectName: true, subjectCode: true } },
        section: { select: { sectionName: true } },
        teacher: {
          select: {
            user: { select: { name: true, email: true } },
          },
        },
      },
    })

    return {
      success: true,
      message: 'Assignment created successfully',
      data: assignment,
    }
  }

  async getTeacherAssignments(
    userUuid: string,
    status?: string,
    courseId?: number
  ) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    const where: Prisma.AssignmentWhereInput = { teacherId: teacher.id }

    if (status) {
      where.status = status as 'DRAFT' | 'PUBLISHED' | 'CLOSED'
    }

    if (courseId) {
      where.subjectId = courseId
    }

    const assignments = await this.prisma.assignment.findMany({
      where,
      include: {
        subject: { select: { subjectName: true, subjectCode: true } },
        section: { select: { sectionName: true } },
        submissions: {
          select: {
            id: true,
            status: true,
            submittedAt: true,
          },
        },
      },
      orderBy: { dueDate: 'desc' },
    })

    // Add submission statistics
    const assignmentsWithStats = assignments.map(assignment => ({
      ...assignment,
      submissionStats: {
        total: assignment.submissions.length,
        submitted: assignment.submissions.filter(
          s => s.status === 'SUBMITTED' || s.status === 'GRADED'
        ).length,
        graded: assignment.submissions.filter(s => s.status === 'GRADED')
          .length,
        returned: assignment.submissions.filter(s => s.status === 'RETURNED')
          .length,
      },
    }))

    return {
      success: true,
      data: {
        assignments: assignmentsWithStats,
        totalCount: assignmentsWithStats.length,
      },
    }
  }

  async getAssignmentById(userUuid: string, assignmentId: number) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    const assignment = await this.prisma.assignment.findUnique({
      where: { id: assignmentId },
      include: {
        subject: { select: { subjectName: true, subjectCode: true } },
        section: { select: { sectionName: true } },
        teacher: {
          select: {
            user: { select: { name: true, email: true } },
          },
        },
        submissions: {
          include: {
            student: {
              select: {
                user: { select: { name: true, email: true } },
                admissionNumber: true,
              },
            },
          },
        },
      },
    })

    if (!assignment) {
      throw new NotFoundException(
        `Assignment with ID ${assignmentId} not found`
      )
    }

    // Verify the assignment belongs to this teacher
    if (assignment.teacherId !== teacher.id) {
      throw new NotFoundException(
        'You do not have permission to access this assignment'
      )
    }

    return {
      success: true,
      data: assignment,
    }
  }

  async updateAssignment(
    userUuid: string,
    assignmentId: number,
    updateAssignmentDto: UpdateAssignmentDto
  ) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    const assignment = await this.prisma.assignment.findUnique({
      where: { id: assignmentId },
    })

    if (!assignment) {
      throw new NotFoundException(
        `Assignment with ID ${assignmentId} not found`
      )
    }

    // Verify the assignment belongs to this teacher
    if (assignment.teacherId !== teacher.id) {
      throw new NotFoundException(
        'You do not have permission to update this assignment'
      )
    }

    const { dueDate: dueDateStr, status, ...updateRest } = updateAssignmentDto
    const updateData: Prisma.AssignmentUpdateInput = { ...updateRest }

    if (dueDateStr) {
      updateData.dueDate = new Date(dueDateStr)
    }

    if (status) {
      updateData.status = status as 'DRAFT' | 'PUBLISHED' | 'CLOSED'
    }

    const updatedAssignment = await this.prisma.assignment.update({
      where: { id: assignmentId },
      data: updateData,
      include: {
        subject: { select: { subjectName: true, subjectCode: true } },
        section: { select: { sectionName: true } },
      },
    })

    return {
      success: true,
      message: 'Assignment updated successfully',
      data: updatedAssignment,
    }
  }

  async deleteAssignment(userUuid: string, assignmentId: number) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    const assignment = await this.prisma.assignment.findUnique({
      where: { id: assignmentId },
    })

    if (!assignment) {
      throw new NotFoundException(
        `Assignment with ID ${assignmentId} not found`
      )
    }

    // Verify the assignment belongs to this teacher
    if (assignment.teacherId !== teacher.id) {
      throw new NotFoundException(
        'You do not have permission to delete this assignment'
      )
    }

    await this.prisma.assignment.delete({
      where: { id: assignmentId },
    })

    return {
      success: true,
      message: 'Assignment deleted successfully',
    }
  }

  // ==================== Examination Management ====================

  async createExamination(
    userUuid: string,
    createExaminationDto: CreateExaminationDto
  ) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
      include: { user: true },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    // Verify subject exists
    const subject = await this.prisma.subject.findUnique({
      where: { id: createExaminationDto.subjectId },
    })

    if (!subject) {
      throw new NotFoundException(
        `Subject with ID ${createExaminationDto.subjectId} not found`
      )
    }

    // Verify semester exists
    const semester = await this.prisma.semester.findUnique({
      where: { id: createExaminationDto.semesterId },
    })

    if (!semester) {
      throw new NotFoundException(
        `Semester with ID ${createExaminationDto.semesterId} not found`
      )
    }

    const {
      examDate,
      startTime,
      examType,
      status,
      subjectId,
      semesterId,
      ...examinationRest
    } = createExaminationDto

    const examination = await this.prisma.examination.create({
      data: {
        ...examinationRest,
        subject: { connect: { id: subjectId } },
        semester: { connect: { id: semesterId } },
        creator: { connect: { id: teacher.id } },
        examDate: new Date(examDate),
        examType: examType as
          | 'QUIZ'
          | 'MIDTERM'
          | 'FINAL'
          | 'ASSIGNMENT'
          | 'PROJECT',
        status:
          (status as 'SCHEDULED' | 'ONGOING' | 'COMPLETED' | 'CANCELLED') ||
          'SCHEDULED',
        startTime: startTime ? new Date(`2024-01-01T${startTime}`) : undefined,
      } as Prisma.ExaminationCreateInput,
      include: {
        subject: { select: { subjectName: true, subjectCode: true } },
        semester: { select: { semesterName: true } },
      },
    })

    return {
      success: true,
      message: 'Examination created successfully',
      data: examination,
    }
  }

  async getTeacherExaminations(
    userUuid: string,
    status?: string,
    courseId?: number
  ) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    const where: Prisma.ExaminationWhereInput = { createdBy: teacher.id }

    if (status) {
      where.status = status as
        | 'SCHEDULED'
        | 'ONGOING'
        | 'COMPLETED'
        | 'CANCELLED'
    }

    if (courseId) {
      where.subjectId = courseId
    }

    const examinations = await this.prisma.examination.findMany({
      where,
      include: {
        subject: { select: { subjectName: true, subjectCode: true } },
        semester: { select: { semesterName: true } },
        results: {
          select: {
            id: true,
            marksObtained: true,
            grade: true,
          },
        },
      },
      orderBy: { examDate: 'desc' },
    })

    // Add result statistics
    const examinationsWithStats = examinations.map(examination => ({
      ...examination,
      resultStats: {
        total: examination.results.length,
        graded: examination.results.filter(r => r.grade !== null).length,
        averageMarks:
          examination.results.length > 0
            ? examination.results.reduce(
                (sum, r) => sum + (Number(r.marksObtained) || 0),
                0
              ) / examination.results.length
            : 0,
      },
    }))

    return {
      success: true,
      data: {
        examinations: examinationsWithStats,
        totalCount: examinationsWithStats.length,
      },
    }
  }

  async getExaminationById(userUuid: string, examinationId: number) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    const examination = await this.prisma.examination.findUnique({
      where: { id: examinationId },
      include: {
        subject: { select: { subjectName: true, subjectCode: true } },
        semester: { select: { semesterName: true } },
        results: {
          include: {
            student: {
              select: {
                user: { select: { name: true, email: true } },
                admissionNumber: true,
              },
            },
          },
        },
      },
    })

    if (!examination) {
      throw new NotFoundException(
        `Examination with ID ${examinationId} not found`
      )
    }

    // Verify the examination belongs to this teacher
    if (examination.createdBy !== teacher.id) {
      throw new NotFoundException(
        'You do not have permission to access this examination'
      )
    }

    return {
      success: true,
      data: examination,
    }
  }

  async updateExamination(
    userUuid: string,
    examinationId: number,
    updateExaminationDto: UpdateExaminationDto
  ) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    const examination = await this.prisma.examination.findUnique({
      where: { id: examinationId },
    })

    if (!examination) {
      throw new NotFoundException(
        `Examination with ID ${examinationId} not found`
      )
    }

    // Verify the examination belongs to this teacher
    if (examination.createdBy !== teacher.id) {
      throw new NotFoundException(
        'You do not have permission to update this examination'
      )
    }

    const { examDate, startTime, examType, status, ...updateRest } =
      updateExaminationDto
    const updateData: Prisma.ExaminationUpdateInput = { ...updateRest }

    if (examDate) {
      updateData.examDate = new Date(examDate)
    }

    if (startTime) {
      updateData.startTime = new Date(`2024-01-01T${startTime}`)
    }

    if (examType) {
      updateData.examType = examType as
        | 'QUIZ'
        | 'MIDTERM'
        | 'FINAL'
        | 'ASSIGNMENT'
        | 'PROJECT'
    }

    if (status) {
      updateData.status = status as
        | 'SCHEDULED'
        | 'ONGOING'
        | 'COMPLETED'
        | 'CANCELLED'
    }

    const updatedExamination = await this.prisma.examination.update({
      where: { id: examinationId },
      data: updateData,
      include: {
        subject: { select: { subjectName: true, subjectCode: true } },
        semester: { select: { semesterName: true } },
      },
    })

    return {
      success: true,
      message: 'Examination updated successfully',
      data: updatedExamination,
    }
  }

  async deleteExamination(userUuid: string, examinationId: number) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    const examination = await this.prisma.examination.findUnique({
      where: { id: examinationId },
    })

    if (!examination) {
      throw new NotFoundException(
        `Examination with ID ${examinationId} not found`
      )
    }

    // Verify the examination belongs to this teacher
    if (examination.createdBy !== teacher.id) {
      throw new NotFoundException(
        'You do not have permission to delete this examination'
      )
    }

    await this.prisma.examination.delete({
      where: { id: examinationId },
    })

    return {
      success: true,
      message: 'Examination deleted successfully',
    }
  }

  // ==================== Phase 1: Actionable Insights ====================

  /**
   * Get pending submissions that need grading
   */
  async getPendingSubmissions(userUuid: string, limit: number = 10) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    const submissions = await this.prisma.submission.findMany({
      where: {
        assignment: { teacherId: teacher.id },
        status: 'SUBMITTED', // Not yet graded
      },
      include: {
        student: {
          select: {
            user: { select: { name: true, uuid: true } },
            admissionNumber: true,
          },
        },
        assignment: {
          select: { id: true, title: true, dueDate: true, maxMarks: true },
        },
      },
      orderBy: { submittedAt: 'asc' }, // Oldest first (FIFO)
      take: limit,
    })

    // Calculate statistics
    const allPendingCount = await this.prisma.submission.count({
      where: {
        assignment: { teacherId: teacher.id },
        status: 'SUBMITTED',
      },
    })

    const oldestSubmission = submissions.length > 0 ? submissions[0] : null

    return {
      success: true,
      data: {
        submissions: submissions.map(s => ({
          id: s.id,
          student: {
            name: s.student.user.name,
            uuid: s.student.user.uuid,
            avatar: this.getInitials(s.student.user.name),
            admissionNumber: s.student.admissionNumber,
          },
          assignment: {
            id: s.assignment.id,
            title: s.assignment.title,
            dueDate: s.assignment.dueDate,
            maxMarks: s.assignment.maxMarks,
          },
          submittedAt: s.submittedAt,
          timeAgo: this.getTimeAgo(s.submittedAt),
          priority: this.calculateSubmissionPriority(s.submittedAt),
          daysWaiting: this.getDaysSince(s.submittedAt),
        })),
        totalCount: allPendingCount,
        avgGradingTime: this.calculateAvgGradingTime(submissions),
        oldestSubmission: oldestSubmission
          ? this.getTimeAgo(oldestSubmission.submittedAt)
          : null,
      },
    }
  }

  /**
   * Get students who are at risk and need attention
   */
  async getStudentsAtRisk(userUuid: string, limit: number = 20) {
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    // Get all students in teacher's classes
    const classSections = await this.prisma.classSection.findMany({
      where: { teacherId: teacher.id, status: 'ACTIVE' },
      select: { id: true },
    })

    const sectionIds = classSections.map(cs => cs.id)

    if (sectionIds.length === 0) {
      return {
        success: true,
        data: {
          students: [],
          totalCount: 0,
          summary: { high: 0, medium: 0, low: 0 },
          lastUpdated: new Date().toISOString(),
        },
      }
    }

    // Get students with their activity data
    const students = await this.prisma.student.findMany({
      where: {
        attendance: {
          some: {
            sectionId: { in: sectionIds },
          },
        },
        status: 'ACTIVE',
      },
      select: {
        id: true,
        admissionNumber: true,
        user: {
          select: {
            name: true,
            uuid: true,
            lastLogin: true,
          },
        },
        submissions: {
          where: {
            assignment: { teacherId: teacher.id },
          },
          select: {
            id: true,
            status: true,
            assignment: {
              select: { dueDate: true },
            },
          },
        },
        attendance: {
          where: {
            sectionId: { in: sectionIds },
            date: {
              gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // Last 30 days
            },
          },
          select: {
            status: true,
          },
        },
        examResults: {
          where: {
            exam: { createdBy: teacher.id },
          },
          orderBy: { createdAt: 'desc' },
          take: 5,
          select: {
            marksObtained: true,
            exam: {
              select: { totalMarks: true },
            },
          },
        },
      },
      take: 100, // Analyze up to 100 students
    })

    // Analyze each student for risk
    const atRiskStudents = students
      .map(student => {
        const analysis = this.analyzeStudentRisk(student, teacher.id)
        if (analysis.riskLevel === 'none') return null

        return {
          id: student.id,
          name: student.user.name,
          uuid: student.user.uuid,
          avatar: this.getInitials(student.user.name),
          admissionNumber: student.admissionNumber,
          riskLevel: analysis.riskLevel,
          riskScore: analysis.riskScore,
          reasons: analysis.reasons,
          suggestedActions: this.getSuggestedActions(analysis),
          stats: {
            missingAssignments: analysis.missingAssignments,
            attendanceRate: analysis.attendanceRate,
            lastActive: this.getTimeAgo(student.user.lastLogin),
            daysSinceLogin: this.getDaysSince(student.user.lastLogin),
            currentGrade: analysis.currentGrade,
            currentPercentage: analysis.currentPercentage,
          },
        }
      })
      .filter(s => s !== null)
      .sort((a, b) => b.riskScore - a.riskScore)
      .slice(0, limit)

    // Calculate summary
    const summary = {
      high: atRiskStudents.filter(s => s.riskLevel === 'high').length,
      medium: atRiskStudents.filter(s => s.riskLevel === 'medium').length,
      low: atRiskStudents.filter(s => s.riskLevel === 'low').length,
    }

    return {
      success: true,
      data: {
        students: atRiskStudents,
        totalCount: atRiskStudents.length,
        summary,
        lastUpdated: new Date().toISOString(),
      },
    }
  }

  // ==================== Helper Methods ====================

  private getInitials(name: string): string {
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase()
      .substring(0, 2)
  }

  private getTimeAgo(date: Date | null): string {
    if (!date) return 'Never'

    const seconds = Math.floor((Date.now() - date.getTime()) / 1000)

    if (seconds < 60) return 'Just now'
    if (seconds < 3600) return `${Math.floor(seconds / 60)} mins ago`
    if (seconds < 86400) return `${Math.floor(seconds / 3600)} hours ago`
    if (seconds < 604800) return `${Math.floor(seconds / 86400)} days ago`
    return `${Math.floor(seconds / 604800)} weeks ago`
  }

  private getDaysSince(date: Date | null): number {
    if (!date) return 999
    return Math.floor((Date.now() - date.getTime()) / (1000 * 60 * 60 * 24))
  }

  private calculateSubmissionPriority(
    submittedAt: Date
  ): 'high' | 'medium' | 'low' {
    const daysWaiting = this.getDaysSince(submittedAt)
    if (daysWaiting >= 3) return 'high'
    if (daysWaiting >= 1) return 'medium'
    return 'low'
  }

  private calculateAvgGradingTime(
    submissions: Array<{ submittedAt: Date | null }>
  ): string {
    if (submissions.length === 0) return 'N/A'

    const totalDays = submissions.reduce(
      (sum, s) => sum + (s.submittedAt ? this.getDaysSince(s.submittedAt) : 0),
      0
    )
    const avgDays = Math.floor(totalDays / submissions.length)

    if (avgDays === 0) return 'Less than 1 day'
    if (avgDays === 1) return '1 day'
    return `${avgDays} days`
  }

  private analyzeStudentRisk(
    student: {
      id: number
      name?: string
      user?: { lastLogin: Date | null }
      missingAssignments?: number
      attendancePercentage?: number
      lastActivityDate?: Date | null
      attendance?: Array<{ status: string }>
      submissions?: Array<unknown>
      examResults: Array<{
        exam: { totalMarks: number | Prisma.Decimal }
        marksObtained: number | Prisma.Decimal
      }>
    },
    _teacherId: number
  ) {
    const reasons: string[] = []
    let riskScore = 0

    // Check missing assignments
    const totalAssignments = 10 // TODO: Get actual count from DB
    const submittedCount =
      student.submissions?.filter(
        (s: { status?: string }) =>
          s.status === 'SUBMITTED' || s.status === 'GRADED'
      ).length || 0
    const missingAssignments = Math.max(0, totalAssignments - submittedCount)

    if (missingAssignments >= 3) {
      reasons.push(`Missing ${missingAssignments} assignments`)
      riskScore += 30
    } else if (missingAssignments >= 1) {
      reasons.push(
        `Missing ${missingAssignments} assignment${missingAssignments > 1 ? 's' : ''}`
      )
      riskScore += 15
    }

    // Check attendance
    const totalAttendance = student.attendance?.length || 0
    const presentCount =
      student.attendance?.filter(
        a => a.status === 'PRESENT' || a.status === 'LATE'
      ).length || 0
    const attendanceRate =
      totalAttendance > 0
        ? Math.round((presentCount / totalAttendance) * 100)
        : 100

    if (attendanceRate < 70) {
      reasons.push(`Low attendance: ${attendanceRate}%`)
      riskScore += 25
    } else if (attendanceRate < 85) {
      reasons.push(`Below average attendance: ${attendanceRate}%`)
      riskScore += 10
    }

    // Check last activity
    const daysSinceLogin = this.getDaysSince(student.user?.lastLogin || null)
    if (daysSinceLogin > 7) {
      reasons.push(`Inactive for ${daysSinceLogin} days`)
      riskScore += 20
    } else if (daysSinceLogin > 3) {
      reasons.push(`Last login: ${daysSinceLogin} days ago`)
      riskScore += 10
    }

    // Calculate current grade
    const examResults = student.examResults
    let currentPercentage = 0
    let currentGrade = 'N/A'

    if (examResults.length > 0) {
      const totalMarks = examResults.reduce(
        (sum: number, r) => sum + Number(r.exam.totalMarks),
        0
      )
      const obtainedMarks = examResults.reduce(
        (sum: number, r) => sum + Number(r.marksObtained),
        0
      )
      currentPercentage =
        totalMarks > 0 ? Math.round((obtainedMarks / totalMarks) * 100) : 0
      currentGrade = this.getGradeFromPercentage(currentPercentage)

      if (currentPercentage < 60) {
        reasons.push(`Low performance: ${currentPercentage}%`)
        riskScore += 25
      }
    }

    // Determine risk level
    let riskLevel: 'high' | 'medium' | 'low' | 'none' = 'none'
    if (riskScore >= 50) riskLevel = 'high'
    else if (riskScore >= 25) riskLevel = 'medium'
    else if (riskScore > 0) riskLevel = 'low'

    return {
      riskLevel,
      riskScore,
      reasons,
      missingAssignments,
      attendanceRate,
      currentGrade,
      currentPercentage,
    }
  }

  /**
   * Convert percentage to letter grade
   * Grading Scale: A+ (93+), A (85-92), B+ (77-84), B (70-76), C (60-69), D (<60)
   */
  private getGradeFromPercentage(percentage: number): string {
    if (percentage >= 93) return 'A+'
    if (percentage >= 85) return 'A'
    if (percentage >= 77) return 'B+'
    if (percentage >= 70) return 'B'
    if (percentage >= 60) return 'C'
    return 'D'
  }

  private getSuggestedActions(analysis: {
    riskLevel: string
    reasons: string[]
    missingAssignments?: number
    attendanceRate?: number
    currentPercentage?: number
  }) {
    const actions: Array<{
      type: string
      label: string
      action: string
      priority: number
    }> = []

    if (analysis.riskLevel === 'high') {
      actions.push({
        type: 'meeting',
        label: 'Schedule urgent 1-on-1 meeting',
        action: 'schedule_meeting',
        priority: 1,
      })
      actions.push({
        type: 'message',
        label: 'Send intervention message',
        action: 'send_message',
        priority: 2,
      })
    }

    if (analysis.missingAssignments > 0) {
      actions.push({
        type: 'extension',
        label: 'Offer deadline extension',
        action: 'extend_deadline',
        priority: 3,
      })
    }

    if (analysis.attendanceRate < 85) {
      actions.push({
        type: 'message',
        label: 'Send attendance reminder',
        action: 'send_attendance_reminder',
        priority: 4,
      })
    }

    if (analysis.currentPercentage < 70) {
      actions.push({
        type: 'resources',
        label: 'Share learning resources',
        action: 'share_resources',
        priority: 5,
      })
      actions.push({
        type: 'mentor',
        label: 'Assign peer mentor',
        action: 'assign_mentor',
        priority: 6,
      })
    }

    return actions.slice(0, 3) // Return top 3 actions
  }

  // ============================================================================
  // ATTENDANCE MANAGEMENT
  // ============================================================================

  /**
   * Mark attendance for a single student
   */
  async markAttendance(
    userUuid: string,
    markAttendanceDto: {
      studentId: number
      sectionId: number
      date: string
      status: string
      remarks?: string
    }
  ) {
    // Find teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    // Verify the section belongs to this teacher
    const section = await this.prisma.classSection.findFirst({
      where: {
        id: markAttendanceDto.sectionId,
        teacherId: teacher.id,
      },
    })

    if (!section) {
      throw new ForbiddenException(
        'You do not have permission to mark attendance for this section'
      )
    }

    // Verify the student is enrolled in the course for this section
    const enrollment = await this.prisma.enrollment.findFirst({
      where: {
        studentId: markAttendanceDto.studentId,
        subjectId: section.subjectId,
        semesterId: section.semesterId,
        enrollmentStatus: 'ENROLLED',
      },
    })

    if (!enrollment) {
      throw new NotFoundException(
        'Student is not enrolled in this course/section'
      )
    }

    // Parse date string and create UTC date at midnight
    const [year, month, day] = markAttendanceDto.date.split('-').map(Number)
    const attendanceDate = new Date(Date.UTC(year, month - 1, day, 0, 0, 0, 0))

    // Check if attendance already exists for this student on this date
    // Using exact date match since Prisma @db.Date only stores date portion
    const existingAttendance = await this.prisma.attendance.findFirst({
      where: {
        studentId: markAttendanceDto.studentId,
        sectionId: markAttendanceDto.sectionId,
        date: attendanceDate,
      },
    })

    if (existingAttendance) {
      // Update existing attendance
      const updatedAttendance = await this.prisma.attendance.update({
        where: { id: existingAttendance.id },
        data: {
          status: markAttendanceDto.status as
            | 'PRESENT'
            | 'ABSENT'
            | 'LATE'
            | 'EXCUSED',
          remarks: markAttendanceDto.remarks,
        },
        include: {
          student: {
            include: {
              user: {
                select: {
                  name: true,
                  email: true,
                },
              },
            },
          },
          section: {
            include: {
              subject: {
                select: {
                  subjectName: true,
                  subjectCode: true,
                },
              },
            },
          },
        },
      })

      // Trigger progress recalculation (async, non-blocking)
      await this.triggerProgressRecalculation(
        markAttendanceDto.studentId,
        section.subjectId,
        section.semesterId,
        'attendance_update'
      )

      return {
        success: true,
        message: 'Attendance updated successfully',
        data: updatedAttendance,
      }
    }

    // Create new attendance record
    const attendance = await this.prisma.attendance.create({
      data: {
        studentId: markAttendanceDto.studentId,
        sectionId: markAttendanceDto.sectionId,
        date: attendanceDate,
        status: markAttendanceDto.status as
          | 'PRESENT'
          | 'ABSENT'
          | 'LATE'
          | 'EXCUSED',
        remarks: markAttendanceDto.remarks,
        markedBy: teacher.id,
      },
      include: {
        student: {
          include: {
            user: {
              select: {
                name: true,
                email: true,
              },
            },
          },
        },
        section: {
          include: {
            subject: {
              select: {
                subjectName: true,
                subjectCode: true,
              },
            },
          },
        },
      },
    })

    // Trigger progress recalculation (async, non-blocking)
    await this.triggerProgressRecalculation(
      markAttendanceDto.studentId,
      section.subjectId,
      section.semesterId,
      'attendance_create'
    )

    return {
      success: true,
      message: 'Attendance marked successfully',
      data: attendance,
    }
  }

  /**
   * Bulk mark attendance for multiple students in a section
   */
  async bulkMarkAttendance(
    userUuid: string,
    bulkMarkAttendanceDto: {
      sectionId: number
      date: string
      attendanceRecords: Array<{
        studentId: number
        status: string
        remarks?: string
      }>
    }
  ) {
    // Find teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    // Verify the section belongs to this teacher
    const section = await this.prisma.classSection.findFirst({
      where: {
        id: bulkMarkAttendanceDto.sectionId,
        teacherId: teacher.id,
      },
      include: {
        subject: {
          select: {
            subjectName: true,
            subjectCode: true,
          },
        },
      },
    })

    if (!section) {
      throw new ForbiddenException(
        'You do not have permission to mark attendance for this section'
      )
    }

    // Parse date string and create UTC date at midnight
    const [year, month, day] = bulkMarkAttendanceDto.date.split('-').map(Number)
    const attendanceDate = new Date(Date.UTC(year, month - 1, day, 0, 0, 0, 0))

    const results = []
    const errors = []

    // Process each attendance record
    for (const record of bulkMarkAttendanceDto.attendanceRecords) {
      try {
        // Verify the student is enrolled in the course for this section
        const enrollment = await this.prisma.enrollment.findFirst({
          where: {
            studentId: record.studentId,
            subjectId: section.subjectId,
            semesterId: section.semesterId,
            enrollmentStatus: 'ENROLLED',
          },
        })

        if (!enrollment) {
          errors.push({
            studentId: record.studentId,
            error: 'Student is not enrolled in this course/section',
          })
          continue
        }

        // Check if attendance already exists
        // Using exact date match since Prisma @db.Date only stores date portion
        const existingAttendance = await this.prisma.attendance.findFirst({
          where: {
            studentId: record.studentId,
            sectionId: bulkMarkAttendanceDto.sectionId,
            date: attendanceDate,
          },
        })

        if (existingAttendance) {
          // Update existing attendance
          const updated = await this.prisma.attendance.update({
            where: { id: existingAttendance.id },
            data: {
              status: record.status as
                | 'PRESENT'
                | 'ABSENT'
                | 'LATE'
                | 'EXCUSED',
              remarks: record.remarks,
            },
            include: {
              student: {
                include: {
                  user: {
                    select: {
                      name: true,
                    },
                  },
                },
              },
            },
          })
          results.push(updated)
        } else {
          // Create new attendance record
          const created = await this.prisma.attendance.create({
            data: {
              studentId: record.studentId,
              sectionId: bulkMarkAttendanceDto.sectionId,
              date: attendanceDate,
              status: record.status as
                | 'PRESENT'
                | 'ABSENT'
                | 'LATE'
                | 'EXCUSED',
              remarks: record.remarks,
              markedBy: teacher.id,
            },
            include: {
              student: {
                include: {
                  user: {
                    select: {
                      name: true,
                    },
                  },
                },
              },
            },
          })
          results.push(created)
        }
      } catch (error) {
        errors.push({
          studentId: record.studentId,
          error: error.message,
        })
      }
    }

    return {
      success: true,
      message: `Attendance marked for ${results.length} student(s)`,
      data: {
        section: {
          id: section.id,
          sectionName: section.sectionName,
          course: section.subject,
        },
        date: bulkMarkAttendanceDto.date,
        totalRecords: bulkMarkAttendanceDto.attendanceRecords.length,
        successCount: results.length,
        errorCount: errors.length,
        results,
        errors: errors.length > 0 ? errors : undefined,
      },
    }
  }

  /**
   * Update an existing attendance record
   */
  async updateAttendance(
    userUuid: string,
    attendanceId: number,
    updateAttendanceDto: {
      status?: string
      remarks?: string
    }
  ) {
    // Find teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    // Find the attendance record
    const attendance = await this.prisma.attendance.findUnique({
      where: { id: attendanceId },
      include: {
        section: true,
      },
    })

    if (!attendance) {
      throw new NotFoundException(
        `Attendance record with ID ${attendanceId} not found`
      )
    }

    // Verify the section belongs to this teacher
    if (attendance.section.teacherId !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to update this attendance record'
      )
    }

    // Update the attendance record
    const updatedAttendance = await this.prisma.attendance.update({
      where: { id: attendanceId },
      data: {
        ...(updateAttendanceDto.status && {
          status: updateAttendanceDto.status as
            | 'PRESENT'
            | 'ABSENT'
            | 'LATE'
            | 'EXCUSED',
        }),
        ...(updateAttendanceDto.remarks !== undefined && {
          remarks: updateAttendanceDto.remarks,
        }),
      },
      include: {
        student: {
          include: {
            user: {
              select: {
                name: true,
                email: true,
              },
            },
          },
        },
        section: {
          include: {
            subject: {
              select: {
                subjectName: true,
                subjectCode: true,
              },
            },
          },
        },
      },
    })

    return {
      success: true,
      message: 'Attendance updated successfully',
      data: updatedAttendance,
    }
  }

  /**
   * Delete an attendance record
   */
  async deleteAttendance(userUuid: string, attendanceId: number) {
    // Find teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    // Find the attendance record
    const attendance = await this.prisma.attendance.findUnique({
      where: { id: attendanceId },
      include: {
        section: true,
      },
    })

    if (!attendance) {
      throw new NotFoundException(
        `Attendance record with ID ${attendanceId} not found`
      )
    }

    // Verify the section belongs to this teacher
    if (attendance.section.teacherId !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to delete this attendance record'
      )
    }

    // Delete the attendance record
    await this.prisma.attendance.delete({
      where: { id: attendanceId },
    })

    return {
      success: true,
      message: 'Attendance record deleted successfully',
    }
  }

  // ============================================================================
  // EXAM RESULT MANAGEMENT
  // ============================================================================

  /**
   * Enter or update exam result for a single student
   */
  async enterExamResult(
    userUuid: string,
    examId: number,
    enterExamResultDto: {
      studentId: number
      marksObtained?: number
      isAbsent?: boolean
      remarks?: string
    }
  ) {
    // Find teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    // Find the examination and verify teacher created it
    const examination = await this.prisma.examination.findUnique({
      where: { id: examId },
    })

    if (!examination) {
      throw new NotFoundException(`Examination with ID ${examId} not found`)
    }

    if (examination.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to enter results for this examination'
      )
    }

    // Verify student is enrolled in the course
    const enrollment = await this.prisma.enrollment.findFirst({
      where: {
        studentId: enterExamResultDto.studentId,
        subjectId: examination.subjectId,
        semesterId: examination.semesterId,
        enrollmentStatus: 'ENROLLED',
      },
    })

    if (!enrollment) {
      throw new NotFoundException(
        'Student is not enrolled in this course/semester'
      )
    }

    // Validate marks if provided
    if (
      enterExamResultDto.marksObtained !== undefined &&
      enterExamResultDto.marksObtained > examination.totalMarks
    ) {
      throw new BadRequestException(
        `Marks obtained (${enterExamResultDto.marksObtained}) cannot exceed total marks (${examination.totalMarks})`
      )
    }

    // Calculate grade if marks are provided and student is not absent
    let grade: string | null = null
    if (
      enterExamResultDto.marksObtained !== undefined &&
      !enterExamResultDto.isAbsent
    ) {
      const percentage =
        (enterExamResultDto.marksObtained / examination.totalMarks) * 100
      grade = this.getGradeFromPercentage(percentage)
    }

    // Check if result already exists
    const existingResult = await this.prisma.examResult.findUnique({
      where: {
        unique_result: {
          examId: examId,
          studentId: enterExamResultDto.studentId,
        },
      },
    })

    if (existingResult) {
      // Update existing result
      const updatedResult = await this.prisma.examResult.update({
        where: { id: existingResult.id },
        data: {
          marksObtained: enterExamResultDto.marksObtained,
          grade: grade,
          isAbsent: enterExamResultDto.isAbsent ?? false,
          remarks: enterExamResultDto.remarks,
          evaluatedBy: teacher.id,
          evaluatedAt: new Date(),
        },
        include: {
          student: {
            include: {
              user: {
                select: {
                  name: true,
                  email: true,
                },
              },
            },
          },
          exam: {
            select: {
              examName: true,
              totalMarks: true,
              passingMarks: true,
            },
          },
        },
      })

      return {
        success: true,
        message: 'Exam result updated successfully',
        data: updatedResult,
      }
    }

    // Create new result
    const result = await this.prisma.examResult.create({
      data: {
        examId: examId,
        studentId: enterExamResultDto.studentId,
        marksObtained: enterExamResultDto.marksObtained,
        grade: grade,
        isAbsent: enterExamResultDto.isAbsent ?? false,
        remarks: enterExamResultDto.remarks,
        evaluatedBy: teacher.id,
        evaluatedAt: new Date(),
      },
      include: {
        student: {
          include: {
            user: {
              select: {
                name: true,
                email: true,
              },
            },
          },
        },
        exam: {
          select: {
            examName: true,
            totalMarks: true,
            passingMarks: true,
          },
        },
      },
    })

    return {
      success: true,
      message: 'Exam result entered successfully',
      data: result,
    }
  }

  /**
   * Bulk enter exam results for multiple students
   */
  async bulkEnterExamResults(
    userUuid: string,
    examId: number,
    bulkEnterExamResultDto: {
      results: Array<{
        studentId: number
        marksObtained?: number
        isAbsent?: boolean
        remarks?: string
      }>
    }
  ) {
    // Find teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    // Find the examination and verify teacher created it
    const examination = await this.prisma.examination.findUnique({
      where: { id: examId },
    })

    if (!examination) {
      throw new NotFoundException(`Examination with ID ${examId} not found`)
    }

    if (examination.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to enter results for this examination'
      )
    }

    const results = []
    const errors = []

    // Process each result
    for (const resultDto of bulkEnterExamResultDto.results) {
      try {
        // Verify student is enrolled in the course
        const enrollment = await this.prisma.enrollment.findFirst({
          where: {
            studentId: resultDto.studentId,
            subjectId: examination.subjectId,
            semesterId: examination.semesterId,
            enrollmentStatus: 'ENROLLED',
          },
        })

        if (!enrollment) {
          errors.push({
            studentId: resultDto.studentId,
            error: 'Student is not enrolled in this course/semester',
          })
          continue
        }

        // Validate marks if provided
        if (
          resultDto.marksObtained !== undefined &&
          resultDto.marksObtained > examination.totalMarks
        ) {
          errors.push({
            studentId: resultDto.studentId,
            error: `Marks obtained (${resultDto.marksObtained}) cannot exceed total marks (${examination.totalMarks})`,
          })
          continue
        }

        // Calculate grade if marks are provided and student is not absent
        let grade: string | null = null
        if (resultDto.marksObtained !== undefined && !resultDto.isAbsent) {
          const percentage =
            (resultDto.marksObtained / examination.totalMarks) * 100
          grade = this.getGradeFromPercentage(percentage)
        }

        // Check if result already exists
        const existingResult = await this.prisma.examResult.findUnique({
          where: {
            unique_result: {
              examId: examId,
              studentId: resultDto.studentId,
            },
          },
        })

        if (existingResult) {
          // Update existing result
          const updated = await this.prisma.examResult.update({
            where: { id: existingResult.id },
            data: {
              marksObtained: resultDto.marksObtained,
              grade: grade,
              isAbsent: resultDto.isAbsent ?? false,
              remarks: resultDto.remarks,
              evaluatedBy: teacher.id,
              evaluatedAt: new Date(),
            },
            include: {
              student: {
                include: {
                  user: {
                    select: {
                      name: true,
                    },
                  },
                },
              },
            },
          })
          results.push(updated)

          // Trigger progress recalculation for updated result
          await this.triggerProgressRecalculation(
            resultDto.studentId,
            examination.subjectId,
            examination.semesterId,
            'exam_result_update'
          )
        } else {
          // Create new result
          const created = await this.prisma.examResult.create({
            data: {
              examId: examId,
              studentId: resultDto.studentId,
              marksObtained: resultDto.marksObtained,
              grade: grade,
              isAbsent: resultDto.isAbsent ?? false,
              remarks: resultDto.remarks,
              evaluatedBy: teacher.id,
              evaluatedAt: new Date(),
            },
            include: {
              student: {
                include: {
                  user: {
                    select: {
                      name: true,
                    },
                  },
                },
              },
            },
          })
          results.push(created)

          // Trigger progress recalculation for new result
          await this.triggerProgressRecalculation(
            resultDto.studentId,
            examination.subjectId,
            examination.semesterId,
            'exam_result_create'
          )
        }
      } catch (error) {
        errors.push({
          studentId: resultDto.studentId,
          error: error.message,
        })
      }
    }

    return {
      success: true,
      message: `Results entered for ${results.length} student(s)`,
      data: {
        examination: {
          id: examination.id,
          examName: examination.examName,
          totalMarks: examination.totalMarks,
        },
        totalRecords: bulkEnterExamResultDto.results.length,
        successCount: results.length,
        errorCount: errors.length,
        results,
        errors: errors.length > 0 ? errors : undefined,
      },
    }
  }

  /**
   * Get all results for an examination
   */
  async getExamResults(userUuid: string, examId: number) {
    // Find teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    // Find the examination and verify teacher created it
    const examination = await this.prisma.examination.findUnique({
      where: { id: examId },
      include: {
        subject: {
          select: {
            subjectName: true,
            subjectCode: true,
          },
        },
      },
    })

    if (!examination) {
      throw new NotFoundException(`Examination with ID ${examId} not found`)
    }

    if (examination.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to view results for this examination'
      )
    }

    // Get all results
    const results = await this.prisma.examResult.findMany({
      where: { examId: examId },
      include: {
        student: {
          include: {
            user: {
              select: {
                name: true,
                email: true,
              },
            },
          },
        },
        evaluator: {
          include: {
            user: {
              select: {
                name: true,
              },
            },
          },
        },
      },
      orderBy: [{ isAbsent: 'asc' }, { marksObtained: 'desc' }],
    })

    // Calculate statistics
    const totalStudents = results.length
    const evaluated = results.filter(
      r => r.marksObtained !== null || r.isAbsent
    ).length
    const pending = totalStudents - evaluated
    const absent = results.filter(r => r.isAbsent).length
    const present = totalStudents - absent

    let avgMarks = 0
    let highestMarks = 0
    let lowestMarks = examination.totalMarks
    let passed = 0

    const presentResults = results.filter(
      r => !r.isAbsent && r.marksObtained !== null
    )

    if (presentResults.length > 0) {
      const totalMarks = presentResults.reduce(
        (sum, r) => sum + (r.marksObtained?.toNumber() || 0),
        0
      )
      avgMarks = totalMarks / presentResults.length

      highestMarks = Math.max(
        ...presentResults.map(r => r.marksObtained?.toNumber() || 0)
      )
      lowestMarks = Math.min(
        ...presentResults.map(r => r.marksObtained?.toNumber() || 0)
      )

      if (examination.passingMarks) {
        passed = presentResults.filter(
          r =>
            r.marksObtained &&
            r.marksObtained.toNumber() >= examination.passingMarks!
        ).length
      }
    }

    return {
      success: true,
      data: {
        examination: {
          id: examination.id,
          examName: examination.examName,
          examType: examination.examType,
          examDate: examination.examDate,
          totalMarks: examination.totalMarks,
          passingMarks: examination.passingMarks,
          course: examination.subject,
        },
        statistics: {
          totalStudents,
          evaluated,
          pending,
          absent,
          present,
          avgMarks: Math.round(avgMarks * 100) / 100,
          highestMarks,
          lowestMarks: present > 0 ? lowestMarks : 0,
          passed,
          passPercentage:
            present > 0 ? Math.round((passed / present) * 100) : 0,
        },
        results: results.map(r => ({
          id: r.id,
          studentId: r.studentId,
          studentName: r.student.user.name,
          studentEmail: r.student.user.email,
          marksObtained: r.marksObtained?.toNumber() || null,
          grade: r.grade,
          isAbsent: r.isAbsent,
          remarks: r.remarks,
          evaluatedBy: r.evaluator?.user.name || null,
          evaluatedAt: r.evaluatedAt,
        })),
      },
    }
  }

  /**
   * Update an existing exam result
   */
  async updateExamResult(
    userUuid: string,
    examId: number,
    resultId: number,
    updateExamResultDto: {
      marksObtained?: number
      isAbsent?: boolean
      remarks?: string
    }
  ) {
    // Find teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    // Find the examination
    const examination = await this.prisma.examination.findUnique({
      where: { id: examId },
    })

    if (!examination) {
      throw new NotFoundException(`Examination with ID ${examId} not found`)
    }

    if (examination.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to update results for this examination'
      )
    }

    // Find the result
    const result = await this.prisma.examResult.findUnique({
      where: { id: resultId },
    })

    if (!result) {
      throw new NotFoundException(`Result with ID ${resultId} not found`)
    }

    if (result.examId !== examId) {
      throw new BadRequestException(
        'Result does not belong to this examination'
      )
    }

    // Validate marks if provided
    if (
      updateExamResultDto.marksObtained !== undefined &&
      updateExamResultDto.marksObtained > examination.totalMarks
    ) {
      throw new BadRequestException(
        `Marks obtained (${updateExamResultDto.marksObtained}) cannot exceed total marks (${examination.totalMarks})`
      )
    }

    // Calculate grade if marks are provided and student is not absent
    let grade: string | null = result.grade
    if (
      updateExamResultDto.marksObtained !== undefined &&
      !updateExamResultDto.isAbsent
    ) {
      const percentage =
        (updateExamResultDto.marksObtained / examination.totalMarks) * 100
      grade = this.getGradeFromPercentage(percentage)
    } else if (updateExamResultDto.isAbsent) {
      grade = null
    }

    // Update the result
    const updatedResult = await this.prisma.examResult.update({
      where: { id: resultId },
      data: {
        ...(updateExamResultDto.marksObtained !== undefined && {
          marksObtained: updateExamResultDto.marksObtained,
        }),
        ...(updateExamResultDto.isAbsent !== undefined && {
          isAbsent: updateExamResultDto.isAbsent,
        }),
        ...(updateExamResultDto.remarks !== undefined && {
          remarks: updateExamResultDto.remarks,
        }),
        grade: grade,
        evaluatedBy: teacher.id,
        evaluatedAt: new Date(),
      },
      include: {
        student: {
          include: {
            user: {
              select: {
                name: true,
                email: true,
              },
            },
          },
        },
        exam: {
          select: {
            examName: true,
            totalMarks: true,
            passingMarks: true,
          },
        },
      },
    })

    return {
      success: true,
      message: 'Exam result updated successfully',
      data: updatedResult,
    }
  }

  /**
   * Delete an exam result
   */
  async deleteExamResult(userUuid: string, examId: number, resultId: number) {
    // Find teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: { user: { uuid: userUuid } },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${userUuid} not found`)
    }

    // Find the examination
    const examination = await this.prisma.examination.findUnique({
      where: { id: examId },
    })

    if (!examination) {
      throw new NotFoundException(`Examination with ID ${examId} not found`)
    }

    if (examination.createdBy !== teacher.id) {
      throw new ForbiddenException(
        'You do not have permission to delete results for this examination'
      )
    }

    // Find the result
    const result = await this.prisma.examResult.findUnique({
      where: { id: resultId },
    })

    if (!result) {
      throw new NotFoundException(`Result with ID ${resultId} not found`)
    }

    if (result.examId !== examId) {
      throw new BadRequestException(
        'Result does not belong to this examination'
      )
    }

    // Delete the result
    await this.prisma.examResult.delete({
      where: { id: resultId },
    })

    return {
      success: true,
      message: 'Exam result deleted successfully',
    }
  }

  /**
   * Helper method to trigger progress recalculation
   * Emits an event that will be handled asynchronously
   */
  private async triggerProgressRecalculation(
    studentId: number,
    subjectId: number,
    semesterId: number,
    trigger: string
  ): Promise<void> {
    try {
      // Get academic year for this semester
      const semester = await this.prisma.semester.findUnique({
        where: { id: semesterId },
        select: { academicYearId: true },
      })

      if (!semester) {
        return
      }

      // Trigger recalculation for the subject
      this.eventEmitter.emit('progress.recalculate', {
        studentId,
        subjectId,
        semesterId,
        academicYearId: semester.academicYearId,
        trigger,
      })
    } catch (error) {
      // Log error but don't throw - this is a background operation
      console.error('Failed to trigger progress recalculation:', error)
    }
  }
}
