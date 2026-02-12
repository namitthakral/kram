import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Put,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { FeesService } from './fees.service';
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

@Controller('fees')
@UseGuards(JwtAuthGuard, RolesGuard)
export class FeesController {
  constructor(private readonly feesService: FeesService) {}

  // ==================== FEE STRUCTURE ENDPOINTS ====================

  /**
   * Create a new fee structure
   * POST /fees/structures
   * Only super_admin and admin can create fee structures
   */
  @Post('structures')
  @Roles('super_admin', 'admin')
  createFeeStructure(@Body() dto: CreateFeeStructureDto) {
    return this.feesService.createFeeStructure(dto);
  }

  /**
   * Get all fee structures with filtering
   * GET /fees/structures
   * All authenticated users can view fee structures
   */
  @Get('structures')
  findAllFeeStructures(@Query() query: FeeStructureQueryDto) {
    return this.feesService.findAllFeeStructures(query);
  }

  /**
   * Get a single fee structure
   * GET /fees/structures/:id
   */
  @Get('structures/:id')
  findOneFeeStructure(@Param('id', ParseIntPipe) id: number) {
    return this.feesService.findOneFeeStructure(id);
  }

  /**
   * Update a fee structure
   * PUT /fees/structures/:id
   * Only super_admin and admin can update
   */
  @Put('structures/:id')
  @Roles('super_admin', 'admin')
  updateFeeStructure(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateFeeStructureDto,
  ) {
    return this.feesService.updateFeeStructure(id, dto);
  }

  /**
   * Delete a fee structure
   * DELETE /fees/structures/:id
   * Only super_admin can delete
   */
  @Delete('structures/:id')
  @Roles('super_admin')
  deleteFeeStructure(@Param('id', ParseIntPipe) id: number) {
    return this.feesService.deleteFeeStructure(id);
  }

  // ==================== STUDENT FEE ENDPOINTS ====================

  /**
   * Create a student fee record
   * POST /fees/student-fees
   * Only super_admin and admin can assign fees
   */
  @Post('student-fees')
  @Roles('super_admin', 'admin')
  createStudentFee(@Body() dto: CreateStudentFeeDto) {
    return this.feesService.createStudentFee(dto);
  }

  /**
   * Bulk create student fees for multiple students
   * POST /fees/student-fees/bulk
   * Only super_admin and admin can bulk assign fees
   */
  @Post('student-fees/bulk')
  @Roles('super_admin', 'admin')
  bulkCreateStudentFees(@Body() dto: BulkCreateStudentFeesDto) {
    return this.feesService.bulkCreateStudentFees(dto);
  }

  /**
   * Get all student fees with filtering
   * GET /fees/student-fees
   * Admin, teachers can view all; students can view their own
   */
  @Get('student-fees')
  @Roles('super_admin', 'admin', 'teacher', 'student', 'parent')
  findAllStudentFees(@Query() query: StudentFeeQueryDto, @Request() req) {
    // If user is a student, filter by their studentId
    if (req.user.role.roleName === 'student' && req.user.student) {
      query.studentId = req.user.student.id;
    }
    // If user is a parent, filter by their children
    // TODO: Implement parent-student relationship filtering

    return this.feesService.findAllStudentFees(query);
  }

  /**
   * Get a single student fee
   * GET /fees/student-fees/:id
   */
  @Get('student-fees/:id')
  @Roles('super_admin', 'admin', 'teacher', 'student', 'parent')
  findOneStudentFee(@Param('id', ParseIntPipe) id: number) {
    return this.feesService.findOneStudentFee(id);
  }

  /**
   * Update a student fee
   * PUT /fees/student-fees/:id
   * Only super_admin and admin can update
   */
  @Put('student-fees/:id')
  @Roles('super_admin', 'admin')
  updateStudentFee(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateStudentFeeDto,
  ) {
    return this.feesService.updateStudentFee(id, dto);
  }

  /**
   * Delete a student fee
   * DELETE /fees/student-fees/:id
   * Only super_admin can delete
   */
  @Delete('student-fees/:id')
  @Roles('super_admin')
  deleteStudentFee(@Param('id', ParseIntPipe) id: number) {
    return this.feesService.deleteStudentFee(id);
  }

  /**
   * Get fee summary for a student
   * GET /fees/student-fees/summary/:studentId
   * Admin, teachers, the student themselves, and parents can view
   */
  @Get('student-fees/summary/:studentId')
  @Roles('super_admin', 'admin', 'teacher', 'student', 'parent')
  getStudentFeeSummary(
    @Param('studentId', ParseIntPipe) studentId: number,
    @Query('semesterId') semesterId?: number,
  ) {
    return this.feesService.getStudentFeeSummary(studentId, semesterId);
  }

  // ==================== PAYMENT ENDPOINTS ====================

  /**
   * Create a payment
   * POST /fees/payments
   * Admin and staff can record payments
   */
  @Post('payments')
  @Roles('super_admin', 'admin', 'staff')
  createPayment(@Body() dto: CreatePaymentDto, @Request() req) {
    return this.feesService.createPayment(dto, req.user.id);
  }

  /**
   * Get all payments with filtering
   * GET /fees/payments
   * Admin and staff can view all; students can view their own
   */
  @Get('payments')
  @Roles('super_admin', 'admin', 'staff', 'teacher', 'student', 'parent')
  findAllPayments(@Query() query: PaymentQueryDto, @Request() req) {
    // If user is a student, filter by their studentId
    if (req.user.role.roleName === 'student' && req.user.student) {
      query.studentId = req.user.student.id;
    }
    // If user is a parent, filter by their children
    // TODO: Implement parent-student relationship filtering

    return this.feesService.findAllPayments(query);
  }

  /**
   * Get a single payment
   * GET /fees/payments/:id
   */
  @Get('payments/:id')
  @Roles('super_admin', 'admin', 'staff', 'teacher', 'student', 'parent')
  findOnePayment(@Param('id', ParseIntPipe) id: number) {
    return this.feesService.findOnePayment(id);
  }

  /**
   * Update a payment
   * PUT /fees/payments/:id
   * Only super_admin and admin can update
   */
  @Put('payments/:id')
  @Roles('super_admin', 'admin')
  updatePayment(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdatePaymentDto,
  ) {
    return this.feesService.updatePayment(id, dto);
  }

  /**
   * Cancel a payment
   * POST /fees/payments/:id/cancel
   * Only super_admin and admin can cancel
   */
  @Post('payments/:id/cancel')
  @Roles('super_admin', 'admin')
  cancelPayment(@Param('id', ParseIntPipe) id: number) {
    return this.feesService.cancelPayment(id);
  }

  /**
   * Get payment summary for an institution
   * GET /fees/payments/summary
   * Only super_admin and admin can view summary
   */
  @Get('payments/summary/institution')
  @Roles('super_admin', 'admin')
  getPaymentSummary(
    @Query('institutionId', ParseIntPipe) institutionId: number,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.feesService.getPaymentSummary(institutionId, startDate, endDate);
  }

  // ==================== UTILITY ENDPOINTS ====================

  /**
   * Calculate and apply late fees
   * POST /fees/calculate-late-fees
   * Only super_admin and admin can trigger
   */
  @Post('calculate-late-fees')
  @Roles('super_admin', 'admin')
  calculateLateFees() {
    return this.feesService.calculateLateFees();
  }

  /**
   * Get overdue fees report
   * GET /fees/overdue
   * Only super_admin and admin can view
   */
  @Get('overdue')
  @Roles('super_admin', 'admin')
  getOverdueFees(@Query('institutionId') institutionId?: number) {
    return this.feesService.getOverdueFees(
      institutionId ? Number(institutionId) : undefined,
    );
  }

  /**
   * Get fee collection summary (OPTIMIZED)
   * GET /fees/collection-summary
   * Only super_admin and admin can view
   */
  @Get('collection-summary')
  @Roles('super_admin', 'admin')
  getFeeCollectionSummary(
    @Query('institutionId', ParseIntPipe) institutionId: number,
    @Query('semesterId') semesterId?: number,
    @Query('courseId') courseId?: number,
    @Query('feeType') feeType?: string,
    @Query('academicYearId') academicYearId?: number,
  ) {
    return this.feesService.getFeeCollectionSummary(institutionId, {
      semesterId: semesterId ? Number(semesterId) : undefined,
      courseId: courseId ? Number(courseId) : undefined,
      feeType,
      academicYearId: academicYearId ? Number(academicYearId) : undefined,
    });
  }
}
