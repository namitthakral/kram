import { PrismaService } from '../../prisma/prisma.service'
import { UserWithRelations } from '../../types/auth.types'

export interface ModelScopeResolver {
  (user: UserWithRelations, prisma: PrismaService): Promise<Record<string, any>>
}

export interface ModelAccessEntry {
  /** The Prisma delegate name (camelCase, e.g., 'student', 'attendance') */
  prismaModel: string
  /** Human-readable description for the AI tool */
  description: string
  /** Which roles can access this model */
  allowedRoles: string[]
  /** Fields to exclude from results */
  hiddenFields: string[]
  /** Relations that can be included */
  allowedIncludes: string[]
  /** Key filterable fields to advertise to the AI */
  filterableFields: string[]
  /** Per-role scope resolvers that return WHERE clause additions */
  scopeByRole: Record<string, ModelScopeResolver>
}

/** Helper: resolve the institution ID for admin/staff users */
async function getAdminInstitutionId(
  user: UserWithRelations,
  prisma: PrismaService
): Promise<number | null> {
  if (user.staff) return (user.staff as any).institutionId
  if (user.teacher) return (user.teacher as any).institutionId

  // Fallback: look up staff record
  const staff = await prisma.staff.findUnique({
    where: { userId: user.id },
    select: { institutionId: true },
  })
  if (staff) return staff.institutionId

  // Last resort: look up teacher record
  const teacher = await prisma.teacher.findUnique({
    where: { userId: user.id },
    select: { institutionId: true },
  })
  if (teacher) return teacher.institutionId

  return null
}

/** Helper: get student IDs for a teacher's class sections */
async function getTeacherStudentIds(
  user: UserWithRelations,
  prisma: PrismaService
): Promise<number[]> {
  const teacherId = user.teacher?.id
  if (!teacherId) return []

  const sections = await prisma.classSection.findMany({
    where: { teacherId },
    select: {
      subject: {
        select: {
          enrollments: { select: { studentId: true } },
        },
      },
    },
  })

  const ids = new Set<number>()
  for (const section of sections) {
    for (const enrollment of section.subject.enrollments) {
      ids.add(enrollment.studentId)
    }
  }
  return Array.from(ids)
}

// ────────────────────────────────────────────────────────────────────
// MODEL ACCESS CONFIGURATION
// To add a new model to the AI: just add an entry here.
// The system will auto-generate a query tool for it at startup.
// ────────────────────────────────────────────────────────────────────

export const MODEL_ACCESS_CONFIG: Record<string, ModelAccessEntry> = {
  Student: {
    prismaModel: 'student',
    description:
      'Query student records including admission, enrollment status, and basic info.',
    allowedRoles: ['teacher', 'admin', 'parent'],
    hiddenFields: ['userId', 'createdAt', 'updatedAt'],
    allowedIncludes: [
      'user',
      'course',
      'institution',
      'enrollments',
      'academicRecords',
      'attendanceSummary',
    ],
    filterableFields: [
      'admissionNumber',
      'rollNumber',
      'currentSemester',
      'currentYear',
      'section',
      'status',
      'studentType',
    ],
    scopeByRole: {
      teacher: async (user, prisma) => {
        const studentIds = await getTeacherStudentIds(user, prisma)
        return { id: { in: studentIds } }
      },
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { institutionId: instId } : {}
      },
      parent: async user => {
        return { id: user.parents?.[0]?.studentId || -1 }
      },
    },
  },

  Enrollment: {
    prismaModel: 'enrollment',
    description:
      'Query student enrollments in subjects/courses. Shows enrollment status and grades.',
    allowedRoles: ['teacher', 'admin', 'student'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['student', 'subject', 'semester'],
    filterableFields: ['enrollmentStatus', 'grade', 'semesterId', 'subjectId'],
    scopeByRole: {
      teacher: async (user, prisma) => {
        const sections = await prisma.classSection.findMany({
          where: { teacherId: user.teacher?.id },
          select: { subjectId: true },
        })
        return { subjectId: { in: sections.map(s => s.subjectId) } }
      },
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { student: { institutionId: instId } } : {}
      },
      student: async user => {
        return { studentId: user.student?.id || -1 }
      },
    },
  },

  AcademicRecord: {
    prismaModel: 'academicRecord',
    description:
      'Query academic records with marks, grades, and grade points per subject per semester.',
    allowedRoles: ['student', 'teacher', 'parent', 'admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['student', 'subject', 'semester'],
    filterableFields: ['grade', 'status', 'semesterId', 'subjectId'],
    scopeByRole: {
      student: async user => ({ studentId: user.student?.id || -1 }),
      teacher: async (user, prisma) => {
        const studentIds = await getTeacherStudentIds(user, prisma)
        return { studentId: { in: studentIds } }
      },
      parent: async user => ({ studentId: user.parents?.[0]?.studentId || -1 }),
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { student: { institutionId: instId } } : {}
      },
    },
  },

  Attendance: {
    prismaModel: 'attendance',
    description:
      'Query individual attendance records by date, student, and class section.',
    allowedRoles: ['student', 'teacher', 'parent', 'admin'],
    hiddenFields: ['createdAt'],
    allowedIncludes: ['student', 'section'],
    filterableFields: ['status', 'date', 'sectionId'],
    scopeByRole: {
      student: async user => ({ studentId: user.student?.id || -1 }),
      teacher: async (user, prisma) => {
        const sections = await prisma.classSection.findMany({
          where: { teacherId: user.teacher?.id },
          select: { id: true },
        })
        return { sectionId: { in: sections.map(s => s.id) } }
      },
      parent: async user => ({ studentId: user.parents?.[0]?.studentId || -1 }),
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { student: { institutionId: instId } } : {}
      },
    },
  },

  AttendanceSummary: {
    prismaModel: 'attendanceSummary',
    description:
      'Query attendance summaries showing total/attended/absent classes and attendance percentage per subject.',
    allowedRoles: ['student', 'teacher', 'parent', 'admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['student', 'subject', 'semester'],
    filterableFields: ['semesterId', 'subjectId'],
    scopeByRole: {
      student: async user => ({ studentId: user.student?.id || -1 }),
      teacher: async (user, prisma) => {
        const studentIds = await getTeacherStudentIds(user, prisma)
        return { studentId: { in: studentIds } }
      },
      parent: async user => ({ studentId: user.parents?.[0]?.studentId || -1 }),
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { student: { institutionId: instId } } : {}
      },
    },
  },

  Assignment: {
    prismaModel: 'assignment',
    description:
      'Query assignments with title, description, due dates, marks, and status.',
    allowedRoles: ['student', 'teacher', 'admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['subject', 'section', 'teacher', 'submissions'],
    filterableFields: ['status', 'subjectId', 'dueDate'],
    scopeByRole: {
      student: async (user, prisma) => {
        const enrollments = await prisma.enrollment.findMany({
          where: { studentId: user.student?.id, enrollmentStatus: 'ENROLLED' },
          select: { subjectId: true },
        })
        return { subjectId: { in: enrollments.map(e => e.subjectId) } }
      },
      teacher: async user => ({ teacherId: user.teacher?.id || -1 }),
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { subject: { course: { institutionId: instId } } } : {}
      },
    },
  },

  Submission: {
    prismaModel: 'submission',
    description:
      'Query assignment submissions with status, marks, and feedback.',
    allowedRoles: ['student', 'teacher'],
    hiddenFields: ['createdAt'],
    allowedIncludes: ['assignment', 'student'],
    filterableFields: ['status', 'isLate', 'assignmentId'],
    scopeByRole: {
      student: async user => ({ studentId: user.student?.id || -1 }),
      teacher: async user => ({
        assignment: { teacherId: user.teacher?.id || -1 },
      }),
    },
  },

  Examination: {
    prismaModel: 'examination',
    description: 'Query examinations with type, date, marks, and status.',
    allowedRoles: ['student', 'teacher', 'admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['subject', 'semester', 'results'],
    filterableFields: ['examType', 'status', 'subjectId', 'semesterId'],
    scopeByRole: {
      student: async (user, prisma) => {
        const enrollments = await prisma.enrollment.findMany({
          where: { studentId: user.student?.id, enrollmentStatus: 'ENROLLED' },
          select: { subjectId: true },
        })
        return { subjectId: { in: enrollments.map(e => e.subjectId) } }
      },
      teacher: async user => ({ createdBy: user.teacher?.id || -1 }),
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { subject: { course: { institutionId: instId } } } : {}
      },
    },
  },

  ExamResult: {
    prismaModel: 'examResult',
    description: 'Query exam results with marks, grades, and rankings.',
    allowedRoles: ['student', 'teacher', 'parent', 'admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['exam', 'student'],
    filterableFields: ['grade', 'isAbsent', 'examId'],
    scopeByRole: {
      student: async user => ({ studentId: user.student?.id || -1 }),
      teacher: async user => ({ evaluatedBy: user.teacher?.id || -1 }),
      parent: async user => ({ studentId: user.parents?.[0]?.studentId || -1 }),
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { student: { institutionId: instId } } : {}
      },
    },
  },

  StudentFee: {
    prismaModel: 'studentFee',
    description:
      'Query student fee records with amount due, paid, late fees, and payment status.',
    allowedRoles: ['student', 'parent', 'admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['student', 'feeStructure', 'semester', 'payments'],
    filterableFields: ['status', 'semesterId'],
    scopeByRole: {
      student: async user => ({ studentId: user.student?.id || -1 }),
      parent: async user => ({ studentId: user.parents?.[0]?.studentId || -1 }),
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { student: { institutionId: instId } } : {}
      },
    },
  },

  Payment: {
    prismaModel: 'payment',
    description: 'Query payment transactions with amount, method, and status.',
    allowedRoles: ['student', 'parent', 'admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['student', 'studentFee'],
    filterableFields: ['status', 'paymentMethod', 'paymentMode'],
    scopeByRole: {
      student: async user => ({ studentId: user.student?.id || -1 }),
      parent: async user => ({ studentId: user.parents?.[0]?.studentId || -1 }),
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { student: { institutionId: instId } } : {}
      },
    },
  },

  FeeStructure: {
    prismaModel: 'feeStructure',
    description:
      'Query fee structure definitions with fee types, amounts, and due dates.',
    allowedRoles: ['admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['course', 'academicYear'],
    filterableFields: ['feeType', 'status', 'courseId'],
    scopeByRole: {
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { institutionId: instId } : {}
      },
    },
  },

  Course: {
    prismaModel: 'course',
    description:
      'Query courses (degree programs/streams) with their details and subjects.',
    allowedRoles: ['student', 'teacher', 'parent', 'admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['subjects', 'institution'],
    filterableFields: ['name', 'code', 'degreeType', 'status'],
    scopeByRole: {
      student: async user => ({
        institutionId: user.student?.institutionId || -1,
      }),
      teacher: async user => ({
        institutionId: user.teacher?.institutionId || -1,
      }),
      parent: async (user, prisma) => {
        const student = await prisma.student.findUnique({
          where: { id: user.parents?.[0]?.studentId },
          select: { institutionId: true },
        })
        return { institutionId: student?.institutionId || -1 }
      },
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { institutionId: instId } : {}
      },
    },
  },

  Subject: {
    prismaModel: 'subject',
    description:
      'Query subjects (individual papers) with code, credits, type, and syllabus.',
    allowedRoles: ['student', 'teacher', 'parent', 'admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['course'],
    filterableFields: [
      'subjectName',
      'subjectCode',
      'subjectType',
      'status',
      'courseId',
    ],
    scopeByRole: {
      student: async user => ({
        course: { institutionId: user.student?.institutionId || -1 },
      }),
      teacher: async user => ({
        course: { institutionId: user.teacher?.institutionId || -1 },
      }),
      parent: async (user, prisma) => {
        const student = await prisma.student.findUnique({
          where: { id: user.parents?.[0]?.studentId },
          select: { institutionId: true },
        })
        return { course: { institutionId: student?.institutionId || -1 } }
      },
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { course: { institutionId: instId } } : {}
      },
    },
  },

  ClassSection: {
    prismaModel: 'classSection',
    description:
      'Query class sections with teacher, subject, schedule, and enrollment capacity.',
    allowedRoles: ['teacher', 'admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['subject', 'teacher', 'semester'],
    filterableFields: ['sectionName', 'status', 'subjectId', 'semesterId'],
    scopeByRole: {
      teacher: async user => ({ teacherId: user.teacher?.id || -1 }),
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { subject: { course: { institutionId: instId } } } : {}
      },
    },
  },

  Notice: {
    prismaModel: 'notice',
    description: 'Query institution notices and announcements.',
    allowedRoles: ['student', 'teacher', 'parent', 'admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: [],
    filterableFields: ['noticeType', 'priority', 'isActive', 'isPinned'],
    scopeByRole: {
      student: async user => ({
        institutionId: user.student?.institutionId || -1,
        isActive: true,
      }),
      teacher: async user => ({
        institutionId: user.teacher?.institutionId || -1,
        isActive: true,
      }),
      parent: async (user, prisma) => {
        const student = await prisma.student.findUnique({
          where: { id: user.parents?.[0]?.studentId },
          select: { institutionId: true },
        })
        return { institutionId: student?.institutionId || -1, isActive: true }
      },
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { institutionId: instId } : {}
      },
    },
  },

  StudentProgress: {
    prismaModel: 'studentProgress',
    description:
      'Query student progress summaries with overall grades, scores, and improvement areas.',
    allowedRoles: ['student', 'teacher', 'parent', 'admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['student', 'subject', 'semester'],
    filterableFields: ['status', 'subjectId', 'semesterId'],
    scopeByRole: {
      student: async user => ({ studentId: user.student?.id || -1 }),
      teacher: async (user, prisma) => {
        const studentIds = await getTeacherStudentIds(user, prisma)
        return { studentId: { in: studentIds } }
      },
      parent: async user => ({ studentId: user.parents?.[0]?.studentId || -1 }),
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { student: { institutionId: instId } } : {}
      },
    },
  },

  DashboardStats: {
    prismaModel: 'dashboardStats',
    description:
      'Query dashboard statistics for institution-wide metrics (attendance, performance, fees).',
    allowedRoles: ['admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: [],
    filterableFields: ['statType', 'statName', 'period'],
    scopeByRole: {
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { institutionId: instId } : {}
      },
    },
  },

  TimeTable: {
    prismaModel: 'timeTable',
    description:
      'Query timetable entries with day, time slot, subject, teacher, and room.',
    allowedRoles: ['student', 'teacher', 'admin'],
    hiddenFields: ['createdAt', 'updatedAt'],
    allowedIncludes: ['subject', 'teacher', 'room', 'timeSlot', 'course'],
    filterableFields: ['dayOfWeek', 'isActive', 'subjectId', 'teacherId'],
    scopeByRole: {
      student: async user => ({
        institutionId: user.student?.institutionId || -1,
        courseId: (user.student as any)?.courseId,
      }),
      teacher: async user => ({ teacherId: user.teacher?.id || -1 }),
      admin: async (user, prisma) => {
        const instId = await getAdminInstitutionId(user, prisma)
        return instId ? { institutionId: instId } : {}
      },
    },
  },
}
