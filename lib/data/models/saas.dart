import 'package:isar/isar.dart';

part 'saas.g.dart';

@collection
class Plan {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id; // Server UUID

  late String code;
  late String name;
  late int monthlyPrice; // cents
  String? limits; // JSON

  bool isActive = true;
  DateTime? createdAt;

  double get priceInDollars => monthlyPrice / 100.0;
  void setPriceFromDollars(double dollars) =>
      monthlyPrice = (dollars * 100).toInt();

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'monthly_price': monthlyPrice / 100.0,
        'limits': limits,
        'is_active': isActive,
        'created_at': createdAt?.toIso8601String(),
      };

  static Plan fromJson(Map<String, dynamic> json) => Plan()
    ..id = json['id'] as String
    ..code = json['code'] as String
    ..name = json['name'] as String
    ..monthlyPrice = ((json['monthly_price'] as num?) ?? 0).toInt() * 100
    ..limits = json['limits'] as String?
    ..isActive = json['is_active'] as bool? ?? true
    ..createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
}

@collection
class School {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id; // Server UUID

  @Index()
  late String name;

  String? subdomain;
  String? logoUrl;
  String? currentPlanId;
  String? subscriptionStatus;
  DateTime? validUntil;
  DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subdomain': subdomain,
        'logo_url': logoUrl,
        'current_plan_id': currentPlanId,
        'subscription_status': subscriptionStatus,
        'valid_until': validUntil?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
      };

  static School fromJson(Map<String, dynamic> json) => School()
    ..id = json['id'] as String
    ..name = json['name'] as String
    ..subdomain = json['subdomain'] as String?
    ..logoUrl = json['logo_url'] as String?
    ..currentPlanId = json['current_plan_id'] as String?
    ..subscriptionStatus = json['subscription_status'] as String?
    ..validUntil = json['valid_until'] != null
        ? DateTime.parse(json['valid_until'] as String)
        : null
    ..createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null;
}
