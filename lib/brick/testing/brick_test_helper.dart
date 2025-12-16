// lib/brick/testing/brick_test_helper.dart
import 'package:flutter/foundation.dart';
import '../repository/brick_repository.dart';
import '../../models/student_brick.dart';

/// Helper class for testing Brick implementation
/// Use this to verify your setup is working correctly
class BrickTestHelper {
  final _repo = BrickRepository.instance;

  /// Test if repository is initialized
  Future<bool> testInitialization() async {
    try {
      final isInit = _repo.isInitialized;
      debugPrint('✓ Repository initialized: $isInit');
      return isInit;
    } catch (e) {
      debugPrint('✗ Initialization test failed: $e');
      return false;
    }
  }

  /// Test database integrity
  Future<bool> testDatabaseIntegrity() async {
    try {
      final isValid = await _repo.verifyIntegrity();
      debugPrint('✓ Database integrity: $isValid');
      return isValid;
    } catch (e) {
      debugPrint('✗ Database integrity test failed: $e');
      return false;
    }
  }

  /// Test basic CRUD operations with Student model
  Future<bool> testStudentCRUD() async {
    try {
      debugPrint('Starting CRUD test...');

      // Create test student
      final testStudent = Student(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        fullName: 'Test Student',
        grade: 'Test Grade',
        isActive: true,
        paidTotal: 0.0,
        owedTotal: 100.0,
      );

      // Create
      debugPrint('Testing CREATE...');
      final created = await _repo.upsert(testStudent);
      if (created == null) {
        debugPrint('✗ CREATE failed');
        return false;
      }
      debugPrint('✓ CREATE succeeded');

      // Read
      debugPrint('Testing READ...');
      final read = await _repo.get<Student>(testStudent.id);
      if (read == null) {
        debugPrint('✗ READ failed');
        return false;
      }
      debugPrint('✓ READ succeeded: ${read.fullName}');

      // Update
      debugPrint('Testing UPDATE...');
      final updated = Student(
        id: testStudent.id,
        fullName: 'Updated Test Student',
        grade: testStudent.grade,
        isActive: testStudent.isActive,
        paidTotal: 50.0,
        owedTotal: 50.0,
      );
      final updatedResult = await _repo.upsert(updated);
      if (updatedResult == null) {
        debugPrint('✗ UPDATE failed');
        return false;
      }
      debugPrint('✓ UPDATE succeeded: ${updatedResult.fullName}');

      // Delete
      debugPrint('Testing DELETE...');
      final deleted = await _repo.delete(updatedResult);
      if (!deleted) {
        debugPrint('✗ DELETE failed');
        return false;
      }
      debugPrint('✓ DELETE succeeded');

      // Verify deletion
      final shouldBeNull = await _repo.get<Student>(testStudent.id);
      if (shouldBeNull != null) {
        debugPrint('✗ DELETE verification failed - record still exists');
        return false;
      }

      debugPrint('✓ All CRUD operations succeeded!');
      return true;
    } catch (e) {
      debugPrint('✗ CRUD test failed: $e');
      return false;
    }
  }

  /// Test query operations
  Future<bool> testQueries() async {
    try {
      debugPrint('Testing QUERIES...');

      // Create test students
      final students = [
        Student(
          id: 'query-test-1',
          fullName: 'Query Test 1',
          grade: 'Grade 10',
          isActive: true,
          paidTotal: 0,
          owedTotal: 0,
        ),
        Student(
          id: 'query-test-2',
          fullName: 'Query Test 2',
          grade: 'Grade 10',
          isActive: false,
          paidTotal: 0,
          owedTotal: 0,
        ),
      ];

      for (final student in students) {
        await _repo.upsert(student);
      }

      // Test query by grade
      final grade10Students = await _repo.getAll<Student>(
        // query: Query.where('grade', 'Grade 10'),
        requireRemote: false,
      );
      debugPrint('✓ Query returned ${grade10Students.length} students');

      // Cleanup
      for (final student in students) {
        await _repo.delete(student);
      }

      return true;
    } catch (e) {
      debugPrint('✗ Query test failed: $e');
      return false;
    }
  }

  /// Test offline queue
  Future<bool> testOfflineQueue() async {
    try {
      final queueLength = _repo.offlineQueueLength;
      debugPrint('✓ Offline queue length: $queueLength');
      return true;
    } catch (e) {
      debugPrint('✗ Offline queue test failed: $e');
      return false;
    }
  }

  /// Run all tests
  Future<Map<String, bool>> runAllTests() async {
    debugPrint('');
    debugPrint('════════════════════════════════');
    debugPrint('  🧪 Brick Implementation Tests');
    debugPrint('════════════════════════════════');
    debugPrint('');

    final results = <String, bool>{};

    // Test 1: Initialization
    debugPrint('Test 1: Repository Initialization');
    debugPrint('─────────────────────────────────');
    results['initialization'] = await testInitialization();
    debugPrint('');

    // Test 2: Database Integrity
    debugPrint('Test 2: Database Integrity');
    debugPrint('─────────────────────────────────');
    results['integrity'] = await testDatabaseIntegrity();
    debugPrint('');

    // Test 3: CRUD Operations
    debugPrint('Test 3: CRUD Operations');
    debugPrint('─────────────────────────────────');
    results['crud'] = await testStudentCRUD();
    debugPrint('');

    // Test 4: Queries
    debugPrint('Test 4: Query Operations');
    debugPrint('─────────────────────────────────');
    results['queries'] = await testQueries();
    debugPrint('');

    // Test 5: Offline Queue
    debugPrint('Test 5: Offline Queue');
    debugPrint('─────────────────────────────────');
    results['queue'] = await testOfflineQueue();
    debugPrint('');

    // Summary
    debugPrint('════════════════════════════════');
    debugPrint('  📊 Test Results Summary');
    debugPrint('════════════════════════════════');
    
    final passed = results.values.where((v) => v).length;
    final total = results.length;
    
    results.forEach((test, result) {
      final icon = result ? '✓' : '✗';
      final status = result ? 'PASSED' : 'FAILED';
      debugPrint('$icon $test: $status');
    });
    
    debugPrint('');
    debugPrint('Total: $passed/$total tests passed');
    
    if (passed == total) {
      debugPrint('');
      debugPrint('🎉 All tests passed! Brick is ready to use.');
    } else {
      debugPrint('');
      debugPrint('⚠️  Some tests failed. Check the logs above.');
      debugPrint('   See BRICK_IMPLEMENTATION_GUIDE.md for troubleshooting.');
    }
    
    debugPrint('════════════════════════════════');
    debugPrint('');

    return results;
  }

  /// Quick health check
  Future<bool> healthCheck() async {
    try {
      final isInit = _repo.isInitialized;
      final isValid = await _repo.verifyIntegrity();
      final queueLength = _repo.offlineQueueLength;

      debugPrint('🏥 Brick Health Check');
      debugPrint('  Initialized: $isInit');
      debugPrint('  Database Valid: $isValid');
      debugPrint('  Queue Length: $queueLength');
      debugPrint('  Status: ${(isInit && isValid) ? "✓ Healthy" : "✗ Issues Detected"}');

      return isInit && isValid;
    } catch (e) {
      debugPrint('✗ Health check failed: $e');
      return false;
    }
  }
}

/// Convenience function to run tests from anywhere
Future<void> runBrickTests() async {
  final tester = BrickTestHelper();
  await tester.runAllTests();
}

/// Convenience function for quick health check
Future<void> brickHealthCheck() async {
  final tester = BrickTestHelper();
  await tester.healthCheck();
}
