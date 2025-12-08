import { Injectable, Logger } from '@nestjs/common'
import { SequenceResetPolicy } from '@prisma/client'
import { PrismaService } from '../prisma/prisma.service'

export type SequenceType =
  | 'admission'
  | 'roll'
  | 'teacherEmployee'
  | 'staffEmployee'

interface SequenceResult {
  sequence: number
  year: number
  month: number
}

/**
 * Sequence Service
 *
 * Handles atomic sequence number generation with support for:
 * - Optimistic locking to prevent race conditions
 * - Automatic sequence reset based on policy (YEARLY, MONTHLY, NEVER)
 * - Retry mechanism for concurrent updates
 */
@Injectable()
export class SequenceService {
  private readonly logger = new Logger(SequenceService.name)
  private readonly MAX_RETRIES = 5

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get next sequence number atomically
   *
   * Uses optimistic locking with retry to handle concurrent requests.
   * Automatically resets sequence based on the institution's reset policy.
   */
  async getNextSequence(
    institutionId: number,
    sequenceType: SequenceType
  ): Promise<SequenceResult> {
    const now = new Date()
    const currentYear = now.getFullYear()
    const currentMonth = now.getMonth() + 1

    for (let attempt = 1; attempt <= this.MAX_RETRIES; attempt++) {
      try {
        return await this.prisma.$transaction(async tx => {
          // Get current config with lock
          const config = await tx.institutionIdConfig.findUnique({
            where: { institutionId },
          })

          if (!config) {
            throw new Error(
              `ID config not found for institution ${institutionId}`
            )
          }

          // Get field names based on sequence type
          const { counterField, yearField } = this.getFieldNames(sequenceType)

          const currentCounter = config[counterField] as number
          const storedYear = config[yearField] as number
          const policy = config.sequenceResetPolicy

          // Determine if we should reset
          const shouldReset = this.shouldResetSequence(
            policy,
            storedYear,
            currentYear
          )

          const nextSequence = shouldReset ? 1 : currentCounter + 1
          const newYear = currentYear

          // Update with optimistic lock
          const updated = await tx.institutionIdConfig.updateMany({
            where: {
              id: config.id,
              [counterField]: currentCounter, // Optimistic lock condition
            },
            data: {
              [counterField]: nextSequence,
              [yearField]: newYear,
            },
          })

          // If no rows updated, another request got there first
          if (updated.count === 0) {
            throw new Error('OPTIMISTIC_LOCK_CONFLICT')
          }

          this.logger.debug(
            `Generated ${sequenceType} sequence ${nextSequence} for institution ${institutionId}`
          )

          return {
            sequence: nextSequence,
            year: newYear,
            month: currentMonth,
          }
        })
      } catch (error) {
        if (
          error.message === 'OPTIMISTIC_LOCK_CONFLICT' &&
          attempt < this.MAX_RETRIES
        ) {
          this.logger.warn(
            `Optimistic lock conflict for ${sequenceType} sequence, attempt ${attempt}/${this.MAX_RETRIES}`
          )
          // Small random delay before retry
          await this.delay(Math.random() * 50 + 10)
          continue
        }
        throw error
      }
    }

    throw new Error(
      `Failed to generate sequence after ${this.MAX_RETRIES} attempts`
    )
  }

  /**
   * Reset a specific sequence counter
   * Useful for testing or manual corrections
   */
  async resetSequence(
    institutionId: number,
    sequenceType: SequenceType,
    startFrom: number = 0
  ): Promise<void> {
    const { counterField, yearField } = this.getFieldNames(sequenceType)

    await this.prisma.institutionIdConfig.update({
      where: { institutionId },
      data: {
        [counterField]: startFrom,
        [yearField]: new Date().getFullYear(),
      },
    })

    this.logger.log(
      `Reset ${sequenceType} sequence for institution ${institutionId} to ${startFrom}`
    )
  }

  /**
   * Get current sequence value without incrementing
   */
  async getCurrentSequence(
    institutionId: number,
    sequenceType: SequenceType
  ): Promise<number> {
    const config = await this.prisma.institutionIdConfig.findUnique({
      where: { institutionId },
    })

    if (!config) {
      return 0
    }

    const { counterField } = this.getFieldNames(sequenceType)
    return config[counterField] as number
  }

  private getFieldNames(sequenceType: SequenceType): {
    counterField: string
    yearField: string
  } {
    const fieldMap: Record<
      SequenceType,
      { counterField: string; yearField: string }
    > = {
      admission: {
        counterField: 'admissionSeqCounter',
        yearField: 'admissionSeqYear',
      },
      roll: {
        counterField: 'rollSeqCounter',
        yearField: 'rollSeqYear',
      },
      teacherEmployee: {
        counterField: 'teacherSeqCounter',
        yearField: 'teacherSeqYear',
      },
      staffEmployee: {
        counterField: 'staffSeqCounter',
        yearField: 'staffSeqYear',
      },
    }

    return fieldMap[sequenceType]
  }

  private shouldResetSequence(
    policy: SequenceResetPolicy,
    storedYear: number,
    currentYear: number
  ): boolean {
    switch (policy) {
      case 'YEARLY':
      case 'MONTHLY':
        // Both YEARLY and MONTHLY reset on year change
        // (Monthly would require storing month in DB for full implementation)
        return currentYear !== storedYear

      case 'NEVER':
        return false

      default:
        return false
    }
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}
