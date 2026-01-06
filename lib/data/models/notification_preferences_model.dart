/// Notification preferences model
class NotificationPreferences {
  final bool billingInApp;
  final bool billingEmail;
  final String billingFreq;
  final bool campaignInApp;
  final bool campaignEmail;
  final bool attendanceInApp;
  final bool attendanceEmail;
  final bool announceInApp;
  final bool announceEmail;
  final bool channelEmail;
  final bool channelPush;
  final bool channelSMS;
  final bool dndEnabled;
  final String dndStart;
  final String dndEnd;

  const NotificationPreferences({
    this.billingInApp = true,
    this.billingEmail = true,
    this.billingFreq = 'Immediate',
    this.campaignInApp = true,
    this.campaignEmail = false,
    this.attendanceInApp = true,
    this.attendanceEmail = false,
    this.announceInApp = true,
    this.announceEmail = true,
    this.channelEmail = true,
    this.channelPush = true,
    this.channelSMS = false,
    this.dndEnabled = false,
    this.dndStart = '22:00',
    this.dndEnd = '07:00',
  });

  Map<String, dynamic> toJson() => {
        'billingInApp': billingInApp,
        'billingEmail': billingEmail,
        'billingFreq': billingFreq,
        'campaignInApp': campaignInApp,
        'campaignEmail': campaignEmail,
        'attendanceInApp': attendanceInApp,
        'attendanceEmail': attendanceEmail,
        'announceInApp': announceInApp,
        'announceEmail': announceEmail,
        'channelEmail': channelEmail,
        'channelPush': channelPush,
        'channelSMS': channelSMS,
        'dndEnabled': dndEnabled,
        'dndStart': dndStart,
        'dndEnd': dndEnd,
      };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      billingInApp: json['billingInApp'] as bool? ?? true,
      billingEmail: json['billingEmail'] as bool? ?? true,
      billingFreq: json['billingFreq'] as String? ?? 'Immediate',
      campaignInApp: json['campaignInApp'] as bool? ?? true,
      campaignEmail: json['campaignEmail'] as bool? ?? false,
      attendanceInApp: json['attendanceInApp'] as bool? ?? true,
      attendanceEmail: json['attendanceEmail'] as bool? ?? false,
      announceInApp: json['announceInApp'] as bool? ?? true,
      announceEmail: json['announceEmail'] as bool? ?? true,
      channelEmail: json['channelEmail'] as bool? ?? true,
      channelPush: json['channelPush'] as bool? ?? true,
      channelSMS: json['channelSMS'] as bool? ?? false,
      dndEnabled: json['dndEnabled'] as bool? ?? false,
      dndStart: json['dndStart'] as String? ?? '22:00',
      dndEnd: json['dndEnd'] as String? ?? '07:00',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferences &&
          runtimeType == other.runtimeType &&
          billingInApp == other.billingInApp &&
          billingEmail == other.billingEmail &&
          billingFreq == other.billingFreq &&
          campaignInApp == other.campaignInApp &&
          campaignEmail == other.campaignEmail &&
          attendanceInApp == other.attendanceInApp &&
          attendanceEmail == other.attendanceEmail &&
          announceInApp == other.announceInApp &&
          announceEmail == other.announceEmail &&
          channelEmail == other.channelEmail &&
          channelPush == other.channelPush &&
          channelSMS == other.channelSMS &&
          dndEnabled == other.dndEnabled &&
          dndStart == other.dndStart &&
          dndEnd == other.dndEnd;

  @override
  int get hashCode =>
      billingInApp.hashCode ^
      billingEmail.hashCode ^
      billingFreq.hashCode ^
      campaignInApp.hashCode ^
      campaignEmail.hashCode ^
      attendanceInApp.hashCode ^
      attendanceEmail.hashCode ^
      announceInApp.hashCode ^
      announceEmail.hashCode ^
      channelEmail.hashCode ^
      channelPush.hashCode ^
      channelSMS.hashCode ^
      dndEnabled.hashCode ^
      dndStart.hashCode ^
      dndEnd.hashCode;
}
