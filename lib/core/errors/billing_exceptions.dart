class BillingSuspendedException implements Exception {
  final String message;
  BillingSuspendedException(
      [this.message =
          'Billing operations are currently suspended for this school.']);

  @override
  String toString() => 'BillingSuspendedException: $message';
}
