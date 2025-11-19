import { Parent, Role, Staff, Student, Teacher, User } from './index'

// Extended user type with relations
export type UserWithRelations = User & {
  role: Role
  student?: Student | null
  teacher?: Teacher | null
  parent?: Parent | null
  staff?: Staff | null
}

// JWT payload type
export interface JWTPayload {
  userId: number
  email: string
  roleId: number
  iat?: number
  exp?: number
}
