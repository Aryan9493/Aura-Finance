import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'smart_notifications_provider.g.dart';

class SmartNotification {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final DateTime timestamp;

  SmartNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.timestamp,
  });
}

@riverpod
class SmartNotifications extends _$SmartNotifications {
  @override
  List<SmartNotification> build() {
    return [];
  }

  void addNotification(SmartNotification notification) {
    // Avoid duplicates by title
    if (state.any((n) => n.title == notification.title)) return;
    state = [notification, ...state];
  }

  void dismissNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}
