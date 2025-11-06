import { Prisma } from '.prisma/client'
import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'
import * as bcrypt from 'bcrypt'
import { PrismaService } from '../prisma/prisma.service'
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

  async getTeacherStatsByUuid(uuid: string) {
    // First find the teacher by UUID
    const teacher = await this.prisma.teacher.findFirst({
      where: {
        user: { uuid },
      },
    })

    if (!teacher) {
      throw new NotFoundException(`Teacher with UUID ${uuid} not found`)
    }

    // Use the existing getTeacherStats method with the found teacher ID
    return this.getTeacherStats(teacher.id)
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
    // Get basic dashboard stats (existing method)
    const basicStats = await this.getDashboardStats(teacherId)

    // Get additional metrics
    const [
      subjectCount,
      subjectPerformanceSummary,
      gradeDistSummary,
      weeklyPreview,
    ] = await Promise.all([
      this.getTeacherSubjectCount(teacherId),
      this.getSubjectPerformanceSummary(teacherId),
      this.getGradeDistributionSummary(teacherId),
      this.getWeeklyAttendancePreview(teacherId),
    ])

    return {
      ...basicStats,
      totalSubjects: subjectCount,
      overallClassAverage: subjectPerformanceSummary.overallAverage,
      studentsAtRisk: subjectPerformanceSummary.studentsAtRisk,
      tabSummaries: {
        attendanceTrends: {
          weeklyAverage: Math.round(basicStats.avgAttendanceThisMonth),
          trend: await this.getAttendanceTrend(teacherId),
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
    const teacher = await this.findByUuid(uuid)
    return this.getEnhancedDashboardStats(teacher.id)
  }

  // ============================================================================
  // ATTENDANCE TRENDS - DETAILED DATA
  // ============================================================================

  /**
   * Get detailed attendance trends data for the Attendance Trends tab
   */
  async getAttendanceTrends(teacherId: number): Promise<AttendanceTrendsData> {
    const today = new Date()
    const startOfWeek = new Date(today)
    startOfWeek.setDate(today.getDate() - today.getDay()) // Start of current week
    startOfWeek.setHours(0, 0, 0, 0)

    const endOfWeek = new Date(startOfWeek)
    endOfWeek.setDate(startOfWeek.getDate() + 6)
    endOfWeek.setHours(23, 59, 59, 999)

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
    const today = new Date()
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1)
    const endOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0)

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
    const today = new Date()
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1)
    const endOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0)

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
          name: ts.subject.name,
          code: ts.subject.code,
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
          subjectName: records[0].subject.name,
          gradeDistribution: subjectGrades,
          averageGrade,
          medianGrade: averageGrade, // Simplified
        }
      }
    )

    // Top performers
    const topPerformers = studentProgress
      .filter(
        sp => sp.overallGrade && ['A+', 'A', 'A-'].includes(sp.overallGrade)
      )
      .slice(0, 10)
      .map(sp => ({
        studentId: sp.student.user.uuid!,
        studentName: `${sp.student.user.firstName} ${sp.student.user.lastName}`,
        overallGrade: sp.overallGrade!,
        subjectGrades: { [sp.subject.name]: sp.overallGrade! },
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
          name: ts.subject.name,
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
    const today = new Date()
    const startOfWeek = new Date(today)
    startOfWeek.setDate(today.getDate() - today.getDay())
    startOfWeek.setHours(0, 0, 0, 0)

    const endOfWeek = new Date(startOfWeek)
    endOfWeek.setDate(startOfWeek.getDate() + 6)

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
    const today = new Date()
    const thisMonth = new Date(today.getFullYear(), today.getMonth(), 1)
    const lastMonth = new Date(today.getFullYear(), today.getMonth() - 1, 1)
    const lastMonthEnd = new Date(today.getFullYear(), today.getMonth(), 0)

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

    // Verify course exists
    const course = await this.prisma.course.findUnique({
      where: { id: createAssignmentDto.courseId },
    })

    if (!course) {
      throw new NotFoundException(
        `Course with ID ${createAssignmentDto.courseId} not found`
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
        status: (status as any) || 'DRAFT',
      },
      include: {
        course: { select: { courseName: true, courseCode: true } },
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
      where.status = status as any
    }

    if (courseId) {
      where.courseId = courseId
    }

    const assignments = await this.prisma.assignment.findMany({
      where,
      include: {
        course: { select: { courseName: true, courseCode: true } },
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
        course: { select: { courseName: true, courseCode: true } },
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
    const updateData: any = { ...updateRest }

    if (dueDateStr) {
      updateData.dueDate = new Date(dueDateStr)
    }

    if (status) {
      updateData.status = status
    }

    const updatedAssignment = await this.prisma.assignment.update({
      where: { id: assignmentId },
      data: updateData,
      include: {
        course: { select: { courseName: true, courseCode: true } },
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

    // Verify course exists
    const course = await this.prisma.course.findUnique({
      where: { id: createExaminationDto.courseId },
    })

    if (!course) {
      throw new NotFoundException(
        `Course with ID ${createExaminationDto.courseId} not found`
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

    const { examDate, startTime, examType, status, ...examinationRest } =
      createExaminationDto

    const examinationData: any = {
      ...examinationRest,
      courseId: createExaminationDto.courseId,
      semesterId: createExaminationDto.semesterId,
      createdBy: teacher.id,
      examDate: new Date(examDate),
      examType: examType,
      status: status || 'SCHEDULED',
      startTime: startTime ? new Date(`2024-01-01T${startTime}`) : undefined,
    }

    const examination = await this.prisma.examination.create({
      data: examinationData,
      include: {
        course: { select: { courseName: true, courseCode: true } },
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
      where.status = status as any
    }

    if (courseId) {
      where.courseId = courseId
    }

    const examinations = await this.prisma.examination.findMany({
      where,
      include: {
        course: { select: { courseName: true, courseCode: true } },
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
        course: { select: { courseName: true, courseCode: true } },
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

    const { examDate, startTime, ...updateRest } = updateExaminationDto
    const updateData: any = { ...updateRest }

    if (examDate) {
      updateData.examDate = new Date(examDate)
    }

    if (startTime) {
      updateData.startTime = new Date(`2024-01-01T${startTime}`)
    }

    const updatedExamination = await this.prisma.examination.update({
      where: { id: examinationId },
      data: updateData,
      include: {
        course: { select: { courseName: true, courseCode: true } },
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
}
