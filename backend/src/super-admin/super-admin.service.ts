import { Injectable, Logger } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'
import {
  InstitutionOverviewQueryDto,
  RecentActivityQueryDto,
  UserGrowthQueryDto,
} from './dto/super-admin.dto'
import {
  InstitutionListResponse,
  InstitutionOverview,
  RecentActivity,
  SuperAdminDashboardResponse,
  SystemStats,
  UserGrowthTrend,
} from './interfaces/super-admin.interfaces'

@Injectable()
export class SuperAdminService {
  private readonly logger = new Logger(SuperAdminService.name)

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get comprehensive dashboard data for super admin
   * Performance target: < 200ms total
   */
  async getDashboardData(): Promise<SuperAdminDashboardResponse> {
    const startTime = Date.now()

    try {
      // Execute all queries in parallel for optimal performance
      const [stats, institutions, userGrowth, recentActivity] =
        await Promise.all([
          this.getSystemStats(),
          this.getInstitutionOverview({ limit: 5 }), // Top 5 institutions for dashboard
          this.getUserGrowthTrends({ months: 6 }), // Last 6 months for dashboard
          this.getRecentActivity({ limit: 10, days: 7 }), // Last 10 activities
        ])

      const executionTime = Date.now() - startTime
      this.logger.log(`Dashboard data retrieved in ${executionTime}ms`)

      return {
        stats,
        institutions,
        userGrowth,
        recentActivity,
      }
    } catch (error) {
      this.logger.error('Failed to get dashboard data', error)
      throw error
    }
  }

  /**
   * Get system-wide statistics using optimized database view
   * Performance target: < 50ms
   */
  async getSystemStats(): Promise<SystemStats> {
    const startTime = Date.now()

    try {
      const result = await this.prisma.$queryRaw<
        Array<Record<string, unknown>>
      >`
        SELECT * FROM super_admin_system_stats LIMIT 1
      `

      const executionTime = Date.now() - startTime
      this.logger.debug(`System stats retrieved in ${executionTime}ms`)

      if (!result[0]) {
        return this.getEmptySystemStats()
      }

      // Convert BigInt values to numbers for JSON serialization
      const rawStats = result[0]
      const stats: SystemStats = {
        totalInstitutions: Number(rawStats.totalInstitutions || 0),
        inactiveInstitutions: Number(rawStats.inactiveInstitutions || 0),
        totalStudents: Number(rawStats.totalStudents || 0),
        totalTeachers: Number(rawStats.totalTeachers || 0),
        totalAdmins: Number(rawStats.totalAdmins || 0),
        totalStaff: Number(rawStats.totalStaff || 0),
        totalParents: Number(rawStats.totalParents || 0),
        totalActiveUsers: Number(rawStats.totalActiveUsers || 0),
        pendingUsers: Number(rawStats.pendingUsers || 0),
        suspendedUsers: Number(rawStats.suspendedUsers || 0),
        lockedUsers: Number(rawStats.lockedUsers || 0),
        newUsers30d: Number(rawStats.newUsers30d || 0),
        newInstitutions30d: Number(rawStats.newInstitutions30d || 0),
        userHealthPercentage: Number(rawStats.userHealthPercentage || 0),
      }

      return stats
    } catch (error) {
      this.logger.error('Failed to get system stats', error)
      throw error
    }
  }

  /**
   * Get institution overview with pagination and filtering
   * Performance target: < 100ms
   */
  async getInstitutionOverview(
    query: InstitutionOverviewQueryDto = {}
  ): Promise<InstitutionListResponse> {
    const { status, type, limit = 20, offset = 0, search } = query
    const startTime = Date.now()

    try {
      // Build WHERE conditions
      const conditions: string[] = []
      const params: unknown[] = []
      let paramIndex = 1

      if (status) {
        conditions.push(`status = $${paramIndex}`)
        params.push(status)
        paramIndex++
      }

      if (type) {
        conditions.push(`type = $${paramIndex}`)
        params.push(type)
        paramIndex++
      }

      if (search) {
        conditions.push(
          `(name ILIKE $${paramIndex} OR code ILIKE $${paramIndex})`
        )
        params.push(`%${search}%`)
        paramIndex++
      }

      const whereClause =
        conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : ''

      // Get total count and data in parallel
      const [totalResult, rawData] = await Promise.all([
        this.prisma.$queryRawUnsafe<Array<{ count: bigint }>>(
          `SELECT COUNT(*) as count FROM super_admin_institution_overview ${whereClause}`,
          ...params
        ),
        this.prisma.$queryRawUnsafe<Array<Record<string, unknown>>>(
          `SELECT * FROM super_admin_institution_overview ${whereClause} 
           ORDER BY "createdAt" DESC 
           LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
          ...params,
          limit,
          offset
        ),
      ])

      // Convert BigInt values to numbers for JSON serialization
      const data: InstitutionOverview[] = rawData.map(item => ({
        id: Number(item.id),
        code: String(item.code),
        name: String(item.name),
        type: item.type as 'SCHOOL' | 'COLLEGE' | 'UNIVERSITY' | 'INSTITUTE',
        status: item.status as 'ACTIVE' | 'INACTIVE',
        createdAt: new Date(item.createdAt as string),
        adminName: item.adminName ? String(item.adminName) : null,
        adminEmail: item.adminEmail ? String(item.adminEmail) : null,
        adminStatus: item.adminStatus ? String(item.adminStatus) : null,
        totalUsers: Number(item.totalUsers || 0),
        activeUsers: Number(item.activeUsers || 0),
        students: Number(item.students || 0),
        teachers: Number(item.teachers || 0),
        staff: Number(item.staff || 0),
        parents: Number(item.parents || 0),
        healthPercentage: Number(item.healthPercentage || 0),
      }))

      const total = Number(totalResult[0]?.count || 0)
      const totalPages = Math.ceil(total / limit)
      const page = Math.floor(offset / limit) + 1

      const executionTime = Date.now() - startTime
      this.logger.debug(`Institution overview retrieved in ${executionTime}ms`)

      return {
        data,
        meta: {
          total,
          page,
          limit,
          totalPages,
        },
      }
    } catch (error) {
      this.logger.error('Failed to get institution overview', error)
      throw error
    }
  }

  /**
   * Get user growth trends using optimized database view
   * Performance target: < 75ms
   */
  async getUserGrowthTrends(
    query: UserGrowthQueryDto = {}
  ): Promise<UserGrowthTrend[]> {
    const { months = 12 } = query
    const startTime = Date.now()

    try {
      const rawResult = await this.prisma.$queryRaw<
        Array<Record<string, unknown>>
      >`
        SELECT 
          month,
          "newUsers",
          "activeNewUsers",
          "cumulativeUsers"
        FROM super_admin_user_growth 
        WHERE month >= NOW() - INTERVAL '${months} months'
        ORDER BY month DESC
        LIMIT ${months}
      `

      // Convert BigInt values to numbers for JSON serialization
      const result: UserGrowthTrend[] = rawResult.map(item => ({
        month: new Date(item.month as string),
        newUsers: Number(item.newUsers || 0),
        activeNewUsers: Number(item.activeNewUsers || 0),
        cumulativeUsers: Number(item.cumulativeUsers || 0),
      }))

      const executionTime = Date.now() - startTime
      this.logger.debug(`User growth trends retrieved in ${executionTime}ms`)

      return result
    } catch (error) {
      this.logger.error('Failed to get user growth trends', error)
      throw error
    }
  }

  /**
   * Get recent activity using optimized database view
   * Performance target: < 60ms
   */
  async getRecentActivity(
    query: RecentActivityQueryDto = {}
  ): Promise<RecentActivity[]> {
    const { limit = 20, days = 7 } = query
    const startTime = Date.now()

    try {
      const result = await this.prisma.$queryRaw<RecentActivity[]>`
        SELECT 
          "activityType",
          description,
          timestamp,
          "institutionId"
        FROM super_admin_recent_activity 
        WHERE timestamp >= NOW() - INTERVAL '${days} days'
        ORDER BY timestamp DESC
        LIMIT ${limit}
      `

      const executionTime = Date.now() - startTime
      this.logger.debug(`Recent activity retrieved in ${executionTime}ms`)

      return result
    } catch (error) {
      this.logger.error('Failed to get recent activity', error)
      throw error
    }
  }

  /**
   * Get detailed institution statistics by ID
   * Performance target: < 80ms
   */
  async getInstitutionDetails(
    institutionId: number
  ): Promise<InstitutionOverview | null> {
    const startTime = Date.now()

    try {
      const rawResult = await this.prisma.$queryRaw<
        Array<Record<string, unknown>>
      >`
        SELECT * FROM super_admin_institution_overview 
        WHERE id = ${institutionId}
        LIMIT 1
      `

      const executionTime = Date.now() - startTime
      this.logger.debug(`Institution details retrieved in ${executionTime}ms`)

      if (!rawResult[0]) {
        return null
      }

      // Convert BigInt values to numbers for JSON serialization
      const item = rawResult[0]
      const result: InstitutionOverview = {
        id: Number(item.id),
        code: String(item.code),
        name: String(item.name),
        type: item.type as 'SCHOOL' | 'COLLEGE' | 'UNIVERSITY' | 'INSTITUTE',
        status: item.status as 'ACTIVE' | 'INACTIVE',
        createdAt: new Date(item.createdAt as string),
        adminName: item.adminName ? String(item.adminName) : null,
        adminEmail: item.adminEmail ? String(item.adminEmail) : null,
        adminStatus: item.adminStatus ? String(item.adminStatus) : null,
        totalUsers: Number(item.totalUsers || 0),
        activeUsers: Number(item.activeUsers || 0),
        students: Number(item.students || 0),
        teachers: Number(item.teachers || 0),
        staff: Number(item.staff || 0),
        parents: Number(item.parents || 0),
        healthPercentage: Number(item.healthPercentage || 0),
      }

      return result
    } catch (error) {
      this.logger.error('Failed to get institution details', error)
      throw error
    }
  }

  /**
   * Get storage usage statistics (placeholder for future implementation)
   * Performance target: < 30ms
   */
  async getStorageStats(): Promise<{
    used: string
    total: string
    percentage: number
  }> {
    // TODO: Implement actual storage calculation
    // For now, return mock data that matches the current frontend
    return {
      used: '0 GB',
      total: '100 GB',
      percentage: 0,
    }
  }

  /**
   * Get active sessions count (placeholder for future implementation)
   * Performance target: < 20ms
   */
  async getActiveSessionsCount(): Promise<number> {
    // TODO: Implement actual session tracking
    // For now, return count of users logged in today
    try {
      const result = await this.prisma.$queryRaw<Array<{ count: bigint }>>`
        SELECT COUNT(*) as count 
        FROM users 
        WHERE last_login >= CURRENT_DATE 
        AND status = 'ACTIVE'
      `
      return Number(result[0]?.count || 0)
    } catch (error) {
      this.logger.error('Failed to get active sessions count', error)
      return 0
    }
  }

  /**
   * Helper method to return empty system stats
   */
  private getEmptySystemStats(): SystemStats {
    return {
      totalInstitutions: 0,
      inactiveInstitutions: 0,
      totalStudents: 0,
      totalTeachers: 0,
      totalAdmins: 0,
      totalStaff: 0,
      totalParents: 0,
      totalActiveUsers: 0,
      pendingUsers: 0,
      suspendedUsers: 0,
      lockedUsers: 0,
      newUsers30d: 0,
      newInstitutions30d: 0,
      userHealthPercentage: 0,
    }
  }
}
