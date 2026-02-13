-- ============================================================================
-- RENAME EDVERSE TO KRAM MIGRATION
-- 1. Creates PostgreSQL function for kramid generation
-- 2. Creates trigger for automatic kramid generation
-- 3. Renames edverse_id column to kramid
-- 4. Updates all views that reference edverse_id
-- ============================================================================

-- ============================================================================
-- 1. CREATE KRAMID GENERATION FUNCTION
-- ============================================================================
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
    
    -- Check if kramid already exists
    IF NOT EXISTS (SELECT 1 FROM users WHERE edverse_id = new_kramid) THEN
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
-- 2. CREATE AUTO-GENERATION TRIGGER FUNCTION
-- ============================================================================
CREATE OR REPLACE FUNCTION auto_generate_kramid()
RETURNS TRIGGER AS $$
DECLARE
  inst_code VARCHAR(4);
  role_name VARCHAR(50);
BEGIN
  -- Only generate if kramid is NULL
  IF NEW.edverse_id IS NULL THEN
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
    
    -- Generate kramid if we have both institution code and role
    IF inst_code IS NOT NULL AND role_name IS NOT NULL THEN
      NEW.edverse_id := generate_kramid(inst_code, role_name);
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER trigger_auto_kramid
  BEFORE INSERT OR UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION auto_generate_kramid();

-- ============================================================================
-- 3. DROP VIEWS BEFORE COLUMN RENAME
-- ============================================================================
-- Drop views that reference edverse_id before renaming the column
DROP VIEW IF EXISTS student_fee_status;
DROP VIEW IF EXISTS overdue_fees_summary;

-- ============================================================================
-- 4. RENAME COLUMN AND INDEX
-- ============================================================================
-- Rename the column from edverse_id to kramid
ALTER TABLE users RENAME COLUMN edverse_id TO kramid;

-- Rename the unique index
ALTER INDEX users_edverse_id_key RENAME TO users_kramid_key;

-- ============================================================================
-- 5. RECREATE VIEWS WITH NEW COLUMN NAME
-- ============================================================================

-- Update student_fee_status view
CREATE OR REPLACE VIEW student_fee_status AS
SELECT 
  sf.id as student_fee_id,
  sf.student_id,
  s.roll_number,
  u.name as student_name,
  u.email as student_email,
  u.kramid,
  sf.fee_structure_id,
  fs.fee_name,
  fs.fee_type,
  sf.semester_id,
  sem.semester_name,
  fs.course_id,
  c.name as course_name,
  fs.institution_id,
  i.name as institution_name,
  sf.amount_due,
  sf.amount_paid,
  (sf.amount_due - sf.amount_paid) as amount_pending,
  sf.late_fee_applied,
  sf.discount,
  sf.status,
  sf.due_date,
  CASE 
    WHEN sf.status = 'PAID' THEN 'On Time'
    WHEN sf.status = 'OVERDUE' THEN 'Overdue'
    WHEN sf.due_date < CURRENT_DATE AND sf.status NOT IN ('PAID', 'WAIVED') THEN 'Past Due'
    WHEN sf.due_date >= CURRENT_DATE THEN 'Upcoming'
    ELSE 'Other'
  END as payment_status_label,
  GREATEST(0, CURRENT_DATE - sf.due_date) as days_overdue,
  COUNT(p.id) FILTER (WHERE p.status = 'COMPLETED') as payment_count,
  MAX(p.payment_date) FILTER (WHERE p.status = 'COMPLETED') as last_payment_date,
  sf.created_at,
  sf.updated_at
FROM student_fees sf
JOIN students s ON sf.student_id = s.id
JOIN users u ON s.user_id = u.id
JOIN fee_structures fs ON sf.fee_structure_id = fs.id
JOIN institutions i ON fs.institution_id = i.id
LEFT JOIN semesters sem ON sf.semester_id = sem.id
LEFT JOIN courses c ON fs.course_id = c.id
LEFT JOIN payments p ON sf.id = p.student_fee_id
GROUP BY 
  sf.id, sf.student_id, s.roll_number, u.name, u.email, u.kramid,
  sf.fee_structure_id, fs.fee_name, fs.fee_type, sf.semester_id, sem.semester_name,
  fs.course_id, c.name, fs.institution_id, i.name, sf.amount_due, 
  sf.amount_paid, sf.late_fee_applied, sf.discount, sf.status, sf.due_date,
  sf.created_at, sf.updated_at;

-- Update overdue_fees_summary view
CREATE OR REPLACE VIEW overdue_fees_summary AS
SELECT 
  sf.id as student_fee_id,
  sf.student_id,
  s.roll_number,
  u.name as student_name,
  u.email as student_email,
  u.phone as student_phone,
  u.kramid,
  fs.institution_id,
  i.name as institution_name,
  fs.fee_name,
  fs.fee_type,
  sf.amount_due,
  sf.amount_paid,
  (sf.amount_due - sf.amount_paid + sf.late_fee_applied) as total_overdue_amount,
  sf.late_fee_applied,
  sf.due_date,
  (CURRENT_DATE - sf.due_date) as days_overdue,
  sf.status,
  sem.semester_name,
  c.name as course_name
FROM student_fees sf
JOIN students s ON sf.student_id = s.id
JOIN users u ON s.user_id = u.id
JOIN fee_structures fs ON sf.fee_structure_id = fs.id
JOIN institutions i ON fs.institution_id = i.id
LEFT JOIN semesters sem ON sf.semester_id = sem.id
LEFT JOIN courses c ON fs.course_id = c.id
WHERE sf.status IN ('OVERDUE', 'PARTIAL')
  AND sf.amount_paid < sf.amount_due
ORDER BY days_overdue DESC, total_overdue_amount DESC;

-- ============================================================================
-- COMMENTS
-- ============================================================================
COMMENT ON FUNCTION generate_kramid(VARCHAR, VARCHAR, INT) IS 'Generates unique kramid in format: {INST_CODE}-{ROLE_CODE}{YY}-{RAND4}';
COMMENT ON FUNCTION auto_generate_kramid() IS 'Trigger function that automatically generates kramid for new users';
COMMENT ON COLUMN users.kramid IS 'Unique Kram ID for user identification';
