class Validators {
  // 1. STRICT MONEY VALIDATION ($0.50 - $5,000.00)
  static String? validateMoney(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }

    // Check format (allows 10, 10.5, 10.50)
    final validMoneyRegex = RegExp(r'^\d*\.?\d+$');
    if (!validMoneyRegex.hasMatch(value)) {
      return 'Invalid format (e.g. 10.50)';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Invalid number';
    }

    // ✅ FLOOR CHECK
    if (number < 0.50) {
      return 'Minimum amount is \$0.50';
    }

    // ✅ CEILING CHECK (Adjusted for School Fees context)
    if (number > 5000.00) {
      return 'Maximum amount is \$5,000.00';
    }

    return null;
  }

  // 2. OPTIONAL MONEY VALIDATION (For fields that can be 0 or empty)
  static String? validateOptionalMoney(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Empty is valid (treated as 0)
    }

    final number = double.tryParse(value);
    if (number == null) return 'Invalid number';

    // If they type something, 0.00 is allowed here.
    if (number == 0) return null;

    if (number < 0.50) return 'Min is \$0.50 (or 0)';
    if (number > 5000.00) return 'Max is \$5,000.00';

    return null;
  }

  // 3. NAME VALIDATION
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name is too short';
    }
    return null;
  }

  // 4. PHONE VALIDATION
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final cleanValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final phoneRegex = RegExp(r'^\+?[0-9]{9,15}$');

    if (!phoneRegex.hasMatch(cleanValue)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // 5. EMAIL VALIDATION
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[A-Za-z]{2,}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter a valid email address";
    }

    return null;
  }

  // 6. PASSWORD VALIDATION
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }
}