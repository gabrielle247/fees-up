import 'package:fees_up/data/providers/broadcast_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

class ComposeBroadcastDialog extends ConsumerStatefulWidget {
  const ComposeBroadcastDialog({super.key});

  @override
  ConsumerState<ComposeBroadcastDialog> createState() => _ComposeBroadcastDialogState();
}

class _ComposeBroadcastDialogState extends ConsumerState<ComposeBroadcastDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _priority = 'normal';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(broadcastLogicProvider).post(
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        priority: _priority,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Post Broadcast", style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: AppColors.textWhite),
                validator: (v) => v!.isEmpty ? "Required" : null,
                decoration: _inputDecoration("Title"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyCtrl,
                style: const TextStyle(color: AppColors.textWhite),
                validator: (v) => v!.isEmpty ? "Required" : null,
                maxLines: 4,
                decoration: _inputDecoration("Body"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _priority, // Controlled value
                dropdownColor: AppColors.surfaceGrey,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: _inputDecoration("Priority"),
                items: const [
                  DropdownMenuItem(value: 'normal', child: Text("Normal")),
                  DropdownMenuItem(value: 'high', child: Text("High")),
                  DropdownMenuItem(value: 'critical', child: Text("Critical")),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: AppColors.textWhite70)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send, size: 16),
                    label: Text(_isLoading ? "Posting..." : "Post"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textWhite54),
      filled: true,
      fillColor: AppColors.backgroundBlack,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
    );
  }
}