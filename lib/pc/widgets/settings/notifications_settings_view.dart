import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

class NotificationsSettingsView extends ConsumerStatefulWidget {
  const NotificationsSettingsView({super.key});

  @override
  ConsumerState<NotificationsSettingsView> createState() => _NotificationsSettingsViewState();
}

class _NotificationsSettingsViewState extends ConsumerState<NotificationsSettingsView> {
  // --- MOCK STATE (Connect to Provider in Logic Phase) ---
  bool _billingInApp = true;
  bool _billingEmail = true;
  String _billingFreq = "Immediate";

  bool _campaignInApp = true;
  bool _campaignEmail = false;

  bool _attendanceInApp = true;
  bool _attendanceEmail = false;

  bool _announceInApp = true;
  bool _announceEmail = true;

  // Global Channels
  bool _channelEmail = true;
  bool _channelPush = true;
  bool _channelSMS = false;

  // DND
  bool _dndEnabled = false;
  final TimeOfDay _dndStart = const TimeOfDay(hour: 22, minute: 0);
  final TimeOfDay _dndEnd = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LEFT COLUMN: PREFERENCES ---
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Notification Preferences", style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Manage what alerts you receive and how.", style: TextStyle(color: AppColors.textWhite54, fontSize: 13)),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.tune, color: AppColors.primaryBlue),
                      tooltip: "Advanced Filters",
                    )
                  ],
                ),
                const SizedBox(height: 24),
                
                // 1. Billing & Finance
                _NotificationGroupTile(
                  title: "Billing & Finance",
                  subtitle: "Alerts for invoice payments, late fees, and daily totals.",
                  icon: Icons.payments,
                  iconColor: AppColors.successGreen,
                  inAppVal: _billingInApp,
                  emailVal: _billingEmail,
                  onInAppChanged: (v) => setState(() => _billingInApp = v),
                  onEmailChanged: (v) => setState(() => _billingEmail = v),
                  extraContent: _buildDropdownRow("EMAIL FREQUENCY", _billingFreq, ["Immediate", "Daily Digest", "Weekly Summary"]),
                ),
                const Divider(color: AppColors.divider, height: 1),

                // 2. Campaign Updates
                _NotificationGroupTile(
                  title: "Campaign Updates",
                  subtitle: "Status changes for fundraising and marketing campaigns.",
                  icon: Icons.campaign,
                  iconColor: AppColors.accentPurple,
                  inAppVal: _campaignInApp,
                  emailVal: _campaignEmail,
                  onInAppChanged: (v) => setState(() => _campaignInApp = v),
                  onEmailChanged: (v) => setState(() => _campaignEmail = v),
                ),
                const Divider(color: AppColors.divider, height: 1),

                // 3. Attendance Issues
                _NotificationGroupTile(
                  title: "Attendance Issues",
                  subtitle: "Critical absentee alerts and staff attendance logs.",
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppColors.warningOrange,
                  inAppVal: _attendanceInApp,
                  emailVal: _attendanceEmail,
                  onInAppChanged: (v) => setState(() => _attendanceInApp = v),
                  onEmailChanged: (v) => setState(() => _attendanceEmail = v),
                ),
                const Divider(color: AppColors.divider, height: 1),

                // 4. General Announcements
                _NotificationGroupTile(
                  title: "General Announcements",
                  subtitle: "System-wide messages from administration.",
                  icon: Icons.campaign_outlined, // Using outlined to differentiate
                  iconColor: AppColors.primaryBlue,
                  inAppVal: _announceInApp,
                  emailVal: _announceEmail,
                  onInAppChanged: (v) => setState(() => _announceInApp = v),
                  onEmailChanged: (v) => setState(() => _announceEmail = v),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 24),

        // --- RIGHT COLUMN: GLOBAL & DND ---
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // 1. Global Delivery Channels
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Global Delivery Channels", style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    
                    _DeliveryChannelTile(
                      icon: Icons.email, 
                      title: "Email", 
                      subtitle: "Send to primary address", 
                      value: _channelEmail,
                      onChanged: (v) => setState(() => _channelEmail = v)
                    ),
                    const SizedBox(height: 20),
                    _DeliveryChannelTile(
                      icon: Icons.smartphone, 
                      title: "Push Notifications", 
                      subtitle: "Browser & mobile app", 
                      value: _channelPush,
                      onChanged: (v) => setState(() => _channelPush = v)
                    ),
                    const SizedBox(height: 20),
                    _DeliveryChannelTile(
                      icon: Icons.sms, 
                      title: "SMS Alerts", 
                      subtitle: "Premium plan only", 
                      value: _channelSMS,
                      onChanged: (v) => setState(() => _channelSMS = v),
                      isDisabled: true, // Visual cue for disabled
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // 2. Do Not Disturb
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.backgroundBlack,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Do Not Disturb", style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
                        Icon(Icons.dark_mode, color: Colors.amber, size: 18),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Pause all notifications", style: TextStyle(color: AppColors.textWhite, fontSize: 13)),
                        Switch(
                          value: _dndEnabled, 
                          onChanged: (v) => setState(() => _dndEnabled = v),
                          activeThumbColor: AppColors.primaryBlue,
                          activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.3),
                          inactiveThumbColor: AppColors.textWhite,
                          inactiveTrackColor: AppColors.surfaceGrey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(child: _buildTimePicker("From", _dndStart)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTimePicker("To", _dndEnd)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "During this time, notifications will be muted and delivered quietly to your in-app inbox.",
                      style: TextStyle(color: AppColors.textWhite38, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.divider),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Reset", style: TextStyle(color: AppColors.textWhite)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- HELPERS ---

  Widget _buildDropdownRow(String label, String value, List<String> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textWhite38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundBlack,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: AppColors.surfaceGrey,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textWhite54),
              style: const TextStyle(color: AppColors.textWhite, fontSize: 12),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _billingFreq = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textWhite54, fontSize: 11)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.backgroundBlack,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time.format(context), style: const TextStyle(color: AppColors.textWhite, fontSize: 13)),
              const Icon(Icons.access_time, size: 14, color: AppColors.textWhite38),
            ],
          ),
        ),
      ],
    );
  }
}

// --- PRIVATE WIDGETS FOR FRAGMENTATION ---

class _NotificationGroupTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool inAppVal;
  final bool emailVal;
  final Function(bool) onInAppChanged;
  final Function(bool) onEmailChanged;
  final Widget? extraContent;

  const _NotificationGroupTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.inAppVal,
    required this.emailVal,
    required this.onInAppChanged,
    required this.onEmailChanged,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textWhite54, fontSize: 12)),
                const SizedBox(height: 16),
                
                // Toggles Row
                _buildToggleRow("In-App Notifications", inAppVal, onInAppChanged),
                const SizedBox(height: 12),
                _buildToggleRow("Email Alerts", emailVal, onEmailChanged),
                
                if (extraContent != null) ...[
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 16),
                  extraContent!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool val, Function(bool) onChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
        SizedBox(
          height: 24,
          child: Switch(
            value: val,
            onChanged: onChange,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primaryBlue,
            inactiveThumbColor: AppColors.textWhite,
            inactiveTrackColor: AppColors.backgroundBlack,
          ),
        ),
      ],
    );
  }
}

class _DeliveryChannelTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  final bool isDisabled;

  const _DeliveryChannelTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isDisabled ? AppColors.textWhite38 : AppColors.textWhite54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isDisabled ? AppColors.textWhite38 : AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w500)),
              Text(subtitle, style: const TextStyle(color: AppColors.textWhite38, fontSize: 11)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: isDisabled ? null : onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppColors.primaryBlue,
          inactiveThumbColor: AppColors.textWhite38,
          inactiveTrackColor: AppColors.backgroundBlack,
        ),
      ],
    );
  }
}