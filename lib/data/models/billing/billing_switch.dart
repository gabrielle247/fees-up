import 'package:uuid/uuid.dart';
import 'billing_configuration.dart';

enum ProrationType {
  prorated('prorated', 'Prorated'),
  fullMonth('fullMonth', 'Full Month'),
  dailyRate('dailyRate', 'Daily Rate');

  final String code;
  final String display;
  const ProrationType(this.code, this.display);
}

class BillingSwitch {
  final String id;
  final String schoolId;
  final String studentId;
  final BillingConfiguration oldConfig;
  final BillingConfiguration newConfig;
  final DateTime effectiveDate;
  final ProrationType prorationType;
  final String? notes;
  final bool isProcessed;

  BillingSwitch({
    String? id,
    required this.schoolId,
    required this.studentId,
    required this.oldConfig,
    required this.newConfig,
    required this.effectiveDate,
    this.prorationType = ProrationType.prorated,
    this.notes,
    this.isProcessed = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'school_id': schoolId,
        'student_id': studentId,
        'old_config': oldConfig.toMap(),
        'new_config': newConfig.toMap(),
        'effective_date': effectiveDate.toIso8601String(),
        'proration_type': prorationType.code,
        'notes': notes,
        'is_processed': isProcessed,
      };
}
