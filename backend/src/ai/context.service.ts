import { Injectable, Logger } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'

@Injectable()
export class ContextService {
    private readonly logger = new Logger(ContextService.name)

    constructor(private readonly prisma: PrismaService) {}

    async getUserContext(userId: number): Promise<string> {
        try {
            const baseUser = await this.prisma.user.findUnique({
                where: { id: userId },
                include: { role: true },
            })

            if (!baseUser) return 'Unknown user.'

            const roleName = baseUser.role.roleName.toLowerCase()
            let context = `User: ${baseUser.firstName} ${baseUser.lastName} | Role: ${baseUser.role.roleName}`

            if (roleName === 'student') {
                context += await this.getStudentContext(userId)
            } else if (roleName === 'teacher') {
                context += await this.getTeacherContext(userId)
            } else if (roleName === 'parent') {
                context += await this.getParentContext(userId)
            } else if (roleName === 'admin') {
                context += await this.getAdminContext(userId)
            }

            return context
        } catch (error) {
            this.logger.error(`Error fetching context for user ${userId}`, error)
            return ''
        }
    }

    private async getStudentContext(userId: number): Promise<string> {
        const student = await this.prisma.student.findUnique({
            where: { userId },
            select: {
                id: true,
                admissionNumber: true,
                currentSemester: true,
                currentYear: true,
                gradeLevel: true,
                section: true,
                institution: { select: { name: true } },
                course: { select: { name: true } },
            },
        })

        if (!student) return ''

        const parts = [
            `\nInstitution: ${student.institution.name}`,
            student.course ? `Course: ${student.course.name}` : null,
            student.currentSemester ? `Semester: ${student.currentSemester}` : null,
            student.currentYear ? `Year: ${student.currentYear}` : null,
            student.gradeLevel ? `Grade: ${student.gradeLevel}` : null,
            student.section ? `Section: ${student.section}` : null,
            `Admission#: ${student.admissionNumber}`,
        ]

        return parts.filter(Boolean).join(' | ')
    }

    private async getTeacherContext(userId: number): Promise<string> {
        const teacher = await this.prisma.teacher.findUnique({
            where: { userId },
            select: {
                id: true,
                employeeId: true,
                designation: true,
                specialization: true,
                institution: { select: { name: true } },
                classSections: {
                    where: { status: 'ACTIVE' },
                    select: {
                        sectionName: true,
                        currentEnrollment: true,
                        subject: { select: { subjectName: true, subjectCode: true } },
                    },
                    take: 10,
                },
            },
        })

        if (!teacher) return ''

        const sections = teacher.classSections
            .map(s => `${s.subject.subjectCode}:${s.sectionName}(${s.currentEnrollment})`)
            .join(', ')

        const parts = [
            `\nInstitution: ${teacher.institution.name}`,
            teacher.designation ? `Designation: ${teacher.designation}` : null,
            `Employee#: ${teacher.employeeId}`,
            sections ? `Sections: [${sections}]` : null,
        ]

        return parts.filter(Boolean).join(' | ')
    }

    private async getParentContext(userId: number): Promise<string> {
        const parent = await this.prisma.parent.findUnique({
            where: { userId },
            select: {
                relation: true,
                student: {
                    select: {
                        admissionNumber: true,
                        user: { select: { firstName: true, lastName: true } },
                        institution: { select: { name: true } },
                        course: { select: { name: true } },
                        currentSemester: true,
                        gradeLevel: true,
                    },
                },
            },
        })

        if (!parent) return ''

        const child = parent.student
        const parts = [
            `\nRelation: ${parent.relation}`,
            `Child: ${child.user.firstName} ${child.user.lastName}`,
            `Institution: ${child.institution.name}`,
            child.course ? `Course: ${child.course.name}` : null,
            child.currentSemester ? `Semester: ${child.currentSemester}` : null,
            child.gradeLevel ? `Grade: ${child.gradeLevel}` : null,
        ]

        return parts.filter(Boolean).join(' | ')
    }

    private async getAdminContext(userId: number): Promise<string> {
        const staff = await this.prisma.staff.findUnique({
            where: { userId },
            select: { institution: { select: { id: true, name: true } } },
        })

        const institutionName = staff?.institution?.name
        const institutionId = staff?.institution?.id

        if (!institutionId) {
            const teacher = await this.prisma.teacher.findUnique({
                where: { userId },
                select: { institution: { select: { id: true, name: true } } },
            })
            if (teacher) {
                return `\nInstitution: ${teacher.institution.name}`
            }
            return '\nAdmin user (no institution linked)'
        }

        const [studentCount, teacherCount, courseCount] = await Promise.all([
            this.prisma.student.count({ where: { institutionId, status: 'ACTIVE' } }),
            this.prisma.teacher.count({ where: { institutionId, status: 'ACTIVE' } }),
            this.prisma.course.count({ where: { institutionId, status: 'ACTIVE' } }),
        ])

        return `\nInstitution: ${institutionName} | Students: ${studentCount} | Teachers: ${teacherCount} | Courses: ${courseCount}`
    }
}
