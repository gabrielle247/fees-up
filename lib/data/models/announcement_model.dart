import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum AnnouncementCategory {
  // Original
  financial,
  academic,
  urgent,
  system,
  
  // The "Rainbow" Types
  success,        // Green
  failure,        // Red
  warning,        // Amber
  info,           // Blue
  security,       // Purple
}

class Announcement {
  final String id;
  final String schoolId;
  final String title;
  final String body;
  final DateTime time;
  final AnnouncementCategory category;
  final bool isRead;
  final String? userId; // For personal notifications

  Announcement({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.body,
    required this.time,
    required this.category,
    required this.isRead,
    this.userId,
  });

  // --- FACTORY: THE CRASH FIX ---
  factory Announcement.fromRow(Map<String, dynamic> row) {
    // 1. Safe Boolean Parsing (Handles 1, 0, true, false, and null)
    final rawRead = row['is_read'];
    bool isReadSafe = false;
    if (rawRead is bool) {
      isReadSafe = rawRead;
    } else if (rawRead is int) {
      isReadSafe = rawRead == 1;
    }

    // 2. Safe Date Parsing
    DateTime parsedTime = DateTime.now();
    if (row['created_at'] != null) {
      parsedTime = DateTime.tryParse(row['created_at'].toString())?.toLocal() ?? DateTime.now();
    }

    return Announcement(
      id: row['id']?.toString() ?? '',
      schoolId: row['school_id']?.toString() ?? '',
      userId: row['user_id']?.toString(),
      title: row['title']?.toString() ?? 'No Title',
      body: row['body']?.toString() ?? '',
      time: parsedTime,
      isRead: isReadSafe,
      category: _parseCategory(row['type']?.toString() ?? 'info'),
    );
  }

  static AnnouncementCategory _parseCategory(String type) {
    switch (type.toLowerCase()) {
      case 'financial': return AnnouncementCategory.financial;
      case 'academic': return AnnouncementCategory.academic;
      case 'urgent': return AnnouncementCategory.urgent;
      case 'system': return AnnouncementCategory.system;
      case 'success': return AnnouncementCategory.success;
      case 'failure': 
      case 'error': return AnnouncementCategory.failure;
      case 'warning': return AnnouncementCategory.warning;
      case 'security': return AnnouncementCategory.security;
      default: return AnnouncementCategory.info;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': category.name, 
      'is_read': isRead ? 1 : 0, // Store as Int for SQLite compatibility
      'created_at': time.toIso8601String(),
    };
  }

  // --- VISUAL GETTERS ---

  Color get color {
    switch (category) {
      case AnnouncementCategory.urgent:
      case AnnouncementCategory.failure:
        return AppColors.errorRed;
      
      case AnnouncementCategory.warning:
        return Colors.amber;
      
      case AnnouncementCategory.success:
        return AppColors.successGreen;
      
      case AnnouncementCategory.financial:
        return const Color(0xFF00BFA5); // Teal
      
      case AnnouncementCategory.security:
        return const Color(0xFF9333EA); // Purple
        
      case AnnouncementCategory.system:
      case AnnouncementCategory.info:
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData get icon {
    switch (category) {
      case AnnouncementCategory.urgent: return Icons.notification_important_rounded;
      case AnnouncementCategory.failure: return Icons.error_outline_rounded;
      case AnnouncementCategory.warning: return Icons.warning_amber_rounded;
      case AnnouncementCategory.success: return Icons.check_circle_outline_rounded;
      case AnnouncementCategory.financial: return Icons.attach_money_rounded;
      case AnnouncementCategory.security: return Icons.security_rounded;
      case AnnouncementCategory.academic: return Icons.school_outlined;
      case AnnouncementCategory.system: return Icons.dns_outlined;
      default: return Icons.info_outline_rounded;
    }
  }

  String get badgeLabel {
    return category.name.toUpperCase();
  }
}