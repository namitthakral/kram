# Frontend API Models - Case Handling Rules

## CRITICAL: API Response Case Compatibility

**MANDATORY: All API model `fromJson` methods must handle both camelCase and snake_case keys.**

### Background
The backend uses a `CaseTransformInterceptor` that converts database snake_case to camelCase in API responses. However, to ensure maximum compatibility and prevent future issues, all frontend models should support both formats.

### Required Pattern

```dart
// ✅ CORRECT - Supports both formats
factory MyModel.fromJson(Map<String, dynamic> json) => MyModel(
  totalStudents: (json['totalStudents'] ?? json['total_students']) as int? ?? 0,
  activeStudents: (json['activeStudents'] ?? json['active_students']) as int? ?? 0,
  feeCollection: _parseDouble(json['feeCollection'] ?? json['fee_collection']),
);

// ❌ WRONG - Only supports one format
factory MyModel.fromJson(Map<String, dynamic> json) => MyModel(
  totalStudents: json['totalStudents'] as int? ?? 0,
  activeStudents: json['activeStudents'] as int? ?? 0,
  feeCollection: _parseDouble(json['feeCollection']),
);
```

### Common Field Mappings

| Field Type | camelCase | snake_case |
|------------|-----------|------------|
| totalStudents | `totalStudents` | `total_students` |
| activeStudents | `activeStudents` | `active_students` |
| totalTeachers | `totalTeachers` | `total_teachers` |
| totalClasses | `totalClasses` | `total_classes` |
| attendanceRate | `attendanceRate` | `attendance_rate` |
| feeCollection | `feeCollection` | `fee_collection` |
| pendingFees | `pendingFees` | `pending_fees` |
| teacherPerformance | `teacherPerformance` | `teacher_performance` |
| attendanceTrends | `attendanceTrends` | `attendance_trends` |
| gradeDistribution | `gradeDistribution` | `grade_distribution` |
| classPerformance | `classPerformance` | `class_performance` |
| financialOverview | `financialOverview` | `financial_overview` |
| systemAlerts | `systemAlerts` | `system_alerts` |
| teacherName | `teacher` or `teacherName` | `teacher_name` |
| avgGrade | `avgGrade` | `avg_grade` |
| studentCount | `studentCount` | `student_count` |
| actualAttendance | `actualAttendance` | `actual_attendance` |
| targetAttendance | `targetAttendance` | `target_attendance` |

### Implementation Guidelines

1. **Always use fallback pattern**: `json['camelCase'] ?? json['snake_case']`
2. **For nested objects**: Apply the same pattern to all nested model lists
3. **For arrays**: `(json['camelCase'] ?? json['snake_case']) as List<dynamic>?`
4. **Test both formats**: Ensure your models work with both API response formats

### Files Already Updated
- ✅ `/frontend/lib/modules/admin/models/admin_dashboard_models.dart` - Full compatibility
- ✅ `/frontend/lib/modules/fees/models/` - All fee models already have compatibility
- ✅ `/frontend/lib/models/auth_models.dart` - Uses camelCase consistently (matches API)
- ✅ `/frontend/lib/modules/teacher/models/dashboard_stats.dart` - Uses camelCase consistently

### Before Creating New Models
1. Check the actual API response format using curl or network inspector
2. Implement fallback pattern for all fields that could be in either format
3. Test with both camelCase and snake_case mock data

### Error Prevention
This pattern prevents UI display issues where:
- API returns correct data but UI shows 0s or empty values
- Backend changes case transformation logic
- Different endpoints use different case formats
- Database migrations affect field naming

**Remember: It's better to be compatible with both formats than to assume one format will always be used.**