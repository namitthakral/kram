import { ParentRelation, UserAccountStatus } from '@prisma/client'
import { Student } from './student.types'
import { Teacher } from './teacher.types'

// Re-export Prisma enums for convenience
export { ParentRelation, UserAccountStatus }

// Core User Types (using Prisma camelCase field names)
export interface User {
  id: number
  uuid?: string
  kramid?: string
  firstName: string
  lastName: string
  email?: string
  phone?: string
  passwordHash: string
  roleId: number
  lastLogin?: Date
  loginAttempts: number
  accountStatus: UserAccountStatus
  institutionId?: number | null
  createdAt: Date
  updatedAt: Date
  // Relations
  role?: Role
  student?: Student
  teacher?: Teacher
  parent?: Parent
  staff?: Staff
}

// Helper interface for backward compatibility with full name
export interface UserWithFullName extends User {
  name: string // Computed from firstName + lastName
}

export interface Role {
  id: number
  roleName: string
  description?: string
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

export interface Staff {
  id: number
  userId: number
  institutionId: number
  employeeId: string
  staffType?: string
  designation?: string
  department?: string
  joinDate?: Date
  salary?: number | { toNumber(): number } // Support Prisma Decimal type
  employmentType?: string
  workingHours?: string
  reportingManager?: number
  skills?: string[]
  qualifications?: string
  experience?: string
  emergencyContact?: string
  address?: string
  employmentStatus?: string
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

// Helper functions for user status and name handling
export class UserHelpers {
  /**
   * Generate full name from first and last name
   */
  static getFullName(firstName: string, lastName: string): string {
    return `${firstName} ${lastName}`.trim()
  }

  /**
   * Add computed full name to user object
   */
  static withFullName<T extends User>(user: T): T & { name: string } {
    return {
      ...user,
      name: this.getFullName(user.firstName, user.lastName)
    }
  }

  /**
   * Check if user needs password change (has temporary password)
   */
  static needsPasswordChange(accountStatus: UserAccountStatus): boolean {
    return accountStatus === 'PENDING_ACTIVATION'
  }

  /**
   * Check if user account is blocked from login
   */
  static isBlocked(accountStatus: UserAccountStatus): boolean {
    return accountStatus === 'SUSPENDED' || accountStatus === 'LOCKED'
  }

  /**
   * Check if user can login (not blocked, but may need password change)
   */
  static canLogin(accountStatus: UserAccountStatus): boolean {
    return accountStatus === 'ACTIVE' || accountStatus === 'PENDING_ACTIVATION'
  }

  /**
   * Get user-friendly status description
   */
  static getStatusDescription(accountStatus: UserAccountStatus): string {
    switch (accountStatus) {
      case 'PENDING_ACTIVATION':
        return 'Account requires password change'
      case 'ACTIVE':
        return 'Active'
      case 'SUSPENDED':
        return 'Account suspended by administrator'
      case 'LOCKED':
        return 'Account locked due to failed login attempts'
      case 'INACTIVE':
        return 'Account deactivated'
      default:
        return 'Unknown status'
    }
  }
}
