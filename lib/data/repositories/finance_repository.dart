import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import '../models/finance_models.dart';
import '../constants/app_strings.dart';

class FinanceRepository {
  final PowerSyncDatabase _db;
  final Logger _log = Logger('FinanceRepository');

  FinanceRepository(this._db);

  /// ==========================================================================
  /// 1. FEE STRUCTURES (The Catalog)
  /// ==========================================================================

  /// Fetches all active fee structures for the current year.
  Future<List<FeeStructure>> getFeeStructures(String schoolId, String academicYearId) async {
    try {
      final results = await _db.getAll(
        '''SELECT * FROM fee_structures 
           WHERE school_id = ? AND academic_year_id = ? 
           ORDER BY name ASC''',
        [schoolId, academicYearId],
      );
      return results.map((row) => FeeStructure.fromJson(row)).toList();
    } catch (e, stack) {
      _log.severe('❌ ${AppStrings.feeStructureRepositoryAllForSchoolFailed}', e, stack);
      throw Exception(AppStrings.feeStructureRepositoryAllForSchoolFailed);
    }
  }

  /// Creates or Updates a Fee Structure.
  Future<void> saveFeeStructure(FeeStructure fee) async {
    try {
      _log.info('Saving Fee Structure: ${fee.name}');
      await _db.execute('''
        INSERT OR REPLACE INTO fee_structures (
          id, school_id, academic_year_id, category_id, name, amount, 
          currency, target_grade, created_at, billing_type, 
          recurrence, billable_months, suspensions
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        fee.id, fee.schoolId, fee.academicYearId, fee.categoryId, fee.name, fee.amount,
        fee.currency, fee.targetGrade, fee.createdAt, fee.billingType,
        fee.recurrence, fee.billableMonths, fee.suspensions
      ]);
      _log.info('✅ Fee Structure saved: ${fee.id}');
    } catch (e, stack) {
      _log.severe('❌ ${AppStrings.feeStructureRepositorySaveFailed}', e, stack);
      throw Exception(AppStrings.feeStructureRepositorySaveFailed);
    }
  }

  /// ==========================================================================
  /// 2. INVOICING (The Bills)
  /// ==========================================================================

  /// Creates a master invoice record.
  Future<void> createInvoice(Invoice invoice) async {
    try {
      await _db.execute('''
        INSERT INTO invoices (
          id, school_id, student_id, invoice_number, term_id, 
          due_date, status, snapshot_grade, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        invoice.id, invoice.schoolId, invoice.studentId, invoice.invoiceNumber, invoice.termId,
        invoice.dueDate, invoice.status, invoice.snapshotGrade, invoice.createdAt
      ]);
    } catch (e, stack) {
      _log.severe('❌ ${AppStrings.invoiceRepositorySaveInvoiceFailed}', e, stack);
      throw Exception(AppStrings.invoiceRepositorySaveInvoiceFailed);
    }
  }

  /// Adds line items to an invoice (Atomic operation usually handled by Service).
  Future<void> addInvoiceItems(List<InvoiceItem> items) async {
    try {
      await _db.writeTransaction((tx) async {
        for (var item in items) {
          await tx.execute('''
            INSERT INTO invoice_items (
              id, invoice_id, fee_structure_id, description, 
              amount, quantity, created_at, school_id
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          ''', [
            item.id, item.invoiceId, item.feeStructureId, item.description,
            item.amount, item.quantity, item.createdAt, item.schoolId
          ]);
        }
      });
      _log.info('✅ Added ${items.length} items to invoices');
    } catch (e, stack) {
      _log.severe('❌ ${AppStrings.invoiceRepositorySaveItemFailed}', e, stack);
      throw Exception(AppStrings.invoiceRepositorySaveItemFailed);
    }
  }

  /// Fetches pending invoices for a specific student.
  Future<List<Invoice>> getPendingInvoices(String studentId) async {
    try {
      // 1. Get Invoices
      final invoiceRows = await _db.getAll(
        '''SELECT * FROM invoices 
           WHERE student_id = ? AND status != ? 
           ORDER BY created_at DESC''',
        [studentId, AppStrings.paid],
      );

      // 2. Hydrate with Items (Simple N+1 for local DB is acceptable for readability here)
      // For high performance, use a JOIN query instead.
      List<Invoice> fullInvoices = [];
      for (var row in invoiceRows) {
        final itemsRows = await _db.getAll(
          'SELECT * FROM invoice_items WHERE invoice_id = ?', 
          [row['id']]
        );
        final items = itemsRows.map((i) => InvoiceItem.fromJson(i)).toList();
        
        var invoice = Invoice.fromJson(row);
        // We need to construct a new Invoice with items since the model fields are final
        fullInvoices.add(Invoice(
          id: invoice.id,
          schoolId: invoice.schoolId,
          studentId: invoice.studentId,
          invoiceNumber: invoice.invoiceNumber,
          termId: invoice.termId,
          dueDate: invoice.dueDate,
          status: invoice.status,
          snapshotGrade: invoice.snapshotGrade,
          createdAt: invoice.createdAt,
          items: items,
        ));
      }
      return fullInvoices;
    } catch (e, stack) {
      _log.severe('❌ Failed to fetch pending invoices', e, stack);
      throw Exception(AppStrings.genericError);
    }
  }

  /// ==========================================================================
  /// 3. LEDGER (The History)
  /// ==========================================================================

  /// Records a ledger entry (Audit trail for ANY money movement).
  Future<void> addLedgerEntry(LedgerEntry entry) async {
    try {
      await _db.execute('''
        INSERT INTO ledger (
          id, school_id, student_id, type, category, amount, 
          currency, invoice_id, reference_code, description, 
          occurred_at, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        entry.id, entry.schoolId, entry.studentId, entry.type, entry.category,
        entry.amount, entry.currency, entry.invoiceId, entry.referenceCode,
        entry.description, entry.occurredAt, entry.createdAt
      ]);
    } catch (e, stack) {
      _log.severe('❌ Failed to write to ledger', e, stack);
      throw Exception(AppStrings.genericError);
    }
  }

  /// Fetches the recent financial activity for a school.
  Future<List<LedgerEntry>> getRecentActivity(String schoolId, {int limit = 20}) async {
    try {
      final results = await _db.getAll(
        '''SELECT * FROM ledger 
           WHERE school_id = ? 
           ORDER BY occurred_at DESC 
           LIMIT ?''',
        [schoolId, limit],
      );
      return results.map((row) => LedgerEntry.fromJson(row)).toList();
    } catch (e, stack) {
      _log.severe('❌ ${AppStrings.ledgerRepositoryAllForSchoolFailed}', e, stack);
      throw Exception(AppStrings.ledgerRepositoryAllForSchoolFailed);
    }
  }

  /// Calculates total revenue and pending balance for the dashboard.
  /// Returns { 'revenue': 12000.0, 'pending': 4500.0 }
  Future<Map<String, double>> getDashboardStats(String schoolId) async {
    try {
      // 1. Calculate Revenue (Sum of 'CREDIT' ledger entries)
      final revenueResult = await _db.getOptional(
        '''SELECT SUM(amount) as total FROM ledger 
           WHERE school_id = ? AND type = ?''',
        [schoolId, AppStrings.creditType],
      );
      final revenue = (revenueResult?['total'] as num?)?.toDouble() ?? 0.0;

      // 2. Calculate Pending (Sum of unpaid invoices)
      // Note: This is a simplification. Real pending calculation might need more complex logic.
      final pendingResult = await _db.getOptional(
        '''SELECT SUM(i.amount) as total FROM invoice_items i
           JOIN invoices inv ON i.invoice_id = inv.id
           WHERE inv.school_id = ? AND inv.status != ?''',
        [schoolId, AppStrings.paid],
      );
      final pending = (pendingResult?['total'] as num?)?.toDouble() ?? 0.0;

      return {'revenue': revenue, 'pending': pending};
    } catch (e) {
      _log.warning('⚠️ Failed to calc dashboard stats: $e');
      return {'revenue': 0.0, 'pending': 0.0}; // Fail safe
    }
  }
}