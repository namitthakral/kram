import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'
import { Prisma } from '@prisma/client'
import { PrismaService } from '../prisma/prisma.service'
import { CreateClassDivisionDto } from './dto/create-class-division.dto'
import { CreateClassSectionDto } from './dto/create-class-section.dto'
import { CreateCourseDto } from './dto/create-course.dto'
import { UpdateClassDivisionDto } from './dto/update-class-division.dto'
import { UpdateClassSectionDto } from './dto/update-class-section.dto'
import { UpdateCourseDto } from './dto/update-course.dto'

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
   * @param institutionId - When provided (admin), scope to this institution. When null (super_admin), no scope.
   */
  async findAll(query: CourseQueryParams, institutionId: number | null) {
    const where: Prisma.CourseWhereInput = {}

    if (institutionId) {
      where.institutionId = institutionId
    } else if (query.institutionId) {
      where.institutionId = query.institutionId
    }

    if (query.status) {
      where.status = query.status as Prisma.CourseWhereInput['status']
    }

    if (query.degreeType) {
      where.degreeType =
        query.degreeType as Prisma.CourseWhereInput['degreeType']
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
   * @param adminInstitutionId - When provided (admin), verify ownership. When null (super_admin), allow any.
   */
  async findOne(id: number, adminInstitutionId: number | null) {
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

    if (
      adminInstitutionId != null &&
      course.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException('You do not have access to this course')
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
    institutionId: number | null
  ): Promise<{ success: boolean; data: CourseWithSections[] }> {
    const where: Prisma.CourseWhereInput = { status: 'ACTIVE' }

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
   * @param institutionId - When provided (admin), scope to teacher's institution. When null (super_admin), no scope.
   */
  async getClassSections(
    query: {
      institutionId?: number
      semesterId?: number
      courseId?: number
      teacherId?: number
      status?: string
    },
    institutionId: number | null
  ) {
    const where: Prisma.ClassSectionWhereInput = {}

    if (query.semesterId) {
      where.semesterId = query.semesterId
    }

    if (query.status) {
      where.status = query.status as Prisma.ClassSectionWhereInput['status']
    }

    if (query.teacherId) {
      where.teacherId = query.teacherId
    }

    // Filter by course through subject
    const subjectFilter: Prisma.SubjectWhereInput = {}
    if (query.courseId) {
      subjectFilter.courseId = query.courseId
    }
    if (!institutionId && query.institutionId) {
      subjectFilter.course = { institutionId: query.institutionId }
    }
    if (Object.keys(subjectFilter).length > 0) {
      where.subject = subjectFilter
    }

    // Filter by institution: via teacher (ClassSection has no direct institutionId)
    if (institutionId) {
      where.teacher = { institutionId }
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

  /**
   * Get students enrolled in a specific class section
   * Returns only students who are enrolled in the subject taught by this section
   */
  async getClassSectionStudents(sectionId: number) {
    // First, find the class section
    const classSection = await this.prisma.classSection.findUnique({
      where: { id: sectionId },
      include: {
        subject: {
          include: {
            course: true,
          },
        },
        semester: true,
      },
    })

    if (!classSection) {
      throw new NotFoundException(
        `Class section with ID ${sectionId} not found`
      )
    }

    // Get all enrollments for this subject and semester
    const enrollments = await this.prisma.enrollment.findMany({
      where: {
        subjectId: classSection.subjectId,
        semesterId: classSection.semesterId,
        enrollmentStatus: 'ENROLLED',
        // Also filter by section if the student has a section attribute
        student: {
          courseId: classSection.subject.courseId,
          section: classSection.sectionName,
          status: 'ACTIVE',
        },
      },
      include: {
        student: {
          include: {
            user: {
              select: {
                id: true,
                uuid: true,
                name: true,
                email: true,
              },
            },
          },
        },
      },
      orderBy: {
        student: {
          rollNumber: 'asc',
        },
      },
    })

    return {
      success: true,
      data: {
        section: {
          id: classSection.id,
          sectionName: classSection.sectionName,
          subject: {
            id: classSection.subject.id,
            name: classSection.subject.subjectName,
            code: classSection.subject.subjectCode,
          },
          course: classSection.subject.course
            ? {
                id: classSection.subject.course.id,
                name: classSection.subject.course.name,
                code: classSection.subject.course.code,
              }
            : null,
          semester: {
            id: classSection.semester.id,
            name: classSection.semester.semesterName,
            semesterNumber: classSection.semester.semesterNumber,
          },
        },
        students: enrollments.map(enrollment => ({
          id: enrollment.student.id,
          userId: enrollment.student.userId,
          uuid: enrollment.student.user.uuid,
          name: enrollment.student.user.name,
          email: enrollment.student.user.email,
          rollNumber: enrollment.student.rollNumber,
          admissionNumber: enrollment.student.admissionNumber,
          section: enrollment.student.section,
          enrollmentId: enrollment.id,
          enrollmentDate: enrollment.enrollmentDate,
          enrollmentStatus: enrollment.enrollmentStatus,
        })),
        count: enrollments.length,
      },
    }
  }

  /**
   * Get attendance records for a specific class section and date
   * Returns attendance records for students in the section on the specified date
   */
  async getClassSectionAttendance(sectionId: number, date: string) {
    // First, verify the class section exists
    const classSection = await this.prisma.classSection.findUnique({
      where: { id: sectionId },
      include: {
        subject: {
          include: {
            course: true,
          },
        },
        semester: true,
      },
    })

    if (!classSection) {
      throw new NotFoundException(
        `Class section with ID ${sectionId} not found`
      )
    }

    // Parse the date
    const attendanceDate = new Date(date)

    // Get all attendance records for this section on the specified date
    const attendanceRecords = await this.prisma.attendance.findMany({
      where: {
        sectionId,
        date: attendanceDate,
      },
      include: {
        student: {
          include: {
            user: {
              select: {
                id: true,
                uuid: true,
                name: true,
                email: true,
              },
            },
          },
        },
      },
      orderBy: {
        student: {
          rollNumber: 'asc',
        },
      },
    })

    return {
      success: true,
      data: {
        section: {
          id: classSection.id,
          sectionName: classSection.sectionName,
          subject: {
            id: classSection.subject.id,
            name: classSection.subject.subjectName,
            code: classSection.subject.subjectCode,
          },
          course: classSection.subject.course
            ? {
                id: classSection.subject.course.id,
                name: classSection.subject.course.name,
                code: classSection.subject.course.code,
              }
            : null,
          semester: {
            id: classSection.semester.id,
            name: classSection.semester.semesterName,
            semesterNumber: classSection.semester.semesterNumber,
          },
        },
        date: attendanceDate,
        attendance: attendanceRecords.map(record => ({
          id: record.id,
          studentId: record.studentId,
          student: {
            id: record.student.id,
            userId: record.student.userId,
            uuid: record.student.user.uuid,
            name: record.student.user.name,
            email: record.student.user.email,
            rollNumber: record.student.rollNumber,
            admissionNumber: record.student.admissionNumber,
          },
          status: record.status,
          remarks: record.remarks,
          markedAt: record.markedAt,
        })),
        count: attendanceRecords.length,
      },
    }
  }

  /**
   * Create a new course
   */
  async createCourse(
    createCourseDto: CreateCourseDto,
    adminInstitutionId: number | null
  ) {
    // Validate institution access
    if (
      adminInstitutionId !== null &&
      createCourseDto.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException(
        'You can only create courses for your own institution'
      )
    }

    // Check if institution exists
    const institution = await this.prisma.institution.findUnique({
      where: { id: createCourseDto.institutionId },
    })

    if (!institution) {
      throw new NotFoundException(
        `Institution with ID ${createCourseDto.institutionId} not found`
      )
    }

    // Check if course code already exists in the institution (if provided)
    if (createCourseDto.code) {
      const existingCourse = await this.prisma.course.findFirst({
        where: {
          code: createCourseDto.code,
          institutionId: createCourseDto.institutionId,
        },
      })

      if (existingCourse) {
        throw new ConflictException(
          `Course with code '${createCourseDto.code}' already exists in this institution`
        )
      }
    }

    // Map SCHOOL to CERTIFICATE for Prisma compatibility
    const degreeType =
      createCourseDto.degreeType === 'SCHOOL'
        ? 'CERTIFICATE'
        : createCourseDto.degreeType

    const course = await this.prisma.course.create({
      data: {
        name: createCourseDto.name,
        code: createCourseDto.code,
        description: createCourseDto.description,
        degreeType: degreeType as any,
        durationYears: createCourseDto.duration,
        totalCredits: createCourseDto.totalSemesters,
        institutionId: createCourseDto.institutionId,
        status: createCourseDto.status || 'ACTIVE',
      },
      include: {
        institution: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    })

    return {
      success: true,
      message: 'Course created successfully',
      data: course,
    }
  }

  /**
   * Update an existing course
   */
  async updateCourse(
    id: number,
    updateCourseDto: UpdateCourseDto,
    adminInstitutionId: number | null
  ) {
    const existingCourse = await this.prisma.course.findUnique({
      where: { id },
    })

    if (!existingCourse) {
      throw new NotFoundException(`Course with ID ${id} not found`)
    }

    // Validate institution access
    if (
      adminInstitutionId !== null &&
      existingCourse.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException(
        'You can only update courses in your own institution'
      )
    }

    // Check if course code already exists in the institution (if being updated)
    if (updateCourseDto.code && updateCourseDto.code !== existingCourse.code) {
      const courseWithSameCode = await this.prisma.course.findFirst({
        where: {
          code: updateCourseDto.code,
          institutionId: existingCourse.institutionId,
          id: { not: id },
        },
      })

      if (courseWithSameCode) {
        throw new ConflictException(
          `Course with code '${updateCourseDto.code}' already exists in this institution`
        )
      }
    }

    // Map SCHOOL to CERTIFICATE for Prisma compatibility
    const degreeType =
      updateCourseDto.degreeType === 'SCHOOL'
        ? 'CERTIFICATE'
        : updateCourseDto.degreeType

    const updatedCourse = await this.prisma.course.update({
      where: { id },
      data: {
        name: updateCourseDto.name,
        code: updateCourseDto.code,
        description: updateCourseDto.description,
        degreeType: degreeType as any,
        durationYears: updateCourseDto.duration,
        totalCredits: updateCourseDto.totalSemesters,
        status: updateCourseDto.status,
      },
      include: {
        institution: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    })

    return {
      success: true,
      message: 'Course updated successfully',
      data: updatedCourse,
    }
  }

  /**
   * Delete a course (soft delete by setting status to INACTIVE)
   */
  async deleteCourse(id: number, adminInstitutionId: number | null) {
    const existingCourse = await this.prisma.course.findUnique({
      where: { id },
      include: {
        _count: {
          select: {
            students: true,
            subjects: true,
          },
        },
      },
    })

    if (!existingCourse) {
      throw new NotFoundException(`Course with ID ${id} not found`)
    }

    // Validate institution access
    if (
      adminInstitutionId !== null &&
      existingCourse.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException(
        'You can only delete courses in your own institution'
      )
    }

    // Check if course has students or subjects
    if (existingCourse._count.students > 0) {
      throw new ConflictException(
        'Cannot delete course with enrolled students. Please transfer students first.'
      )
    }

    if (existingCourse._count.subjects > 0) {
      throw new ConflictException(
        'Cannot delete course with associated subjects. Please remove subjects first.'
      )
    }

    // Soft delete by setting status to INACTIVE
    const deletedCourse = await this.prisma.course.update({
      where: { id },
      data: { status: 'INACTIVE' },
    })

    return {
      success: true,
      message: 'Course deleted successfully',
      data: deletedCourse,
    }
  }

  /**
   * Create a new class section
   */
  async createClassSection(
    createClassSectionDto: CreateClassSectionDto,
    adminInstitutionId: number | null
  ) {
    // Validate subject exists and get its course
    const subject = await this.prisma.subject.findUnique({
      where: { id: createClassSectionDto.subjectId },
      include: {
        course: true,
      },
    })

    if (!subject) {
      throw new NotFoundException(
        `Subject with ID ${createClassSectionDto.subjectId} not found`
      )
    }

    // Validate institution access
    if (
      adminInstitutionId !== null &&
      subject.course?.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException(
        'You can only create class sections for subjects in your own institution'
      )
    }

    // Validate semester exists
    const semester = await this.prisma.semester.findUnique({
      where: { id: createClassSectionDto.semesterId },
    })

    if (!semester) {
      throw new NotFoundException(
        `Semester with ID ${createClassSectionDto.semesterId} not found`
      )
    }

    // Validate teacher exists (if provided)
    if (createClassSectionDto.teacherId) {
      const teacher = await this.prisma.teacher.findUnique({
        where: { id: createClassSectionDto.teacherId },
      })

      if (!teacher) {
        throw new NotFoundException(
          `Teacher with ID ${createClassSectionDto.teacherId} not found`
        )
      }

      // Validate teacher is in the same institution
      if (
        adminInstitutionId !== null &&
        teacher.institutionId !== adminInstitutionId
      ) {
        throw new ForbiddenException(
          'You can only assign teachers from your own institution'
        )
      }
    }

    // Check if class section already exists for this subject, semester, and section name
    const existingSection = await this.prisma.classSection.findFirst({
      where: {
        subjectId: createClassSectionDto.subjectId,
        semesterId: createClassSectionDto.semesterId,
        sectionName: createClassSectionDto.sectionName,
      },
    })

    if (existingSection) {
      throw new ConflictException(
        `Class section '${createClassSectionDto.sectionName}' already exists for this subject and semester`
      )
    }

    const classSection = await this.prisma.classSection.create({
      data: {
        sectionName: createClassSectionDto.sectionName,
        subjectId: createClassSectionDto.subjectId,
        semesterId: createClassSectionDto.semesterId,
        teacherId: createClassSectionDto.teacherId,
        maxCapacity: createClassSectionDto.maxCapacity,
        schedule: createClassSectionDto.schedule,
        roomNumber: createClassSectionDto.room,
        status: createClassSectionDto.status || 'ACTIVE',
      },
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
                email: true,
              },
            },
          },
        },
      },
    })

    return {
      success: true,
      message: 'Class section created successfully',
      data: classSection,
    }
  }

  /**
   * Update an existing class section
   */
  async updateClassSection(
    id: number,
    updateClassSectionDto: UpdateClassSectionDto,
    adminInstitutionId: number | null
  ) {
    const existingSection = await this.prisma.classSection.findUnique({
      where: { id },
      include: {
        subject: {
          include: {
            course: true,
          },
        },
      },
    })

    if (!existingSection) {
      throw new NotFoundException(`Class section with ID ${id} not found`)
    }

    // Validate institution access
    if (
      adminInstitutionId !== null &&
      existingSection.subject.course?.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException(
        'You can only update class sections in your own institution'
      )
    }

    // Validate teacher exists (if being updated)
    if (updateClassSectionDto.teacherId) {
      const teacher = await this.prisma.teacher.findUnique({
        where: { id: updateClassSectionDto.teacherId },
      })

      if (!teacher) {
        throw new NotFoundException(
          `Teacher with ID ${updateClassSectionDto.teacherId} not found`
        )
      }

      // Validate teacher is in the same institution
      if (
        adminInstitutionId !== null &&
        teacher.institutionId !== adminInstitutionId
      ) {
        throw new ForbiddenException(
          'You can only assign teachers from your own institution'
        )
      }
    }

    // Check for duplicate section name (if being updated)
    if (
      updateClassSectionDto.sectionName &&
      updateClassSectionDto.sectionName !== existingSection.sectionName
    ) {
      const duplicateSection = await this.prisma.classSection.findFirst({
        where: {
          subjectId: existingSection.subjectId,
          semesterId: existingSection.semesterId,
          sectionName: updateClassSectionDto.sectionName,
          id: { not: id },
        },
      })

      if (duplicateSection) {
        throw new ConflictException(
          `Class section '${updateClassSectionDto.sectionName}' already exists for this subject and semester`
        )
      }
    }

    const updatedSection = await this.prisma.classSection.update({
      where: { id },
      data: {
        sectionName: updateClassSectionDto.sectionName,
        teacherId: updateClassSectionDto.teacherId,
        maxCapacity: updateClassSectionDto.maxCapacity,
        schedule: updateClassSectionDto.schedule,
        roomNumber: updateClassSectionDto.room,
        status: updateClassSectionDto.status,
      },
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
                email: true,
              },
            },
          },
        },
      },
    })

    return {
      success: true,
      message: 'Class section updated successfully',
      data: updatedSection,
    }
  }

  /**
   * Delete a class section (soft delete by setting status to INACTIVE)
   */
  async deleteClassSection(id: number, adminInstitutionId: number | null) {
    const existingSection = await this.prisma.classSection.findUnique({
      where: { id },
      include: {
        subject: {
          include: {
            course: true,
          },
        },
        _count: {
          select: {
            attendance: true,
          },
        },
      },
    })

    if (!existingSection) {
      throw new NotFoundException(`Class section with ID ${id} not found`)
    }

    // Validate institution access
    if (
      adminInstitutionId !== null &&
      existingSection.subject.course?.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException(
        'You can only delete class sections in your own institution'
      )
    }

    // Check if section has attendance records
    if (existingSection._count.attendance > 0) {
      throw new ConflictException(
        'Cannot delete class section with attendance records.'
      )
    }

    // Soft delete by setting status to INACTIVE
    const deletedSection = await this.prisma.classSection.update({
      where: { id },
      data: { status: 'INACTIVE' },
    })

    return {
      success: true,
      message: 'Class section deleted successfully',
      data: deletedSection,
    }
  }

  // ============================================================================
  // CLASS DIVISIONS (Simple class organization)
  // ============================================================================

  /**
   * Get all class divisions for a course (Performance Optimized)
   * Query time target: < 50ms
   * Uses selective field loading and pagination
   */
  async getClassDivisions(
    courseId: number,
    adminInstitutionId: number | null,
    page: number = 1,
    limit: number = 50
  ) {
    // Verify course exists and belongs to admin's institution (optimized query)
    const course = await this.prisma.course.findUnique({
      where: { id: courseId },
      select: {
        id: true,
        institutionId: true,
        name: true,
        code: true,
      },
    })

    if (!course) {
      throw new NotFoundException(`Course with ID ${courseId} not found`)
    }

    if (adminInstitutionId && course.institutionId !== adminInstitutionId) {
      throw new ForbiddenException(
        'You can only view class divisions for courses in your own institution'
      )
    }

    // Calculate pagination
    const skip = (page - 1) * limit
    const take = Math.min(limit, 100) // Max 100 items per page as per rules

    // Use optimized query with selective field loading
    const [divisions, totalCount] = await Promise.all([
      this.prisma.classDivision.findMany({
        where: {
          courseId,
          status: 'ACTIVE', // Partial index optimization
        },
        select: {
          id: true,
          sectionName: true,
          maxCapacity: true,
          roomNumber: true,
          status: true,
          createdAt: true,
          teacher: {
            select: {
              id: true,
              user: {
                select: {
                  name: true,
                  email: true,
                },
              },
            },
          },
          _count: {
            select: {
              students: {
                where: { status: 'ACTIVE' }, // Only count active students
              },
            },
          },
        },
        orderBy: { sectionName: 'asc' },
        skip,
        take,
      }),
      // Separate count query for better performance
      this.prisma.classDivision.count({
        where: {
          courseId,
          status: 'ACTIVE',
        },
      }),
    ])

    const totalPages = Math.ceil(totalCount / take)

    return {
      message: 'Class divisions retrieved successfully',
      data: divisions.map(division => ({
        id: division.id,
        sectionName: division.sectionName,
        maxCapacity: division.maxCapacity,
        currentEnrollment: division._count.students,
        roomNumber: division.roomNumber,
        status: division.status,
        course: {
          id: course.id,
          name: course.name,
          code: course.code,
        },
        teacher: division.teacher
          ? {
              id: division.teacher.id,
              name: division.teacher.user.name,
              email: division.teacher.user.email,
            }
          : null,
        createdAt: division.createdAt,
      })),
      meta: {
        total: totalCount,
        page,
        limit: take,
        totalPages,
      },
    }
  }

  /**
   * Create a new class division
   */
  async createClassDivision(
    createClassDivisionDto: CreateClassDivisionDto,
    adminInstitutionId: number | null
  ) {
    // Verify course exists and belongs to admin's institution
    const course = await this.prisma.course.findUnique({
      where: { id: createClassDivisionDto.courseId },
      include: { institution: true },
    })

    if (!course) {
      throw new NotFoundException(
        `Course with ID ${createClassDivisionDto.courseId} not found`
      )
    }

    if (adminInstitutionId && course.institutionId !== adminInstitutionId) {
      throw new ForbiddenException(
        'You can only create class divisions for courses in your own institution'
      )
    }

    // Verify teacher exists if provided
    if (createClassDivisionDto.teacherId) {
      const teacher = await this.prisma.teacher.findUnique({
        where: { id: createClassDivisionDto.teacherId },
        include: { institution: true },
      })

      if (!teacher) {
        throw new NotFoundException(
          `Teacher with ID ${createClassDivisionDto.teacherId} not found`
        )
      }

      if (adminInstitutionId && teacher.institutionId !== adminInstitutionId) {
        throw new ForbiddenException(
          'You can only assign teachers from your own institution'
        )
      }
    }

    // Check if class division already exists for this course and section name
    const existingDivision = await this.prisma.classDivision.findFirst({
      where: {
        courseId: createClassDivisionDto.courseId,
        sectionName: createClassDivisionDto.sectionName,
      },
    })

    if (existingDivision) {
      throw new ConflictException(
        `Class division '${createClassDivisionDto.sectionName}' already exists for this course`
      )
    }

    const classDivision = await this.prisma.classDivision.create({
      data: {
        courseId: createClassDivisionDto.courseId,
        sectionName: createClassDivisionDto.sectionName,
        teacherId: createClassDivisionDto.teacherId,
        maxCapacity: createClassDivisionDto.maxCapacity,
        roomNumber: createClassDivisionDto.roomNumber,
        status: createClassDivisionDto.status || 'ACTIVE',
      },
      include: {
        course: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
        teacher: {
          include: {
            user: {
              select: {
                name: true,
                email: true,
              },
            },
          },
        },
      },
    })

    return {
      message: 'Class division created successfully',
      data: {
        id: classDivision.id,
        sectionName: classDivision.sectionName,
        maxCapacity: classDivision.maxCapacity,
        roomNumber: classDivision.roomNumber,
        status: classDivision.status,
        course: classDivision.course,
        teacher: classDivision.teacher
          ? {
              id: classDivision.teacher.id,
              name: classDivision.teacher.user.name,
              email: classDivision.teacher.user.email,
            }
          : null,
        createdAt: classDivision.createdAt,
      },
    }
  }

  /**
   * Update an existing class division
   */
  async updateClassDivision(
    id: number,
    updateClassDivisionDto: UpdateClassDivisionDto,
    adminInstitutionId: number | null
  ) {
    const existingDivision = await this.prisma.classDivision.findUnique({
      where: { id },
      include: {
        course: {
          include: { institution: true },
        },
      },
    })

    if (!existingDivision) {
      throw new NotFoundException(`Class division with ID ${id} not found`)
    }

    if (
      adminInstitutionId &&
      existingDivision.course.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException(
        'You can only update class divisions in your own institution'
      )
    }

    // Verify teacher exists if provided
    if (updateClassDivisionDto.teacherId) {
      const teacher = await this.prisma.teacher.findUnique({
        where: { id: updateClassDivisionDto.teacherId },
        include: { institution: true },
      })

      if (!teacher) {
        throw new NotFoundException(
          `Teacher with ID ${updateClassDivisionDto.teacherId} not found`
        )
      }

      if (adminInstitutionId && teacher.institutionId !== adminInstitutionId) {
        throw new ForbiddenException(
          'You can only assign teachers from your own institution'
        )
      }
    }

    // Check for duplicate section name if changing
    if (
      updateClassDivisionDto.sectionName &&
      updateClassDivisionDto.sectionName !== existingDivision.sectionName
    ) {
      const duplicateDivision = await this.prisma.classDivision.findFirst({
        where: {
          courseId: existingDivision.courseId,
          sectionName: updateClassDivisionDto.sectionName,
          id: { not: id },
        },
      })

      if (duplicateDivision) {
        throw new ConflictException(
          `Class division '${updateClassDivisionDto.sectionName}' already exists for this course`
        )
      }
    }

    const updatedDivision = await this.prisma.classDivision.update({
      where: { id },
      data: {
        sectionName: updateClassDivisionDto.sectionName,
        teacherId: updateClassDivisionDto.teacherId,
        maxCapacity: updateClassDivisionDto.maxCapacity,
        roomNumber: updateClassDivisionDto.roomNumber,
        status: updateClassDivisionDto.status,
      },
      include: {
        course: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
        teacher: {
          include: {
            user: {
              select: {
                name: true,
                email: true,
              },
            },
          },
        },
      },
    })

    return {
      message: 'Class division updated successfully',
      data: {
        id: updatedDivision.id,
        sectionName: updatedDivision.sectionName,
        maxCapacity: updatedDivision.maxCapacity,
        roomNumber: updatedDivision.roomNumber,
        status: updatedDivision.status,
        course: updatedDivision.course,
        teacher: updatedDivision.teacher
          ? {
              id: updatedDivision.teacher.id,
              name: updatedDivision.teacher.user.name,
              email: updatedDivision.teacher.user.email,
            }
          : null,
        updatedAt: updatedDivision.updatedAt,
      },
    }
  }

  /**
   * Delete a class division
   */
  async deleteClassDivision(id: number, adminInstitutionId: number | null) {
    const existingDivision = await this.prisma.classDivision.findUnique({
      where: { id },
      include: {
        course: {
          include: { institution: true },
        },
        _count: {
          select: {
            students: true,
          },
        },
      },
    })

    if (!existingDivision) {
      throw new NotFoundException(`Class division with ID ${id} not found`)
    }

    if (
      adminInstitutionId &&
      existingDivision.course.institutionId !== adminInstitutionId
    ) {
      throw new ForbiddenException(
        'You can only delete class divisions in your own institution'
      )
    }

    // Check if there are students assigned to this division
    if (existingDivision._count.students > 0) {
      throw new ConflictException(
        'Cannot delete class division with assigned students.'
      )
    }

    const deletedDivision = await this.prisma.classDivision.update({
      where: { id },
      data: { status: 'INACTIVE' },
    })

    return {
      message: 'Class division deleted successfully',
      data: deletedDivision,
    }
  }
}
