/**
 * System-wide statistics interface
 * Maps to super_admin_system_stats database view
 */
export interface SystemStats {
  // Institution metrics
  total_institutions: number
  inactive_institutions: number
  
  // User metrics by role
  total_students: number
  total_teachers: number
  total_admins: number
  total_staff: number
  total_parents: number
  
  // User status metrics
  total_active_users: number
  pending_users: number
  suspended_users: number
  locked_users: number
  
  // Recent activity (30 days)
  new_users_30d: number
  new_institutions_30d: number
  
  // System health
  user_health_percentage: number
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
  created_at: Date
  
  // User counts
  total_users: number
  active_users: number
  students: number
  teachers: number
  staff: number
  parents: number
  
  // Health metrics
  health_percentage: number
}

/**
 * User growth trend data
 * Maps to super_admin_user_growth database view
 */
export interface UserGrowthTrend {
  month: Date
  new_users: number
  active_new_users: number
  cumulative_users: number
}

/**
 * Recent activity item
 * Maps to super_admin_recent_activity database view
 */
export interface RecentActivity {
  activity_type: 'user_created' | 'institution_created'
  description: string
  institution_name: string | null
  role: string
  timestamp: Date
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