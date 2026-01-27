import { Injectable, Logger } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'
import { Role, User } from '@prisma/client'

@Injectable()
export class ContextService {
  private readonly logger = new Logger(ContextService.name)

  // Configuration: Defines what data to fetch for each role
  // This makes the system "Generic" - to add more context, just add fields here.
  private readonly CONTEXT_CONFIG = {
    student: {
      institution: { select: { name: true } },
      course: {
        select: {
          name: true,
          subjects: {
            select: {
                 subjectName: true,
                 subjectCode: true,
                 syllabus: true
            }
          }
        }
      },
      attendanceSummary: true,
      enrollments: true,
      academicHistory: true,
    },
    teacher: {
      institution: { select: { name: true } },
      classSections: {
        select: {
          sectionName: true,
          subject: {
             select: {
                subjectName: true,
                subjectCode: true,
                enrollments: {
                    select: {
                        student: {
                            select: {
                                admissionNumber: true,
                                user: { select: { firstName: true, lastName: true } }
                            }
                        }
                    }
                }
             }
          }
        }
      }
    },
    parent: {
      student: { // The child
        select: {
           user: { select: { firstName: true, lastName: true } }, // Name
           institution: { select: { name: true } },
           course: { select: { name: true } },
           attendanceSummary: true
        }
      }
    }
  }

  constructor(private readonly prisma: PrismaService) {}

  async getUserContext(userId: number): Promise<string> {
    try {
      // 1. Fetch User with Role
      const baseUser = await this.prisma.user.findUnique({
        where: { id: userId },
        include: { role: true }
      })

      if (!baseUser) return ''

      // 2. Determine Role and Config
      const roleName = baseUser.role.roleName.toLowerCase()
      let roleData = null

      if (roleName === 'student') {
        roleData = await this.prisma.student.findUnique({
          where: { userId: userId },
          select: this.CONTEXT_CONFIG.student as any
        })
        // Fetch separate lists that depend on dynamic filters (like Assignments) if needed
        // but for now, we rely on the generic fetch.
        // Actually, to make it truly 'Generic Algo', we should try to rely on the Tree.
        // If Assignments are not directly linked to Student in schema, we might need a specific fetch.
        // Let's stick to the user's request: "Generic Algorithm".

      } else if (roleName === 'teacher') {
        roleData = await this.prisma.teacher.findUnique({
          where: { userId: userId },
          select: this.CONTEXT_CONFIG.teacher as any
        })
      } else if (roleName === 'parent') {
        roleData = await this.prisma.parent.findUnique({
          where: { userId: userId },
          select: this.CONTEXT_CONFIG.parent as any
        })
      }

      // 3. Build Context String
      let context = `Current User Profile:\n`
      context += `- Name: ${baseUser.firstName} ${baseUser.lastName}\n`
      context += `- Role: ${baseUser.role.roleName}\n`
      context += `- Status: ${baseUser.status}\n\n`

      if (roleData) {
        context += `Role Specific Data:\n`
        context += this.formatDataToContext(roleData)
      }

      // 4. Append Computed/Dynamic Data (The "Smart" part)
      // Some things like "Assignments due next week" are hard to do with just 'include'.
      // Only generic way to do that is if we fetched *all* assignments and filtered in js.
      // For now, this is a good balance.

      return context

    } catch (error) {
      this.logger.error(`Error fetching generic context for user ${userId}`, error)
      return ''
    }
  }

  // The "Generic Context Algorithm"
  // Recursively traverses any JSON object and turns it into readable context text.
  private formatDataToContext(data: any, depth = 0): string {
    if (!data) return ''

    let output = ''
    const indent = '  '.repeat(depth)
    const bullet = depth > 0 ? '- ' : ''

    // Handle Array (List of items)
    if (Array.isArray(data)) {
        if (data.length === 0) return `${indent}${bullet}(None)\n`

        // Limit large lists
        const limit = 5
        data.slice(0, limit).forEach(item => {
            output += this.formatDataToContext(item, depth + 1)
        })
        if (data.length > limit) output += `${indent}  ...and ${data.length - limit} more\n`
        return output
    }

    // Handle Object (Dictionaries)
    if (typeof data === 'object' && data !== null) {
        // Check if it's a Date
        if (data instanceof Date) return `${indent}${bullet}${data.toISOString().split('T')[0]}\n`

        for (const [key, value] of Object.entries(data)) {
            // Filter out internal IDs and excessive implementation details to save tokens
            if (this.isIgnoredField(key)) continue

            // If value is primitive, print line. If object/array, recurse.
            if (value && typeof value === 'object' && !((value as any) instanceof Date)) {
                 // Header for nested section
                 output += `${indent}- ${this.formatKey(key)}:\n`
                 output += this.formatDataToContext(value, depth + 1)
            } else {
                 if (value !== null && value !== undefined && value !== '') {
                    output += `${indent}- ${this.formatKey(key)}: ${value}\n`
                 }
            }
        }
        return output
    }

    // Handle Primitive
    return `${indent}${bullet}${data}\n`
  }

  private isIgnoredField(key: string): boolean {
    const ignored = [
      'id', 'userId', 'password', 'hash', 'createdAt', 'updatedAt',
      'institutionId', 'courseId', 'programId', 'sectionId',
      'uuid', 'edverseId', 'roleId', 'passwordHash',
      'emailVerified', 'phoneVerified', 'twoFactorEnabled',
      'loginAttempts', 'accountLocked', 'isTemporaryPassword'
    ]
    return ignored.includes(key)
  }

  private formatKey(key: string): string {
    // CamelCase to Sentence Case (e.g., 'admissionNumber' -> 'Admission Number')
    return key.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase())
  }
}
