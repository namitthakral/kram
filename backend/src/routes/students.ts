import { Router } from 'express';
import prisma from '../database/client';
import { validateRequest, schemas } from '../middleware/validation';
import { authenticateToken, requireRole, requireStudent } from '../middleware/auth';
import { ApiResponse, PaginationParams } from '../types';

const router = Router();

// Get all students (Admin/Teacher only)
router.get('/', authenticateToken, requireRole(['admin', 'teacher']), async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      sortBy = 'createdAt',
      sortOrder = 'desc',
      search
    } = req.query as PaginationParams;

    const skip = (page - 1) * limit;
    const take = parseInt(limit.toString());

    // Build where clause
    const where: any = {};
    if (search) {
      where.OR = [
        { admissionNumber: { contains: search } },
        { rollNumber: { contains: search } },
        { user: { name: { contains: search } } },
        { user: { email: { contains: search } } }
      ];
    }

    // Get students with pagination
    const [students, total] = await Promise.all([
      prisma.student.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              name: true,
              email: true,
              phone: true,
              status: true
            }
          },
          institution: {
            select: {
              id: true,
              name: true,
              type: true
            }
          },
          program: {
            select: {
              id: true,
              name: true,
              code: true
            }
          },
          parents: {
            include: {
              user: {
                select: {
                  id: true,
                  name: true,
                  email: true,
                  phone: true
                }
              }
            }
          }
        },
        orderBy: { [sortBy]: sortOrder },
        skip,
        take
      }),
      prisma.student.count({ where })
    ]);

    const response: ApiResponse = {
      success: true,
      data: students,
      pagination: {
        page,
        limit: take,
        total,
        totalPages: Math.ceil(total / take)
      }
    };

    res.json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: 'Failed to fetch students'
    };

    res.status(500).json(response);
  }
});

// Get student by ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const studentId = parseInt(req.params.id);

    const student = await prisma.student.findUnique({
      where: { id: studentId },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            phone: true,
            status: true,
            createdAt: true
          }
        },
        institution: true,
        program: true,
        parents: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
                phone: true
              }
            }
          }
        }
      }
    });

    if (!student) {
      const response: ApiResponse = {
        success: false,
        error: 'Student not found'
      };
      res.status(404).json(response);
      return;
    }

    // Check if user can access this student
    if (req.user!.role.roleName === 'student' && req.user!.student?.id !== studentId) {
      const response: ApiResponse = {
        success: false,
        error: 'Access denied'
      };
      res.status(403).json(response);
      return;
    }

    const response: ApiResponse = {
      success: true,
      data: student
    };

    res.json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: 'Failed to fetch student'
    };

    res.status(500).json(response);
  }
});

// Create new student
router.post('/', authenticateToken, requireRole(['admin']), validateRequest(schemas.createStudent), async (req, res) => {
  try {
    const student = await prisma.student.create({
      data: req.body,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            phone: true,
            status: true
          }
        },
        institution: {
          select: {
            id: true,
            name: true,
            type: true
          }
        },
        program: {
          select: {
            id: true,
            name: true,
            code: true
          }
        }
      }
    });

    const response: ApiResponse = {
      success: true,
      data: student,
      message: 'Student created successfully'
    };

    res.status(201).json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to create student'
    };

    res.status(400).json(response);
  }
});

// Update student
router.put('/:id', authenticateToken, requireRole(['admin']), async (req, res) => {
  try {
    const studentId = parseInt(req.params.id);
    const updateData = req.body;

    const student = await prisma.student.update({
      where: { id: studentId },
      data: updateData,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            phone: true,
            status: true
          }
        },
        institution: {
          select: {
            id: true,
            name: true,
            type: true
          }
        },
        program: {
          select: {
            id: true,
            name: true,
            code: true
          }
        }
      }
    });

    const response: ApiResponse = {
      success: true,
      data: student,
      message: 'Student updated successfully'
    };

    res.json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to update student'
    };

    res.status(400).json(response);
  }
});

// Delete student
router.delete('/:id', authenticateToken, requireRole(['admin']), async (req, res) => {
  try {
    const studentId = parseInt(req.params.id);

    await prisma.student.delete({
      where: { id: studentId }
    });

    const response: ApiResponse = {
      success: true,
      message: 'Student deleted successfully'
    };

    res.json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: 'Failed to delete student'
    };

    res.status(500).json(response);
  }
});

// Get student's academic records
router.get('/:id/academic-records', authenticateToken, async (req, res) => {
  try {
    const studentId = parseInt(req.params.id);

    // Check access permissions
    if (req.user!.role.roleName === 'student' && req.user!.student?.id !== studentId) {
      const response: ApiResponse = {
        success: false,
        error: 'Access denied'
      };
      res.status(403).json(response);
      return;
    }

    const academicRecords = await prisma.academicRecord.findMany({
      where: { studentId },
      include: {
        course: {
          select: {
            id: true,
            courseName: true,
            courseCode: true,
            credits: true
          }
        },
        semester: {
          select: {
            id: true,
            semesterName: true,
            semesterNumber: true
          }
        }
      },
      orderBy: [
        { semester: { semesterNumber: 'desc' } },
        { course: { courseCode: 'asc' } }
      ]
    });

    const response: ApiResponse = {
      success: true,
      data: academicRecords
    };

    res.json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: 'Failed to fetch academic records'
    };

    res.status(500).json(response);
  }
});

// Get student's attendance
router.get('/:id/attendance', authenticateToken, async (req, res) => {
  try {
    const studentId = parseInt(req.params.id);
    const { startDate, endDate } = req.query;

    // Check access permissions
    if (req.user!.role.roleName === 'student' && req.user!.student?.id !== studentId) {
      const response: ApiResponse = {
        success: false,
        error: 'Access denied'
      };
      res.status(403).json(response);
      return;
    }

    const where: any = { studentId };
    if (startDate && endDate) {
      where.date = {
        gte: new Date(startDate as string),
        lte: new Date(endDate as string)
      };
    }

    const attendance = await prisma.attendance.findMany({
      where,
      include: {
        section: {
          include: {
            course: {
              select: {
                courseName: true,
                courseCode: true
              }
            }
          }
        }
      },
      orderBy: { date: 'desc' }
    });

    const response: ApiResponse = {
      success: true,
      data: attendance
    };

    res.json(response);
  } catch (error) {
    const response: ApiResponse = {
      success: false,
      error: 'Failed to fetch attendance'
    };

    res.status(500).json(response);
  }
});

export default router;
