-- Performance optimization for ClassDivision queries
-- Following cursor rules for database optimization

-- Index for frequently queried fields
CREATE INDEX IF NOT EXISTS "idx_class_divisions_course_id" ON "class_divisions" ("course_id");
CREATE INDEX IF NOT EXISTS "idx_class_divisions_teacher_id" ON "class_divisions" ("teacher_id");
CREATE INDEX IF NOT EXISTS "idx_class_divisions_status" ON "class_divisions" ("status");

-- Composite index for common query patterns
CREATE INDEX IF NOT EXISTS "idx_class_divisions_course_status" ON "class_divisions" ("course_id", "status");

-- Index for student assignments
CREATE INDEX IF NOT EXISTS "idx_students_class_division_id" ON "students" ("class_division_id");

-- Composite index for student queries
CREATE INDEX IF NOT EXISTS "idx_students_division_status" ON "students" ("class_division_id", "status");

-- Performance view for class division statistics
CREATE OR REPLACE VIEW "class_division_stats" AS
SELECT 
    cd.id,
    cd.course_id,
    cd.section_name,
    cd.max_capacity,
    cd.room_number,
    cd.status,
    cd.teacher_id,
    c.name as course_name,
    c.code as course_code,
    t.user_id as teacher_user_id,
    u.name as teacher_name,
    u.email as teacher_email,
    COUNT(s.id) as current_enrollment,
    COUNT(CASE WHEN s.status = 'ACTIVE' THEN 1 END) as active_students,
    cd.created_at,
    cd.updated_at
FROM class_divisions cd
LEFT JOIN courses c ON cd.course_id = c.id
LEFT JOIN teachers t ON cd.teacher_id = t.id
LEFT JOIN users u ON t.user_id = u.id
LEFT JOIN students s ON cd.id = s.class_division_id
GROUP BY 
    cd.id, cd.course_id, cd.section_name, cd.max_capacity, 
    cd.room_number, cd.status, cd.teacher_id, c.name, c.code,
    t.user_id, u.name, u.email, cd.created_at, cd.updated_at;