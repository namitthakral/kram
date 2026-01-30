# Ed-verse 🎓

A comprehensive educational management platform built with modern technologies, designed specifically for Indian schools, colleges, and universities.

## 🌟 Key Features

- **Multi-Institution Support** - Manage multiple educational institutions from a single platform
- **Indian Education System** - Built with Indian terminology (courses, subjects, streams)
- **Role-Based Access** - Super Admin, Admin, Teacher, Student, Parent, Librarian, Staff
- **Academic Management** - Complete student lifecycle from admission to graduation
- **Attendance Tracking** - Real-time attendance with analytics and trends
- **Assessment & Grading** - Assignments, examinations, and comprehensive grading system
- **Fee Management** - Fee structures, collections, and payment tracking
- **Library Management** - Book cataloging, issue/return, and reservations
- **Timetable Management** - Automated scheduling with conflict detection
- **Communications Hub** - Unified communications (notices, announcements, alerts) with read tracking
- **Analytics Dashboard** - Built-in analytics for students, teachers, and administrators
- **EdVerse ID System** - Institution-wide unique ID generation
- **Question Paper Generator** - Automated question paper generation
- **Gate Pass System** - Digital gate pass requests and approvals
- **Staff Management** - Attendance, leave, and assignment tracking for staff

## 🏗️ Technology Stack

### Backend
- **Runtime**: Node.js (v18+)
- **Framework**: NestJS with TypeScript
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT with role-based access control
- **Validation**: class-validator
- **Security**: Helmet, CORS, Rate Limiting

### Frontend
- **Framework**: Flutter (v3.10+)
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Platforms**: Web, Android, iOS

## 🇮🇳 Indian Education System Terminology

This platform uses terminology familiar to Indian educational institutions:

| Term | Meaning | Examples |
|------|---------|----------|
| **Course** | Degree/Stream/Program | B.Sc. Computer Science, Science-Medical, Commerce, Arts |
| **Subject** | Individual Academic Paper | Data Structures, Physics, English, Mathematics |
| **Semester** | Academic Term | Fall 2024, Spring 2025 |
| **Section** | Class Division | Section A, Section B |

### Database Structure
- `courses` table → Degree programs and streams
- `subjects` table → Individual subjects/papers that students study
- `enrollments` → Students enrolled in specific subjects
- `academic_records` → Grades and marks for subjects

## 📁 Project Structure

```
ed-verse/
├── backend/                    # Node.js + NestJS API
│   ├── src/
│   │   ├── auth/              # Authentication & authorization
│   │   ├── users/             # User management
│   │   ├── admin/             # Administrative functions
│   │   ├── students/          # Student management & analytics
│   │   ├── teachers/          # Teacher management, assignments, exams, attendance
│   │   ├── courses/           # Course & subject management
│   │   ├── institutions/      # Institution management
│   │   ├── communications/    # Unified communications (notices, announcements, alerts)
│   │   ├── timetable/         # Scheduling & timetable management
│   │   ├── question-paper/    # Question paper generation
│   │   ├── id-generation/     # EdVerse ID generation system
│   │   ├── prisma/            # Database access layer
│   │   ├── common/            # Shared DTOs and types
│   │   └── utils/             # Utility functions
│   ├── prisma/
│   │   ├── schema/            # Modular Prisma schemas
│   │   │   ├── core.prisma
│   │   │   ├── academic.prisma
│   │   │   ├── users.prisma
│   │   │   ├── communication.prisma
│   │   │   ├── library.prisma
│   │   │   ├── timetable.prisma
│   │   │   └── ...
│   │   ├── schema.prisma      # Auto-generated combined schema
│   │   ├── migrations/        # Database migrations
│   │   └── seed.ts            # Database seeding
│   └── package.json
│
├── frontend/                  # Flutter application
│   ├── lib/
│   │   ├── core/              # Core utilities & constants
│   │   ├── modules/           # Feature modules
│   │   │   ├── admin/
│   │   │   ├── teacher/
│   │   │   ├── student/
│   │   │   └── parent/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── docs/                      # Documentation
└── scripts/                   # Build & deployment scripts
```

## 🚀 Quick Start

### Prerequisites

- **Node.js** v18 or higher
- **npm** v9 or higher
- **PostgreSQL** v12 or higher
- **Flutter** v3.10 or higher (for frontend development)

### 1. Clone the Repository

```bash
git clone https://github.com/namitthakral/ed-verse.git
cd ed-verse
```

### 2. Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your database credentials

# Set up database
npm run db:generate    # Generate Prisma client
npm run db:push        # Apply schema to database
npm run db:seed        # Seed with sample data

# Start development server
npm run dev
```

The backend will be available at `http://localhost:3000`

### 3. Frontend Setup

```bash
cd frontend

# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on mobile (with device/simulator connected)
flutter run
```

## 📝 Sample Accounts

After running the seed script, you can login with these accounts:

```
Super Admin:  admin@edverse.edu      / admin123!
Teacher:      john.doe@edverse.edu   / teacher123!
Students:     student1@edverse.edu   / student123!
              student2@edverse.edu   / student123!
              ...student5@edverse.edu
Parents:      parent1@email.com      / parent123!
              parent2@email.com      / parent123!
              ...parent5@email.com
Librarian:    librarian@edverse.edu  / librarian123!
Staff:        staff@edverse.edu      / staff123!
```

## 🎯 Key Features Breakdown

### For Administrators
- ✅ Multi-institution management with unique institution codes
- ✅ User and role management
- ✅ Course and subject setup
- ✅ Fee structure configuration
- ✅ Academic year & semester management
- ✅ EdVerse ID configuration and generation
- ✅ Comprehensive analytics dashboard
- ✅ System-wide communications (notices, announcements, alerts)
- ✅ Staff management and assignments

### For Teachers
- ✅ Class attendance marking (individual & bulk)
- ✅ Assignment creation, management, and grading
- ✅ Examination scheduling and result entry
- ✅ Student performance tracking and analytics
- ✅ At-risk student identification
- ✅ Report card generation
- ✅ Subject performance analytics
- ✅ Grade distribution insights
- ✅ Class-specific communications

### For Students
- ✅ View enrolled subjects and schedules
- ✅ Check attendance records and history
- ✅ Submit assignments online
- ✅ View exam schedules and results
- ✅ Fee payment status tracking
- ✅ Academic performance trends
- ✅ Digital gate pass requests
- ✅ Receive communications (notices, announcements)

### For Parents
- ✅ Monitor child's attendance
- ✅ View academic performance and progress
- ✅ Fee payment tracking
- ✅ Gate pass approval workflow
- ✅ Receive important communications
- ✅ View report cards

## 🔌 API Documentation

The backend API follows RESTful conventions:

```
Base URL: http://localhost:3000/api

Authentication:
POST   /auth/login          # User login
POST   /auth/register       # User registration
POST   /auth/refresh        # Refresh token
GET    /auth/profile        # Get user profile

Students:
GET    /students                    # List all students
GET    /students/:uuid              # Get student details
GET    /students/:uuid/assignments  # Get student assignments
GET    /students/:uuid/attendance   # Get attendance history
GET    /students/:uuid/dashboard-stats  # Dashboard analytics
PATCH  /students/:uuid              # Update student
DELETE /students/:uuid              # Delete student

Teachers:
GET    /teachers/:uuid              # Get teacher details
GET    /teachers/:uuid/subjects     # Get assigned subjects
GET    /teachers/:uuid/assignments  # Manage assignments
GET    /teachers/:uuid/examinations # Manage examinations
POST   /teachers/:uuid/attendance   # Mark attendance
GET    /teachers/:uuid/dashboard-stats  # Dashboard analytics

Courses & Subjects:
GET    /courses                     # List all courses
GET    /subjects                    # List all subjects
GET    /subjects/course/:id         # Get subjects for a course
POST   /subjects                    # Create subject (Admin)
PATCH  /subjects/:id                # Update subject
DELETE /subjects/:id                # Delete subject

Communications:
POST   /communications              # Create communication
GET    /communications              # List with filtering
GET    /communications/unread       # Get unread
POST   /communications/:id/read     # Mark as read
GET    /communications/:id/stats    # Read statistics

...and many more endpoints (50+ total)
```

See [backend/README.md](backend/README.md) for complete API documentation.

## 🗄️ Database Management

```bash
cd backend

# Build combined schema from modular files
npm run build:schema

# Generate Prisma client (after schema changes)
npm run db:generate

# Push schema changes (development)
npm run db:push

# Create a migration
npm run db:migrate

# Apply migrations (production)
npx prisma migrate deploy

# Open Prisma Studio (Database GUI)
npm run db:studio

# Reset database (WARNING: Deletes all data!)
npm run db:reset

# Seed database with sample data
npm run db:seed
```

### Database Features

- **50+ Tables** - Comprehensive data model for educational institutions
- **Modular Schema** - Organized into logical files for maintainability
- **Type-Safe** - Full TypeScript support via Prisma Client
- **Migrations** - Version-controlled database schema changes
- **Relationships** - Complex foreign key relationships and cascades
- **Enums** - Type-safe enumerations for status, roles, types
- **Indexes** - Optimized queries with strategic indexing
- **Unique Constraints** - Data integrity enforcement

## 🧪 Testing

### Backend Tests
```bash
cd backend
npm test                 # Run all tests
npm run test:watch      # Watch mode
npm run test:cov        # With coverage
```

### Frontend Tests
```bash
cd frontend
flutter test            # Run all tests
flutter test --coverage # With coverage
```

## 🚀 Deployment

### Backend Deployment

1. **Build for production:**
   ```bash
   cd backend
   npm run build
   ```

2. **Set environment variables:**
   - `NODE_ENV=production`
   - `DATABASE_URL=<production-db-url>`
   - `JWT_SECRET=<strong-secret>`
   - `PORT=3000`

3. **Start production server:**
   ```bash
   npm start
   ```

### Frontend Deployment

**Web:**
```bash
cd frontend
flutter build web
# Deploy the build/web folder to your hosting service
```

**Android:**
```bash
flutter build apk --release
# Find APK in build/app/outputs/flutter-apk/
```

**iOS:**
```bash
flutter build ios --release
# Build and archive using Xcode
```

## 📚 Documentation

### Available Documentation

- **[Backend API Documentation](backend/README.md)** - Complete API reference with all endpoints
- **[Database Schema Documentation](backend/MIGRATIONS.md)** - Migration history and schema evolution
- **[Communications Module](backend/src/communications/)** - Unified communications API
- **Frontend Architecture** - Flutter app documentation (coming soon)

### Key Features Documentation

Each major feature is documented inline in the codebase:
- **Authentication** - JWT strategy, guards, decorators (`src/auth/`)
- **EdVerse ID Generation** - Unique ID system (`src/id-generation/`)
- **Student Progress Tracking** - Grading and progress calculation (`src/students/utils/`)
- **Communications System** - Notices, announcements, alerts (`src/communications/`)
- **Question Paper Generation** - Automated paper creation (`src/question-paper/`)

## 🔒 Security Features

- **JWT Authentication** with refresh tokens and automatic expiry
- **Role-Based Access Control (RBAC)** - 7 distinct roles with granular permissions
- **Password Hashing** with bcrypt (configurable rounds)
- **Rate Limiting** to prevent brute force attacks (ThrottlerModule)
- **CORS Configuration** for secure cross-origin requests
- **Input Validation** at multiple layers via class-validator
- **SQL Injection Protection** via Prisma ORM parameterized queries
- **XSS Protection** with Helmet middleware
- **Account Security** - Login attempts tracking, account locking, 2FA support
- **Email/Phone Verification** - Verification workflow for user accounts
- **Temporary Password Flow** - Force password change on first login

## 🛠️ Development Tools

### Backend Development
```bash
npm run dev           # Start with hot reload
npm run lint          # Check code quality
npm run lint:fix      # Auto-fix linting issues
npm run format        # Format code with Prettier
npm run build         # Build for production
```

### Frontend Development
```bash
flutter run           # Run in debug mode
flutter analyze       # Static analysis
flutter format .      # Format Dart code
flutter clean         # Clean build artifacts
```

## 🐛 Troubleshooting

### Database Issues
```bash
# If Prisma client is out of sync
npm run db:generate

# If schema doesn't match database
npm run db:push

# If you want to start fresh
npm run db:reset
```

### Port Conflicts
If port 3000 is already in use, change it in `.env`:
```env
PORT=3001
```

### Flutter Issues
```bash
# Clear Flutter cache
flutter clean
flutter pub get

# Update Flutter
flutter upgrade
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/namitthakral/ed-verse/issues)
- **Documentation**: Check the `docs/` folder
- **Email**: support@edverse.edu

## 📊 Project Statistics

- **Backend:**
  - 50+ database tables with comprehensive relationships
  - 12 feature modules with clear separation of concerns
  - 50+ API endpoints (RESTful)
  - 13 controllers handling different domains
  - Modular Prisma schema (10+ files)
  - Type-safe with TypeScript throughout

- **Database:**
  - PostgreSQL with Prisma ORM
  - Version-controlled migrations
  - Comprehensive seed data for testing
  - Optimized with indexes and relationships

## 🚦 Current Status

**Backend:** ✅ Production-ready
- All core modules implemented
- Authentication & authorization complete
- Database schema stable and optimized
- API endpoints documented and tested

**Frontend:** 🚧 In Development
- Flutter web app structure in place
- Mock data being used for development
- API integration in progress

## 📝 Recent Updates (January 2026)

### Database Optimization
- ✅ Removed redundant analytics tables (computed on-the-fly instead)
- ✅ Unified communications system (merged notices & announcements)
- ✅ Improved query performance with strategic indexes

### New Features
- ✅ Communications API with read tracking
- ✅ EdVerse ID generation system
- ✅ Question paper generator
- ✅ Comprehensive student progress tracking
- ✅ Staff management module

---

**Built with ❤️ for Indian educational institutions**

Empowering schools, colleges, and universities with modern technology.
