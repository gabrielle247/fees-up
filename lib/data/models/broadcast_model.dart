import 'package:fees_up/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class Broadcast {
  final String id;
  final String? schoolId; // Null = Global Greyway.Co Broadcast
  final String authorId;
  final bool isSystemMessage;
  final String targetRole; // 'all', 'teacher', 'hq_internal'
  final String title;
  final String body;
  final String priority;
  final DateTime createdAt;

  Broadcast({
    required this.id,
    this.schoolId,
    required this.authorId,
    this.isSystemMessage = false,
    required this.targetRole,
    required this.title,
    required this.body,
    required this.priority,
    required this.createdAt,
  });

  factory Broadcast.fromRow(Map<String, dynamic> row) {
    return Broadcast(
      id: row['id'] as String,
      schoolId: row['school_id'] as String?,
      authorId: row['author_id'] as String,
      isSystemMessage: (row['is_system_message'] == 1),
      targetRole: row['target_role'] ?? 'all',
      title: row['title'] as String,
      body: row['body'] as String,
      priority: row['priority'] ?? 'normal',
      createdAt: DateTime.tryParse(row['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'author_id': authorId,
      'is_system_message': isSystemMessage ? 1 : 0,
      'target_role': targetRole,
      'title': title,
      'body': body,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // --- CE0 UI HELPERS ---
  
  bool get isInternalHQ => targetRole == 'hq_internal';

  Color get badgeColor {
    if (isInternalHQ) return AppColors.accentPurpleDark; // Security Purple
    if (isSystemMessage) return  AppColors.primaryBlue; // System Blue
    if (priority == 'critical') return AppColors.errorRed; // Failure Red
    return AppColors.successGreen; // General Green
  }

  String get authorLabel {
    if (isInternalHQ) return "Greyway HQ";
    if (isSystemMessage) return "Fees Up System";
    return "School Admin";
  }

  IconData get icon {
    if (isInternalHQ) return Icons.security;
    if (isSystemMessage) return Icons.settings_suggest;
    if (priority == 'critical') return Icons.report_problem;
    return Icons.campaign;
  }
}