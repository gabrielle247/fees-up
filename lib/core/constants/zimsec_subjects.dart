// Core Reference File for ZIMSEC Curriculum
class ZimsecSubject {
  static const Map<int, String> _codeMap = {
    // ---------------------------------------------------------
    // FORM 1 - 4 (O-LEVEL)
    // ---------------------------------------------------------
    
    // --- CORE (Compulsory for most) ---
    4005: 'English Language',
    4004: 'Mathematics',
    4003: 'Combined Science', // Replaces Integrated Science
    4006: 'Heritage Studies',
    4007: 'Shona',
    4068: 'Ndebele',
    4001: 'Agriculture',

    // --- COMMERCIALS ---
    4049: 'Commerce',
    4051: 'Principles of Accounting',
    4048: 'Business Enterprise Skills',
    4033: 'Economics (O-Level)',

    // --- HUMANITIES & ARTS ---
    4037: 'Geography',
    4044: 'History',
    4047: 'Family & Religious Studies', // F.R.S
    4008: 'Literature in English',
    4009: 'Literature in Shona',
    4010: 'Literature in Ndebele',
    4063: 'Sociology',

    // --- SCIENCES & TECH ---
    4029: 'Computer Science',
    4025: 'Biology',
    4023: 'Physics',
    4024: 'Chemistry',
    4059: 'Wood Technology and Design',
    4062: 'Metal Technology and Design',
    4057: 'Food Technology and Design',
    4034: 'Technical Graphics',
    4030: 'Statistics',
    4055: 'Building Technology',
    4052: 'Fashion and Fabrics',

    // ---------------------------------------------------------
    // FORM 5 - 6 (A-LEVEL)
    // ---------------------------------------------------------

    // --- COMMERCIALS ---
    6001: 'Accounting',
    6025: 'Business Studies',
    6073: 'Economics',
    6035: 'Management of Business (MOB)', // Legacy/Still Used

    // --- HUMANITIES & ARTS ---
    6022: 'Geography',
    6006: 'History',
    6003: 'Divinity',
    6009: 'Literature in English',
    6081: 'Heritage Studies',
    6010: 'Shona (A-Level)',
    6011: 'Ndebele (A-Level)',
    6036: 'Sociology (A-Level)',
    6070: 'Family & Religious Studies (A-Level)',

    // --- SCIENCES ---
    6042: 'Pure Mathematics',
    6030: 'Biology',
    6031: 'Chemistry',
    6032: 'Physics',
    6046: 'Statistics',
    6008: 'Computer Science',
    6015: 'Crop Science',
    6016: 'Animal Science',
    6017: 'Mechanical Mathematics',
    6020: 'Further Mathematics',
    6080: 'Sports Science',
    6050: 'Design and Technology',
  };

  // ignore: unintended_html_in_doc_comment
  /// Returns a simple List<String> of all subject names for dropdowns.
  static List<String> get allNames => _codeMap.values.toList()..sort();

  /// Helper to get a name by code (useful if you store codes in DB later)
  static String nameFromCode(int code) => _codeMap[code] ?? 'Unknown Subject';
}