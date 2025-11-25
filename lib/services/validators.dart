class Validators {
  // 1. STRICT MONEY VALIDATION ($0.50 - $500.00)
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

    // ✅ CEILING CHECK (Prevents anomalies/typos)
    if (number > 500.00) {
      return 'Maximum amount is \$500.00';
    }

    return null;
  }

  // 2. OPTIONAL MONEY VALIDATION (For fields that can be 0 or empty)
  // Useful for "Initial Payment" during registration
  static String? validateOptionalMoney(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Empty is valid (treated as 0)
    }
    
    final number = double.tryParse(value);
    if (number == null) return 'Invalid number';
    
    // If they type something, it must follow rules, 
    // BUT 0.00 is allowed here.
    if (number == 0) return null; 

    // Otherwise enforce limits
    if (number < 0.50) return 'Min is \$0.50 (or 0)';
    if (number > 500.00) return 'Max is \$500.00';
    
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
}