import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../models/fundraiser_models.dart';
import 'auth_provider.dart'; 

// 1. WATCH: Listen for ANY active campaign for this school
final activeCampaignProvider = StreamProvider.family<Campaign?, String>((ref, schoolId) {
  final db = DatabaseService();
  // We limit to 1 because the UI logic assumes sequential campaigns for safety
  return db.db.watch(
    "SELECT * FROM campaigns WHERE school_id = ? AND status = 'active' ORDER BY created_at DESC LIMIT 1",
    parameters: [schoolId],
  ).map((rows) {
    if (rows.isEmpty) return null;
    return Campaign.fromRow(rows.first);
  });
});

// 2. CONTROLLER: Handle Create & Close actions
final campaignControllerProvider = StateNotifierProvider<CampaignController, AsyncValue<void>>((ref) {
  return CampaignController(ref);
});

class CampaignController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  CampaignController(this._ref) : super(const AsyncData(null));

  Future<bool> createCampaign({
    required String schoolId,
    required String name,
    required String type,
    required double goal,
    required String description,
  }) async {
    state = const AsyncLoading();
    try {
      final user = _ref.read(currentUserProvider);
      final id = const Uuid().v4();
      
      final newCampaign = Campaign(
        id: id,
        schoolId: schoolId,
        createdById: user?.id ?? 'unknown',
        name: name,
        type: type,
        goalAmount: goal,
        description: description,
        status: 'active',
        createdAt: DateTime.now(),
      );

      await DatabaseService().insert('campaigns', newCampaign.toMap());

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> closeCampaign(String campaignId) async {
    state = const AsyncLoading();
    try {
      await DatabaseService().update('campaigns', campaignId, {
        'status': 'closed',
      });
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}