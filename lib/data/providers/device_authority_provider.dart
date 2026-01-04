import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/device_authority_service.dart';

/// Provider for DeviceAuthorityService singleton
final deviceAuthorityProvider = Provider<DeviceAuthorityService>((ref) {
  return DeviceAuthorityService();
});

/// Check if current device is the billing engine for the given school
final isBillingEngineProvider =
    FutureProvider.family<bool, String>((ref, schoolId) async {
  final deviceAuthority = ref.watch(deviceAuthorityProvider);
  return await deviceAuthority.isBillingEngineForSchool(schoolId);
});

/// Get the active billing engine device for a school (if any)
final activeBillingEngineProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, schoolId) async {
  final deviceAuthority = ref.watch(deviceAuthorityProvider);
  return await deviceAuthority.getActiveBillingEngineForSchool(schoolId);
});
