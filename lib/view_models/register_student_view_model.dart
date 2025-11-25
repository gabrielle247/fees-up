import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';

class RegisterStudentViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();

  // --- FORM STATE ---
  String studentName = '';
  String parentContact = '';
  List<String> selectedSubjects = [];
  double negotiatedFee = 0.0;
  double initialPayment = 0.0;

  // 🔒 LOCKED: We force this to Monthly for now.
  final String frequency = 'Monthly';

  // --- SETTERS ---
  void updateStudentName(String val) {
    studentName = val;
    notifyListeners();
  }

  void updateParentContact(String val) {
    parentContact = val;
    notifyListeners();
  }

  void updateSelectedSubjects(List<String> val) {
    selectedSubjects = val;
    notifyListeners();
  }

  void updateNegotiatedFee(String val) {
    negotiatedFee = double.tryParse(val) ?? 0.0;
    notifyListeners();
  }

  void updateInitialPayment(String val) {
    initialPayment = double.tryParse(val) ?? 0.0;
    notifyListeners();
  }

  // (Removed updateFrequency to prevent changes)

  // --- VALIDATION ---
  bool validate() {
    return studentName.isNotEmpty &&
        negotiatedFee > 0 &&
        selectedSubjects.isNotEmpty;
  }

  // --- SAVE LOGIC ---
  Future<String?> registerStudent() async {
    if (!validate()) return null;

    return await _storageService.registerNewStudent(
      name: studentName,
      fee: negotiatedFee,
      initialPayment: initialPayment,
      parentContact: parentContact,
      subjects: selectedSubjects,
      frequency: frequency, // 🔒 Always passes 'Monthly'
    );
  }
}
