class Campaign {
  final String id;
  final String schoolId;
  final String createdById;
  final String name;
  final String? description;
  final String type; // Added to match Schema 'campaign_type'
  final String status; 
  final double goalAmount;
  final DateTime createdAt; // Useful for sorting

  Campaign({
    required this.id,
    required this.schoolId,
    required this.createdById,
    required this.name,
    this.description,
    this.type = 'General',
    this.status = 'active',
    this.goalAmount = 0.0,
    required this.createdAt,
  });

  factory Campaign.fromRow(Map<String, dynamic> row) {
    return Campaign(
      id: row['id'] as String,
      schoolId: row['school_id'] as String,
      createdById: row['created_by_id'] ?? '',
      name: row['name'] as String,
      description: row['description'] as String?,
      type: row['campaign_type'] ?? 'General',
      status: row['status'] ?? 'active',
      goalAmount: (row['goal_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(row['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'created_by_id': createdById,
      'name': name,
      'description': description,
      'campaign_type': type,
      'status': status,
      'goal_amount': goalAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class CampaignDonation {
  final String id;
  final String campaignId;
  final String? donorName;
  final double amount;
  final String? paymentMethod;
  final DateTime dateReceived;
  final double expectedCash;
  final double actualCash;
  final double variance;

  CampaignDonation({
    required this.id,
    required this.campaignId,
    this.donorName,
    this.amount = 0.0,
    this.paymentMethod,
    required this.dateReceived,
    this.expectedCash = 0.0,
    this.actualCash = 0.0,
    this.variance = 0.0,
  });

  factory CampaignDonation.fromRow(Map<String, dynamic> row) {
    return CampaignDonation(
      id: row['id'] as String,
      campaignId: row['campaign_id'] as String,
      donorName: row['donor_name'] as String?,
      amount: (row['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: row['payment_method'] as String?,
      dateReceived: DateTime.tryParse(row['date_received'] ?? '') ?? DateTime.now(),
      expectedCash: (row['expected_cash'] as num?)?.toDouble() ?? 0.0,
      actualCash: (row['actual_cash'] as num?)?.toDouble() ?? 0.0,
      variance: (row['variance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CampaignExpense {
  final String id;
  final String campaignId;
  final String? category;
  final double amount;
  final String? incurredBy;

  CampaignExpense({
    required this.id,
    required this.campaignId,
    this.category,
    required this.amount,
    this.incurredBy,
  });

  factory CampaignExpense.fromRow(Map<String, dynamic> row) {
    return CampaignExpense(
      id: row['id'] as String,
      campaignId: row['campaign_id'] as String,
      category: row['category'] as String?,
      amount: (row['amount'] as num?)?.toDouble() ?? 0.0,
      incurredBy: row['incurred_by'] as String?,
    );
  }
}

class BankingRegister {
  final String id;
  final String? campaignId;
  final double amount;
  final String direction; // 'in' or 'out'
  final String? reference;
  final String schoolId;

  BankingRegister({
    required this.id,
    this.campaignId,
    required this.amount,
    required this.direction,
    this.reference,
    required this.schoolId,
  });

  factory BankingRegister.fromRow(Map<String, dynamic> row) {
    return BankingRegister(
      id: row['id'] as String,
      campaignId: row['campaign_id'] as String?,
      amount: (row['amount'] as num?)?.toDouble() ?? 0.0,
      direction: row['direction'] as String,
      reference: row['reference'] as String?,
      schoolId: row['school_id'] as String,
    );
  }
}