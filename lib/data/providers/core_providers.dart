import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../services/isar_service.dart';

/// Provides the initialized Isar instance.
/// Throws an error if IsarService hasn't been initialized yet.
final isarInstanceProvider = Provider<Future<Isar>>((ref) async {
  return IsarService().db;
});
