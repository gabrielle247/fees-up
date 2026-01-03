import 'dart:convert'; // Required for JSON decoding

class StudentArchive {
  final String id;
  final String schoolId;
  final String? fullName;
  final String? reason;
  final DateTime archivedAt;
  final Map<String, dynamic>? originalData; // Stored as JSONB in SQL

  StudentArchive({
    required this.id,
    required this.schoolId,
    this.fullName,
    this.reason,
    required this.archivedAt,
    this.originalData,
  });

  factory StudentArchive.fromRow(Map<String, dynamic> row) {
    return StudentArchive(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      fullName: row['full_name'] as String?,
      reason: row['reason'] as String?,
      archivedAt: DateTime.tryParse(row['archived_at'] ?? '') ?? DateTime.now(),
      // Handle potential JSON string from SQLite
      originalData: row['original_data'] != null
          ? (row['original_data'] is String 
              ? jsonDecode(row['original_data']) 
              : row['original_data'])
          : null,
    );
  }
}

class Expense {
  final String id;
  final String schoolId;
  final String title;
  final double amount;
  final String? category;
  final DateTime incurredAt;
  final String? description;
  final String? recipient;
  final String? paymentMethod;

  Expense({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.amount,
    this.category,
    required this.incurredAt,
    this.description,
    this.recipient,
    this.paymentMethod,
  });

  factory Expense.fromRow(Map<String, dynamic> row) {
    return Expense(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      title: row['title'] as String,
      amount: (row['amount'] as num).toDouble(),
      category: row['category'] as String?,
      incurredAt: DateTime.tryParse(row['incurred_at'] ?? '') ?? DateTime.now(),
      description: row['description'] as String?,
      recipient: row['recipient'] as String?,
      paymentMethod: row['payment_method'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'title': title,
      'amount': amount,
      'category': category,
      'incurred_at': incurredAt.toIso8601String(),
      'description': description,
      'recipient': recipient,
      'payment_method': paymentMethod,
    };
  }
}