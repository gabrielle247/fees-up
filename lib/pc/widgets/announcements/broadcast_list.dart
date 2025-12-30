import 'package:fees_up/data/providers/broadcast_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/broadcast_model.dart';
import 'compose_broadcast_dialog.dart'; // We'll create this next

class BroadcastList extends ConsumerStatefulWidget {
  const BroadcastList({super.key});

  @override
  ConsumerState<BroadcastList> createState() => _BroadcastListState();
}

class _BroadcastListState extends ConsumerState<BroadcastList> {
  String _filter = 'All'; // 'All', 'System', 'Internal'

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(broadcastFeedProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // --- ACTION BAR ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterTab("All"),
                _buildFilterTab("System"),
                _buildFilterTab("Internal"),
                
                const Spacer(),
                
                // Refresh Button (Replaces "Mark Read")
                OutlinedButton.icon(
                  onPressed: () => ref.refresh(broadcastFeedProvider),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text("Refresh Feed"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textWhite,
                    side: const BorderSide(color: AppColors.divider),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Compose Button
                ElevatedButton.icon(
                  onPressed: () => _showComposeDialog(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Post Update"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // --- LIST CONTENT ---
          feedAsync.when(
            data: (broadcasts) {
              final filtered = _applyFilter(broadcasts);
              
              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: AppColors.textWhite38),
                      SizedBox(height: 16),
                      Text("No broadcasts found", style: TextStyle(color: AppColors.textWhite54)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) => _buildBroadcastItem(filtered[index]),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => Padding(
              padding: const EdgeInsets.all(20),
              child: Text("Connection Error: $e", style: const TextStyle(color: AppColors.errorRed)),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  List<Broadcast> _applyFilter(List<Broadcast> list) {
    if (_filter == 'System') return list.where((b) => b.isSystemMessage).toList();
    if (_filter == 'Internal') return list.where((b) => !b.isSystemMessage).toList();
    return list;
  }

  Widget _buildFilterTab(String label) {
    final isActive = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.backgroundBlack : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isActive ? Border.all(color: AppColors.divider) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.textWhite : AppColors.textWhite70,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBroadcastItem(Broadcast item) {
    final timeStr = DateFormat('MMM d, h:mm a').format(item.createdAt);
    
    return Container(
      padding: const EdgeInsets.all(20),
      // Highlight System messages slightly
      color: item.isSystemMessage ? const Color(0xFF9333EA).withValues(alpha: 0.05) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Avatar
          CircleAvatar(
            backgroundColor: item.badgeColor.withValues(alpha: 0.15),
            child: Icon(item.icon, color: item.badgeColor, size: 20),
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Author Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.badgeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.authorLabel.toUpperCase(),
                        style: TextStyle(color: item.badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Title
                    Text(item.title, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.body,
                  style: const TextStyle(color: AppColors.textWhite70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          
          // Meta
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(timeStr, style: const TextStyle(color: AppColors.textWhite38, fontSize: 12)),
              const SizedBox(height: 8),
              if (item.priority == 'critical')
                 const Icon(Icons.priority_high, color: AppColors.errorRed, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  void _showComposeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => const ComposeBroadcastDialog(),
    );
  }
}