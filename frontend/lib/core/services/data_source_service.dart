import '../constants/role_constants.dart';

/// Enum to represent the data source type
enum DataSourceType { api, localDatabase }

/// Service to determine which data source to use based on user role
class DataSourceService {
  factory DataSourceService() => _instance;
  DataSourceService._internal();
  static final DataSourceService _instance = DataSourceService._internal();

  // Current data source type
  DataSourceType _currentDataSource = DataSourceType.api;

  /// Get the current data source type
  DataSourceType get currentDataSource => _currentDataSource;

  /// Determine data source based on role ID
  DataSourceType getDataSourceForRole(int roleId) {
    final role = RoleConstants.getRoleById(roleId);
    if (role != null && role.usesLocalDatabase) {
      return DataSourceType.localDatabase;
    }
    return DataSourceType.api;
  }

  /// Set the current data source based on role ID
  void setDataSourceByRole(int roleId) {
    _currentDataSource = getDataSourceForRole(roleId);
  }

  /// Check if current data source is local database
  bool get isUsingLocalDatabase =>
      _currentDataSource == DataSourceType.localDatabase;

  /// Check if current data source is API
  bool get isUsingApi => _currentDataSource == DataSourceType.api;

  /// Reset to default (API)
  void resetToDefault() {
    _currentDataSource = DataSourceType.api;
  }

  /// Get data source description for logging/debugging
  String getDataSourceDescription() {
    switch (_currentDataSource) {
      case DataSourceType.api:
        return 'API Server';
      case DataSourceType.localDatabase:
        return 'Local SQLite Database';
    }
  }
}
