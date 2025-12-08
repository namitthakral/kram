import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'

export interface CourseQueryParams {
  institutionId?: number
  status?: string
  degreeType?: string
}

export interface SectionInfo {
  sectionName: string
  studentCount: number
  classTeacher?: string
}

export interface CourseWithSections {
  courseId: number
  courseName: string
  courseCode: string | null
  degreeType: string
  totalStudents: number
  sections: SectionInfo[]
}

@Injectable()
export class CoursesService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get all courses/programs
   * Optionally filter by institution, status, or degree type
   */
  async findAll(query: CourseQueryParams) {
    const where: any = {}

    if (query.institutionId) {
      where.institutionId = query.institutionId
    }

    if (query.status) {
      where.status = query.status
    }

    if (query.degreeType) {
      where.degreeType = query.degreeType
    }

    const courses = await this.prisma.course.findMany({
      where,
      include: {
        institution: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
        _count: {
          select: {
            students: true,
            subjects: true,
          },
        },
      },
      orderBy: { name: 'asc' },
    })

    return {
      success: true,
      data: courses.map(course => ({
        id: course.id,
        name: course.name,
        code: course.code,
        degreeType: course.degreeType,
        durationYears: course.durationYears,
        totalCredits: course.totalCredits,
        description: course.description,
        status: course.status,
        institution: course.institution,
        studentCount: course._count.students,
        subjectCount: course._count.subjects,
      })),
      count: courses.length,
    }
  }

  /**
   * Get a single course by ID
   */
  async findOne(id: number) {
    const course = await this.prisma.course.findUnique({
      where: { id },
      include: {
        institution: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
        subjects: {
          select: {
            id: true,
            subjectName: true,
            subjectCode: true,
            credits: true,
            subjectType: true,
            status: true,
          },
          orderBy: { subjectName: 'asc' },
        },
      },
    })

    if (!course) {
      throw new NotFoundException(`Course with ID ${id} not found`)
    }

    // Get student count separately
    const studentCount = await this.prisma.student.count({
      where: { courseId: id },
    })

    return {
      success: true,
      data: {
        ...course,
        studentCount,
      },
    }
  }

  /**
   * Get all courses with their sections
   * Groups students by course and section
   */
  async getCoursesWithSections(
    institutionId?: number
  ): Promise<{ success: boolean; data: CourseWithSections[] }> {
    const where: any = { status: 'ACTIVE' }

    if (institutionId) {
      where.institutionId = institutionId
    }

    // Get all courses
    const courses = await this.prisma.course.findMany({
      where,
      include: {
        students: {
          where: { status: 'ACTIVE' },
          select: {
            id: true,
            section: true,
          },
        },
        classTeachers: {
          where: {
            academicYear: {
              status: 'CURRENT',
            },
          },
          include: {
            teacher: {
              include: {
                user: {
                  select: {
                    name: true,
                  },
                },
              },
            },
          },
        },
      },
      orderBy: { name: 'asc' },
    })

    const result: CourseWithSections[] = courses.map(course => {
      // Group students by section
      const sectionMap = new Map<string, number>()

      course.students.forEach(student => {
        const section = student.section || 'Unassigned'
        sectionMap.set(section, (sectionMap.get(section) || 0) + 1)
      })

      // Build sections array
      const sections: SectionInfo[] = []
      sectionMap.forEach((count, sectionName) => {
        // Find class teacher for this section
        const classTeacher = course.classTeachers.find(
          ct => ct.section === sectionName
        )

        sections.push({
          sectionName,
          studentCount: count,
          classTeacher: classTeacher?.teacher?.user?.name,
        })
      })

      // Sort sections alphabetically
      sections.sort((a, b) => a.sectionName.localeCompare(b.sectionName))

      return {
        courseId: course.id,
        courseName: course.name,
        courseCode: course.code,
        degreeType: course.degreeType,
        totalStudents: course.students.length,
        sections,
      }
    })

    return {
      success: true,
      data: result,
    }
  }

  /**
   * Get sections for a specific course
   */
  async getCourseSections(courseId: number) {
    const course = await this.prisma.course.findUnique({
      where: { id: courseId },
      include: {
        students: {
          where: { status: 'ACTIVE' },
          select: {
            id: true,
            section: true,
            currentSemester: true,
            currentYear: true,
            gradeLevel: true,
          },
        },
        classTeachers: {
          where: {
            academicYear: {
              status: 'CURRENT',
            },
          },
          include: {
            teacher: {
              include: {
                user: {
                  select: {
                    name: true,
                  },
                },
              },
            },
          },
        },
      },
    })

    if (!course) {
      throw new NotFoundException(`Course with ID ${courseId} not found`)
    }

    // Group students by section and year/semester
    const sectionMap = new Map<
      string,
      {
        students: number
        years: Map<number, number>
        semesters: Map<number, number>
      }
    >()

    course.students.forEach(student => {
      const section = student.section || 'Unassigned'

      if (!sectionMap.has(section)) {
        sectionMap.set(section, {
          students: 0,
          years: new Map(),
          semesters: new Map(),
        })
      }

      const sectionData = sectionMap.get(section)!
      sectionData.students++

      if (student.currentYear) {
        sectionData.years.set(
          student.currentYear,
          (sectionData.years.get(student.currentYear) || 0) + 1
        )
      }

      if (student.currentSemester) {
        sectionData.semesters.set(
          student.currentSemester,
          (sectionData.semesters.get(student.currentSemester) || 0) + 1
        )
      }
    })

    // Build sections array with detailed breakdown
    const sections = Array.from(sectionMap.entries())
      .map(([sectionName, data]) => {
        const classTeacher = course.classTeachers.find(
          ct => ct.section === sectionName
        )

        return {
          sectionName,
          studentCount: data.students,
          classTeacher: classTeacher?.teacher?.user?.name || null,
          yearBreakdown: Object.fromEntries(data.years),
          semesterBreakdown: Object.fromEntries(data.semesters),
        }
      })
      .sort((a, b) => a.sectionName.localeCompare(b.sectionName))

    return {
      success: true,
      data: {
        courseId: course.id,
        courseName: course.name,
        courseCode: course.code,
        totalStudents: course.students.length,
        totalSections: sections.length,
        sections,
      },
    }
  }

  /**
   * Get all class sections (subject-based sections)
   * These are sections for specific subjects in a semester
   */
  async getClassSections(query: {
    institutionId?: number
    semesterId?: number
    courseId?: number
    teacherId?: number
    status?: string
  }) {
    const where: any = {}

    if (query.semesterId) {
      where.semesterId = query.semesterId
    }

    if (query.status) {
      where.status = query.status
    }

    if (query.teacherId) {
      where.teacherId = query.teacherId
    }

    // Filter by course through subject
    if (query.courseId) {
      where.subject = {
        courseId: query.courseId,
      }
    }

    // Filter by institution through subject -> course
    if (query.institutionId) {
      where.subject = {
        ...where.subject,
        course: {
          institutionId: query.institutionId,
        },
      }
    }

    const classSections = await this.prisma.classSection.findMany({
      where,
      include: {
        subject: {
          include: {
            course: true,
          },
        },
        semester: true,
        teacher: {
          include: {
            user: {
              select: {
                name: true,
                uuid: true,
              },
            },
          },
        },
      },
      orderBy: [{ sectionName: 'asc' }],
    })

    return {
      success: true,
      data: classSections.map(cs => ({
        id: cs.id,
        sectionName: cs.sectionName,
        maxCapacity: cs.maxCapacity,
        currentEnrollment: cs.currentEnrollment,
        roomNumber: cs.roomNumber,
        schedule: cs.schedule,
        status: cs.status,
        subject: {
          id: cs.subject.id,
          name: cs.subject.subjectName,
          code: cs.subject.subjectCode,
          courseId: cs.subject.courseId,
        },
        course: cs.subject.course
          ? {
              id: cs.subject.course.id,
              name: cs.subject.course.name,
              code: cs.subject.course.code,
            }
          : null,
        semester: {
          id: cs.semester.id,
          name: cs.semester.semesterName,
          semesterNumber: cs.semester.semesterNumber,
        },
        teacher: cs.teacher
          ? {
              id: cs.teacher.id,
              uuid: cs.teacher.user.uuid,
              name: cs.teacher.user.name,
            }
          : null,
      })),
      count: classSections.length,
    }
  }
}
