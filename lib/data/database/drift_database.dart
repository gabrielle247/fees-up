import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'drift_database.g.dart';

// ============================================================================
// TABLES
// ============================================================================

class Schools extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get subdomain => text()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get currentPlanId => text().nullable()();
  TextColumn get subscriptionStatus =>
      text().withDefault(const Constant('ACTIVE'))();
  DateTimeColumn get subscriptionEndsAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Students extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get gender => text().nullable()();
  TextColumn get nationalId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('ACTIVE'))();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Enrollments extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get studentId => text()();
  TextColumn get academicYearId => text()();
  TextColumn get gradeLevel => text()();
  TextColumn get classStream => text().nullable()();
  TextColumn get snapshotGrade => text().nullable()();
  TextColumn get targetGrade => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get enrolledAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class FeeCategories extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class FeeStructures extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get academicYearId => text()();
  TextColumn get name => text()();
  TextColumn get targetGrade => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  IntColumn get amount => integer()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  TextColumn get recurrence => text().withDefault(const Constant('TERM'))();
  TextColumn get billingType => text().withDefault(const Constant('FIXED'))();
  TextColumn get billableMonths => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get suspensions => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get studentId => text()();
  TextColumn get invoiceNumber => text()();
  TextColumn get termId => text().nullable()();
  TextColumn get snapshotGrade => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('ISSUED'))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text()();
  TextColumn get description => text()();
  IntColumn get amount => integer()();
  TextColumn get feeStructureId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get studentId => text()();
  IntColumn get amount => integer()();
  TextColumn get method => text()();
  TextColumn get referenceCode => text().nullable()();
  DateTimeColumn get receivedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LedgerEntries extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get studentId => text()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  IntColumn get amount => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get invoiceId => text().nullable()();
  TextColumn get referenceCode => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// DATABASE
// ============================================================================

@DriftDatabase(tables: [
  Schools,
  Students,
  Enrollments,
  FeeCategories,
  FeeStructures,
  Invoices,
  InvoiceItems,
  Payments,
  LedgerEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'fees_up.db'));

      // For Android, ensure sqlite3 is properly initialized
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
        sqlite3.tempDirectory = (await getTemporaryDirectory()).path;
      }

      return NativeDatabase.createInBackground(file);
    });
  }
}
