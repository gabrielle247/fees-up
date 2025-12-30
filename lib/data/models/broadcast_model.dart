import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class Broadcast {
  final String id;
  final String? schoolId; // Null = Global
  final String authorId;
  final bool isSystemMessage;
  final String targetRole;
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

  // --- UI HELPERS ---
  
  Color get badgeColor {
    if (isSystemMessage) return const Color(0xFF9333EA); // System Purple
    if (priority == 'critical') return AppColors.errorRed;
    return AppColors.primaryBlue;
  }

  String get authorLabel {
    if (isSystemMessage) return "Fees Up HQ";
    return "School Admin";
  }

  IconData get icon {
    if (isSystemMessage) return Icons.verified;
    if (priority == 'critical') return Icons.campaign;
    return Icons.info_outline;
  }
}