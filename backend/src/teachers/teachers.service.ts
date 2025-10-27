import { Prisma } from '.prisma/client'
import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'
import * as bcrypt from 'bcrypt'
import { PrismaService } from '../prisma/prisma.service'
import {
  TeacherAttendanceSummary,
  TeacherDashboardStats,
  TeacherStudentActivity,
} from '../types/teacher.types'
import {
  AssignSubjectsDto,
  CreateTeacherDto,
  TeacherQueryDto,
  UpdateTeacherDto,
} from './dto/teacher.dto'

@Injectable()
export class TeachersService {
  constructor(private prisma: PrismaService) {}

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
            name: true,
            email: true,
            phone: true,
            status: true,
          },
        },
        institution: true,
        classSections: {
          include: {
            course: {
              select: {
                id: true,
                courseName: true,
                courseCode: true,
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
        course: {
          select: {
            id: true,
            courseName: true,
            courseCode: true,
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
        course: {
          courseName: 'asc',
        },
      },
    })

    return classes
  }

  async getTeacherStats(teacherId: number) {
    const [
      totalClasses,
      totalStudents,
      currentSemesterClasses,
      recentAssignments,
      upcomingExaminations,
    ] = await Promise.all([
      this.prisma.classSection.count({
        where: { teacherId },
      }),
      this.prisma.classSection.aggregate({
        where: { teacherId },
        _sum: { currentEnrollment: true },
      }),
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
      totalClasses,
      totalStudents: totalStudents._sum.currentEnrollment || 0,
      currentSemesterClasses,
      recentAssignments,
      upcomingExaminations,
    }
  }

  async getDashboardStats(teacherId: number): Promise<TeacherDashboardStats> {
    // Check if teacher exists
    const teacher = await this.prisma.teacher.findUnique({
      where: { id: teacherId },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with ID ${teacherId} not found`)
    }

    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const tomorrow = new Date(today)
    tomorrow.setDate(tomorrow.getDate() + 1)

    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1)
    const endOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0)

    const [totalStudents, todayAttendance, monthlyAttendanceStats] =
      await Promise.all([
        // Get total students across all teacher's active classes
        this.prisma.classSection.aggregate({
          where: {
            teacherId,
            status: 'ACTIVE',
          },
          _sum: { currentEnrollment: true },
        }),

        // Today's attendance for teacher's classes
        this.prisma.attendance.groupBy({
          by: ['status'],
          where: {
            section: {
              teacherId,
              status: 'ACTIVE',
            },
            date: {
              gte: today,
              lt: tomorrow,
            },
          },
          _count: {
            status: true,
          },
        }),

        // Monthly attendance statistics
        this.prisma.attendance.findMany({
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
          select: {
            status: true,
          },
        }),
      ])

    // Calculate attendance statistics
    const totalStudentsCount = totalStudents._sum.currentEnrollment || 0
    const presentToday =
      todayAttendance.find(a => a.status === 'PRESENT')?._count.status || 0
    const absentToday =
      todayAttendance.find(a => a.status === 'ABSENT')?._count.status || 0
    const lateToday =
      todayAttendance.find(a => a.status === 'LATE')?._count.status || 0

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

          // Assign letter grade
          if (averagePercentage >= 90) averageGrade = 'A'
          else if (averagePercentage >= 80) averageGrade = 'A-'
          else if (averagePercentage >= 75) averageGrade = 'B+'
          else if (averagePercentage >= 70) averageGrade = 'B'
          else if (averagePercentage >= 65) averageGrade = 'B-'
          else if (averagePercentage >= 60) averageGrade = 'C+'
          else if (averagePercentage >= 55) averageGrade = 'C'
          else if (averagePercentage >= 50) averageGrade = 'D'
          else averageGrade = 'F'
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
            course: {
              select: {
                courseName: true,
                courseCode: true,
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
        course: {
          name: record.section.course.courseName,
          code: record.section.course.courseCode,
        },
        remarks: record.remarks,
      })),
    }
  }
}
