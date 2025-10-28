/// Utility functions for user-related operations
class UserUtils {
  /// Extracts initials from a user's name
  /// Examples:
  /// - "John Doe" -> "JD"
  /// - "Alex Johnson" -> "AJ"
  /// - "Maria" -> "M"
  /// - "John Paul Smith" -> "JS" (first and last)
  static String getInitials(String name) {
    if (name.isEmpty) {
      return '';
    }

    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      // Single name - return first character
      return parts[0][0].toUpperCase();
    } else {
      // Multiple names - return first character of first and last name
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
  }

  /// Gets a formatted role display string
  static String formatRole(String roleName) => roleName
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}
