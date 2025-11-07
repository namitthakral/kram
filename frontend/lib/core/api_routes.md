# EdVerse API Routes Reference

This document provides a comprehensive overview of all available API endpoints in the EdVerse application, organized by module.

## Base Configuration

- **Base URL**: Configured in `AppConstants.baseUrl`
- **API Version**: Configured in `AppConstants.apiVersion`
- **Authentication**: Most endpoints require JWT Bearer token (managed automatically by `ApiService`)

## Authentication Endpoints

### Auth Controller (`/auth`)

| Method | Endpoint | Description | Public | Service Location |
|--------|----------|-------------|--------|------------------|
| POST | `/auth/login` | User login | Yes | `auth_service.dart` |
| POST | `/auth/register` | Self-registration | Yes | `auth_service.dart` |
| POST | `/auth/refresh` | Refresh access token | No | `auth_service.dart` |
| POST | `/auth/activate-account` | Activate user account | Yes | `auth_service.dart` |
| POST | `/auth/change-password` | Change user password | No | `auth_service.dart` |
| POST | `/auth/map-parent-child` | Map parent to child | No | `parent_service.dart` |
| GET | `/auth/profile` | Get current user profile | No | `auth_service.dart` |

## Student Endpoints

### Students Controller (`/students`)

All student endpoints are implemented in `lib/modules/student/services/student_service.dart`

| Method | Endpoint | Description | Required Role | Query Parameters |
|--------|----------|-------------|---------------|------------------|
| GET | `/students` | Get all students | admin, teacher | `page`, `limit` |
| GET | `/students/:user_uuid` | Get student by UUID | authenticated | - |
| POST | `/students` | Create new student | admin | - |
| PATCH | `/students/:user_uuid` | Update student | admin | - |
| DELETE | `/students/:user_uuid` | Delete student | admin | - |
| GET | `/students/:user_uuid/academic-records` | Get academic records | authenticated | - |
| GET | `/students/:user_uuid/attendance` | Get attendance data | authenticated | `startDate`, `endDate` |
| GET | `/students/:user_uuid/dashboard-stats` | Get dashboard statistics | authenticated | - |
| GET | `/students/:user_uuid/assignments` | Get assignments | authenticated | `limit`, `status` |
| GET | `/students/:user_uuid/performance-trends` | Get performance trends | authenticated | `startMonth`, `endMonth` |
| GET | `/students/:user_uuid/attendance-history` | Get attendance history | authenticated | `semesterId` |
| GET | `/students/:user_uuid/subject-performance` | Get subject performance | authenticated | - |
| GET | `/students/:user_uuid/upcoming-events` | Get upcoming events | authenticated | `limit` |

### Student Service Methods

```dart
// Example usage:
final studentService = StudentService();

// Get dashboard stats
final stats = await studentService.getDashboardStats(userUuid);

// Get assignments with filters
final assignments = await studentService.getAssignments(
  userUuid,
  limit: 20,
  status: 'pending',
);

// Get attendance with date range
final attendance = await studentService.getAttendance(
  userUuid,
  startDate: '2024-01-01',
  endDate: '2024-12-31',
);
```

## Parent Endpoints

### Parent Service

All parent endpoints are implemented in `lib/modules/parent/services/parent_service.dart`

Parents access their children's data through student endpoints. The backend validates parent-child relationships.

| Method | Endpoint | Description | Service Method |
|--------|----------|-------------|----------------|
| POST | `/auth/map-parent-child` | Map parent to child | `mapParentToChild()` |
| GET | `/students/:user_uuid/dashboard-stats` | Get child's dashboard stats | `getChildDashboardStats()` |
| GET | `/students/:user_uuid/academic-records` | Get child's academic records | `getChildAcademicRecords()` |
| GET | `/students/:user_uuid/attendance` | Get child's attendance | `getChildAttendance()` |
| GET | `/students/:user_uuid/assignments` | Get child's assignments | `getChildAssignments()` |
| GET | `/students/:user_uuid/performance-trends` | Get child's performance trends | `getChildPerformanceTrends()` |
| GET | `/students/:user_uuid/attendance-history` | Get child's attendance history | `getChildAttendanceHistory()` |
| GET | `/students/:user_uuid/subject-performance` | Get child's subject performance | `getChildSubjectPerformance()` |
| GET | `/students/:user_uuid/upcoming-events` | Get child's upcoming events | `getChildUpcomingEvents()` |
| GET | `/students/:user_uuid` | Get child's basic info | `getChildInfo()` |

### Parent Service Methods

```dart
// Example usage:
final parentService = ParentService();

// Map parent to child
await parentService.mapParentToChild('CHILD_EDVERSE_ID');

// Get child's dashboard stats
final stats = await parentService.getChildDashboardStats(childUserUuid);

// Get child's assignments
final assignments = await parentService.getChildAssignments(
  childUserUuid,
  limit: 10,
  status: 'pending',
);
```

## Teacher Endpoints

### Teachers Controller (`/teachers`)

All teacher endpoints are implemented in `lib/modules/teacher/services/teacher_service.dart`

| Method | Endpoint | Description | Required Role | Query Parameters |
|--------|----------|-------------|---------------|------------------|
| GET | `/teachers` | Get all teachers | admin, teacher | `page`, `limit` |
| GET | `/teachers/stats` | Get overall teacher stats | admin | - |
| GET | `/teachers/:user_uuid` | Get teacher by UUID | admin, teacher | - |
| GET | `/teachers/:user_uuid/subjects` | Get teacher's subjects | admin, teacher | `academicYearId` |
| GET | `/teachers/:user_uuid/classes` | Get teacher's classes | admin, teacher | `semesterId` |
| GET | `/teachers/:user_uuid/stats` | Get teacher statistics | admin, teacher | - |
| GET | `/teachers/:user_uuid/dashboard-stats` | Get enhanced dashboard stats | admin, teacher | - |
| GET | `/teachers/:user_uuid/attendance-trends` | Get attendance trends | admin, teacher | - |
| GET | `/teachers/:user_uuid/subject-performance` | Get subject performance | admin, teacher | - |
| GET | `/teachers/:user_uuid/grade-distribution` | Get grade distribution | admin, teacher | - |
| GET | `/teachers/:user_uuid/recent-activity` | Get recent student activity | admin, teacher | `limit` |
| GET | `/teachers/:user_uuid/attendance-summary` | Get attendance summary | admin, teacher | `date`, `period` |
| POST | `/teachers` | Create new teacher | admin | - |
| POST | `/teachers/:user_uuid/assign-subjects` | Assign subjects to teacher | admin | - |
| PATCH | `/teachers/:user_uuid` | Update teacher | admin | - |
| DELETE | `/teachers/:user_uuid` | Delete teacher | admin | - |

### Teacher Service Methods

```dart
// Example usage:
final teacherService = TeacherService();

// Get dashboard stats (returns typed DashboardStats object)
final stats = await teacherService.getDashboardStats(userUuid);

// Get recent activity
final activities = await teacherService.getRecentActivity(
  userUuid,
  limit: 15,
);

// Get attendance summary
final summary = await teacherService.getAttendanceSummary(
  userUuid,
  date: '2024-10-20',
  period: 'daily',
);

// Get teacher's subjects
final subjects = await teacherService.getTeacherSubjects(
  userUuid,
  academicYearId: 2024,
);
```

## Users Endpoints

### Users Controller (`/users`)

| Method | Endpoint | Description | Required Role |
|--------|----------|-------------|---------------|
| GET | `/users` | Get all users | admin |
| GET | `/users/stats` | Get users statistics | admin |
| GET | `/users/role/:roleId` | Get users by role | admin |
| GET | `/users/profile` | Get current user profile | authenticated |
| GET | `/users/:user_uuid` | Get user by UUID | admin |
| PATCH | `/users/profile` | Update current user profile | authenticated |
| PATCH | `/users/:user_uuid` | Update user by UUID | admin |
| DELETE | `/users/:user_uuid` | Soft delete user | admin |
| DELETE | `/users/:user_uuid/hard` | Hard delete user | super_admin |
| POST | `/users` | Create new user | admin |

## Response Formats

### Success Response
```json
{
  "success": true,
  "data": { ... }
}
```

### Error Response
```json
{
  "statusCode": 400,
  "message": "Error message",
  "error": "Bad Request"
}
```

## Error Handling

All service methods include proper error handling:

- **404**: Resource not found
- **401**: Unauthorized (token invalid/expired)
- **403**: Forbidden (insufficient permissions)
- **400**: Bad request (invalid data)
- **500**: Internal server error

Example:
```dart
try {
  final data = await studentService.getDashboardStats(userUuid);
  // Handle success
} catch (e) {
  // Error message is user-friendly and can be displayed
  print(e.toString()); // "Failed to load dashboard stats: ..."
}
```

## Authentication Flow

1. **Login**: User logs in via `/auth/login`
2. **Token Storage**: Access and refresh tokens stored in secure storage
3. **Auto Refresh**: `ApiService` automatically refreshes expired tokens
4. **Token Injection**: Bearer token automatically added to all authenticated requests
5. **Logout**: Clear tokens from secure storage

## Service Organization

```
lib/
├── core/
│   └── services/
│       ├── api_service.dart         # Base API service with Dio
│       └── auth_service.dart        # Authentication methods
├── modules/
│   ├── student/
│   │   └── services/
│   │       └── student_service.dart # Student-specific APIs
│   ├── parent/
│   │   └── services/
│   │       └── parent_service.dart  # Parent-specific APIs
│   └── teacher/
│       └── services/
│           └── teacher_service.dart # Teacher-specific APIs
```

## Best Practices

1. **Use Service Singletons**: All services use singleton pattern
   ```dart
   final service = StudentService(); // Always returns same instance
   ```

2. **Error Handling**: Always wrap API calls in try-catch
   ```dart
   try {
     final data = await service.getData();
   } catch (e) {
     // Show error to user
   }
   ```

3. **Type Safety**: Use proper typing for responses
   ```dart
   Future<Map<String, dynamic>> getData() async { ... }
   Future<List<dynamic>> getList() async { ... }
   ```

4. **Optional Parameters**: Use named optional parameters for filters
   ```dart
   getAssignments(userUuid, {limit = 10, String? status})
   ```

5. **Documentation**: All methods include dartdoc comments
   ```dart
   /// Get student dashboard statistics
   ///
   /// Endpoint: GET /students/:user_uuid/dashboard-stats
   Future<Map<String, dynamic>> getDashboardStats(String userUuid) async
   ```

## Notes

- All routes are prefixed with the base URL and API version
- UUID is used instead of numeric IDs for better security
- Parent access to child data is validated by backend based on parent-child mappings
- Role-based access control is enforced at the backend level
- Automatic token refresh prevents auth interruptions
