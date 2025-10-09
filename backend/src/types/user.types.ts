import { UserStatus, ParentRelation } from '@prisma/client'
import { Student } from './student.types'
import { Teacher } from './teacher.types'

// Re-export Prisma enums for convenience
export { UserStatus, ParentRelation }

// Core User Types
export interface User {
  id: number
  name: string
  email: string
  phone?: string
  passwordHash: string
  roleId: number
  emailVerified: boolean
  phoneVerified: boolean
  twoFactorEnabled: boolean
  lastLogin?: Date
  loginAttempts: number
  accountLocked: boolean
  status: UserStatus
  createdAt: Date
  updatedAt: Date
  // Relations
  role?: Role
  student?: Student
  teacher?: Teacher
  parent?: Parent
}

export interface Role {
  id: number
  roleName: string
  description?: string
  permissions?: string[]
  createdAt: Date
}

export interface Parent {
  id: number
  userId: number
  studentId: number
  relation: ParentRelation
  occupation?: string
  annualIncome?: number | { toNumber(): number } // Support Prisma Decimal type
  educationLevel?: string
  isPrimaryContact: boolean
  createdAt: Date
  updatedAt: Date
}

// Auth Request/Response Types
export interface CreateUserRequest {
  name: string
  email: string
  phone?: string
  password: string
  roleId: number
}

export interface LoginRequest {
  email: string
  password: string
}

export interface AuthResponse {
  user: Omit<User, 'passwordHash'>
  token: string
  refreshToken: string
}
