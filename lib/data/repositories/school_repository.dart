import 'package:logging/logging.dart';
import 'package:powersync/powersync.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import '../models/all_models.dart';
import '../constants/app_strings.dart';

class SchoolRepository {
  final PowerSyncDatabase _db;
  final Logger _log = Logger('SchoolRepository');

  SchoolRepository(this._db);

  /// ==========================================================================
  /// 1. CREATE
  /// ==========================================================================

  /// Creates a new school record. 
  /// Usually called during the onboarding/setup phase.
  Future<void> createSchool(School school) async {
    try {
      _log.info('Creating school: ${school.name} (${school.id})');
      
      await _db.execute('''
        INSERT INTO schools (
          id, 
          name, 
          subdomain, 
          logo_url, 
          current_plan_id, 
          subscription_status, 
          valid_until, 
          address_line1, 
          city, 
          country, 
          phone_number, 
          email_address, 
          tax_id, 
          website, 
          created_at, 
          updated_at, 
          owner_id
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        school.id,
        school.name,
        school.subdomain,
        school.logoUrl,
        school.currentPlanId,
        school.subscriptionStatus,
        school.validUntil?.toIso8601String(),
        school.addressLine1,
        school.city,
        school.country,
        school.phoneNumber,
        school.emailAddress,
        school.taxId,
        school.website,
        school.createdAt.toIso8601String(),
        DateTime.now().toIso8601String(), // updated_at
        school.ownerId,
      ]);
      
      _log.info('✅ School created successfully');
    } catch (e, stack) {
      _log.severe('❌ ${AppStrings.schoolRepositorySaveFailed}', e, stack);
      throw Exception(AppStrings.schoolRepositorySaveFailed);
    }
  }

  /// ==========================================================================
  /// 2. READ
  /// ==========================================================================

  /// Fetches a specific school by ID.
  Future<School?> getSchoolById(String schoolId) async {
    try {
      final result = await _db.getOptional(
        'SELECT * FROM schools WHERE id = ?', 
        [schoolId]
      );

      if (result == null) return null;
      return School.fromJson(result);
    } catch (e, stack) {
      _log.severe('❌ Failed to fetch school by ID', e, stack);
      throw Exception(AppStrings.genericError);
    }
  }

  /// Fetches the school owned by a specific user.
  /// Used during login to determine if the user has completed setup.
  Future<School?> getSchoolByOwner(String ownerId) async {
    try {
      final result = await _db.getOptional(
        'SELECT * FROM schools WHERE owner_id = ? LIMIT 1', 
        [ownerId]
      );

      if (result == null) return null;
      return School.fromJson(result);
    } catch (e, stack) {
      _log.severe('❌ Failed to fetch school by Owner', e, stack);
      throw Exception(AppStrings.genericError);
    }
  }

  /// Gets the first available school in the local database.
  /// Useful for offline-first scenarios where we assume 1 device = 1 school context.
  Future<School?> getLocalSchool() async {
    try {
      final result = await _db.getOptional('SELECT * FROM schools LIMIT 1');
      
      if (result == null) return null;
      return School.fromJson(result);
    } catch (e, stack) {
      _log.severe('❌ ${AppStrings.schoolRepositoryGetCurrentSchoolFailed}', e, stack);
      throw Exception(AppStrings.schoolRepositoryGetCurrentSchoolFailed);
    }
  }

  /// ==========================================================================
  /// 3. UPDATE
  /// ==========================================================================

  /// Updates school details (Settings/Configs).
  Future<void> updateSchool(School school) async {
    try {
      _log.info('Updating school: ${school.id}');

      await _db.execute('''
        UPDATE schools SET 
          name = ?, 
          subdomain = ?, 
          logo_url = ?, 
          address_line1 = ?, 
          city = ?, 
          country = ?, 
          phone_number = ?, 
          email_address = ?, 
          tax_id = ?, 
          website = ?, 
          updated_at = ?
        WHERE id = ?
      ''', [
        school.name,
        school.subdomain,
        school.logoUrl,
        school.addressLine1,
        school.city,
        school.country,
        school.phoneNumber,
        school.emailAddress,
        school.taxId,
        school.website,
        DateTime.now().toIso8601String(), // updated_at
        school.id
      ]);

      _log.info('✅ School updated successfully');
    } catch (e, stack) {
      _log.severe('❌ Failed to update school', e, stack);
      throw Exception(AppStrings.genericError);
    }
  }

  /// Updates the subscription plan for the school.
  Future<void> updateSubscription(String schoolId, String planId, String status, DateTime? validUntil) async {
    try {
      await _db.execute('''
        UPDATE schools SET 
          current_plan_id = ?, 
          subscription_status = ?, 
          valid_until = ?, 
          updated_at = ?
        WHERE id = ?
      ''', [
        planId,
        status,
        validUntil?.toIso8601String(),
        DateTime.now().toIso8601String(),
        schoolId
      ]);
      _log.info('✅ Subscription updated for school: $schoolId');
    } catch (e) {
      _log.severe('❌ Failed to update subscription: $e');
      throw Exception(AppStrings.genericError);
    }
  }

  /// ==========================================================================
  /// 4. DELETE
  /// ==========================================================================

  /// Deletes the school locally.
  /// Note: Permissions usually prevent this on the server unless you are Super Admin.
  Future<void> deleteSchool(String schoolId) async {
    try {
      await _db.execute('DELETE FROM schools WHERE id = ?', [schoolId]);
      _log.warning('⚠️ School deleted locally: $schoolId');
    } catch (e) {
      _log.severe('❌ Failed to delete school: $e');
      throw Exception(AppStrings.genericError);
    }
  }
}