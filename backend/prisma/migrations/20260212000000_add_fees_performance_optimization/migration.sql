-- ============================================================================
-- FEES MODULE PERFORMANCE OPTIMIZATION
-- Creates database views and indexes for improved query performance
-- ============================================================================

-- ============================================================================
-- 1. FEE COLLECTION SUMMARY VIEW
-- Pre-aggregated fee collection data per institution/course/semester
-- Used by: Admin dashboard, financial reports
-- ============================================================================
CREATE OR REPLACE VIEW fee_collection_summary AS
SELECT 
  i.id as institution_id,
  i.name as institution_name,
  sf.semester_id,
  fs.course_id,
  fs.fee_type,
  fs.academic_year_id,
  COUNT(DISTINCT sf.id) as total_fees_assigned,
  COUNT(DISTINCT sf.student_id) as total_students,
  SUM(sf.amount_due) as total_amount_due,
  SUM(sf.amount_paid) as total_amount_paid,
  SUM(sf.amount_due - sf.amount_paid) as total_pending,
  SUM(sf.late_fee_applied) as total_late_fees,
  SUM(sf.discount) as total_discounts,
  COUNT(*) FILTER (WHERE sf.status = 'PENDING') as pending_count,
  COUNT(*) FILTER (WHERE sf.status = 'PARTIAL') as partial_count,
  COUNT(*) FILTER (WHERE sf.status = 'PAID') as paid_count,
  COUNT(*) FILTER (WHERE sf.status = 'OVERDUE') as overdue_count,
  COUNT(*) FILTER (WHERE sf.status = 'WAIVED') as waived_count,
  ROUND(
    (COUNT(*) FILTER (WHERE sf.status = 'PAID')::DECIMAL / NULLIF(COUNT(*), 0)) * 100,
    2
  ) as collection_percentage,
  MIN(sf.due_date) as earliest_due_date,
  MAX(sf.due_date) as latest_due_date,
  CURRENT_TIMESTAMP as last_updated
FROM student_fees sf
JOIN fee_structures fs ON sf.fee_structure_id = fs.id
JOIN institutions i ON fs.institution_id = i.id
GROUP BY i.id, i.name, sf.semester_id, fs.course_id, fs.fee_type, fs.academic_year_id;

-- ============================================================================
-- 2. STUDENT FEE STATUS VIEW
-- Current fee status per student with payment details
-- Used by: Student dashboard, parent dashboard, fee reports
-- ============================================================================
CREATE OR REPLACE VIEW student_fee_status AS
SELECT 
  sf.id as student_fee_id,
  sf.student_id,
  s.roll_number,
  u.name as student_name,
  u.email as student_email,
  u.edverse_id,
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
  sf.id, sf.student_id, s.roll_number, u.name, u.email, u.edverse_id,
  sf.fee_structure_id, fs.fee_name, fs.fee_type, sf.semester_id, sem.semester_name,
  fs.course_id, c.name, fs.institution_id, i.name, sf.amount_due, 
  sf.amount_paid, sf.late_fee_applied, sf.discount, sf.status, sf.due_date,
  sf.created_at, sf.updated_at;

-- ============================================================================
-- 3. PAYMENT ANALYTICS VIEW
-- Payment analytics per institution with trends
-- Used by: Financial reports, payment analytics dashboard
-- ============================================================================
CREATE OR REPLACE VIEW payment_analytics AS
SELECT 
  i.id as institution_id,
  i.name as institution_name,
  DATE_TRUNC('month', p.payment_date) as payment_month,
  p.payment_method,
  p.payment_mode,
  p.status,
  COUNT(*) as transaction_count,
  SUM(p.amount) as total_amount,
  AVG(p.amount) as average_amount,
  MIN(p.amount) as min_amount,
  MAX(p.amount) as max_amount,
  COUNT(DISTINCT p.student_id) as unique_students,
  COUNT(DISTINCT DATE(p.payment_date)) as transaction_days
FROM payments p
JOIN students s ON p.student_id = s.id
JOIN institutions i ON s.institution_id = i.id
GROUP BY i.id, i.name, DATE_TRUNC('month', p.payment_date), p.payment_method, p.payment_mode, p.status;

-- ============================================================================
-- 4. OVERDUE FEES SUMMARY VIEW
-- Quick lookup for overdue fees requiring action
-- Used by: Fee reminder systems, collections reports
-- ============================================================================
CREATE OR REPLACE VIEW overdue_fees_summary AS
SELECT 
  sf.id as student_fee_id,
  sf.student_id,
  s.roll_number,
  u.name as student_name,
  u.email as student_email,
  u.phone as student_phone,
  u.edverse_id,
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
-- PERFORMANCE INDEXES FOR FEE TABLES
-- Optimize frequent queries on fee and payment tables
-- ============================================================================

-- Fee Structure table indexes
CREATE INDEX IF NOT EXISTS idx_fee_structures_institution ON fee_structures(institution_id);
CREATE INDEX IF NOT EXISTS idx_fee_structures_course ON fee_structures(course_id);
CREATE INDEX IF NOT EXISTS idx_fee_structures_academic_year ON fee_structures(academic_year_id);
CREATE INDEX IF NOT EXISTS idx_fee_structures_type_status ON fee_structures(fee_type, status);
CREATE INDEX IF NOT EXISTS idx_fee_structures_due_date ON fee_structures(due_date) WHERE due_date IS NOT NULL;

-- Student Fee table indexes
CREATE INDEX IF NOT EXISTS idx_student_fees_student ON student_fees(student_id);
CREATE INDEX IF NOT EXISTS idx_student_fees_structure ON student_fees(fee_structure_id);
CREATE INDEX IF NOT EXISTS idx_student_fees_semester ON student_fees(semester_id) WHERE semester_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_student_fees_status ON student_fees(status);
CREATE INDEX IF NOT EXISTS idx_student_fees_due_date ON student_fees(due_date);
CREATE INDEX IF NOT EXISTS idx_student_fees_student_status ON student_fees(student_id, status);
CREATE INDEX IF NOT EXISTS idx_student_fees_overdue ON student_fees(status, due_date) WHERE status IN ('OVERDUE', 'PENDING', 'PARTIAL');

-- Composite index for common fee queries
CREATE INDEX IF NOT EXISTS idx_student_fees_lookup ON student_fees(student_id, fee_structure_id, semester_id);

-- Payment table indexes
CREATE INDEX IF NOT EXISTS idx_payments_student ON payments(student_id);
CREATE INDEX IF NOT EXISTS idx_payments_student_fee ON payments(student_fee_id) WHERE student_fee_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_method ON payments(payment_method);
CREATE INDEX IF NOT EXISTS idx_payments_mode ON payments(payment_mode);
CREATE INDEX IF NOT EXISTS idx_payments_date ON payments(payment_date);
CREATE INDEX IF NOT EXISTS idx_payments_receipt ON payments(receipt_number) WHERE receipt_number IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_payments_transaction ON payments(transaction_id) WHERE transaction_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_payments_processed_by ON payments(processed_by) WHERE processed_by IS NOT NULL;

-- Composite index for payment queries
CREATE INDEX IF NOT EXISTS idx_payments_student_status_date ON payments(student_id, status, payment_date);

-- Index for date range queries
CREATE INDEX IF NOT EXISTS idx_payments_date_range ON payments(payment_date, status) WHERE status = 'COMPLETED';

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON VIEW fee_collection_summary IS 'Pre-aggregated fee collection data per institution/course/semester. Used for admin dashboards and financial reports.';
COMMENT ON VIEW student_fee_status IS 'Current fee status per student with payment details. Used for student/parent dashboards and fee reports.';
COMMENT ON VIEW payment_analytics IS 'Payment analytics per institution with trends. Used for financial reports and payment analytics dashboard.';
COMMENT ON VIEW overdue_fees_summary IS 'Quick lookup for overdue fees requiring action. Used for fee reminder systems and collections reports.';

-- Index comments
COMMENT ON INDEX idx_student_fees_overdue IS 'Optimizes queries for overdue fee reports and late fee calculations';
COMMENT ON INDEX idx_payments_date_range IS 'Optimizes date range queries for payment reports and analytics';
COMMENT ON INDEX idx_student_fees_lookup IS 'Optimizes student fee lookup queries by student, structure, and semester';

