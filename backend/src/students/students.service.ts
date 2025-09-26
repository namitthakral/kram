import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'
import {
  CreateStudentDto,
  UpdateStudentDto,
  PaginationDto,
} from './dto/student.dto'
import { UserWithRelations } from '../types/auth.types'

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
    } = {}
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
    const student = await this.prisma.student.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
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

  async create(createStudentDto: CreateStudentDto) {
    const student = await this.prisma.student.create({
      data: createStudentDto,
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
      message: 'Student created successfully',
    }
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
    await this.prisma.student.delete({
      where: { id },
    })

    return {
      success: true,
      message: 'Student deleted successfully',
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
}
