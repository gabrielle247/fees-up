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
  final String grade; // <--- ADDED FIELD
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
    this.grade = 'Form 1', // <--- DEFAULT VALUE
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
    String? grade, // <--- ADDED
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
      grade: grade ?? this.grade, // <--- ADDED
      monthlyFee: monthlyFee ?? this.monthlyFee,
      initialPayment: initialPayment ?? this.initialPayment,
      subjects: subjects ?? this.subjects,
      frequency: frequency ?? this.frequency,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }
}

// --- PROVIDER ---
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
  
  // <--- NEW GRADE UPDATER
  void updateGrade(String val) => state = state.copyWith(grade: val);

  void updateFee(String val) => state = state.copyWith(monthlyFee: double.tryParse(val) ?? 0.0);
  void updateInitialPayment(String val) => state = state.copyWith(initialPayment: double.tryParse(val) ?? 0.0);
  void updateSubjects(List<String> val) => state = state.copyWith(subjects: val);
  
  void updateFrequency(String val) {
    state = state.copyWith(frequency: val);
    updateDate(state.registrationDate); 
  }

  void updateDate(DateTime date) {
    // Logic: For Monthly, restrict to 1-28
    if (state.frequency == 'Monthly') {
      if (date.day > 28) {
        final corrected = DateTime(date.year, date.month, 28);
        state = state.copyWith(registrationDate: corrected);
      } else {
        state = state.copyWith(registrationDate: date);
      }
    } else {
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
        grade: state.grade, // <--- USE SELECTED GRADE
        parentContact: state.parentContact,
        registrationDate: state.registrationDate,
        defaultMonthlyFee: state.monthlyFee,
        subjects: state.subjects,
        isActive: true,
      );

      await _studentRepo.addStudent(student);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}