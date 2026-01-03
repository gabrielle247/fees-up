import 'package:fees_up/data/providers/broadcast_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/broadcast_model.dart';
import 'compose_broadcast_dialog.dart';

class BroadcastList extends ConsumerStatefulWidget {
  const BroadcastList({super.key});

  @override
  ConsumerState<BroadcastList> createState() => _BroadcastListState();
}

class _BroadcastListState extends ConsumerState<BroadcastList> {
  String _filter = 'All'; // 'All', 'System', 'Internal'

  @override
  Widget build(BuildContext context) {
    // SWITCHER LOGIC: Select the correct Fortress Stream [cite: 2025-12-30]
    final AsyncValue<List<Broadcast>> feedAsync = (_filter == 'Internal')
        ? ref.watch(internalHQBroadcastProvider)
        : ref.watch(schoolBroadcastProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterTab("All"),
                _buildFilterTab("System"),
                _buildFilterTab("Internal"),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _filter == 'Internal' 
                      ? ref.refresh(internalHQBroadcastProvider) 
                      : ref.refresh(schoolBroadcastProvider),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text("Refresh Feed"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textWhite,
                    side: const BorderSide(color: AppColors.divider),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showComposeDialog(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Post Update"),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          feedAsync.when(
            data: (broadcasts) {
              final filtered = _filter == 'System' 
                  ? broadcasts.where((b) => b.isSystemMessage).toList() 
                  : broadcasts;
              
              if (filtered.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) => _buildBroadcastItem(filtered[index]),
              );
            },
            loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
            error: (e, s) => Padding(padding: const EdgeInsets.all(20), child: Text("Error: $e", style: const TextStyle(color: AppColors.errorRed))),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastItem(Broadcast item) {
    final timeStr = DateFormat('MMM d, h:mm a').format(item.createdAt);
    return Container(
      padding: const EdgeInsets.all(20),
      color: item.isInternalHQ ? AppColors.purpleBg : (item.isSystemMessage ? AppColors.primaryBlueBg : null),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: item.badgeColor.withAlpha(40),
            child: Icon(item.icon, color: item.badgeColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: item.badgeColor.withAlpha(50), borderRadius: BorderRadius.circular(4)),
                      child: Text(item.authorLabel.toUpperCase(), style: TextStyle(color: item.badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(item.title, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item.body, style: const TextStyle(color: AppColors.textWhite70, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(timeStr, style: const TextStyle(color: AppColors.textWhite38, fontSize: 12)),
              const SizedBox(height: 8),
              if (item.priority == 'critical') const Icon(Icons.report, color: AppColors.errorRed, size: 16),
            ],
          ),
        ],
      ),
    );
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
        child: Text(label, style: TextStyle(color: isActive ? AppColors.textWhite : AppColors.textWhite70, fontSize: 13)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(48.0),
      child: Center(child: Text("No broadcasts in this category", style: TextStyle(color: AppColors.textWhite38))),
    );
  }

  void _showComposeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: AppColors.overlayDark,
      builder: (context) => const ComposeBroadcastDialog(),
    );
  }
}