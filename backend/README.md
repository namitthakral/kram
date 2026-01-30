# Ed-verse Backend API

A comprehensive NestJS-based backend API for educational institution management, built with TypeScript, Prisma ORM, and PostgreSQL. Designed specifically for Indian schools, colleges, and universities.

## 🚀 Features

### Core Functionality
- **🔐 Authentication & Authorization** - JWT-based auth with role-based access control (RBAC)
- **👥 Multi-Institution Support** - Manage multiple schools/colleges from one platform
- **🎓 Academic Management** - Complete student lifecycle from admission to graduation
- **📚 Course & Subject Management** - Handle courses (degree programs) and subjects (academic papers)
- **📊 Attendance Tracking** - Real-time attendance with analytics and reports
- **📝 Assessment System** - Assignments, examinations, and grading
- **💰 Fee Management** - Fee structures, collections, payment tracking
- **📖 Library System** - Book cataloging, issue/return, reservations
- **🗓️ Timetable Management** - Automated scheduling with conflict detection
- **💬 Communications Hub** - Unified communications (notices, announcements, alerts) with read tracking
- **🆔 EdVerse ID System** - Unique institution-wide ID generation
- **📋 Question Paper Generator** - Automated question paper generation
- **🚪 Gate Pass Management** - Digital gate pass requests and approvals
- **📈 Analytics Dashboard** - Built-in analytics for students and teachers

### Technical Features
- **Type Safety** - Full TypeScript implementation
- **Data Validation** - class-validator for request validation
- **Database ORM** - Prisma for type-safe database access
- **Security** - Rate limiting, CORS, Helmet, password hashing
- **Scalable Architecture** - NestJS modular structure
- **API Documentation** - Swagger/OpenAPI ready

## 📋 Prerequisites

- **Node.js** v18 or higher
- **npm** v9 or higher
- **PostgreSQL** v12 or higher
- **Git**

## 🛠️ Installation

### 1. Install Dependencies

```bash
npm install
```

### 2. Environment Configuration

Create a `.env` file in the backend root:

```bash
cp .env.example .env
```

Configure your environment variables:

```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/edverse"

# Server
PORT=3000
NODE_ENV=development

# JWT Authentication
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
JWT_EXPIRES_IN="1h"
JWT_REFRESH_SECRET="your-refresh-secret"
JWT_REFRESH_EXPIRES_IN="7d"

# Rate Limiting
RATE_LIMIT_TTL=60
RATE_LIMIT_MAX=100

# CORS
CORS_ORIGIN="http://localhost:3000,http://localhost:8080"

# Email (Optional - for notifications)
SMTP_HOST="smtp.gmail.com"
SMTP_PORT=587
SMTP_USER="your-email@gmail.com"
SMTP_PASS="your-app-password"
SMTP_FROM="Ed-verse <noreply@edverse.edu>"
```

### 3. Database Setup

```bash
# Generate Prisma client
npm run db:generate

# Apply schema to database
npm run db:push

# Seed database with sample data
npm run db:seed
```

### 4. Start Development Server

```bash
npm run dev
```

The API will be available at `http://localhost:3000`

## 🏗️ Project Architecture

This backend follows **NestJS's modular architecture** pattern with clear separation of concerns:

```
src/
├── auth/                   # Authentication & authorization
│   ├── guards/            # Auth guards (JWT, Roles, Student, Teacher, Parent)
│   ├── decorators/        # Custom decorators (CurrentUser, Public, Roles)
│   ├── strategies/        # Passport strategies (JWT)
│   └── dto/              # Auth DTOs
│
├── users/                 # User management
├── admin/                 # Administrative functions
├── students/              # Student management
│   ├── services/         # Progress updater service
│   └── utils/            # Grading config & progress calculator
│
├── teachers/              # Teacher management
│   └── dto/              # Assignment, Attendance, Exam DTOs
│
├── courses/               # Course & subject management
│   ├── courses.controller.ts
│   ├── subjects.controller.ts
│   ├── class-sections.controller.ts
│   └── dto/
│
├── institutions/          # Institution management
├── communications/        # Unified communications (notices, announcements, alerts)
│   ├── communications.controller.ts
│   ├── communications.service.ts
│   └── dto/              # Create, Update, Query DTOs
│
├── timetable/             # Scheduling & timetable management
├── question-paper/        # Question paper generation
├── id-generation/         # EdVerse ID generation system
│   ├── id-generation.service.ts
│   ├── sequence.service.ts
│   └── id-config-cache.service.ts
│
├── prisma/                # Database access layer
│   ├── prisma.module.ts
│   └── prisma.service.ts
│
├── common/                # Shared resources
│   ├── dto/              # Common DTOs
│   └── types/            # TypeScript type definitions
│
├── utils/                 # Utility functions
│   ├── edverse-id.util.ts
│   └── id-template.util.ts
│
└── main.ts                # Application entry point
```

### Architecture Components

#### **Controllers** (`*.controller.ts`)
Handle HTTP requests and responses. Define API endpoints using decorators.

```typescript
@Controller('subjects')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SubjectsController {
  @Get()
  @Roles('admin', 'teacher')
  findAll() {
    return this.subjectsService.findAll()
  }
}
```

#### **Services** (`*.service.ts`)
Contain business logic and database operations.

```typescript
@Injectable()
export class SubjectsService {
  constructor(private prisma: PrismaService) {}
  
  async findAll() {
    return this.prisma.subject.findMany({
      include: { course: true }
    })
  }
}
```

#### **Modules** (`*.module.ts`)
Organize and configure related components.

```typescript
@Module({
  imports: [PrismaModule],
  controllers: [SubjectsController],
  providers: [SubjectsService],
  exports: [SubjectsService],
})
export class SubjectsModule {}
```

#### **DTOs** (`dto/*.dto.ts`)
Define data validation rules and types.

```typescript
export class CreateSubjectDto {
  @IsString()
  @MinLength(2)
  subjectName: string

  @IsInt()
  @Min(0)
  credits: number
}
```

## 🗄️ Database Schema

### Indian Education System Terminology

This system uses terminology familiar to Indian educational institutions:

| Term | Database Table | Meaning | Examples |
|------|---------------|---------|----------|
| **Course** | `courses` | Degree/Stream/Program | B.Sc. Computer Science, Science-Medical, Commerce |
| **Subject** | `subjects` | Individual Academic Paper | Data Structures, Physics, English |
| **Enrollment** | `enrollments` | Student taking a subject | Student enrolled in "Physics" |
| **Academic Record** | `academic_records` | Grades for a subject | 85 marks in "Data Structures" |

### Core Entities

#### **Authentication & Users**
- `users` - User accounts and authentication
- `roles` - User roles (super_admin, admin, teacher, student, parent, librarian, staff)
- `institutions` - Educational institutions

#### **Academic Structure**
- `academic_years` - Academic years (2024-2025)
- `semesters` - Academic terms (Fall 2024, Spring 2025)
- `courses` - Degree programs/streams (B.Sc. CS, Science-Medical)
- `subjects` - Individual subjects/papers (Data Structures, Physics)

#### **People**
- `students` - Student profiles and enrollment information
- `teachers` - Faculty profiles and teaching assignments
- `parents` - Parent/guardian information
- `staff` - Administrative staff

#### **Academic Operations**
- `enrollments` - Students enrolled in subjects
- `class_sections` - Subject sections with teachers
- `attendance` - Daily attendance records
- `academic_records` - Semester-wise grades and marks

#### **Assessment**
- `examinations` - Exam schedules and details
- `exam_results` - Student exam results
- `assignments` - Course assignments
- `submissions` - Student assignment submissions

#### **Communications**
- `communications` - Unified communications (notices, announcements, alerts)
- `communication_read_receipts` - Read tracking for communications
- `messages` - Direct messages between users
- `message_groups` - Group messaging
- `group_members` - Group membership

#### **Fee & Payments**
- `fee_structures` - Fee definitions by course
- `student_fees` - Individual student fee records
- `payments` - Fee payment transactions

#### **Library Management**
- `books` - Library book catalog
- `book_categories` - Book categorization
- `book_issues` - Book issue/return records
- `book_reservations` - Book reservation requests
- `library_settings` - Library configuration

#### **Staff Management**
- `staff_attendance` - Staff attendance records
- `staff_leave` - Leave requests and approvals
- `staff_assignments` - Staff duty assignments

#### **Gate Pass System**
- `gate_passes` - Student gate pass requests
- `gate_pass_settings` - Gate pass configuration
- `visitor_passes` - Visitor entry passes

#### **Timetable & Scheduling**
- `timetables` - Class schedules
- `time_slots` - Time slot definitions
- `rooms` - Room/classroom management
- `teacher_subjects` - Teacher-subject assignments
- `teacher_substitutions` - Substitute teacher tracking
- `class_teachers` - Class teacher assignments

#### **Advanced Features**
- `student_progress` - Comprehensive student progress tracking
- `career_guidance` - Career counseling records
- `applications` - Student application forms
- `system_alerts` - System-wide alerts and notifications
- `institution_grading_config` - Institution-specific grading rules
- `institution_id_config` - EdVerse ID generation configuration

## 🔌 API Endpoints

### Authentication

```
POST   /api/auth/register          Register new user
POST   /api/auth/login             User login (returns JWT)
POST   /api/auth/refresh           Refresh access token
POST   /api/auth/change-password   Change password
POST   /api/auth/forgot-password   Request password reset
GET    /api/auth/profile           Get current user profile
POST   /api/auth/logout            User logout
```

### Users & Roles

```
GET    /api/users                  List all users (Admin)
GET    /api/users/:id              Get user by ID
POST   /api/users                  Create user (Admin)
PATCH  /api/users/:id              Update user
DELETE /api/users/:id              Delete user (Admin)
GET    /api/roles                  List all roles
```

### Students

```
GET    /api/students               List students (Admin/Teacher)
GET    /api/students/:id           Get student details
POST   /api/students               Create student (Admin)
PATCH  /api/students/:id           Update student (Admin)
DELETE /api/students/:id           Delete student (Admin)
GET    /api/students/:id/academic-records    Student grades
GET    /api/students/:id/attendance          Attendance history
```

### Teachers

```
GET    /api/teachers               List teachers
GET    /api/teachers/:id           Get teacher details
POST   /api/teachers               Create teacher (Admin)
PATCH  /api/teachers/:id           Update teacher
DELETE /api/teachers/:id           Delete teacher
GET    /api/teachers/:id/subjects  Assigned subjects
```

### Subjects (Academic Papers)

```
GET    /api/subjects               List all subjects
GET    /api/subjects/:id           Get subject details
GET    /api/subjects/course/:id    Get subjects for a course
POST   /api/subjects               Create subject (Admin)
PATCH  /api/subjects/:id           Update subject (Admin)
DELETE /api/subjects/:id           Delete subject (Admin)
GET    /api/subjects/stats/overview    Subject statistics
```

### Attendance

```
GET    /api/attendance             List attendance records
GET    /api/attendance/student/:id Student attendance
POST   /api/attendance             Mark attendance (Teacher)
PATCH  /api/attendance/:id         Update attendance
GET    /api/attendance/summary     Attendance summary
```

### Courses & Subjects

```
GET    /api/courses                List all courses
GET    /api/courses/with-sections  List courses with sections
GET    /api/courses/:id            Get course details
GET    /api/courses/:id/sections   Get sections for a course

GET    /api/subjects               List all subjects
GET    /api/subjects/:id           Get subject details
GET    /api/subjects/course/:id    Get subjects for a course
POST   /api/subjects               Create subject (Admin)
PATCH  /api/subjects/:id           Update subject (Admin)
DELETE /api/subjects/:id           Delete subject (Admin)
GET    /api/subjects/stats/overview    Subject statistics

GET    /api/class-sections         List all class sections
GET    /api/class-sections/:id/students     Get section students
GET    /api/class-sections/:id/attendance   Get section attendance
```

### Communications (Unified Notices, Announcements & Alerts)

```
POST   /api/communications                Create communication
GET    /api/communications                List all (with filtering)
GET    /api/communications/unread         Get unread communications
GET    /api/communications/:id            Get communication details
PUT    /api/communications/:id            Update communication
DELETE /api/communications/:id            Delete communication
POST   /api/communications/:id/read       Mark as read
GET    /api/communications/:id/stats      Get read statistics
```

**Query Parameters for GET /api/communications:**
- `type` - Filter by type (NOTICE, ANNOUNCEMENT, ALERT, etc.)
- `priority` - Filter by priority (LOW, MEDIUM, HIGH, URGENT)
- `targetAudience` - Filter by role (student, teacher, parent, etc.)
- `isEmergency` - Filter emergency communications
- `isPinned` - Filter pinned communications
- `isActive` - Filter active/inactive
- `institutionId` - Filter by institution
- `search` - Search in title and content
- `startDate` / `endDate` - Filter by date range
- `page` / `limit` - Pagination

### Institutions

```
GET    /api/institutions           List institutions (Admin)
GET    /api/institutions/:id       Get institution details
POST   /api/institutions           Create institution (Super Admin)
PATCH  /api/institutions/:id       Update institution (Admin)
DELETE /api/institutions/:id       Delete institution (Super Admin)
```

### Timetable

```
GET    /api/timetable              List timetables
GET    /api/timetable/:id          Get timetable details
POST   /api/timetable              Create timetable (Admin)
PATCH  /api/timetable/:id          Update timetable
DELETE /api/timetable/:id          Delete timetable
```

### Question Papers

```
GET    /api/question-paper         List question papers
GET    /api/question-paper/:id     Get question paper details
POST   /api/question-paper         Generate question paper (Teacher)
PATCH  /api/question-paper/:id     Update question paper
DELETE /api/question-paper/:id     Delete question paper
```

### Assignments & Examinations (via Teachers Module)

**Assignments:**
```
POST   /api/teachers/:uuid/assignments              Create assignment
GET    /api/teachers/:uuid/assignments              List assignments
GET    /api/teachers/:uuid/assignments/:id          Get assignment details
PATCH  /api/teachers/:uuid/assignments/:id          Update assignment
DELETE /api/teachers/:uuid/assignments/:id          Delete assignment
GET    /api/teachers/:uuid/submissions/pending      Get pending submissions
```

**Examinations:**
```
POST   /api/teachers/:uuid/examinations             Create examination
GET    /api/teachers/:uuid/examinations             List examinations
GET    /api/teachers/:uuid/examinations/:id         Get examination details
PATCH  /api/teachers/:uuid/examinations/:id         Update examination
DELETE /api/teachers/:uuid/examinations/:id         Delete examination
POST   /api/teachers/:uuid/examinations/:id/results      Post result
POST   /api/teachers/:uuid/examinations/:id/results/bulk Post bulk results
GET    /api/teachers/:uuid/examinations/:id/results      Get all results
PATCH  /api/teachers/:uuid/examinations/:id/results/:id  Update result
DELETE /api/teachers/:uuid/examinations/:id/results/:id  Delete result
```

**Attendance:**
```
POST   /api/teachers/:uuid/attendance               Mark attendance
POST   /api/teachers/:uuid/attendance/bulk          Mark bulk attendance
PATCH  /api/teachers/:uuid/attendance/:id           Update attendance
DELETE /api/teachers/:uuid/attendance/:id           Delete attendance
GET    /api/teachers/:uuid/attendance-summary       Get attendance summary
GET    /api/teachers/:uuid/attendance-trends        Get attendance trends
```

**Analytics & Reports:**
```
GET    /api/teachers/:uuid/dashboard-stats          Teacher dashboard stats
GET    /api/teachers/:uuid/subject-performance      Subject performance
GET    /api/teachers/:uuid/grade-distribution       Grade distribution
GET    /api/teachers/:uuid/recent-activity          Recent activity
GET    /api/teachers/:uuid/students/at-risk         At-risk students
POST   /api/teachers/:uuid/report-cards/generate    Generate report cards
```

### Admin Functions

```
GET    /api/admin/grading-config           Get grading configuration
POST   /api/admin/grading-config           Update grading configuration
```

### Health Check

```
GET    /health                     Server health status
GET    /api                        API information
```

## 📦 Available Modules

The backend is organized into the following feature modules:

| Module | Description | Controllers |
|--------|-------------|-------------|
| `AuthModule` | Authentication & authorization | `auth.controller.ts` |
| `UsersModule` | User management | `users.controller.ts` |
| `AdminModule` | Administrative functions | `admin.controller.ts` |
| `StudentsModule` | Student management & analytics | `students.controller.ts` |
| `TeachersModule` | Teacher management, assignments, exams | `teachers.controller.ts` |
| `CoursesModule` | Courses, subjects, class sections | `courses.controller.ts`, `subjects.controller.ts`, `class-sections.controller.ts` |
| `InstitutionsModule` | Institution management | `institutions.controller.ts` |
| `CommunicationsModule` | Unified communications system | `communications.controller.ts` |
| `TimetableModule` | Timetable & scheduling | `timetable.controller.ts` |
| `QuestionPaperModule` | Question paper generation | `question-paper.controller.ts` |
| `IdGenerationModule` | EdVerse ID generation | (Service only) |
| `PrismaModule` | Database access layer | (Service only) |

**Note:** Some features mentioned in older documentation (like separate `assignments`, `examinations`, `attendance`, `fees`, `library`, `analytics` modules) are **integrated into the main modules** (Students, Teachers) rather than being separate modules. The database schema supports these features, but they are accessed through the Students and Teachers controllers.

## 🔐 Authentication & Authorization

### JWT Authentication

The API uses JWT (JSON Web Tokens) for authentication:

1. **Login** with credentials to get access and refresh tokens
2. **Include token** in Authorization header: `Bearer <token>`
3. **Refresh token** when access token expires

**Sample Login Request:**

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@edverse.edu",
    "password": "admin123!"
  }'
```

**Sample Response:**

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": 1,
      "email": "admin@edverse.edu",
      "role": "super_admin"
    }
  }
}
```

**Sample Authenticated Request:**

```bash
curl -X GET http://localhost:3000/api/students \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

### Role-Based Access Control

The system supports 7 roles with different permissions:

| Role | Permissions |
|------|-------------|
| **super_admin** | Full system access, manage all institutions |
| **admin** | Manage institution, users, courses, subjects |
| **teacher** | Manage classes, attendance, assignments, grades |
| **student** | View own data, submit assignments |
| **parent** | View child's data, communicate with teachers |
| **librarian** | Manage library, books, issue/return |
| **staff** | Administrative tasks, gate passes |

**Protecting Routes:**

```typescript
@Get('sensitive-data')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'super_admin')
getSensitiveData() {
  return this.service.getSensitiveData()
}
```

## 📝 Sample Data

After running `npm run db:seed`, you get:

### Sample Accounts

```
Super Admin:  admin@edverse.edu      / admin123!
Teacher:      john.doe@edverse.edu   / teacher123!
Students:     student1@edverse.edu   / student123!
              student2@edverse.edu   / student123!
              student3@edverse.edu   / student123!
              student4@edverse.edu   / student123!
              student5@edverse.edu   / student123!
Parents:      parent1@email.com      / parent123!
              parent2@email.com      / parent123!
              parent3@email.com      / parent123!
              parent4@email.com      / parent123!
              parent5@email.com      / parent123!
Librarian:    librarian@edverse.edu  / librarian123!
Staff:        staff@edverse.edu      / staff123!
```

### Sample Data Includes

- 1 Institution (Ed-verse University)
- 7 Roles (Super Admin, Admin, Teacher, Student, Parent, Librarian, Staff)
- 1 Course (B.Sc. Computer Science)
- 3 Subjects (Programming, Data Structures, Web Development)
- 5 Students with enrollments
- 1 Teacher with subject assignments
- 2 Class sections
- Sample attendance records
- Sample assignments and exams
- Fee structures and payments
- Library books and categories
- Communications (notices, announcements, alerts)
- Timetable entries
- Academic records

## 🗄️ Database Management

### Database Commands

```bash
# Build combined schema from modular files
npm run build:schema

# Generate Prisma client (after schema changes)
npm run db:generate

# Push schema to database (development only)
npm run db:push

# Create a new migration
npm run db:migrate

# Apply pending migrations
npx prisma migrate deploy

# Reset database (WARNING: Deletes all data and re-seeds!)
npm run db:reset

# Open Prisma Studio (Database GUI)
npm run db:studio

# Seed database with sample data
npm run db:seed
```

### Database Schema Organization

The Prisma schema is organized into modular files under `/prisma/schema/` for better maintainability:

- `core.prisma` - User, Role, Institution
- `academic.prisma` - Academic years, semesters, courses, subjects
- `users.prisma` - Student, Teacher, Parent, Staff profiles
- `academics-operations.prisma` - Attendance, enrollments, academic records
- `assessment.prisma` - Assignments, examinations, submissions
- `communication.prisma` - Communications, messages, groups
- `fee.prisma` - Fee structures and payments
- `library.prisma` - Library books and management
- `timetable.prisma` - Timetable and scheduling
- `gate-pass.prisma` - Gate pass and visitor management
- `enums.prisma` - All enum definitions

After modifying any schema file, run:
```bash
npm run build:schema  # Combines all files into schema.prisma
npm run db:generate   # Regenerates Prisma Client
```

### Recent Database Changes

**Phase 1 - Removed Redundant Analytics Tables (January 2026)**
- ❌ Removed `dashboard_stats` - Computed on-the-fly
- ❌ Removed `attendance_summary` - Computed on-the-fly
- ❌ Removed `performance_metrics` - Computed on-the-fly

**Phase 2 - Unified Communications (January 2026)**
- ❌ Removed separate `notices` and `announcements` tables
- ✅ Added unified `communications` table with type field
- ✅ Added `communication_read_receipts` for read tracking
- ✅ Supports types: NOTICE, ANNOUNCEMENT, ALERT, UPDATE, REMINDER, EVENT
- ✅ Priority levels: LOW, MEDIUM, HIGH, URGENT
- ✅ Target audience filtering by role
- ✅ Emergency flag for critical communications
- ✅ Pin/unpin functionality
- ✅ Publish date and expiry date support

## 🧪 Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:cov

# Run E2E tests
npm run test:e2e
```

## 📝 Code Quality

```bash
# Lint code
npm run lint

# Auto-fix linting issues
npm run lint:fix

# Format code
npm run format

# Type checking
npx tsc --noEmit
```

## 🚀 Deployment

### Build for Production

```bash
npm run build
```

### Start Production Server

```bash
npm start
```

### Environment Variables for Production

**Critical Settings:**

```env
NODE_ENV=production
DATABASE_URL="<production-database-url>"
JWT_SECRET="<strong-random-secret>"
JWT_REFRESH_SECRET="<different-strong-secret>"
PORT=3000
```

**Security Settings:**

```env
CORS_ORIGIN="https://yourdomain.com"
RATE_LIMIT_TTL=60
RATE_LIMIT_MAX=100
```

### Deployment Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Use strong, random `JWT_SECRET` (256-bit minimum)
- [ ] Configure production database with SSL
- [ ] Set appropriate `CORS_ORIGIN`
- [ ] Enable HTTPS/TLS
- [ ] Configure rate limiting
- [ ] Set up error logging (Sentry, LogRocket)
- [ ] Configure backup strategy
- [ ] Set up monitoring (PM2, New Relic)
- [ ] Enable database connection pooling
- [ ] Configure CDN for static assets

## 📚 Response Format

All API responses follow a consistent format:

**Success Response:**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe"
  },
  "message": "Resource retrieved successfully"
}
```

**Error Response:**

```json
{
  "success": false,
  "error": "Resource not found",
  "statusCode": 404,
  "timestamp": "2024-11-13T10:30:00.000Z",
  "path": "/api/students/999"
}
```

**Paginated Response:**

```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 50,
    "totalPages": 5
  }
}
```

## 🛡️ Security Features

- **JWT Authentication** - Secure token-based auth with refresh tokens
- **Password Hashing** - bcrypt with configurable rounds
- **Rate Limiting** - ThrottlerModule prevents brute force attacks (100 req/min)
- **CORS Configuration** - Controlled cross-origin access
- **Helmet Middleware** - Security headers for HTTP responses
- **Input Validation** - class-validator on all DTOs
- **SQL Injection Protection** - Prisma parameterized queries
- **XSS Protection** - Sanitized outputs
- **Role-Based Access Control (RBAC)** - Granular permissions via guards
- **Account Security** - Login attempts tracking, account locking
- **Two-Factor Auth Support** - 2FA fields in user model
- **Email/Phone Verification** - Verification status tracking
- **Temporary Password Flow** - Force password change on first login

## 🐛 Troubleshooting

### Database Connection Issues

```bash
# Check PostgreSQL is running
psql --version

# Test connection
psql -h localhost -U username -d edverse

# Regenerate Prisma client
npm run db:generate
```

### Port Already in Use

```bash
# Find process using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or change port in .env
PORT=3001
```

### Prisma Client Errors

```bash
# Clear Prisma cache
rm -rf node_modules/.prisma
rm -rf node_modules/@prisma

# Reinstall
npm install
npm run db:generate
```

### JWT Secret Not Set

```env
# Add to .env
JWT_SECRET="your-secret-key-here-make-it-long-and-random"
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 📊 API Statistics

- **Total Endpoints:** 50+ RESTful endpoints
- **Modules:** 12 feature modules
- **Controllers:** 13 controllers
- **Database Tables:** 50+ with full relationships
- **Authentication:** JWT with role-based access control
- **Validation:** 100% DTOs validated with class-validator

## 🎯 Best Practices Implemented

- ✅ **Modular Architecture** - Clear separation of concerns with NestJS modules
- ✅ **Type Safety** - Full TypeScript implementation with Prisma Client
- ✅ **Error Handling** - Global exception filters and custom exceptions
- ✅ **Input Validation** - DTOs with class-validator decorators
- ✅ **Security First** - JWT, rate limiting, CORS, Helmet
- ✅ **Clean Code** - Consistent naming conventions and structure
- ✅ **Database Migrations** - Version-controlled schema changes
- ✅ **Seed Data** - Comprehensive sample data for testing
- ✅ **Documentation** - Inline comments and README files

## 🔄 Recent Changes (January 2026)

### Phase 1: Database Optimization
- Removed `dashboard_stats`, `attendance_summary`, `performance_metrics`
- These are now computed on-demand for better data accuracy
- Reduced database complexity and maintenance overhead

### Phase 2: Communications Unification
- Merged `notices` and `announcements` into unified `communications` table
- Added comprehensive filtering and querying capabilities
- Implemented read tracking with `communication_read_receipts`
- Support for multiple communication types: NOTICE, ANNOUNCEMENT, ALERT, UPDATE, REMINDER, EVENT
- Priority levels: LOW, MEDIUM, HIGH, URGENT
- Target audience filtering by role
- Emergency flag for critical communications
- Publish and expiry date support

### New API Additions
- ✅ Communications API (8 endpoints)
- ✅ Question Paper Generation API
- ✅ EdVerse ID Generation System
- ✅ Enhanced Student Progress Tracking
- ✅ Staff Management APIs

## 🆘 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/namitthakral/ed-verse/issues)
- **Documentation**: Check this README and inline code documentation
- **Email**: support@edverse.edu

## 🎓 Learn More

- **NestJS Documentation**: https://docs.nestjs.com/
- **Prisma Documentation**: https://www.prisma.io/docs/
- **TypeScript Handbook**: https://www.typescriptlang.org/docs/

---

**Built with ❤️ for educational institutions worldwide**

*Empowering schools, colleges, and universities with modern, scalable technology.*
