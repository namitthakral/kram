// Institution Types
export interface Institution {
  id: number
  name: string
  type: InstitutionType
  address?: string
  city?: string
  state?: string
  country?: string
  postalCode?: string
  phone?: string
  email?: string
  website?: string
  establishedYear?: number
  accreditation?: string
  status: InstitutionStatus
  createdAt: Date
  updatedAt: Date
}

export interface CreateInstitutionRequest {
  name: string
  type: InstitutionType
  address?: string
  city?: string
  state?: string
  country?: string
  postalCode?: string
  phone?: string
  email?: string
  website?: string
  establishedYear?: number
  accreditation?: string
}

// Institution Enums
export enum InstitutionType {
  SCHOOL = 'SCHOOL',
  COLLEGE = 'COLLEGE',
  UNIVERSITY = 'UNIVERSITY',
  INSTITUTE = 'INSTITUTE',
}

export enum InstitutionStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
}
