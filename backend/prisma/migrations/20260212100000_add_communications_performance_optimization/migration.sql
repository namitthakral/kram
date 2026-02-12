-- ============================================================================
-- COMMUNICATIONS MODULE PERFORMANCE OPTIMIZATION
-- Creates database views and indexes for improved query performance
-- ============================================================================

-- ============================================================================
-- 1. COMMUNICATION STATISTICS VIEW
-- Pre-aggregated read statistics per communication
-- Used by: Communication list, read statistics, dashboards
-- ============================================================================
CREATE OR REPLACE VIEW communication_statistics AS
SELECT 
  c.id as communication_id,
  c.institution_id,
  c.title,
  c.communication_type,
  c.priority,
  c."targetAudience",
  c.is_emergency,
  c.is_pinned,
  c.is_active,
  c.publish_date,
  c.expiry_date,
  c.created_by,
  c.created_at,
  COUNT(DISTINCT crr.id) as total_reads,
  COUNT(DISTINCT crr.user_id) as unique_readers,
  ROUND(
    (COUNT(DISTINCT crr.id)::DECIMAL / 
     NULLIF(
       (SELECT COUNT(DISTINCT u.id) 
        FROM users u 
        JOIN roles r ON u.role_id = r.id
        WHERE r.role_name = ANY(c."targetAudience")
        AND (EXISTS (SELECT 1 FROM students s WHERE s.user_id = u.id AND s.institution_id = c.institution_id)
          OR EXISTS (SELECT 1 FROM teachers t WHERE t.user_id = u.id AND t.institution_id = c.institution_id)
          OR EXISTS (SELECT 1 FROM parents p JOIN students s ON p.student_id = s.id WHERE p.user_id = u.id AND s.institution_id = c.institution_id)
          OR EXISTS (SELECT 1 FROM staff st WHERE st.user_id = u.id AND st.institution_id = c.institution_id))
       ), 0
     )) * 100, 2
  ) as read_percentage,
  MIN(crr.read_at) as first_read_at,
  MAX(crr.read_at) as last_read_at,
  CASE 
    WHEN c.expiry_date IS NOT NULL AND c.expiry_date < CURRENT_DATE THEN 'expired'
    WHEN c.is_active = false THEN 'inactive'
    WHEN c.is_emergency = true THEN 'emergency'
    WHEN c.is_pinned = true THEN 'pinned'
    ELSE 'active'
  END as status_label
FROM communications c
LEFT JOIN communication_read_receipts crr ON c.id = crr.communication_id
GROUP BY 
  c.id, c.institution_id, c.title, c.communication_type, c.priority,
  c."targetAudience", c.is_emergency, c.is_pinned, c.is_active,
  c.publish_date, c.expiry_date, c.created_by, c.created_at;

-- ============================================================================
-- 2. UNREAD COMMUNICATIONS VIEW
-- Quick lookup for unread communications per user/role
-- Used by: User dashboards, notification badges
-- ============================================================================
CREATE OR REPLACE VIEW unread_communications_summary AS
SELECT 
  c.id as communication_id,
  c.institution_id,
  c.title,
  c.communication_type,
  c.priority,
  c."targetAudience" as target_audience,
  c.is_emergency,
  c.is_pinned,
  c.publish_date,
  c.created_by,
  u.name as creator_name,
  -- Count of target users who haven't read
  (SELECT COUNT(DISTINCT usr.id)
   FROM users usr
   JOIN roles r ON usr.role_id = r.id
   WHERE r.role_name = ANY(c."targetAudience")
   AND usr.id NOT IN (
     SELECT user_id FROM communication_read_receipts 
     WHERE communication_id = c.id
   )
   AND (EXISTS (SELECT 1 FROM students s WHERE s.user_id = usr.id AND s.institution_id = c.institution_id)
     OR EXISTS (SELECT 1 FROM teachers t WHERE t.user_id = usr.id AND t.institution_id = c.institution_id)
     OR EXISTS (SELECT 1 FROM parents p JOIN students s ON p.student_id = s.id WHERE p.user_id = usr.id AND s.institution_id = c.institution_id)
     OR EXISTS (SELECT 1 FROM staff st WHERE st.user_id = usr.id AND st.institution_id = c.institution_id))
  ) as unread_count,
  CURRENT_TIMESTAMP - c.publish_date as time_since_published
FROM communications c
JOIN users u ON c.created_by = u.id
WHERE c.is_active = true
  AND (c.expiry_date IS NULL OR c.expiry_date >= CURRENT_DATE)
ORDER BY c.is_emergency DESC, c.is_pinned DESC, c.publish_date DESC;

-- ============================================================================
-- 3. COMMUNICATION ANALYTICS VIEW
-- Analytics per institution with read rates
-- Used by: Admin reports, communication effectiveness tracking
-- ============================================================================
CREATE OR REPLACE VIEW communication_analytics AS
SELECT 
  c.institution_id,
  i.name as institution_name,
  DATE_TRUNC('month', c.publish_date) as publish_month,
  c.communication_type,
  c.priority,
  COUNT(DISTINCT c.id) as total_communications,
  COUNT(DISTINCT c.id) FILTER (WHERE c.is_emergency = true) as emergency_count,
  COUNT(DISTINCT c.id) FILTER (WHERE c.is_pinned = true) as pinned_count,
  COUNT(DISTINCT crr.id) as total_reads,
  COUNT(DISTINCT crr.user_id) as unique_readers,
  ROUND(AVG(
    (SELECT COUNT(*) FROM communication_read_receipts WHERE communication_id = c.id)
  ), 2) as avg_reads_per_communication,
  ROUND(
    (COUNT(DISTINCT crr.id)::DECIMAL / 
     NULLIF(COUNT(DISTINCT c.id), 0)) * 100, 2
  ) as engagement_rate
FROM communications c
JOIN institutions i ON c.institution_id = i.id
LEFT JOIN communication_read_receipts crr ON c.id = crr.communication_id
WHERE c.is_active = true
GROUP BY 
  c.institution_id, i.name, DATE_TRUNC('month', c.publish_date),
  c.communication_type, c.priority
ORDER BY publish_month DESC, institution_id;

-- ============================================================================
-- PERFORMANCE INDEXES FOR COMMUNICATIONS TABLES
-- Optimize frequent queries on communications and read receipts
-- ============================================================================

-- Communications table indexes
CREATE INDEX IF NOT EXISTS idx_communications_institution ON communications(institution_id);
CREATE INDEX IF NOT EXISTS idx_communications_type ON communications(communication_type);
CREATE INDEX IF NOT EXISTS idx_communications_priority ON communications(priority);
CREATE INDEX IF NOT EXISTS idx_communications_creator ON communications(created_by);
CREATE INDEX IF NOT EXISTS idx_communications_publish_date ON communications(publish_date);
CREATE INDEX IF NOT EXISTS idx_communications_expiry_date ON communications(expiry_date) WHERE expiry_date IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_communications_status ON communications(is_active, is_emergency, is_pinned);

-- Composite index for active communications queries
CREATE INDEX IF NOT EXISTS idx_communications_active_lookup 
ON communications(institution_id, is_active, publish_date DESC) 
WHERE is_active = true;

-- Composite index for unread queries
CREATE INDEX IF NOT EXISTS idx_communications_unread_lookup 
ON communications(institution_id, is_active, expiry_date) 
WHERE is_active = true;

-- Index for target audience array queries
CREATE INDEX IF NOT EXISTS idx_communications_target_audience 
ON communications USING GIN ("targetAudience");

-- Index for search queries
CREATE INDEX IF NOT EXISTS idx_communications_title_search 
ON communications USING gin(to_tsvector('english', title));

CREATE INDEX IF NOT EXISTS idx_communications_content_search 
ON communications USING gin(to_tsvector('english', content));

-- Communication Read Receipts indexes
CREATE INDEX IF NOT EXISTS idx_read_receipts_communication ON communication_read_receipts(communication_id);
CREATE INDEX IF NOT EXISTS idx_read_receipts_user ON communication_read_receipts(user_id);
CREATE INDEX IF NOT EXISTS idx_read_receipts_read_at ON communication_read_receipts(read_at);

-- Composite index for read receipt lookups
CREATE INDEX IF NOT EXISTS idx_read_receipts_lookup 
ON communication_read_receipts(communication_id, user_id);

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON VIEW communication_statistics IS 'Pre-aggregated read statistics per communication. Used for communication lists and dashboards with read counts.';
COMMENT ON VIEW unread_communications_summary IS 'Quick lookup for unread communications per user/role. Used for user dashboards and notification badges.';
COMMENT ON VIEW communication_analytics IS 'Analytics per institution with read rates and engagement metrics. Used for admin reports.';

-- Index comments
COMMENT ON INDEX idx_communications_active_lookup IS 'Optimizes queries for active communications list with date sorting';
COMMENT ON INDEX idx_communications_unread_lookup IS 'Optimizes unread communications queries filtering by active and non-expired';
COMMENT ON INDEX idx_communications_target_audience IS 'GIN index for array containment queries on target_audience';
COMMENT ON INDEX idx_communications_title_search IS 'Full-text search index on title field';
COMMENT ON INDEX idx_communications_content_search IS 'Full-text search index on content field';
