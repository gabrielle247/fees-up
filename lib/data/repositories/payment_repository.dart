import 'dart:math';
import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import '../models/finance_models.dart';
import '../constants/app_strings.dart';

class PaymentRepository {
  final PowerSyncDatabase _db;
  final Logger _log = Logger('PaymentRepository');
  final Uuid _uuid = const Uuid();

  PaymentRepository(this._db);

  /// ==========================================================================
  /// 1. THE "SELF-REGULATED" PAYMENT ENGINE
  /// ==========================================================================

  /// Processes a payment with "Zero-Loss" logic.
  /// 
  /// If [partialPayment] has missing fields (like reference codes or dates),
  /// this engine auto-fills them with intelligent defaults (Placebo Data)
  /// so the transaction never fails due to minor human error.
  Future<void> processPayment({
    required String schoolId,
    required String studentId,
    required double amount,
    String? method,         // Optional: Defaults to CASH
    String? referenceCode,  // Optional: Auto-generated if missing
    String? description,    // Optional: Auto-generated
    DateTime? receivedAt,   // Optional: Defaults to NOW
  }) async {
    try {
      _log.info('⚙️ Processing payment for Student: $studentId');

      // -----------------------------------------------------------------------
      // A. SANITIZE & AUTO-FILL (The "Placebo" Logic)
      // -----------------------------------------------------------------------
      final safeMethod = method ?? 'CASH';
      final safeDate = receivedAt ?? DateTime.now();
      final safeReference = referenceCode ?? _generateAutoReference(safeMethod);
      final safeDescription = description ?? 'Payment received via $safeMethod';
      
      final paymentId = _uuid.v4();
      final ledgerId = _uuid.v4();

      // -----------------------------------------------------------------------
      // B. ATOMIC TRANSACTION (Write to Payment + Ledger + Update Balance)
      // -----------------------------------------------------------------------
      await _db.writeTransaction((tx) async {
        
        // 1. Insert into PAYMENTS table
        await tx.execute('''
          INSERT INTO payments (
            id, school_id, student_id, amount, method, 
            reference_code, received_at, created_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          paymentId,
          schoolId,
          studentId,
          amount,
          safeMethod,
          safeReference,
          safeDate.toIso8601String(),
          DateTime.now().toIso8601String(),
        ]);

        // 2. Insert into LEDGER (The Double-Entry Audit Trail)
        await tx.execute('''
          INSERT INTO ledger (
            id, school_id, student_id, type, category, amount, 
            currency, invoice_id, reference_code, description, 
            occurred_at, created_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          ledgerId,
          schoolId,
          studentId,
          AppStrings.creditType, // "CREDIT"
          'PAYMENT',
          amount,
          'USD', // Default currency for now
          null, // Not linked to invoice yet (Allocation Service handles this)
          safeReference,
          safeDescription,
          safeDate.toIso8601String(),
          DateTime.now().toIso8601String(),
        ]);

        // 3. Update Student Cache (Fees Owed)
        // We decrement the fees_owed by the payment amount
        await tx.execute('''
          UPDATE students 
          SET fees_owed = fees_owed - ?, updated_at = ? 
          WHERE id = ?
        ''', [amount, DateTime.now().toIso8601String(), studentId]);

      });

      _log.info('✅ Payment processed successfully. Ref: $safeReference');

    } catch (e, stack) {
      _log.severe('❌ ${AppStrings.paymentRepositorySaveFailed}', e, stack);
      throw Exception('Payment Engine Failure: $e');
    }
  }

  /// Helper to generate a professional-looking reference code if one is missing.
  String _generateAutoReference(String method) {
    final prefix = method.substring(0, min(3, method.length)).toUpperCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    final random = Random().nextInt(999).toString().padLeft(3, '0');
    return '$prefix-$timestamp-$random'; // e.g., CAS-4921-007
  }

  /// ==========================================================================
  /// 2. READ OPERATIONS
  /// ==========================================================================

  /// Get all payments for a specific student (History).
  Future<List<Payment>> getPaymentsByStudent(String studentId) async {
    try {
      final results = await _db.getAll(
        'SELECT * FROM payments WHERE student_id = ? ORDER BY received_at DESC',
        [studentId],
      );
      return results.map((row) => Payment.fromJson(row)).toList();
    } catch (e) {
      _log.severe('Failed to fetch student payments', e);
      return [];
    }
  }

  /// ==========================================================================
  /// 3. PREMIUM RECOVERY (CSV BACKUP)
  /// ==========================================================================

  /// Generates a CSV string of the entire financial history.
  /// This string can be saved to a file or uploaded to a secure vault.
  /// 
  /// Format: Date, Type, Student ID, Amount, Reference, Description
  Future<String> generateRecoveryCsv(String schoolId) async {
    try {
      _log.info('💾 Generating CSV Backup for School: $schoolId');

      final results = await _db.getAll('''
        SELECT 
          l.occurred_at as date,
          l.type as type,
          s.first_name || ' ' || s.last_name as student_name,
          l.amount as amount,
          l.reference_code as reference,
          l.description as description
        FROM ledger l
        LEFT JOIN students s ON l.student_id = s.id
        WHERE l.school_id = ?
        ORDER BY l.occurred_at DESC
      ''', [schoolId]);

      final buffer = StringBuffer();
      
      // Header Row
      buffer.writeln('Date,Type,Student Name,Amount,Reference,Description');

      // Data Rows
      for (var row in results) {
        final date = row['date']?.toString() ?? '';
        final type = row['type']?.toString() ?? '';
        final name = row['student_name']?.toString() ?? 'Unknown';
        final amount = row['amount']?.toString() ?? '0.00';
        final ref = row['reference']?.toString() ?? '';
        final desc = row['description']?.toString().replaceAll(',', ' ') ?? ''; // Escape commas

        buffer.writeln('$date,$type,$name,$amount,$ref,$desc');
      }

      _log.info('✅ CSV Backup Generated (${results.length} rows)');
      return buffer.toString();

    } catch (e) {
      _log.severe('❌ CSV Generation Failed', e);
      throw Exception('Failed to generate backup');
    }
  }
}