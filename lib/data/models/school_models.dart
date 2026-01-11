class School {
  final String id;
  final String name;
  final String? subdomain;
  final String? logoUrl;
  final String? currentPlanId;
  final String subscriptionStatus;
  final DateTime? validUntil;
  final String? addressLine1;
  final String? city;
  final String? country;
  final String? phoneNumber;
  final String? emailAddress;
  final String? taxId;
  final String? website;
  final DateTime createdAt;
  final String ownerId;

  School({
    required this.id,
    required this.name,
    this.subdomain,
    this.logoUrl,
    this.currentPlanId,
    required this.subscriptionStatus,
    this.validUntil,
    this.addressLine1,
    this.city,
    this.country,
    this.phoneNumber,
    this.emailAddress,
    this.taxId,
    this.website,
    required this.createdAt,
    required this.ownerId,
  });

  factory School.fromJson(Map<String, dynamic> json) => School(
        id: json['id'],
        name: json['name'],
        subdomain: json['subdomain'],
        logoUrl: json['logo_url'],
        currentPlanId: json['current_plan_id'],
        subscriptionStatus: json['subscription_status'],
        validUntil: json['valid_until'] != null
            ? DateTime.parse(json['valid_until'])
            : null,
        addressLine1: json['address_line1'],
        city: json['city'],
        country: json['country'],
        phoneNumber: json['phone_number'],
        emailAddress: json['email_address'],
        taxId: json['tax_id'],
        website: json['website'],
        createdAt: DateTime.parse(json['created_at']),
        ownerId: json['owner_id'],
      );
}