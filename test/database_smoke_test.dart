import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fees_up/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final tempDir = await Directory.systemTemp.createTemp('fees_up_db_test');
    await databaseFactory.setDatabasesPath(tempDir.path);
  });

  test('database opens and core tables exist', () async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    final names = rows.map((row) => row['name'] as String).toSet();

    expect(names.contains('schools'), isTrue);
    expect(names.contains('user_profiles'), isTrue);
    expect(names.contains('students'), isTrue);
    expect(names.contains('bills'), isTrue);
    expect(names.contains('payments'), isTrue);
    expect(names.contains('classes'), isTrue);
    expect(names.contains('enrollments'), isTrue);
    expect(names.contains('attendance'), isTrue);
    expect(names.contains('expenses'), isTrue);
    expect(names.contains('campaigns'), isTrue);
    expect(names.contains('sync_queue'), isTrue);
    expect(names.contains('student_archives'), isTrue);
  });
}
