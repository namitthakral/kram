# Ed-verse Backend API

A comprehensive NestJS-based backend API for educational institution management, built with TypeScript, Prisma ORM, and PostgreSQL. Designed specifically for Indian schools, colleges, and universities.

## 🚀 Features

### Core Functionality
- **🔐 Authentication & Authorization** - JWT-based auth with role-based access control (RBAC)
- **👥 Multi-Institution Support** - Manage multiple schools/colleges from one platform
- **🎓 Academic Management** - Complete student lifecycle from admission to graduation
- **📚 Subject Management** - Handle courses (degree programs) and subjects (academic papers)
- **📊 Attendance Tracking** - Real-time attendance with analytics and reports
- **📝 Assessment System** - Assignments, examinations, and grading
- **💰 Fee Management** - Fee structures, collections, payment tracking
- **📖 Library System** - Book management, issue/return, reservations
- **🗓️ Timetable Scheduling** - Automated timetable with conflict detection
- **💬 Communication Hub** - Notices, announcements, messaging
- **📈 Analytics Dashboard** - Comprehensive insights and reports

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
│   ├── guards/            # Auth guards (JWT, Roles)
│   ├── decorators/        # Custom decorators
│   ├── strategies/        # Passport strategies
│   └── dto/              # Auth DTOs
│
├── users/                 # User management
│   ├── users.controller.ts
│   ├── users.service.ts
│   ├── users.module.ts
│   └── dto/
│
├── students/              # Student management
├── teachers/              # Teacher management
├── courses/               # Subject management (academic papers)
├── attendance/            # Attendance tracking
├── assignments/           # Assignment system
├── examinations/          # Examination system
├── fees/                  # Fee management
├── library/               # Library system
├── timetable/             # Scheduling
├── communication/         # Notices & messages
├── analytics/             # Dashboard & reports
│
├── prisma/                # Database
│   ├── prisma.module.ts
│   └── prisma.service.ts
│
├── common/                # Shared resources
│   ├── filters/           # Exception filters
│   ├── interceptors/      # Response interceptors
│   └── pipes/            # Validation pipes
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

#### **Administration**
- `fee_structures` - Fee definitions by course
- `student_fees` - Individual student fee records
- `payments` - Fee payment transactions
- `books` - Library book catalog
- `book_issues` - Book issue/return records
- `timetables` - Class schedules
- `notices` - Important notices
- `announcements` - General announcements

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

### Assignments

```
GET    /api/assignments            List assignments
GET    /api/assignments/:id        Get assignment details
POST   /api/assignments            Create assignment (Teacher)
PATCH  /api/assignments/:id        Update assignment
DELETE /api/assignments/:id        Delete assignment
POST   /api/assignments/:id/submit Submit assignment (Student)
```

### Examinations

```
GET    /api/examinations           List exams
GET    /api/examinations/:id       Get exam details
POST   /api/examinations           Create exam (Admin/Teacher)
PATCH  /api/examinations/:id       Update exam
DELETE /api/examinations/:id       Delete exam
POST   /api/examinations/:id/results    Post exam results
```

### Health Check

```
GET    /health                     Server health status
GET    /api                        API information
```

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
- 1 Course (B.Sc. Computer Science)
- 3 Subjects (Programming, Data Structures, Web Development)
- 5 Students with enrollments
- 1 Teacher with subject assignments
- 2 Class sections
- Sample attendance records
- Sample assignments and exams
- Fee structures
- Library books
- Notices and announcements

## 🗄️ Database Commands

```bash
# Build combined schema from modular files
npm run build:schema

# Generate Prisma client
npm run db:generate

# Push schema to database (no migrations)
npm run db:push

# Create a new migration
npm run db:migrate

# Reset database (WARNING: Deletes all data!)
npm run db:reset

# Open Prisma Studio (Database GUI)
npm run db:studio

# Seed database with sample data
npm run db:seed
```

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

- **JWT Authentication** - Secure token-based auth
- **Password Hashing** - bcrypt with 12 rounds
- **Rate Limiting** - Prevent brute force attacks
- **CORS Configuration** - Controlled cross-origin access
- **Helmet Middleware** - Security headers
- **Input Validation** - class-validator on all inputs
- **SQL Injection Protection** - Prisma parameterized queries
- **XSS Protection** - Sanitized outputs
- **Role-Based Access** - Granular permissions

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

## 🆘 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/namitthakral/ed-verse/issues)
- **Documentation**: Check the `/docs` folder
- **Email**: support@edverse.edu

---

**Built with ❤️ for educational institutions worldwide**
