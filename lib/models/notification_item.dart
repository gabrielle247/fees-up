class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'info', 'warning', 'success'
  final String? adminUid;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type = 'info',
    this.adminUid,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      // Handle SQLite Integer (0/1) to Boolean conversion
      isRead: (map['is_read'] is int) ? (map['is_read'] == 1) : (map['is_read'] ?? false),
      type: map['type'] ?? 'info',
      adminUid: map['admin_uid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead ? 1 : 0, // SQLite stores bool as int
      'type': type,
      'admin_uid': adminUid,
    };
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
      adminUid: adminUid,
    );
  }
}