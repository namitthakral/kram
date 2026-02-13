-- ============================================================================
-- PRODUCTION DATABASE FIX: KRAMID TRIGGER FUNCTIONS
-- ============================================================================
-- This script fixes the database trigger functions that still reference the
-- old 'edverse_id' column name instead of the new 'kramid' column.
--
-- SAFE TO RUN: This script only updates function definitions, it does NOT
-- modify any data or table structures.
--
-- WHAT IT FIXES:
-- 1. generate_kramid() function - collision check uses wrong column
-- 2. auto_generate_kramid() trigger - references wrong column in NEW record
--
-- HOW TO RUN ON PRODUCTION:
-- psql $DATABASE_URL < scripts/fix-production-kramid-triggers.sql
--
-- OR if using AWS RDS:
-- psql -h your-rds-endpoint.amazonaws.com -U postgres -d kram < scripts/fix-production-kramid-triggers.sql
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. FIX generate_kramid() FUNCTION
-- ============================================================================
-- Issue: Function checks "WHERE edverse_id = new_kramid" but column is now "kramid"
-- Fix: Update to check "WHERE kramid = new_kramid"

CREATE OR REPLACE FUNCTION generate_kramid(
  institution_code VARCHAR(4),
  role_name VARCHAR(50),
  year INT DEFAULT NULL
) RETURNS VARCHAR(20) AS $$
DECLARE
  role_code VARCHAR(2);
  year_short VARCHAR(2);
  random_code VARCHAR(4);
  new_kramid VARCHAR(20);
  attempts INT := 0;
  max_attempts INT := 10;
  chars TEXT := '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  chars_length INT := 32;
BEGIN
  -- Map role names to codes
  role_code := CASE LOWER(role_name)
    WHEN 'super_admin' THEN 'SA'
    WHEN 'admin' THEN 'AD'
    WHEN 'teacher' THEN 'T'
    WHEN 'student' THEN 'S'
    WHEN 'parent' THEN 'P'
    WHEN 'staff' THEN 'SF'
    ELSE 'U'
  END;
  
  -- Get year (last 2 digits)
  year_short := SUBSTRING(COALESCE(year, EXTRACT(YEAR FROM NOW())::INT)::TEXT, 3, 2);
  
  -- Generate unique kramid with collision handling
  LOOP
    -- Generate random 4-char code (excluding 0,O,1,I)
    random_code := '';
    FOR i IN 1..4 LOOP
      random_code := random_code || SUBSTRING(chars FROM (floor(random() * chars_length)::int + 1) FOR 1);
    END LOOP;
    
    new_kramid := UPPER(institution_code) || '-' || role_code || year_short || '-' || random_code;
    
    -- ✅ FIXED: Check if kramid already exists (was: edverse_id, now: kramid)
    IF NOT EXISTS (SELECT 1 FROM users WHERE kramid = new_kramid) THEN
      RETURN new_kramid;
    END IF;
    
    attempts := attempts + 1;
    IF attempts >= max_attempts THEN
      RAISE EXCEPTION 'Failed to generate unique kramid after % attempts', max_attempts;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql VOLATILE;

-- ============================================================================
-- 2. FIX auto_generate_kramid() TRIGGER FUNCTION
-- ============================================================================
-- Issue: References NEW.edverse_id but column is now NEW.kramid
-- Fix: Update all references to use kramid

DROP TRIGGER IF EXISTS trigger_auto_kramid ON users;
DROP FUNCTION IF EXISTS auto_generate_kramid();

CREATE OR REPLACE FUNCTION auto_generate_kramid()
RETURNS TRIGGER AS $$
DECLARE
  inst_code VARCHAR(4);
  role_name VARCHAR(50);
BEGIN
  -- ✅ FIXED: Only generate if kramid is NULL (was: edverse_id, now: kramid)
  IF NEW.kramid IS NULL THEN
    -- Get institution code based on user type
    -- Try to get from student
    SELECT i.code INTO inst_code
    FROM institutions i
    INNER JOIN students s ON s.institution_id = i.id
    WHERE s.user_id = NEW.id
    LIMIT 1;
    
    -- If not found, try teacher
    IF inst_code IS NULL THEN
      SELECT i.code INTO inst_code
      FROM institutions i
      INNER JOIN teachers t ON t.institution_id = i.id
      WHERE t.user_id = NEW.id
      LIMIT 1;
    END IF;
    
    -- If not found, try staff
    IF inst_code IS NULL THEN
      SELECT i.code INTO inst_code
      FROM institutions i
      INNER JOIN staff st ON st.institution_id = i.id
      WHERE st.user_id = NEW.id
      LIMIT 1;
    END IF;
    
    -- Get role name
    SELECT r.role_name INTO role_name
    FROM roles r
    WHERE r.id = NEW.role_id;
    
    -- ✅ FIXED: Generate kramid if we have both (was: edverse_id, now: kramid)
    IF inst_code IS NOT NULL AND role_name IS NOT NULL THEN
      NEW.kramid := generate_kramid(inst_code, role_name);
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger
CREATE TRIGGER trigger_auto_kramid
  BEFORE INSERT OR UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION auto_generate_kramid();

-- ============================================================================
-- 3. UPDATE COMMENTS
-- ============================================================================
COMMENT ON FUNCTION generate_kramid(VARCHAR, VARCHAR, INT) IS 'Generates unique kramid in format: {INST_CODE}-{ROLE_CODE}{YY}-{RAND4}';
COMMENT ON FUNCTION auto_generate_kramid() IS 'Trigger function that automatically generates kramid for new users';
COMMENT ON COLUMN users.kramid IS 'Unique Kram ID for user identification';

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES (Optional - Run After Script)
-- ============================================================================
-- 1. Verify generate_kramid function uses 'kramid':
--    SELECT prosrc FROM pg_proc WHERE proname = 'generate_kramid';
--    (Should NOT contain 'edverse_id')
--
-- 2. Verify auto_generate_kramid function uses 'kramid':
--    SELECT prosrc FROM pg_proc WHERE proname = 'auto_generate_kramid';
--    (Should NOT contain 'edverse_id')
--
-- 3. Test the functions still work:
--    SELECT generate_kramid('KRAM', 'student', 2026);
--    (Should return something like: KRAM-S26-A3B7)
-- ============================================================================

-- ✅ SCRIPT COMPLETED
-- The database trigger functions have been updated to use 'kramid' instead of 'edverse_id'.
-- No data was modified, only function definitions were updated.
