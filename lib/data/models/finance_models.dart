// ALL FINANCE MODELS IN ONE FILE - NO REPEATS

class FeeCategory {
  final String id;
  final String schoolId;
  final String name;
  final bool isTaxable;
  final String createdAt;

  FeeCategory({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.isTaxable,
    required this.createdAt,
  });

  factory FeeCategory.fromJson(Map<String, dynamic> json) => FeeCategory(
        id: json['id'] as String,
        schoolId: json['school_id'] as String,
        name: json['name'] as String,
        isTaxable: json['is_taxable'] == '1' || json['is_taxable'] == true,
        createdAt: json['created_at'] as String,
      );
}

class FeeStructure {
  final String id;
  final String schoolId;
  final String academicYearId;
  final String categoryId;
  final String name;
  final double amount;
  final String currency;
  final String? targetGrade;
  final String createdAt;
  final String billingType;
  final String recurrence;
  final String billableMonths;
  final String suspensions;

  FeeStructure({
    required this.id,
    required this.schoolId,
    required this.academicYearId,
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.currency,
    this.targetGrade,
    required this.createdAt,
    required this.billingType,
    required this.recurrence,
    required this.billableMonths,
    required this.suspensions,
  });

  factory FeeStructure.fromJson(Map<String, dynamic> json) => FeeStructure(
        id: json['id'] as String,
        schoolId: json['school_id'] as String,
        academicYearId: json['academic_year_id'] as String,
        categoryId: json['category_id'] as String,
        name: json['name'] as String,
        amount: double.parse(json['amount'].toString()),
        currency: json['currency'] as String,
        targetGrade: json['target_grade'] as String?,
        createdAt: json['created_at'] as String,
        billingType: json['billing_type'] as String,
        recurrence: json['recurrence'] as String,
        billableMonths: json['billable_months'] as String,
        suspensions: json['suspensions'] as String,
      );
}

class InvoiceItem {
  final String id;
  final String invoiceId;
  final String? feeStructureId;
  final String description;
  final double amount;
  final int quantity;
  final String createdAt;
  final String schoolId;

  InvoiceItem({
    required this.id,
    required this.invoiceId,
    this.feeStructureId,
    required this.description,
    required this.amount,
    required this.quantity,
    required this.createdAt,
    required this.schoolId,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        id: json['id'] as String,
        invoiceId: json['invoice_id'] as String,
        feeStructureId: json['fee_structure_id'] as String?,
        description: json['description'] as String,
        amount: double.parse(json['amount'].toString()),
        quantity: int.parse(json['quantity'].toString()),
        createdAt: json['created_at'] as String,
        schoolId: json['school_id'] as String,
      );
}

class Invoice {
  final String id;
  final String schoolId;
  final String studentId;
  final String invoiceNumber;
  final String? termId;
  final String dueDate;
  final String status;
  final String? snapshotGrade;
  final String createdAt;
  final List<InvoiceItem>? items; // Optional items list

  Invoice({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.invoiceNumber,
    this.termId,
    required this.dueDate,
    required this.status,
    this.snapshotGrade,
    required this.createdAt,
    this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as String,
        schoolId: json['school_id'] as String,
        studentId: json['student_id'] as String,
        invoiceNumber: json['invoice_number'] as String,
        termId: json['term_id'] as String?,
        dueDate: json['due_date'] as String,
        status: json['status'] as String,
        snapshotGrade: json['snapshot_grade'] as String?,
        createdAt: json['created_at'] as String,
      );
}

class LedgerEntry {
  final String id;
  final String schoolId;
  final String? studentId;
  final String type;
  final String category;
  final double amount;
  final String currency;
  final String? invoiceId;
  final String? referenceCode;
  final String? description;
  final String occurredAt;
  final String createdAt;

  LedgerEntry({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.type,
    required this.category,
    required this.amount,
    required this.currency,
    this.invoiceId,
    this.referenceCode,
    this.description,
    required this.occurredAt,
    required this.createdAt,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) => LedgerEntry(
        id: json['id'] as String,
        schoolId: json['school_id'] as String,
        studentId: json['student_id'] as String?,
        type: json['type'] as String,
        category: json['category'] as String,
        amount: double.parse(json['amount'].toString()),
        currency: json['currency'] as String,
        invoiceId: json['invoice_id'] as String?,
        referenceCode: json['reference_code'] as String?,
        description: json['description'] as String?,
        occurredAt: json['occurred_at'] as String,
        createdAt: json['created_at'] as String,
      );
}

class PaymentAllocation {
  final String id;
  final String paymentId;
  final String invoiceItemId;
  final double amountAllocated;
  final String createdAt;
  final String schoolId;

  PaymentAllocation({
    required this.id,
    required this.paymentId,
    required this.invoiceItemId,
    required this.amountAllocated,
    required this.createdAt,
    required this.schoolId,
  });

  factory PaymentAllocation.fromJson(Map<String, dynamic> json) => PaymentAllocation(
        id: json['id'] as String,
        paymentId: json['payment_id'] as String,
        invoiceItemId: json['invoice_item_id'] as String,
        amountAllocated: double.parse(json['amount_allocated'].toString()),
        createdAt: json['created_at'] as String,
        schoolId: json['school_id'] as String,
      );
}

class Payment {
  final String id;
  final String schoolId;
  final String studentId;
  final double amount;
  final String method;
  final String? referenceCode;
  final String receivedAt;
  final String createdAt;
  final List<PaymentAllocation>? allocations; // Optional allocations list

  Payment({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.amount,
    required this.method,
    this.referenceCode,
    required this.receivedAt,
    required this.createdAt,
    this.allocations,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as String,
        schoolId: json['school_id'] as String,
        studentId: json['student_id'] as String,
        amount: double.parse(json['amount'].toString()),
        method: json['method'] as String,
        referenceCode: json['reference_code'] as String?,
        receivedAt: json['received_at'] as String,
        createdAt: json['created_at'] as String,
      );
}

class PlanModel {
  final String id;
  final String title;
  final String price;
  final String description;
  final List<String> features;
  final bool isPopular;

  const PlanModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.features,
    this.isPopular = false,
  });
}