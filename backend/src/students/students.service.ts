import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'
import { Prisma } from '@prisma/client'
import * as bcrypt from 'bcrypt'
import { IdGenerationService } from '../id-generation/id-generation.service'
import { PrismaService } from '../prisma/prisma.service'
import { UserWithRelations } from '../types/auth.types'
import {
  ReportCard,
  ReportCardAttendanceSummary,
  ReportCardExamSummary,
  ReportCardPerformanceSummary,
  ReportCardQueryParams,
  ReportCardRemarks,
  ReportCardResponse,
  ReportCardSemesterInfo,
  ReportCardStudentInfo,
  ReportCardSubjectRecord,
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
import { AcademicProgressionService } from './services/academic-progression.service'
import { AttendanceService, AttendanceQueryOptions } from './services/attendance.service'

@Injectable()
export class StudentsService {
  constructor(
    private prisma: PrismaService,
    private idGenerationService: IdGenerationService,
    private academicProgressionService: AcademicProgressionService,
    private attendanceService: AttendanceService,
  ) {}

  /**
   * Helper function to get full name from firstName and lastName
   */
  private getFullName(firstName: string, lastName: string): string {
    return `${firstName} ${lastName}`.trim()
  }

  /**
   * Helper: Get attendance summary from database view
   * Uses student_attendance_summary view for optimized performance
   */
  private async getAttendanceSummaryFromView(
    studentId: number,
    semesterId: number
  ): Promise<
    Array<{
      subject_id: number
      subject_name: string
      subject_code: string
      total_classes: bigint
      classes_present: bigint
      classes_absent: bigint
      classes_late: bigint
      classes_excused: bigint
      attendance_percentage: number
      status: string
    }>
  > {
    return this.prisma.$queryRaw`
      SELECT * FROM student_attendance_summary
      WHERE student_id = ${studentId} AND semester_id = ${semesterId}
    `
  }

  /**
   * Helper: Get grade summary from database view
   * Uses semester_grade_summary view for optimized SGPA calculations
   */
  private async getGradeSummaryFromView(
    studentId: number,
    semesterId: number
  ): Promise<{
    sgpa: number | null
    total_subjects: bigint
    percentage: number | null
  } | null> {
    const results = await this.prisma.$queryRaw<
      Array<{
        sgpa: number
        total_subjects: bigint
        percentage: number
      }>
    >`
      SELECT sgpa, total_subjects, percentage
      FROM semester_grade_summary
      WHERE student_id = ${studentId} AND semester_id = ${semesterId}
    `

    return results.length > 0 ? results[0] : null
  }

  async findAll(paginationDto: PaginationDto, currentUser: UserWithRelations) {
    const {
      page = 1,
      limit = 10,
      sortBy = 'createdAt',
      sortOrder = 'desc',
      search,
    } = paginationDto

    const skip = (page - 1) * limit
    const take = limit

    // Build where clause for students
    const where: Prisma.StudentWhereInput = {
      enrollmentStatus: { not: 'SUSPENDED' }, // Exclude soft deleted students
    }

    if (search) {
      where.OR = [
        { admissionNumber: { contains: search } },
        { user: { firstName: { contains: search } } },
        { user: { lastName: { contains: search } } },
        { user: { email: { contains: search } } },
      ]
    }

    const resolvedInstitutionId =
      currentUser.institutionId ??
      currentUser.staff?.institutionId ??
      currentUser.teacher?.institutionId ??
      null
    if (resolvedInstitutionId) {
      where.institutionId = resolvedInstitutionId
    }

    // Get students with their current academic year information
    const [students, total] = await Promise.all([
      this.prisma.student.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              uuid: true,
              firstName: true,
              lastName: true,
              email: true,
              phone: true,
              accountStatus: true,
            },
          },
          institution: {
            select: {
              id: true,
              name: true,
              type: true,
            },
          },
          parents: {
            include: {
              user: {
                select: {
                  id: true,
                  firstName: true,
                  lastName: true,
                  email: true,
                  phone: true,
                },
              },
            },
          },
          course: {
            select: {
              id: true,
              name: true,
              code: true,
            },
          },
          // Get current academic year information
          academicYears: {
            where: {
              promotionStatus: 'IN_PROGRESS',
            },
            include: {
              academicYear: {
                select: {
                  yearName: true,
                  status: true,
                },
              },
              classDivision: {
                include: {
                  course: {
                    select: {
                      name: true,
                      code: true,
                    },
                  },
                },
              },
              classTeacher: {
                include: {
                  user: {
                    select: {
                      firstName: true,
                      lastName: true,
                    },
                  },
                },
              },
            },
            orderBy: {
              academicYear: { startDate: 'desc' },
            },
            take: 1,
          },
        },
        orderBy: { [sortBy]: sortOrder },
        skip,
        take,
      }),
      this.prisma.student.count({ where }),
    ])

    // Transform data to include current academic year info
    const transformedStudents = students.map(student => {
      const currentAcademicYear = student.academicYears[0]
      
      return {
        ...student,
        currentAcademicYear: currentAcademicYear ? {
          classLevel: currentAcademicYear.classLevel,
          section: currentAcademicYear.section,
          rollNumber: currentAcademicYear.rollNumber,
          academicYear: currentAcademicYear.academicYear.yearName,
          course: currentAcademicYear.classDivision?.course,
          classTeacher: currentAcademicYear.classTeacher ? 
            `${currentAcademicYear.classTeacher.user.firstName} ${currentAcademicYear.classTeacher.user.lastName}` : null,
          promotionStatus: currentAcademicYear.promotionStatus,
          attendancePercentage: currentAcademicYear.attendancePercentage ? 
            parseFloat(currentAcademicYear.attendancePercentage.toString()) : null,
        } : null,
        // Remove the raw academicYears from response
        academicYears: undefined,
      }
    })

    return {
      success: true,
      data: transformedStudents,
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
        enrollmentStatus: { not: 'SUSPENDED' }, // Exclude soft deleted students
      },
      include: {
          user: {
            select: {
              id: true,
              uuid: true,
              kramid: true,
              firstName: true,
              lastName: true,
              email: true,
              phone: true,
              accountStatus: true,
              createdAt: true,
            },
          },
        institution: true,
        parents: {
          include: {
              user: {
                select: {
                  id: true,
                  uuid: true,
                  kramid: true,
                  firstName: true,
                  lastName: true,
                  email: true,
                  phone: true,
                },
              },
          },
        },
        // Get complete academic history
        academicYears: {
          include: {
            academicYear: {
              select: {
                id: true,
                yearName: true,
                startDate: true,
                endDate: true,
                status: true,
              },
            },
            classDivision: {
              include: {
                course: {
                  select: {
                    id: true,
                    name: true,
                    code: true,
                  },
                },
              },
            },
            classTeacher: {
              include: {
                user: {
                  select: {
                    firstName: true,
                    lastName: true,
                  },
                },
              },
            },
          },
          orderBy: {
            academicYear: { startDate: 'desc' },
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

    const resolvedInstitutionId =
      currentUser.institutionId ??
      currentUser.staff?.institutionId ??
      currentUser.teacher?.institutionId ??
      null
    if (
      currentUser.role.roleName === 'admin' &&
      resolvedInstitutionId !== null &&
      student.institutionId !== resolvedInstitutionId
    ) {
      throw new ForbiddenException('Access denied to this student')
    }

    // Transform academic years data for better presentation
    const academicHistory = student.academicYears.map(record => ({
      id: record.id,
      academicYear: record.academicYear.yearName,
      classLevel: record.classLevel,
      section: record.section,
      rollNumber: record.rollNumber,
      course: record.classDivision?.course,
      classTeacher: record.classTeacher ? 
        `${record.classTeacher.user.firstName} ${record.classTeacher.user.lastName}` : null,
      promotionStatus: record.promotionStatus,
      finalGrade: record.finalGrade,
      finalPercentage: record.finalPercentage ? 
        parseFloat(record.finalPercentage.toString()) : null,
      attendancePercentage: record.attendancePercentage ? 
        parseFloat(record.attendancePercentage.toString()) : null,
      enrollmentDate: record.enrollmentDate,
      completionDate: record.completionDate,
    }))

    const currentAcademicYear = academicHistory.find(record => 
      record.promotionStatus === 'IN_PROGRESS'
    )

    return {
      success: true,
      data: {
        ...student,
        academicHistory,
        currentAcademicYear,
        // Remove the raw academicYears from response
        academicYears: undefined,
      },
    }
  }

  async findByUuid(uuid: string, currentUser: UserWithRelations) {
    const student = await this.prisma.student.findFirst({
      where: {
        user: {
          uuid,
        },
        enrollmentStatus: { not: 'SUSPENDED' },
      },
      include: {
        user: {
          select: {
            id: true,
            uuid: true,
            kramid: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            accountStatus: true,
            createdAt: true,
          },
        },
        institution: true,
        course: true,
        parents: {
          include: {
            user: {
              select: {
                id: true,
                uuid: true,
                kramid: true,
                firstName: true,
                lastName: true,
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

    const resolvedInstitutionId =
      currentUser.institutionId ??
      currentUser.staff?.institutionId ??
      currentUser.teacher?.institutionId ??
      null
    if (
      currentUser.role.roleName === 'admin' &&
      resolvedInstitutionId !== null &&
      student.institutionId !== resolvedInstitutionId
    ) {
      throw new ForbiddenException('Access denied to this student')
    }

    return {
      success: true,
      data: student,
    }
  }

  async create(createStudentDto: CreateStudentDto & {
    // Optional academic year enrollment data
    academicYearId?: number
    classLevel?: number
    section?: string
    rollNumber?: string
    classDivisionId?: number
    classTeacherId?: number
  }) {
    const { firstName, lastName, email, phone, password, academicYearId, classLevel, section, rollNumber, classDivisionId, classTeacherId, ...studentData } =
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
          email,
          phone,
          passwordHash: hashedPassword,
          roleId: studentRole.id,
          institutionId: studentData.institutionId,
          accountStatus: 'ACTIVE',
        },
      })

      // Create student profile (without legacy fields)
      const student = await tx.student.create({
        data: {
          userId: user.id,
          institutionId: studentData.institutionId,
          admissionNumber: studentData.admissionNumber,
          admissionDate: studentData.admissionDate
            ? new Date(studentData.admissionDate)
            : new Date(),
          studentType: studentData.studentType,
          residentialStatus: studentData.residentialStatus,
          transportRequired: studentData.transportRequired,
          emergencyContactName: studentData.emergencyContactName,
          emergencyContactPhone: studentData.emergencyContactPhone,
          emergencyContactEmail: studentData.emergencyContactPhone, // Temporary fix
          bloodGroup: studentData.bloodGroup,
          medicalConditions: studentData.medicalConditions,
          // Legacy fields temporarily kept for compatibility
          courseId: studentData.programId, // Map programId to courseId
          classDivisionId: null, // Not in DTO
          rollNumber: null, // Will be set via academic year record
          currentSemester: studentData.currentSemester,
          currentYear: studentData.currentYear,
          section: null, // Will be set via academic year record
        },
        include: {
          user: {
            select: {
              id: true,
              uuid: true,
              firstName: true,
              lastName: true,
              email: true,
              phone: true,
              accountStatus: true,
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

      // Create academic year record if academic year info is provided
      let academicYearRecord = null
      if (academicYearId && classLevel) {
        // Generate roll number if not provided
        let finalRollNumber = rollNumber
        if (!finalRollNumber && classDivisionId) {
          const classDivision = await tx.classDivision.findUnique({
            where: { id: classDivisionId },
            include: { course: true },
          })

          if (classDivision) {
            try {
              finalRollNumber = await this.idGenerationService.generateRollNumber({
                institutionId: studentData.institutionId,
                courseCode: classDivision.course.code || 'GEN',
                section: section || 'A',
              })
            } catch (error) {
              console.warn('Failed to generate roll number:', error.message)
              finalRollNumber = `${classLevel}-${Date.now().toString(36).toUpperCase()}`
            }
          }
        }

        if (!finalRollNumber) {
          finalRollNumber = `${classLevel}-${Date.now().toString(36).toUpperCase()}`
        }

        academicYearRecord = await tx.studentAcademicYear.create({
          data: {
            studentId: student.id,
            academicYearId,
            classLevel,
            section,
            rollNumber: finalRollNumber,
            classDivisionId,
            classTeacherId,
            enrollmentDate: new Date(),
            promotionStatus: 'IN_PROGRESS',
          },
          include: {
            academicYear: {
              select: {
                yearName: true,
              },
            },
            classDivision: {
              include: {
                course: {
                  select: {
                    name: true,
                    code: true,
                  },
                },
              },
            },
          },
        })
      }

      return { 
        student, 
        academicYearRecord,
        generatedPassword: password ? null : finalPassword 
      }
    })

    // Return student data with generated password if applicable
    return {
      success: true,
      data: {
        ...result.student,
        currentAcademicYear: result.academicYearRecord ? {
          classLevel: result.academicYearRecord.classLevel,
          section: result.academicYearRecord.section,
          rollNumber: result.academicYearRecord.rollNumber,
          academicYear: result.academicYearRecord.academicYear.yearName,
          course: result.academicYearRecord.classDivision?.course,
        } : null,
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
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            accountStatus: true,
          },
        },
        institution: {
          select: {
            id: true,
            name: true,
            type: true,
          },
        },
        course: {
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
        enrollmentStatus: 'SUSPENDED',
      },
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            accountStatus: true,
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

  async getAcademicRecords(
    id: number, 
    currentUser: UserWithRelations,
    academicYearId?: number,
    semesterId?: number
  ) {
    // Check access permissions
    if (
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== id
    ) {
      throw new ForbiddenException('Access denied')
    }

    const where: Prisma.AcademicRecordWhereInput = { 
      studentId: id 
    }

    if (academicYearId) {
      where.studentAcademicYear = {
        academicYearId: academicYearId
      }
    }

    if (semesterId) {
      where.semesterId = semesterId
    }

    const academicRecords = await this.prisma.academicRecord.findMany({
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
            academicYear: {
              select: {
                id: true,
                yearName: true,
              },
            },
          },
        },
        studentAcademicYear: {
          select: {
            id: true,
            classLevel: true,
            section: true,
            rollNumber: true,
            academicYear: {
              select: {
                yearName: true,
              },
            },
          },
        },
      },
      orderBy: [
        { semester: { academicYear: { startDate: 'desc' } } },
        { semester: { semesterNumber: 'desc' } },
        { subject: { subjectCode: 'asc' } },
      ],
    })

    // Group records by academic year for better organization
    const recordsByYear = academicRecords.reduce((acc, record) => {
      const yearName = record.studentAcademicYear?.academicYear.yearName || 
                     record.semester.academicYear.yearName
      
      if (!acc[yearName]) {
        acc[yearName] = {
          academicYear: yearName,
          classLevel: record.studentAcademicYear?.classLevel,
          section: record.studentAcademicYear?.section,
          rollNumber: record.studentAcademicYear?.rollNumber,
          records: [],
        }
      }
      
      acc[yearName].records.push({
        id: record.id,
        subject: record.subject,
        semester: {
          id: record.semester.id,
          semesterName: record.semester.semesterName,
          semesterNumber: record.semester.semesterNumber,
        },
        marksObtained: record.marksObtained ? parseFloat(record.marksObtained.toString()) : null,
        maxMarks: record.maxMarks ? parseFloat(record.maxMarks.toString()) : null,
        grade: record.grade,
        gradePoints: record.gradePoints ? parseFloat(record.gradePoints.toString()) : null,
        creditsEarned: record.creditsEarned,
        status: record.status,
        remarks: record.remarks,
      })
      
      return acc
    }, {} as Record<string, {
      academicYear: string
      classLevel?: number
      section?: string | null
      rollNumber?: string
      records: Array<{
        id: number
        subject: { id: number; subjectName: string; subjectCode: string; credits: number }
        semester: { id: number; semesterName: string; semesterNumber: number }
        marksObtained: number | null
        maxMarks: number | null
        grade: string | null
        gradePoints: number | null
        creditsEarned: number | null
        status: string
        remarks: string | null
      }>
    }>)

    return {
      success: true,
      data: {
        byAcademicYear: Object.values(recordsByYear),
        allRecords: academicRecords.map(record => ({
          id: record.id,
          subject: record.subject,
          semester: record.semester,
          academicYear: record.studentAcademicYear?.academicYear.yearName || 
                       record.semester.academicYear.yearName,
          classLevel: record.studentAcademicYear?.classLevel,
          marksObtained: record.marksObtained ? parseFloat(record.marksObtained.toString()) : null,
          maxMarks: record.maxMarks ? parseFloat(record.maxMarks.toString()) : null,
          grade: record.grade,
          gradePoints: record.gradePoints ? parseFloat(record.gradePoints.toString()) : null,
          creditsEarned: record.creditsEarned,
          status: record.status,
          remarks: record.remarks,
        })),
      },
    }
  }

  async getAttendance(
    id: number,
    startDate?: string,
    endDate?: string,
    academicYearId?: number,
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

    const options: AttendanceQueryOptions = {
      studentId: id,
    }

    if (startDate) {
      options.startDate = new Date(startDate)
    }

    if (endDate) {
      options.endDate = new Date(endDate)
    }

    if (academicYearId) {
      options.academicYearId = academicYearId
    }

    // Use the new attendance service
    const attendanceResult = await this.attendanceService.getAttendanceRecords(options as AttendanceQueryOptions)

    // Also get attendance summary
    const summaryResult = await this.attendanceService.getAttendanceSummary(id, academicYearId)

    return {
      success: true,
      data: {
        records: attendanceResult.data,
        summary: summaryResult.data,
        pagination: attendanceResult.pagination,
      },
    }
  }

  // UUID-based methods
  async updateByUuid(uuid: string, updateStudentDto: UpdateStudentDto) {
    // First find the student by UUID with course information
    const student = await this.prisma.student.findFirst({
      where: {
        user: { uuid },
      },
      include: {
        course: {
          select: {
            id: true,
            code: true,
          },
        },
      },
    })

    if (!student) {
      throw new NotFoundException(`Student with UUID ${uuid} not found`)
    }

    // Auto-generate roll number if conditions are met
    if (this.shouldGenerateRollNumber(student, updateStudentDto)) {
      try {
        const courseCode = await this.getCourseCode(updateStudentDto.courseId || student.courseId)
        const rollNumber = await this.idGenerationService.generateRollNumber({
          institutionId: student.institutionId,
          courseCode: courseCode || 'GEN',
          section: updateStudentDto.section || student.section || 'A',
        })
        updateStudentDto.rollNumber = rollNumber
      } catch (error) {
        // Log error but don't fail the update - roll number can be generated later
        console.warn('Failed to generate roll number:', error.message)
      }
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
    return this.getAttendance(student.id, startDate, endDate, undefined, currentUser)
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
      include: { subject: true },
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
      include: { subject: true },
    })

    const courseIds = enrollments.map(e => e.subjectId)

    // Build where clause
    const where: Prisma.AssignmentWhereInput = {
      subjectId: { in: courseIds },
      status: 'PUBLISHED',
    }

    // Get assignments with submissions
    const assignments = await this.prisma.assignment.findMany({
      where,
      include: {
        subject: { select: { subjectName: true, subjectCode: true } },
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
        subject: assignment.subject.subjectName,
        dueDate: assignment.dueDate.toISOString().split('T')[0],
        status: assignmentStatus,
        grade,
        score,
        maxMarks: assignment.maxMarks,
        marksObtained: submission?.marksObtained
          ? parseFloat(submission.marksObtained.toString())
          : undefined,
        description: assignment.description,
        instructions: assignment.instructions,
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

  async getExaminationsByUuid(
    uuid: string,
    status?: 'SCHEDULED' | 'ONGOING' | 'COMPLETED' | 'CANCELLED',
    currentUser?: UserWithRelations
  ) {
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
      include: { subject: true },
    })

    const courseIds = enrollments.map(e => e.subjectId)

    // Build where clause
    const where: Prisma.ExaminationWhereInput = {
      subjectId: { in: courseIds },
      // Only show scheduled, ongoing, or completed exams
      ...(status ? { status } : { status: { in: ['SCHEDULED', 'ONGOING', 'COMPLETED'] as const } }),
    }

    const examinations = await this.prisma.examination.findMany({
      where,
      include: {
        subject: { select: { subjectName: true, subjectCode: true } },
        results: {
          where: { studentId: student.id },
          take: 1,
        },
      },
      orderBy: { examDate: 'desc' },
    })

    const examinationData = examinations.map(exam => {
      const result = exam.results[0]
      const examStatus = exam.status
      let grade: string | undefined
      let score: string | undefined

      if (result) {
        if (result.marksObtained) {
          score = `${result.marksObtained}/${exam.totalMarks}`
        }
      }

      return {
        id: exam.id,
        name: exam.examName,
        subject: exam.subject.subjectName,
        date: exam.examDate?.toISOString().split('T')[0],
        startTime: exam.startTime?.toISOString(),
        duration: exam.durationMinutes,
        totalMarks: exam.totalMarks,
        status: examStatus,
        score,
        grade,
      }
    })

    return {
      success: true,
      data: examinationData,
    }
  }

  async getPublishedQuestionPaperByUuid(
    uuid: string,
    examId: number,
    currentUser: UserWithRelations
  ) {
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

    // Find the examination and its linked question paper
    const examination = await this.prisma.examination.findUnique({
      where: { id: examId },
      include: {
        subject: {
          include: {
            course: true,
          },
        },
        semester: {
          include: {
            academicYear: {
              include: {
                institution: true,
              },
            },
          },
        },
        questionPaper: {
          include: {
            sections: {
              include: {
                questions: {
                  include: {
                    options: {
                      orderBy: {
                        sortOrder: 'asc',
                      },
                    },
                  },
                  orderBy: {
                    sortOrder: 'asc',
                  },
                },
              },
              orderBy: {
                sortOrder: 'asc',
              },
            },
          },
        },
      },
    })

    if (!examination) {
      throw new NotFoundException('Examination not found')
    }

    if (!examination.questionPaper) {
      throw new NotFoundException(
        'Question paper not found for this examination'
      )
    }

    // Check if question paper is published
    if (
      examination.questionPaper.status !== 'PUBLISHED' &&
      examination.questionPaper.status !== 'DRAFT'
    ) {
      throw new ForbiddenException('Question paper is not published yet')
    }

    const { questionPaper, subject, semester } = examination
    const institution = semester.academicYear.institution

    // Map to QuestionPaperTemplate structure
    // Map to QuestionPaperTemplate structure
    const data = {
      schoolName: institution.name,
      schoolAddress: institution.address || '',
      examName: examination.examName,
      className: subject.course?.name || semester.semesterName,
      section: '', // Examination is not tied to a single section
      subject: subject.subjectName,
      date: examination.examDate
        ? examination.examDate.toISOString().split('T')[0]
        : '',
      duration: examination.durationMinutes
        ? examination.durationMinutes.toString()
        : '0',
      maxMarks: questionPaper.totalMarks,
      sections: questionPaper.sections.map(section => ({
        sectionName: section.name,
        description: section.description,
        marksPerQuestion: 0, // All questions have custom marks
        questions: section.questions.map(question => ({
          questionText: question.text,
          customMarks: question.marks,
          type: question.questionType === 'MCQ' ? 'mcq' : 'written', // Map to QuestionType enum string
          hasImage: false, // Not yet supported in backend
          imagePlaceholder: null,
          mcqOptions: question.options.map(o => o.text),
        })),
      })),
      instructions: questionPaper.instructions,
      logo: null,
    }

    return {
      success: true,
      data,
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
        subject: { select: { subjectName: true, subjectCode: true } },
        semester: { select: { semesterName: true } },
      },
      orderBy: { createdAt: 'asc' },
    })

    // Group by subject and create trends
    const subjectMap = new Map()

    progressData.forEach(progress => {
      const subjectKey = progress.subject.subjectCode
      if (!subjectMap.has(subjectKey)) {
        subjectMap.set(subjectKey, {
          subject: progress.subject.subjectName,
          subjectCode: progress.subject.subjectCode,
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
        subject: { select: { subjectName: true, subjectCode: true } },
      },
    })

    // Get enrollments to find teachers
    const enrollments = await this.prisma.enrollment.findMany({
      where: {
        studentId: student.id,
        semesterId: currentSemester.id,
      },
      include: {
        subject: {
          select: {
            subjectName: true,
            subjectCode: true,
            classSections: {
              include: {
                teacher: {
                  include: { user: { select: { firstName: true, lastName: true } } },
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
        subject: { select: { subjectName: true, subjectCode: true } },
      },
      orderBy: { examDate: 'asc' },
    })

    const subjects = progressData.map(progress => {
      // Find teacher for this subject - match by subject name
      const enrollment = enrollments.find(e =>
        e.subject.subjectName
          .toLowerCase()
          .includes(progress.subject.subjectName.toLowerCase())
      )
      const teacher =
        enrollment?.subject.classSections[0]?.teacher?.user ? 
          this.getFullName(enrollment.subject.classSections[0].teacher.user.firstName, enrollment.subject.classSections[0].teacher.user.lastName) : 'TBD'

      // Find next test
      const nextExam = upcomingExams.find(exam =>
        exam.subject.subjectName
          .toLowerCase()
          .includes(progress.subject.subjectName.toLowerCase())
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
        subject: progress.subject.subjectName,
        subjectCode: progress.subject.subjectCode,
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
    startDateStr?: string,
    endDateStr?: string,
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
    const startDate = startDateStr ? new Date(startDateStr) : now
    const endDate = endDateStr ? new Date(endDateStr) : undefined

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
      select: { subjectId: true },
    })
    const enrolledCourseIds = enrollments.map(e => e.subjectId)

    // Get upcoming exams for enrolled courses
    const upcomingExams = await this.prisma.examination.findMany({
      where: {
        examDate: endDate
          ? { gte: startDate, lte: endDate }
          : { gte: startDate },
        status: { in: ['SCHEDULED', 'ONGOING'] },
        subjectId: { in: enrolledCourseIds },
      },
      include: {
        subject: { select: { subjectName: true, subjectCode: true } },
      },
      orderBy: { examDate: 'asc' },
      take: limit,
    })

    upcomingExams.forEach(exam => {
      events.push({
        id: exam.id,
        title:
          exam.examName ||
          `${exam.subject.subjectName} - ${exam.examType} Exam`,
        date: exam.examDate?.toISOString().split('T')[0] || '',
        time: exam.startTime?.toISOString().slice(11, 16) || '10:00',
        type: 'test' as const,
        subject: exam.subject.subjectName,
        description: `${exam.examType} - ${exam.subject.subjectName}`,
      })
    })

    // Get upcoming assignments for enrolled courses
    const upcomingAssignments = await this.prisma.assignment.findMany({
      where: {
        dueDate: endDate
          ? { gte: startDate, lte: endDate }
          : { gte: startDate },
        status: 'PUBLISHED',
        subjectId: { in: enrolledCourseIds },
        submissions: {
          none: { studentId: student.id },
        },
      },
      include: {
        subject: { select: { subjectName: true, subjectCode: true } },
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
        subject: assignment.subject.subjectName,
        description: `Assignment Due - ${assignment.subject.subjectName}`,
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

  // ============================================================================
  // REPORT CARD GENERATION
  // ============================================================================

  async generateReportCardByUuid(
    uuid: string,
    queryParams: ReportCardQueryParams,
    currentUser: UserWithRelations
  ): Promise<ReportCardResponse> {
    // Find student by UUID with all required relations
    const student = await this.prisma.student.findFirst({
      where: { user: { uuid } },
      include: {
        user: {
          select: {
            id: true,
            uuid: true,
            kramid: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },
        institution: {
          select: {
            id: true,
            name: true,
          },
        },
        course: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
      },
    })

    if (!student) {
      throw new NotFoundException(`Student with UUID ${uuid} not found`)
    }

    // Check permissions - students can only see their own report cards
    // Parents can see their children's report cards (handled by parent guard)
    // Teachers and admins can see all
    if (
      currentUser.role.roleName === 'student' &&
      currentUser.student?.userId !== student.userId
    ) {
      throw new ForbiddenException('Access denied')
    }

    // Determine semester to use
    let semester
    if (queryParams.semesterId) {
      semester = await this.prisma.semester.findUnique({
        where: { id: queryParams.semesterId },
        include: {
          academicYear: {
            select: {
              yearName: true,
            },
          },
        },
      })
    } else {
      // Get the most recent completed semester or current active semester
      semester = await this.prisma.semester.findFirst({
        where: {
          status: { in: ['ACTIVE', 'COMPLETED'] },
        },
        orderBy: [{ status: 'asc' }, { semesterNumber: 'desc' }],
        include: {
          academicYear: {
            select: {
              yearName: true,
            },
          },
        },
      })
    }

    if (!semester) {
      throw new NotFoundException(
        'No semester found for report card generation'
      )
    }

    // Build report card components in parallel
    const [
      academicRecords,
      attendanceSummaryData,
      examResults,
      studentProgress,
      classRankData,
      cumulativeRecords,
    ] = await Promise.all([
      // Get academic records for the semester
      this.prisma.academicRecord.findMany({
        where: {
          studentId: student.id,
          semesterId: semester.id,
        },
        include: {
          subject: {
            select: {
              id: true,
              subjectName: true,
              subjectCode: true,
              credits: true,
            },
          },
        },
        orderBy: { subject: { subjectCode: 'asc' } },
      }),

      // Get attendance summary from optimized view (replaces individual attendance query)
      this.getAttendanceSummaryFromView(student.id, semester.id),

      // Get exam results if requested
      queryParams.includeExamDetails !== false
        ? this.prisma.examResult.findMany({
            where: {
              studentId: student.id,
              exam: {
                semesterId: semester.id,
              },
            },
            include: {
              exam: {
                select: {
                  examName: true,
                  examType: true,
                  totalMarks: true,
                },
              },
            },
          })
        : Promise.resolve([]),

      // Get student progress for remarks
      this.prisma.studentProgress.findMany({
        where: {
          studentId: student.id,
          semesterId: semester.id,
        },
        orderBy: { updatedAt: 'desc' },
        take: 1,
      }),

      // Get class rank data
      this.prisma.academicRecord.groupBy({
        by: ['studentId'],
        where: { semesterId: semester.id },
        _avg: { gradePoints: true },
        _sum: { creditsEarned: true },
      }),

      // Get cumulative records for CGPA
      this.prisma.academicRecord.findMany({
        where: { studentId: student.id },
        select: {
          gradePoints: true,
          creditsEarned: true,
        },
      }),
    ])

    // Build student info
    const studentInfo: ReportCardStudentInfo = {
      name: this.getFullName(student.user.firstName, student.user.lastName),
      kramid: student.user.kramid,
      admissionNumber: student.admissionNumber,
      rollNumber: student.rollNumber,
      courseName: student.course?.name || null,
      courseCode: student.course?.code || null,
      currentSemester: student.currentSemester,
      currentYear: student.currentYear,
      section: student.section,
      institutionName: student.institution.name,
    }

    // Build semester info
    const semesterInfo: ReportCardSemesterInfo = {
      semesterId: semester.id,
      semesterName: semester.semesterName,
      semesterNumber: semester.semesterNumber,
      academicYear: semester.academicYear.yearName,
      startDate: semester.startDate.toISOString().split('T')[0],
      endDate: semester.endDate.toISOString().split('T')[0],
    }

    // Build subject records
    const subjectRecords: ReportCardSubjectRecord[] = academicRecords.map(
      record => {
        const marksObtained = record.marksObtained
          ? parseFloat(record.marksObtained.toString())
          : null
        const maxMarks = record.maxMarks
          ? parseFloat(record.maxMarks.toString())
          : null
        const percentage =
          marksObtained !== null && maxMarks !== null && maxMarks > 0
            ? Math.round((marksObtained / maxMarks) * 100 * 100) / 100
            : null

        return {
          subjectName: record.subject.subjectName,
          subjectCode: record.subject.subjectCode,
          credits: record.subject.credits,
          marksObtained,
          maxMarks,
          percentage,
          grade: record.grade,
          gradePoints: record.gradePoints
            ? parseFloat(record.gradePoints.toString())
            : null,
          status: record.status as
            | 'PASSED'
            | 'FAILED'
            | 'INCOMPLETE'
            | 'WITHDRAWN',
          teacherRemarks: record.remarks || undefined,
        }
      }
    )

    // Build exam summaries
    const examSummaries: ReportCardExamSummary[] = examResults.map(result => {
      const marksObtained = result.marksObtained
        ? parseFloat(result.marksObtained.toString())
        : 0
      const totalMarks = result.exam.totalMarks || 100
      const percentage =
        Math.round((marksObtained / totalMarks) * 100 * 100) / 100

      // Calculate grade based on percentage
      let grade = 'F'
      if (percentage >= 90) grade = 'A+'
      else if (percentage >= 80) grade = 'A'
      else if (percentage >= 70) grade = 'B+'
      else if (percentage >= 60) grade = 'B'
      else if (percentage >= 50) grade = 'C'
      else if (percentage >= 40) grade = 'D'

      return {
        examType: result.exam.examType,
        examName: result.exam.examName || `${result.exam.examType} Exam`,
        totalMarks,
        marksObtained,
        percentage,
        grade,
        rank: result.rankInClass || undefined,
      }
    })

    // Build attendance summary from optimized view data
    const totalClasses = attendanceSummaryData.reduce(
      (sum, record) => sum + Number(record.total_classes),
      0
    )
    const classesAttended = attendanceSummaryData.reduce(
      (sum, record) =>
        sum + Number(record.classes_present) + Number(record.classes_late),
      0
    )
    const classesAbsent = attendanceSummaryData.reduce(
      (sum, record) => sum + Number(record.classes_absent),
      0
    )
    const attendancePercentage =
      totalClasses > 0
        ? Math.round((classesAttended / totalClasses) * 100 * 100) / 100
        : 0

    let attendanceStatus: 'excellent' | 'good' | 'satisfactory' | 'poor' =
      'poor'
    if (attendancePercentage >= 90) attendanceStatus = 'excellent'
    else if (attendancePercentage >= 75) attendanceStatus = 'good'
    else if (attendancePercentage >= 60) attendanceStatus = 'satisfactory'

    const attendanceSummary: ReportCardAttendanceSummary = {
      totalClasses,
      classesAttended,
      classesAbsent,
      percentage: attendancePercentage,
      status: attendanceStatus,
    }

    // Calculate SGPA (Semester Grade Point Average)
    let totalGradePoints = 0
    let totalCredits = 0
    for (const record of academicRecords) {
      if (record.gradePoints && record.creditsEarned) {
        totalGradePoints +=
          parseFloat(record.gradePoints.toString()) * record.creditsEarned
        totalCredits += record.creditsEarned
      }
    }
    const sgpa4 =
      totalCredits > 0
        ? Math.round((totalGradePoints / totalCredits) * 100) / 100
        : 0
    // Convert to 10-point scale (4 * 2.5 = 10)
    const sgpa = Math.round(Math.min(10, (sgpa4 / 4) * 10) * 100) / 100

    // Calculate CGPA (Cumulative Grade Point Average)
    let cumulativeGradePoints = 0
    let cumulativeCredits = 0
    for (const record of cumulativeRecords) {
      if (record.gradePoints && record.creditsEarned) {
        cumulativeGradePoints +=
          parseFloat(record.gradePoints.toString()) * record.creditsEarned
        cumulativeCredits += record.creditsEarned
      }
    }
    const cgpa4 =
      cumulativeCredits > 0
        ? Math.round((cumulativeGradePoints / cumulativeCredits) * 100) / 100
        : 0
    const cgpa = Math.round(Math.min(10, (cgpa4 / 4) * 10) * 100) / 100

    // Calculate class rank
    const studentGpas = classRankData
      .map(record => ({
        studentId: record.studentId,
        gpa:
          record._sum.creditsEarned && record._avg.gradePoints
            ? parseFloat(record._avg.gradePoints.toString())
            : 0,
      }))
      .sort((a, b) => b.gpa - a.gpa)

    const studentRankIndex = studentGpas.findIndex(
      s => s.studentId === student.id
    )
    const classRank = studentRankIndex >= 0 ? studentRankIndex + 1 : null
    const totalStudentsInClass = studentGpas.length
    const percentile =
      classRank !== null && totalStudentsInClass > 0
        ? Math.round(
            ((totalStudentsInClass - classRank) / totalStudentsInClass) *
              100 *
              100
          ) / 100
        : null

    // Determine overall grade (SGPA on 10-point scale)
    let overallGrade = 'F'
    if (sgpa >= 9.0) overallGrade = 'A+'
    else if (sgpa >= 8.0) overallGrade = 'A'
    else if (sgpa >= 7.0) overallGrade = 'B+'
    else if (sgpa >= 6.0) overallGrade = 'B'
    else if (sgpa >= 5.0) overallGrade = 'C'
    else if (sgpa >= 4.0) overallGrade = 'D'

    // Determine overall status
    const failedSubjects = subjectRecords.filter(
      r => r.status === 'FAILED'
    ).length
    let overallStatus: 'PASSED' | 'FAILED' | 'PROMOTED' | 'DETAINED' = 'PASSED'
    if (failedSubjects > 0 && attendancePercentage < 75) {
      overallStatus = 'DETAINED'
    } else if (failedSubjects > 0) {
      overallStatus = 'FAILED'
    } else if (sgpa < 5.0 && attendancePercentage >= 75) {
      overallStatus = 'PROMOTED'
    }

    const performanceSummary: ReportCardPerformanceSummary = {
      sgpa,
      cgpa,
      totalCreditsEarned: totalCredits,
      totalCreditsAttempted: academicRecords.reduce(
        (sum, r) => sum + r.subject.credits,
        0
      ),
      classRank,
      totalStudents: totalStudentsInClass > 0 ? totalStudentsInClass : null,
      percentile,
      overallGrade,
      overallStatus,
    }

    // Build remarks from student progress
    const latestProgress = studentProgress[0]
    const remarks: ReportCardRemarks = {
      classTeacherRemarks: latestProgress?.teacherComments || undefined,
      strengths: latestProgress?.strengths || [],
      areasForImprovement: latestProgress?.areasForImprovement || [],
    }

    // Generate report card number
    const reportCardNumber = `RC-${student.institution.id}-${student.id}-${semester.id}-${Date.now().toString(36).toUpperCase()}`

    // Build final report card
    const reportCard: ReportCard = {
      studentInfo,
      semesterInfo,
      subjectRecords,
      examSummaries,
      attendanceSummary,
      performanceSummary,
      remarks,
      generatedAt: new Date().toISOString(),
      reportCardNumber,
    }

    return {
      success: true,
      data: reportCard,
    }
  }

  /**
   * Determines if a roll number should be auto-generated
   */
  private shouldGenerateRollNumber(
    student: { rollNumber?: string | null; courseId?: number | null; section?: string | null },
    updateDto: UpdateStudentDto,
  ): boolean {
    // Don't generate if roll number is manually provided
    if (updateDto.rollNumber) {
      return false
    }

    // Don't generate if student already has a roll number
    if (student.rollNumber) {
      return false
    }

    // Generate if course and section are being assigned
    const hasCourse = updateDto.courseId || student.courseId
    const hasSection = updateDto.section || student.section

    return !!(hasCourse && hasSection)
  }

  /**
   * Gets course code for roll number generation
   */
  private async getCourseCode(courseId?: number): Promise<string | null> {
    if (!courseId) return null

    const course = await this.prisma.course.findUnique({
      where: { id: courseId },
      select: { code: true, name: true },
    })

    return course?.code || course?.name?.substring(0, 3).toUpperCase() || null
  }

  // ============================================================================
  // ACADEMIC PROGRESSION METHODS
  // ============================================================================

  /**
   * Get student's academic history across all years
   */
  async getAcademicHistory(
    studentId: number,
    currentUser: UserWithRelations
  ) {
    // Check access permissions
    if (
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== studentId
    ) {
      throw new ForbiddenException('Access denied')
    }

    return this.academicProgressionService.getStudentAcademicHistory(studentId, {
      includeCurrentYear: true,
      limit: 50,
    })
  }

  /**
   * Get current academic year information for a student
   */
  async getCurrentAcademicYear(
    studentId: number,
    currentUser: UserWithRelations
  ) {
    // Check access permissions
    if (
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== studentId
    ) {
      throw new ForbiddenException('Access denied')
    }

    return this.academicProgressionService.getCurrentAcademicYear(studentId)
  }

  /**
   * Enroll student in a new academic year
   */
  async enrollInAcademicYear(
    studentId: number,
    enrollmentData: {
      academicYearId: number
      classLevel: number
      section?: string
      rollNumber?: string
      classDivisionId?: number
      classTeacherId?: number
    },
    currentUser: UserWithRelations
  ) {
    // Check permissions - only admins and authorized staff can enroll students
    if (!['admin', 'super_admin', 'staff'].includes(currentUser.role.roleName)) {
      throw new ForbiddenException('Access denied')
    }

    // Verify student exists and user has access
    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
    })

    if (!student) {
      throw new NotFoundException('Student not found')
    }

    const resolvedInstitutionId =
      currentUser.institutionId ??
      currentUser.staff?.institutionId ??
      null

    if (
      currentUser.role.roleName === 'admin' &&
      resolvedInstitutionId !== null &&
      student.institutionId !== resolvedInstitutionId
    ) {
      throw new ForbiddenException('Access denied to this student')
    }

    return this.academicProgressionService.createStudentAcademicYear({
      studentId,
      academicYearId: enrollmentData.academicYearId,
      classLevel: enrollmentData.classLevel,
      section: enrollmentData.section,
      rollNumber: enrollmentData.rollNumber || `${enrollmentData.classLevel}-${Date.now().toString(36).toUpperCase()}`,
      classDivisionId: enrollmentData.classDivisionId,
      classTeacherId: enrollmentData.classTeacherId,
      enrollmentDate: new Date().toISOString(),
    })
  }

  /**
   * Promote student to next academic year
   */
  async promoteStudent(
    studentId: number,
    promotionData: {
      currentAcademicYearId: number
      nextAcademicYearId: number
      nextClassLevel: number
      nextSection?: string
      nextRollNumber?: string
      nextClassDivisionId?: number
      nextClassTeacherId?: number
      finalGrade?: string
      finalPercentage?: number
      finalAttendancePercentage?: number
    },
    currentUser: UserWithRelations
  ) {
    // Check permissions - only admins and authorized staff can promote students
    if (!['admin', 'super_admin', 'staff'].includes(currentUser.role.roleName)) {
      throw new ForbiddenException('Access denied')
    }

    // Verify student exists and user has access
    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
    })

    if (!student) {
      throw new NotFoundException('Student not found')
    }

    const resolvedInstitutionId =
      currentUser.institutionId ??
      currentUser.staff?.institutionId ??
      null

    if (
      currentUser.role.roleName === 'admin' &&
      resolvedInstitutionId !== null &&
      student.institutionId !== resolvedInstitutionId
    ) {
      throw new ForbiddenException('Access denied to this student')
    }

    return this.academicProgressionService.promoteStudent(studentId, promotionData)
  }

  /**
   * Get students by academic year and class
   */
  async getStudentsByAcademicYear(
    academicYearId: number,
    classLevel?: number,
    classDivisionId?: number,
    _currentUser?: UserWithRelations
  ) {
    const result = await this.academicProgressionService.getStudentsByAcademicYear(
      academicYearId,
      classLevel,
      classDivisionId
    )

    // TODO: Apply institution filtering at the service level for non-super-admin users
    // For now, we'll return the result as-is since institution filtering should be done at the query level

    return result
  }

  // ============================================================================
  // ATTENDANCE METHODS (Delegated to AttendanceService)
  // ============================================================================

  /**
   * Record attendance for a student
   */
  async recordAttendance(
    attendanceData: {
      studentId: number
      date: Date
      status: 'PRESENT' | 'ABSENT' | 'LATE' | 'EXCUSED'
      attendanceType?: 'DAILY' | 'SUBJECT_WISE' | 'EVENT' | 'EXAM'
      sectionId?: number
      remarks?: string
    },
    currentUser: UserWithRelations
  ) {
    // Check permissions - only teachers, admins, and staff can record attendance
    if (!['teacher', 'admin', 'super_admin', 'staff'].includes(currentUser.role.roleName)) {
      throw new ForbiddenException('Access denied')
    }

    return this.attendanceService.recordAttendance({
      ...attendanceData,
      markedBy: currentUser.teacher?.id || currentUser.staff?.id || 1, // Get teacher/staff ID
    })
  }

  /**
   * Get attendance summary for a student
   */
  async getAttendanceSummary(
    studentId: number,
    academicYearId?: number,
    currentUser?: UserWithRelations
  ) {
    // Check access permissions
    if (
      currentUser &&
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== studentId
    ) {
      throw new ForbiddenException('Access denied')
    }

    return this.attendanceService.getAttendanceSummary(studentId, academicYearId)
  }

  /**
   * Get attendance trends for a student across academic years
   */
  async getAttendanceTrends(
    studentId: number,
    startAcademicYear?: number,
    endAcademicYear?: number,
    currentUser?: UserWithRelations
  ) {
    // Check access permissions
    if (
      currentUser &&
      currentUser.role.roleName === 'student' &&
      currentUser.student?.id !== studentId
    ) {
      throw new ForbiddenException('Access denied')
    }

    return this.attendanceService.getAttendanceTrends(
      studentId,
      startAcademicYear,
      endAcademicYear
    )
  }
}
