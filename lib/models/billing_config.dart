import 'dart:convert';

class TermConfig {
  String id;
  String name;
  String year;
  DateTime start;
  DateTime end;

  TermConfig({
    required this.id,
    required this.name,
    required this.year,
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'year': year,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
  };

  factory TermConfig.fromMap(Map<String, dynamic> map) => TermConfig(
    id: map['id'],
    name: map['name'],
    year: map['year'],
    start: DateTime.parse(map['start']),
    end: DateTime.parse(map['end']),
  );
}

class BillingConfig {
  String billingType;
  int cycleInterval;
  double defaultFee;
  List<TermConfig> terms;
  List<String> expenseCategories; // Mutable List
  bool autoLateFee;
  int graceDays;
  double lateFeeAmount;

  BillingConfig({
    this.billingType = 'Term-based',
    this.cycleInterval = 3,
    this.defaultFee = 0.0,
    List<TermConfig>? terms,
    List<String>? expenseCategories,
    this.autoLateFee = false,
    this.graceDays = 5,
    this.lateFeeAmount = 0.0,
  }) : // Create new mutable lists to prevent "Unsupported operation" crash
       terms = terms ?? [],
       expenseCategories =
           expenseCategories ??
           ['Salary', 'Maintenance', 'Supplies', 'Utilities'];

  String toJson() => jsonEncode({
    'billingType': billingType,
    'cycleInterval': cycleInterval,
    'defaultFee': defaultFee,
    'terms': terms.map((x) => x.toMap()).toList(),
    'expenseCategories': expenseCategories,
    'autoLateFee': autoLateFee,
    'graceDays': graceDays,
    'lateFeeAmount': lateFeeAmount,
  });

  factory BillingConfig.fromJson(String source) {
    final map = jsonDecode(source);
    return BillingConfig(
      billingType: map['billingType'] ?? 'Term-based',
      cycleInterval: map['cycleInterval'] ?? 3,
      defaultFee: (map['defaultFee'] as num?)?.toDouble() ?? 0.0,
      terms: (map['terms'] as List?)
          ?.map((x) => TermConfig.fromMap(x))
          .toList(),
      expenseCategories: List<String>.from(map['expenseCategories'] ?? []),
      autoLateFee: map['autoLateFee'] ?? false,
      graceDays: map['graceDays'] ?? 5,
      lateFeeAmount: (map['lateFeeAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}