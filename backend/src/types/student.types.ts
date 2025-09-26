import { StudentType, ResidentialStatus, StudentStatus } from '@prisma/client'

// Re-export Prisma enums for convenience
export { StudentType, ResidentialStatus, StudentStatus }

// Student Types
export interface Student {
  id: number
  userId: number
  institutionId: number
  programId?: number
  admissionNumber: string
  rollNumber?: string
  admissionDate?: Date
  graduationDate?: Date
  currentSemester?: number
  currentYear?: number
  gradeLevel?: string
  section?: string
  studentType: StudentType
  residentialStatus: ResidentialStatus
  transportRequired: boolean
  emergencyContactName?: string
  emergencyContactPhone?: string
  bloodGroup?: string
  medicalConditions?: string
  status: StudentStatus
  createdAt: Date
  updatedAt: Date
}

export interface CreateStudentRequest {
  userId: number
  institutionId: number
  programId?: number
  admissionNumber: string
  rollNumber?: string
  admissionDate?: Date
  currentSemester?: number
  currentYear?: number
  gradeLevel?: string
  section?: string
  studentType?: StudentType
  residentialStatus?: ResidentialStatus
  transportRequired?: boolean
  emergencyContactName?: string
  emergencyContactPhone?: string
  bloodGroup?: string
  medicalConditions?: string
}
