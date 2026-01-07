import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/safe_data.dart';
import '../providers/students_provider.dart';

class EditStudentState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  EditStudentState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  EditStudentState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return EditStudentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class EditStudentViewModel extends StateNotifier<EditStudentState> {
  final Ref ref;

  EditStudentViewModel(this.ref) : super(EditStudentState());

  Future<void> saveChanges({
    required String studentId,
    required String fullName,
    required String parentContact,
    required String emergencyContact,
    required String address,
    required String medicalNotes,
    required List<String> subjects,
    required DateTime dob,
    required DateTime registrationDate,
    required DateTime enrollmentDate,
    required DateTime billingDate,
    required String gender,
    required String grade,
    required String billingType,
    required String termId,
    required double defaultFee,
    required bool photoConsent,
    required bool isActive,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final db = ref.read(databaseServiceProvider);

      // Validate critical fields
      if (fullName.isEmpty || fullName.length < 3) {
        state = state.copyWith(
          isLoading: false,
          error: 'Full name must be at least 3 characters',
        );
        return;
      }

      if (parentContact.isNotEmpty && !SafeData.isValidPhone(parentContact)) {
        state = state.copyWith(
          isLoading: false,
          error: 'Please enter a valid phone number',
        );
        return;
      }

      // Sanitized update data
      final updateData = {
        'full_name': SafeData.sanitize(fullName),
        'parent_contact': SafeData.sanitize(parentContact),
        'emergency_contact_name': SafeData.sanitize(emergencyContact),
        'address': SafeData.sanitize(address),
        'medical_notes': SafeData.sanitize(medicalNotes),
        'subjects': subjects.join(','),
        'date_of_birth': DateFormat('yyyy-MM-dd').format(dob),
        'registration_date': DateFormat('yyyy-MM-dd').format(registrationDate),
        'enrollment_date': DateFormat('yyyy-MM-dd').format(enrollmentDate),
        'billing_date': DateFormat('yyyy-MM-dd').format(billingDate),
        'gender': gender,
        'grade': grade,
        'billing_type': billingType,
        'term_id': termId,
        'default_fee': defaultFee,
        'photo_consent': photoConsent ? 1 : 0,
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await db.update('students', studentId, updateData);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final editStudentViewModelProvider =
    StateNotifierProvider<EditStudentViewModel, EditStudentState>((ref) {
  return EditStudentViewModel(ref);
});
