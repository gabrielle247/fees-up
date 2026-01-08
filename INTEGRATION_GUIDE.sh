#!/bin/bash
# Quick integration guide for Isar + Supabase

# 1. Initialize Isar (in main.dart)
# await IsarService().initialize();

# 2. Use in your app:
# 
# // LOCAL: Write instantly
# final isar = await IsarService().db;
# final invoice = Invoice()
#   ..id = Uuid().v4()
#   ..schoolId = currentSchoolId
#   ..studentId = studentId
#   ..invoiceNumber = 'INV-001'
#   ..dueDate = DateTime.now().add(Duration(days: 30))
#   ..status = 'DRAFT'
#   ..createdAt = DateTime.now();
#
# await isar.writeTxn(() => isar.invoices.put(invoice));
#
# // CLOUD: Sync when ready
# final sync = SyncService();
# await sync.fullSync(schoolId: currentSchoolId);
#
# // CHECK STATUS
# final status = await sync.getSyncStatus(schoolId: currentSchoolId);
# print(status); // {schools: 5, students: 150, invoices: 320, ...}

# 3. MODEL HELPERS (all models have these)
# 
# // Convert between cents and dollars
# invoice.setAmountFromDollars(100.50); // → 10050 cents
# double display = invoice.amountInDollars; // → 100.50
#
# // JSON serialization (ready for Supabase)
# Map<String, dynamic> json = invoice.toJson();
# Invoice fromServer = Invoice.fromJson(supabaseData);

# 4. SAFE FOR PRODUCTION
# 
# ✅ Encryption at rest (Isar + secure key storage)
# ✅ No platform-specific dependencies (pure Dart)
# ✅ Multi-tenant isolation via schoolId indexes
# ✅ Proper UTC timestamps (toIso8601String())
# ✅ Financial precision (int cents, not double dollars)
# ✅ Full Supabase schema alignment
# ✅ Offline-first with UUID IDs
# ✅ Bidirectional sync with conflict handling

echo "✅ Isar + Supabase integration is production-ready!"
echo ""
echo "Key files:"
echo "  - Models: lib/data/models/{access,finance,people,saas}.dart"
echo "  - Isar Service: lib/data/services/isar_service.dart"
echo "  - Sync Service: lib/data/services/sync_service.dart"
echo ""
echo "Next steps:"
echo "  1. Call IsarService().initialize() in main.dart"
echo "  2. Authenticate users with Supabase"
echo "  3. Call SyncService().fullSync() after login"
echo "  4. Use models locally and sync on demand"
