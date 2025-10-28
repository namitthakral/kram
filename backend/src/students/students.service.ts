import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'
import * as bcrypt from 'bcrypt'
import { PrismaService } from '../prisma/prisma.service'
import { UserWithRelations } from '../types/auth.types'
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
}
