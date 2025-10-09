import { EmploymentType, TeacherStatus } from '@prisma/client'

// Re-export Prisma enums for convenience
export { EmploymentType, TeacherStatus }

// Teacher Types
export interface Teacher {
  id: number
  userId: number
  institutionId: number
  deptId?: number
  employeeId: string
  designation?: string
  specialization?: string
  qualification?: string
  experienceYears: number
  joinDate?: Date
  salary?: number | { toNumber(): number } // Support Prisma Decimal type
  employmentType: EmploymentType
  officeLocation?: string
  officeHours?: string
  researchInterests?: string
  publications?: string
  status: TeacherStatus
  createdAt: Date
  updatedAt: Date
}

export interface CreateTeacherRequest {
  userId: number
  institutionId: number
  deptId?: number
  employeeId: string
  designation?: string
  specialization?: string
  qualification?: string
  experienceYears?: number
  joinDate?: Date
  salary?: number
  employmentType?: EmploymentType
  officeLocation?: string
  officeHours?: string
  researchInterests?: string
  publications?: string
}
