import { Injectable, Logger } from '@nestjs/common'
import { InstitutionIdConfig } from '@prisma/client'
import { PrismaService } from '../prisma/prisma.service'
import { DEFAULT_TEMPLATES } from '../utils/id-template.util'

interface CacheEntry {
  config: InstitutionIdConfig
  cachedAt: number
}

/**
 * Caching service for Institution ID Configurations
 *
 * Reduces database lookups by caching configs in memory.
 * Cache entries expire after TTL and are refreshed on next access.
 */
@Injectable()
export class IdConfigCacheService {
  private readonly logger = new Logger(IdConfigCacheService.name)
  private cache = new Map<number, CacheEntry>()

  // Cache TTL in milliseconds (5 minutes)
  private readonly TTL_MS = 5 * 60 * 1000

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get institution ID config from cache or database
   * Creates default config if none exists
   */
  async getConfig(institutionId: number): Promise<InstitutionIdConfig> {
    const cached = this.cache.get(institutionId)
    const now = Date.now()

    // Return cached if valid
    if (cached && now - cached.cachedAt < this.TTL_MS) {
      this.logger.debug(`Cache HIT for institution ${institutionId}`)
      return cached.config
    }

    this.logger.debug(`Cache MISS for institution ${institutionId}`)

    // Fetch from database
    let config = await this.prisma.institutionIdConfig.findUnique({
      where: { institutionId },
    })

    // Create default config if not exists
    if (!config) {
      this.logger.log(
        `Creating default ID config for institution ${institutionId}`
      )
      config = await this.prisma.institutionIdConfig.create({
        data: {
          institutionId,
          admissionNumberFormat: DEFAULT_TEMPLATES.admissionNumber,
          rollNumberFormat: DEFAULT_TEMPLATES.rollNumber,
          teacherEmployeeIdFormat: DEFAULT_TEMPLATES.teacherEmployeeId,
          staffEmployeeIdFormat: DEFAULT_TEMPLATES.staffEmployeeId,
        },
      })
    }

    // Update cache
    this.cache.set(institutionId, {
      config,
      cachedAt: now,
    })

    return config
  }

  /**
   * Invalidate cache entry for an institution
   * Call this when config is updated
   */
  invalidate(institutionId: number): void {
    this.logger.debug(`Invalidating cache for institution ${institutionId}`)
    this.cache.delete(institutionId)
  }

  /**
   * Invalidate all cache entries
   */
  invalidateAll(): void {
    this.logger.debug('Invalidating all cache entries')
    this.cache.clear()
  }

  /**
   * Get cache statistics
   */
  getStats(): {
    size: number
    entries: { institutionId: number; age: number }[]
  } {
    const now = Date.now()
    const entries: { institutionId: number; age: number }[] = []

    this.cache.forEach((entry, institutionId) => {
      entries.push({
        institutionId,
        age: Math.round((now - entry.cachedAt) / 1000), // Age in seconds
      })
    })

    return {
      size: this.cache.size,
      entries,
    }
  }
}
