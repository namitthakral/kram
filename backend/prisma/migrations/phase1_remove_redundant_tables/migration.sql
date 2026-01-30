-- Phase 1: Remove redundant analytics and library tables
-- These tables store computed/aggregated data that can be calculated on-the-fly
-- No backend services query these tables directly

-- Drop tables in correct order (respecting foreign key constraints)
DROP TABLE IF EXISTS "dashboard_stats" CASCADE;
DROP TABLE IF EXISTS "attendance_summary" CASCADE;
DROP TABLE IF EXISTS "performance_metrics" CASCADE;
DROP TABLE IF EXISTS "library_transactions" CASCADE;

