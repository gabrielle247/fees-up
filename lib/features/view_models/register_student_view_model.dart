import 'package:fees_up/features/students/data/student_model.dart';
import 'package:fees_up/features/students/data/student_repository.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

// --- STATE CLASS ---
class RegisterStudentState {
  final bool isLoading;
  final String? error;
  
  // Form Fields
  final String fullName;
  final String parentContact;
  final double monthlyFee;
  final double initialPayment;
  final List<String> subjects;
  final String frequency; // 'Monthly', 'Termly', 'Annually'
  final DateTime registrationDate;

  const RegisterStudentState({
    this.isLoading = false,
    this.error,
    this.fullName = '',
    this.parentContact = '',
    this.monthlyFee = 0.0,
    this.initialPayment = 0.0,
    this.subjects = const [],
    this.frequency = 'Monthly',
    required this.registrationDate,
  });

  RegisterStudentState copyWith({
    bool? isLoading,
    String? error,
    String? fullName,
    String? parentContact,
    double? monthlyFee,
    double? initialPayment,
    List<String>? subjects,
    String? frequency,
    DateTime? registrationDate,
  }) {
    return RegisterStudentState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      fullName: fullName ?? this.fullName,
      parentContact: parentContact ?? this.parentContact,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      initialPayment: initialPayment ?? this.initialPayment,
      subjects: subjects ?? this.subjects,
      frequency: frequency ?? this.frequency,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }
}

// --- PROVIDER ---
// This is the variable your screen is looking for!
final registerStudentControllerProvider = 
    StateNotifierProvider.autoDispose<RegisterStudentController, RegisterStudentState>((ref) {
  return RegisterStudentController();
});

// --- CONTROLLER ---
class RegisterStudentController extends StateNotifier<RegisterStudentState> {
  final StudentRepository _studentRepo = StudentRepository();
  final Uuid _uuid = const Uuid();

  RegisterStudentController() 
      : super(RegisterStudentState(registrationDate: DateTime.now()));

  // --- FIELD UPDATERS ---
  void updateName(String val) => state = state.copyWith(fullName: val);
  void updateContact(String val) => state = state.copyWith(parentContact: val);
  void updateFee(String val) => state = state.copyWith(monthlyFee: double.tryParse(val) ?? 0.0);
  void updateInitialPayment(String val) => state = state.copyWith(initialPayment: double.tryParse(val) ?? 0.0);
  void updateSubjects(List<String> val) => state = state.copyWith(subjects: val);
  
  void updateFrequency(String val) {
    state = state.copyWith(frequency: val);
    // Re-validate date logic when frequency changes
    updateDate(state.registrationDate); 
  }

  void updateDate(DateTime date) {
    // 🧠 LOGIC: For Monthly, restrict to 1-28
    if (state.frequency == 'Monthly') {
      if (date.day > 28) {
        // Auto-correct to the 28th of that month
        final corrected = DateTime(date.year, date.month, 28);
        state = state.copyWith(registrationDate: corrected);
      } else {
        state = state.copyWith(registrationDate: date);
      }
    } else {
      // Annual/Termly can be any day
      state = state.copyWith(registrationDate: date);
    }
  }

  // --- SAVE LOGIC ---
  Future<bool> register() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newId = _uuid.v4();
      
      final student = Student(
        id: newId,
        fullName: state.fullName,
        grade: "Form 1", // TODO: Add Grade Picker if needed
        parentContact: state.parentContact,
        registrationDate: state.registrationDate,
        defaultMonthlyFee: state.monthlyFee,
        subjects: state.subjects,
        isActive: true,
      );

      await _studentRepo.addStudent(student);

      // TODO: Here we would trigger the Payment Logic for 'initialPayment'
      // await _billingService.processInitialPayment(student, state.initialPayment);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}