# Brick Quick Reference Card

## 🚀 Quick Start Commands

```bash
# Install dependencies
flutter pub get

# Generate adapters (run after creating/modifying models)
flutter pub run build_runner build --delete-conflicting-outputs

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuild on changes)
flutter pub run build_runner watch
```

## 📋 Common Operations

### Basic CRUD

```dart
final repo = BrickRepository.instance;

// CREATE/UPDATE
final student = Student(id: '123', fullName: 'John Doe');
await repo.upsert(student);

// READ
final student = await repo.get<Student>('123');
final all = await repo.getAll<Student>();

// DELETE
await repo.delete(student);
```

### Queries

```dart
// Single condition
await repo.getAll<Student>(
  query: Query.where('grade', 'Grade 10'),
);

// Multiple conditions (AND)
await repo.getAll<Student>(
  query: Query.where('grade', 'Grade 10')
              .where('isActive', true),
);

// Force remote fetch
await repo.getAll<Student>(requireRemote: true);
```

### Real-time Updates

```dart
await repo.subscribe<Student>(
  onData: (students) => print('Updated: ${students.length}'),
  onError: (error) => print('Error: $error'),
);
```

### Sync

```dart
// Manual sync
await repo.sync<Student>();

// Check queue
print(repo.offlineQueueLength);
```

## 🔒 Encryption Operations

```dart
final helper = EncryptedDatabaseHelper();

// Verify integrity
final ok = await helper.verifyIntegrity();

// Change key
await helper.changeEncryptionKey('new-key');

// Full reset
await BrickRepository.instance.reset();
```

## 🎯 Service Pattern

```dart
class MyService {
  final _repo = BrickRepository.instance;
  
  Future<List<Model>> getAll() async {
    return await _repo.getAll<Model>();
  }
  
  Future<void> save(Model model) async {
    await _repo.upsert(model);
  }
}
```

## 📝 Model Annotations

```dart
@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'table_name'),
)
class MyModel extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  @Sqlite(unique: true)
  final String id;
  
  @Supabase(name: 'custom_column')
  @Sqlite(name: 'custom_column')
  final String? field;
  
  // Constructor and methods...
}
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Repository not initialized" | Call `BrickRepository.instance.initialize()` in `main()` |
| Adapters not generated | Run `flutter pub run build_runner build --delete-conflicting-outputs` |
| Database corruption | Run `await BrickRepository.instance.reset()` |
| Sync not working | Check network and Supabase credentials |
| Encryption errors | Verify keys in secure storage, may need to reset |

## 📊 Query Operators

```dart
// Equals
Query.where('field', value)

// Not equals
Query.where('field', value, compare: Compare.notEqual)

// Greater than
Query.where('field', value, compare: Compare.greaterThan)

// Less than
Query.where('field', value, compare: Compare.lessThan)

// Contains (for text)
Query.where('field', value, compare: Compare.contains)

// Between
Query.where('field', value, compare: Compare.between)
```

## 🔄 Migration Workflow

1. Keep existing models
2. Create Brick versions (`_brick.dart`)
3. Add conversion methods
4. Generate adapters
5. Gradually migrate features
6. Use both systems during transition

## ⚙️ Key Files

- `lib/brick/brick.g.dart` - Main config
- `lib/brick/db/encrypted_database_helper.dart` - Encryption
- `lib/brick/repository/brick_repository.dart` - Repository
- `build.yaml` - Build configuration
- Generated: `lib/brick/adapters/*.g.dart`

## 💾 Database Info

- **Location**: `{AppDocs}/brick_dbs/fees_up_brick.db`
- **Encryption**: SQLCipher with 256-bit key
- **Key Storage**: FlutterSecureStorage
- **Backup**: Automatic through Supabase sync

## 🌐 Offline Behavior

- **Writes**: Queued automatically for sync
- **Reads**: Local-first, fallback to remote
- **Conflicts**: Last-write-wins (default)
- **Queue**: Persisted, survives app restart

## 📞 Support

See full docs: `BRICK_IMPLEMENTATION_GUIDE.md`
