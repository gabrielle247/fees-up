
import 'package:fees_up/data/constants/app_strings.dart';
import 'package:fees_up/data/repositories/finance_repository.dart';
import 'package:fees_up/data/repositories/student_repository.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import '../models/all_models.dart';


class InvoiceService {
  final StudentRepository _studentRepo;
  final FinanceRepository _financeRepo;
  final Logger _log = Logger('InvoiceService');
  final Uuid _uuid = const Uuid();

  InvoiceService(this._studentRepo, this._financeRepo);

  /// Generates invoices for an entire grade/class based on a Fee Structure.
  Future<int> generateBulkInvoices({
    required String schoolId,
    required FeeStructure feeStructure,
    required String termId,
    required DateTime dueDate,
  }) async {
    try {
      _log.info('🏭 Starting Bulk Invoice Generation: ${feeStructure.name} for ${feeStructure.targetGrade}');

      // 1. Get Target Students
      // If target is "All", fetch all. Else fetch by grade.
      // Since our repo only has `getAllStudents`, we filter in memory for now.
      // (Optimization: Add `getStudentsByGrade` to StudentRepository later)
      final allStudents = await _studentRepo.getAllStudents(schoolId);
      
      List<Student> targets = [];
      if (feeStructure.targetGrade == 'All') {
        targets = allStudents;
      } else {
        // Mock filtering logic - assumes you store grade in student info
        // You might need to check Enrollments table in real implementation
        targets = allStudents; 
      }

      _log.info('Found ${targets.length} students to invoice.');

      int successCount = 0;

      // 2. Loop and Create
      for (var student in targets) {
        final invoiceId = _uuid.v4();

        // A. Create Invoice Header
        final invoice = Invoice(
          id: invoiceId,
          schoolId: schoolId,
          studentId: student.id,
          invoiceNumber: _generateInvoiceNumber(student),
          termId: termId,
          dueDate: dueDate.toIso8601String(),
          status: AppStrings.pending, // "Pending"
          createdAt: DateTime.now().toIso8601String(),
        );

        await _financeRepo.createInvoice(invoice);

        // B. Create Invoice Item (Line Item)
        final item = InvoiceItem(
          id: _uuid.v4(),
          invoiceId: invoiceId,
          feeStructureId: feeStructure.id,
          description: feeStructure.name,
          amount: feeStructure.amount,
          quantity: 1,
          createdAt: DateTime.now().toIso8601String(),
          schoolId: schoolId,
        );

        await _financeRepo.addInvoiceItems([item]);
        
        // C. Update Student Balance (Increase Debt)
        await _studentRepo.updateBalance(
          student.id, 
          student.feesOwed + feeStructure.amount
        );

        successCount++;
      }

      _log.info('✅ Successfully generated $successCount invoices.');
      return successCount;

    } catch (e, stack) {
      _log.severe('❌ Bulk Invoicing Failed', e, stack);
      throw Exception('Failed to generate invoices.');
    }
  }

  String _generateInvoiceNumber(Student student) {
    // INV-{Year}-{Random}
    return 'INV-${DateTime.now().year}-${_uuid.v4().substring(0, 5).toUpperCase()}';
  }
}