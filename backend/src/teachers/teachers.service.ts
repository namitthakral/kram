import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'
import {
  CreateTeacherDto,
  UpdateTeacherDto,
  TeacherQueryDto,
  AssignSubjectsDto,
} from './dto/teacher.dto'
import { Prisma } from '.prisma/client'
import * as bcrypt from 'bcrypt'

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
}
