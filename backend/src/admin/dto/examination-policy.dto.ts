import { Type } from 'class-transformer'
import {
  IsBoolean,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator'

export class UpdateExaminationPolicyDto {
  // Examination Scheduling Policies
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(1)
  @Max(30)
  minAdvanceNoticeDays?: number // Minimum days notice before exam

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(30)
  @Max(480)
  maxExamDurationMinutes?: number // Maximum exam duration

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(1)
  @Max(10)
  maxExamsPerDay?: number // Maximum exams a student can have per day

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  @Max(7)
  minGapBetweenExamsDays?: number // Minimum gap between major exams

  // Evaluation Policies
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(1)
  @Max(30)
  maxEvaluationDays?: number // Maximum days to complete evaluation after exam

  @IsOptional()
  @IsBoolean()
  requireEvaluatorApproval?: boolean // Require admin approval for evaluators

  @IsOptional()
  @IsBoolean()
  allowSelfEvaluation?: boolean // Allow teachers to evaluate their own exams

  @IsOptional()
  @IsBoolean()
  requireDoubleEvaluation?: boolean // Require two evaluators for major exams

  // Result Publication Policies
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  @Max(30)
  resultPublicationDelayDays?: number // Days to wait before publishing results

  @IsOptional()
  @IsBoolean()
  requireAdminApprovalForPublication?: boolean // Require admin approval before publishing

  @IsOptional()
  @IsBoolean()
  allowResultModification?: boolean // Allow result modification after publication

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(1)
  @Max(30)
  resultModificationWindowDays?: number // Days allowed for result modification

  // Grade Boundaries and Standards
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  @Max(100)
  defaultPassingPercentage?: number // Default passing percentage for all exams

  @IsOptional()
  @IsBoolean()
  enforceGradingScale?: boolean // Enforce institution grading scale

  @IsOptional()
  @IsBoolean()
  allowGradeInflation?: boolean // Allow teachers to apply grade curves

  // Attendance and Makeup Policies
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  @Max(100)
  minAttendanceForExam?: number // Minimum attendance percentage to appear in exam

  @IsOptional()
  @IsBoolean()
  allowMakeupExams?: boolean // Allow makeup exams for absent students

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(1)
  @Max(30)
  makeupExamWindowDays?: number // Days allowed to schedule makeup exam

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(0)
  @Max(50)
  makeupExamPenaltyPercentage?: number // Penalty percentage for makeup exams

  // Security and Integrity Policies
  @IsOptional()
  @IsBoolean()
  requireProctoring?: boolean // Require proctoring for exams

  @IsOptional()
  @IsBoolean()
  allowOpenBook?: boolean // Allow open book exams

  @IsOptional()
  @IsBoolean()
  requirePlagiarismCheck?: boolean // Require plagiarism checking

  @IsOptional()
  @IsString()
  examConductGuidelines?: string // General exam conduct guidelines

  // Notification Policies
  @IsOptional()
  @IsBoolean()
  notifyStudentsOnSchedule?: boolean // Notify students when exam is scheduled

  @IsOptional()
  @IsBoolean()
  notifyParentsOnResults?: boolean // Notify parents when results are published

  @IsOptional()
  @IsBoolean()
  sendReminderNotifications?: boolean // Send reminder notifications before exams

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(1)
  @Max(7)
  reminderDaysBeforeExam?: number // Days before exam to send reminder

  // Metadata
  @IsOptional()
  @IsBoolean()
  isActive?: boolean

  @IsOptional()
  @IsString()
  notes?: string // Additional policy notes
}
