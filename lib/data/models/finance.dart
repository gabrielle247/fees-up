import 'package:isar/isar.dart';

part 'finance.g.dart';

@collection
class FeeCategory {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String id;
  @Index()
  late String schoolId;
  late String name;
  bool isTaxable = false;
  DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'name': name,
        'is_taxable': isTaxable,
        'created_at': createdAt?.toIso8601String(),
      };

  static FeeCategory fromJson(Map<String, dynamic> json) => FeeCategory()
    ..id = json['id'] as String
    ..schoolId = json['school_id'] as String
    ..name = json['name'] as String
    ..isTaxable = json['is_taxable'] as bool? ?? false
    ..createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
}

@collection
class FeeStructure {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String id;
  @Index()
  late String schoolId;
  late String academicYearId;
  late String categoryId;
  late String name;
  late int amount; // cents
  String currency = 'USD';
  String? targetGrade;
  // Billing extensions
  String billingType = 'tuition'; // tuition, exam, transport, penalty, discount
  // Recurrence: none, monthly, termly, yearly
  String recurrence = 'none';
  // Billable months (1-12). If empty and recurrence=monthly, defaults to all months in academic year.
  List<int> billableMonths = [];
  // Suspension windows for holidays, etc.
  List<SuspensionWindow> suspensions = [];
  DateTime? createdAt;

  double get amountInDollars => amount / 100.0;
  void setAmountFromDollars(double dollars) => amount = (dollars * 100).toInt();

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'academic_year_id': academicYearId,
        'category_id': categoryId,
        'name': name,
        'amount': amount / 100.0,
        'currency': currency,
        'target_grade': targetGrade,
        'billing_type': billingType,
        'recurrence': recurrence,
        'billable_months': billableMonths,
        'suspensions': suspensions
            .map((s) => {
                  'start': s.start.toIso8601String(),
                  'end': s.end.toIso8601String(),
                })
            .toList(),
        'created_at': createdAt?.toIso8601String(),
      };

  static FeeStructure fromJson(Map<String, dynamic> json) => FeeStructure()
    ..id = json['id'] as String
    ..schoolId = json['school_id'] as String
    ..academicYearId = json['academic_year_id'] as String
    ..categoryId = json['category_id'] as String
    ..name = json['name'] as String
    ..amount = ((json['amount'] as num?) ?? 0).toInt() * 100
    ..currency = json['currency'] as String? ?? 'USD'
    ..targetGrade = json['target_grade'] as String?
    ..billingType = json['billing_type'] as String? ?? 'tuition'
    ..recurrence = json['recurrence'] as String? ?? 'none'
    ..billableMonths = (json['billable_months'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        []
    ..suspensions = (json['suspensions'] as List?)?.map((m) {
          final mm = m as Map<String, dynamic>;
          return SuspensionWindow()
            ..start = DateTime.parse(mm['start'] as String)
            ..end = DateTime.parse(mm['end'] as String);
        }).toList() ??
        []
    ..createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
}

@embedded
class SuspensionWindow {
  late DateTime start;
  late DateTime end;
}

@collection
class Invoice {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String id;
  @Index()
  late String schoolId;
  @Index()
  late String studentId;
  @Index()
  late String invoiceNumber;
  String? termId;
  late DateTime dueDate;
  @Index()
  String status = 'DRAFT';
  String? snapshotGrade;
  DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'student_id': studentId,
        'invoice_number': invoiceNumber,
        'term_id': termId,
        'due_date': dueDate.toIso8601String(),
        'status': status,
        'snapshot_grade': snapshotGrade,
        'created_at': createdAt?.toIso8601String(),
      };

  static Invoice fromJson(Map<String, dynamic> json) => Invoice()
    ..id = json['id'] as String
    ..schoolId = json['school_id'] as String
    ..studentId = json['student_id'] as String
    ..invoiceNumber = json['invoice_number'] as String
    ..termId = json['term_id'] as String?
    ..dueDate = DateTime.parse(json['due_date'] as String)
    ..status = json['status'] as String? ?? 'DRAFT'
    ..snapshotGrade = json['snapshot_grade'] as String?
    ..createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
}

@collection
class InvoiceItem {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String id;
  @Index()
  late String invoiceId;
  String? feeStructureId;
  late String description;
  late int amount; // cents
  int quantity = 1;
  DateTime? createdAt;

  double get amountInDollars => amount / 100.0;
  void setAmountFromDollars(double dollars) => amount = (dollars * 100).toInt();

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_id': invoiceId,
        'fee_structure_id': feeStructureId,
        'description': description,
        'amount': amount / 100.0,
        'quantity': quantity,
        'created_at': createdAt?.toIso8601String(),
      };

  static InvoiceItem fromJson(Map<String, dynamic> json) => InvoiceItem()
    ..id = json['id'] as String
    ..invoiceId = json['invoice_id'] as String
    ..feeStructureId = json['fee_structure_id'] as String?
    ..description = json['description'] as String
    ..amount = ((json['amount'] as num?) ?? 0).toInt() * 100
    ..quantity = json['quantity'] as int? ?? 1
    ..createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
}

@collection
class LedgerEntry {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String id;
  @Index()
  late String schoolId;
  String? studentId;
  @Index()
  late String type; // DEBIT / CREDIT
  late String category;
  late int amount; // cents
  String currency = 'USD';
  String? invoiceId;
  String? referenceCode;
  String? description;
  late DateTime occurredAt;

  double get amountInDollars => amount / 100.0;
  void setAmountFromDollars(double dollars) => amount = (dollars * 100).toInt();

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'student_id': studentId,
        'type': type,
        'category': category,
        'amount': amount / 100.0,
        'currency': currency,
        'invoice_id': invoiceId,
        'reference_code': referenceCode,
        'description': description,
        'occurred_at': occurredAt.toIso8601String(),
      };

  static LedgerEntry fromJson(Map<String, dynamic> json) => LedgerEntry()
    ..id = json['id'] as String
    ..schoolId = json['school_id'] as String
    ..studentId = json['student_id'] as String?
    ..type = json['type'] as String
    ..category = json['category'] as String
    ..amount = ((json['amount'] as num?) ?? 0).toInt() * 100
    ..currency = json['currency'] as String? ?? 'USD'
    ..invoiceId = json['invoice_id'] as String?
    ..referenceCode = json['reference_code'] as String?
    ..description = json['description'] as String?
    ..occurredAt = DateTime.parse(json['occurred_at'] as String);
}

@collection
class Payment {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String id;
  @Index()
  late String schoolId;
  @Index()
  late String studentId;
  late int amount; // cents
  late String method;
  String? referenceCode;
  late DateTime receivedAt;
  DateTime? createdAt;

  double get amountInDollars => amount / 100.0;
  void setAmountFromDollars(double dollars) => amount = (dollars * 100).toInt();

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'student_id': studentId,
        'amount': amount / 100.0,
        'method': method,
        'reference_code': referenceCode,
        'received_at': receivedAt.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
      };

  static Payment fromJson(Map<String, dynamic> json) => Payment()
    ..id = json['id'] as String
    ..schoolId = json['school_id'] as String
    ..studentId = json['student_id'] as String
    ..amount = ((json['amount'] as num?) ?? 0).toInt() * 100
    ..method = json['method'] as String
    ..referenceCode = json['reference_code'] as String?
    ..receivedAt = DateTime.parse(json['received_at'] as String)
    ..createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
}

@collection
class PaymentAllocation {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String id;
  @Index()
  late String paymentId;
  @Index()
  late String invoiceItemId;
  late int amountAllocated; // cents
  DateTime? createdAt;

  double get amountInDollars => amountAllocated / 100.0;
  void setAmountFromDollars(double dollars) =>
      amountAllocated = (dollars * 100).toInt();

  Map<String, dynamic> toJson() => {
        'id': id,
        'payment_id': paymentId,
        'invoice_item_id': invoiceItemId,
        'amount_allocated': amountAllocated / 100.0,
        'created_at': createdAt?.toIso8601String(),
      };

  static PaymentAllocation fromJson(Map<String, dynamic> json) =>
      PaymentAllocation()
        ..id = json['id'] as String
        ..paymentId = json['payment_id'] as String
        ..invoiceItemId = json['invoice_item_id'] as String
        ..amountAllocated =
            ((json['amount_allocated'] as num?) ?? 0).toInt() * 100
        ..createdAt = json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null;
}
