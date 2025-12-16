// lib/models/student_brick.dart
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';

/// Brick-annotated Student model for offline-first sync with Supabase
@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'students'),
)
class Student extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  @Sqlite(unique: true)
  final String id;

  @Supabase(name: 'full_name')
  @Sqlite(name: 'full_name')
  final String? fullName;

  final String? grade;

  @Supabase(name: 'parent_contact')
  @Sqlite(name: 'parent_contact')
  final String? parentContact;

  @Supabase(name: 'registration_date')
  @Sqlite(name: 'registration_date')
  final DateTime? registrationDate;

  @Supabase(name: 'billing_type')
  @Sqlite(name: 'billing_type')
  final String? billingType;

  @Supabase(name: 'is_active')
  @Sqlite(name: 'is_active')
  final bool isActive;

  @Supabase(name: 'default_fee')
  @Sqlite(name: 'default_fee')
  final double? defaultFee;

  @Supabase(name: 'admin_uid')
  @Sqlite(name: 'admin_uid')
  final String? adminUid;

  @Supabase(name: 'paid_total')
  @Sqlite(name: 'paid_total')
  final double paidTotal;

  @Supabase(name: 'owed_total')
  @Sqlite(name: 'owed_total')
  final double owedTotal;

  final String? subjects;

  Student({
    required this.id,
    this.fullName,
    this.grade,
    this.parentContact,
    this.registrationDate,
    this.billingType,
    this.isActive = true,
    this.defaultFee,
    this.adminUid,
    this.paidTotal = 0.0,
    this.owedTotal = 0.0,
    this.subjects,
  });

  /// Convert to your existing StudentModel for compatibility
  StudentModel toStudentModel() {
    return StudentModel(
      id: id,
      fullName: fullName,
      grade: grade,
      parentContact: parentContact,
      registrationDate: registrationDate,
      billingType: billingType,
      isActive: isActive,
      defaultFee: defaultFee,
      adminUid: adminUid,
      paidTotal: paidTotal,
      owedTotal: owedTotal,
      subjects: subjects,
    );
  }

  /// Create from your existing StudentModel
  factory Student.fromStudentModel(StudentModel model) {
    return Student(
      id: model.id,
      fullName: model.fullName,
      grade: model.grade,
      parentContact: model.parentContact,
      registrationDate: model.registrationDate,
      billingType: model.billingType,
      isActive: model.isActive,
      defaultFee: model.defaultFee,
      adminUid: model.adminUid,
      paidTotal: model.paidTotal,
      owedTotal: model.owedTotal,
      subjects: model.subjects,
    );
  }
}

// Keep your existing StudentModel for backward compatibility
class StudentModel {
  final String id;
  final String? fullName;
  final String? grade;
  final String? parentContact;
  final DateTime? registrationDate;
  final String? billingType;
  final bool isActive;
  final double? defaultFee;
  final String? adminUid;
  final double paidTotal;
  final double owedTotal;
  final String? subjects;

  StudentModel({
    required this.id,
    this.fullName,
    this.grade,
    this.parentContact,
    this.registrationDate,
    this.billingType,
    this.isActive = true,
    this.defaultFee,
    this.adminUid,
    this.paidTotal = 0.0,
    this.owedTotal = 0.0,
    this.subjects,
  });

  factory StudentModel.fromMap(Map<String, Object?> m) {
    DateTime? reg;
    try {
      if (m['registration_date'] != null) {
        reg = DateTime.parse(m['registration_date'] as String);
      }
    } catch (_) {}

    return StudentModel(
      id: m['id'] as String,
      fullName: m['full_name'] as String?,
      grade: m['grade'] as String?,
      parentContact: m['parent_contact'] as String?,
      registrationDate: reg,
      billingType: m['billing_type'] as String?,
      isActive: (m['is_active'] as int? ?? 1) == 1,
      defaultFee: (m['default_fee'] as num?)?.toDouble(),
      adminUid: m['admin_uid'] as String?,
      paidTotal: (m['paid_total'] as num?)?.toDouble() ?? 0.0,
      owedTotal: (m['owed_total'] as num?)?.toDouble() ?? 0.0,
      subjects: m['subjects'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'grade': grade,
      'parent_contact': parentContact,
      'registration_date': registrationDate?.toIso8601String(),
      'billing_type': billingType,
      'is_active': isActive ? 1 : 0,
      'default_fee': defaultFee,
      'admin_uid': adminUid,
      'paid_total': paidTotal,
      'owed_total': owedTotal,
      'subjects': subjects,
    };
  }
}
