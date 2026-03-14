import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../core/services/communications_service.dart';
import '../../core/services/local_notification_service.dart';
import '../../models/communication_model.dart';

class CommunicationsProvider extends ChangeNotifier {
  final CommunicationsService _communicationsService = CommunicationsService();
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  List<Communication> _unreadCommunications = [];
  List<Communication> _allCommunications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;
  int? _lastKnownMessageId;

  List<Communication> get unreadCommunications => _unreadCommunications;
  List<Communication> get allCommunications => _allCommunications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Start polling for notifications
  void startPolling({int? institutionId}) {
    // Poll immediately
    _fetchUnread(institutionId: institutionId);

    // Cancel existing timer if any
    stopPolling();

    // Poll every 60 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _fetchUnread(institutionId: institutionId);
    });
  }

  /// Stop polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Initialize local notifications
  Future<void> initLocalNotifications() async {
    await _localNotificationService.init();
    await _localNotificationService.requestPermissions();
  }

  /// Fetch unread communications
  Future<void> _fetchUnread({int? institutionId}) async {
    try {
      final messages = await _communicationsService.getUnreadCommunications(
        institutionId: institutionId,
      );

      _unreadCommunications = messages;
      _unreadCount = messages.length;
      notifyListeners();

      // Check for new messages to trigger local notification
      if (messages.isNotEmpty) {
        // Sort by id descending to get latest
        messages.sort((a, b) => b.id.compareTo(a.id));
        final latestMessage = messages.first;

        if (_lastKnownMessageId != null &&
            latestMessage.id > _lastKnownMessageId!) {
          // New message detected
          _localNotificationService.showNotification(
            id: latestMessage.id,
            title: latestMessage.title,
            body: latestMessage.content,
            payload: '/notifications',
          );
        } else if (_lastKnownMessageId == null) {
          // First load, set tracker but don't notify
        }
        _lastKnownMessageId = latestMessage.id;
      }
    } on Exception catch (e) {
      debugPrint('Error in polling unread communications: $e');
    }
  }

  /// Fetch all communications with pagination
  Future<void> fetchAllCommunications({
    int page = 1,
    int limit = 10,
    String? type,
    String? search,
    int? institutionId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _communicationsService.getAllCommunications(
        page: page,
        limit: limit,
        type: type,
        search: search,
        institutionId: institutionId,
      );

      if (response['data'] != null) {
        _allCommunications = response['data'] as List<Communication>;
      } else {
        _allCommunications = [];
      }
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark a communication as read
  Future<void> markAsRead(int id) async {
    final success = await _communicationsService.markAsRead(id);
    if (success) {
      // Remove from unread list locally
      _unreadCommunications.removeWhere((c) => c.id == id);
      _unreadCount = _unreadCommunications.length;

      // Update in all list - we can't modify the object but we can trigger refresh
      // or we can rely on UI to show read state based on local logic if we had mutable models
      // For now, refreshing the list is safests
      await fetchAllCommunications();

      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
