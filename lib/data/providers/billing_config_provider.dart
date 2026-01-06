import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../services/database_service.dart';

const _uuid = Uuid();
const _defaultBillingConfig = <String, dynamic>{
  'currency_code': 'USD',
  'tax_rate_percentage': 0.0,
  'registration_fee': 0.0,
  'grace_period_days': 7,
  'invoice_prefix': 'INV-',
  'invoice_sequence_seed': 1000,
  'late_fee_percentage': 0.0,
  'invoice_footer_note': '',
  'allow_partial_payments': 1,
  'default_fee': 0.0,
};

final billingConfigProvider = StateNotifierProvider.autoDispose.family<
    BillingConfigNotifier, AsyncValue<Map<String, dynamic>>, String>(
  (ref, schoolId) {
    final notifier = BillingConfigNotifier(DatabaseService(), schoolId);
    notifier.load();
    return notifier;
  },
);

class BillingConfigNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  BillingConfigNotifier(this._db, this.schoolId)
      : super(const AsyncLoading());

  final DatabaseService _db;
  final String schoolId;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final result = await _db.db.getAll(
        'SELECT * FROM billing_configs WHERE school_id = ? LIMIT 1',
        [schoolId],
      );
      if (result.isNotEmpty) {
        state = AsyncData(result.first);
      } else {
        state = const AsyncData(_defaultBillingConfig);
      }
    } catch (e, st) {
      debugPrint('⚠️ Failed to load billing config: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> saveConfig({
    required String currencyCode,
    required double taxRate,
    required double registrationFee,
    required int gracePeriodDays,
    required String invoicePrefix,
    required int invoiceSequenceSeed,
    required double lateFeePercentage,
    required double defaultFee,
    required bool allowPartialPayments,
    required String invoiceFooterNote,
  }) async {
    try {
      final existing = await _db.db.getAll(
        'SELECT id FROM billing_configs WHERE school_id = ? LIMIT 1',
        [schoolId],
      );

      final payload = <String, dynamic>{
        'school_id': schoolId,
        'currency_code': currencyCode,
        'tax_rate_percentage': taxRate,
        'registration_fee': registrationFee,
        'grace_period_days': gracePeriodDays,
        'invoice_prefix': invoicePrefix,
        'invoice_sequence_seed': invoiceSequenceSeed,
        'late_fee_percentage': lateFeePercentage,
        'default_fee': defaultFee,
        'allow_partial_payments': allowPartialPayments ? 1 : 0,
        'invoice_footer_note': invoiceFooterNote,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existing.isEmpty) {
        await _db.insert('billing_configs', {
          'id': _uuid.v4(),
          ...payload,
        });
      } else {
        await _db.update(
          'billing_configs',
          existing.first['id'] as String,
          payload,
        );
      }

      await load();
    } catch (e, st) {
      debugPrint('❌ Failed to save billing config: $e');
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
