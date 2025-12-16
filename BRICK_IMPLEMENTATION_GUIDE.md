# Brick Offline-First Implementation Guide

## Overview
This implementation provides an encrypted, offline-first data sync system using Brick with Supabase backend. Your local database files are encrypted using SQLCipher with keys stored in secure storage.

## 🔐 Security Features
- **Encrypted SQLite Database**: Uses SQLCipher for database encryption
- **Secure Key Storage**: Encryption keys stored in Flutter Secure Storage
- **Automatic Key Generation**: Keys are generated securely on first run
- **Re-encryption Support**: Can change encryption keys without data loss

## 📁 Project Structure
```
lib/brick/
├── brick.g.dart                    # Main Brick configuration
├── db/
│   └── encrypted_database_helper.dart  # Encryption & DB management
├── repository/
│   └── brick_repository.dart       # Singleton repository manager
└── adapters/                       # Auto-generated adapters (after build_runner)
    └── *.g.dart
```

## 🚀 Getting Started

### Step 1: Update Your Models
Create Brick-annotated versions of your models (see `lib/models/student_brick.dart` as example):

```dart
@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'students'),
)
class Student extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  @Sqlite(unique: true)
  final String id;
  
  // ... other fields with annotations
}
```

### Step 2: Generate Adapters
Run the build_runner to generate adapters:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- Model adapters in `lib/brick/adapters/`
- Updated `brick.g.dart` with model dictionary

### Step 3: Update brick.g.dart
After generation, uncomment the imports and model dictionary entries in `lib/brick/brick.g.dart`.

### Step 4: Use the Repository

```dart
import 'package:fees_up/brick/repository/brick_repository.dart';
import 'package:fees_up/models/student_brick.dart';

// Get repository instance
final repo = BrickRepository.instance;

// Get all students (offline-first)
final students = await repo.getAll<Student>();

// Get single student
final student = await repo.get<Student>('student-id-123');

// Create/Update student
final newStudent = Student(id: '123', fullName: 'John Doe');
await repo.upsert(newStudent);

// Delete student
await repo.delete(student);

// Force remote fetch
final freshStudents = await repo.getAll<Student>(requireRemote: true);

// Subscribe to real-time changes
await repo.subscribe<Student>(
  onData: (students) {
    print('Students updated: ${students.length}');
  },
  onError: (error) {
    print('Error: $error');
  },
);
```

## 🔄 Sync Behavior

### Offline-First Strategy
1. **Reads**: Always try local DB first, fallback to Supabase if `requireRemote: true`
2. **Writes**: Save to local DB immediately, queue for Supabase sync
3. **Conflict Resolution**: Last-write-wins by default (configurable)

### Manual Sync
```dart
// Sync specific model type
await repo.sync<Student>();

// Check offline queue
print('Pending syncs: ${repo.offlineQueueLength}');
```

## 🔒 Encryption Management

### View Current Encryption Status
```dart
final helper = EncryptedDatabaseHelper();
final isValid = await helper.verifyIntegrity();
print('Database integrity: $isValid');
```

### Change Encryption Key
```dart
final helper = EncryptedDatabaseHelper();
await helper.changeEncryptionKey('new-secure-key-here');
```

### Reset Everything (Logout/Clear Data)
```dart
await BrickRepository.instance.reset();
// This deletes DB, clears encryption key, resets repository
```

## 📊 Model Conversion

Since you have existing code using the old models, the Brick models include conversion helpers:

```dart
// Convert TO Brick model
final brickStudent = Student.fromStudentModel(existingStudentModel);
await repo.upsert(brickStudent);

// Convert FROM Brick model
final legacyStudent = brickStudent.toStudentModel();
// Use with existing code
```

## 🎯 Migration Strategy

### Gradual Migration
You don't need to migrate everything at once:

1. Keep existing models and repositories
2. Create Brick versions alongside (e.g., `student_brick.dart`)
3. Gradually migrate features to use Brick
4. Use conversion helpers for compatibility

### Example Service Pattern
```dart
class StudentService {
  final repo = BrickRepository.instance;
  
  Future<List<StudentModel>> getStudents() async {
    final brickStudents = await repo.getAll<Student>();
    return brickStudents.map((s) => s.toStudentModel()).toList();
  }
  
  Future<void> saveStudent(StudentModel model) async {
    final brickStudent = Student.fromStudentModel(model);
    await repo.upsert(brickStudent);
  }
}
```

## ⚙️ Configuration

### Database Location
Default: `{ApplicationDocumentsDirectory}/brick_dbs/fees_up_brick.db`

Change in `encrypted_database_helper.dart`:
```dart
static const String _databaseName = 'your_db_name.db';
```

### Encryption Key Storage
Keys stored in: `FlutterSecureStorage` with key `brick_db_encryption_key`

### Supabase Configuration
Set in `assets/keys.env`:
```env
SUPABASE_URL=your-url
SUPABASE_ANON_KEY=your-key
```

## 🐛 Debugging

### Enable Verbose Logging
Check console for:
- `Initializing encrypted database at: ...`
- `Brick repository initialized successfully`
- `Sync completed for Student`

### Common Issues

**"Database not initialized"**
- Ensure `BrickRepository.instance.initialize()` is called in `main()`

**"Missing Supabase keys"**
- Check `assets/keys.env` file exists and has correct keys

**"Failed to generate adapters"**
- Run: `flutter pub run build_runner clean`
- Then: `flutter pub run build_runner build --delete-conflicting-outputs`

**Database locked/corruption**
- Verify integrity: `await BrickRepository.instance.verifyIntegrity()`
- Reset if needed: `await BrickRepository.instance.reset()`

## 📝 Next Steps

1. ✅ Run `flutter pub get`
2. ✅ Create Brick models for other entities (billing_config, etc.)
3. ✅ Run build_runner to generate adapters
4. ✅ Update brick.g.dart with generated model dictionary
5. ✅ Test basic CRUD operations
6. ✅ Gradually migrate services to use Brick repository
7. ✅ Test offline/online scenarios
8. ✅ Monitor sync queue and performance

## 🔗 Resources

- [Brick Documentation](https://github.com/GetDutchie/brick)
- [SQLCipher](https://www.zetetic.net/sqlcipher/)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

## 💡 Tips

- Always use `requireRemote: false` for better offline experience
- Subscribe to changes for real-time UI updates
- Use `upsert` instead of separate insert/update logic
- Test offline scenarios thoroughly
- Monitor offline queue length for sync status
- Back up encryption keys in production (user recovery flow)
