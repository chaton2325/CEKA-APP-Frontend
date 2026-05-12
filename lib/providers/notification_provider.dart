import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService;
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  NotificationProvider(this._apiService);

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications({bool? unreadOnly}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getNotifications(unreadOnly: unreadOnly);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _notifications = (data['notifications'] as List)
            .map((n) => NotificationModel.fromJson(n))
            .toList();
        _unreadCount = data['unread_count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Fetch notifications error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.markNotificationAsRead(notificationId);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedNotification = NotificationModel.fromJson(data['notification']);
        
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = updatedNotification;
          if (_unreadCount > 0) _unreadCount--;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Mark notification as read error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _apiService.markAllNotificationsAsRead();
      if (response.statusCode == 200) {
        for (var i = 0; i < _notifications.length; i++) {
          if (!_notifications[i].isRead) {
            _notifications[i] = NotificationModel(
              id: _notifications[i].id,
              type: _notifications[i].type,
              actor: _notifications[i].actor,
              postId: _notifications[i].postId,
              commentId: _notifications[i].commentId,
              isRead: true,
              createdAt: _notifications[i].createdAt,
            );
          }
        }
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Mark all notifications as read error: $e');
    }
  }
}
