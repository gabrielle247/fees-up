/// Broadcast feed filter types.
///
/// This enum replaces string literals ('All', 'System', 'Internal') with
/// compile-time safe, type-checked filter values.
///
/// **Before (Stringly-Typed - Unsafe):**
/// ```dart
/// String _filter = 'All'; // ❌ Typo: if you wrote 'AL' by mistake, no compile error!
/// if (_filter == 'Internal') { ... } // ❌ Fragile string comparison
/// if (_filter == 'Internak') { ... } // ❌ Silent bug - condition never true
/// ```
///
/// **After (Enum - Safe):**
/// ```dart
/// BroadcastFilter _filter = BroadcastFilter.all;
/// switch (_filter) {
///   case BroadcastFilter.all => ...,
///   case BroadcastFilter.system => ...,
///   case BroadcastFilter.internal => ...,
/// } // ✅ Compiler ensures all cases handled
/// ```
enum BroadcastFilter {
  /// Show all broadcasts (school + internal HQ messages)
  all('All'),

  /// Show only system-level announcements
  system('System'),

  /// Show only internal HQ messages
  internal('Internal');

  /// Human-readable display name
  final String displayName;

  const BroadcastFilter(this.displayName);

  /// Get filter from display name (for UI deserialization)
  ///
  /// Example: When deserializing from user preferences
  /// ```dart
  /// final saved = 'Internal';
  /// final filter = BroadcastFilter.fromDisplayName(saved);
  /// ```
  static BroadcastFilter fromDisplayName(String name) {
    try {
      return BroadcastFilter.values.firstWhere(
        (f) => f.displayName == name,
        orElse: () => BroadcastFilter.all,
      );
    } catch (e) {
      return BroadcastFilter.all;
    }
  }

  /// Check if this filter matches a broadcast
  ///
  /// Returns true if the broadcast should be shown when this filter is active
  bool matches(bool isSystemMessage, bool isInternalHQ) {
    switch (this) {
      case BroadcastFilter.all:
        // All filter shows everything
        return true;

      case BroadcastFilter.system:
        // System filter shows only system messages
        return isSystemMessage;

      case BroadcastFilter.internal:
        // Internal filter shows only internal HQ messages
        return isInternalHQ;
    }
  }
}

/// Extension for convenient string conversion
extension BroadcastFilterExt on BroadcastFilter {
  /// Get the broadcast provider to watch based on filter
  ///
  /// Example usage in BroadcastList:
  /// ```dart
  /// final provider = _filter.getProvider(); // Returns correct provider
  /// final feedAsync = ref.watch(provider);
  /// ```
  ///
  /// This is used with Riverpod's "Fortress Stream" pattern to
  /// dynamically switch between providers based on user's filter selection
  String getProviderName() {
    switch (this) {
      case BroadcastFilter.internal:
        return 'internalHQBroadcastProvider';
      case BroadcastFilter.all:
      case BroadcastFilter.system:
        return 'schoolBroadcastProvider';
    }
  }
}
