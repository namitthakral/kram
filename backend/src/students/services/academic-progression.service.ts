import {
  ConflictException,
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common'
import { Prisma, PromotionStatus } from '@prisma/client'
import { PrismaService } from '../../prisma/prisma.service'
import { IdGenerationService } from '../../id-generation/id-generation.service'
import {
  CreateStudentAcademicYearDto,
  UpdateStudentAcademicYearDto,
  PromoteStudentDto,
  StudentAcademicHistoryQueryDto,
  BulkPromotionDto,
} from '../dto/academic-year.dto'

export interface StudentAcademicYearWithRelations {
  id: number
  studentId: number
  academicYearId: number
  classLevel: number
  section: string | null
  rollNumber: string
  classDivisionId: number | null
  classTeacherId: number | null
  currentRollNumber: string | null
  boardRollNumber: string | null
  promotionStatus: PromotionStatus
  finalGrade: string | null
  finalPercentage: any | null
  attendancePercentage: any | null
  totalWorkingDays: number | null
  totalDaysPresent: number | null
  enrollmentDate: Date
  completionDate: Date | null
  createdAt: Date
  updatedAt: Date
  student: {
    id: number
    admissionNumber: string
    user: {
      id: number
      firstName: string
      lastName: string
      email: string
    }
  }
  academicYear: {
    id: number
    yearName: string
    startDate: Date
    endDate: Date
    status: string
  }
  classDivision?: {
    id: number
    sectionName: string
    course: {
      name: string
      code: string
    }
  } | null
  classTeacher?: {
    id: number
    user: {
      firstName: string
      lastName: string
    }
  } | null
}

@Injectable()
export class AcademicProgressionService {
  constructor(
    private prisma: PrismaService,
    private idGenerationService: IdGenerationService,
  ) {}

  /**
   * Create a new academic year record for a student
   */
  async createStudentAcademicYear(
    dto: CreateStudentAcademicYearDto,
  ): Promise<{
    success: boolean
    data: StudentAcademicYearWithRelations
    message: string
  }> {
    // Validate student exists
    const student = await this.prisma.student.findUnique({
      where: { id: dto.studentId },
      include: { institution: true },
    })

    if (!student) {
      throw new NotFoundException(`Student with ID ${dto.studentId} not found`)
    }

    // Validate academic year exists
    const academicYear = await this.prisma.academicYear.findUnique({
      where: { id: dto.academicYearId },
    })

    if (!academicYear) {
      throw new NotFoundException(
        `Academic year with ID ${dto.academicYearId} not found`,
      )
    }

    // Check if student already has a record for this academic year
    const existingRecord = await this.prisma.studentAcademicYear.findUnique({
      where: {
        studentId_academicYearId: {
          studentId: dto.studentId,
          academicYearId: dto.academicYearId,
        },
      },
    })

    if (existingRecord) {
      throw new ConflictException(
        'Student already has a record for this academic year',
      )
    }

    // Validate roll number uniqueness within academic year and class division
    if (dto.classDivisionId) {
      const existingRollNumber = await this.prisma.studentAcademicYear.findUnique(
        {
          where: {
            academicYearId_classDivisionId_rollNumber: {
              academicYearId: dto.academicYearId,
              classDivisionId: dto.classDivisionId,
              rollNumber: dto.rollNumber,
            },
          },
        },
      )

      if (existingRollNumber) {
        throw new ConflictException(
          'Roll number already exists for this class division in the academic year',
        )
      }
    }

    // Create the academic year record
    const studentAcademicYear = await this.prisma.studentAcademicYear.create({
      data: {
        studentId: dto.studentId,
        academicYearId: dto.academicYearId,
        classLevel: dto.classLevel,
        section: dto.section,
        rollNumber: dto.rollNumber,
        classDivisionId: dto.classDivisionId,
        classTeacherId: dto.classTeacherId,
        currentRollNumber: dto.currentRollNumber,
        boardRollNumber: dto.boardRollNumber,
        promotionStatus: dto.promotionStatus || PromotionStatus.IN_PROGRESS,
        finalGrade: dto.finalGrade,
        finalPercentage: dto.finalPercentage,
        attendancePercentage: dto.attendancePercentage,
        totalWorkingDays: dto.totalWorkingDays || 0,
        totalDaysPresent: dto.totalDaysPresent || 0,
        enrollmentDate: new Date(dto.enrollmentDate),
        completionDate: dto.completionDate ? new Date(dto.completionDate) : null,
      },
      include: {
        student: {
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
        },
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
    })

    return {
      success: true,
      data: studentAcademicYear,
      message: 'Student academic year record created successfully',
    }
  }

  /**
   * Update an existing academic year record for a student
   */
  async updateStudentAcademicYear(
    id: number,
    dto: UpdateStudentAcademicYearDto,
  ): Promise<{
    success: boolean
    data: StudentAcademicYearWithRelations
    message: string
  }> {
    const existingRecord = await this.prisma.studentAcademicYear.findUnique({
      where: { id },
    })

    if (!existingRecord) {
      throw new NotFoundException(
        `Student academic year record with ID ${id} not found`,
      )
    }

    // Validate roll number uniqueness if being updated
    if (dto.rollNumber && dto.rollNumber !== existingRecord.rollNumber) {
      const classDivisionId = dto.classDivisionId || existingRecord.classDivisionId
      
      if (classDivisionId) {
        const existingRollNumber = await this.prisma.studentAcademicYear.findFirst(
          {
            where: {
              academicYearId: existingRecord.academicYearId,
              classDivisionId,
              rollNumber: dto.rollNumber,
              id: { not: id }, // Exclude current record
            },
          },
        )

        if (existingRollNumber) {
          throw new ConflictException(
            'Roll number already exists for this class division in the academic year',
          )
        }
      }
    }

    const updatedRecord = await this.prisma.studentAcademicYear.update({
      where: { id },
      data: {
        ...dto,
        enrollmentDate: dto.enrollmentDate ? new Date(dto.enrollmentDate) : undefined,
        completionDate: dto.completionDate ? new Date(dto.completionDate) : undefined,
      },
      include: {
        student: {
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
        },
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
    })

    return {
      success: true,
      data: updatedRecord,
      message: 'Student academic year record updated successfully',
    }
  }

  /**
   * Get student's academic history across all years
   */
  async getStudentAcademicHistory(
    studentId: number,
    query: StudentAcademicHistoryQueryDto,
  ): Promise<{
    success: boolean
    data: StudentAcademicYearWithRelations[]
    pagination: {
      total: number
      limit: number
    }
  }> {
    const where: Prisma.StudentAcademicYearWhereInput = {
      studentId,
    }

    if (query.academicYearId) {
      where.academicYearId = query.academicYearId
    }

    if (query.classLevel) {
      where.classLevel = query.classLevel
    }

    if (query.promotionStatus) {
      where.promotionStatus = query.promotionStatus
    }

    if (!query.includeCurrentYear) {
      where.promotionStatus = { not: PromotionStatus.IN_PROGRESS }
    }

    const [records, total] = await Promise.all([
      this.prisma.studentAcademicYear.findMany({
        where,
        include: {
          student: {
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
          },
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
        orderBy: [
          { academicYear: { startDate: 'desc' } },
          { classLevel: 'desc' },
        ],
        take: query.limit || 10,
      }),
      this.prisma.studentAcademicYear.count({ where }),
    ])

    return {
      success: true,
      data: records,
      pagination: {
        total,
        limit: query.limit || 10,
      },
    }
  }

  /**
   * Get current academic year record for a student
   */
  async getCurrentAcademicYear(studentId: number): Promise<{
    success: boolean
    data: StudentAcademicYearWithRelations | null
  }> {
    const currentRecord = await this.prisma.studentAcademicYear.findFirst({
      where: {
        studentId,
        promotionStatus: PromotionStatus.IN_PROGRESS,
      },
      include: {
        student: {
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
        },
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
      orderBy: { academicYear: { startDate: 'desc' } },
    })

    return {
      success: true,
      data: currentRecord,
    }
  }

  /**
   * Promote a student to the next academic year/class
   */
  async promoteStudent(
    studentId: number,
    dto: PromoteStudentDto,
  ): Promise<{
    success: boolean
    data: {
      completedRecord: StudentAcademicYearWithRelations
      newRecord: StudentAcademicYearWithRelations
    }
    message: string
  }> {
    return await this.prisma.$transaction(async (tx) => {
      // Get current academic year record
      const currentRecord = await tx.studentAcademicYear.findUnique({
        where: {
          studentId_academicYearId: {
            studentId,
            academicYearId: dto.currentAcademicYearId,
          },
        },
      })

      if (!currentRecord) {
        throw new NotFoundException(
          'Current academic year record not found for student',
        )
      }

      if (currentRecord.promotionStatus !== PromotionStatus.IN_PROGRESS) {
        throw new BadRequestException(
          'Student is not currently in progress for the specified academic year',
        )
      }

      // Check if student already has a record for the next academic year
      const existingNextRecord = await tx.studentAcademicYear.findUnique({
        where: {
          studentId_academicYearId: {
            studentId,
            academicYearId: dto.nextAcademicYearId,
          },
        },
      })

      if (existingNextRecord) {
        throw new ConflictException(
          'Student already has a record for the next academic year',
        )
      }

      // Generate roll number for next year if not provided
      let nextRollNumber = dto.nextRollNumber
      if (!nextRollNumber && dto.nextClassDivisionId) {
        const classDivision = await tx.classDivision.findUnique({
          where: { id: dto.nextClassDivisionId },
          include: { course: true },
        })

        if (classDivision) {
          try {
            nextRollNumber = await this.idGenerationService.generateRollNumber({
              institutionId: currentRecord.studentId, // This needs to be fixed to get actual institutionId
              courseCode: classDivision.course.code || 'GEN',
              section: dto.nextSection || 'A',
            })
          } catch (error) {
            console.warn('Failed to generate roll number for promotion:', error.message)
            nextRollNumber = `${dto.nextClassLevel}-${Date.now().toString(36).toUpperCase()}`
          }
        }
      }

      if (!nextRollNumber) {
        throw new BadRequestException(
          'Roll number is required for promotion. Please provide nextRollNumber or nextClassDivisionId.',
        )
      }

      // Complete current record
      const completedRecord = await tx.studentAcademicYear.update({
        where: { id: currentRecord.id },
        data: {
          promotionStatus: PromotionStatus.PROMOTED,
          finalGrade: dto.finalGrade,
          finalPercentage: dto.finalPercentage,
          attendancePercentage: dto.finalAttendancePercentage,
          completionDate: new Date(),
        },
        include: {
          student: {
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
          },
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
      })

      // Create new record for next academic year
      const newRecord = await tx.studentAcademicYear.create({
        data: {
          studentId,
          academicYearId: dto.nextAcademicYearId,
          classLevel: dto.nextClassLevel,
          section: dto.nextSection,
          rollNumber: nextRollNumber,
          classDivisionId: dto.nextClassDivisionId,
          classTeacherId: dto.nextClassTeacherId,
          promotionStatus: PromotionStatus.IN_PROGRESS,
          enrollmentDate: new Date(),
        },
        include: {
          student: {
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
          },
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
      })

      return {
        success: true,
        data: {
          completedRecord,
          newRecord,
        },
        message: 'Student promoted successfully',
      }
    })
  }

  /**
   * Bulk promote multiple students
   */
  async bulkPromoteStudents(
    dto: BulkPromotionDto,
  ): Promise<{
    success: boolean
    data: {
      promoted: number[]
      failed: Array<{ studentId: number; error: string }>
    }
    message: string
  }> {
    const promoted: number[] = []
    const failed: Array<{ studentId: number; error: string }> = []

    for (const studentId of dto.studentIds) {
      try {
        // Get student's current record
        const currentRecord = await this.prisma.studentAcademicYear.findUnique({
          where: {
            studentId_academicYearId: {
              studentId,
              academicYearId: dto.currentAcademicYearId,
            },
          },
        })

        if (!currentRecord) {
          failed.push({
            studentId,
            error: 'Current academic year record not found',
          })
          continue
        }

        // Generate roll number if auto-generation is enabled
        let nextRollNumber: string | undefined
        if (dto.autoGenerateRollNumbers && dto.nextClassDivisionId) {
          const classDivision = await this.prisma.classDivision.findUnique({
            where: { id: dto.nextClassDivisionId },
            include: { course: true },
          })

          if (classDivision) {
            try {
              nextRollNumber = await this.idGenerationService.generateRollNumber({
                institutionId: currentRecord.studentId, // This needs to be fixed
                courseCode: classDivision.course.code || 'GEN',
                section: 'A', // Default section
              })
            } catch (error) {
              nextRollNumber = `${currentRecord.classLevel + 1}-${Date.now().toString(36).toUpperCase()}-${studentId}`
            }
          }
        }

        if (!nextRollNumber) {
          nextRollNumber = `${currentRecord.classLevel + 1}-${Date.now().toString(36).toUpperCase()}-${studentId}`
        }

        await this.promoteStudent(studentId, {
          currentAcademicYearId: dto.currentAcademicYearId,
          nextAcademicYearId: dto.nextAcademicYearId,
          nextClassLevel: currentRecord.classLevel + 1,
          nextRollNumber,
          nextClassDivisionId: dto.nextClassDivisionId,
          nextClassTeacherId: dto.nextClassTeacherId,
        })

        promoted.push(studentId)
      } catch (error) {
        failed.push({
          studentId,
          error: error.message,
        })
      }
    }

    return {
      success: true,
      data: { promoted, failed },
      message: `Bulk promotion completed. ${promoted.length} students promoted, ${failed.length} failed.`,
    }
  }

  /**
   * Get students by academic year and class level
   */
  async getStudentsByAcademicYear(
    academicYearId: number,
    classLevel?: number,
    classDivisionId?: number,
  ): Promise<{
    success: boolean
    data: StudentAcademicYearWithRelations[]
  }> {
    const where: Prisma.StudentAcademicYearWhereInput = {
      academicYearId,
    }

    if (classLevel) {
      where.classLevel = classLevel
    }

    if (classDivisionId) {
      where.classDivisionId = classDivisionId
    }

    const students = await this.prisma.studentAcademicYear.findMany({
      where,
      include: {
        student: {
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
        },
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
      orderBy: [
        { classLevel: 'asc' },
        { rollNumber: 'asc' },
      ],
    })

    return {
      success: true,
      data: students,
    }
  }
}