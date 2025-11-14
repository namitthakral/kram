import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'
import { Prisma } from '@prisma/client'
import { PrismaService } from '../prisma/prisma.service'
import { CreateSubjectDto, UpdateSubjectDto } from './dto/subject.dto'

/**
 * Subjects Service
 *
 * Manages academic subjects in Indian education system
 * In Indian context: Subjects/Papers that students study
 * Examples: Data Structures, English, Physics, Chemistry
 */
@Injectable()
export class SubjectsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Find all subjects with optional filters
   */
  async findAll(filters?: {
    courseId?: number // Course = Program/Stream in Indian context
    institutionId?: number
    status?: string
  }) {
    const where: Prisma.SubjectWhereInput = {}

    if (filters?.courseId) {
      where.courseId = filters.courseId
    }

    if (filters?.status) {
      where.status = filters.status as any
    }

    if (filters?.institutionId) {
      where.course = {
        institutionId: filters.institutionId,
      }
    }

    const subjects = await this.prisma.subject.findMany({
      where,
      include: {
        course: {
          select: {
            id: true,
            name: true,
            code: true,
            institution: {
              select: {
                id: true,
                name: true,
                type: true,
              },
            },
          },
        },
        _count: {
          select: {
            enrollments: true,
            assignments: true,
            examinations: true,
            classSections: true,
          },
        },
      },
      orderBy: {
        subjectName: 'asc',
      },
    })

    return subjects
  }

  /**
   * Find one subject by ID
   */
  async findOne(id: number) {
    const subject = await this.prisma.subject.findUnique({
      where: { id },
      include: {
        course: {
          select: {
            id: true,
            name: true,
            code: true,
            degreeType: true,
            institution: {
              select: {
                id: true,
                name: true,
                type: true,
              },
            },
          },
        },
        classSections: {
          include: {
            teacher: {
              select: {
                id: true,
                user: {
                  select: {
                    firstName: true,
                    lastName: true,
                  },
                },
              },
            },
            semester: {
              select: {
                id: true,
                semesterName: true,
                status: true,
              },
            },
          },
        },
        _count: {
          select: {
            enrollments: true,
            assignments: true,
            examinations: true,
            academicRecords: true,
          },
        },
      },
    })

    if (!subject) {
      throw new NotFoundException(`Subject with ID ${id} not found`)
    }

    return subject
  }

  /**
   * Find subjects by course (program/stream in Indian context)
   */
  async findByCourse(courseId: number) {
    const course = await this.prisma.course.findUnique({
      where: { id: courseId },
    })

    if (!course) {
      throw new NotFoundException(`Course with ID ${courseId} not found`)
    }

    return this.prisma.subject.findMany({
      where: {
        courseId,
        status: 'ACTIVE',
      },
      include: {
        _count: {
          select: {
            enrollments: true,
            classSections: true,
          },
        },
      },
      orderBy: {
        subjectName: 'asc',
      },
    })
  }

  /**
   * Create a new subject
   */
  async create(createSubjectDto: CreateSubjectDto) {
    // Check if subject code already exists
    const existingSubject = await this.prisma.subject.findUnique({
      where: { subjectCode: createSubjectDto.subjectCode },
    })

    if (existingSubject) {
      throw new ConflictException(
        `Subject with code ${createSubjectDto.subjectCode} already exists`
      )
    }

    // Verify course exists if provided
    if (createSubjectDto.courseId) {
      const course = await this.prisma.course.findUnique({
        where: { id: createSubjectDto.courseId },
      })

      if (!course) {
        throw new NotFoundException(
          `Course with ID ${createSubjectDto.courseId} not found`
        )
      }
    }

    return this.prisma.subject.create({
      data: {
        courseId: createSubjectDto.courseId,
        subjectName: createSubjectDto.subjectName,
        subjectCode: createSubjectDto.subjectCode,
        credits: createSubjectDto.credits,
        theoryHours: createSubjectDto.theoryHours || 0,
        practicalHours: createSubjectDto.practicalHours || 0,
        tutorialHours: createSubjectDto.tutorialHours || 0,
        subjectType: createSubjectDto.subjectType || 'CORE',
        prerequisites: createSubjectDto.prerequisites
          ? JSON.stringify(createSubjectDto.prerequisites)
          : null,
        description: createSubjectDto.description,
        syllabus: createSubjectDto.syllabus,
        status: 'ACTIVE',
      },
      include: {
        course: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
      },
    })
  }

  /**
   * Update a subject
   */
  async update(id: number, updateSubjectDto: UpdateSubjectDto) {
    // Check if subject exists
    const subject = await this.prisma.subject.findUnique({
      where: { id },
    })

    if (!subject) {
      throw new NotFoundException(`Subject with ID ${id} not found`)
    }

    // Check if new code conflicts with existing subject
    if (
      updateSubjectDto.subjectCode &&
      updateSubjectDto.subjectCode !== subject.subjectCode
    ) {
      const existingSubject = await this.prisma.subject.findUnique({
        where: { subjectCode: updateSubjectDto.subjectCode },
      })

      if (existingSubject) {
        throw new ConflictException(
          `Subject with code ${updateSubjectDto.subjectCode} already exists`
        )
      }
    }

    // Verify course exists if provided
    if (updateSubjectDto.courseId) {
      const course = await this.prisma.course.findUnique({
        where: { id: updateSubjectDto.courseId },
      })

      if (!course) {
        throw new NotFoundException(
          `Course with ID ${updateSubjectDto.courseId} not found`
        )
      }
    }

    const updateData: Prisma.SubjectUpdateInput = {}

    if (updateSubjectDto.courseId !== undefined) {
      (updateData as any).courseId = updateSubjectDto.courseId
    }
    if (updateSubjectDto.subjectName) {
      updateData.subjectName = updateSubjectDto.subjectName
    }
    if (updateSubjectDto.subjectCode) {
      updateData.subjectCode = updateSubjectDto.subjectCode
    }
    if (updateSubjectDto.credits !== undefined) {
      updateData.credits = updateSubjectDto.credits
    }
    if (updateSubjectDto.theoryHours !== undefined) {
      updateData.theoryHours = updateSubjectDto.theoryHours
    }
    if (updateSubjectDto.practicalHours !== undefined) {
      updateData.practicalHours = updateSubjectDto.practicalHours
    }
    if (updateSubjectDto.tutorialHours !== undefined) {
      updateData.tutorialHours = updateSubjectDto.tutorialHours
    }
    if (updateSubjectDto.subjectType) {
      updateData.subjectType = updateSubjectDto.subjectType
    }
    if (updateSubjectDto.prerequisites !== undefined) {
      updateData.prerequisites = updateSubjectDto.prerequisites
        ? JSON.stringify(updateSubjectDto.prerequisites)
        : null
    }
    if (updateSubjectDto.description !== undefined) {
      updateData.description = updateSubjectDto.description
    }
    if (updateSubjectDto.syllabus !== undefined) {
      updateData.syllabus = updateSubjectDto.syllabus
    }
    if (updateSubjectDto.status) {
      updateData.status = updateSubjectDto.status
    }

    return this.prisma.subject.update({
      where: { id },
      data: updateData,
      include: {
        course: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
      },
    })
  }

  /**
   * Delete a subject (soft delete)
   */
  async remove(id: number) {
    const subject = await this.prisma.subject.findUnique({
      where: { id },
      include: {
        _count: {
          select: {
            enrollments: true,
            classSections: true,
            assignments: true,
            examinations: true,
          },
        },
      },
    })

    if (!subject) {
      throw new NotFoundException(`Subject with ID ${id} not found`)
    }

    // Check if subject has active enrollments or class sections
    if (subject._count.enrollments > 0 || subject._count.classSections > 0) {
      // Soft delete by setting status to INACTIVE
      await this.prisma.subject.update({
        where: { id },
        data: { status: 'INACTIVE' },
      })
    } else {
      // Hard delete if no dependencies
      await this.prisma.subject.delete({
        where: { id },
      })
    }
  }

  /**
   * Get subjects statistics
   */
  async getStats(institutionId?: number) {
    const where: Prisma.SubjectWhereInput = {}

    if (institutionId) {
      where.course = {
        institutionId,
      }
    }

    const [total, active, inactive, byType, byCourse] = await Promise.all([
      // Total subjects
      this.prisma.subject.count({ where }),

      // Active subjects
      this.prisma.subject.count({
        where: { ...where, status: 'ACTIVE' },
      }),

      // Inactive subjects
      this.prisma.subject.count({
        where: { ...where, status: 'INACTIVE' },
      }),

      // Subjects by type
      this.prisma.subject.groupBy({
        by: ['subjectType'],
        where,
        _count: true,
      }),

      // Subjects by course
      this.prisma.subject.groupBy({
        by: ['courseId'],
        where,
        _count: true,
      }),
    ])

    return {
      total,
      active,
      inactive,
      byType: byType.map(item => ({
        type: item.subjectType,
        count: item._count,
      })),
      byCourse: await Promise.all(
        byCourse
          .filter(item => item.courseId !== null)
          .map(async item => {
            const course = await this.prisma.course.findUnique({
              where: { id: item.courseId! },
              select: { name: true, code: true },
            })
            return {
              courseId: item.courseId,
              courseName: course?.name,
              courseCode: course?.code,
              count: item._count,
            }
          })
      ),
    }
  }
}
