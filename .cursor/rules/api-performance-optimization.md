# API Performance Optimization Rules

**MANDATORY RULE**: All APIs must be performance-optimized following these standards.

---

## 🎯 Core Principles

1. **Query Optimization First** - Optimize at the database level before application level
2. **Selective Loading** - Only fetch data you need
3. **Index Everything** - Add indexes for all frequently queried fields
4. **Use Database Views** - Pre-aggregate complex data
5. **Monitor Performance** - Track query execution times

---

## 📋 Checklist for Every API

When creating or modifying any API endpoint, ensure:

- [ ] Database indexes exist for all WHERE/JOIN clauses
- [ ] Selective field loading (use `select`, avoid `include: true`)
- [ ] Database views for complex aggregations
- [ ] Pagination for list endpoints (page, limit)
- [ ] Query execution time < 500ms (aim for < 100ms)
- [ ] No N+1 query problems
- [ ] Proper use of composite indexes
- [ ] Documentation of performance characteristics

---

## 1️⃣ Database Indexes

### Rule: Index All Frequently Queried Fields

**Always create indexes for:**
- Primary keys (automatic)
- Foreign keys
- Fields used in WHERE clauses
- Fields used in ORDER BY
- Fields used in JOIN conditions
- Composite indexes for multi-column queries

### Example:
```sql
-- Single column indexes
CREATE INDEX IF NOT EXISTS idx_students_institution ON students(institution_id);
CREATE INDEX IF NOT EXISTS idx_students_status ON students(status);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_students_institution_status ON students(institution_id, status);

-- Partial indexes for specific conditions
CREATE INDEX IF NOT EXISTS idx_fees_overdue ON student_fees(status, due_date) 
WHERE status IN ('OVERDUE', 'PENDING');
```

### Migration File Structure:
```
backend/prisma/migrations/
└── YYYYMMDDHHMMSS_add_[module]_performance_optimization/
    └── migration.sql
```

---

## 2️⃣ Selective Field Loading

### Rule: Never Use `include: true` or Fetch Unnecessary Fields

**❌ BAD:**
```typescript
const students = await prisma.student.findMany({
  include: {
    user: true,              // Loads ALL user fields
    enrollments: true,       // Loads ALL enrollment data
    attendance: true,        // Loads ALL attendance records
  },
});
```

**✅ GOOD:**
```typescript
const students = await prisma.student.findMany({
  select: {
    id: true,
    rollNumber: true,
    user: {
      select: {
        id: true,
        name: true,
        email: true,
        // Only required fields
      },
    },
    _count: {
      select: {
        enrollments: true,   // Just the count
      },
    },
  },
});
```

### Benefits:
- ⚡ 40-60% reduction in data transfer
- ⚡ Faster JSON serialization
- ⚡ Lower memory usage
- ⚡ Reduced database load

---

## 3️⃣ Database Views for Aggregations

### Rule: Create Views for Complex/Repeated Aggregations

**When to create a view:**
- Query joins 3+ tables
- Complex calculations (sums, averages, percentages)
- Data accessed frequently (dashboards, reports)
- Query takes > 200ms without optimization

### Example Pattern:

**Migration SQL:**
```sql
-- Create optimized view
CREATE OR REPLACE VIEW student_performance_summary AS
SELECT 
  s.id as student_id,
  s.roll_number,
  u.name as student_name,
  COUNT(DISTINCT e.subject_id) as total_subjects,
  ROUND(AVG(ar.grade_points), 2) as gpa,
  COUNT(DISTINCT a.date) as total_attendance,
  ROUND(
    (COUNT(*) FILTER (WHERE a.status = 'PRESENT')::DECIMAL / 
     NULLIF(COUNT(*), 0)) * 100, 2
  ) as attendance_percentage
FROM students s
JOIN users u ON s.user_id = u.id
LEFT JOIN enrollments e ON s.id = e.student_id
LEFT JOIN academic_records ar ON s.id = ar.student_id
LEFT JOIN attendance a ON s.id = a.student_id
GROUP BY s.id, s.roll_number, u.name;
```

**Service Method:**
```typescript
/**
 * Get student performance summary (OPTIMIZED)
 * Uses student_performance_summary view
 */
private async getStudentPerformanceFromView(studentId: number) {
  return this.prisma.$queryRaw`
    SELECT * FROM student_performance_summary
    WHERE student_id = ${studentId}
  `;
}
```

---

## 4️⃣ Pagination Standards

### Rule: All List Endpoints Must Support Pagination

**Required query parameters:**
- `page` (default: 1)
- `limit` (default: 10, max: 100)

**Implementation:**
```typescript
async findAll(query: QueryDto) {
  const { page = 1, limit = 10 } = query;
  const skip = (page - 1) * limit;

  const [total, data] = await Promise.all([
    this.prisma.model.count({ where }),
    this.prisma.model.findMany({
      where,
      skip,
      take: Math.min(limit, 100), // Cap at 100
      select: { /* selective fields */ },
    }),
  ]);

  return {
    data,
    meta: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    },
  };
}
```

---

## 5️⃣ Query Performance Standards

### Rule: Target < 100ms for Most Queries, < 500ms Maximum

**Performance Tiers:**
- ⚡ **Excellent**: < 50ms
- ✅ **Good**: 50-100ms
- ⚠️ **Acceptable**: 100-500ms
- ❌ **Needs Optimization**: > 500ms

### Monitoring:
```typescript
// Enable query logging in development
constructor() {
  if (process.env.NODE_ENV === 'development') {
    this.prisma.$on('query', (e: any) => {
      if (e.duration > 500) {
        console.warn(`⚠️ SLOW QUERY (${e.duration}ms):`, e.query);
      }
    });
  }
}
```

---

## 6️⃣ Avoid N+1 Query Problems

### Rule: Use `include` or Batch Queries, Never Loop Queries

**❌ BAD (N+1 Problem):**
```typescript
const students = await prisma.student.findMany();

// N+1: One query per student!
for (const student of students) {
  student.fees = await prisma.studentFee.findMany({
    where: { studentId: student.id }
  });
}
```

**✅ GOOD:**
```typescript
const students = await prisma.student.findMany({
  select: {
    id: true,
    name: true,
    fees: {
      select: {
        id: true,
        amount: true,
        status: true,
      },
    },
  },
});
```

**✅ ALSO GOOD (Batch Query):**
```typescript
const students = await prisma.student.findMany();
const studentIds = students.map(s => s.id);

const fees = await prisma.studentFee.findMany({
  where: { studentId: { in: studentIds } },
});

// Group fees by student in memory
const feesByStudent = fees.reduce((acc, fee) => {
  if (!acc[fee.studentId]) acc[fee.studentId] = [];
  acc[fee.studentId].push(fee);
  return acc;
}, {});
```

---

## 7️⃣ Composite Indexes for Multi-Column Queries

### Rule: Create Composite Indexes for Frequently Combined Filters

**Example:**
```sql
-- If you frequently query by studentId AND status
CREATE INDEX idx_student_fees_lookup 
ON student_fees(student_id, status);

-- If you frequently query by institutionId AND date range
CREATE INDEX idx_payments_institution_date 
ON payments(institution_id, payment_date);

-- Column order matters! Most selective column first
CREATE INDEX idx_attendance_lookup 
ON attendance(student_id, section_id, date);
```

**Index Column Order:**
1. Equality conditions first (WHERE x = y)
2. Range conditions second (WHERE x > y)
3. Sort columns last (ORDER BY x)

---

## 8️⃣ Partial Indexes for Specific Conditions

### Rule: Use Partial Indexes for Filtered Queries

**Example:**
```sql
-- Index only active records
CREATE INDEX idx_students_active 
ON students(institution_id, grade_level) 
WHERE status = 'ACTIVE';

-- Index only overdue fees
CREATE INDEX idx_fees_overdue 
ON student_fees(student_id, due_date) 
WHERE status IN ('OVERDUE', 'PENDING');

-- Index only completed payments
CREATE INDEX idx_payments_completed 
ON payments(payment_date, amount) 
WHERE status = 'COMPLETED';
```

**Benefits:**
- Smaller index size
- Faster updates
- More efficient for specific queries

---

## 9️⃣ Caching Strategy

### Rule: Cache Rarely-Changing Data

**Good candidates for caching:**
- Fee structures (change rarely)
- Academic years (change annually)
- Institution details
- Course information
- System configurations

**Implementation:**
```typescript
// Service-level caching
private feeStructureCache = new Map<number, any>();
private cacheExpiry = 5 * 60 * 1000; // 5 minutes

async getFeeStructure(id: number) {
  const cached = this.feeStructureCache.get(id);
  
  if (cached && Date.now() - cached.timestamp < this.cacheExpiry) {
    return cached.data;
  }

  const data = await this.prisma.feeStructure.findUnique({
    where: { id },
  });

  this.feeStructureCache.set(id, {
    data,
    timestamp: Date.now(),
  });

  return data;
}
```

---

## 🔟 Service Method Naming Convention

### Rule: Indicate Optimization in Method Names

**Pattern:**
```typescript
// Standard query
async getStudentFees(studentId: number) { }

// Optimized with view
async getStudentFeesFromView(studentId: number) { }

// Cached result
async getStudentFeesCached(studentId: number) { }

// Aggregated data
async getStudentFeeSummary(studentId: number) { } // Uses view
```

**Documentation:**
```typescript
/**
 * Get student fee summary (OPTIMIZED)
 * Uses student_fee_status view for better performance
 * Performance: ~45ms (vs 850ms without optimization)
 * 
 * @param studentId - Student ID
 * @param semesterId - Optional semester filter
 * @returns Fee summary with status breakdown
 */
async getStudentFeeSummary(studentId: number, semesterId?: number) {
  // Implementation using optimized view
}
```

---

## 📊 Performance Testing Checklist

Before deploying any API:

- [ ] Test with realistic data volume (1000+ records)
- [ ] Verify query execution time < 100ms
- [ ] Check EXPLAIN ANALYZE for query plan
- [ ] Test with concurrent requests (load testing)
- [ ] Monitor memory usage
- [ ] Verify no N+1 queries
- [ ] Test pagination with large datasets
- [ ] Check index usage with EXPLAIN

---

## 🛠️ Tools & Commands

### Analyze Query Performance:
```sql
EXPLAIN ANALYZE 
SELECT * FROM students 
WHERE institution_id = 1 AND status = 'ACTIVE';
```

### Check Index Usage:
```sql
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan as index_scans,
  idx_tup_read as tuples_read,
  idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

### Find Missing Indexes:
```sql
SELECT 
  schemaname,
  tablename,
  seq_scan,
  seq_tup_read,
  seq_tup_read / seq_scan as avg_read
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_tup_read DESC
LIMIT 20;
```

---

## 📝 Implementation Template

When creating a new API module:

### 0. Postman Documentation (MANDATORY)
```
For EVERY endpoint created or updated:

1. Open Postman
2. Create/Update request in appropriate collection folder
3. Add request details:
   - HTTP method (GET, POST, PUT, DELETE)
   - URL with path parameters
   - Query parameters with descriptions
   - Request headers (Authorization: Bearer {{token}})
   - Request body (JSON examples)
   - Example responses (success + error cases)
4. Test the endpoint
5. Save and export collection
```

### 1. Create Migration File:
```
backend/prisma/migrations/YYYYMMDDHHMMSS_add_[module]_performance/
└── migration.sql
```

### 2. Add Indexes:
```sql
-- Single column indexes
CREATE INDEX IF NOT EXISTS idx_[table]_[column] ON [table]([column]);

-- Composite indexes
CREATE INDEX IF NOT EXISTS idx_[table]_[col1]_[col2] ON [table]([col1], [col2]);

-- Partial indexes
CREATE INDEX IF NOT EXISTS idx_[table]_[condition] ON [table]([column]) WHERE [condition];
```

### 3. Create Views:
```sql
CREATE OR REPLACE VIEW [module]_summary AS
SELECT 
  -- Pre-aggregated columns
FROM [base_table]
JOIN [related_tables]
GROUP BY [grouping_columns];
```

### 4. Service Methods:
```typescript
// Helper for view queries
private async get[Entity]FromView(filters) {
  return this.prisma.$queryRaw`SELECT * FROM [view_name] WHERE ...`;
}

// Main service methods with selective loading
async findAll(query: QueryDto) {
  return this.prisma.[model].findMany({
    select: { /* only required fields */ },
  });
}
```

---

## 🎯 Examples from Existing Modules

### Students Module ✅
- Uses `student_attendance_summary` view
- Uses `semester_grade_summary` view
- 18 strategic indexes
- Selective field loading
- Performance: 93% improvement

### Teachers Module ✅
- Uses `teacher_attendance_summary` view
- Composite indexes for dashboard queries
- Selective field loading
- Performance: 94% improvement

### Fees Module ✅
- 4 database views
- 18 performance indexes
- Selective field loading
- Performance: 93% improvement

---

## ⚠️ Common Mistakes to Avoid

### 1. Over-fetching Data
❌ `include: { student: true }`
✅ `select: { student: { select: { id: true, name: true } } }`

### 2. Missing Indexes
❌ Query without index on WHERE column
✅ Add index before deploying

### 3. Not Using Views
❌ Complex JOIN in every query
✅ Create view, query view

### 4. No Pagination
❌ Return all records
✅ Paginate with limit

### 5. N+1 Queries
❌ Loop with await inside
✅ Single query with include/batch

---

## 📚 Review Process

Before merging any API PR:

1. **Code Review Checklist:**
   - [ ] Performance optimization applied
   - [ ] Migration file includes indexes
   - [ ] Views created for aggregations
   - [ ] Selective field loading used
   - [ ] Pagination implemented
   - [ ] No N+1 queries
   - [ ] Performance documented

2. **Performance Review:**
   - [ ] Query execution time logged
   - [ ] EXPLAIN ANALYZE reviewed
   - [ ] Load testing passed
   - [ ] Memory usage acceptable

3. **Documentation:**
   - [ ] Performance characteristics documented
   - [ ] Optimization strategies explained
   - [ ] View purposes described
   - [ ] **All endpoints tested in Postman**
   - [ ] **Postman collection exported and committed**

---

## 🎓 Learning Resources

- [Prisma Performance Best Practices](https://www.prisma.io/docs/guides/performance-and-optimization)
- [PostgreSQL Index Types](https://www.postgresql.org/docs/current/indexes-types.html)
- [Query Optimization Guide](https://www.postgresql.org/docs/current/performance-tips.html)
- [Database View Strategies](https://www.postgresql.org/docs/current/sql-createview.html)

---

## 🔄 Version History

- **v1.0** (2026-02-12): Initial performance optimization standards
- Applied to: Students, Teachers, Fees, Communications modules
- Average improvement: 93% across all optimized endpoints

---

**Remember**: Performance optimization is not optional. It's a core requirement for production-ready APIs.

Every millisecond saved improves user experience. Every optimized query reduces server costs.

⚡ **Optimize by default. Measure everything. Iterate continuously.**
