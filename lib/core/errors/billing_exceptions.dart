class BillingSuspendedException implements Exception {
  final String message;
  BillingSuspendedException(
      [this.message =
          'Billing operations are currently suspended for this school.']);

  @override
  String toString() => 'BillingSuspendedException: $message';
}

class BillingEnginePermissionException implements Exception {
  final String message;
  BillingEnginePermissionException(
      [this.message =
          'Only the billing engine device can perform this operation.']);

  @override
  String toString() => 'BillingEnginePermissionException: $message';
}
