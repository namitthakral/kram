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

## 🏗️ Architecture Overview

### NestJS Architecture Components

This backend follows NestJS's modular architecture pattern, which consists of four main components that work together to create a clean, maintainable, and scalable application:

#### 1. **Controllers** (`*.controller.ts`)

**Purpose**: Handle HTTP requests and responses. Act as the entry point for API endpoints.

**Key Features**:

- **Route Definition**: Define API endpoints using decorators like `@Get()`, `@Post()`, `@Patch()`, `@Delete()`
- **Request Handling**: Extract data from request body, parameters, and query strings
- **Authorization**: Implement security using guards like `@UseGuards(JwtAuthGuard, RolesGuard)`
- **Role-based Access**: Control access with `@Roles('admin', 'teacher')` decorators
- **Data Validation**: Use DTOs to validate incoming data

**Example**:

```typescript
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  @Get(':id')
  @UseGuards(RolesGuard)
  @Roles('super_admin', 'admin')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.findOne(id)
  }
}
```

#### 2. **Services** (`*.service.ts`)

**Purpose**: Contain business logic and data manipulation. The "brain" of your application.

**Key Features**:

- **Business Logic**: Implement complex operations like user creation, validation, password hashing
- **Database Operations**: Use Prisma ORM to interact with the database
- **Data Transformation**: Process and format data before returning to controllers
- **Error Handling**: Throw appropriate exceptions (NotFoundException, ConflictException)
- **Security**: Handle password hashing, data sanitization, and validation

**Example**:

```typescript
@Injectable()
export class UsersService {
  async create(createUserDto: CreateUserDto) {
    // Check if email already exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email: createUserDto.email },
    })

    if (existingUser) {
      throw new ConflictException('User with this email already exists')
    }

    // Hash password and create user
    const hashedPassword = await bcrypt.hash(createUserDto.password, 12)
    return this.prisma.user.create({
      data: { ...createUserDto, password: hashedPassword },
    })
  }
}
```

#### 3. **Modules** (`*.module.ts`)

**Purpose**: Organize and configure related components. Define what the module provides and what it needs.

**Key Features**:

- **Dependency Injection**: Register controllers, services, and other providers
- **Imports**: Bring in other modules this module depends on
- **Exports**: Make services available to other modules
- **Encapsulation**: Group related functionality together

**Example**:

```typescript
@Module({
  imports: [PrismaModule], // What this module needs
  controllers: [UsersController], // What controllers it provides
  providers: [UsersService], // What services it provides
  exports: [UsersService], // What it makes available to others
})
export class UsersModule {}
```

#### 4. **DTOs (Data Transfer Objects)** (`*.dto.ts`)

**Purpose**: Define the structure and validation rules for data being transferred between client and server.

**Key Features**:

- **Data Validation**: Use decorators like `@IsEmail()`, `@IsString()`, `@IsOptional()`
- **Type Safety**: Ensure data matches expected structure
- **Documentation**: Serve as a contract for API consumers
- **Transformation**: Transform data between different formats

**Example**:

```typescript
export class CreateUserDto {
  @IsInt()
  roleId: number

  @IsEmail()
  email: string

  @IsString()
  password: string

  @IsOptional()
  @IsString()
  phoneNumber?: string
}
```

### How Components Work Together

```mermaid
graph TD
    A[Client Request] --> B[Controller]
    B --> C[DTO Validation]
    C --> D[Service]
    D --> E[Database via Prisma]
    E --> D
    D --> B
    B --> F[HTTP Response]
    F --> A

    G[Module] --> B
    G --> D
    H[Guards] --> B
    I[Roles] --> B
```

**Request Flow**:

1. **Client** sends HTTP request to `/users`
2. **Controller** receives request, validates route and permissions
3. **Controller** validates incoming data using **DTO** rules
4. **Controller** calls appropriate **Service** method with validated data
5. **Service** performs business logic and database operations
6. **Service** returns processed data to **Controller**
7. **Controller** sends HTTP response back to client

### Benefits of This Architecture

#### 🎯 **Separation of Concerns**

- Each component has a single, well-defined responsibility
- Controllers handle HTTP, services handle business logic, DTOs handle validation
- Easy to locate and modify specific functionality

#### 🔄 **Reusability**

- Services can be used by multiple controllers
- DTOs can be reused across different endpoints
- Modules can be imported and used in other parts of the application

#### 🧪 **Testability**

- Each component can be tested independently
- Easy to mock dependencies for unit testing
- Clear boundaries make integration testing straightforward

#### 🛠️ **Maintainability**

- Changes to business logic don't affect API structure
- Easy to add new features without breaking existing code
- Clear code organization makes debugging easier

#### 🔒 **Type Safety**

- DTOs ensure data integrity and validation
- TypeScript provides compile-time error checking
- Reduces runtime errors and improves developer experience

#### 🚀 **Scalability**

- Modular structure allows for easy feature additions
- Services can be optimized independently
- Clear separation makes it easy to add caching, logging, etc.

#### 🔐 **Security**

- Guards and decorators handle authorization consistently
- DTOs prevent invalid data from reaching business logic
- Centralized security policies across the application

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
