-- ============================================================================
-- FIX KRAMID TRIGGER AFTER RENAME
-- The rename_edverse_to_kram migration renamed edverse_id to kramid but left
-- the trigger function referencing NEW.edverse_id, which no longer exists.
-- This causes "column does not exist" when inserting users.
-- ============================================================================

-- Drop trigger and functions so we can recreate them with kramid
DROP TRIGGER IF EXISTS trigger_auto_kramid ON users;
DROP FUNCTION IF EXISTS auto_generate_kramid();
DROP FUNCTION IF EXISTS generate_kramid(VARCHAR, VARCHAR, INT);

-- Recreate generate_kramid using kramid column
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
  role_code := CASE LOWER(role_name)
    WHEN 'super_admin' THEN 'SA'
    WHEN 'admin' THEN 'AD'
    WHEN 'teacher' THEN 'T'
    WHEN 'student' THEN 'S'
    WHEN 'parent' THEN 'P'
    WHEN 'staff' THEN 'SF'
    ELSE 'U'
  END;

  year_short := SUBSTRING(COALESCE(year, EXTRACT(YEAR FROM NOW())::INT)::TEXT, 3, 2);

  LOOP
    random_code := '';
    FOR i IN 1..4 LOOP
      random_code := random_code || SUBSTRING(chars FROM (floor(random() * chars_length)::int + 1) FOR 1);
    END LOOP;

    new_kramid := UPPER(institution_code) || '-' || role_code || year_short || '-' || random_code;

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

-- Recreate trigger function using NEW.kramid (column exists after rename)
CREATE OR REPLACE FUNCTION auto_generate_kramid()
RETURNS TRIGGER AS $$
DECLARE
  inst_code VARCHAR(4);
  role_name VARCHAR(50);
BEGIN
  IF NEW.kramid IS NULL THEN
    SELECT i.code INTO inst_code
    FROM institutions i
    INNER JOIN students s ON s.institution_id = i.id
    WHERE s.user_id = NEW.id
    LIMIT 1;

    IF inst_code IS NULL THEN
      SELECT i.code INTO inst_code
      FROM institutions i
      INNER JOIN teachers t ON t.institution_id = i.id
      WHERE t.user_id = NEW.id
      LIMIT 1;
    END IF;

    IF inst_code IS NULL THEN
      SELECT i.code INTO inst_code
      FROM institutions i
      INNER JOIN staff st ON st.institution_id = i.id
      WHERE st.user_id = NEW.id
      LIMIT 1;
    END IF;

    SELECT r.role_name INTO role_name
    FROM roles r
    WHERE r.id = NEW.role_id;

    IF inst_code IS NOT NULL AND role_name IS NOT NULL THEN
      NEW.kramid := generate_kramid(inst_code, role_name);
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_kramid
  BEFORE INSERT OR UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION auto_generate_kramid();

COMMENT ON FUNCTION generate_kramid(VARCHAR, VARCHAR, INT) IS 'Generates unique kramid in format: {INST_CODE}-{ROLE_CODE}{YY}-{RAND4}';
COMMENT ON FUNCTION auto_generate_kramid() IS 'Trigger function that automatically generates kramid for new users';
