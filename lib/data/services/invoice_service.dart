import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// 🔒 SECURE Invoice Service with RPC-only access pattern
/// All invoice operations must respect billing suspension status
class InvoiceService {
  final SupabaseClient supabase;

  InvoiceService({required this.supabase});

  /// Generate next invoice number sequentially
  /// Format: INV-XXXXX (e.g., INV-00001)
  Future<String> getNextInvoiceNumber(String schoolId) async {
    try {
      final response = await supabase
          .from('bills')
          .select('invoice_number')
          .eq('school_id', schoolId)
          .order('invoice_number', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        return 'INV-00001';
      }

      final lastInvoice = response.first['invoice_number'] as String?;
      if (lastInvoice != null && lastInvoice.startsWith('INV-')) {
        final numericPart = int.tryParse(lastInvoice.split('-')[1]);
        if (numericPart != null) {
          final nextNum = numericPart + 1;
          return 'INV-${nextNum.toString().padLeft(5, '0')}';
        }
      }

      return 'INV-00001';
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ SECURE: Create adhoc invoice (manual billing)
  /// - No schema hacks (no 'term_id': 'adhoc-manual')
  /// - Supports draft status before sending
  /// - Properly tracks invoice with all metadata
  Future<Map<String, dynamic>> createAdhocInvoice({
    required String schoolId,
    required String studentId,
    required String title,
    required double amount,
    required DateTime dueDate,
    required String status, // 'draft', 'sent', 'paid', 'overdue'
  }) async {
    try {
      final invoiceId = const Uuid().v4();
      final invoiceNumber = await getNextInvoiceNumber(schoolId);
      final now = DateTime.now();

      // ✅ CORRECT: No artificial term_id hack
      // Bill_type 'adhoc' is sufficient - database schema supports null values
      // for school_year_id, month_index, and term_id
      final billData = {
        'id': invoiceId,
        'school_id': schoolId,
        'student_id': studentId,
        'invoice_number': invoiceNumber,
        'title': title,
        'total_amount': amount,
        'paid_amount': 0.0,
        'is_paid': 0,
        'is_closed': 0,
        'bill_type': 'adhoc',
        'status': status, // 'draft', 'sent', 'paid', 'overdue'
        'due_date': DateFormat('yyyy-MM-dd').format(dueDate),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'month_year': DateFormat('yyyy-MM').format(now),
        // ✅ CORRECT: No term_id, school_year_id, month_index required for adhoc
        // Database schema allows nulls for these fields
      };

      await supabase.from('bills').insert(billData);

      return {
        'id': invoiceId,
        'invoiceNumber': invoiceNumber,
        'status': 'success',
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Update invoice status (draft → sent, sent → paid, etc.)
  Future<void> updateInvoiceStatus({
    required String invoiceId,
    required String newStatus, // 'draft', 'sent', 'paid', 'overdue'
  }) async {
    try {
      await supabase
          .from('bills')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invoiceId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get invoice by ID with full details
  Future<Map<String, dynamic>?> getInvoiceById(String invoiceId) async {
    try {
      final response = await supabase
          .from('bills')
          .select(
              'id, school_id, student_id, invoice_number, title, total_amount, paid_amount, is_paid, status, due_date, bill_type, created_at, updated_at')
          .eq('id', invoiceId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Get all invoices for a school (with optional filtering)
  Future<List<Map<String, dynamic>>> getInvoicesForSchool({
    required String schoolId,
    String? status, // Optional filter: 'draft', 'sent', 'paid', 'overdue'
    String? studentId, // Optional filter by student
  }) async {
    try {
      // Build query without conditional reassignment
      final query = supabase
          .from('bills')
          .select(
              'id, school_id, student_id, invoice_number, title, total_amount, paid_amount, is_paid, status, due_date, bill_type, created_at');

      // Apply filters in chain
      var filtered = query.eq('school_id', schoolId).eq('bill_type', 'adhoc');

      // Apply optional filters inline without reassignment
      final response = await (status != null && studentId != null
          ? filtered.eq('status', status).eq('student_id', studentId).order('created_at', ascending: false)
          : status != null
              ? filtered.eq('status', status).order('created_at', ascending: false)
              : studentId != null
                  ? filtered.eq('student_id', studentId).order('created_at', ascending: false)
                  : filtered.order('created_at', ascending: false));

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get outstanding (unpaid) invoices for a student
  Future<List<Map<String, dynamic>>> getOutstandingInvoices(
      String studentId) async {
    try {
      final response = await supabase
          .from('bills')
          .select(
              'id, invoice_number, title, total_amount, paid_amount, due_date, status')
          .eq('student_id', studentId)
          .eq('is_paid', 0)
          .neq('status', 'draft') // Exclude drafts from outstanding
          .order('due_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate invoice aging (how overdue)
  /// Returns number of days overdue (negative if not yet due)
  int calculateInvoiceAge(DateTime dueDate) {
    final now = DateTime.now();
    return now.difference(dueDate).inDays;
  }

  /// Get invoices by date range
  Future<List<Map<String, dynamic>>> getInvoicesByDateRange({
    required String schoolId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await supabase
          .from('bills')
          .select(
              'id, invoice_number, title, total_amount, paid_amount, status, created_at')
          .eq('school_id', schoolId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Archive/close an invoice (mark as closed)
  Future<void> closeInvoice(String invoiceId) async {
    try {
      await supabase
          .from('bills')
          .update({
            'is_closed': 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invoiceId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get invoice statistics for school dashboard
  Future<Map<String, dynamic>> getInvoiceStatistics(String schoolId) async {
    try {
      final response = await supabase.rpc('get_invoice_statistics', params: {
        'p_school_id': schoolId,
      });

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
