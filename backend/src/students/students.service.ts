import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'
import { Prisma } from '@prisma/client'
import * as bcrypt from 'bcrypt'
import { PrismaService } from '../prisma/prisma.service'
import { UserWithRelations } from '../types/auth.types'
import {
  StudentAssignmentsResponse,
  StudentAttendanceHistoryResponse,
  StudentDashboardStatsResponse,
  StudentPerformanceTrendsResponse,
  StudentSubjectPerformanceResponse,
  StudentUpcomingEventsResponse,
} from '../types/student.types'
import {
  CreateStudentDto,
  PaginationDto,
  UpdateStudentDto,
} from './dto/student.dto'

@Injectable()
export class StudentsService {
  constructor(private prisma: PrismaService) {}

  async findAll(paginationDto: PaginationDto, _currentUser: UserWithRelations) {
    const {
      page = 1,
      limit = 10,
      sortBy = 'createdAt',
      sortOrder = 'desc',
      search,
    } = paginationDto

    const skip = (page - 1) * limit
    const take = limit

    // Build where clause
    const where: {
      OR?: Array<{
        admissionNumber?: { contains: string }
        rollNumber?: { contains: string }
        firstName?: { contains: string }
        lastName?: { contains: string }
        email?: { contains: string }
        user?: {
          name?: { contains: string }
          email?: { contains: string }
        }
      }>
      institutionId?: number
      isActive?: boolean
      status?: { not: 'SUSPENDED' }
    } = {
      status: { not: 'SUSPENDED' }, // Exclude soft deleted students
    }
    if (search) {
      where.OR = [
        { admissionNumber: { contains: search } },
        { rollNumber: { contains: search } },
        { user: { name: { contains: search } } },
        { user: { email: { contains: search } } },
      ]
    }

    // Get students with pagination
    const [students, total] = await Promise.all([
      this.prisma.student.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              uuid: true,
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
          program: {
            select: {
              id: true,
              name: true,
              code: true,
            },
          },
          parents: {
            include: {
              user: {
                select: {
                  id: true,
                  name: true,
                  email: true,
                  phone: true,
                },
              },
            },
          },
        },
        orderBy: { [sortBy]: sortOrder },
        skip,
        take,
      }),
      this.prisma.student.count({ where }),
    ])

    return {
      success: true,
      data: students,
      pagination: {
        page,
        limit: take,
        total,
        totalPages: Math.ceil(total / take),
      },
    }
  }

  async findOne(id: number, currentUser: UserWithRelations) {
    const student = await this.prisma.student.findFirst({
      where: {
        id,
        status: { not: 'SUSPENDED' }, // Exclude soft deleted students
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
            createdAt: true,
          },
        },
        institution: true,
        program: true,
        parents: {
          include: {
            user: {
              select: {
                id: true,
                uuid: true,
                edverseId: true,
                name: true,
                email: true,
                phone: true,
              },
            },
          },
        },
      },
    })

    if (!student) {
      throw new NotFoundException('Student not found')
    }

    // Check if user can access this student
    if (
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== id
    ) {
      throw new ForbiddenException('Access denied')
    }

    return {
      success: true,
      data: student,
    }
  }

  async findByUuid(uuid: string, currentUser: UserWithRelations) {
    const student = await this.prisma.student.findFirst({
      where: {
        user: {
          uuid,
        },
        status: { not: 'SUSPENDED' },
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
            createdAt: true,
          },
        },
        institution: true,
        program: true,
        parents: {
          include: {
            user: {
              select: {
                id: true,
                uuid: true,
                edverseId: true,
                name: true,
                email: true,
                phone: true,
              },
            },
          },
        },
      },
    })

    if (!student) {
      throw new NotFoundException('Student not found')
    }

    // Check if user can access this student
    if (
      currentUser.role.roleName === 'student' &&
      currentUser.student?.userId !== student.userId
    ) {
      throw new ForbiddenException('Access denied')
    }

    return {
      success: true,
      data: student,
    }
  }

  async create(createStudentDto: CreateStudentDto) {
    const { firstName, lastName, email, phone, password, ...studentData } =
      createStudentDto

    // Check if admission number already exists
    const existingStudent = await this.prisma.student.findUnique({
      where: { admissionNumber: createStudentDto.admissionNumber },
    })

    if (existingStudent) {
      throw new ConflictException(
        'Student with this admission number already exists'
      )
    }

    // Check if email already exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    })

    if (existingUser) {
      throw new ConflictException('User with this email already exists')
    }

    // Get student role ID
    const studentRole = await this.prisma.role.findUnique({
      where: { roleName: 'student' },
    })

    if (!studentRole) {
      throw new NotFoundException('Student role not found')
    }

    // Generate password if not provided
    const finalPassword = password || this.generateRandomPassword()
    const hashedPassword = await bcrypt.hash(finalPassword, 10)

    // Create user and student in a transaction
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
          roleId: studentRole.id,
          emailVerified: false,
          phoneVerified: false,
          status: 'ACTIVE',
        },
      })

      // Create student profile
      const student = await tx.student.create({
        data: {
          ...studentData,
          userId: user.id,
          admissionDate: studentData.admissionDate
            ? new Date(studentData.admissionDate)
            : null,
        },
        include: {
          user: {
            select: {
              id: true,
              uuid: true,
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
          program: {
            select: {
              id: true,
              name: true,
              code: true,
            },
          },
        },
      })

      return { student, generatedPassword: password ? null : finalPassword }
    })

    // Return student data with generated password if applicable
    return {
      success: true,
      data: {
        ...result.student,
        ...(result.generatedPassword && {
          generatedPassword: result.generatedPassword,
        }),
      },
      message: 'Student created successfully',
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

  async update(id: number, updateStudentDto: UpdateStudentDto) {
    const student = await this.prisma.student.update({
      where: { id },
      data: updateStudentDto,
      include: {
        user: {
          select: {
            id: true,
            uuid: true,
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
        program: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
      },
    })

    return {
      success: true,
      data: student,
      message: 'Student updated successfully',
    }
  }

  async remove(id: number) {
    const existingStudent = await this.prisma.student.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            name: true,
            email: true,
          },
        },
      },
    })

    if (!existingStudent) {
      throw new NotFoundException(`Student with ID ${id} not found`)
    }

    const student = await this.prisma.student.update({
      where: { id },
      data: {
        status: 'SUSPENDED',
      },
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            name: true,
            email: true,
            status: true,
          },
        },
        institution: {
          select: { id: true, name: true, type: true },
        },
      },
    })

    return {
      success: true,
      message: 'Student deactivated successfully',
      data: student,
    }
  }

  async getAcademicRecords(id: number, currentUser: UserWithRelations) {
    // Check access permissions
    if (
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== id
    ) {
      throw new ForbiddenException('Access denied')
    }

    const academicRecords = await this.prisma.academicRecord.findMany({
      where: { studentId: id },
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
      orderBy: [
        { semester: { semesterNumber: 'desc' } },
        { course: { courseCode: 'asc' } },
      ],
    })

    return {
      success: true,
      data: academicRecords,
    }
  }

  async getAttendance(
    id: number,
    startDate?: string,
    endDate?: string,
    currentUser?: UserWithRelations
  ) {
    // Check access permissions
    if (
      currentUser &&
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== id
    ) {
      throw new ForbiddenException('Access denied')
    }

    const where: {
      studentId: number
      date?: {
        gte: Date
        lte: Date
      }
    } = { studentId: id }
    if (startDate && endDate) {
      where.date = {
        gte: new Date(startDate),
        lte: new Date(endDate),
      }
    }

    const attendance = await this.prisma.attendance.findMany({
      where,
      include: {
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
      orderBy: { date: 'desc' },
    })

    return {
      success: true,
      data: attendance,
    }
  }

  // UUID-based methods
  async updateByUuid(uuid: string, updateStudentDto: UpdateStudentDto) {
    // First find the student by UUID
    const student = await this.prisma.student.findFirst({
      where: {
        user: { uuid },
      },
    })

    if (!student) {
      throw new NotFoundException(`Student with UUID ${uuid} not found`)
    }

    // Use the existing update method with the found student ID
    return this.update(student.id, updateStudentDto)
  }

  async removeByUuid(uuid: string) {
    // First find the student by UUID
    const student = await this.prisma.student.findFirst({
      where: {
        user: { uuid },
      },
    })

    if (!student) {
      throw new NotFoundException(`Student with UUID ${uuid} not found`)
    }

    // Use the existing remove method with the found student ID
    return this.remove(student.id)
  }

  async getAcademicRecordsByUuid(
    uuid: string,
    currentUser?: UserWithRelations
  ) {
    // First find the student by UUID
    const student = await this.prisma.student.findFirst({
      where: {
        user: { uuid },
      },
    })

    if (!student) {
      throw new NotFoundException(`Student with UUID ${uuid} not found`)
    }

    // Use the existing getAcademicRecords method with the found student ID
    return this.getAcademicRecords(student.id, currentUser)
  }

  async getAttendanceByUuid(
    uuid: string,
    startDate?: string,
    endDate?: string,
    currentUser?: UserWithRelations
  ) {
    // First find the student by UUID
    const student = await this.prisma.student.findFirst({
      where: {
        user: { uuid },
      },
    })

    if (!student) {
      throw new NotFoundException(`Student with UUID ${uuid} not found`)
    }

    // Use the existing getAttendance method with the found student ID
    return this.getAttendance(student.id, startDate, endDate, currentUser)
  }

  // ============================================================================
  // STUDENT DASHBOARD METHODS
  // ============================================================================

  async getDashboardStatsByUuid(
    uuid: string,
    currentUser: UserWithRelations
  ): Promise<StudentDashboardStatsResponse> {
    // Find student by UUID
    const student = await this.prisma.student.findFirst({
      where: { user: { uuid } },
      include: { user: true },
    })

    if (!student) {
      throw new NotFoundException(`Student with UUID ${uuid} not found`)
    }

    // Check permissions
    if (
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== student.id
    ) {
      throw new ForbiddenException('Access denied')
    }

    // Get current semester
    const currentSemester = await this.prisma.semester.findFirst({
      where: { status: 'ACTIVE' },
      orderBy: { semesterNumber: 'desc' },
    })

    if (!currentSemester) {
      throw new NotFoundException('No active semester found')
    }

    // Calculate GPA from academic records
    const academicRecords = await this.prisma.academicRecord.findMany({
      where: {
        studentId: student.id,
        semesterId: currentSemester.id,
      },
      include: { course: true },
    })

    let totalGradePoints = 0
    let totalCredits = 0
    for (const record of academicRecords) {
      if (record.gradePoints && record.creditsEarned) {
        totalGradePoints +=
          parseFloat(record.gradePoints.toString()) * record.creditsEarned
        totalCredits += record.creditsEarned
      }
    }
    const currentGpa = totalCredits > 0 ? totalGradePoints / totalCredits : 0

    // Calculate previous semester GPA for comparison
    const previousSemester = await this.prisma.semester.findFirst({
      where: {
        semesterNumber: currentSemester.semesterNumber - 1,
        status: { not: 'ACTIVE' },
      },
    })

    let previousGpa = 0
    if (previousSemester) {
      const prevRecords = await this.prisma.academicRecord.findMany({
        where: {
          studentId: student.id,
          semesterId: previousSemester.id,
        },
      })

      let prevTotalGradePoints = 0
      let prevTotalCredits = 0
      for (const record of prevRecords) {
        if (record.gradePoints && record.creditsEarned) {
          prevTotalGradePoints +=
            parseFloat(record.gradePoints.toString()) * record.creditsEarned
          prevTotalCredits += record.creditsEarned
        }
      }
      previousGpa =
        prevTotalCredits > 0 ? prevTotalGradePoints / prevTotalCredits : 0
    }

    // Calculate attendance percentage
    const thirtyDaysAgo = new Date()
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)

    const attendanceRecords = await this.prisma.attendance.findMany({
      where: {
        studentId: student.id,
        date: { gte: thirtyDaysAgo },
      },
    })

    const totalClasses = attendanceRecords.length
    const presentClasses = attendanceRecords.filter(
      record => record.status === 'PRESENT'
    ).length
    const attendance =
      totalClasses > 0 ? (presentClasses / totalClasses) * 100 : 0

    // Calculate previous month attendance for comparison
    const sixtyDaysAgo = new Date()
    sixtyDaysAgo.setDate(sixtyDaysAgo.getDate() - 60)

    const prevAttendanceRecords = await this.prisma.attendance.findMany({
      where: {
        studentId: student.id,
        date: { gte: sixtyDaysAgo, lt: thirtyDaysAgo },
      },
    })

    const prevTotalClasses = prevAttendanceRecords.length
    const prevPresentClasses = prevAttendanceRecords.filter(
      record => record.status === 'PRESENT'
    ).length
    const previousAttendance =
      prevTotalClasses > 0 ? (prevPresentClasses / prevTotalClasses) * 100 : 0

    // Calculate class rank
    const allStudentsGpa = await this.prisma.academicRecord.groupBy({
      by: ['studentId'],
      where: { semesterId: currentSemester.id },
      _avg: { gradePoints: true },
      _sum: { creditsEarned: true },
    })

    const studentGpas = allStudentsGpa
      .map(record => ({
        studentId: record.studentId,
        gpa:
          record._sum.creditsEarned && record._avg.gradePoints
            ? (parseFloat(record._avg.gradePoints.toString()) *
                record._sum.creditsEarned) /
              record._sum.creditsEarned
            : 0,
      }))
      .sort((a, b) => b.gpa - a.gpa)

    const studentRankIndex = studentGpas.findIndex(
      s => s.studentId === student.id
    )
    const classRank = studentRankIndex >= 0 ? studentRankIndex + 1 : 0
    const totalStudents = studentGpas.length

    // Calculate rank change (simplified - using GPA change as proxy)
    const rankChange =
      currentGpa > previousGpa ? -1 : currentGpa < previousGpa ? 1 : 0

    // Count assignments due
    const now = new Date()
    const oneWeekFromNow = new Date()
    oneWeekFromNow.setDate(oneWeekFromNow.getDate() + 7)

    const assignmentsDue = await this.prisma.assignment.count({
      where: {
        dueDate: { gte: now, lte: oneWeekFromNow },
        status: 'PUBLISHED',
        submissions: {
          none: { studentId: student.id },
        },
      },
    })

    return {
      success: true,
      data: {
        currentGpa: Math.round(currentGpa * 100) / 100,
        maxGpa: 4.0,
        gpaChange: Math.round((currentGpa - previousGpa) * 100) / 100,
        attendance: Math.round(attendance * 100) / 100,
        attendanceChange:
          Math.round((attendance - previousAttendance) * 100) / 100,
        classRank,
        totalStudents,
        rankChange,
        assignmentsDue,
      },
    }
  }

  async getAssignmentsByUuid(
    uuid: string,
    limit: number = 10,
    status?: string,
    currentUser?: UserWithRelations
  ): Promise<StudentAssignmentsResponse> {
    // Find student by UUID
    const student = await this.prisma.student.findFirst({
      where: { user: { uuid } },
    })

    if (!student) {
      throw new NotFoundException(`Student with UUID ${uuid} not found`)
    }

    // Check permissions
    if (
      currentUser &&
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== student.id
    ) {
      throw new ForbiddenException('Access denied')
    }

    // Get student's enrollments to find their courses
    const enrollments = await this.prisma.enrollment.findMany({
      where: { studentId: student.id },
      include: { course: true },
    })

    const courseIds = enrollments.map(e => e.courseId)

    // Build where clause
    const where: Prisma.AssignmentWhereInput = {
      courseId: { in: courseIds },
      status: 'PUBLISHED',
    }

    // Get assignments with submissions
    const assignments = await this.prisma.assignment.findMany({
      where,
      include: {
        course: { select: { courseName: true, courseCode: true } },
        submissions: {
          where: { studentId: student.id },
          orderBy: { version: 'desc' },
          take: 1,
        },
      },
      orderBy: { dueDate: 'desc' },
      take: limit,
    })

    const assignmentData = assignments.map(assignment => {
      const submission = assignment.submissions[0]
      let assignmentStatus: 'submitted' | 'graded' | 'pending' = 'pending'
      let grade: string | undefined
      let score: string | undefined

      if (submission) {
        if (submission.status === 'GRADED') {
          assignmentStatus = 'graded'
          if (submission.marksObtained) {
            score = `${submission.marksObtained}/${assignment.maxMarks}`
            const percentage =
              (parseFloat(submission.marksObtained.toString()) /
                assignment.maxMarks) *
              100
            // Grading Scale: A+ (93+), A (85-92), B+ (77-84), B (70-76), C (60-69), D (<60)
            if (percentage >= 93) grade = 'A+'
            else if (percentage >= 85) grade = 'A'
            else if (percentage >= 77) grade = 'B+'
            else if (percentage >= 70) grade = 'B'
            else if (percentage >= 60) grade = 'C'
            else grade = 'D'
          }
        } else {
          assignmentStatus = 'submitted'
        }
      }

      return {
        id: assignment.id,
        title: assignment.title,
        subject: assignment.course.courseName,
        dueDate: assignment.dueDate.toISOString().split('T')[0],
        status: assignmentStatus,
        grade,
        score,
        maxMarks: assignment.maxMarks,
        marksObtained: submission?.marksObtained
          ? parseFloat(submission.marksObtained.toString())
          : undefined,
      }
    })

    // Filter by status if provided
    const filteredAssignments = status
      ? assignmentData.filter(a => a.status === status)
      : assignmentData

    return {
      success: true,
      data: {
        assignments: filteredAssignments,
        totalCount: filteredAssignments.length,
      },
    }
  }

  async getPerformanceTrendsByUuid(
    uuid: string,
    startMonth?: string,
    endMonth?: string,
    currentUser?: UserWithRelations
  ): Promise<StudentPerformanceTrendsResponse> {
    // Find student by UUID
    const student = await this.prisma.student.findFirst({
      where: { user: { uuid } },
    })

    if (!student) {
      throw new NotFoundException(`Student with UUID ${uuid} not found`)
    }

    // Check permissions
    if (
      currentUser &&
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== student.id
    ) {
      throw new ForbiddenException('Access denied')
    }

    // Default to last 6 months if not specified
    const endDate = endMonth ? new Date(endMonth + '-01') : new Date()

    // If endMonth is specified, set endDate to the last day of that month
    if (endMonth) {
      const [year, month] = endMonth.split('-').map(Number)
      endDate.setFullYear(year, month - 1) // month - 1 because JS months are 0-indexed
      endDate.setDate(new Date(year, month, 0).getDate()) // Last day of the month
      endDate.setHours(23, 59, 59, 999) // End of day
    }

    const startDate = startMonth
      ? new Date(startMonth + '-01')
      : new Date(endDate.getFullYear(), endDate.getMonth() - 5, 1)

    // Get student progress data
    const progressData = await this.prisma.studentProgress.findMany({
      where: {
        studentId: student.id,
        createdAt: { gte: startDate, lte: endDate },
      },
      include: {
        subject: { select: { name: true, code: true } },
        semester: { select: { semesterName: true } },
      },
      orderBy: { createdAt: 'asc' },
    })

    // Group by subject and create trends
    const subjectMap = new Map()

    progressData.forEach(progress => {
      const subjectKey = progress.subject.code
      if (!subjectMap.has(subjectKey)) {
        subjectMap.set(subjectKey, {
          subject: progress.subject.name,
          subjectCode: progress.subject.code,
          dataPoints: [],
        })
      }

      const monthYear = progress.createdAt.toISOString().slice(0, 7) // YYYY-MM
      const score = progress.gradePoints
        ? parseFloat(progress.gradePoints.toString()) * 25
        : 0 // Convert to percentage

      subjectMap.get(subjectKey).dataPoints.push({
        month: new Date(monthYear + '-01').toLocaleDateString('en-US', {
          month: 'short',
        }),
        score: Math.round(score),
      })
    })

    const trends = Array.from(subjectMap.values())

    return {
      success: true,
      data: {
        trends,
        period: {
          startMonth: startDate.toISOString().slice(0, 7),
          endMonth: endDate.toISOString().slice(0, 7),
        },
      },
    }
  }

  async getAttendanceHistoryByUuid(
    uuid: string,
    semesterId?: number,
    currentUser?: UserWithRelations
  ): Promise<StudentAttendanceHistoryResponse> {
    // Find student by UUID
    const student = await this.prisma.student.findFirst({
      where: { user: { uuid } },
    })

    if (!student) {
      throw new NotFoundException(`Student with UUID ${uuid} not found`)
    }

    // Check permissions
    if (
      currentUser &&
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== student.id
    ) {
      throw new ForbiddenException('Access denied')
    }

    // Get current semester if not specified
    let semester
    if (semesterId) {
      semester = await this.prisma.semester.findUnique({
        where: { id: semesterId },
      })
    } else {
      semester = await this.prisma.semester.findFirst({
        where: { status: 'ACTIVE' },
        orderBy: { semesterNumber: 'desc' },
      })
    }

    if (!semester) {
      throw new NotFoundException('Semester not found')
    }

    // Get attendance data for the last 6 months
    const endDate = new Date()
    const startDate = new Date(endDate.getFullYear(), endDate.getMonth() - 5, 1)

    const attendanceData = await this.prisma.attendance.findMany({
      where: {
        studentId: student.id,
        date: { gte: startDate, lte: endDate },
      },
      orderBy: { date: 'asc' },
    })

    // Group by month
    const monthlyData = new Map()
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ]

    // Initialize months
    for (let i = 0; i < 6; i++) {
      const date = new Date(endDate.getFullYear(), endDate.getMonth() - i, 1)
      const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`
      const monthName = months[date.getMonth()]

      monthlyData.set(monthKey, {
        month: monthName,
        totalClasses: 0,
        attendedClasses: 0,
        percentage: 0,
      })
    }

    // Process attendance data
    attendanceData.forEach(record => {
      const monthKey = record.date.toISOString().slice(0, 7) // YYYY-MM
      if (monthlyData.has(monthKey)) {
        const monthData = monthlyData.get(monthKey)
        monthData.totalClasses++
        if (record.status === 'PRESENT') {
          monthData.attendedClasses++
        }
        monthData.percentage =
          monthData.totalClasses > 0
            ? Math.round(
                (monthData.attendedClasses / monthData.totalClasses) * 100
              )
            : 0
      }
    })

    const attendanceHistory = Array.from(monthlyData.values()).reverse()

    // Calculate overall percentage
    const totalClasses = attendanceData.length
    const totalPresent = attendanceData.filter(
      record => record.status === 'PRESENT'
    ).length
    const overallPercentage =
      totalClasses > 0 ? Math.round((totalPresent / totalClasses) * 100) : 0

    return {
      success: true,
      data: {
        attendanceHistory,
        overallPercentage,
        period: {
          startDate: startDate.toISOString().split('T')[0],
          endDate: endDate.toISOString().split('T')[0],
        },
      },
    }
  }

  async getSubjectPerformanceByUuid(
    uuid: string,
    currentUser?: UserWithRelations
  ): Promise<StudentSubjectPerformanceResponse> {
    // Find student by UUID
    const student = await this.prisma.student.findFirst({
      where: { user: { uuid } },
    })

    if (!student) {
      throw new NotFoundException(`Student with UUID ${uuid} not found`)
    }

    // Check permissions
    if (
      currentUser &&
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== student.id
    ) {
      throw new ForbiddenException('Access denied')
    }

    // Get current semester
    const currentSemester = await this.prisma.semester.findFirst({
      where: { status: 'ACTIVE' },
      orderBy: { semesterNumber: 'desc' },
    })

    if (!currentSemester) {
      throw new NotFoundException('No active semester found')
    }

    // Get student progress data
    const progressData = await this.prisma.studentProgress.findMany({
      where: {
        studentId: student.id,
        semesterId: currentSemester.id,
      },
      include: {
        subject: { select: { name: true, code: true } },
      },
    })

    // Get enrollments to find teachers
    const enrollments = await this.prisma.enrollment.findMany({
      where: {
        studentId: student.id,
        semesterId: currentSemester.id,
      },
      include: {
        course: {
          select: {
            courseName: true,
            courseCode: true,
            classSections: {
              include: {
                teacher: {
                  include: { user: { select: { name: true } } },
                },
              },
            },
          },
        },
      },
    })

    // Get upcoming exams
    const upcomingExams = await this.prisma.examination.findMany({
      where: {
        examDate: { gte: new Date() },
        semesterId: currentSemester.id,
      },
      include: {
        course: { select: { courseName: true, courseCode: true } },
      },
      orderBy: { examDate: 'asc' },
    })

    const subjects = progressData.map(progress => {
      // Find teacher for this subject - match by subject name
      const enrollment = enrollments.find(e =>
        e.course.courseName
          .toLowerCase()
          .includes(progress.subject.name.toLowerCase())
      )
      const teacher =
        enrollment?.course.classSections[0]?.teacher?.user?.name || 'TBD'

      // Find next test
      const nextExam = upcomingExams.find(exam =>
        exam.course.courseName
          .toLowerCase()
          .includes(progress.subject.name.toLowerCase())
      )
      const nextTest = nextExam
        ? nextExam.examDate.toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
          })
        : 'TBD'

      // Calculate percentage and grade
      const gradePoints = progress.gradePoints
        ? parseFloat(progress.gradePoints.toString())
        : 0
      const percentage = Math.round(gradePoints * 25) // Convert 4.0 scale to percentage

      const grade = progress.overallGrade || 'N/A'
      let status: 'excellent' | 'good' | 'average' | 'needs_improvement' =
        'average'

      if (percentage >= 90) {
        status = 'excellent'
      } else if (percentage >= 80) {
        status = 'good'
      } else if (percentage >= 70) {
        status = 'average'
      } else {
        status = 'needs_improvement'
      }

      return {
        subject: progress.subject.name,
        subjectCode: progress.subject.code,
        teacher,
        nextTest,
        grade,
        percentage,
        gradePoints,
        status,
      }
    })

    // Calculate overall GPA
    const totalGradePoints = progressData.reduce((sum, progress) => {
      return (
        sum +
        (progress.gradePoints ? parseFloat(progress.gradePoints.toString()) : 0)
      )
    }, 0)
    const overallGpa =
      progressData.length > 0 ? totalGradePoints / progressData.length : 0

    return {
      success: true,
      data: {
        subjects,
        overallGpa: Math.round(overallGpa * 100) / 100,
      },
    }
  }

  async getUpcomingEventsByUuid(
    uuid: string,
    limit: number = 10,
    currentUser?: UserWithRelations
  ): Promise<StudentUpcomingEventsResponse> {
    // Find student by UUID
    const student = await this.prisma.student.findFirst({
      where: { user: { uuid } },
    })

    if (!student) {
      throw new NotFoundException(`Student with UUID ${uuid} not found`)
    }

    // Check permissions
    if (
      currentUser &&
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== student.id
    ) {
      throw new ForbiddenException('Access denied')
    }

    const now = new Date()
    const events: Array<{
      id: number
      title: string
      type: 'test' | 'assignment'
      date: string
      time: string
      subject: string
      description: string
    }> = []

    // Get student's enrolled courses
    const enrollments = await this.prisma.enrollment.findMany({
      where: { studentId: student.id },
      select: { courseId: true },
    })
    const enrolledCourseIds = enrollments.map(e => e.courseId)

    // Get upcoming exams for enrolled courses
    const upcomingExams = await this.prisma.examination.findMany({
      where: {
        examDate: { gte: now },
        status: { in: ['SCHEDULED', 'ONGOING'] },
        courseId: { in: enrolledCourseIds },
      },
      include: {
        course: { select: { courseName: true, courseCode: true } },
      },
      orderBy: { examDate: 'asc' },
      take: limit,
    })

    upcomingExams.forEach(exam => {
      events.push({
        id: exam.id,
        title: `${exam.examName}`,
        date: exam.examDate?.toISOString().split('T')[0] || '',
        time: exam.startTime?.toISOString().slice(11, 16) || '10:00',
        type: 'test' as const,
        subject: exam.course.courseName,
        description: `${exam.examType} - ${exam.course.courseName}`,
      })
    })

    // Get upcoming assignments for enrolled courses
    const upcomingAssignments = await this.prisma.assignment.findMany({
      where: {
        dueDate: { gte: now },
        status: 'PUBLISHED',
        courseId: { in: enrolledCourseIds },
        submissions: {
          none: { studentId: student.id },
        },
      },
      include: {
        course: { select: { courseName: true, courseCode: true } },
      },
      orderBy: { dueDate: 'asc' },
      take: limit,
    })

    upcomingAssignments.forEach(assignment => {
      events.push({
        id: assignment.id + 10000, // Offset to avoid ID conflicts
        title: assignment.title,
        date: assignment.dueDate.toISOString().split('T')[0],
        time: '23:59',
        type: 'assignment' as const,
        subject: assignment.course.courseName,
        description: `Assignment Due - ${assignment.course.courseName}`,
      })
    })

    // Sort all events by date and limit
    const sortedEvents = events
      .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime())
      .slice(0, limit)

    return {
      success: true,
      data: {
        events: sortedEvents,
        totalCount: sortedEvents.length,
      },
    }
  }
}
