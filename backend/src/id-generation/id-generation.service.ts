import { Injectable, Logger, NotFoundException } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'
import {
  parseTemplate,
  TemplateContext,
  validateTemplate,
} from '../utils/id-template.util'
import { IdConfigCacheService } from './id-config-cache.service'
import { SequenceService, SequenceType } from './sequence.service'

export interface GenerateIdOptions {
  institutionId: number
  courseCode?: string
  section?: string
  customValue?: string // If provided, skip generation and use this
}

export interface GeneratedIds {
  admissionNumber?: string
  rollNumber?: string
  employeeId?: string
}

/**
 * ID Generation Service
 *
 * Main service for generating admission numbers, roll numbers, and employee IDs.
 * Uses configurable templates per institution with atomic sequence generation.
 *
 * Features:
 * - Template-based ID generation
 * - Caching for performance
 * - Atomic sequence handling (no race conditions)
 * - Support for custom/override values
 */
@Injectable()
export class IdGenerationService {
  private readonly logger = new Logger(IdGenerationService.name)

  constructor(
    private readonly prisma: PrismaService,
    private readonly cacheService: IdConfigCacheService,
    private readonly sequenceService: SequenceService
  ) {}

  /**
   * Generate admission number for a student
   */
  async generateAdmissionNumber(options: GenerateIdOptions): Promise<string> {
    // If custom value provided, validate and return it
    if (options.customValue) {
      await this.validateUniqueAdmissionNumber(options.customValue)
      return options.customValue
    }

    const { config, institution } = await this.getConfigAndInstitution(
      options.institutionId
    )

    // Get next sequence atomically
    const seqResult = await this.sequenceService.getNextSequence(
      options.institutionId,
      'admission'
    )

    const context: TemplateContext = {
      year: seqResult.year,
      month: seqResult.month,
      institutionCode: institution.code,
      courseCode: options.courseCode || 'GEN',
      section: options.section,
      sequence: seqResult.sequence,
    }

    const admissionNumber = parseTemplate(config.admissionNumberFormat, context)

    // Verify uniqueness (edge case handling)
    await this.validateUniqueAdmissionNumber(admissionNumber)

    this.logger.log(
      `Generated admission number: ${admissionNumber} for institution ${options.institutionId}`
    )

    return admissionNumber
  }

  /**
   * Generate roll number for a student
   */
  async generateRollNumber(options: GenerateIdOptions): Promise<string | null> {
    // Roll number requires section
    if (!options.section && !options.customValue) {
      return null
    }

    // If custom value provided, return it
    if (options.customValue) {
      return options.customValue
    }

    const { config, institution } = await this.getConfigAndInstitution(
      options.institutionId
    )

    // Get next sequence atomically
    const seqResult = await this.sequenceService.getNextSequence(
      options.institutionId,
      'roll'
    )

    const context: TemplateContext = {
      year: seqResult.year,
      month: seqResult.month,
      institutionCode: institution.code,
      courseCode: options.courseCode || 'GEN',
      section: options.section,
      sequence: seqResult.sequence,
    }

    const rollNumber = parseTemplate(config.rollNumberFormat, context)

    this.logger.log(
      `Generated roll number: ${rollNumber} for institution ${options.institutionId}`
    )

    return rollNumber
  }

  /**
   * Generate employee ID for a teacher
   */
  async generateTeacherEmployeeId(options: GenerateIdOptions): Promise<string> {
    // If custom value provided, validate and return it
    if (options.customValue) {
      await this.validateUniqueTeacherEmployeeId(options.customValue)
      return options.customValue
    }

    const { config, institution } = await this.getConfigAndInstitution(
      options.institutionId
    )

    // Get next sequence atomically
    const seqResult = await this.sequenceService.getNextSequence(
      options.institutionId,
      'teacherEmployee'
    )

    const context: TemplateContext = {
      year: seqResult.year,
      month: seqResult.month,
      institutionCode: institution.code,
      sequence: seqResult.sequence,
    }

    const employeeId = parseTemplate(config.teacherEmployeeIdFormat, context)

    // Verify uniqueness
    await this.validateUniqueTeacherEmployeeId(employeeId)

    this.logger.log(
      `Generated teacher employee ID: ${employeeId} for institution ${options.institutionId}`
    )

    return employeeId
  }

  /**
   * Generate employee ID for staff
   */
  async generateStaffEmployeeId(options: GenerateIdOptions): Promise<string> {
    // If custom value provided, validate and return it
    if (options.customValue) {
      await this.validateUniqueStaffEmployeeId(options.customValue)
      return options.customValue
    }

    const { config, institution } = await this.getConfigAndInstitution(
      options.institutionId
    )

    // Get next sequence atomically
    const seqResult = await this.sequenceService.getNextSequence(
      options.institutionId,
      'staffEmployee'
    )

    const context: TemplateContext = {
      year: seqResult.year,
      month: seqResult.month,
      institutionCode: institution.code,
      sequence: seqResult.sequence,
    }

    const employeeId = parseTemplate(config.staffEmployeeIdFormat, context)

    // Verify uniqueness
    await this.validateUniqueStaffEmployeeId(employeeId)

    this.logger.log(
      `Generated staff employee ID: ${employeeId} for institution ${options.institutionId}`
    )

    return employeeId
  }

  /**
   * Preview what an ID would look like with given template and context
   * Does not increment sequence counter
   */
  async previewId(
    institutionId: number,
    template: string,
    context: Partial<TemplateContext>
  ): Promise<{ preview: string; isValid: boolean; errors: string[] }> {
    const validation = validateTemplate(template)

    if (!validation.isValid) {
      return {
        preview: '',
        isValid: false,
        errors: validation.errors,
      }
    }

    const institution = await this.prisma.institution.findUnique({
      where: { id: institutionId },
      select: { code: true },
    })

    const fullContext: TemplateContext = {
      year: context.year || new Date().getFullYear(),
      month: context.month || new Date().getMonth() + 1,
      institutionCode: context.institutionCode || institution?.code || 'INST',
      courseCode: context.courseCode || 'COURSE',
      section: context.section || 'A',
      sequence: context.sequence || 1,
    }

    const preview = parseTemplate(template, fullContext)

    return {
      preview,
      isValid: true,
      errors: [],
    }
  }

  /**
   * Get ID configuration for an institution
   */
  async getIdConfig(institutionId: number) {
    return this.cacheService.getConfig(institutionId)
  }

  /**
   * Update ID configuration for an institution
   */
  async updateIdConfig(
    institutionId: number,
    updates: {
      admissionNumberFormat?: string
      rollNumberFormat?: string
      teacherEmployeeIdFormat?: string
      staffEmployeeIdFormat?: string
      sequenceResetPolicy?: 'YEARLY' | 'MONTHLY' | 'NEVER'
    }
  ) {
    // Validate templates
    const templates = [
      updates.admissionNumberFormat,
      updates.rollNumberFormat,
      updates.teacherEmployeeIdFormat,
      updates.staffEmployeeIdFormat,
    ].filter(Boolean)

    for (const template of templates) {
      const validation = validateTemplate(template!)
      if (!validation.isValid) {
        throw new Error(`Invalid template: ${validation.errors.join(', ')}`)
      }
    }

    const config = await this.prisma.institutionIdConfig.update({
      where: { institutionId },
      data: updates,
    })

    // Invalidate cache
    this.cacheService.invalidate(institutionId)

    return config
  }

  /**
   * Reset sequence counters for an institution
   */
  async resetSequence(
    institutionId: number,
    sequenceType: SequenceType,
    startFrom: number = 0
  ) {
    await this.sequenceService.resetSequence(
      institutionId,
      sequenceType,
      startFrom
    )
    this.cacheService.invalidate(institutionId)
  }

  // Private helper methods

  private async getConfigAndInstitution(institutionId: number) {
    const [config, institution] = await Promise.all([
      this.cacheService.getConfig(institutionId),
      this.prisma.institution.findUnique({
        where: { id: institutionId },
        select: { id: true, code: true, name: true },
      }),
    ])

    if (!institution) {
      throw new NotFoundException(`Institution ${institutionId} not found`)
    }

    if (!institution.code) {
      throw new Error(
        'Institution code not configured. Please contact administrator.'
      )
    }

    return { config, institution }
  }

  private async validateUniqueAdmissionNumber(
    admissionNumber: string
  ): Promise<void> {
    const existing = await this.prisma.student.findUnique({
      where: { admissionNumber },
      select: { id: true },
    })

    if (existing) {
      throw new Error(`Admission number ${admissionNumber} already exists`)
    }
  }

  private async validateUniqueTeacherEmployeeId(
    employeeId: string
  ): Promise<void> {
    const existing = await this.prisma.teacher.findUnique({
      where: { employeeId },
      select: { id: true },
    })

    if (existing) {
      throw new Error(`Teacher employee ID ${employeeId} already exists`)
    }
  }

  private async validateUniqueStaffEmployeeId(
    employeeId: string
  ): Promise<void> {
    const existing = await this.prisma.staff.findUnique({
      where: { employeeId },
      select: { id: true },
    })

    if (existing) {
      throw new Error(`Staff employee ID ${employeeId} already exists`)
    }
  }
}
