/**
 * System-wide statistics interface
 * Maps to super_admin_system_stats database view
 */
export interface SystemStats {
  // Institution metrics
  totalInstitutions: number
  inactiveInstitutions: number

  // User metrics by role
  totalStudents: number
  totalTeachers: number
  totalAdmins: number
  totalStaff: number
  totalParents: number

  // User status metrics
  totalActiveUsers: number
  pendingUsers: number
  suspendedUsers: number
  lockedUsers: number

  // Recent activity (30 days)
  newUsers30d: number
  newInstitutions30d: number

  // System health
  userHealthPercentage: number
}

/**
 * Institution overview with user statistics
 * Maps to super_admin_institution_overview database view
 */
export interface InstitutionOverview {
  id: number
  code: string
  name: string
  type: 'SCHOOL' | 'COLLEGE' | 'UNIVERSITY' | 'INSTITUTE'
  status: 'ACTIVE' | 'INACTIVE'
  createdAt: Date

  // Admin information
  adminName: string | null
  adminEmail: string | null
  adminStatus: string | null

  // User counts
  totalUsers: number
  activeUsers: number
  students: number
  teachers: number
  staff: number
  parents: number

  // Health metrics
  healthPercentage: number
}

/**
 * User growth trend data
 * Maps to super_admin_user_growth database view
 */
export interface UserGrowthTrend {
  month: Date
  newUsers: number
  activeNewUsers: number
  cumulativeUsers: number
}

/**
 * Recent activity item
 * Maps to super_admin_recent_activity database view
 */
export interface RecentActivity {
  activityType: 'user_registration' | 'institution_creation'
  description: string
  timestamp: Date
  institutionId: number | null
}

/**
 * Super Admin dashboard response
 * Aggregated response for dashboard API
 */
export interface SuperAdminDashboardResponse {
  stats: SystemStats
  institutions: {
    data: InstitutionOverview[]
    meta: {
      total: number
      page: number
      limit: number
      totalPages: number
    }
  }
  userGrowth: UserGrowthTrend[]
  recentActivity: RecentActivity[]
}

/**
 * Institution list response with pagination
 */
export interface InstitutionListResponse {
  data: InstitutionOverview[]
  meta: {
    total: number
    page: number
    limit: number
    totalPages: number
  }
}
