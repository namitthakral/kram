import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that provides secure storage operations.
///
/// On mobile/desktop: Uses flutter_secure_storage for encrypted storage
/// On web: Falls back to shared_preferences (local storage)
///
/// This class is implemented as a singleton to ensure only one instance exists
/// throughout the application, optimizing resource usage.
class SecureStorageService {
  // Factory constructor to return the singleton instance
  factory SecureStorageService() => _instance;

  // Private constructor for singleton pattern
  SecureStorageService._internal();

  // Singleton instance
  static final SecureStorageService _instance =
      SecureStorageService._internal();

  // Instance of flutter_secure_storage with optimized settings (mobile/desktop)
  FlutterSecureStorage? _storage;

  // SharedPreferences instance for web
  SharedPreferences? _prefs;

  // Flag to check if running on web
  final bool _isWeb = kIsWeb;

  // Cache to minimize disk I/O operations
  final Map<String, String> _cache = {};

  // Initialize storage based on platform
  Future<void> _initStorage() async {
    if (_isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
    } else {
      _storage ??= const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
          resetOnError: true,
        ),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );
    }
  }

  /// Stores a value securely.
  ///
  /// Stores in both the secure storage and the memory cache.
  Future<void> write(String key, String value) async {
    await _initStorage();

    if (_isWeb) {
      await _prefs!.setString(key, value);
    } else {
      await _storage!.write(key: key, value: value);
    }

    _cache[key] = value; // Update cache
  }

  /// Reads a value securely.
  ///
  /// Attempts to read from cache first, then falls back to secure storage.
  Future<String?> read(String key) async {
    // Try to get from cache first
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    await _initStorage();

    // If not in cache, get from storage and update cache
    final String? value;
    if (_isWeb) {
      value = _prefs!.getString(key);
    } else {
      value = await _storage!.read(key: key);
    }

    if (value != null) {
      _cache[key] = value;
    }
    return value;
  }

  /// Deletes a value.
  Future<void> delete(String key) async {
    await _initStorage();

    if (_isWeb) {
      await _prefs!.remove(key);
    } else {
      await _storage!.delete(key: key);
    }

    _cache.remove(key); // Update cache
  }

  /// Clears all stored values.
  Future<void> deleteAll() async {
    await _initStorage();

    if (_isWeb) {
      // Get all keys that belong to our app (if you have a prefix)
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        await _prefs!.remove(key);
      }
    } else {
      await _storage!.deleteAll();
    }

    _cache.clear(); // Clear cache
  }

  /// Checks if a key exists.
  ///
  /// Optimized to check cache first before disk access.
  Future<bool> containsKey(String key) async {
    if (_cache.containsKey(key)) {
      return true;
    }

    await _initStorage();

    if (_isWeb) {
      return _prefs!.containsKey(key);
    } else {
      final value = await _storage!.read(key: key);
      return value != null;
    }
  }

  /// Gets all stored keys.
  Future<Map<String, String>> readAll() async {
    await _initStorage();

    final Map<String, String> allValues;
    if (_isWeb) {
      allValues = {};
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        final value = _prefs!.getString(key);
        if (value != null) {
          allValues[key] = value;
        }
      }
    } else {
      allValues = await _storage!.readAll();
    }

    // Update cache with all values
    _cache.addAll(allValues);
    return allValues;
  }

  /// Batch write operation for better performance
  /// when storing multiple values.
  Future<void> writeMultiple(Map<String, String> values) async {
    await _initStorage();

    if (_isWeb) {
      for (final entry in values.entries) {
        await _prefs!.setString(entry.key, entry.value);
      }
    } else {
      // Use Future.wait to perform operations in parallel
      await Future.wait(
        values.entries.map(
          (entry) => _storage!.write(key: entry.key, value: entry.value),
        ),
      );
    }

    // Update cache
    _cache.addAll(values);
  }

  /// Refreshes the cache from secure storage.
  /// Useful after app restarts or when cache might be stale.
  Future<void> refreshCache() async {
    final allValues = await readAll();
    _cache
      ..clear()
      ..addAll(allValues);
  }
}
