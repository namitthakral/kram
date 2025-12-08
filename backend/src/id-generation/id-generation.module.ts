import { Global, Module } from '@nestjs/common'
import { PrismaModule } from '../prisma/prisma.module'
import { IdConfigCacheService } from './id-config-cache.service'
import { IdGenerationService } from './id-generation.service'
import { SequenceService } from './sequence.service'

/**
 * ID Generation Module
 *
 * Provides services for generating unique IDs (admission numbers, roll numbers, employee IDs)
 * based on configurable templates per institution.
 *
 * Services:
 * - IdGenerationService: Main service for ID generation
 * - IdConfigCacheService: Caching layer for institution configs
 * - SequenceService: Atomic sequence number generation
 *
 * The module is marked as @Global so it can be injected anywhere without importing.
 */
@Global()
@Module({
  imports: [PrismaModule],
  providers: [IdGenerationService, IdConfigCacheService, SequenceService],
  exports: [IdGenerationService, IdConfigCacheService, SequenceService],
})
export class IdGenerationModule {}
