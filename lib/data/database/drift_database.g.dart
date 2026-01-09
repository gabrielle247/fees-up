// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $SchoolsTable extends Schools with TableInfo<$SchoolsTable, School> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchoolsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subdomainMeta =
      const VerificationMeta('subdomain');
  @override
  late final GeneratedColumn<String> subdomain = GeneratedColumn<String>(
      'subdomain', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _logoUrlMeta =
      const VerificationMeta('logoUrl');
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
      'logo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currentPlanIdMeta =
      const VerificationMeta('currentPlanId');
  @override
  late final GeneratedColumn<String> currentPlanId = GeneratedColumn<String>(
      'current_plan_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subscriptionStatusMeta =
      const VerificationMeta('subscriptionStatus');
  @override
  late final GeneratedColumn<String> subscriptionStatus =
      GeneratedColumn<String>('subscription_status', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('ACTIVE'));
  static const VerificationMeta _subscriptionEndsAtMeta =
      const VerificationMeta('subscriptionEndsAt');
  @override
  late final GeneratedColumn<DateTime> subscriptionEndsAt =
      GeneratedColumn<DateTime>('subscription_ends_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        subdomain,
        logoUrl,
        currentPlanId,
        subscriptionStatus,
        subscriptionEndsAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schools';
  @override
  VerificationContext validateIntegrity(Insertable<School> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('subdomain')) {
      context.handle(_subdomainMeta,
          subdomain.isAcceptableOrUnknown(data['subdomain']!, _subdomainMeta));
    } else if (isInserting) {
      context.missing(_subdomainMeta);
    }
    if (data.containsKey('logo_url')) {
      context.handle(_logoUrlMeta,
          logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta));
    }
    if (data.containsKey('current_plan_id')) {
      context.handle(
          _currentPlanIdMeta,
          currentPlanId.isAcceptableOrUnknown(
              data['current_plan_id']!, _currentPlanIdMeta));
    }
    if (data.containsKey('subscription_status')) {
      context.handle(
          _subscriptionStatusMeta,
          subscriptionStatus.isAcceptableOrUnknown(
              data['subscription_status']!, _subscriptionStatusMeta));
    }
    if (data.containsKey('subscription_ends_at')) {
      context.handle(
          _subscriptionEndsAtMeta,
          subscriptionEndsAt.isAcceptableOrUnknown(
              data['subscription_ends_at']!, _subscriptionEndsAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  School map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return School(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      subdomain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subdomain'])!,
      logoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_url']),
      currentPlanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}current_plan_id']),
      subscriptionStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}subscription_status'])!,
      subscriptionEndsAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}subscription_ends_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SchoolsTable createAlias(String alias) {
    return $SchoolsTable(attachedDatabase, alias);
  }
}

class School extends DataClass implements Insertable<School> {
  final String id;
  final String name;
  final String subdomain;
  final String? logoUrl;
  final String? currentPlanId;
  final String subscriptionStatus;
  final DateTime? subscriptionEndsAt;
  final DateTime createdAt;
  const School(
      {required this.id,
      required this.name,
      required this.subdomain,
      this.logoUrl,
      this.currentPlanId,
      required this.subscriptionStatus,
      this.subscriptionEndsAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['subdomain'] = Variable<String>(subdomain);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    if (!nullToAbsent || currentPlanId != null) {
      map['current_plan_id'] = Variable<String>(currentPlanId);
    }
    map['subscription_status'] = Variable<String>(subscriptionStatus);
    if (!nullToAbsent || subscriptionEndsAt != null) {
      map['subscription_ends_at'] = Variable<DateTime>(subscriptionEndsAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SchoolsCompanion toCompanion(bool nullToAbsent) {
    return SchoolsCompanion(
      id: Value(id),
      name: Value(name),
      subdomain: Value(subdomain),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      currentPlanId: currentPlanId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentPlanId),
      subscriptionStatus: Value(subscriptionStatus),
      subscriptionEndsAt: subscriptionEndsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionEndsAt),
      createdAt: Value(createdAt),
    );
  }

  factory School.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return School(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      subdomain: serializer.fromJson<String>(json['subdomain']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      currentPlanId: serializer.fromJson<String?>(json['currentPlanId']),
      subscriptionStatus:
          serializer.fromJson<String>(json['subscriptionStatus']),
      subscriptionEndsAt:
          serializer.fromJson<DateTime?>(json['subscriptionEndsAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'subdomain': serializer.toJson<String>(subdomain),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'currentPlanId': serializer.toJson<String?>(currentPlanId),
      'subscriptionStatus': serializer.toJson<String>(subscriptionStatus),
      'subscriptionEndsAt': serializer.toJson<DateTime?>(subscriptionEndsAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  School copyWith(
          {String? id,
          String? name,
          String? subdomain,
          Value<String?> logoUrl = const Value.absent(),
          Value<String?> currentPlanId = const Value.absent(),
          String? subscriptionStatus,
          Value<DateTime?> subscriptionEndsAt = const Value.absent(),
          DateTime? createdAt}) =>
      School(
        id: id ?? this.id,
        name: name ?? this.name,
        subdomain: subdomain ?? this.subdomain,
        logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
        currentPlanId:
            currentPlanId.present ? currentPlanId.value : this.currentPlanId,
        subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
        subscriptionEndsAt: subscriptionEndsAt.present
            ? subscriptionEndsAt.value
            : this.subscriptionEndsAt,
        createdAt: createdAt ?? this.createdAt,
      );
  School copyWithCompanion(SchoolsCompanion data) {
    return School(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      subdomain: data.subdomain.present ? data.subdomain.value : this.subdomain,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      currentPlanId: data.currentPlanId.present
          ? data.currentPlanId.value
          : this.currentPlanId,
      subscriptionStatus: data.subscriptionStatus.present
          ? data.subscriptionStatus.value
          : this.subscriptionStatus,
      subscriptionEndsAt: data.subscriptionEndsAt.present
          ? data.subscriptionEndsAt.value
          : this.subscriptionEndsAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('School(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('subdomain: $subdomain, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('currentPlanId: $currentPlanId, ')
          ..write('subscriptionStatus: $subscriptionStatus, ')
          ..write('subscriptionEndsAt: $subscriptionEndsAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, subdomain, logoUrl, currentPlanId,
      subscriptionStatus, subscriptionEndsAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is School &&
          other.id == this.id &&
          other.name == this.name &&
          other.subdomain == this.subdomain &&
          other.logoUrl == this.logoUrl &&
          other.currentPlanId == this.currentPlanId &&
          other.subscriptionStatus == this.subscriptionStatus &&
          other.subscriptionEndsAt == this.subscriptionEndsAt &&
          other.createdAt == this.createdAt);
}

class SchoolsCompanion extends UpdateCompanion<School> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> subdomain;
  final Value<String?> logoUrl;
  final Value<String?> currentPlanId;
  final Value<String> subscriptionStatus;
  final Value<DateTime?> subscriptionEndsAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SchoolsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.subdomain = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.currentPlanId = const Value.absent(),
    this.subscriptionStatus = const Value.absent(),
    this.subscriptionEndsAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchoolsCompanion.insert({
    required String id,
    required String name,
    required String subdomain,
    this.logoUrl = const Value.absent(),
    this.currentPlanId = const Value.absent(),
    this.subscriptionStatus = const Value.absent(),
    this.subscriptionEndsAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        subdomain = Value(subdomain),
        createdAt = Value(createdAt);
  static Insertable<School> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? subdomain,
    Expression<String>? logoUrl,
    Expression<String>? currentPlanId,
    Expression<String>? subscriptionStatus,
    Expression<DateTime>? subscriptionEndsAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (subdomain != null) 'subdomain': subdomain,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (currentPlanId != null) 'current_plan_id': currentPlanId,
      if (subscriptionStatus != null) 'subscription_status': subscriptionStatus,
      if (subscriptionEndsAt != null)
        'subscription_ends_at': subscriptionEndsAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchoolsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? subdomain,
      Value<String?>? logoUrl,
      Value<String?>? currentPlanId,
      Value<String>? subscriptionStatus,
      Value<DateTime?>? subscriptionEndsAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SchoolsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      subdomain: subdomain ?? this.subdomain,
      logoUrl: logoUrl ?? this.logoUrl,
      currentPlanId: currentPlanId ?? this.currentPlanId,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionEndsAt: subscriptionEndsAt ?? this.subscriptionEndsAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (subdomain.present) {
      map['subdomain'] = Variable<String>(subdomain.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (currentPlanId.present) {
      map['current_plan_id'] = Variable<String>(currentPlanId.value);
    }
    if (subscriptionStatus.present) {
      map['subscription_status'] = Variable<String>(subscriptionStatus.value);
    }
    if (subscriptionEndsAt.present) {
      map['subscription_ends_at'] =
          Variable<DateTime>(subscriptionEndsAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('subdomain: $subdomain, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('currentPlanId: $currentPlanId, ')
          ..write('subscriptionStatus: $subscriptionStatus, ')
          ..write('subscriptionEndsAt: $subscriptionEndsAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _schoolIdMeta =
      const VerificationMeta('schoolId');
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
      'school_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nationalIdMeta =
      const VerificationMeta('nationalId');
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
      'national_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ACTIVE'));
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        schoolId,
        firstName,
        lastName,
        gender,
        nationalId,
        status,
        dateOfBirth,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(Insertable<Student> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(_schoolIdMeta,
          schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta));
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('national_id')) {
      context.handle(
          _nationalIdMeta,
          nationalId.isAcceptableOrUnknown(
              data['national_id']!, _nationalIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      schoolId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}school_id'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      nationalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}national_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      dateOfBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final String id;
  final String schoolId;
  final String firstName;
  final String lastName;
  final String? gender;
  final String? nationalId;
  final String status;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  const Student(
      {required this.id,
      required this.schoolId,
      required this.firstName,
      required this.lastName,
      this.gender,
      this.nationalId,
      required this.status,
      this.dateOfBirth,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || nationalId != null) {
      map['national_id'] = Variable<String>(nationalId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      firstName: Value(firstName),
      lastName: Value(lastName),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      nationalId: nationalId == null && nullToAbsent
          ? const Value.absent()
          : Value(nationalId),
      status: Value(status),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      createdAt: Value(createdAt),
    );
  }

  factory Student.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      gender: serializer.fromJson<String?>(json['gender']),
      nationalId: serializer.fromJson<String?>(json['nationalId']),
      status: serializer.fromJson<String>(json['status']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'gender': serializer.toJson<String?>(gender),
      'nationalId': serializer.toJson<String?>(nationalId),
      'status': serializer.toJson<String>(status),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Student copyWith(
          {String? id,
          String? schoolId,
          String? firstName,
          String? lastName,
          Value<String?> gender = const Value.absent(),
          Value<String?> nationalId = const Value.absent(),
          String? status,
          Value<DateTime?> dateOfBirth = const Value.absent(),
          DateTime? createdAt}) =>
      Student(
        id: id ?? this.id,
        schoolId: schoolId ?? this.schoolId,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        gender: gender.present ? gender.value : this.gender,
        nationalId: nationalId.present ? nationalId.value : this.nationalId,
        status: status ?? this.status,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
        createdAt: createdAt ?? this.createdAt,
      );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      gender: data.gender.present ? data.gender.value : this.gender,
      nationalId:
          data.nationalId.present ? data.nationalId.value : this.nationalId,
      status: data.status.present ? data.status.value : this.status,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('gender: $gender, ')
          ..write('nationalId: $nationalId, ')
          ..write('status: $status, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, schoolId, firstName, lastName, gender,
      nationalId, status, dateOfBirth, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.gender == this.gender &&
          other.nationalId == this.nationalId &&
          other.status == this.status &&
          other.dateOfBirth == this.dateOfBirth &&
          other.createdAt == this.createdAt);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String?> gender;
  final Value<String?> nationalId;
  final Value<String> status;
  final Value<DateTime?> dateOfBirth;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.gender = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.status = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentsCompanion.insert({
    required String id,
    required String schoolId,
    required String firstName,
    required String lastName,
    this.gender = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.status = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        schoolId = Value(schoolId),
        firstName = Value(firstName),
        lastName = Value(lastName),
        createdAt = Value(createdAt);
  static Insertable<Student> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? gender,
    Expression<String>? nationalId,
    Expression<String>? status,
    Expression<DateTime>? dateOfBirth,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (gender != null) 'gender': gender,
      if (nationalId != null) 'national_id': nationalId,
      if (status != null) 'status': status,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? schoolId,
      Value<String>? firstName,
      Value<String>? lastName,
      Value<String?>? gender,
      Value<String?>? nationalId,
      Value<String>? status,
      Value<DateTime?>? dateOfBirth,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return StudentsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      nationalId: nationalId ?? this.nationalId,
      status: status ?? this.status,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('gender: $gender, ')
          ..write('nationalId: $nationalId, ')
          ..write('status: $status, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnrollmentsTable extends Enrollments
    with TableInfo<$EnrollmentsTable, Enrollment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnrollmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _schoolIdMeta =
      const VerificationMeta('schoolId');
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
      'school_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
      'student_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _academicYearIdMeta =
      const VerificationMeta('academicYearId');
  @override
  late final GeneratedColumn<String> academicYearId = GeneratedColumn<String>(
      'academic_year_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gradeLevelMeta =
      const VerificationMeta('gradeLevel');
  @override
  late final GeneratedColumn<String> gradeLevel = GeneratedColumn<String>(
      'grade_level', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _classStreamMeta =
      const VerificationMeta('classStream');
  @override
  late final GeneratedColumn<String> classStream = GeneratedColumn<String>(
      'class_stream', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _snapshotGradeMeta =
      const VerificationMeta('snapshotGrade');
  @override
  late final GeneratedColumn<String> snapshotGrade = GeneratedColumn<String>(
      'snapshot_grade', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _targetGradeMeta =
      const VerificationMeta('targetGrade');
  @override
  late final GeneratedColumn<String> targetGrade = GeneratedColumn<String>(
      'target_grade', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _enrolledAtMeta =
      const VerificationMeta('enrolledAt');
  @override
  late final GeneratedColumn<DateTime> enrolledAt = GeneratedColumn<DateTime>(
      'enrolled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        schoolId,
        studentId,
        academicYearId,
        gradeLevel,
        classStream,
        snapshotGrade,
        targetGrade,
        isActive,
        enrolledAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'enrollments';
  @override
  VerificationContext validateIntegrity(Insertable<Enrollment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(_schoolIdMeta,
          schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta));
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('academic_year_id')) {
      context.handle(
          _academicYearIdMeta,
          academicYearId.isAcceptableOrUnknown(
              data['academic_year_id']!, _academicYearIdMeta));
    } else if (isInserting) {
      context.missing(_academicYearIdMeta);
    }
    if (data.containsKey('grade_level')) {
      context.handle(
          _gradeLevelMeta,
          gradeLevel.isAcceptableOrUnknown(
              data['grade_level']!, _gradeLevelMeta));
    } else if (isInserting) {
      context.missing(_gradeLevelMeta);
    }
    if (data.containsKey('class_stream')) {
      context.handle(
          _classStreamMeta,
          classStream.isAcceptableOrUnknown(
              data['class_stream']!, _classStreamMeta));
    }
    if (data.containsKey('snapshot_grade')) {
      context.handle(
          _snapshotGradeMeta,
          snapshotGrade.isAcceptableOrUnknown(
              data['snapshot_grade']!, _snapshotGradeMeta));
    }
    if (data.containsKey('target_grade')) {
      context.handle(
          _targetGradeMeta,
          targetGrade.isAcceptableOrUnknown(
              data['target_grade']!, _targetGradeMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('enrolled_at')) {
      context.handle(
          _enrolledAtMeta,
          enrolledAt.isAcceptableOrUnknown(
              data['enrolled_at']!, _enrolledAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Enrollment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Enrollment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      schoolId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}school_id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}student_id'])!,
      academicYearId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}academic_year_id'])!,
      gradeLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grade_level'])!,
      classStream: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}class_stream']),
      snapshotGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}snapshot_grade']),
      targetGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_grade']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      enrolledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}enrolled_at']),
    );
  }

  @override
  $EnrollmentsTable createAlias(String alias) {
    return $EnrollmentsTable(attachedDatabase, alias);
  }
}

class Enrollment extends DataClass implements Insertable<Enrollment> {
  final String id;
  final String schoolId;
  final String studentId;
  final String academicYearId;
  final String gradeLevel;
  final String? classStream;
  final String? snapshotGrade;
  final String? targetGrade;
  final bool isActive;
  final DateTime? enrolledAt;
  const Enrollment(
      {required this.id,
      required this.schoolId,
      required this.studentId,
      required this.academicYearId,
      required this.gradeLevel,
      this.classStream,
      this.snapshotGrade,
      this.targetGrade,
      required this.isActive,
      this.enrolledAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    map['academic_year_id'] = Variable<String>(academicYearId);
    map['grade_level'] = Variable<String>(gradeLevel);
    if (!nullToAbsent || classStream != null) {
      map['class_stream'] = Variable<String>(classStream);
    }
    if (!nullToAbsent || snapshotGrade != null) {
      map['snapshot_grade'] = Variable<String>(snapshotGrade);
    }
    if (!nullToAbsent || targetGrade != null) {
      map['target_grade'] = Variable<String>(targetGrade);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || enrolledAt != null) {
      map['enrolled_at'] = Variable<DateTime>(enrolledAt);
    }
    return map;
  }

  EnrollmentsCompanion toCompanion(bool nullToAbsent) {
    return EnrollmentsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      academicYearId: Value(academicYearId),
      gradeLevel: Value(gradeLevel),
      classStream: classStream == null && nullToAbsent
          ? const Value.absent()
          : Value(classStream),
      snapshotGrade: snapshotGrade == null && nullToAbsent
          ? const Value.absent()
          : Value(snapshotGrade),
      targetGrade: targetGrade == null && nullToAbsent
          ? const Value.absent()
          : Value(targetGrade),
      isActive: Value(isActive),
      enrolledAt: enrolledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(enrolledAt),
    );
  }

  factory Enrollment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Enrollment(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      academicYearId: serializer.fromJson<String>(json['academicYearId']),
      gradeLevel: serializer.fromJson<String>(json['gradeLevel']),
      classStream: serializer.fromJson<String?>(json['classStream']),
      snapshotGrade: serializer.fromJson<String?>(json['snapshotGrade']),
      targetGrade: serializer.fromJson<String?>(json['targetGrade']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      enrolledAt: serializer.fromJson<DateTime?>(json['enrolledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'studentId': serializer.toJson<String>(studentId),
      'academicYearId': serializer.toJson<String>(academicYearId),
      'gradeLevel': serializer.toJson<String>(gradeLevel),
      'classStream': serializer.toJson<String?>(classStream),
      'snapshotGrade': serializer.toJson<String?>(snapshotGrade),
      'targetGrade': serializer.toJson<String?>(targetGrade),
      'isActive': serializer.toJson<bool>(isActive),
      'enrolledAt': serializer.toJson<DateTime?>(enrolledAt),
    };
  }

  Enrollment copyWith(
          {String? id,
          String? schoolId,
          String? studentId,
          String? academicYearId,
          String? gradeLevel,
          Value<String?> classStream = const Value.absent(),
          Value<String?> snapshotGrade = const Value.absent(),
          Value<String?> targetGrade = const Value.absent(),
          bool? isActive,
          Value<DateTime?> enrolledAt = const Value.absent()}) =>
      Enrollment(
        id: id ?? this.id,
        schoolId: schoolId ?? this.schoolId,
        studentId: studentId ?? this.studentId,
        academicYearId: academicYearId ?? this.academicYearId,
        gradeLevel: gradeLevel ?? this.gradeLevel,
        classStream: classStream.present ? classStream.value : this.classStream,
        snapshotGrade:
            snapshotGrade.present ? snapshotGrade.value : this.snapshotGrade,
        targetGrade: targetGrade.present ? targetGrade.value : this.targetGrade,
        isActive: isActive ?? this.isActive,
        enrolledAt: enrolledAt.present ? enrolledAt.value : this.enrolledAt,
      );
  Enrollment copyWithCompanion(EnrollmentsCompanion data) {
    return Enrollment(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      academicYearId: data.academicYearId.present
          ? data.academicYearId.value
          : this.academicYearId,
      gradeLevel:
          data.gradeLevel.present ? data.gradeLevel.value : this.gradeLevel,
      classStream:
          data.classStream.present ? data.classStream.value : this.classStream,
      snapshotGrade: data.snapshotGrade.present
          ? data.snapshotGrade.value
          : this.snapshotGrade,
      targetGrade:
          data.targetGrade.present ? data.targetGrade.value : this.targetGrade,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      enrolledAt:
          data.enrolledAt.present ? data.enrolledAt.value : this.enrolledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Enrollment(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('academicYearId: $academicYearId, ')
          ..write('gradeLevel: $gradeLevel, ')
          ..write('classStream: $classStream, ')
          ..write('snapshotGrade: $snapshotGrade, ')
          ..write('targetGrade: $targetGrade, ')
          ..write('isActive: $isActive, ')
          ..write('enrolledAt: $enrolledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      schoolId,
      studentId,
      academicYearId,
      gradeLevel,
      classStream,
      snapshotGrade,
      targetGrade,
      isActive,
      enrolledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Enrollment &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.academicYearId == this.academicYearId &&
          other.gradeLevel == this.gradeLevel &&
          other.classStream == this.classStream &&
          other.snapshotGrade == this.snapshotGrade &&
          other.targetGrade == this.targetGrade &&
          other.isActive == this.isActive &&
          other.enrolledAt == this.enrolledAt);
}

class EnrollmentsCompanion extends UpdateCompanion<Enrollment> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<String> academicYearId;
  final Value<String> gradeLevel;
  final Value<String?> classStream;
  final Value<String?> snapshotGrade;
  final Value<String?> targetGrade;
  final Value<bool> isActive;
  final Value<DateTime?> enrolledAt;
  final Value<int> rowid;
  const EnrollmentsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.academicYearId = const Value.absent(),
    this.gradeLevel = const Value.absent(),
    this.classStream = const Value.absent(),
    this.snapshotGrade = const Value.absent(),
    this.targetGrade = const Value.absent(),
    this.isActive = const Value.absent(),
    this.enrolledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnrollmentsCompanion.insert({
    required String id,
    required String schoolId,
    required String studentId,
    required String academicYearId,
    required String gradeLevel,
    this.classStream = const Value.absent(),
    this.snapshotGrade = const Value.absent(),
    this.targetGrade = const Value.absent(),
    this.isActive = const Value.absent(),
    this.enrolledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        schoolId = Value(schoolId),
        studentId = Value(studentId),
        academicYearId = Value(academicYearId),
        gradeLevel = Value(gradeLevel);
  static Insertable<Enrollment> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<String>? academicYearId,
    Expression<String>? gradeLevel,
    Expression<String>? classStream,
    Expression<String>? snapshotGrade,
    Expression<String>? targetGrade,
    Expression<bool>? isActive,
    Expression<DateTime>? enrolledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (academicYearId != null) 'academic_year_id': academicYearId,
      if (gradeLevel != null) 'grade_level': gradeLevel,
      if (classStream != null) 'class_stream': classStream,
      if (snapshotGrade != null) 'snapshot_grade': snapshotGrade,
      if (targetGrade != null) 'target_grade': targetGrade,
      if (isActive != null) 'is_active': isActive,
      if (enrolledAt != null) 'enrolled_at': enrolledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnrollmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? schoolId,
      Value<String>? studentId,
      Value<String>? academicYearId,
      Value<String>? gradeLevel,
      Value<String?>? classStream,
      Value<String?>? snapshotGrade,
      Value<String?>? targetGrade,
      Value<bool>? isActive,
      Value<DateTime?>? enrolledAt,
      Value<int>? rowid}) {
    return EnrollmentsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      academicYearId: academicYearId ?? this.academicYearId,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      classStream: classStream ?? this.classStream,
      snapshotGrade: snapshotGrade ?? this.snapshotGrade,
      targetGrade: targetGrade ?? this.targetGrade,
      isActive: isActive ?? this.isActive,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (academicYearId.present) {
      map['academic_year_id'] = Variable<String>(academicYearId.value);
    }
    if (gradeLevel.present) {
      map['grade_level'] = Variable<String>(gradeLevel.value);
    }
    if (classStream.present) {
      map['class_stream'] = Variable<String>(classStream.value);
    }
    if (snapshotGrade.present) {
      map['snapshot_grade'] = Variable<String>(snapshotGrade.value);
    }
    if (targetGrade.present) {
      map['target_grade'] = Variable<String>(targetGrade.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (enrolledAt.present) {
      map['enrolled_at'] = Variable<DateTime>(enrolledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnrollmentsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('academicYearId: $academicYearId, ')
          ..write('gradeLevel: $gradeLevel, ')
          ..write('classStream: $classStream, ')
          ..write('snapshotGrade: $snapshotGrade, ')
          ..write('targetGrade: $targetGrade, ')
          ..write('isActive: $isActive, ')
          ..write('enrolledAt: $enrolledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeeCategoriesTable extends FeeCategories
    with TableInfo<$FeeCategoriesTable, FeeCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeeCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _schoolIdMeta =
      const VerificationMeta('schoolId');
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
      'school_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, schoolId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fee_categories';
  @override
  VerificationContext validateIntegrity(Insertable<FeeCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(_schoolIdMeta,
          schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta));
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeeCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeeCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      schoolId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}school_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $FeeCategoriesTable createAlias(String alias) {
    return $FeeCategoriesTable(attachedDatabase, alias);
  }
}

class FeeCategory extends DataClass implements Insertable<FeeCategory> {
  final String id;
  final String schoolId;
  final String name;
  const FeeCategory(
      {required this.id, required this.schoolId, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['name'] = Variable<String>(name);
    return map;
  }

  FeeCategoriesCompanion toCompanion(bool nullToAbsent) {
    return FeeCategoriesCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      name: Value(name),
    );
  }

  factory FeeCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeeCategory(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'name': serializer.toJson<String>(name),
    };
  }

  FeeCategory copyWith({String? id, String? schoolId, String? name}) =>
      FeeCategory(
        id: id ?? this.id,
        schoolId: schoolId ?? this.schoolId,
        name: name ?? this.name,
      );
  FeeCategory copyWithCompanion(FeeCategoriesCompanion data) {
    return FeeCategory(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeeCategory(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, schoolId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeeCategory &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.name == this.name);
}

class FeeCategoriesCompanion extends UpdateCompanion<FeeCategory> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> name;
  final Value<int> rowid;
  const FeeCategoriesCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeeCategoriesCompanion.insert({
    required String id,
    required String schoolId,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        schoolId = Value(schoolId),
        name = Value(name);
  static Insertable<FeeCategory> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeeCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? schoolId,
      Value<String>? name,
      Value<int>? rowid}) {
    return FeeCategoriesCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeeCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeeStructuresTable extends FeeStructures
    with TableInfo<$FeeStructuresTable, FeeStructure> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeeStructuresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _schoolIdMeta =
      const VerificationMeta('schoolId');
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
      'school_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _academicYearIdMeta =
      const VerificationMeta('academicYearId');
  @override
  late final GeneratedColumn<String> academicYearId = GeneratedColumn<String>(
      'academic_year_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetGradeMeta =
      const VerificationMeta('targetGrade');
  @override
  late final GeneratedColumn<String> targetGrade = GeneratedColumn<String>(
      'target_grade', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('USD'));
  static const VerificationMeta _recurrenceMeta =
      const VerificationMeta('recurrence');
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
      'recurrence', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('TERM'));
  static const VerificationMeta _billingTypeMeta =
      const VerificationMeta('billingType');
  @override
  late final GeneratedColumn<String> billingType = GeneratedColumn<String>(
      'billing_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('FIXED'));
  static const VerificationMeta _billableMonthsMeta =
      const VerificationMeta('billableMonths');
  @override
  late final GeneratedColumn<String> billableMonths = GeneratedColumn<String>(
      'billable_months', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _suspensionsMeta =
      const VerificationMeta('suspensions');
  @override
  late final GeneratedColumn<String> suspensions = GeneratedColumn<String>(
      'suspensions', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        schoolId,
        academicYearId,
        name,
        targetGrade,
        categoryId,
        amount,
        currency,
        recurrence,
        billingType,
        billableMonths,
        isActive,
        suspensions,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fee_structures';
  @override
  VerificationContext validateIntegrity(Insertable<FeeStructure> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(_schoolIdMeta,
          schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta));
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('academic_year_id')) {
      context.handle(
          _academicYearIdMeta,
          academicYearId.isAcceptableOrUnknown(
              data['academic_year_id']!, _academicYearIdMeta));
    } else if (isInserting) {
      context.missing(_academicYearIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_grade')) {
      context.handle(
          _targetGradeMeta,
          targetGrade.isAcceptableOrUnknown(
              data['target_grade']!, _targetGradeMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('recurrence')) {
      context.handle(
          _recurrenceMeta,
          recurrence.isAcceptableOrUnknown(
              data['recurrence']!, _recurrenceMeta));
    }
    if (data.containsKey('billing_type')) {
      context.handle(
          _billingTypeMeta,
          billingType.isAcceptableOrUnknown(
              data['billing_type']!, _billingTypeMeta));
    }
    if (data.containsKey('billable_months')) {
      context.handle(
          _billableMonthsMeta,
          billableMonths.isAcceptableOrUnknown(
              data['billable_months']!, _billableMonthsMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('suspensions')) {
      context.handle(
          _suspensionsMeta,
          suspensions.isAcceptableOrUnknown(
              data['suspensions']!, _suspensionsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeeStructure map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeeStructure(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      schoolId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}school_id'])!,
      academicYearId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}academic_year_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      targetGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_grade']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      recurrence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence'])!,
      billingType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}billing_type'])!,
      billableMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}billable_months']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      suspensions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}suspensions']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FeeStructuresTable createAlias(String alias) {
    return $FeeStructuresTable(attachedDatabase, alias);
  }
}

class FeeStructure extends DataClass implements Insertable<FeeStructure> {
  final String id;
  final String schoolId;
  final String academicYearId;
  final String name;
  final String? targetGrade;
  final String? categoryId;
  final int amount;
  final String currency;
  final String recurrence;
  final String billingType;
  final String? billableMonths;
  final bool isActive;
  final String? suspensions;
  final DateTime createdAt;
  const FeeStructure(
      {required this.id,
      required this.schoolId,
      required this.academicYearId,
      required this.name,
      this.targetGrade,
      this.categoryId,
      required this.amount,
      required this.currency,
      required this.recurrence,
      required this.billingType,
      this.billableMonths,
      required this.isActive,
      this.suspensions,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['academic_year_id'] = Variable<String>(academicYearId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || targetGrade != null) {
      map['target_grade'] = Variable<String>(targetGrade);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['amount'] = Variable<int>(amount);
    map['currency'] = Variable<String>(currency);
    map['recurrence'] = Variable<String>(recurrence);
    map['billing_type'] = Variable<String>(billingType);
    if (!nullToAbsent || billableMonths != null) {
      map['billable_months'] = Variable<String>(billableMonths);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || suspensions != null) {
      map['suspensions'] = Variable<String>(suspensions);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FeeStructuresCompanion toCompanion(bool nullToAbsent) {
    return FeeStructuresCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      academicYearId: Value(academicYearId),
      name: Value(name),
      targetGrade: targetGrade == null && nullToAbsent
          ? const Value.absent()
          : Value(targetGrade),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amount: Value(amount),
      currency: Value(currency),
      recurrence: Value(recurrence),
      billingType: Value(billingType),
      billableMonths: billableMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(billableMonths),
      isActive: Value(isActive),
      suspensions: suspensions == null && nullToAbsent
          ? const Value.absent()
          : Value(suspensions),
      createdAt: Value(createdAt),
    );
  }

  factory FeeStructure.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeeStructure(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      academicYearId: serializer.fromJson<String>(json['academicYearId']),
      name: serializer.fromJson<String>(json['name']),
      targetGrade: serializer.fromJson<String?>(json['targetGrade']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      amount: serializer.fromJson<int>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      billingType: serializer.fromJson<String>(json['billingType']),
      billableMonths: serializer.fromJson<String?>(json['billableMonths']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      suspensions: serializer.fromJson<String?>(json['suspensions']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'academicYearId': serializer.toJson<String>(academicYearId),
      'name': serializer.toJson<String>(name),
      'targetGrade': serializer.toJson<String?>(targetGrade),
      'categoryId': serializer.toJson<String?>(categoryId),
      'amount': serializer.toJson<int>(amount),
      'currency': serializer.toJson<String>(currency),
      'recurrence': serializer.toJson<String>(recurrence),
      'billingType': serializer.toJson<String>(billingType),
      'billableMonths': serializer.toJson<String?>(billableMonths),
      'isActive': serializer.toJson<bool>(isActive),
      'suspensions': serializer.toJson<String?>(suspensions),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FeeStructure copyWith(
          {String? id,
          String? schoolId,
          String? academicYearId,
          String? name,
          Value<String?> targetGrade = const Value.absent(),
          Value<String?> categoryId = const Value.absent(),
          int? amount,
          String? currency,
          String? recurrence,
          String? billingType,
          Value<String?> billableMonths = const Value.absent(),
          bool? isActive,
          Value<String?> suspensions = const Value.absent(),
          DateTime? createdAt}) =>
      FeeStructure(
        id: id ?? this.id,
        schoolId: schoolId ?? this.schoolId,
        academicYearId: academicYearId ?? this.academicYearId,
        name: name ?? this.name,
        targetGrade: targetGrade.present ? targetGrade.value : this.targetGrade,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        recurrence: recurrence ?? this.recurrence,
        billingType: billingType ?? this.billingType,
        billableMonths:
            billableMonths.present ? billableMonths.value : this.billableMonths,
        isActive: isActive ?? this.isActive,
        suspensions: suspensions.present ? suspensions.value : this.suspensions,
        createdAt: createdAt ?? this.createdAt,
      );
  FeeStructure copyWithCompanion(FeeStructuresCompanion data) {
    return FeeStructure(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      academicYearId: data.academicYearId.present
          ? data.academicYearId.value
          : this.academicYearId,
      name: data.name.present ? data.name.value : this.name,
      targetGrade:
          data.targetGrade.present ? data.targetGrade.value : this.targetGrade,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      recurrence:
          data.recurrence.present ? data.recurrence.value : this.recurrence,
      billingType:
          data.billingType.present ? data.billingType.value : this.billingType,
      billableMonths: data.billableMonths.present
          ? data.billableMonths.value
          : this.billableMonths,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      suspensions:
          data.suspensions.present ? data.suspensions.value : this.suspensions,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeeStructure(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('academicYearId: $academicYearId, ')
          ..write('name: $name, ')
          ..write('targetGrade: $targetGrade, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('recurrence: $recurrence, ')
          ..write('billingType: $billingType, ')
          ..write('billableMonths: $billableMonths, ')
          ..write('isActive: $isActive, ')
          ..write('suspensions: $suspensions, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      schoolId,
      academicYearId,
      name,
      targetGrade,
      categoryId,
      amount,
      currency,
      recurrence,
      billingType,
      billableMonths,
      isActive,
      suspensions,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeeStructure &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.academicYearId == this.academicYearId &&
          other.name == this.name &&
          other.targetGrade == this.targetGrade &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.recurrence == this.recurrence &&
          other.billingType == this.billingType &&
          other.billableMonths == this.billableMonths &&
          other.isActive == this.isActive &&
          other.suspensions == this.suspensions &&
          other.createdAt == this.createdAt);
}

class FeeStructuresCompanion extends UpdateCompanion<FeeStructure> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> academicYearId;
  final Value<String> name;
  final Value<String?> targetGrade;
  final Value<String?> categoryId;
  final Value<int> amount;
  final Value<String> currency;
  final Value<String> recurrence;
  final Value<String> billingType;
  final Value<String?> billableMonths;
  final Value<bool> isActive;
  final Value<String?> suspensions;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FeeStructuresCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.academicYearId = const Value.absent(),
    this.name = const Value.absent(),
    this.targetGrade = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.billingType = const Value.absent(),
    this.billableMonths = const Value.absent(),
    this.isActive = const Value.absent(),
    this.suspensions = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeeStructuresCompanion.insert({
    required String id,
    required String schoolId,
    required String academicYearId,
    required String name,
    this.targetGrade = const Value.absent(),
    this.categoryId = const Value.absent(),
    required int amount,
    this.currency = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.billingType = const Value.absent(),
    this.billableMonths = const Value.absent(),
    this.isActive = const Value.absent(),
    this.suspensions = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        schoolId = Value(schoolId),
        academicYearId = Value(academicYearId),
        name = Value(name),
        amount = Value(amount),
        createdAt = Value(createdAt);
  static Insertable<FeeStructure> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? academicYearId,
    Expression<String>? name,
    Expression<String>? targetGrade,
    Expression<String>? categoryId,
    Expression<int>? amount,
    Expression<String>? currency,
    Expression<String>? recurrence,
    Expression<String>? billingType,
    Expression<String>? billableMonths,
    Expression<bool>? isActive,
    Expression<String>? suspensions,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (academicYearId != null) 'academic_year_id': academicYearId,
      if (name != null) 'name': name,
      if (targetGrade != null) 'target_grade': targetGrade,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (recurrence != null) 'recurrence': recurrence,
      if (billingType != null) 'billing_type': billingType,
      if (billableMonths != null) 'billable_months': billableMonths,
      if (isActive != null) 'is_active': isActive,
      if (suspensions != null) 'suspensions': suspensions,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeeStructuresCompanion copyWith(
      {Value<String>? id,
      Value<String>? schoolId,
      Value<String>? academicYearId,
      Value<String>? name,
      Value<String?>? targetGrade,
      Value<String?>? categoryId,
      Value<int>? amount,
      Value<String>? currency,
      Value<String>? recurrence,
      Value<String>? billingType,
      Value<String?>? billableMonths,
      Value<bool>? isActive,
      Value<String?>? suspensions,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return FeeStructuresCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      academicYearId: academicYearId ?? this.academicYearId,
      name: name ?? this.name,
      targetGrade: targetGrade ?? this.targetGrade,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      recurrence: recurrence ?? this.recurrence,
      billingType: billingType ?? this.billingType,
      billableMonths: billableMonths ?? this.billableMonths,
      isActive: isActive ?? this.isActive,
      suspensions: suspensions ?? this.suspensions,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (academicYearId.present) {
      map['academic_year_id'] = Variable<String>(academicYearId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetGrade.present) {
      map['target_grade'] = Variable<String>(targetGrade.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (billingType.present) {
      map['billing_type'] = Variable<String>(billingType.value);
    }
    if (billableMonths.present) {
      map['billable_months'] = Variable<String>(billableMonths.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (suspensions.present) {
      map['suspensions'] = Variable<String>(suspensions.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeeStructuresCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('academicYearId: $academicYearId, ')
          ..write('name: $name, ')
          ..write('targetGrade: $targetGrade, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('recurrence: $recurrence, ')
          ..write('billingType: $billingType, ')
          ..write('billableMonths: $billableMonths, ')
          ..write('isActive: $isActive, ')
          ..write('suspensions: $suspensions, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _schoolIdMeta =
      const VerificationMeta('schoolId');
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
      'school_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
      'student_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceNumberMeta =
      const VerificationMeta('invoiceNumber');
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
      'invoice_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _termIdMeta = const VerificationMeta('termId');
  @override
  late final GeneratedColumn<String> termId = GeneratedColumn<String>(
      'term_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _snapshotGradeMeta =
      const VerificationMeta('snapshotGrade');
  @override
  late final GeneratedColumn<String> snapshotGrade = GeneratedColumn<String>(
      'snapshot_grade', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ISSUED'));
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        schoolId,
        studentId,
        invoiceNumber,
        termId,
        snapshotGrade,
        status,
        dueDate,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(Insertable<Invoice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(_schoolIdMeta,
          schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta));
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
          _invoiceNumberMeta,
          invoiceNumber.isAcceptableOrUnknown(
              data['invoice_number']!, _invoiceNumberMeta));
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('term_id')) {
      context.handle(_termIdMeta,
          termId.isAcceptableOrUnknown(data['term_id']!, _termIdMeta));
    }
    if (data.containsKey('snapshot_grade')) {
      context.handle(
          _snapshotGradeMeta,
          snapshotGrade.isAcceptableOrUnknown(
              data['snapshot_grade']!, _snapshotGradeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      schoolId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}school_id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}student_id'])!,
      invoiceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_number'])!,
      termId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}term_id']),
      snapshotGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}snapshot_grade']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final String id;
  final String schoolId;
  final String studentId;
  final String invoiceNumber;
  final String? termId;
  final String? snapshotGrade;
  final String status;
  final DateTime? dueDate;
  final DateTime? createdAt;
  const Invoice(
      {required this.id,
      required this.schoolId,
      required this.studentId,
      required this.invoiceNumber,
      this.termId,
      this.snapshotGrade,
      required this.status,
      this.dueDate,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    if (!nullToAbsent || termId != null) {
      map['term_id'] = Variable<String>(termId);
    }
    if (!nullToAbsent || snapshotGrade != null) {
      map['snapshot_grade'] = Variable<String>(snapshotGrade);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      invoiceNumber: Value(invoiceNumber),
      termId:
          termId == null && nullToAbsent ? const Value.absent() : Value(termId),
      snapshotGrade: snapshotGrade == null && nullToAbsent
          ? const Value.absent()
          : Value(snapshotGrade),
      status: Value(status),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Invoice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      termId: serializer.fromJson<String?>(json['termId']),
      snapshotGrade: serializer.fromJson<String?>(json['snapshotGrade']),
      status: serializer.fromJson<String>(json['status']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'studentId': serializer.toJson<String>(studentId),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'termId': serializer.toJson<String?>(termId),
      'snapshotGrade': serializer.toJson<String?>(snapshotGrade),
      'status': serializer.toJson<String>(status),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  Invoice copyWith(
          {String? id,
          String? schoolId,
          String? studentId,
          String? invoiceNumber,
          Value<String?> termId = const Value.absent(),
          Value<String?> snapshotGrade = const Value.absent(),
          String? status,
          Value<DateTime?> dueDate = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent()}) =>
      Invoice(
        id: id ?? this.id,
        schoolId: schoolId ?? this.schoolId,
        studentId: studentId ?? this.studentId,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        termId: termId.present ? termId.value : this.termId,
        snapshotGrade:
            snapshotGrade.present ? snapshotGrade.value : this.snapshotGrade,
        status: status ?? this.status,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      termId: data.termId.present ? data.termId.value : this.termId,
      snapshotGrade: data.snapshotGrade.present
          ? data.snapshotGrade.value
          : this.snapshotGrade,
      status: data.status.present ? data.status.value : this.status,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('termId: $termId, ')
          ..write('snapshotGrade: $snapshotGrade, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, schoolId, studentId, invoiceNumber,
      termId, snapshotGrade, status, dueDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.invoiceNumber == this.invoiceNumber &&
          other.termId == this.termId &&
          other.snapshotGrade == this.snapshotGrade &&
          other.status == this.status &&
          other.dueDate == this.dueDate &&
          other.createdAt == this.createdAt);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<String> invoiceNumber;
  final Value<String?> termId;
  final Value<String?> snapshotGrade;
  final Value<String> status;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.termId = const Value.absent(),
    this.snapshotGrade = const Value.absent(),
    this.status = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesCompanion.insert({
    required String id,
    required String schoolId,
    required String studentId,
    required String invoiceNumber,
    this.termId = const Value.absent(),
    this.snapshotGrade = const Value.absent(),
    this.status = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        schoolId = Value(schoolId),
        studentId = Value(studentId),
        invoiceNumber = Value(invoiceNumber);
  static Insertable<Invoice> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<String>? invoiceNumber,
    Expression<String>? termId,
    Expression<String>? snapshotGrade,
    Expression<String>? status,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (termId != null) 'term_id': termId,
      if (snapshotGrade != null) 'snapshot_grade': snapshotGrade,
      if (status != null) 'status': status,
      if (dueDate != null) 'due_date': dueDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? schoolId,
      Value<String>? studentId,
      Value<String>? invoiceNumber,
      Value<String?>? termId,
      Value<String?>? snapshotGrade,
      Value<String>? status,
      Value<DateTime?>? dueDate,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return InvoicesCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      termId: termId ?? this.termId,
      snapshotGrade: snapshotGrade ?? this.snapshotGrade,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (termId.present) {
      map['term_id'] = Variable<String>(termId.value);
    }
    if (snapshotGrade.present) {
      map['snapshot_grade'] = Variable<String>(snapshotGrade.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('termId: $termId, ')
          ..write('snapshotGrade: $snapshotGrade, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceItemsTable extends InvoiceItems
    with TableInfo<$InvoiceItemsTable, InvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _feeStructureIdMeta =
      const VerificationMeta('feeStructureId');
  @override
  late final GeneratedColumn<String> feeStructureId = GeneratedColumn<String>(
      'fee_structure_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, invoiceId, description, amount, feeStructureId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_items';
  @override
  VerificationContext validateIntegrity(Insertable<InvoiceItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('fee_structure_id')) {
      context.handle(
          _feeStructureIdMeta,
          feeStructureId.isAcceptableOrUnknown(
              data['fee_structure_id']!, _feeStructureIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      feeStructureId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}fee_structure_id']),
    );
  }

  @override
  $InvoiceItemsTable createAlias(String alias) {
    return $InvoiceItemsTable(attachedDatabase, alias);
  }
}

class InvoiceItem extends DataClass implements Insertable<InvoiceItem> {
  final String id;
  final String invoiceId;
  final String description;
  final int amount;
  final String? feeStructureId;
  const InvoiceItem(
      {required this.id,
      required this.invoiceId,
      required this.description,
      required this.amount,
      this.feeStructureId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || feeStructureId != null) {
      map['fee_structure_id'] = Variable<String>(feeStructureId);
    }
    return map;
  }

  InvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      description: Value(description),
      amount: Value(amount),
      feeStructureId: feeStructureId == null && nullToAbsent
          ? const Value.absent()
          : Value(feeStructureId),
    );
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceItem(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<int>(json['amount']),
      feeStructureId: serializer.fromJson<String?>(json['feeStructureId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<int>(amount),
      'feeStructureId': serializer.toJson<String?>(feeStructureId),
    };
  }

  InvoiceItem copyWith(
          {String? id,
          String? invoiceId,
          String? description,
          int? amount,
          Value<String?> feeStructureId = const Value.absent()}) =>
      InvoiceItem(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        feeStructureId:
            feeStructureId.present ? feeStructureId.value : this.feeStructureId,
      );
  InvoiceItem copyWithCompanion(InvoiceItemsCompanion data) {
    return InvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      description:
          data.description.present ? data.description.value : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      feeStructureId: data.feeStructureId.present
          ? data.feeStructureId.value
          : this.feeStructureId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('feeStructureId: $feeStructureId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, invoiceId, description, amount, feeStructureId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.feeStructureId == this.feeStructureId);
}

class InvoiceItemsCompanion extends UpdateCompanion<InvoiceItem> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<String> description;
  final Value<int> amount;
  final Value<String?> feeStructureId;
  final Value<int> rowid;
  const InvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.feeStructureId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceItemsCompanion.insert({
    required String id,
    required String invoiceId,
    required String description,
    required int amount,
    this.feeStructureId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceId = Value(invoiceId),
        description = Value(description),
        amount = Value(amount);
  static Insertable<InvoiceItem> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<String>? description,
    Expression<int>? amount,
    Expression<String>? feeStructureId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (feeStructureId != null) 'fee_structure_id': feeStructureId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceId,
      Value<String>? description,
      Value<int>? amount,
      Value<String?>? feeStructureId,
      Value<int>? rowid}) {
    return InvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      feeStructureId: feeStructureId ?? this.feeStructureId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (feeStructureId.present) {
      map['fee_structure_id'] = Variable<String>(feeStructureId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('feeStructureId: $feeStructureId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _schoolIdMeta =
      const VerificationMeta('schoolId');
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
      'school_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
      'student_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceCodeMeta =
      const VerificationMeta('referenceCode');
  @override
  late final GeneratedColumn<String> referenceCode = GeneratedColumn<String>(
      'reference_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receivedAtMeta =
      const VerificationMeta('receivedAt');
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
      'received_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        schoolId,
        studentId,
        amount,
        method,
        referenceCode,
        receivedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(_schoolIdMeta,
          schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta));
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('reference_code')) {
      context.handle(
          _referenceCodeMeta,
          referenceCode.isAcceptableOrUnknown(
              data['reference_code']!, _referenceCodeMeta));
    }
    if (data.containsKey('received_at')) {
      context.handle(
          _receivedAtMeta,
          receivedAt.isAcceptableOrUnknown(
              data['received_at']!, _receivedAtMeta));
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      schoolId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}school_id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}student_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      referenceCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_code']),
      receivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}received_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String schoolId;
  final String studentId;
  final int amount;
  final String method;
  final String? referenceCode;
  final DateTime receivedAt;
  final DateTime createdAt;
  const Payment(
      {required this.id,
      required this.schoolId,
      required this.studentId,
      required this.amount,
      required this.method,
      this.referenceCode,
      required this.receivedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    map['amount'] = Variable<int>(amount);
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || referenceCode != null) {
      map['reference_code'] = Variable<String>(referenceCode);
    }
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      amount: Value(amount),
      method: Value(method),
      referenceCode: referenceCode == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceCode),
      receivedAt: Value(receivedAt),
      createdAt: Value(createdAt),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      amount: serializer.fromJson<int>(json['amount']),
      method: serializer.fromJson<String>(json['method']),
      referenceCode: serializer.fromJson<String?>(json['referenceCode']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'studentId': serializer.toJson<String>(studentId),
      'amount': serializer.toJson<int>(amount),
      'method': serializer.toJson<String>(method),
      'referenceCode': serializer.toJson<String?>(referenceCode),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Payment copyWith(
          {String? id,
          String? schoolId,
          String? studentId,
          int? amount,
          String? method,
          Value<String?> referenceCode = const Value.absent(),
          DateTime? receivedAt,
          DateTime? createdAt}) =>
      Payment(
        id: id ?? this.id,
        schoolId: schoolId ?? this.schoolId,
        studentId: studentId ?? this.studentId,
        amount: amount ?? this.amount,
        method: method ?? this.method,
        referenceCode:
            referenceCode.present ? referenceCode.value : this.referenceCode,
        receivedAt: receivedAt ?? this.receivedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      amount: data.amount.present ? data.amount.value : this.amount,
      method: data.method.present ? data.method.value : this.method,
      referenceCode: data.referenceCode.present
          ? data.referenceCode.value
          : this.referenceCode,
      receivedAt:
          data.receivedAt.present ? data.receivedAt.value : this.receivedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('referenceCode: $referenceCode, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, schoolId, studentId, amount, method,
      referenceCode, receivedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.amount == this.amount &&
          other.method == this.method &&
          other.referenceCode == this.referenceCode &&
          other.receivedAt == this.receivedAt &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<int> amount;
  final Value<String> method;
  final Value<String?> referenceCode;
  final Value<DateTime> receivedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.amount = const Value.absent(),
    this.method = const Value.absent(),
    this.referenceCode = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String schoolId,
    required String studentId,
    required int amount,
    required String method,
    this.referenceCode = const Value.absent(),
    required DateTime receivedAt,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        schoolId = Value(schoolId),
        studentId = Value(studentId),
        amount = Value(amount),
        method = Value(method),
        receivedAt = Value(receivedAt),
        createdAt = Value(createdAt);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<int>? amount,
    Expression<String>? method,
    Expression<String>? referenceCode,
    Expression<DateTime>? receivedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (amount != null) 'amount': amount,
      if (method != null) 'method': method,
      if (referenceCode != null) 'reference_code': referenceCode,
      if (receivedAt != null) 'received_at': receivedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? schoolId,
      Value<String>? studentId,
      Value<int>? amount,
      Value<String>? method,
      Value<String?>? referenceCode,
      Value<DateTime>? receivedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      referenceCode: referenceCode ?? this.referenceCode,
      receivedAt: receivedAt ?? this.receivedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (referenceCode.present) {
      map['reference_code'] = Variable<String>(referenceCode.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('referenceCode: $referenceCode, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _schoolIdMeta =
      const VerificationMeta('schoolId');
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
      'school_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
      'student_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceCodeMeta =
      const VerificationMeta('referenceCode');
  @override
  late final GeneratedColumn<String> referenceCode = GeneratedColumn<String>(
      'reference_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('USD'));
  static const VerificationMeta _occurredAtMeta =
      const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
      'occurred_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        schoolId,
        studentId,
        type,
        category,
        amount,
        description,
        invoiceId,
        referenceCode,
        currency,
        occurredAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LedgerEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(_schoolIdMeta,
          schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta));
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    }
    if (data.containsKey('reference_code')) {
      context.handle(
          _referenceCodeMeta,
          referenceCode.isAcceptableOrUnknown(
              data['reference_code']!, _referenceCodeMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
          _occurredAtMeta,
          occurredAt.isAcceptableOrUnknown(
              data['occurred_at']!, _occurredAtMeta));
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      schoolId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}school_id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}student_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id']),
      referenceCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_code']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerEntry extends DataClass implements Insertable<LedgerEntry> {
  final String id;
  final String schoolId;
  final String studentId;
  final String type;
  final String category;
  final int amount;
  final String? description;
  final String? invoiceId;
  final String? referenceCode;
  final String currency;
  final DateTime occurredAt;
  const LedgerEntry(
      {required this.id,
      required this.schoolId,
      required this.studentId,
      required this.type,
      required this.category,
      required this.amount,
      this.description,
      this.invoiceId,
      this.referenceCode,
      required this.currency,
      required this.occurredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || invoiceId != null) {
      map['invoice_id'] = Variable<String>(invoiceId);
    }
    if (!nullToAbsent || referenceCode != null) {
      map['reference_code'] = Variable<String>(referenceCode);
    }
    map['currency'] = Variable<String>(currency);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      type: Value(type),
      category: Value(category),
      amount: Value(amount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      invoiceId: invoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceId),
      referenceCode: referenceCode == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceCode),
      currency: Value(currency),
      occurredAt: Value(occurredAt),
    );
  }

  factory LedgerEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntry(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<int>(json['amount']),
      description: serializer.fromJson<String?>(json['description']),
      invoiceId: serializer.fromJson<String?>(json['invoiceId']),
      referenceCode: serializer.fromJson<String?>(json['referenceCode']),
      currency: serializer.fromJson<String>(json['currency']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schoolId': serializer.toJson<String>(schoolId),
      'studentId': serializer.toJson<String>(studentId),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<int>(amount),
      'description': serializer.toJson<String?>(description),
      'invoiceId': serializer.toJson<String?>(invoiceId),
      'referenceCode': serializer.toJson<String?>(referenceCode),
      'currency': serializer.toJson<String>(currency),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  LedgerEntry copyWith(
          {String? id,
          String? schoolId,
          String? studentId,
          String? type,
          String? category,
          int? amount,
          Value<String?> description = const Value.absent(),
          Value<String?> invoiceId = const Value.absent(),
          Value<String?> referenceCode = const Value.absent(),
          String? currency,
          DateTime? occurredAt}) =>
      LedgerEntry(
        id: id ?? this.id,
        schoolId: schoolId ?? this.schoolId,
        studentId: studentId ?? this.studentId,
        type: type ?? this.type,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        description: description.present ? description.value : this.description,
        invoiceId: invoiceId.present ? invoiceId.value : this.invoiceId,
        referenceCode:
            referenceCode.present ? referenceCode.value : this.referenceCode,
        currency: currency ?? this.currency,
        occurredAt: occurredAt ?? this.occurredAt,
      );
  LedgerEntry copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerEntry(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      description:
          data.description.present ? data.description.value : this.description,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      referenceCode: data.referenceCode.present
          ? data.referenceCode.value
          : this.referenceCode,
      currency: data.currency.present ? data.currency.value : this.currency,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntry(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('referenceCode: $referenceCode, ')
          ..write('currency: $currency, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, schoolId, studentId, type, category,
      amount, description, invoiceId, referenceCode, currency, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntry &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.type == this.type &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.invoiceId == this.invoiceId &&
          other.referenceCode == this.referenceCode &&
          other.currency == this.currency &&
          other.occurredAt == this.occurredAt);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntry> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<String> type;
  final Value<String> category;
  final Value<int> amount;
  final Value<String?> description;
  final Value<String?> invoiceId;
  final Value<String?> referenceCode;
  final Value<String> currency;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.referenceCode = const Value.absent(),
    this.currency = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    required String id,
    required String schoolId,
    required String studentId,
    required String type,
    required String category,
    required int amount,
    this.description = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.referenceCode = const Value.absent(),
    this.currency = const Value.absent(),
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        schoolId = Value(schoolId),
        studentId = Value(studentId),
        type = Value(type),
        category = Value(category),
        amount = Value(amount),
        occurredAt = Value(occurredAt);
  static Insertable<LedgerEntry> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<String>? type,
    Expression<String>? category,
    Expression<int>? amount,
    Expression<String>? description,
    Expression<String>? invoiceId,
    Expression<String>? referenceCode,
    Expression<String>? currency,
    Expression<DateTime>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (referenceCode != null) 'reference_code': referenceCode,
      if (currency != null) 'currency': currency,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? schoolId,
      Value<String>? studentId,
      Value<String>? type,
      Value<String>? category,
      Value<int>? amount,
      Value<String?>? description,
      Value<String?>? invoiceId,
      Value<String?>? referenceCode,
      Value<String>? currency,
      Value<DateTime>? occurredAt,
      Value<int>? rowid}) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      invoiceId: invoiceId ?? this.invoiceId,
      referenceCode: referenceCode ?? this.referenceCode,
      currency: currency ?? this.currency,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (referenceCode.present) {
      map['reference_code'] = Variable<String>(referenceCode.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('referenceCode: $referenceCode, ')
          ..write('currency: $currency, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchoolsTable schools = $SchoolsTable(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $EnrollmentsTable enrollments = $EnrollmentsTable(this);
  late final $FeeCategoriesTable feeCategories = $FeeCategoriesTable(this);
  late final $FeeStructuresTable feeStructures = $FeeStructuresTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceItemsTable invoiceItems = $InvoiceItemsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        schools,
        students,
        enrollments,
        feeCategories,
        feeStructures,
        invoices,
        invoiceItems,
        payments,
        ledgerEntries
      ];
}

typedef $$SchoolsTableCreateCompanionBuilder = SchoolsCompanion Function({
  required String id,
  required String name,
  required String subdomain,
  Value<String?> logoUrl,
  Value<String?> currentPlanId,
  Value<String> subscriptionStatus,
  Value<DateTime?> subscriptionEndsAt,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SchoolsTableUpdateCompanionBuilder = SchoolsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> subdomain,
  Value<String?> logoUrl,
  Value<String?> currentPlanId,
  Value<String> subscriptionStatus,
  Value<DateTime?> subscriptionEndsAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SchoolsTableFilterComposer
    extends Composer<_$AppDatabase, $SchoolsTable> {
  $$SchoolsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subdomain => $composableBuilder(
      column: $table.subdomain, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoUrl => $composableBuilder(
      column: $table.logoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currentPlanId => $composableBuilder(
      column: $table.currentPlanId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subscriptionStatus => $composableBuilder(
      column: $table.subscriptionStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get subscriptionEndsAt => $composableBuilder(
      column: $table.subscriptionEndsAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SchoolsTableOrderingComposer
    extends Composer<_$AppDatabase, $SchoolsTable> {
  $$SchoolsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subdomain => $composableBuilder(
      column: $table.subdomain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoUrl => $composableBuilder(
      column: $table.logoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentPlanId => $composableBuilder(
      column: $table.currentPlanId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subscriptionStatus => $composableBuilder(
      column: $table.subscriptionStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get subscriptionEndsAt => $composableBuilder(
      column: $table.subscriptionEndsAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SchoolsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchoolsTable> {
  $$SchoolsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get subdomain =>
      $composableBuilder(column: $table.subdomain, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get currentPlanId => $composableBuilder(
      column: $table.currentPlanId, builder: (column) => column);

  GeneratedColumn<String> get subscriptionStatus => $composableBuilder(
      column: $table.subscriptionStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get subscriptionEndsAt => $composableBuilder(
      column: $table.subscriptionEndsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SchoolsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SchoolsTable,
    School,
    $$SchoolsTableFilterComposer,
    $$SchoolsTableOrderingComposer,
    $$SchoolsTableAnnotationComposer,
    $$SchoolsTableCreateCompanionBuilder,
    $$SchoolsTableUpdateCompanionBuilder,
    (School, BaseReferences<_$AppDatabase, $SchoolsTable, School>),
    School,
    PrefetchHooks Function()> {
  $$SchoolsTableTableManager(_$AppDatabase db, $SchoolsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchoolsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchoolsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchoolsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> subdomain = const Value.absent(),
            Value<String?> logoUrl = const Value.absent(),
            Value<String?> currentPlanId = const Value.absent(),
            Value<String> subscriptionStatus = const Value.absent(),
            Value<DateTime?> subscriptionEndsAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SchoolsCompanion(
            id: id,
            name: name,
            subdomain: subdomain,
            logoUrl: logoUrl,
            currentPlanId: currentPlanId,
            subscriptionStatus: subscriptionStatus,
            subscriptionEndsAt: subscriptionEndsAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String subdomain,
            Value<String?> logoUrl = const Value.absent(),
            Value<String?> currentPlanId = const Value.absent(),
            Value<String> subscriptionStatus = const Value.absent(),
            Value<DateTime?> subscriptionEndsAt = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SchoolsCompanion.insert(
            id: id,
            name: name,
            subdomain: subdomain,
            logoUrl: logoUrl,
            currentPlanId: currentPlanId,
            subscriptionStatus: subscriptionStatus,
            subscriptionEndsAt: subscriptionEndsAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SchoolsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SchoolsTable,
    School,
    $$SchoolsTableFilterComposer,
    $$SchoolsTableOrderingComposer,
    $$SchoolsTableAnnotationComposer,
    $$SchoolsTableCreateCompanionBuilder,
    $$SchoolsTableUpdateCompanionBuilder,
    (School, BaseReferences<_$AppDatabase, $SchoolsTable, School>),
    School,
    PrefetchHooks Function()>;
typedef $$StudentsTableCreateCompanionBuilder = StudentsCompanion Function({
  required String id,
  required String schoolId,
  required String firstName,
  required String lastName,
  Value<String?> gender,
  Value<String?> nationalId,
  Value<String> status,
  Value<DateTime?> dateOfBirth,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$StudentsTableUpdateCompanionBuilder = StudentsCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> firstName,
  Value<String> lastName,
  Value<String?> gender,
  Value<String?> nationalId,
  Value<String> status,
  Value<DateTime?> dateOfBirth,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StudentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudentsTable,
    Student,
    $$StudentsTableFilterComposer,
    $$StudentsTableOrderingComposer,
    $$StudentsTableAnnotationComposer,
    $$StudentsTableCreateCompanionBuilder,
    $$StudentsTableUpdateCompanionBuilder,
    (Student, BaseReferences<_$AppDatabase, $StudentsTable, Student>),
    Student,
    PrefetchHooks Function()> {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> schoolId = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<String> lastName = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> nationalId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudentsCompanion(
            id: id,
            schoolId: schoolId,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            nationalId: nationalId,
            status: status,
            dateOfBirth: dateOfBirth,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String schoolId,
            required String firstName,
            required String lastName,
            Value<String?> gender = const Value.absent(),
            Value<String?> nationalId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StudentsCompanion.insert(
            id: id,
            schoolId: schoolId,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            nationalId: nationalId,
            status: status,
            dateOfBirth: dateOfBirth,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StudentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudentsTable,
    Student,
    $$StudentsTableFilterComposer,
    $$StudentsTableOrderingComposer,
    $$StudentsTableAnnotationComposer,
    $$StudentsTableCreateCompanionBuilder,
    $$StudentsTableUpdateCompanionBuilder,
    (Student, BaseReferences<_$AppDatabase, $StudentsTable, Student>),
    Student,
    PrefetchHooks Function()>;
typedef $$EnrollmentsTableCreateCompanionBuilder = EnrollmentsCompanion
    Function({
  required String id,
  required String schoolId,
  required String studentId,
  required String academicYearId,
  required String gradeLevel,
  Value<String?> classStream,
  Value<String?> snapshotGrade,
  Value<String?> targetGrade,
  Value<bool> isActive,
  Value<DateTime?> enrolledAt,
  Value<int> rowid,
});
typedef $$EnrollmentsTableUpdateCompanionBuilder = EnrollmentsCompanion
    Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> studentId,
  Value<String> academicYearId,
  Value<String> gradeLevel,
  Value<String?> classStream,
  Value<String?> snapshotGrade,
  Value<String?> targetGrade,
  Value<bool> isActive,
  Value<DateTime?> enrolledAt,
  Value<int> rowid,
});

class $$EnrollmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get academicYearId => $composableBuilder(
      column: $table.academicYearId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gradeLevel => $composableBuilder(
      column: $table.gradeLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get classStream => $composableBuilder(
      column: $table.classStream, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get snapshotGrade => $composableBuilder(
      column: $table.snapshotGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetGrade => $composableBuilder(
      column: $table.targetGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get enrolledAt => $composableBuilder(
      column: $table.enrolledAt, builder: (column) => ColumnFilters(column));
}

class $$EnrollmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get academicYearId => $composableBuilder(
      column: $table.academicYearId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gradeLevel => $composableBuilder(
      column: $table.gradeLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get classStream => $composableBuilder(
      column: $table.classStream, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get snapshotGrade => $composableBuilder(
      column: $table.snapshotGrade,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetGrade => $composableBuilder(
      column: $table.targetGrade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get enrolledAt => $composableBuilder(
      column: $table.enrolledAt, builder: (column) => ColumnOrderings(column));
}

class $$EnrollmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get academicYearId => $composableBuilder(
      column: $table.academicYearId, builder: (column) => column);

  GeneratedColumn<String> get gradeLevel => $composableBuilder(
      column: $table.gradeLevel, builder: (column) => column);

  GeneratedColumn<String> get classStream => $composableBuilder(
      column: $table.classStream, builder: (column) => column);

  GeneratedColumn<String> get snapshotGrade => $composableBuilder(
      column: $table.snapshotGrade, builder: (column) => column);

  GeneratedColumn<String> get targetGrade => $composableBuilder(
      column: $table.targetGrade, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get enrolledAt => $composableBuilder(
      column: $table.enrolledAt, builder: (column) => column);
}

class $$EnrollmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EnrollmentsTable,
    Enrollment,
    $$EnrollmentsTableFilterComposer,
    $$EnrollmentsTableOrderingComposer,
    $$EnrollmentsTableAnnotationComposer,
    $$EnrollmentsTableCreateCompanionBuilder,
    $$EnrollmentsTableUpdateCompanionBuilder,
    (Enrollment, BaseReferences<_$AppDatabase, $EnrollmentsTable, Enrollment>),
    Enrollment,
    PrefetchHooks Function()> {
  $$EnrollmentsTableTableManager(_$AppDatabase db, $EnrollmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnrollmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnrollmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnrollmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> schoolId = const Value.absent(),
            Value<String> studentId = const Value.absent(),
            Value<String> academicYearId = const Value.absent(),
            Value<String> gradeLevel = const Value.absent(),
            Value<String?> classStream = const Value.absent(),
            Value<String?> snapshotGrade = const Value.absent(),
            Value<String?> targetGrade = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> enrolledAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EnrollmentsCompanion(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            academicYearId: academicYearId,
            gradeLevel: gradeLevel,
            classStream: classStream,
            snapshotGrade: snapshotGrade,
            targetGrade: targetGrade,
            isActive: isActive,
            enrolledAt: enrolledAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String schoolId,
            required String studentId,
            required String academicYearId,
            required String gradeLevel,
            Value<String?> classStream = const Value.absent(),
            Value<String?> snapshotGrade = const Value.absent(),
            Value<String?> targetGrade = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> enrolledAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EnrollmentsCompanion.insert(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            academicYearId: academicYearId,
            gradeLevel: gradeLevel,
            classStream: classStream,
            snapshotGrade: snapshotGrade,
            targetGrade: targetGrade,
            isActive: isActive,
            enrolledAt: enrolledAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EnrollmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EnrollmentsTable,
    Enrollment,
    $$EnrollmentsTableFilterComposer,
    $$EnrollmentsTableOrderingComposer,
    $$EnrollmentsTableAnnotationComposer,
    $$EnrollmentsTableCreateCompanionBuilder,
    $$EnrollmentsTableUpdateCompanionBuilder,
    (Enrollment, BaseReferences<_$AppDatabase, $EnrollmentsTable, Enrollment>),
    Enrollment,
    PrefetchHooks Function()>;
typedef $$FeeCategoriesTableCreateCompanionBuilder = FeeCategoriesCompanion
    Function({
  required String id,
  required String schoolId,
  required String name,
  Value<int> rowid,
});
typedef $$FeeCategoriesTableUpdateCompanionBuilder = FeeCategoriesCompanion
    Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> name,
  Value<int> rowid,
});

class $$FeeCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $FeeCategoriesTable> {
  $$FeeCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$FeeCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FeeCategoriesTable> {
  $$FeeCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$FeeCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeeCategoriesTable> {
  $$FeeCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$FeeCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FeeCategoriesTable,
    FeeCategory,
    $$FeeCategoriesTableFilterComposer,
    $$FeeCategoriesTableOrderingComposer,
    $$FeeCategoriesTableAnnotationComposer,
    $$FeeCategoriesTableCreateCompanionBuilder,
    $$FeeCategoriesTableUpdateCompanionBuilder,
    (
      FeeCategory,
      BaseReferences<_$AppDatabase, $FeeCategoriesTable, FeeCategory>
    ),
    FeeCategory,
    PrefetchHooks Function()> {
  $$FeeCategoriesTableTableManager(_$AppDatabase db, $FeeCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeeCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeeCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeeCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> schoolId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FeeCategoriesCompanion(
            id: id,
            schoolId: schoolId,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String schoolId,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              FeeCategoriesCompanion.insert(
            id: id,
            schoolId: schoolId,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FeeCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FeeCategoriesTable,
    FeeCategory,
    $$FeeCategoriesTableFilterComposer,
    $$FeeCategoriesTableOrderingComposer,
    $$FeeCategoriesTableAnnotationComposer,
    $$FeeCategoriesTableCreateCompanionBuilder,
    $$FeeCategoriesTableUpdateCompanionBuilder,
    (
      FeeCategory,
      BaseReferences<_$AppDatabase, $FeeCategoriesTable, FeeCategory>
    ),
    FeeCategory,
    PrefetchHooks Function()>;
typedef $$FeeStructuresTableCreateCompanionBuilder = FeeStructuresCompanion
    Function({
  required String id,
  required String schoolId,
  required String academicYearId,
  required String name,
  Value<String?> targetGrade,
  Value<String?> categoryId,
  required int amount,
  Value<String> currency,
  Value<String> recurrence,
  Value<String> billingType,
  Value<String?> billableMonths,
  Value<bool> isActive,
  Value<String?> suspensions,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$FeeStructuresTableUpdateCompanionBuilder = FeeStructuresCompanion
    Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> academicYearId,
  Value<String> name,
  Value<String?> targetGrade,
  Value<String?> categoryId,
  Value<int> amount,
  Value<String> currency,
  Value<String> recurrence,
  Value<String> billingType,
  Value<String?> billableMonths,
  Value<bool> isActive,
  Value<String?> suspensions,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$FeeStructuresTableFilterComposer
    extends Composer<_$AppDatabase, $FeeStructuresTable> {
  $$FeeStructuresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get academicYearId => $composableBuilder(
      column: $table.academicYearId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetGrade => $composableBuilder(
      column: $table.targetGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billingType => $composableBuilder(
      column: $table.billingType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billableMonths => $composableBuilder(
      column: $table.billableMonths,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suspensions => $composableBuilder(
      column: $table.suspensions, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FeeStructuresTableOrderingComposer
    extends Composer<_$AppDatabase, $FeeStructuresTable> {
  $$FeeStructuresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get academicYearId => $composableBuilder(
      column: $table.academicYearId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetGrade => $composableBuilder(
      column: $table.targetGrade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billingType => $composableBuilder(
      column: $table.billingType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billableMonths => $composableBuilder(
      column: $table.billableMonths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suspensions => $composableBuilder(
      column: $table.suspensions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FeeStructuresTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeeStructuresTable> {
  $$FeeStructuresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get academicYearId => $composableBuilder(
      column: $table.academicYearId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get targetGrade => $composableBuilder(
      column: $table.targetGrade, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => column);

  GeneratedColumn<String> get billingType => $composableBuilder(
      column: $table.billingType, builder: (column) => column);

  GeneratedColumn<String> get billableMonths => $composableBuilder(
      column: $table.billableMonths, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get suspensions => $composableBuilder(
      column: $table.suspensions, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FeeStructuresTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FeeStructuresTable,
    FeeStructure,
    $$FeeStructuresTableFilterComposer,
    $$FeeStructuresTableOrderingComposer,
    $$FeeStructuresTableAnnotationComposer,
    $$FeeStructuresTableCreateCompanionBuilder,
    $$FeeStructuresTableUpdateCompanionBuilder,
    (
      FeeStructure,
      BaseReferences<_$AppDatabase, $FeeStructuresTable, FeeStructure>
    ),
    FeeStructure,
    PrefetchHooks Function()> {
  $$FeeStructuresTableTableManager(_$AppDatabase db, $FeeStructuresTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeeStructuresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeeStructuresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeeStructuresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> schoolId = const Value.absent(),
            Value<String> academicYearId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> targetGrade = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String> recurrence = const Value.absent(),
            Value<String> billingType = const Value.absent(),
            Value<String?> billableMonths = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> suspensions = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FeeStructuresCompanion(
            id: id,
            schoolId: schoolId,
            academicYearId: academicYearId,
            name: name,
            targetGrade: targetGrade,
            categoryId: categoryId,
            amount: amount,
            currency: currency,
            recurrence: recurrence,
            billingType: billingType,
            billableMonths: billableMonths,
            isActive: isActive,
            suspensions: suspensions,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String schoolId,
            required String academicYearId,
            required String name,
            Value<String?> targetGrade = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            required int amount,
            Value<String> currency = const Value.absent(),
            Value<String> recurrence = const Value.absent(),
            Value<String> billingType = const Value.absent(),
            Value<String?> billableMonths = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> suspensions = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FeeStructuresCompanion.insert(
            id: id,
            schoolId: schoolId,
            academicYearId: academicYearId,
            name: name,
            targetGrade: targetGrade,
            categoryId: categoryId,
            amount: amount,
            currency: currency,
            recurrence: recurrence,
            billingType: billingType,
            billableMonths: billableMonths,
            isActive: isActive,
            suspensions: suspensions,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FeeStructuresTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FeeStructuresTable,
    FeeStructure,
    $$FeeStructuresTableFilterComposer,
    $$FeeStructuresTableOrderingComposer,
    $$FeeStructuresTableAnnotationComposer,
    $$FeeStructuresTableCreateCompanionBuilder,
    $$FeeStructuresTableUpdateCompanionBuilder,
    (
      FeeStructure,
      BaseReferences<_$AppDatabase, $FeeStructuresTable, FeeStructure>
    ),
    FeeStructure,
    PrefetchHooks Function()>;
typedef $$InvoicesTableCreateCompanionBuilder = InvoicesCompanion Function({
  required String id,
  required String schoolId,
  required String studentId,
  required String invoiceNumber,
  Value<String?> termId,
  Value<String?> snapshotGrade,
  Value<String> status,
  Value<DateTime?> dueDate,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$InvoicesTableUpdateCompanionBuilder = InvoicesCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> studentId,
  Value<String> invoiceNumber,
  Value<String?> termId,
  Value<String?> snapshotGrade,
  Value<String> status,
  Value<DateTime?> dueDate,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get termId => $composableBuilder(
      column: $table.termId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get snapshotGrade => $composableBuilder(
      column: $table.snapshotGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get termId => $composableBuilder(
      column: $table.termId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get snapshotGrade => $composableBuilder(
      column: $table.snapshotGrade,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => column);

  GeneratedColumn<String> get termId =>
      $composableBuilder(column: $table.termId, builder: (column) => column);

  GeneratedColumn<String> get snapshotGrade => $composableBuilder(
      column: $table.snapshotGrade, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InvoicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, BaseReferences<_$AppDatabase, $InvoicesTable, Invoice>),
    Invoice,
    PrefetchHooks Function()> {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> schoolId = const Value.absent(),
            Value<String> studentId = const Value.absent(),
            Value<String> invoiceNumber = const Value.absent(),
            Value<String?> termId = const Value.absent(),
            Value<String?> snapshotGrade = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoicesCompanion(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            invoiceNumber: invoiceNumber,
            termId: termId,
            snapshotGrade: snapshotGrade,
            status: status,
            dueDate: dueDate,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String schoolId,
            required String studentId,
            required String invoiceNumber,
            Value<String?> termId = const Value.absent(),
            Value<String?> snapshotGrade = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoicesCompanion.insert(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            invoiceNumber: invoiceNumber,
            termId: termId,
            snapshotGrade: snapshotGrade,
            status: status,
            dueDate: dueDate,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InvoicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, BaseReferences<_$AppDatabase, $InvoicesTable, Invoice>),
    Invoice,
    PrefetchHooks Function()>;
typedef $$InvoiceItemsTableCreateCompanionBuilder = InvoiceItemsCompanion
    Function({
  required String id,
  required String invoiceId,
  required String description,
  required int amount,
  Value<String?> feeStructureId,
  Value<int> rowid,
});
typedef $$InvoiceItemsTableUpdateCompanionBuilder = InvoiceItemsCompanion
    Function({
  Value<String> id,
  Value<String> invoiceId,
  Value<String> description,
  Value<int> amount,
  Value<String?> feeStructureId,
  Value<int> rowid,
});

class $$InvoiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feeStructureId => $composableBuilder(
      column: $table.feeStructureId,
      builder: (column) => ColumnFilters(column));
}

class $$InvoiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feeStructureId => $composableBuilder(
      column: $table.feeStructureId,
      builder: (column) => ColumnOrderings(column));
}

class $$InvoiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get feeStructureId => $composableBuilder(
      column: $table.feeStructureId, builder: (column) => column);
}

class $$InvoiceItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (
      InvoiceItem,
      BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem>
    ),
    InvoiceItem,
    PrefetchHooks Function()> {
  $$InvoiceItemsTableTableManager(_$AppDatabase db, $InvoiceItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String?> feeStructureId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceItemsCompanion(
            id: id,
            invoiceId: invoiceId,
            description: description,
            amount: amount,
            feeStructureId: feeStructureId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceId,
            required String description,
            required int amount,
            Value<String?> feeStructureId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceItemsCompanion.insert(
            id: id,
            invoiceId: invoiceId,
            description: description,
            amount: amount,
            feeStructureId: feeStructureId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InvoiceItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (
      InvoiceItem,
      BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem>
    ),
    InvoiceItem,
    PrefetchHooks Function()>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  required String schoolId,
  required String studentId,
  required int amount,
  required String method,
  Value<String?> referenceCode,
  required DateTime receivedAt,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> studentId,
  Value<int> amount,
  Value<String> method,
  Value<String?> referenceCode,
  Value<DateTime> receivedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceCode => $composableBuilder(
      column: $table.referenceCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceCode => $composableBuilder(
      column: $table.referenceCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get referenceCode => $composableBuilder(
      column: $table.referenceCode, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
      column: $table.receivedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> schoolId = const Value.absent(),
            Value<String> studentId = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<String?> referenceCode = const Value.absent(),
            Value<DateTime> receivedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            amount: amount,
            method: method,
            referenceCode: referenceCode,
            receivedAt: receivedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String schoolId,
            required String studentId,
            required int amount,
            required String method,
            Value<String?> referenceCode = const Value.absent(),
            required DateTime receivedAt,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            amount: amount,
            method: method,
            referenceCode: referenceCode,
            receivedAt: receivedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()>;
typedef $$LedgerEntriesTableCreateCompanionBuilder = LedgerEntriesCompanion
    Function({
  required String id,
  required String schoolId,
  required String studentId,
  required String type,
  required String category,
  required int amount,
  Value<String?> description,
  Value<String?> invoiceId,
  Value<String?> referenceCode,
  Value<String> currency,
  required DateTime occurredAt,
  Value<int> rowid,
});
typedef $$LedgerEntriesTableUpdateCompanionBuilder = LedgerEntriesCompanion
    Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> studentId,
  Value<String> type,
  Value<String> category,
  Value<int> amount,
  Value<String?> description,
  Value<String?> invoiceId,
  Value<String?> referenceCode,
  Value<String> currency,
  Value<DateTime> occurredAt,
  Value<int> rowid,
});

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceCode => $composableBuilder(
      column: $table.referenceCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get schoolId => $composableBuilder(
      column: $table.schoolId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceId => $composableBuilder(
      column: $table.invoiceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceCode => $composableBuilder(
      column: $table.referenceCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get referenceCode => $composableBuilder(
      column: $table.referenceCode, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);
}

class $$LedgerEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LedgerEntriesTable,
    LedgerEntry,
    $$LedgerEntriesTableFilterComposer,
    $$LedgerEntriesTableOrderingComposer,
    $$LedgerEntriesTableAnnotationComposer,
    $$LedgerEntriesTableCreateCompanionBuilder,
    $$LedgerEntriesTableUpdateCompanionBuilder,
    (
      LedgerEntry,
      BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntry>
    ),
    LedgerEntry,
    PrefetchHooks Function()> {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> schoolId = const Value.absent(),
            Value<String> studentId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> invoiceId = const Value.absent(),
            Value<String?> referenceCode = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LedgerEntriesCompanion(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            type: type,
            category: category,
            amount: amount,
            description: description,
            invoiceId: invoiceId,
            referenceCode: referenceCode,
            currency: currency,
            occurredAt: occurredAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String schoolId,
            required String studentId,
            required String type,
            required String category,
            required int amount,
            Value<String?> description = const Value.absent(),
            Value<String?> invoiceId = const Value.absent(),
            Value<String?> referenceCode = const Value.absent(),
            Value<String> currency = const Value.absent(),
            required DateTime occurredAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LedgerEntriesCompanion.insert(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            type: type,
            category: category,
            amount: amount,
            description: description,
            invoiceId: invoiceId,
            referenceCode: referenceCode,
            currency: currency,
            occurredAt: occurredAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LedgerEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LedgerEntriesTable,
    LedgerEntry,
    $$LedgerEntriesTableFilterComposer,
    $$LedgerEntriesTableOrderingComposer,
    $$LedgerEntriesTableAnnotationComposer,
    $$LedgerEntriesTableCreateCompanionBuilder,
    $$LedgerEntriesTableUpdateCompanionBuilder,
    (
      LedgerEntry,
      BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntry>
    ),
    LedgerEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SchoolsTableTableManager get schools =>
      $$SchoolsTableTableManager(_db, _db.schools);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$EnrollmentsTableTableManager get enrollments =>
      $$EnrollmentsTableTableManager(_db, _db.enrollments);
  $$FeeCategoriesTableTableManager get feeCategories =>
      $$FeeCategoriesTableTableManager(_db, _db.feeCategories);
  $$FeeStructuresTableTableManager get feeStructures =>
      $$FeeStructuresTableTableManager(_db, _db.feeStructures);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db, _db.invoiceItems);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
}
