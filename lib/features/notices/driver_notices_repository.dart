import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/driver_api_client.dart';

class DriverNoticeItem {
  const DriverNoticeItem({
    required this.id,
    required this.title,
    required this.body,
    this.sentAt,
    this.readAt,
    this.unread = true,
  });

  final String id;
  final String title;
  final String body;
  final DateTime? sentAt;
  final DateTime? readAt;
  final bool unread;

  static DriverNoticeItem fromJson(Map<String, dynamic> json) {
    DateTime? parseTs(Object? raw) {
      if (raw == null) return null;
      return DateTime.tryParse(raw.toString())?.toLocal();
    }

    return DriverNoticeItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      sentAt: parseTs(json['sentAt'] ?? json['sent_at']),
      readAt: parseTs(json['readAt'] ?? json['read_at']),
      unread: json['unread'] == true,
    );
  }
}

class DriverNoticesSnapshot {
  const DriverNoticesSnapshot({
    this.items = const [],
    this.unreadCount = 0,
  });

  final List<DriverNoticeItem> items;
  final int unreadCount;
}

class DriverNoticesRepository {
  DriverNoticesRepository({DriverApiClient? client})
      : _client = client ?? DriverApiClient();

  final DriverApiClient _client;

  Future<DriverNoticesSnapshot> fetchInbox() async {
    try {
      final res = await _client.getWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/notices',
        flow: 'driver_notices',
      );
      final root = res.data;
      if (root == null || root['success'] != true) {
        return const DriverNoticesSnapshot();
      }
      final data = root['data'];
      if (data is! Map) return const DriverNoticesSnapshot();
      final map = Map<String, dynamic>.from(data);
      final raw = map['items'];
      final items = raw is List
          ? raw
                .whereType<Map>()
                .map((e) => DriverNoticeItem.fromJson(Map<String, dynamic>.from(e)))
                .where((e) => e.id.isNotEmpty)
                .toList()
          : const <DriverNoticeItem>[];
      final unread = map['unreadCount'];
      return DriverNoticesSnapshot(
        items: items,
        unreadCount: unread is num
            ? unread.toInt()
            : items.where((e) => e.unread).length,
      );
    } on DioException {
      return const DriverNoticesSnapshot();
    }
  }

  Future<void> markRead(String campaignId) async {
    if (campaignId.trim().isEmpty) return;
    try {
      await _client.postWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/notices/${campaignId.trim()}/read',
        flow: 'driver_notices_read',
      );
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _client.postWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/notices/read-all',
        flow: 'driver_notices_read_all',
      );
    } catch (_) {}
  }
}

final driverNoticesUnreadProvider = FutureProvider<int>((ref) async {
  final snap = await DriverNoticesRepository().fetchInbox();
  return snap.unreadCount;
});
