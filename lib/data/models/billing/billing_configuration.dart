import 'package:uuid/uuid.dart';

enum BillingFrequency {
  daily('daily', 'Daily'),
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly'),
  termly('termly', 'Termly'),
  annually('annually', 'Annually'),
  custom('custom', 'Custom');

  final String code;
  final String display;
  const BillingFrequency(this.code, this.display);

  static BillingFrequency fromCode(String code) =>
      BillingFrequency.values.firstWhere(
        (e) => e.code == code,
        orElse: () => BillingFrequency.monthly,
      );
}

enum BillingType {
  tuition('tuition', 'Tuition'),
  transport('transport', 'Transport'),
  meals('meals', 'Meals'),
  activities('activities', 'Activities'),
  uniform('uniform', 'Uniform'),
  library('library', 'Library'),
  technology('technology', 'Technology'),
  custom('custom', 'Custom');

  final String code;
  final String display;
  const BillingType(this.code, this.display);

  static BillingType fromCode(String code) =>
      BillingType.values.firstWhere(
        (e) => e.code == code,
        orElse: () => BillingType.tuition,
      );
}

class FeeComponent {
  final String id;
  final String name;
  final BillingType type;
  final double amount;
  final bool isOptional;
  final bool isApplicable; // Used for conditional fees

  FeeComponent({
    String? id,
    required this.name,
    required this.type,
    required this.amount,
    this.isOptional = false,
    this.isApplicable = true,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.code,
        'amount': amount,
        'is_optional': isOptional,
        'is_applicable': isApplicable,
      };

  factory FeeComponent.fromMap(Map<String, dynamic> map) => FeeComponent(
        id: map['id'] as String?,
        name: map['name'] as String,
        type: BillingType.fromCode(map['type'] as String),
        amount: (map['amount'] as num).toDouble(),
        isOptional: map['is_optional'] as bool? ?? false,
        isApplicable: map['is_applicable'] as bool? ?? true,
      );
}

class BillingConfiguration {
  final String id;
  final String schoolId;
  final String gradeLevel; // e.g., "Grade 1", "Grade 2", null for all
  final BillingFrequency frequency;
  final int billingDay; // Day of month when billing occurs
  final int dueDay; // Due day (usually billingDay + 7-30)
  final List<FeeComponent> feeComponents;
  final double? lateFeePercentage; // e.g., 5% = 5.0
  final double? minLateFee;
  final double? maxLateFee;
  final bool isActive;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;

  BillingConfiguration({
    String? id,
    required this.schoolId,
    required this.gradeLevel,
    required this.frequency,
    required this.billingDay,
    required this.dueDay,
    required this.feeComponents,
    this.lateFeePercentage,
    this.minLateFee,
    this.maxLateFee,
    this.isActive = true,
    required this.effectiveFrom,
    this.effectiveUntil,
  }) : id = id ?? const Uuid().v4();

  double calculateTotalFee([List<String>? includeTypes]) {
    return feeComponents
        .where((fc) =>
            fc.isApplicable &&
            (includeTypes == null ||
                includeTypes.contains(fc.type.code)))
        .fold(0.0, (sum, fc) => sum + fc.amount);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'school_id': schoolId,
        'grade_level': gradeLevel,
        'frequency': frequency.code,
        'billing_day': billingDay,
        'due_day': dueDay,
        'fee_components': feeComponents.map((fc) => fc.toMap()).toList(),
        'late_fee_percentage': lateFeePercentage,
        'min_late_fee': minLateFee,
        'max_late_fee': maxLateFee,
        'is_active': isActive,
        'effective_from': effectiveFrom.toIso8601String(),
        'effective_until': effectiveUntil?.toIso8601String(),
      };

  factory BillingConfiguration.fromMap(Map<String, dynamic> map) =>
      BillingConfiguration(
        id: map['id'] as String?,
        schoolId: map['school_id'] as String,
        gradeLevel: map['grade_level'] as String? ?? 'General',
        frequency: BillingFrequency.fromCode(map['frequency'] as String),
        billingDay: map['billing_day'] as int,
        dueDay: map['due_day'] as int,
        feeComponents: (map['fee_components'] as List<dynamic>?)
                ?.map((fc) =>
                    FeeComponent.fromMap(fc as Map<String, dynamic>))
                .toList() ??
            [],
        lateFeePercentage:
            (map['late_fee_percentage'] as num?)?.toDouble(),
        minLateFee: (map['min_late_fee'] as num?)?.toDouble(),
        maxLateFee: (map['max_late_fee'] as num?)?.toDouble(),
        isActive: map['is_active'] as bool? ?? true,
        effectiveFrom:
            DateTime.parse(map['effective_from'] as String),
        effectiveUntil: map['effective_until'] != null
            ? DateTime.parse(map['effective_until'] as String)
            : null,
      );
}
