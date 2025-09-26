// Core Types
export interface User {
  id: number;
  name: string;
  email: string;
  phone?: string;
  passwordHash: string;
  roleId: number;
  emailVerified: boolean;
  phoneVerified: boolean;
  twoFactorEnabled: boolean;
  lastLogin?: Date;
  loginAttempts: number;
  accountLocked: boolean;
  status: UserStatus;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserRequest {
  name: string;
  email: string;
  phone?: string;
  password: string;
  roleId: number;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface AuthResponse {
  user: Omit<User, 'passwordHash'>;
  token: string;
  refreshToken: string;
}

// Institution Types
export interface Institution {
  id: number;
  name: string;
  type: InstitutionType;
  address?: string;
  city?: string;
  state?: string;
  country?: string;
  postalCode?: string;
  phone?: string;
  email?: string;
  website?: string;
  establishedYear?: number;
  accreditation?: string;
  status: InstitutionStatus;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateInstitutionRequest {
  name: string;
  type: InstitutionType;
  address?: string;
  city?: string;
  state?: string;
  country?: string;
  postalCode?: string;
  phone?: string;
  email?: string;
  website?: string;
  establishedYear?: number;
  accreditation?: string;
}

// Student Types
export interface Student {
  id: number;
  userId: number;
  institutionId: number;
  programId?: number;
  admissionNumber: string;
  rollNumber?: string;
  admissionDate?: Date;
  graduationDate?: Date;
  currentSemester?: number;
  currentYear?: number;
  gradeLevel?: string;
  section?: string;
  studentType: StudentType;
  residentialStatus: ResidentialStatus;
  transportRequired: boolean;
  emergencyContactName?: string;
  emergencyContactPhone?: string;
  bloodGroup?: string;
  medicalConditions?: string;
  status: StudentStatus;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateStudentRequest {
  userId: number;
  institutionId: number;
  programId?: number;
  admissionNumber: string;
  rollNumber?: string;
  admissionDate?: Date;
  currentSemester?: number;
  currentYear?: number;
  gradeLevel?: string;
  section?: string;
  studentType?: StudentType;
  residentialStatus?: ResidentialStatus;
  transportRequired?: boolean;
  emergencyContactName?: string;
  emergencyContactPhone?: string;
  bloodGroup?: string;
  medicalConditions?: string;
}

// Teacher Types
export interface Teacher {
  id: number;
  userId: number;
  institutionId: number;
  deptId?: number;
  employeeId: string;
  designation?: string;
  specialization?: string;
  qualification?: string;
  experienceYears: number;
  joinDate?: Date;
  salary?: number;
  employmentType: EmploymentType;
  officeLocation?: string;
  officeHours?: string;
  researchInterests?: string;
  publications?: string;
  status: TeacherStatus;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateTeacherRequest {
  userId: number;
  institutionId: number;
  deptId?: number;
  employeeId: string;
  designation?: string;
  specialization?: string;
  qualification?: string;
  experienceYears?: number;
  joinDate?: Date;
  salary?: number;
  employmentType?: EmploymentType;
  officeLocation?: string;
  officeHours?: string;
  researchInterests?: string;
  publications?: string;
}

// Course Types
export interface Course {
  id: number;
  programId?: number;
  deptId?: number;
  courseName: string;
  courseCode: string;
  credits: number;
  lectureHours: number;
  labHours: number;
  tutorialHours: number;
  courseType: CourseType;
  prerequisites?: string;
  description?: string;
  syllabus?: string;
  status: CourseStatus;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateCourseRequest {
  programId?: number;
  deptId?: number;
  courseName: string;
  courseCode: string;
  credits: number;
  lectureHours?: number;
  labHours?: number;
  tutorialHours?: number;
  courseType?: CourseType;
  prerequisites?: string;
  description?: string;
  syllabus?: string;
}

// API Response Types
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
  pagination?: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface PaginationParams {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  search?: string;
}

// Enums
export enum UserStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  SUSPENDED = 'SUSPENDED'
}

export enum InstitutionType {
  SCHOOL = 'SCHOOL',
  COLLEGE = 'COLLEGE',
  UNIVERSITY = 'UNIVERSITY',
  INSTITUTE = 'INSTITUTE'
}

export enum InstitutionStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE'
}

export enum StudentType {
  REGULAR = 'REGULAR',
  TRANSFER = 'TRANSFER',
  EXCHANGE = 'EXCHANGE'
}

export enum ResidentialStatus {
  DAY_SCHOLAR = 'DAY_SCHOLAR',
  HOSTELER = 'HOSTELER'
}

export enum StudentStatus {
  ACTIVE = 'ACTIVE',
  ALUMNI = 'ALUMNI',
  DROPOUT = 'DROPOUT',
  TRANSFERRED = 'TRANSFERRED',
  SUSPENDED = 'SUSPENDED'
}

export enum EmploymentType {
  FULL_TIME = 'FULL_TIME',
  PART_TIME = 'PART_TIME',
  CONTRACT = 'CONTRACT',
  VISITING = 'VISITING'
}

export enum TeacherStatus {
  ACTIVE = 'ACTIVE',
  ON_LEAVE = 'ON_LEAVE',
  RESIGNED = 'RESIGNED',
  RETIRED = 'RETIRED'
}

export enum CourseType {
  CORE = 'CORE',
  ELECTIVE = 'ELECTIVE',
  MINOR = 'MINOR',
  MAJOR = 'MAJOR'
}

export enum CourseStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE'
}

export enum DegreeType {
  CERTIFICATE = 'CERTIFICATE',
  DIPLOMA = 'DIPLOMA',
  BACHELORS = 'BACHELORS',
  MASTERS = 'MASTERS',
  PHD = 'PHD',
  OTHER = 'OTHER'
}

export enum ProgramStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE'
}

export enum ParentRelation {
  FATHER = 'FATHER',
  MOTHER = 'MOTHER',
  GUARDIAN = 'GUARDIAN',
  OTHER = 'OTHER'
}
