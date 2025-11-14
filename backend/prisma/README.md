# Prisma Schema Organization

This project uses a **multi-file schema approach** for better organization, maintainability, and team collaboration.

## 🎯 Why Multi-File Schema?

Traditional Prisma projects use a single `schema.prisma` file, which can become unwieldy in large projects. Our approach splits the schema into logical modules:

- ✅ **Better Organization** - Related models grouped together
- ✅ **Easier Maintenance** - Smaller, focused files
- ✅ **Team Collaboration** - Multiple developers can work on different modules
- ✅ **Version Control** - Cleaner diffs and easier code reviews
- ✅ **Scalability** - Easy to add new modules without cluttering

## 📁 File Structure

```
prisma/
├── schema.prisma              # Auto-generated combined schema
├── schema/                    # Individual schema modules
│   ├── core.prisma           # Institution, User, Role
│   ├── academic.prisma       # Course, Subject, AcademicYear, Semester
│   ├── users.prisma          # Student, Teacher, Parent, Staff
│   ├── records.prisma        # AcademicRecord, Attendance, Enrollment
│   ├── assessment.prisma     # Examination, Assignment, Submission
│   ├── fees.prisma           # FeeStructure, StudentFee, Payment
│   ├── communication.prisma  # Notice, Message, Announcement
│   ├── library.prisma        # Book, BookIssue, LibraryTransaction
│   ├── staff.prisma          # Staff, StaffAttendance, StaffLeave
│   ├── gatepass.prisma       # GatePass, VisitorPass
│   ├── timetable.prisma      # TimeTable, TimeSlot, Room
│   └── analytics.prisma      # StudentProgress, DashboardStats
├── seed.ts                    # Database seeding script
└── README.md                  # This file
```

## 📋 Schema Modules Breakdown

### `core.prisma` - Foundation

Core entities that the entire system depends on:

- **User** - User accounts and authentication
- **Role** - Role definitions (admin, teacher, student, etc.)
- **Institution** - Educational institution details

### `academic.prisma` - Academic Structure

The backbone of the educational system:

- **AcademicYear** - Academic years (2024-2025)
- **Semester** - Terms (Fall, Spring)
- **Course** - Degree programs/streams (B.Sc. CS, Science-Medical)
- **Subject** - Individual subjects/papers (Data Structures, Physics)

### `users.prisma` - People

All user-related profiles:

- **Student** - Student profiles and enrollment info
- **Teacher** - Faculty profiles and assignments
- **Parent** - Parent/guardian information
- **Staff** - Administrative staff profiles

### `records.prisma` - Academic Operations

Day-to-day academic activities:

- **AcademicRecord** - Grades and marks
- **Enrollment** - Student-subject enrollments
- **ClassSection** - Class sections with teachers
- **Attendance** - Daily attendance tracking

### `assessment.prisma` - Evaluation

Student assessment and grading:

- **Examination** - Exam schedules and details
- **ExamResult** - Student exam results
- **Assignment** - Course assignments
- **Submission** - Student submissions

### `fees.prisma` - Financial

Fee management:

- **FeeStructure** - Fee definitions by course
- **StudentFee** - Individual fee records
- **Payment** - Payment transactions
- **PaymentMethod** - Payment method tracking

### `communication.prisma` - Messaging

Internal communication:

- **Notice** - Important notices
- **Announcement** - General announcements
- **Message** - Direct messaging
- **MessageGroup** - Group conversations

### `library.prisma` - Library System

Library management:

- **Book** - Book catalog
- **BookIssue** - Issue/return records
- **BookReservation** - Book reservations
- **LibraryTransaction** - Transaction history
- **LibrarySettings** - Library configuration

### `staff.prisma` - Staff Management

Staff operations:

- **StaffAttendance** - Staff attendance
- **StaffLeave** - Leave applications
- **StaffSalary** - Salary management

### `gatepass.prisma` - Access Control

Entry/exit management:

- **GatePass** - Student gate passes
- **VisitorPass** - Visitor entry passes
- **GatePassSettings** - Configuration

### `timetable.prisma` - Scheduling

Class scheduling:

- **TimeTable** - Class schedules
- **TimeSlot** - Time slot definitions
- **Room** - Room/classroom management
- **TeacherSubject** - Teacher-subject assignments
- **ClassTeacher** - Class teacher assignments

### `analytics.prisma` - Insights

Analytics and reporting:

- **StudentProgress** - Progress tracking
- **AttendanceSummary** - Attendance analytics
- **DashboardStats** - Dashboard metrics
- **PerformanceMetrics** - Performance data
- **CareerGuidance** - Career guidance records
- **Application** - Student applications
- **SystemAlert** - System alerts

## 🔧 How It Works

### 1. Individual Schema Files

Each file in `schema/` contains related models and enums. For example, `academic.prisma`:

```prisma
model Course {
  id            Int      @id @default(autoincrement())
  institutionId Int      @map("institution_id")
  name          String   @db.VarChar(200)
  code          String?  @unique @db.VarChar(20)
  degreeType    DegreeType @map("degree_type")

  // Relations
  institution   Institution @relation(fields: [institutionId], references: [id])
  subjects      Subject[]
  students      Student[]

  @@map("courses")
}

enum DegreeType {
  CERTIFICATE
  DIPLOMA
  BACHELORS
  MASTERS
  PHD
  OTHER
}
```

### 2. Build Script

The `scripts/build-schema.js` file combines all individual schemas into `schema.prisma`:

```javascript
// Reads all files from schema/ directory
// Combines them with proper ordering
// Writes to schema.prisma
```

### 3. Auto-Generation

The main `schema.prisma` is **automatically generated**. Never edit it directly!

```prisma
// This is your Prisma schema file
// Auto-generated from individual files in /prisma/schema/
// DO NOT EDIT DIRECTLY - Edit files in /prisma/schema/ instead

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ... combined models from all schema files ...
```

## 📝 Usage Guide

### Adding New Models

**Step 1:** Edit the appropriate schema file in `/prisma/schema/`

```prisma
// In schema/academic.prisma
model Department {
  id            Int      @id @default(autoincrement())
  institutionId Int      @map("institution_id")
  name          String   @db.VarChar(100)
  code          String   @unique @db.VarChar(10)

  institution   Institution @relation(fields: [institutionId], references: [id])

  @@map("departments")
}
```

**Step 2:** Rebuild the schema

```bash
npm run build:schema
```

**Step 3:** Generate Prisma client

```bash
npm run db:generate
```

**Step 4:** Apply changes to database

```bash
npm run db:push
# or
npm run db:migrate
```

### Modifying Existing Models

1. **Find the model** in the appropriate schema file
2. **Make your changes** to the individual file
3. **Run build script**: `npm run build:schema`
4. **Generate client**: `npm run db:generate`
5. **Apply to database**: `npm run db:push`

### Creating New Schema Modules

If you need a new module (e.g., `hostel.prisma`):

1. **Create the file** in `prisma/schema/`:

   ```bash
   touch prisma/schema/hostel.prisma
   ```

2. **Add your models**:

   ```prisma
   model Hostel {
     id   Int    @id @default(autoincrement())
     name String @db.VarChar(100)

     @@map("hostels")
   }
   ```

3. **Update build script** to include the new file in `scripts/build-schema.js`

4. **Rebuild and generate**:
   ```bash
   npm run build:schema
   npm run db:generate
   ```

## 🛠️ Available Commands

### Core Commands

```bash
# Build combined schema from individual files
npm run build:schema

# Generate Prisma client (auto-builds schema first)
npm run db:generate

# Push schema to database without migrations (auto-builds schema first)
npm run db:push

# Create a new migration (auto-builds schema first)
npm run db:migrate

# Reset database (WARNING: Deletes all data!)
npm run db:reset

# Open Prisma Studio - Database GUI
npm run db:studio

# Seed database with sample data
npm run db:seed
```

### Common Workflows

**Making Schema Changes:**

```bash
# 1. Edit individual schema file
vim prisma/schema/academic.prisma

# 2. Build and generate
npm run db:generate

# 3. Apply to database
npm run db:push
```

**Creating a Migration:**

```bash
# Build schema and create migration
npm run db:migrate

# Follow the prompts to name your migration
```

**Fresh Start:**

```bash
# Reset everything and seed
npm run db:reset
npm run db:seed
```

## 🇮🇳 Indian Education System Terminology

This schema uses terminology familiar to Indian educational institutions:

### Database Tables & Their Meanings

| Table              | Indian Term          | Represents                  | Examples                                          |
| ------------------ | -------------------- | --------------------------- | ------------------------------------------------- |
| `courses`          | Course/Degree/Stream | Program of study            | B.Sc. Computer Science, Science-Medical, Commerce |
| `subjects`         | Subject/Paper        | Individual academic subject | Data Structures, Physics, English, Mathematics    |
| `enrollments`      | Enrollment           | Student taking a subject    | Student enrolled in "Physics"                     |
| `academic_records` | Marks/Grades         | Student performance         | 85 marks in "Data Structures"                     |
| `class_sections`   | Section              | Class division              | Section A, Section B                              |
| `academic_years`   | Session              | Academic year               | 2024-2025                                         |
| `semesters`        | Term/Semester        | Academic term               | Fall 2024, Spring 2025                            |

### Key Relationships

```
Institution
    ↓
Course (B.Sc. Computer Science)
    ↓
Subject (Data Structures, Physics, etc.)
    ↓
Enrollment (Student enrolls in subject)
    ↓
AcademicRecord (Student gets grades)
```

## ⚠️ Important Notes

### DO's ✅

- **Always edit individual files** in `/prisma/schema/`
- **Run `npm run build:schema`** after making changes
- **Commit both** individual files and generated `schema.prisma`
- **Test changes** in development before production
- **Use migrations** for production databases

### DON'Ts ❌

- **Never edit** `schema.prisma` directly (it will be overwritten)
- **Don't skip** the build step after editing individual files
- **Don't forget** to regenerate Prisma client after schema changes
- **Avoid force-reset** on production databases (data loss!)

## 🔄 Migration Workflow

### Development

```bash
# 1. Make schema changes
vim prisma/schema/academic.prisma

# 2. Push changes (no migrations needed in dev)
npm run db:push
```

### Production

```bash
# 1. Make schema changes
vim prisma/schema/academic.prisma

# 2. Create migration
npm run db:migrate

# 3. Apply migration on production
npx prisma migrate deploy
```

## 🐛 Troubleshooting

### Schema Out of Sync

```bash
# Rebuild schema from individual files
npm run build:schema

# Regenerate Prisma client
npm run db:generate
```

### Prisma Client Errors

```bash
# Clear Prisma cache
rm -rf node_modules/.prisma
rm -rf node_modules/@prisma

# Reinstall and regenerate
npm install
npm run db:generate
```

### Database Out of Sync

```bash
# Check current state
npx prisma db pull

# Reset to match schema (WARNING: Data loss!)
npm run db:reset
npm run db:seed
```

### Build Script Errors

```bash
# Check if all schema files are valid
npx prisma format prisma/schema/academic.prisma
npx prisma format prisma/schema/users.prisma
# ... check each file

# Then rebuild
npm run build:schema
```

## 📚 Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [Prisma Schema Reference](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference)
- [Prisma CLI Reference](https://www.prisma.io/docs/reference/api-reference/command-reference)
- [Prisma Best Practices](https://www.prisma.io/docs/guides/performance-and-optimization)

## 🤝 Contributing

When contributing schema changes:

1. **Edit individual schema files** only
2. **Run build script** before committing
3. **Include both** individual files and generated schema in commits
4. **Test migrations** locally first
5. **Document breaking changes** in commit messages

---

**Organized schemas for a scalable educational platform** 🎓
