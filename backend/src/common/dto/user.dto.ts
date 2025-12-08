import {
  EmploymentType,
  ResidentialStatus,
  StaffType,
  StudentType,
  UserStatus,
} from '@prisma/client'
import { Transform, Type } from 'class-transformer'
import {
  IsBoolean,
  IsDateString,
  IsDecimal,
  IsEmail,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator'

// ============================================================================
// ROLE-SPECIFIC DATA DTOs
// ============================================================================

export class CreateStudentDataDto {
  @IsOptional()
  @IsString()
  @MaxLength(50)
  admissionNumber?: string // Auto-generated if not provided

  @IsOptional()
  @IsString()
  @MaxLength(50)
  rollNumber?: string // Auto-generated if not provided

  @IsOptional()
  @IsInt()
  courseId?: number

  @IsOptional()
  @IsDateString()
  admissionDate?: string

  @IsOptional()
  @IsInt()
  currentSemester?: number

  @IsOptional()
  @IsInt()
  currentYear?: number

  @IsOptional()
  @IsString()
  @MaxLength(20)
  gradeLevel?: string

  @IsOptional()
  @IsString()
  @MaxLength(10)
  section?: string

  @IsOptional()
  @IsEnum(StudentType)
  studentType?: StudentType

  @IsOptional()
  @IsEnum(ResidentialStatus)
  residentialStatus?: ResidentialStatus

  @IsOptional()
  @IsBoolean()
  transportRequired?: boolean

  @IsOptional()
  @IsString()
  @MaxLength(100)
  emergencyContactName?: string

  @IsOptional()
  @IsString()
  emergencyContactPhone?: string

  @IsOptional()
  @IsString()
  @MaxLength(5)
  bloodGroup?: string

  @IsOptional()
  @IsString()
  medicalConditions?: string
}

export class CreateTeacherDataDto {
  @IsOptional()
  @IsString()
  employeeId?: string // Auto-generated if not provided

  @IsOptional()
  @IsString()
  designation?: string

  @IsOptional()
  @IsString()
  specialization?: string

  @IsOptional()
  @IsString()
  qualification?: string

  @IsOptional()
  @IsInt()
  experienceYears?: number

  @IsOptional()
  @IsDateString()
  joinDate?: string

  @IsOptional()
  @IsDecimal()
  salary?: number

  @IsOptional()
  @IsEnum(EmploymentType)
  employmentType?: EmploymentType

  @IsOptional()
  @IsString()
  officeLocation?: string

  @IsOptional()
  @IsString()
  officeHours?: string

  @IsOptional()
  @IsString()
  researchInterests?: string

  @IsOptional()
  @IsString()
  publications?: string
}

export class CreateStaffDataDto {
  @IsOptional()
  @IsString()
  employeeId?: string // Auto-generated if not provided

  @IsEnum(StaffType)
  staffType: StaffType

  @IsString()
  designation: string

  @IsOptional()
  @IsString()
  department?: string

  @IsOptional()
  @IsDateString()
  joinDate?: string

  @IsOptional()
  @IsDecimal()
  salary?: number

  @IsOptional()
  @IsEnum(EmploymentType)
  employmentType?: EmploymentType

  @IsOptional()
  @IsString()
  workingHours?: string

  @IsOptional()
  @IsString()
  qualifications?: string

  @IsOptional()
  @IsString()
  experience?: string

  @IsOptional()
  @IsString()
  emergencyContact?: string

  @IsOptional()
  @IsString()
  address?: string
}

export class CreateParentDataDto {
  @IsString()
  childEdverseId: string // Required - must link to existing student

  @IsOptional()
  @IsString()
  relation?: string // FATHER, MOTHER, GUARDIAN, OTHER

  @IsOptional()
  @IsBoolean()
  isPrimaryContact?: boolean

  @IsOptional()
  @IsString()
  occupation?: string

  @IsOptional()
  @IsDecimal()
  annualIncome?: number

  @IsOptional()
  @IsString()
  educationLevel?: string
}

// ============================================================================
// MAIN USER DTOs
// ============================================================================

export class CreateUserDto {
  @IsString()
  @MinLength(2)
  firstName: string

  @IsString()
  @MinLength(2)
  lastName: string

  @IsEmail()
  email: string

  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/, {
    message:
      'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character',
  })
  password: string

  @IsInt()
  @Transform(({ value }) => Number(value))
  roleId: number

  @IsInt()
  @Transform(({ value }) => Number(value))
  institutionId: number

  @IsOptional()
  @IsString()
  phoneNumber?: string

  @IsOptional()
  @IsString()
  address?: string

  @IsOptional()
  @IsString()
  city?: string

  @IsOptional()
  @IsString()
  state?: string

  @IsOptional()
  @IsString()
  zipCode?: string

  @IsOptional()
  @IsString()
  country?: string

  @IsOptional()
  @IsDateString()
  dateOfBirth?: string

  @IsOptional()
  @IsString()
  gender?: string

  @IsOptional()
  @IsString()
  profilePicture?: string

  @IsOptional()
  @IsBoolean()
  isVerified?: boolean

  @IsOptional()
  @IsBoolean()
  accountLocked?: boolean

  @IsOptional()
  @IsEnum(UserStatus)
  status?: UserStatus

  // Role-specific data - provide based on roleId
  @IsOptional()
  @ValidateNested()
  @Type(() => CreateStudentDataDto)
  studentData?: CreateStudentDataDto

  @IsOptional()
  @ValidateNested()
  @Type(() => CreateTeacherDataDto)
  teacherData?: CreateTeacherDataDto

  @IsOptional()
  @ValidateNested()
  @Type(() => CreateStaffDataDto)
  staffData?: CreateStaffDataDto

  @IsOptional()
  @ValidateNested()
  @Type(() => CreateParentDataDto)
  parentData?: CreateParentDataDto
}

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  @MinLength(2)
  firstName?: string

  @IsOptional()
  @IsString()
  @MinLength(2)
  lastName?: string

  @IsOptional()
  @IsEmail()
  email?: string

  @IsOptional()
  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/, {
    message:
      'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character',
  })
  password?: string

  @IsOptional()
  @IsInt()
  @Transform(({ value }) => Number(value))
  roleId?: number

  @IsOptional()
  @IsString()
  phoneNumber?: string

  @IsOptional()
  @IsString()
  address?: string

  @IsOptional()
  @IsString()
  city?: string

  @IsOptional()
  @IsString()
  state?: string

  @IsOptional()
  @IsString()
  zipCode?: string

  @IsOptional()
  @IsString()
  country?: string

  @IsOptional()
  @IsDateString()
  dateOfBirth?: string

  @IsOptional()
  @IsString()
  gender?: string

  @IsOptional()
  @IsString()
  profilePicture?: string

  @IsOptional()
  @IsBoolean()
  isVerified?: boolean

  @IsOptional()
  @IsBoolean()
  accountLocked?: boolean

  @IsOptional()
  @IsEnum(UserStatus)
  status?: UserStatus
}

export class UserQueryDto {
  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsInt()
  page?: number = 1

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsInt()
  limit?: number = 10

  @IsOptional()
  @IsString()
  search?: string

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @IsInt()
  roleId?: number

  @IsOptional()
  @IsEnum(UserStatus)
  status?: UserStatus

  @IsOptional()
  @IsString()
  sortBy?: string = 'createdAt'

  @IsOptional()
  @IsString()
  sortOrder?: 'asc' | 'desc' = 'desc'
}
