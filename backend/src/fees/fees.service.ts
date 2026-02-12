import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import {
  CreateFeeStructureDto,
  FeeStructureQueryDto,
  UpdateFeeStructureDto,
} from './dto/fee-structure.dto';
import {
  BulkCreateStudentFeesDto,
  CreateStudentFeeDto,
  StudentFeeQueryDto,
  UpdateStudentFeeDto,
} from './dto/student-fee.dto';
import {
  CreatePaymentDto,
  PaymentQueryDto,
  UpdatePaymentDto,
} from './dto/payment.dto';
import { FeeStatus } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

// Database View Types
export interface StudentFeeStatusView {
  student_fee_id: number;
  student_id: number;
  roll_number: string;
  student_name: string;
  student_email: string;
  edverse_id: string;
  fee_structure_id: number;
  fee_name: string;
  fee_type: string;
  semester_id: number | null;
  semester_name: string | null;
  course_id: number | null;
  course_name: string | null;
  institution_id: number;
  institution_name: string;
  amount_due: Decimal;
  amount_paid: Decimal;
  amount_pending: Decimal;
  late_fee_applied: Decimal;
  discount: Decimal;
  status: string;
  due_date: Date;
  payment_status_label: string;
  days_overdue: number;
  payment_count: number;
  last_payment_date: Date | null;
  created_at: Date;
  updated_at: Date;
}

export interface PaymentAnalyticsView {
  institution_id: number;
  institution_name: string;
  payment_month: Date;
  payment_method: string;
  payment_mode: string;
  status: string;
  transaction_count: number;
  total_amount: Decimal;
  average_amount: Decimal;
  min_amount: Decimal;
  max_amount: Decimal;
  unique_students: number;
  transaction_days: number;
}

export interface OverdueFeeView {
  student_fee_id: number;
  student_id: number;
  roll_number: string;
  student_name: string;
  student_email: string;
  student_phone: string | null;
  edverse_id: string;
  institution_id: number;
  institution_name: string;
  fee_name: string;
  fee_type: string;
  amount_due: Decimal;
  amount_paid: Decimal;
  total_overdue_amount: Decimal;
  late_fee_applied: Decimal;
  due_date: Date;
  days_overdue: number;
  status: string;
  semester_name: string | null;
  course_name: string | null;
}

@Injectable()
export class FeesService {
  constructor(private prisma: PrismaService) {}

  // ==================== OPTIMIZED HELPER METHODS ====================

  /**
   * Get fee collection summary from optimized database view
   * Uses fee_collection_summary view for better performance
   */
  private async getFeeCollectionSummaryFromView(
    institutionId: number,
    filters?: {
      semesterId?: number;
      courseId?: number;
      feeType?: string;
      academicYearId?: number;
    },
  ) {
    let query = `
      SELECT * FROM fee_collection_summary
      WHERE institution_id = ${institutionId}
    `;

    if (filters?.semesterId) {
      query += ` AND semester_id = ${filters.semesterId}`;
    }
    if (filters?.courseId) {
      query += ` AND course_id = ${filters.courseId}`;
    }
    if (filters?.feeType) {
      query += ` AND fee_type = '${filters.feeType}'`;
    }
    if (filters?.academicYearId) {
      query += ` AND academic_year_id = ${filters.academicYearId}`;
    }

    return this.prisma.$queryRawUnsafe(query);
  }

  /**
   * Get student fee status from optimized database view
   * Uses student_fee_status view for better performance
   */
  private async getStudentFeeStatusFromView(
    studentId: number,
    semesterId?: number,
  ): Promise<StudentFeeStatusView[]> {
    let query = `
      SELECT * FROM student_fee_status
      WHERE student_id = ${studentId}
    `;

    if (semesterId) {
      query += ` AND semester_id = ${semesterId}`;
    }

    query += ' ORDER BY due_date ASC';

    return this.prisma.$queryRawUnsafe<StudentFeeStatusView[]>(query);
  }

  /**
   * Get payment analytics from optimized database view
   * Uses payment_analytics view for better performance
   */
  private async getPaymentAnalyticsFromView(
    institutionId: number,
    startMonth?: Date,
    endMonth?: Date,
  ): Promise<PaymentAnalyticsView[]> {
    let query = `
      SELECT * FROM payment_analytics
      WHERE institution_id = ${institutionId}
    `;

    if (startMonth) {
      query += ` AND payment_month >= '${startMonth.toISOString()}'`;
    }
    if (endMonth) {
      query += ` AND payment_month <= '${endMonth.toISOString()}'`;
    }

    query += ' ORDER BY payment_month DESC';

    return this.prisma.$queryRawUnsafe<PaymentAnalyticsView[]>(query);
  }

  /**
   * Get overdue fees from optimized database view
   * Uses overdue_fees_summary view for better performance
   */
  private async getOverdueFeesFromView(institutionId?: number): Promise<OverdueFeeView[]> {
    let query = 'SELECT * FROM overdue_fees_summary';

    if (institutionId) {
      query += ` WHERE institution_id = ${institutionId}`;
    }

    query += ' ORDER BY days_overdue DESC LIMIT 100';

    return this.prisma.$queryRawUnsafe<OverdueFeeView[]>(query);
  }

  // ==================== FEE STRUCTURE METHODS ====================

  /**
   * Create a new fee structure
   */
  async createFeeStructure(dto: CreateFeeStructureDto) {
    // Validate institution exists
    const institution = await this.prisma.institution.findUnique({
      where: { id: dto.institutionId },
    });

    if (!institution) {
      throw new NotFoundException(
        `Institution with ID ${dto.institutionId} not found`,
      );
    }

    // Validate academic year exists
    const academicYear = await this.prisma.academicYear.findUnique({
      where: { id: dto.academicYearId },
    });

    if (!academicYear) {
      throw new NotFoundException(
        `Academic Year with ID ${dto.academicYearId} not found`,
      );
    }

    // Validate course if provided
    if (dto.courseId) {
      const course = await this.prisma.course.findUnique({
        where: { id: dto.courseId },
      });

      if (!course) {
        throw new NotFoundException(`Course with ID ${dto.courseId} not found`);
      }
    }

    return this.prisma.feeStructure.create({
      data: {
        ...dto,
        dueDate: dto.dueDate ? new Date(dto.dueDate) : null,
      },
      include: {
        institution: {
          select: { id: true, name: true, code: true },
        },
        course: {
          select: { id: true, name: true, code: true },
        },
        academicYear: {
          select: { id: true, yearName: true },
        },
      },
    });
  }

  /**
   * Get all fee structures with filtering
   */
  async findAllFeeStructures(query: FeeStructureQueryDto) {
    const { institutionId, courseId, academicYearId, feeType, status, page = 1, limit = 10 } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.FeeStructureWhereInput = {};

    if (institutionId) {
      where.institutionId = institutionId;
    }

    if (courseId) {
      where.courseId = courseId;
    }

    if (academicYearId) {
      where.academicYearId = academicYearId;
    }

    if (feeType) {
      where.feeType = feeType;
    }

    if (status) {
      where.status = status;
    }

    const [total, data] = await Promise.all([
      this.prisma.feeStructure.count({ where }),
      this.prisma.feeStructure.findMany({
        where,
        skip,
        take: limit,
        select: {
          id: true,
          institutionId: true,
          courseId: true,
          academicYearId: true,
          feeType: true,
          feeName: true,
          amount: true,
          dueDate: true,
          lateFeeAmount: true,
          lateFeeAfterDays: true,
          isRecurring: true,
          recurringFrequency: true,
          description: true,
          status: true,
          createdAt: true,
          updatedAt: true,
          institution: {
            select: { id: true, name: true, code: true },
          },
          course: {
            select: { id: true, name: true, code: true },
          },
          academicYear: {
            select: { id: true, yearName: true },
          },
          _count: {
            select: { studentFees: true },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get a single fee structure by ID
   */
  async findOneFeeStructure(id: number) {
    const feeStructure = await this.prisma.feeStructure.findUnique({
      where: { id },
      include: {
        institution: {
          select: { id: true, name: true, code: true },
        },
        course: {
          select: { id: true, name: true, code: true },
        },
        academicYear: {
          select: { id: true, yearName: true },
        },
        _count: {
          select: { studentFees: true },
        },
      },
    });

    if (!feeStructure) {
      throw new NotFoundException(`Fee structure with ID ${id} not found`);
    }

    return feeStructure;
  }

  /**
   * Update a fee structure
   */
  async updateFeeStructure(id: number, dto: UpdateFeeStructureDto) {
    // Check if fee structure exists
    await this.findOneFeeStructure(id);

    // Validate course if provided
    if (dto.courseId) {
      const course = await this.prisma.course.findUnique({
        where: { id: dto.courseId },
      });

      if (!course) {
        throw new NotFoundException(`Course with ID ${dto.courseId} not found`);
      }
    }

    const updateData: any = { ...dto };
    if (dto.dueDate) {
      updateData.dueDate = new Date(dto.dueDate);
    }

    return this.prisma.feeStructure.update({
      where: { id },
      data: updateData,
      include: {
        institution: {
          select: { id: true, name: true, code: true },
        },
        course: {
          select: { id: true, name: true, code: true },
        },
        academicYear: {
          select: { id: true, yearName: true },
        },
      },
    });
  }

  /**
   * Delete a fee structure
   */
  async deleteFeeStructure(id: number) {
    // Check if fee structure exists
    await this.findOneFeeStructure(id);

    // Check if there are any student fees associated
    const studentFeesCount = await this.prisma.studentFee.count({
      where: { feeStructureId: id },
    });

    if (studentFeesCount > 0) {
      throw new BadRequestException(
        `Cannot delete fee structure with ${studentFeesCount} associated student fees`,
      );
    }

    return this.prisma.feeStructure.delete({ where: { id } });
  }

  // ==================== STUDENT FEE METHODS ====================

  /**
   * Create a student fee record
   */
  async createStudentFee(dto: CreateStudentFeeDto) {
    // Validate student exists
    const student = await this.prisma.student.findUnique({
      where: { id: dto.studentId },
    });

    if (!student) {
      throw new NotFoundException(`Student with ID ${dto.studentId} not found`);
    }

    // Validate fee structure exists
    const feeStructure = await this.prisma.feeStructure.findUnique({
      where: { id: dto.feeStructureId },
    });

    if (!feeStructure) {
      throw new NotFoundException(
        `Fee structure with ID ${dto.feeStructureId} not found`,
      );
    }

    // Check if student fee already exists
    const existing = await this.prisma.studentFee.findFirst({
      where: {
        studentId: dto.studentId,
        feeStructureId: dto.feeStructureId,
        semesterId: dto.semesterId || null,
      },
    });

    if (existing) {
      throw new BadRequestException(
        'Fee already assigned to this student for this semester',
      );
    }

    return this.prisma.studentFee.create({
      data: {
        ...dto,
        dueDate: new Date(dto.dueDate),
      },
      include: {
        student: {
          select: {
            id: true,
            user: {
              select: { name: true, email: true },
            },
          },
        },
        feeStructure: true,
        semester: {
          select: { id: true, semesterName: true },
        },
      },
    });
  }

  /**
   * Bulk create student fees for multiple students
   */
  async bulkCreateStudentFees(dto: BulkCreateStudentFeesDto) {
    const { studentIds, feeStructureId, semesterId, discount, remarks } = dto;

    // Validate fee structure exists
    const feeStructure = await this.prisma.feeStructure.findUnique({
      where: { id: feeStructureId },
    });

    if (!feeStructure) {
      throw new NotFoundException(
        `Fee structure with ID ${feeStructureId} not found`,
      );
    }

    const results = [];
    const errors = [];

    for (const studentId of studentIds) {
      try {
        // Check if student exists
        const student = await this.prisma.student.findUnique({
          where: { id: studentId },
        });

        if (!student) {
          errors.push({
            studentId,
            error: 'Student not found',
          });
          continue;
        }

        // Check if fee already assigned
        const existing = await this.prisma.studentFee.findFirst({
          where: {
            studentId,
            feeStructureId,
            semesterId: semesterId || null,
          },
        });

        if (existing) {
          errors.push({
            studentId,
            error: 'Fee already assigned',
          });
          continue;
        }

        const amountDue =
          Number(feeStructure.amount) - (discount ? Number(discount) : 0);

        const studentFee = await this.prisma.studentFee.create({
          data: {
            studentId,
            feeStructureId,
            semesterId,
            amountDue,
            discount: discount || 0,
            dueDate: feeStructure.dueDate || new Date(),
            remarks,
          },
        });

        results.push(studentFee);
      } catch (error) {
        errors.push({
          studentId,
          error: error.message,
        });
      }
    }

    return {
      success: results.length,
      failed: errors.length,
      results,
      errors,
    };
  }

  /**
   * Get all student fees with filtering
   */
  async findAllStudentFees(query: StudentFeeQueryDto) {
    const { studentId, institutionId, semesterId, courseId, status, page = 1, limit = 10 } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.StudentFeeWhereInput = {};

    if (studentId) {
      where.studentId = studentId;
    }

    if (semesterId) {
      where.semesterId = semesterId;
    }

    if (status) {
      where.status = status;
    }

    // Build student filter properly
    const studentFilter: Prisma.StudentWhereInput = {};
    if (institutionId) {
      studentFilter.institutionId = institutionId;
    }
    if (courseId) {
      studentFilter.courseId = courseId;
    }
    if (Object.keys(studentFilter).length > 0) {
      where.student = studentFilter;
    }

    const [total, data] = await Promise.all([
      this.prisma.studentFee.count({ where }),
      this.prisma.studentFee.findMany({
        where,
        skip,
        take: limit,
        select: {
          id: true,
          studentId: true,
          feeStructureId: true,
          semesterId: true,
          amountDue: true,
          amountPaid: true,
          lateFeeApplied: true,
          discount: true,
          dueDate: true,
          status: true,
          remarks: true,
          createdAt: true,
          updatedAt: true,
          student: {
            select: {
              id: true,
              rollNumber: true,
              user: {
                select: { 
                  id: true,
                  name: true, 
                  email: true, 
                  edverseId: true 
                },
              },
            },
          },
          feeStructure: {
            select: {
              id: true,
              feeName: true,
              feeType: true,
              amount: true,
              dueDate: true,
            },
          },
          semester: {
            select: { id: true, semesterName: true },
          },
          payments: {
            where: { status: 'COMPLETED' },
            select: {
              id: true,
              amount: true,
              paymentDate: true,
              paymentMethod: true,
              receiptNumber: true,
            },
            orderBy: { paymentDate: 'desc' },
          },
        },
        orderBy: { dueDate: 'asc' },
      }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get a single student fee by ID
   */
  async findOneStudentFee(id: number) {
    const studentFee = await this.prisma.studentFee.findUnique({
      where: { id },
      include: {
        student: {
          select: {
            id: true,
            user: {
              select: { name: true, email: true, edverseId: true },
            },
          },
        },
        feeStructure: true,
        semester: {
          select: { id: true, semesterName: true },
        },
        payments: {
          select: {
            id: true,
            amount: true,
            paymentDate: true,
            paymentMethod: true,
            status: true,
            receiptNumber: true,
          },
        },
      },
    });

    if (!studentFee) {
      throw new NotFoundException(`Student fee with ID ${id} not found`);
    }

    return studentFee;
  }

  /**
   * Update a student fee
   */
  async updateStudentFee(id: number, dto: UpdateStudentFeeDto) {
    // Check if student fee exists
    await this.findOneStudentFee(id);

    const updateData: any = { ...dto };
    if (dto.dueDate) {
      updateData.dueDate = new Date(dto.dueDate);
    }

    return this.prisma.studentFee.update({
      where: { id },
      data: updateData,
      include: {
        student: {
          select: {
            id: true,
            user: {
              select: { name: true, email: true },
            },
          },
        },
        feeStructure: true,
        semester: {
          select: { id: true, semesterName: true },
        },
      },
    });
  }

  /**
   * Delete a student fee
   */
  async deleteStudentFee(id: number) {
    // Check if student fee exists
    const studentFee = await this.findOneStudentFee(id);

    // Check if there are any payments
    if (Number(studentFee.amountPaid) > 0) {
      throw new BadRequestException(
        'Cannot delete student fee with payments. Refund payments first.',
      );
    }

    return this.prisma.studentFee.delete({ where: { id } });
  }

  /**
   * Get fee summary for a student (OPTIMIZED)
   * Uses student_fee_status view for better performance
   */
  async getStudentFeeSummary(studentId: number, semesterId?: number) {
    // Use optimized view for better performance
    const feeStatusData = await this.getStudentFeeStatusFromView(
      studentId,
      semesterId,
    );

    const totalDue = feeStatusData.reduce(
      (sum: number, fee: StudentFeeStatusView) => sum + Number(fee.amount_due),
      0,
    );
    const totalPaid = feeStatusData.reduce(
      (sum: number, fee: StudentFeeStatusView) => sum + Number(fee.amount_paid),
      0,
    );
    const totalLateFees = feeStatusData.reduce(
      (sum: number, fee: StudentFeeStatusView) => sum + Number(fee.late_fee_applied),
      0,
    );
    const totalDiscount = feeStatusData.reduce(
      (sum: number, fee: StudentFeeStatusView) => sum + Number(fee.discount),
      0,
    );

    return {
      totalFees: feeStatusData.length,
      totalDue,
      totalPaid,
      totalPending: totalDue - totalPaid,
      totalLateFees,
      totalDiscount,
      feesByStatus: {
        pending: feeStatusData.filter((f: StudentFeeStatusView) => f.status === 'PENDING')
          .length,
        partial: feeStatusData.filter((f: StudentFeeStatusView) => f.status === 'PARTIAL')
          .length,
        paid: feeStatusData.filter((f: StudentFeeStatusView) => f.status === 'PAID').length,
        overdue: feeStatusData.filter((f: StudentFeeStatusView) => f.status === 'OVERDUE')
          .length,
        waived: feeStatusData.filter((f: StudentFeeStatusView) => f.status === 'WAIVED').length,
      },
      fees: feeStatusData,
    };
  }

  // ==================== PAYMENT METHODS ====================

  /**
   * Create a payment
   */
  async createPayment(dto: CreatePaymentDto, processedBy: number) {
    // Validate student exists
    const student = await this.prisma.student.findUnique({
      where: { id: dto.studentId },
    });

    if (!student) {
      throw new NotFoundException(`Student with ID ${dto.studentId} not found`);
    }

    // Validate student fee if provided
    let studentFee;
    if (dto.studentFeeId) {
      studentFee = await this.prisma.studentFee.findUnique({
        where: { id: dto.studentFeeId },
      });

      if (!studentFee) {
        throw new NotFoundException(
          `Student fee with ID ${dto.studentFeeId} not found`,
        );
      }

      // Check if payment amount is valid
      const remainingAmount =
        Number(studentFee.amountDue) - Number(studentFee.amountPaid);

      if (Number(dto.amount) > remainingAmount) {
        throw new BadRequestException(
          `Payment amount (${dto.amount}) exceeds remaining amount (${remainingAmount})`,
        );
      }
    }

    // Generate receipt number
    const receiptNumber = await this.generateReceiptNumber(student.institutionId);

    // Create payment
    const payment = await this.prisma.payment.create({
      data: {
        ...dto,
        paymentDate: dto.paymentDate ? new Date(dto.paymentDate) : new Date(),
        chequeDate: dto.chequeDate ? new Date(dto.chequeDate) : null,
        status: 'COMPLETED',
        receiptNumber,
        processedBy,
        processedAt: new Date(),
      },
      include: {
        student: {
          select: {
            id: true,
            user: {
              select: { name: true, email: true, edverseId: true },
            },
          },
        },
        studentFee: {
          include: {
            feeStructure: true,
          },
        },
        processor: {
          select: { id: true, name: true, email: true },
        },
      },
    });

    // Update student fee if provided
    if (dto.studentFeeId && studentFee) {
      const newAmountPaid = Number(studentFee.amountPaid) + Number(dto.amount);
      const amountDue = Number(studentFee.amountDue);

      let status = 'PARTIAL';
      if (newAmountPaid >= amountDue) {
        status = 'PAID';
      }

      await this.prisma.studentFee.update({
        where: { id: dto.studentFeeId },
        data: {
          amountPaid: newAmountPaid,
          status: status as FeeStatus,
        },
      });
    }

    return payment;
  }

  /**
   * Get all payments with filtering
   */
  async findAllPayments(query: PaymentQueryDto) {
    const {
      studentId,
      institutionId,
      status,
      paymentMethod,
      startDate,
      endDate,
      page = 1,
      limit = 10,
    } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.PaymentWhereInput = {};

    if (studentId) {
      where.studentId = studentId;
    }

    if (status) {
      where.status = status;
    }

    if (paymentMethod) {
      where.paymentMethod = paymentMethod;
    }

    if (startDate || endDate) {
      where.paymentDate = {};
      if (startDate) {
        where.paymentDate.gte = new Date(startDate);
      }
      if (endDate) {
        where.paymentDate.lte = new Date(endDate);
      }
    }

    if (institutionId) {
      where.student = {
        institutionId,
      };
    }

    const [total, data] = await Promise.all([
      this.prisma.payment.count({ where }),
      this.prisma.payment.findMany({
        where,
        skip,
        take: limit,
        select: {
          id: true,
          studentId: true,
          studentFeeId: true,
          amount: true,
          paymentMethod: true,
          paymentMode: true,
          transactionId: true,
          referenceNumber: true,
          paymentDate: true,
          status: true,
          remarks: true,
          receiptNumber: true,
          processedBy: true,
          processedAt: true,
          createdAt: true,
          student: {
            select: {
              id: true,
              rollNumber: true,
              user: {
                select: { 
                  id: true,
                  name: true, 
                  email: true, 
                  edverseId: true 
                },
              },
            },
          },
          studentFee: {
            select: {
              id: true,
              amountDue: true,
              amountPaid: true,
              status: true,
              feeStructure: {
                select: {
                  id: true,
                  feeName: true,
                  feeType: true,
                  amount: true,
                },
              },
            },
          },
          processor: {
            select: { id: true, name: true, email: true },
          },
        },
        orderBy: { paymentDate: 'desc' },
      }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get a single payment by ID
   */
  async findOnePayment(id: number) {
    const payment = await this.prisma.payment.findUnique({
      where: { id },
      include: {
        student: {
          select: {
            id: true,
            user: {
              select: { name: true, email: true, edverseId: true },
            },
          },
        },
        studentFee: {
          include: {
            feeStructure: true,
          },
        },
        processor: {
          select: { id: true, name: true, email: true },
        },
      },
    });

    if (!payment) {
      throw new NotFoundException(`Payment with ID ${id} not found`);
    }

    return payment;
  }

  /**
   * Update a payment
   */
  async updatePayment(id: number, dto: UpdatePaymentDto) {
    // Check if payment exists
    await this.findOnePayment(id);

    return this.prisma.payment.update({
      where: { id },
      data: dto,
      include: {
        student: {
          select: {
            id: true,
            user: {
              select: { name: true, email: true },
            },
          },
        },
        studentFee: {
          include: {
            feeStructure: true,
          },
        },
      },
    });
  }

  /**
   * Cancel a payment
   */
  async cancelPayment(id: number) {
    const payment = await this.findOnePayment(id);

    if (payment.status !== 'PENDING' && payment.status !== 'COMPLETED') {
      throw new BadRequestException(
        `Cannot cancel payment with status: ${payment.status}`,
      );
    }

    // Update payment status
    const updatedPayment = await this.prisma.payment.update({
      where: { id },
      data: { status: 'CANCELLED' },
    });

    // Revert student fee amount if it was completed
    if (payment.status === 'COMPLETED' && payment.studentFeeId) {
      const studentFee = await this.prisma.studentFee.findUnique({
        where: { id: payment.studentFeeId },
      });

      if (studentFee) {
        const newAmountPaid =
          Number(studentFee.amountPaid) - Number(payment.amount);

        let status = 'PENDING';
        if (newAmountPaid > 0) {
          status = 'PARTIAL';
        }

        await this.prisma.studentFee.update({
          where: { id: payment.studentFeeId },
          data: {
            amountPaid: newAmountPaid,
            status: status as FeeStatus,
          },
        });
      }
    }

    return updatedPayment;
  }

  /**
   * Get payment summary for an institution (OPTIMIZED)
   * Uses payment_analytics view for better performance
   */
  async getPaymentSummary(institutionId: number, startDate?: string, endDate?: string) {
    // Use optimized view for better performance
    const startMonth = startDate ? new Date(startDate) : undefined;
    const endMonth = endDate ? new Date(endDate) : undefined;

    const analyticsData = await this.getPaymentAnalyticsFromView(
      institutionId,
      startMonth,
      endMonth,
    );

    // Filter for completed payments only
    const completedPayments = analyticsData.filter(
      (record: any) => record.status === 'COMPLETED',
    );

    const totalAmount = completedPayments.reduce(
      (sum: number, record: any) => sum + Number(record.total_amount),
      0,
    );

    const totalPayments = completedPayments.reduce(
      (sum: number, record: any) => sum + Number(record.transaction_count),
      0,
    );

    // Aggregate by payment method
    const byMethod: Record<string, { count: number; amount: number }> = {};
    completedPayments.forEach((record: any) => {
      const method = record.payment_method;
      if (!byMethod[method]) {
        byMethod[method] = { count: 0, amount: 0 };
      }
      byMethod[method].count += Number(record.transaction_count);
      byMethod[method].amount += Number(record.total_amount);
    });

    // Aggregate by payment mode
    const byMode: Record<string, { count: number; amount: number }> = {};
    completedPayments.forEach((record: any) => {
      const mode = record.payment_mode;
      if (!byMode[mode]) {
        byMode[mode] = { count: 0, amount: 0 };
      }
      byMode[mode].count += Number(record.transaction_count);
      byMode[mode].amount += Number(record.total_amount);
    });

    // Monthly trends
    const monthlyTrends = completedPayments.reduce((acc: any[], record: any) => {
      const month = new Date(record.payment_month).toISOString().slice(0, 7);
      const existing = acc.find((item) => item.month === month);
      
      if (existing) {
        existing.count += Number(record.transaction_count);
        existing.amount += Number(record.total_amount);
      } else {
        acc.push({
          month,
          count: Number(record.transaction_count),
          amount: Number(record.total_amount),
        });
      }
      
      return acc;
    }, []);

    return {
      totalPayments,
      totalAmount,
      byMethod,
      byMode,
      monthlyTrends: monthlyTrends.sort((a, b) => a.month.localeCompare(b.month)),
    };
  }

  // ==================== UTILITY METHODS ====================

  /**
   * Generate unique receipt number
   */
  private async generateReceiptNumber(institutionId: number): Promise<string> {
    const year = new Date().getFullYear();
    const count = await this.prisma.payment.count({
      where: {
        student: {
          institutionId,
        },
      },
    });

    return `RCP-${institutionId}-${year}-${String(count + 1).padStart(5, '0')}`;
  }

  /**
   * Calculate and apply late fees
   */
  async calculateLateFees() {
    const today = new Date();

    const overdueStudentFees = await this.prisma.studentFee.findMany({
      where: {
        status: {
          in: ['PENDING', 'PARTIAL'],
        },
        dueDate: {
          lt: today,
        },
      },
      include: {
        feeStructure: true,
      },
    });

    for (const studentFee of overdueStudentFees) {
      const { feeStructure } = studentFee;

      if (
        feeStructure.lateFeeAmount &&
        Number(feeStructure.lateFeeAmount) > 0 &&
        feeStructure.lateFeeAfterDays
      ) {
        const daysOverdue = Math.floor(
          (today.getTime() - studentFee.dueDate.getTime()) /
            (1000 * 60 * 60 * 24),
        );

        if (daysOverdue >= feeStructure.lateFeeAfterDays) {
          const lateFeeAmount = Number(feeStructure.lateFeeAmount);

          await this.prisma.studentFee.update({
            where: { id: studentFee.id },
            data: {
              lateFeeApplied: lateFeeAmount,
              status: 'OVERDUE',
            },
          });
        }
      } else if (studentFee.status !== 'OVERDUE') {
        // Mark as overdue even without late fee
        await this.prisma.studentFee.update({
          where: { id: studentFee.id },
          data: {
            status: 'OVERDUE',
          },
        });
      }
    }

    return { updated: overdueStudentFees.length };
  }

  /**
   * Get overdue fees report (OPTIMIZED)
   * Uses overdue_fees_summary view for better performance
   */
  async getOverdueFees(institutionId?: number) {
    // Use optimized view for better performance
    const overdueFees = await this.getOverdueFeesFromView(institutionId);

    const totalOverdue = overdueFees.reduce(
      (sum: number, fee: OverdueFeeView) => sum + Number(fee.total_overdue_amount),
      0,
    );

    return {
      count: overdueFees.length,
      totalOverdue,
      fees: overdueFees,
    };
  }

  /**
   * Get fee collection summary (OPTIMIZED)
   * Uses fee_collection_summary view for comprehensive analytics
   */
  async getFeeCollectionSummary(
    institutionId: number,
    filters?: {
      semesterId?: number;
      courseId?: number;
      feeType?: string;
      academicYearId?: number;
    },
  ) {
    const summary = await this.getFeeCollectionSummaryFromView(
      institutionId,
      filters,
    );

    return {
      summary,
      metadata: {
        institutionId,
        filters,
        generatedAt: new Date(),
      },
    };
  }
}
