class School {
  final String id;
  final String name;
  final String subscriptionTier; // 'free', 'basic', 'pro'
  final int maxStudents;
  final bool isSuspended;
  final DateTime createdAt;

  School({
    required this.id,
    required this.name,
    this.subscriptionTier = 'free',
    this.maxStudents = 50,
    this.isSuspended = false,
    required this.createdAt,
  });

  factory School.fromRow(Map<String, dynamic> row) {
    return School(
      id: row['id'] as String,
      name: row['name'] as String,
      subscriptionTier: row['subscription_tier'] ?? 'free',
      maxStudents: (row['max_students'] as num?)?.toInt() ?? 50,
      isSuspended: (row['is_suspended'] == 1),
      createdAt: DateTime.parse(row['created_at']),
    );
  }
}

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'super_admin', 'school_admin', 'teacher', 'student'
  final String? schoolId;
  final bool isBanned;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.role = 'teacher',
    this.schoolId,
    this.isBanned = false,
    this.avatarUrl,
  });

  factory UserProfile.fromRow(Map<String, dynamic> row) {
    return UserProfile(
      id: row['id'] as String,
      email: row['email'] as String,
      fullName: row['full_name'] as String,
      role: row['role'] ?? 'teacher',
      schoolId: row['school_id'] as String?,
      isBanned: (row['is_banned'] == 1),
      avatarUrl: row['avatar_url'] as String?,
    );
  }
}

class BillingConfig {
  final String id;
  final String? schoolId;
  final String currencyCode;
  final double lateFeePercentage;
  final String? invoiceFooterNote;
  final bool allowPartialPayments;
  final double defaultFee;

  BillingConfig({
    required this.id,
    this.schoolId,
    this.currencyCode = 'USD',
    this.lateFeePercentage = 0.0,
    this.invoiceFooterNote,
    this.allowPartialPayments = true,
    this.defaultFee = 100.00,
  });

  factory BillingConfig.fromRow(Map<String, dynamic> row) {
    return BillingConfig(
      id: row['id'] as String,
      schoolId: row['school_id'] as String?,
      currencyCode: row['currency_code'] ?? 'USD',
      lateFeePercentage: (row['late_fee_percentage'] as num?)?.toDouble() ?? 0.0,
      invoiceFooterNote: row['invoice_footer_note'] as String?,
      allowPartialPayments: (row['allow_partial_payments'] == 1),
      defaultFee: (row['default_fee'] as num?)?.toDouble() ?? 100.00,
    );
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String? schoolId;
  final String title;
  final String body;
  final String type; // 'info', 'warning', etc.
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    this.schoolId,
    required this.title,
    required this.body,
    this.type = 'info',
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromRow(Map<String, dynamic> row) {
    return NotificationModel(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      schoolId: row['school_id'] as String?,
      title: row['title'] as String,
      body: row['body'] as String,
      type: row['type'] ?? 'info',
      isRead: (row['is_read'] == 1),
      createdAt: DateTime.parse(row['created_at']),
    );
  }
}