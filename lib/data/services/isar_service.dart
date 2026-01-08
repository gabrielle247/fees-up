import 'package:cryptography/cryptography.dart';
import 'package:isar/isar.dart';
import 'dart:io';

import '../models/access.dart';
import '../models/finance.dart';
import '../models/people.dart';
import '../models/saas.dart';
import 'crypto_service.dart';

class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  late Future<Isar> db;
  static late String _dbPath;
  SecretKey? _userKey;

  /// Initialize with custom path (cross-platform compatible)
  /// If no path provided, uses current directory (works everywhere)
  Future<void> initialize(
      {String? customPath, required String email, required String uid}) async {
    _dbPath = customPath ?? Directory.current.path;
    _userKey = await CryptoService.deriveUserKey(email: email, uid: uid);
    db = _openVault();
  }

  Future<Isar> _openVault() async {
    // OPEN THE VAULT (encryption handled at app layer via CryptoService)
    if (Isar.instanceNames.isEmpty) {
      try {
        final isar = await Isar.open(
          [
            // SAAS
            PlanSchema,
            SchoolSchema,
            // ACCESS
            RoleSchema,
            ProfileSchema,
            // PEOPLE
            AcademicYearSchema,
            StudentSchema,
            EnrollmentSchema,
            // FINANCE (ERP)
            FeeCategorySchema,
            FeeStructureSchema,
            InvoiceSchema,
            InvoiceItemSchema,
            LedgerEntrySchema,
            PaymentSchema,
            PaymentAllocationSchema,
          ],
          directory: _dbPath,
          inspector: false,
        );
        // AppLogger.success('Isar vault opened successfully');
        return isar;
      } catch (e) {
        // AppLogger.error('Failed to open Isar vault', e);
        rethrow;
      }
    }

    return Future.value(Isar.getInstance());
  }

  // ===========================================================================
  // DATA ACCESS HELPERS
  // ===========================================================================

  /// Get the DB instance
  Future<Isar> get _isar => db;

  /// Expose derived user key for application-level encryption.
  SecretKey? get userKey => _userKey;

  /// Fast cleaner for logout
  Future<void> wipeLocalData() async {
    try {
      final isar = await _isar;
      await isar.writeTxn(() async {
        await isar.clear();
      });
      // AppLogger.success('Local data wiped successfully');
    } catch (e) {
      // AppLogger.error('Failed to wipe local data', e);
      rethrow;
    }
  }

  /// Safely close the vault (call on app shutdown)
  Future<void> closeVault() async {
    try {
      final isar = await _isar;
      await isar.close();
      // AppLogger.success('Isar vault closed successfully');
    } catch (e) {
      // AppLogger.error('Failed to close vault', e);
      rethrow;
    }
  }
}
