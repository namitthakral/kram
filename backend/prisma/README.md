# Prisma Schema Organization

This project uses a **multi-file schema approach** for better organization and maintainability.

## 📁 File Structure

```
prisma/
├── schema.prisma          # Main schema file (auto-generated)
├── schema/                # Individual schema files
│   ├── core.prisma        # User, Role, Institution
│   ├── academic.prisma    # AcademicYear, Semester, Program, Course
│   ├── users.prisma       # Student, Teacher, Parent, Staff
│   ├── records.prisma     # AcademicRecord, Attendance, Enrollment
│   ├── assessment.prisma  # Examination, Assignment, Submission
│   ├── fees.prisma        # FeeStructure, StudentFee, Payment
│   ├── communication.prisma # Notice, Message, Announcement
│   ├── library.prisma     # Book, BookIssue, LibraryTransaction
│   ├── staff.prisma       # Staff, StaffAttendance, StaffLeave
│   ├── gatepass.prisma    # GatePass, VisitorPass
│   ├── timetable.prisma   # TimeTable, TimeSlot, Subject
│   └── analytics.prisma   # StudentProgress, DashboardStats
└── seed.ts               # Database seeding
```

## 🔧 How It Works

1. **Individual Files**: Each schema file contains related models and enums
2. **Build Script**: `scripts/build-schema.js` combines all files into `schema.prisma`
3. **Auto-Generation**: All Prisma commands automatically run the build script first

## 📝 Usage

### Adding New Models

1. **Edit the appropriate individual file** in `/prisma/schema/`
2. **Run the build command**:
   ```bash
   npm run build:schema
   ```
3. **Generate Prisma client**:
   ```bash
   npm run db:generate
   ```

### Available Commands

```bash
# Build schema from individual files
npm run build:schema

# Generate Prisma client (includes build)
npm run db:generate

# Push schema to database (includes build)
npm run db:push

# Run migrations (includes build)
npm run db:migrate

# Open Prisma Studio
npm run db:studio

# Seed the database
npm run db:seed
```

## 🎯 Benefits

- ✅ **Better Organization**: Related models grouped together
- ✅ **Easier Maintenance**: Smaller, focused files
- ✅ **Team Collaboration**: Multiple developers can work on different modules
- ✅ **Version Control**: Cleaner diffs and easier code reviews
- ✅ **Scalability**: Easy to add new modules without cluttering

## ⚠️ Important Notes

- **Always edit individual files** in `/prisma/schema/`, not `schema.prisma`
- **The main `schema.prisma` is auto-generated** and will be overwritten
- **Run `npm run build:schema`** after making changes to individual files
- **All Prisma commands automatically build** the schema first

## 🔄 Workflow

1. Make changes to individual schema files
2. Run `npm run build:schema` (or any db command)
3. Test with `npm run db:generate`
4. Commit both individual files and generated schema
