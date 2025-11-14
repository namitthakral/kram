# Ed-verse 🎓

A comprehensive educational management platform built with modern technologies, designed specifically for Indian schools, colleges, and universities.

## 🌟 Key Features

- **Multi-Institution Support** - Manage multiple educational institutions from a single platform
- **Indian Education System** - Built with Indian terminology (courses, subjects, streams)
- **Role-Based Access** - Super Admin, Admin, Teacher, Student, Parent, Librarian, Staff
- **Academic Management** - Complete student lifecycle from admission to graduation
- **Attendance Tracking** - Real-time attendance with analytics
- **Assessment & Grading** - Assignments, examinations, and comprehensive grading system
- **Fee Management** - Fee structures, collections, and payment tracking
- **Library Management** - Book cataloging, issue/return, and reservations
- **Timetable Management** - Automated scheduling with conflict detection
- **Communication Hub** - Notices, announcements, and messaging system
- **Analytics Dashboard** - Comprehensive insights for administrators and teachers

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
│   │   ├── students/          # Student management
│   │   ├── teachers/          # Teacher management
│   │   ├── courses/           # Subjects management (academic papers)
│   │   ├── attendance/        # Attendance tracking
│   │   ├── assignments/       # Assignment management
│   │   ├── examinations/      # Examination system
│   │   ├── fees/              # Fee management
│   │   ├── library/           # Library management
│   │   ├── timetable/         # Scheduling system
│   │   ├── communication/     # Notices & messages
│   │   └── analytics/         # Dashboard & reports
│   ├── prisma/
│   │   ├── schema/            # Modular Prisma schemas
│   │   │   ├── core.prisma
│   │   │   ├── academic.prisma
│   │   │   ├── users.prisma
│   │   │   └── ...
│   │   ├── schema.prisma      # Auto-generated combined schema
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
- ✅ Multi-institution management
- ✅ User role management
- ✅ Course and subject setup
- ✅ Fee structure configuration
- ✅ Academic year & semester management
- ✅ Comprehensive analytics dashboard
- ✅ System-wide notices and announcements

### For Teachers
- ✅ Class attendance marking
- ✅ Assignment creation and grading
- ✅ Examination scheduling
- ✅ Student performance tracking
- ✅ Timetable management
- ✅ Class-specific communication

### For Students
- ✅ View enrolled subjects
- ✅ Check attendance records
- ✅ Submit assignments online
- ✅ View exam schedules and results
- ✅ Fee payment status
- ✅ Library book reservations
- ✅ Digital gate pass requests

### For Parents
- ✅ Monitor child's attendance
- ✅ View academic performance
- ✅ Fee payment tracking
- ✅ Communication with teachers
- ✅ Receive important notices

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
GET    /students            # List all students
GET    /students/:id        # Get student details
POST   /students            # Create student (Admin)
PATCH  /students/:id        # Update student
DELETE /students/:id        # Delete student

Subjects:
GET    /subjects            # List all subjects
GET    /subjects/:id        # Get subject details
GET    /subjects/course/:id # Get subjects for a course
POST   /subjects            # Create subject (Admin)
PATCH  /subjects/:id        # Update subject
DELETE /subjects/:id        # Delete subject

...and many more endpoints
```

See [backend/README.md](backend/README.md) for complete API documentation.

## 🗄️ Database Management

```bash
cd backend

# Generate Prisma client
npm run db:generate

# Push schema changes
npm run db:push

# Create a migration
npm run db:migrate

# Open Prisma Studio (Database GUI)
npm run db:studio

# Reset database
npm run db:reset

# Seed database with sample data
npm run db:seed
```

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

- [Backend API Documentation](backend/README.md)
- [Database Schema Documentation](backend/prisma/README.md)
- [Subjects Module Documentation](backend/src/courses/README.md)
- [Frontend Architecture](frontend/README.md)

## 🔒 Security Features

- **JWT Authentication** with refresh tokens
- **Role-Based Access Control** (RBAC)
- **Password Hashing** with bcrypt
- **Rate Limiting** to prevent abuse
- **CORS Configuration** for secure cross-origin requests
- **Input Validation** at multiple layers
- **SQL Injection Protection** via Prisma ORM
- **XSS Protection** with Helmet middleware

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

---

**Built with ❤️ for Indian educational institutions**

Empowering schools, colleges, and universities with modern technology.
