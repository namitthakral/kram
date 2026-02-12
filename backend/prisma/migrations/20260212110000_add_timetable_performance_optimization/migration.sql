-- ============================================================================
-- TIMETABLE MODULE PERFORMANCE OPTIMIZATION
-- Creates indexes for improved query performance
-- ============================================================================

-- ============================================================================
-- PERFORMANCE INDEXES FOR TIMETABLE TABLES
-- Optimize frequent queries on timetables, time slots, and rooms
-- ============================================================================

-- Time Slots indexes
CREATE INDEX IF NOT EXISTS idx_time_slots_institution ON time_slots(institution_id);
CREATE INDEX IF NOT EXISTS idx_time_slots_sort ON time_slots(sort_order);
CREATE INDEX IF NOT EXISTS idx_time_slots_active ON time_slots(is_active) WHERE is_active = true;

-- Composite index for time slot lookups
CREATE INDEX IF NOT EXISTS idx_time_slots_lookup 
ON time_slots(institution_id, is_active) 
WHERE is_active = true;

-- Rooms indexes
CREATE INDEX IF NOT EXISTS idx_rooms_institution ON rooms(institution_id);
CREATE INDEX IF NOT EXISTS idx_rooms_type ON rooms(room_type);
CREATE INDEX IF NOT EXISTS idx_rooms_active ON rooms(is_active);
CREATE INDEX IF NOT EXISTS idx_rooms_building ON rooms(building) WHERE building IS NOT NULL;

-- Composite index for room searches
CREATE INDEX IF NOT EXISTS idx_rooms_lookup 
ON rooms(institution_id, is_active, room_type) 
WHERE is_active = true;

-- Timetable entries indexes
CREATE INDEX IF NOT EXISTS idx_timetable_institution ON timetables(institution_id);
CREATE INDEX IF NOT EXISTS idx_timetable_academic_year ON timetables(academic_year_id);
CREATE INDEX IF NOT EXISTS idx_timetable_semester ON timetables(semester_id);
CREATE INDEX IF NOT EXISTS idx_timetable_course ON timetables(course_id) WHERE course_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_timetable_class ON timetables(class_id) WHERE class_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_timetable_section ON timetables(section) WHERE section IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_timetable_teacher ON timetables(teacher_id);
CREATE INDEX IF NOT EXISTS idx_timetable_subject ON timetables(subject_id);
CREATE INDEX IF NOT EXISTS idx_timetable_time_slot ON timetables(time_slot_id);
CREATE INDEX IF NOT EXISTS idx_timetable_room ON timetables(room_id) WHERE room_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_timetable_day ON timetables(day_of_week);

-- Composite indexes for common timetable queries
-- Student timetable lookup (by course)
CREATE INDEX IF NOT EXISTS idx_timetable_student_course_lookup 
ON timetables(course_id, section, semester_id, day_of_week)
WHERE course_id IS NOT NULL;

-- Student timetable lookup (by class)
CREATE INDEX IF NOT EXISTS idx_timetable_student_class_lookup 
ON timetables(class_id, section, semester_id, day_of_week)
WHERE class_id IS NOT NULL;

-- Teacher timetable lookup  
CREATE INDEX IF NOT EXISTS idx_timetable_teacher_lookup 
ON timetables(teacher_id, semester_id, day_of_week);

-- Room schedule lookup
CREATE INDEX IF NOT EXISTS idx_timetable_room_lookup 
ON timetables(room_id, day_of_week, time_slot_id) 
WHERE room_id IS NOT NULL;

-- Subject schedule lookup
CREATE INDEX IF NOT EXISTS idx_timetable_subject_lookup 
ON timetables(subject_id, semester_id, day_of_week);

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON INDEX idx_time_slots_lookup IS 'Optimizes time slot queries by institution with active filter';
COMMENT ON INDEX idx_rooms_lookup IS 'Optimizes room availability queries with type and active status filters';
COMMENT ON INDEX idx_timetable_student_course_lookup IS 'Optimizes student timetable queries by course, section, and day';
COMMENT ON INDEX idx_timetable_student_class_lookup IS 'Optimizes student timetable queries by class ID, section, and day';
COMMENT ON INDEX idx_timetable_teacher_lookup IS 'Optimizes teacher schedule queries by teacher and day';
COMMENT ON INDEX idx_timetable_room_lookup IS 'Optimizes room schedule and conflict detection queries';
COMMENT ON INDEX idx_timetable_subject_lookup IS 'Optimizes subject schedule queries';
