import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';

export const validateRequest = (schema: Joi.ObjectSchema) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true
    });

    if (error) {
      const errorDetails = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));

      res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errorDetails
      });
      return;
    }

    req.body = value;
    next();
  };
};

// Common validation schemas
export const schemas = {
  // User schemas
  createUser: Joi.object({
    name: Joi.string().min(2).max(100).required(),
    email: Joi.string().email().required(),
    phone: Joi.string().pattern(/^\+?[\d\s-()]+$/).optional(),
    password: Joi.string().min(8).pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/).required()
      .messages({
        'string.pattern.base': 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'
      }),
    roleId: Joi.number().integer().positive().required()
  }),

  login: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required()
  }),

  // Institution schemas
  createInstitution: Joi.object({
    name: Joi.string().min(2).max(200).required(),
    type: Joi.string().valid('SCHOOL', 'COLLEGE', 'UNIVERSITY', 'INSTITUTE').required(),
    address: Joi.string().optional(),
    city: Joi.string().max(100).optional(),
    state: Joi.string().max(100).optional(),
    country: Joi.string().max(100).optional(),
    postalCode: Joi.string().max(20).optional(),
    phone: Joi.string().pattern(/^\+?[\d\s-()]+$/).optional(),
    email: Joi.string().email().optional(),
    website: Joi.string().uri().optional(),
    establishedYear: Joi.number().integer().min(1800).max(new Date().getFullYear()).optional(),
    accreditation: Joi.string().max(100).optional()
  }),

  // Student schemas
  createStudent: Joi.object({
    userId: Joi.number().integer().positive().required(),
    institutionId: Joi.number().integer().positive().required(),
    programId: Joi.number().integer().positive().optional(),
    admissionNumber: Joi.string().max(50).required(),
    rollNumber: Joi.string().max(50).optional(),
    admissionDate: Joi.date().optional(),
    currentSemester: Joi.number().integer().min(1).max(20).optional(),
    currentYear: Joi.number().integer().min(1).max(10).optional(),
    gradeLevel: Joi.string().max(20).optional(),
    section: Joi.string().max(10).optional(),
    studentType: Joi.string().valid('REGULAR', 'TRANSFER', 'EXCHANGE').optional(),
    residentialStatus: Joi.string().valid('DAY_SCHOLAR', 'HOSTELER').optional(),
    transportRequired: Joi.boolean().optional(),
    emergencyContactName: Joi.string().max(100).optional(),
    emergencyContactPhone: Joi.string().pattern(/^\+?[\d\s-()]+$/).optional(),
    bloodGroup: Joi.string().max(5).optional(),
    medicalConditions: Joi.string().optional()
  }),

  // Teacher schemas
  createTeacher: Joi.object({
    userId: Joi.number().integer().positive().required(),
    institutionId: Joi.number().integer().positive().required(),
    deptId: Joi.number().integer().positive().optional(),
    employeeId: Joi.string().max(50).required(),
    designation: Joi.string().max(100).optional(),
    specialization: Joi.string().max(200).optional(),
    qualification: Joi.string().max(200).optional(),
    experienceYears: Joi.number().integer().min(0).max(50).optional(),
    joinDate: Joi.date().optional(),
    salary: Joi.number().positive().optional(),
    employmentType: Joi.string().valid('FULL_TIME', 'PART_TIME', 'CONTRACT', 'VISITING').optional(),
    officeLocation: Joi.string().max(100).optional(),
    officeHours: Joi.string().max(200).optional(),
    researchInterests: Joi.string().optional(),
    publications: Joi.string().optional()
  }),

  // Course schemas
  createCourse: Joi.object({
    programId: Joi.number().integer().positive().optional(),
    deptId: Joi.number().integer().positive().optional(),
    courseName: Joi.string().min(2).max(200).required(),
    courseCode: Joi.string().max(20).required(),
    credits: Joi.number().integer().min(1).max(20).required(),
    lectureHours: Joi.number().integer().min(0).max(100).optional(),
    labHours: Joi.number().integer().min(0).max(100).optional(),
    tutorialHours: Joi.number().integer().min(0).max(100).optional(),
    courseType: Joi.string().valid('CORE', 'ELECTIVE', 'MINOR', 'MAJOR').optional(),
    prerequisites: Joi.string().optional(),
    description: Joi.string().optional(),
    syllabus: Joi.string().optional()
  }),

  // Pagination schema
  pagination: Joi.object({
    page: Joi.number().integer().min(1).default(1),
    limit: Joi.number().integer().min(1).max(100).default(10),
    sortBy: Joi.string().optional(),
    sortOrder: Joi.string().valid('asc', 'desc').default('asc'),
    search: Joi.string().optional()
  })
};
