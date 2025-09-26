# Ed-verse Backend API

A comprehensive Node.js TypeScript backend for the Ed-verse educational platform, built with Express.js and Prisma ORM.

## 🚀 Features

- **Authentication & Authorization** - JWT-based auth with role-based access control
- **Student Management** - Complete student lifecycle management
- **Teacher Management** - Faculty and course management
- **Course Management** - Academic course and program management
- **Institution Management** - Multi-institution support
- **Database Integration** - PostgreSQL with Prisma ORM
- **API Validation** - Joi-based request validation
- **Security** - Rate limiting, CORS, Helmet security headers
- **TypeScript** - Full type safety and IntelliSense support

## 📋 Prerequisites

- Node.js (v18+)
- npm (v9+)
- PostgreSQL (v12+)
- Git

## 🛠️ Installation

1. **Install dependencies:**

   ```bash
   npm install
   ```

2. **Set up environment variables:**

   ```bash
   cp .env.example .env
   ```

   Edit `.env` with your configuration:

   ```env
   # Database
   DATABASE_URL="postgresql://username:password@localhost:5432/edverse_db"

   # Server
   PORT=3000
   NODE_ENV=development

   # JWT
   JWT_SECRET="your-super-secret-jwt-key-here"

   # Email (optional)
   SMTP_HOST="smtp.gmail.com"
   SMTP_PORT=587
   SMTP_USER="your-email@gmail.com"
   SMTP_PASS="your-app-password"
   ```

3. **Set up the database:**

   ```bash
   # Generate Prisma client
   npm run db:generate

   # Push schema to database
   npm run db:push

   # Seed the database with sample data
   npm run db:seed
   ```

4. **Start the development server:**
   ```bash
   npm run dev
   ```

## 📊 Database Schema

The backend uses a comprehensive database schema designed for educational institutions:

### Core Entities

- **Users** - Authentication and user management
- **Roles** - Role-based access control
- **Institutions** - Multi-institution support
- **Departments** - Academic departments
- **Programs** - Degree programs and courses of study
- **Courses** - Individual academic courses

### Academic Management

- **Students** - Student profiles and academic records
- **Teachers** - Faculty profiles and teaching assignments
- **Parents** - Parent/guardian information
- **Enrollments** - Student course enrollments
- **ClassSections** - Course sections and scheduling
- **Attendance** - Student attendance tracking

### Assessment & Grading

- **Examinations** - Exam scheduling and management
- **ExamResults** - Student exam results
- **AcademicRecords** - Comprehensive academic history
- **Assignments** - Course assignments and projects
- **Submissions** - Student assignment submissions

## 🔌 API Endpoints

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/change-password` - Change password
- `POST /api/auth/forgot-password` - Request password reset
- `GET /api/auth/profile` - Get current user profile
- `POST /api/auth/logout` - User logout

### Students

- `GET /api/students` - Get all students (Admin/Teacher)
- `GET /api/students/:id` - Get student by ID
- `POST /api/students` - Create new student (Admin)
- `PUT /api/students/:id` - Update student (Admin)
- `DELETE /api/students/:id` - Delete student (Admin)
- `GET /api/students/:id/academic-records` - Get student's academic records
- `GET /api/students/:id/attendance` - Get student's attendance

### Health Check

- `GET /health` - Server health status
- `GET /api` - API information and available endpoints

## 🔐 Authentication

The API uses JWT (JSON Web Tokens) for authentication:

1. **Register/Login** to get access and refresh tokens
2. **Include token** in Authorization header: `Bearer <token>`
3. **Refresh token** when access token expires

### Sample Request:

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@edverse.edu",
    "password": "admin123!"
  }'
```

### Sample Authenticated Request:

```bash
curl -X GET http://localhost:3000/api/students \
  -H "Authorization: Bearer <your-jwt-token>"
```

## 🧪 Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test -- --coverage
```

## 📝 Code Quality

```bash
# Lint code
npm run lint

# Fix linting issues
npm run lint:fix

# Type check
npx tsc --noEmit
```

## 🗄️ Database Management

```bash
# Generate Prisma client
npm run db:generate

# Push schema changes
npm run db:push

# Create migration
npm run db:migrate

# Reset database
npm run db:reset

# Open Prisma Studio
npm run db:studio

# Seed database
npm run db:seed
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

- Set `NODE_ENV=production`
- Use strong `JWT_SECRET`
- Configure production database URL
- Set up proper CORS origins
- Configure rate limiting appropriately

## 📚 API Documentation

### Response Format

All API responses follow this format:

```json
{
  "success": boolean,
  "data": any,
  "message": string,
  "error": string,
  "pagination": {
    "page": number,
    "limit": number,
    "total": number,
    "totalPages": number
  }
}
```

### Error Handling

- **400** - Bad Request (validation errors)
- **401** - Unauthorized (invalid/missing token)
- **403** - Forbidden (insufficient permissions)
- **404** - Not Found
- **429** - Too Many Requests (rate limited)
- **500** - Internal Server Error

## 🔧 Development

### Project Structure

```
src/
├── controllers/     # Route controllers
├── middleware/      # Express middleware
├── routes/          # API routes
├── services/        # Business logic
├── types/           # TypeScript types
├── utils/           # Utility functions
├── database/        # Database client
└── index.ts         # Application entry point
```

### Adding New Features

1. Define types in `src/types/`
2. Create service in `src/services/`
3. Add routes in `src/routes/`
4. Update main router in `src/index.ts`
5. Add tests in `tests/`

## 🐛 Troubleshooting

### Common Issues

1. **Database Connection Error**

   - Check PostgreSQL is running
   - Verify DATABASE_URL in .env
   - Ensure database exists

2. **JWT Secret Error**

   - Set JWT_SECRET in .env
   - Use a strong, random secret

3. **Port Already in Use**

   - Change PORT in .env
   - Kill process using the port

4. **Prisma Client Error**
   - Run `npm run db:generate`
   - Check schema syntax

### Debug Mode

```bash
DEBUG=* npm run dev
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Run linting and tests
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

- Check the [Issues](https://github.com/namitthakral/ed-verse/issues) page
- Create a new issue for bugs or feature requests
- Refer to [Prisma documentation](https://www.prisma.io/docs)
- Refer to [Express.js documentation](https://expressjs.com/)

---

Built with ❤️ for educational institutions worldwide.
