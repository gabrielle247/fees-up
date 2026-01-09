class SyncState {
  final bool inProgress;
  final DateTime? lastSuccessAt;
  final String? lastError;

  const SyncState({
    required this.inProgress,
    this.lastSuccessAt,
    this.lastError,
  });

  SyncState copyWith({
    bool? inProgress,
    DateTime? lastSuccessAt,
    String? lastError,
  }) =>
      SyncState(
        inProgress: inProgress ?? this.inProgress,
        lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
        lastError: lastError,
      );

  static const initial = SyncState(inProgress: false);
}
