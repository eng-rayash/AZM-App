// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authMethodMeta = const VerificationMeta(
    'authMethod',
  );
  @override
  late final GeneratedColumn<int> authMethod = GeneratedColumn<int>(
    'auth_method',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isBiometricEnabledMeta =
      const VerificationMeta('isBiometricEnabled');
  @override
  late final GeneratedColumn<bool> isBiometricEnabled = GeneratedColumn<bool>(
    'is_biometric_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_biometric_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<int> role = GeneratedColumn<int>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    displayName,
    pinHash,
    authMethod,
    isBiometricEnabled,
    role,
    avatarPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    }
    if (data.containsKey('auth_method')) {
      context.handle(
        _authMethodMeta,
        authMethod.isAcceptableOrUnknown(data['auth_method']!, _authMethodMeta),
      );
    }
    if (data.containsKey('is_biometric_enabled')) {
      context.handle(
        _isBiometricEnabledMeta,
        isBiometricEnabled.isAcceptableOrUnknown(
          data['is_biometric_enabled']!,
          _isBiometricEnabledMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      ),
      authMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auth_method'],
      )!,
      isBiometricEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_biometric_enabled'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role'],
      )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;

  /// Display name shown on dashboard
  final String displayName;

  /// Hashed PIN code (never stored in plain text)
  final String? pinHash;

  /// Preferred authentication method (biometric=0, pin=1, pattern=2)
  final int authMethod;

  /// Whether biometric authentication is enabled
  final bool isBiometricEnabled;

  /// User role (for future multi-user: 0=admin, 1=secretary, 2=viewer)
  final int role;

  /// User avatar path (local file)
  final String? avatarPath;
  const User({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.displayName,
    this.pinHash,
    required this.authMethod,
    required this.isBiometricEnabled,
    required this.role,
    this.avatarPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    map['auth_method'] = Variable<int>(authMethod);
    map['is_biometric_enabled'] = Variable<bool>(isBiometricEnabled);
    map['role'] = Variable<int>(role);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      displayName: Value(displayName),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      authMethod: Value(authMethod),
      isBiometricEnabled: Value(isBiometricEnabled),
      role: Value(role),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      displayName: serializer.fromJson<String>(json['displayName']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      authMethod: serializer.fromJson<int>(json['authMethod']),
      isBiometricEnabled: serializer.fromJson<bool>(json['isBiometricEnabled']),
      role: serializer.fromJson<int>(json['role']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'displayName': serializer.toJson<String>(displayName),
      'pinHash': serializer.toJson<String?>(pinHash),
      'authMethod': serializer.toJson<int>(authMethod),
      'isBiometricEnabled': serializer.toJson<bool>(isBiometricEnabled),
      'role': serializer.toJson<int>(role),
      'avatarPath': serializer.toJson<String?>(avatarPath),
    };
  }

  User copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    String? displayName,
    Value<String?> pinHash = const Value.absent(),
    int? authMethod,
    bool? isBiometricEnabled,
    int? role,
    Value<String?> avatarPath = const Value.absent(),
  }) => User(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    displayName: displayName ?? this.displayName,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    authMethod: authMethod ?? this.authMethod,
    isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    role: role ?? this.role,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      authMethod: data.authMethod.present
          ? data.authMethod.value
          : this.authMethod,
      isBiometricEnabled: data.isBiometricEnabled.present
          ? data.isBiometricEnabled.value
          : this.isBiometricEnabled,
      role: data.role.present ? data.role.value : this.role,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('displayName: $displayName, ')
          ..write('pinHash: $pinHash, ')
          ..write('authMethod: $authMethod, ')
          ..write('isBiometricEnabled: $isBiometricEnabled, ')
          ..write('role: $role, ')
          ..write('avatarPath: $avatarPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    displayName,
    pinHash,
    authMethod,
    isBiometricEnabled,
    role,
    avatarPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.displayName == this.displayName &&
          other.pinHash == this.pinHash &&
          other.authMethod == this.authMethod &&
          other.isBiometricEnabled == this.isBiometricEnabled &&
          other.role == this.role &&
          other.avatarPath == this.avatarPath);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> displayName;
  final Value<String?> pinHash;
  final Value<int> authMethod;
  final Value<bool> isBiometricEnabled;
  final Value<int> role;
  final Value<String?> avatarPath;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.displayName = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.authMethod = const Value.absent(),
    this.isBiometricEnabled = const Value.absent(),
    this.role = const Value.absent(),
    this.avatarPath = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String displayName,
    this.pinHash = const Value.absent(),
    this.authMethod = const Value.absent(),
    this.isBiometricEnabled = const Value.absent(),
    this.role = const Value.absent(),
    this.avatarPath = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       displayName = Value(displayName);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<String>? displayName,
    Expression<String>? pinHash,
    Expression<int>? authMethod,
    Expression<bool>? isBiometricEnabled,
    Expression<int>? role,
    Expression<String>? avatarPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (displayName != null) 'display_name': displayName,
      if (pinHash != null) 'pin_hash': pinHash,
      if (authMethod != null) 'auth_method': authMethod,
      if (isBiometricEnabled != null)
        'is_biometric_enabled': isBiometricEnabled,
      if (role != null) 'role': role,
      if (avatarPath != null) 'avatar_path': avatarPath,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<String>? displayName,
    Value<String?>? pinHash,
    Value<int>? authMethod,
    Value<bool>? isBiometricEnabled,
    Value<int>? role,
    Value<String?>? avatarPath,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      displayName: displayName ?? this.displayName,
      pinHash: pinHash ?? this.pinHash,
      authMethod: authMethod ?? this.authMethod,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      role: role ?? this.role,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (authMethod.present) {
      map['auth_method'] = Variable<int>(authMethod.value);
    }
    if (isBiometricEnabled.present) {
      map['is_biometric_enabled'] = Variable<bool>(isBiometricEnabled.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(role.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('displayName: $displayName, ')
          ..write('pinHash: $pinHash, ')
          ..write('authMethod: $authMethod, ')
          ..write('isBiometricEnabled: $isBiometricEnabled, ')
          ..write('role: $role, ')
          ..write('avatarPath: $avatarPath')
          ..write(')'))
        .toString();
  }
}

class $MeetingsTable extends Meetings with TableInfo<$MeetingsTable, Meeting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeetingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meetingTypeMeta = const VerificationMeta(
    'meetingType',
  );
  @override
  late final GeneratedColumn<int> meetingType = GeneratedColumn<int>(
    'meeting_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _objectiveMeta = const VerificationMeta(
    'objective',
  );
  @override
  late final GeneratedColumn<String> objective = GeneratedColumn<String>(
    'objective',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _agendaMeta = const VerificationMeta('agenda');
  @override
  late final GeneratedColumn<String> agenda = GeneratedColumn<String>(
    'agenda',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decisionsMeta = const VerificationMeta(
    'decisions',
  );
  @override
  late final GeneratedColumn<String> decisions = GeneratedColumn<String>(
    'decisions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outcomesMeta = const VerificationMeta(
    'outcomes',
  );
  @override
  late final GeneratedColumn<String> outcomes = GeneratedColumn<String>(
    'outcomes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attendeesMeta = const VerificationMeta(
    'attendees',
  );
  @override
  late final GeneratedColumn<String> attendees = GeneratedColumn<String>(
    'attendees',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attachmentsMeta = const VerificationMeta(
    'attachments',
  );
  @override
  late final GeneratedColumn<String> attachments = GeneratedColumn<String>(
    'attachments',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<String> minutes = GeneratedColumn<String>(
    'minutes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customMeetingTypeMeta = const VerificationMeta(
    'customMeetingType',
  );
  @override
  late final GeneratedColumn<String> customMeetingType =
      GeneratedColumn<String>(
        'custom_meeting_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    meetingType,
    date,
    time,
    endTime,
    location,
    objective,
    agenda,
    decisions,
    outcomes,
    attendees,
    attachments,
    status,
    priority,
    notes,
    minutes,
    recurrenceRule,
    customMeetingType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meetings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Meeting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('meeting_type')) {
      context.handle(
        _meetingTypeMeta,
        meetingType.isAcceptableOrUnknown(
          data['meeting_type']!,
          _meetingTypeMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('objective')) {
      context.handle(
        _objectiveMeta,
        objective.isAcceptableOrUnknown(data['objective']!, _objectiveMeta),
      );
    }
    if (data.containsKey('agenda')) {
      context.handle(
        _agendaMeta,
        agenda.isAcceptableOrUnknown(data['agenda']!, _agendaMeta),
      );
    }
    if (data.containsKey('decisions')) {
      context.handle(
        _decisionsMeta,
        decisions.isAcceptableOrUnknown(data['decisions']!, _decisionsMeta),
      );
    }
    if (data.containsKey('outcomes')) {
      context.handle(
        _outcomesMeta,
        outcomes.isAcceptableOrUnknown(data['outcomes']!, _outcomesMeta),
      );
    }
    if (data.containsKey('attendees')) {
      context.handle(
        _attendeesMeta,
        attendees.isAcceptableOrUnknown(data['attendees']!, _attendeesMeta),
      );
    }
    if (data.containsKey('attachments')) {
      context.handle(
        _attachmentsMeta,
        attachments.isAcceptableOrUnknown(
          data['attachments']!,
          _attachmentsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
        ),
      );
    }
    if (data.containsKey('custom_meeting_type')) {
      context.handle(
        _customMeetingTypeMeta,
        customMeetingType.isAcceptableOrUnknown(
          data['custom_meeting_type']!,
          _customMeetingTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Meeting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meeting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      meetingType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meeting_type'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      objective: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}objective'],
      ),
      agenda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agenda'],
      ),
      decisions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decisions'],
      ),
      outcomes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcomes'],
      ),
      attendees: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attendees'],
      ),
      attachments: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachments'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}minutes'],
      ),
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
      ),
      customMeetingType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_meeting_type'],
      ),
    );
  }

  @override
  $MeetingsTable createAlias(String alias) {
    return $MeetingsTable(attachedDatabase, alias);
  }
}

class Meeting extends DataClass implements Insertable<Meeting> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;

  /// Meeting title
  final String title;

  /// Meeting type (general=0, administrative=1, emergency=2, etc.)
  final int meetingType;

  /// Meeting date (stored as ISO 8601 string: YYYY-MM-DD)
  final String date;

  /// Meeting time (stored as HH:mm)
  final String time;

  /// Meeting end time (stored as HH:mm, nullable)
  final String? endTime;

  /// Meeting location
  final String? location;

  /// Meeting objective / purpose
  final String? objective;

  /// Agenda items (stored as JSON array of strings)
  final String? agenda;

  /// Decisions made (stored as JSON array of strings)
  final String? decisions;

  /// Meeting outcomes / outputs (stored as JSON array of strings)
  final String? outcomes;

  /// Attendees (stored as JSON array of objects: [{name, role}])
  final String? attendees;

  /// Attachments (stored as JSON array of file paths)
  final String? attachments;

  /// Meeting status (scheduled=0, inProgress=1, completed=2, postponed=3, cancelled=4)
  final int status;

  /// Priority level (critical=0, high=1, medium=2, low=3)
  final int priority;

  /// Additional notes
  final String? notes;

  /// Minutes of meeting (محضر الاجتماع) — full text
  final String? minutes;

  /// Recurrence rule (for repeating meetings, future use)
  final String? recurrenceRule;

  /// Custom dynamic meeting type (if the user overrides the standard enum)
  final String? customMeetingType;
  const Meeting({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.title,
    required this.meetingType,
    required this.date,
    required this.time,
    this.endTime,
    this.location,
    this.objective,
    this.agenda,
    this.decisions,
    this.outcomes,
    this.attendees,
    this.attachments,
    required this.status,
    required this.priority,
    this.notes,
    this.minutes,
    this.recurrenceRule,
    this.customMeetingType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['title'] = Variable<String>(title);
    map['meeting_type'] = Variable<int>(meetingType);
    map['date'] = Variable<String>(date);
    map['time'] = Variable<String>(time);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<String>(endTime);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || objective != null) {
      map['objective'] = Variable<String>(objective);
    }
    if (!nullToAbsent || agenda != null) {
      map['agenda'] = Variable<String>(agenda);
    }
    if (!nullToAbsent || decisions != null) {
      map['decisions'] = Variable<String>(decisions);
    }
    if (!nullToAbsent || outcomes != null) {
      map['outcomes'] = Variable<String>(outcomes);
    }
    if (!nullToAbsent || attendees != null) {
      map['attendees'] = Variable<String>(attendees);
    }
    if (!nullToAbsent || attachments != null) {
      map['attachments'] = Variable<String>(attachments);
    }
    map['status'] = Variable<int>(status);
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || minutes != null) {
      map['minutes'] = Variable<String>(minutes);
    }
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    if (!nullToAbsent || customMeetingType != null) {
      map['custom_meeting_type'] = Variable<String>(customMeetingType);
    }
    return map;
  }

  MeetingsCompanion toCompanion(bool nullToAbsent) {
    return MeetingsCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      title: Value(title),
      meetingType: Value(meetingType),
      date: Value(date),
      time: Value(time),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      objective: objective == null && nullToAbsent
          ? const Value.absent()
          : Value(objective),
      agenda: agenda == null && nullToAbsent
          ? const Value.absent()
          : Value(agenda),
      decisions: decisions == null && nullToAbsent
          ? const Value.absent()
          : Value(decisions),
      outcomes: outcomes == null && nullToAbsent
          ? const Value.absent()
          : Value(outcomes),
      attendees: attendees == null && nullToAbsent
          ? const Value.absent()
          : Value(attendees),
      attachments: attachments == null && nullToAbsent
          ? const Value.absent()
          : Value(attachments),
      status: Value(status),
      priority: Value(priority),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      minutes: minutes == null && nullToAbsent
          ? const Value.absent()
          : Value(minutes),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      customMeetingType: customMeetingType == null && nullToAbsent
          ? const Value.absent()
          : Value(customMeetingType),
    );
  }

  factory Meeting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Meeting(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      title: serializer.fromJson<String>(json['title']),
      meetingType: serializer.fromJson<int>(json['meetingType']),
      date: serializer.fromJson<String>(json['date']),
      time: serializer.fromJson<String>(json['time']),
      endTime: serializer.fromJson<String?>(json['endTime']),
      location: serializer.fromJson<String?>(json['location']),
      objective: serializer.fromJson<String?>(json['objective']),
      agenda: serializer.fromJson<String?>(json['agenda']),
      decisions: serializer.fromJson<String?>(json['decisions']),
      outcomes: serializer.fromJson<String?>(json['outcomes']),
      attendees: serializer.fromJson<String?>(json['attendees']),
      attachments: serializer.fromJson<String?>(json['attachments']),
      status: serializer.fromJson<int>(json['status']),
      priority: serializer.fromJson<int>(json['priority']),
      notes: serializer.fromJson<String?>(json['notes']),
      minutes: serializer.fromJson<String?>(json['minutes']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      customMeetingType: serializer.fromJson<String?>(
        json['customMeetingType'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'title': serializer.toJson<String>(title),
      'meetingType': serializer.toJson<int>(meetingType),
      'date': serializer.toJson<String>(date),
      'time': serializer.toJson<String>(time),
      'endTime': serializer.toJson<String?>(endTime),
      'location': serializer.toJson<String?>(location),
      'objective': serializer.toJson<String?>(objective),
      'agenda': serializer.toJson<String?>(agenda),
      'decisions': serializer.toJson<String?>(decisions),
      'outcomes': serializer.toJson<String?>(outcomes),
      'attendees': serializer.toJson<String?>(attendees),
      'attachments': serializer.toJson<String?>(attachments),
      'status': serializer.toJson<int>(status),
      'priority': serializer.toJson<int>(priority),
      'notes': serializer.toJson<String?>(notes),
      'minutes': serializer.toJson<String?>(minutes),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'customMeetingType': serializer.toJson<String?>(customMeetingType),
    };
  }

  Meeting copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    String? title,
    int? meetingType,
    String? date,
    String? time,
    Value<String?> endTime = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> objective = const Value.absent(),
    Value<String?> agenda = const Value.absent(),
    Value<String?> decisions = const Value.absent(),
    Value<String?> outcomes = const Value.absent(),
    Value<String?> attendees = const Value.absent(),
    Value<String?> attachments = const Value.absent(),
    int? status,
    int? priority,
    Value<String?> notes = const Value.absent(),
    Value<String?> minutes = const Value.absent(),
    Value<String?> recurrenceRule = const Value.absent(),
    Value<String?> customMeetingType = const Value.absent(),
  }) => Meeting(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    title: title ?? this.title,
    meetingType: meetingType ?? this.meetingType,
    date: date ?? this.date,
    time: time ?? this.time,
    endTime: endTime.present ? endTime.value : this.endTime,
    location: location.present ? location.value : this.location,
    objective: objective.present ? objective.value : this.objective,
    agenda: agenda.present ? agenda.value : this.agenda,
    decisions: decisions.present ? decisions.value : this.decisions,
    outcomes: outcomes.present ? outcomes.value : this.outcomes,
    attendees: attendees.present ? attendees.value : this.attendees,
    attachments: attachments.present ? attachments.value : this.attachments,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    notes: notes.present ? notes.value : this.notes,
    minutes: minutes.present ? minutes.value : this.minutes,
    recurrenceRule: recurrenceRule.present
        ? recurrenceRule.value
        : this.recurrenceRule,
    customMeetingType: customMeetingType.present
        ? customMeetingType.value
        : this.customMeetingType,
  );
  Meeting copyWithCompanion(MeetingsCompanion data) {
    return Meeting(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      title: data.title.present ? data.title.value : this.title,
      meetingType: data.meetingType.present
          ? data.meetingType.value
          : this.meetingType,
      date: data.date.present ? data.date.value : this.date,
      time: data.time.present ? data.time.value : this.time,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      location: data.location.present ? data.location.value : this.location,
      objective: data.objective.present ? data.objective.value : this.objective,
      agenda: data.agenda.present ? data.agenda.value : this.agenda,
      decisions: data.decisions.present ? data.decisions.value : this.decisions,
      outcomes: data.outcomes.present ? data.outcomes.value : this.outcomes,
      attendees: data.attendees.present ? data.attendees.value : this.attendees,
      attachments: data.attachments.present
          ? data.attachments.value
          : this.attachments,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      notes: data.notes.present ? data.notes.value : this.notes,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      customMeetingType: data.customMeetingType.present
          ? data.customMeetingType.value
          : this.customMeetingType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Meeting(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('meetingType: $meetingType, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('endTime: $endTime, ')
          ..write('location: $location, ')
          ..write('objective: $objective, ')
          ..write('agenda: $agenda, ')
          ..write('decisions: $decisions, ')
          ..write('outcomes: $outcomes, ')
          ..write('attendees: $attendees, ')
          ..write('attachments: $attachments, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('notes: $notes, ')
          ..write('minutes: $minutes, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('customMeetingType: $customMeetingType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    meetingType,
    date,
    time,
    endTime,
    location,
    objective,
    agenda,
    decisions,
    outcomes,
    attendees,
    attachments,
    status,
    priority,
    notes,
    minutes,
    recurrenceRule,
    customMeetingType,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Meeting &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.title == this.title &&
          other.meetingType == this.meetingType &&
          other.date == this.date &&
          other.time == this.time &&
          other.endTime == this.endTime &&
          other.location == this.location &&
          other.objective == this.objective &&
          other.agenda == this.agenda &&
          other.decisions == this.decisions &&
          other.outcomes == this.outcomes &&
          other.attendees == this.attendees &&
          other.attachments == this.attachments &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.notes == this.notes &&
          other.minutes == this.minutes &&
          other.recurrenceRule == this.recurrenceRule &&
          other.customMeetingType == this.customMeetingType);
}

class MeetingsCompanion extends UpdateCompanion<Meeting> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> title;
  final Value<int> meetingType;
  final Value<String> date;
  final Value<String> time;
  final Value<String?> endTime;
  final Value<String?> location;
  final Value<String?> objective;
  final Value<String?> agenda;
  final Value<String?> decisions;
  final Value<String?> outcomes;
  final Value<String?> attendees;
  final Value<String?> attachments;
  final Value<int> status;
  final Value<int> priority;
  final Value<String?> notes;
  final Value<String?> minutes;
  final Value<String?> recurrenceRule;
  final Value<String?> customMeetingType;
  const MeetingsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.title = const Value.absent(),
    this.meetingType = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.endTime = const Value.absent(),
    this.location = const Value.absent(),
    this.objective = const Value.absent(),
    this.agenda = const Value.absent(),
    this.decisions = const Value.absent(),
    this.outcomes = const Value.absent(),
    this.attendees = const Value.absent(),
    this.attachments = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.notes = const Value.absent(),
    this.minutes = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.customMeetingType = const Value.absent(),
  });
  MeetingsCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String title,
    this.meetingType = const Value.absent(),
    required String date,
    required String time,
    this.endTime = const Value.absent(),
    this.location = const Value.absent(),
    this.objective = const Value.absent(),
    this.agenda = const Value.absent(),
    this.decisions = const Value.absent(),
    this.outcomes = const Value.absent(),
    this.attendees = const Value.absent(),
    this.attachments = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.notes = const Value.absent(),
    this.minutes = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.customMeetingType = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title),
       date = Value(date),
       time = Value(time);
  static Insertable<Meeting> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<String>? title,
    Expression<int>? meetingType,
    Expression<String>? date,
    Expression<String>? time,
    Expression<String>? endTime,
    Expression<String>? location,
    Expression<String>? objective,
    Expression<String>? agenda,
    Expression<String>? decisions,
    Expression<String>? outcomes,
    Expression<String>? attendees,
    Expression<String>? attachments,
    Expression<int>? status,
    Expression<int>? priority,
    Expression<String>? notes,
    Expression<String>? minutes,
    Expression<String>? recurrenceRule,
    Expression<String>? customMeetingType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (title != null) 'title': title,
      if (meetingType != null) 'meeting_type': meetingType,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (endTime != null) 'end_time': endTime,
      if (location != null) 'location': location,
      if (objective != null) 'objective': objective,
      if (agenda != null) 'agenda': agenda,
      if (decisions != null) 'decisions': decisions,
      if (outcomes != null) 'outcomes': outcomes,
      if (attendees != null) 'attendees': attendees,
      if (attachments != null) 'attachments': attachments,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (notes != null) 'notes': notes,
      if (minutes != null) 'minutes': minutes,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (customMeetingType != null) 'custom_meeting_type': customMeetingType,
    });
  }

  MeetingsCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<String>? title,
    Value<int>? meetingType,
    Value<String>? date,
    Value<String>? time,
    Value<String?>? endTime,
    Value<String?>? location,
    Value<String?>? objective,
    Value<String?>? agenda,
    Value<String?>? decisions,
    Value<String?>? outcomes,
    Value<String?>? attendees,
    Value<String?>? attachments,
    Value<int>? status,
    Value<int>? priority,
    Value<String?>? notes,
    Value<String?>? minutes,
    Value<String?>? recurrenceRule,
    Value<String?>? customMeetingType,
  }) {
    return MeetingsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      meetingType: meetingType ?? this.meetingType,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      objective: objective ?? this.objective,
      agenda: agenda ?? this.agenda,
      decisions: decisions ?? this.decisions,
      outcomes: outcomes ?? this.outcomes,
      attendees: attendees ?? this.attendees,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      minutes: minutes ?? this.minutes,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      customMeetingType: customMeetingType ?? this.customMeetingType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (meetingType.present) {
      map['meeting_type'] = Variable<int>(meetingType.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (objective.present) {
      map['objective'] = Variable<String>(objective.value);
    }
    if (agenda.present) {
      map['agenda'] = Variable<String>(agenda.value);
    }
    if (decisions.present) {
      map['decisions'] = Variable<String>(decisions.value);
    }
    if (outcomes.present) {
      map['outcomes'] = Variable<String>(outcomes.value);
    }
    if (attendees.present) {
      map['attendees'] = Variable<String>(attendees.value);
    }
    if (attachments.present) {
      map['attachments'] = Variable<String>(attachments.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<String>(minutes.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (customMeetingType.present) {
      map['custom_meeting_type'] = Variable<String>(customMeetingType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeetingsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('meetingType: $meetingType, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('endTime: $endTime, ')
          ..write('location: $location, ')
          ..write('objective: $objective, ')
          ..write('agenda: $agenda, ')
          ..write('decisions: $decisions, ')
          ..write('outcomes: $outcomes, ')
          ..write('attendees: $attendees, ')
          ..write('attachments: $attachments, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('notes: $notes, ')
          ..write('minutes: $minutes, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('customMeetingType: $customMeetingType')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignedToMeta = const VerificationMeta(
    'assignedTo',
  );
  @override
  late final GeneratedColumn<String> assignedTo = GeneratedColumn<String>(
    'assigned_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _linkedMeetingIdMeta = const VerificationMeta(
    'linkedMeetingId',
  );
  @override
  late final GeneratedColumn<int> linkedMeetingId = GeneratedColumn<int>(
    'linked_meeting_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    description,
    dueDate,
    assignedTo,
    priority,
    status,
    linkedMeetingId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
        _assignedToMeta,
        assignedTo.isAcceptableOrUnknown(data['assigned_to']!, _assignedToMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('linked_meeting_id')) {
      context.handle(
        _linkedMeetingIdMeta,
        linkedMeetingId.isAcceptableOrUnknown(
          data['linked_meeting_id']!,
          _linkedMeetingIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      ),
      assignedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      linkedMeetingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_meeting_id'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;

  /// Task title
  final String title;

  /// Task description / details
  final String? description;

  /// Due date (stored as ISO 8601 string: YYYY-MM-DD)
  final String? dueDate;

  /// Assigned to (name or role of the assignee)
  final String? assignedTo;

  /// Priority level (critical=0, high=1, medium=2, low=3)
  final int priority;

  /// Task status using UnifiedStatus (newItem=0, inProgress=1, completed=3, overdue=4)
  final int status;

  /// Optional: ID of the meeting this task originated from
  final int? linkedMeetingId;
  const Task({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.title,
    this.description,
    this.dueDate,
    this.assignedTo,
    required this.priority,
    required this.status,
    this.linkedMeetingId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    if (!nullToAbsent || assignedTo != null) {
      map['assigned_to'] = Variable<String>(assignedTo);
    }
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || linkedMeetingId != null) {
      map['linked_meeting_id'] = Variable<int>(linkedMeetingId);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      assignedTo: assignedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTo),
      priority: Value(priority),
      status: Value(status),
      linkedMeetingId: linkedMeetingId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedMeetingId),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      assignedTo: serializer.fromJson<String?>(json['assignedTo']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<int>(json['status']),
      linkedMeetingId: serializer.fromJson<int?>(json['linkedMeetingId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'dueDate': serializer.toJson<String?>(dueDate),
      'assignedTo': serializer.toJson<String?>(assignedTo),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<int>(status),
      'linkedMeetingId': serializer.toJson<int?>(linkedMeetingId),
    };
  }

  Task copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> dueDate = const Value.absent(),
    Value<String?> assignedTo = const Value.absent(),
    int? priority,
    int? status,
    Value<int?> linkedMeetingId = const Value.absent(),
  }) => Task(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    assignedTo: assignedTo.present ? assignedTo.value : this.assignedTo,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    linkedMeetingId: linkedMeetingId.present
        ? linkedMeetingId.value
        : this.linkedMeetingId,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      assignedTo: data.assignedTo.present
          ? data.assignedTo.value
          : this.assignedTo,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      linkedMeetingId: data.linkedMeetingId.present
          ? data.linkedMeetingId.value
          : this.linkedMeetingId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('linkedMeetingId: $linkedMeetingId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    description,
    dueDate,
    assignedTo,
    priority,
    status,
    linkedMeetingId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.assignedTo == this.assignedTo &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.linkedMeetingId == this.linkedMeetingId);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> dueDate;
  final Value<String?> assignedTo;
  final Value<int> priority;
  final Value<int> status;
  final Value<int?> linkedMeetingId;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.linkedMeetingId = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.linkedMeetingId = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? dueDate,
    Expression<String>? assignedTo,
    Expression<int>? priority,
    Expression<int>? status,
    Expression<int>? linkedMeetingId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (linkedMeetingId != null) 'linked_meeting_id': linkedMeetingId,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? dueDate,
    Value<String?>? assignedTo,
    Value<int>? priority,
    Value<int>? status,
    Value<int?>? linkedMeetingId,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      linkedMeetingId: linkedMeetingId ?? this.linkedMeetingId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<String>(assignedTo.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (linkedMeetingId.present) {
      map['linked_meeting_id'] = Variable<int>(linkedMeetingId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('linkedMeetingId: $linkedMeetingId')
          ..write(')'))
        .toString();
  }
}

class $FollowUpsTable extends FollowUps
    with TableInfo<$FollowUpsTable, FollowUp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FollowUpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<String> targetDate = GeneratedColumn<String>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<int> entityType = GeneratedColumn<int>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _assignedToMeta = const VerificationMeta(
    'assignedTo',
  );
  @override
  late final GeneratedColumn<String> assignedTo = GeneratedColumn<String>(
    'assigned_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    notes,
    targetDate,
    entityType,
    entityId,
    priority,
    status,
    assignedTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'follow_ups';
  @override
  VerificationContext validateIntegrity(
    Insertable<FollowUp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
        _assignedToMeta,
        assignedTo.isAcceptableOrUnknown(data['assigned_to']!, _assignedToMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FollowUp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FollowUp(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_date'],
      ),
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      assignedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to'],
      ),
    );
  }

  @override
  $FollowUpsTable createAlias(String alias) {
    return $FollowUpsTable(attachedDatabase, alias);
  }
}

class FollowUp extends DataClass implements Insertable<FollowUp> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;

  /// Follow-up title
  final String title;

  /// Follow-up description / notes
  final String? notes;

  /// Target date for the follow-up (ISO 8601 string)
  final String? targetDate;

  /// Type of entity being followed up (0=Meeting, 1=Task, 2=Directive)
  final int entityType;

  /// ID of the entity being followed up
  final int? entityId;

  /// Priority level (critical=0, high=1, medium=2, low=3)
  final int priority;

  /// Status using UnifiedStatus
  final int status;

  /// Assigned entity/person handling the follow-up
  final String? assignedTo;
  const FollowUp({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.title,
    this.notes,
    this.targetDate,
    required this.entityType,
    this.entityId,
    required this.priority,
    required this.status,
    this.assignedTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<String>(targetDate);
    }
    map['entity_type'] = Variable<int>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || assignedTo != null) {
      map['assigned_to'] = Variable<String>(assignedTo);
    }
    return map;
  }

  FollowUpsCompanion toCompanion(bool nullToAbsent) {
    return FollowUpsCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      priority: Value(priority),
      status: Value(status),
      assignedTo: assignedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTo),
    );
  }

  factory FollowUp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FollowUp(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      targetDate: serializer.fromJson<String?>(json['targetDate']),
      entityType: serializer.fromJson<int>(json['entityType']),
      entityId: serializer.fromJson<int?>(json['entityId']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<int>(json['status']),
      assignedTo: serializer.fromJson<String?>(json['assignedTo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'targetDate': serializer.toJson<String?>(targetDate),
      'entityType': serializer.toJson<int>(entityType),
      'entityId': serializer.toJson<int?>(entityId),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<int>(status),
      'assignedTo': serializer.toJson<String?>(assignedTo),
    };
  }

  FollowUp copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    String? title,
    Value<String?> notes = const Value.absent(),
    Value<String?> targetDate = const Value.absent(),
    int? entityType,
    Value<int?> entityId = const Value.absent(),
    int? priority,
    int? status,
    Value<String?> assignedTo = const Value.absent(),
  }) => FollowUp(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    entityType: entityType ?? this.entityType,
    entityId: entityId.present ? entityId.value : this.entityId,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    assignedTo: assignedTo.present ? assignedTo.value : this.assignedTo,
  );
  FollowUp copyWithCompanion(FollowUpsCompanion data) {
    return FollowUp(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      assignedTo: data.assignedTo.present
          ? data.assignedTo.value
          : this.assignedTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FollowUp(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('targetDate: $targetDate, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('assignedTo: $assignedTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    notes,
    targetDate,
    entityType,
    entityId,
    priority,
    status,
    assignedTo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FollowUp &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.targetDate == this.targetDate &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.assignedTo == this.assignedTo);
}

class FollowUpsCompanion extends UpdateCompanion<FollowUp> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> title;
  final Value<String?> notes;
  final Value<String?> targetDate;
  final Value<int> entityType;
  final Value<int?> entityId;
  final Value<int> priority;
  final Value<int> status;
  final Value<String?> assignedTo;
  const FollowUpsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.assignedTo = const Value.absent(),
  });
  FollowUpsCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.assignedTo = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title);
  static Insertable<FollowUp> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? targetDate,
    Expression<int>? entityType,
    Expression<int>? entityId,
    Expression<int>? priority,
    Expression<int>? status,
    Expression<String>? assignedTo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (targetDate != null) 'target_date': targetDate,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (assignedTo != null) 'assigned_to': assignedTo,
    });
  }

  FollowUpsCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<String>? title,
    Value<String?>? notes,
    Value<String?>? targetDate,
    Value<int>? entityType,
    Value<int?>? entityId,
    Value<int>? priority,
    Value<int>? status,
    Value<String?>? assignedTo,
  }) {
    return FollowUpsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      targetDate: targetDate ?? this.targetDate,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<String>(targetDate.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<int>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<String>(assignedTo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FollowUpsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('targetDate: $targetDate, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('assignedTo: $assignedTo')
          ..write(')'))
        .toString();
  }
}

class $DirectivesTable extends Directives
    with TableInfo<$DirectivesTable, Directive> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DirectivesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignedToMeta = const VerificationMeta(
    'assignedTo',
  );
  @override
  late final GeneratedColumn<String> assignedTo = GeneratedColumn<String>(
    'assigned_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<String> deadline = GeneratedColumn<String>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    details,
    source,
    assignedTo,
    deadline,
    priority,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'directives';
  @override
  VerificationContext validateIntegrity(
    Insertable<Directive> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
        _assignedToMeta,
        assignedTo.isAcceptableOrUnknown(data['assigned_to']!, _assignedToMeta),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Directive map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Directive(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      assignedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to'],
      ),
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deadline'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $DirectivesTable createAlias(String alias) {
    return $DirectivesTable(attachedDatabase, alias);
  }
}

class Directive extends DataClass implements Insertable<Directive> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;

  /// Directive title or subject
  final String title;

  /// Detailed instructions
  final String? details;

  /// Directive source / authority (e.g., 'CEO', 'Board')
  final String? source;

  /// Assigned to (department or individual)
  final String? assignedTo;

  /// Target deadline
  final String? deadline;

  /// Priority level (critical=0, high=1, medium=2, low=3)
  final int priority;

  /// Status using UnifiedStatus
  final int status;
  const Directive({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.title,
    this.details,
    this.source,
    this.assignedTo,
    this.deadline,
    required this.priority,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || assignedTo != null) {
      map['assigned_to'] = Variable<String>(assignedTo);
    }
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<String>(deadline);
    }
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<int>(status);
    return map;
  }

  DirectivesCompanion toCompanion(bool nullToAbsent) {
    return DirectivesCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      title: Value(title),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      assignedTo: assignedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTo),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      priority: Value(priority),
      status: Value(status),
    );
  }

  factory Directive.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Directive(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      title: serializer.fromJson<String>(json['title']),
      details: serializer.fromJson<String?>(json['details']),
      source: serializer.fromJson<String?>(json['source']),
      assignedTo: serializer.fromJson<String?>(json['assignedTo']),
      deadline: serializer.fromJson<String?>(json['deadline']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<int>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'title': serializer.toJson<String>(title),
      'details': serializer.toJson<String?>(details),
      'source': serializer.toJson<String?>(source),
      'assignedTo': serializer.toJson<String?>(assignedTo),
      'deadline': serializer.toJson<String?>(deadline),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<int>(status),
    };
  }

  Directive copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    String? title,
    Value<String?> details = const Value.absent(),
    Value<String?> source = const Value.absent(),
    Value<String?> assignedTo = const Value.absent(),
    Value<String?> deadline = const Value.absent(),
    int? priority,
    int? status,
  }) => Directive(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    title: title ?? this.title,
    details: details.present ? details.value : this.details,
    source: source.present ? source.value : this.source,
    assignedTo: assignedTo.present ? assignedTo.value : this.assignedTo,
    deadline: deadline.present ? deadline.value : this.deadline,
    priority: priority ?? this.priority,
    status: status ?? this.status,
  );
  Directive copyWithCompanion(DirectivesCompanion data) {
    return Directive(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      title: data.title.present ? data.title.value : this.title,
      details: data.details.present ? data.details.value : this.details,
      source: data.source.present ? data.source.value : this.source,
      assignedTo: data.assignedTo.present
          ? data.assignedTo.value
          : this.assignedTo,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Directive(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('details: $details, ')
          ..write('source: $source, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('deadline: $deadline, ')
          ..write('priority: $priority, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    details,
    source,
    assignedTo,
    deadline,
    priority,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Directive &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.title == this.title &&
          other.details == this.details &&
          other.source == this.source &&
          other.assignedTo == this.assignedTo &&
          other.deadline == this.deadline &&
          other.priority == this.priority &&
          other.status == this.status);
}

class DirectivesCompanion extends UpdateCompanion<Directive> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> title;
  final Value<String?> details;
  final Value<String?> source;
  final Value<String?> assignedTo;
  final Value<String?> deadline;
  final Value<int> priority;
  final Value<int> status;
  const DirectivesCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.title = const Value.absent(),
    this.details = const Value.absent(),
    this.source = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.deadline = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
  });
  DirectivesCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String title,
    this.details = const Value.absent(),
    this.source = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.deadline = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title);
  static Insertable<Directive> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<String>? title,
    Expression<String>? details,
    Expression<String>? source,
    Expression<String>? assignedTo,
    Expression<String>? deadline,
    Expression<int>? priority,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (title != null) 'title': title,
      if (details != null) 'details': details,
      if (source != null) 'source': source,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (deadline != null) 'deadline': deadline,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
    });
  }

  DirectivesCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<String>? title,
    Value<String?>? details,
    Value<String?>? source,
    Value<String?>? assignedTo,
    Value<String?>? deadline,
    Value<int>? priority,
    Value<int>? status,
  }) {
    return DirectivesCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      details: details ?? this.details,
      source: source ?? this.source,
      assignedTo: assignedTo ?? this.assignedTo,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<String>(assignedTo.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<String>(deadline.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DirectivesCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('details: $details, ')
          ..write('source: $source, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('deadline: $deadline, ')
          ..write('priority: $priority, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 150,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVipMeta = const VerificationMeta('isVip');
  @override
  late final GeneratedColumn<bool> isVip = GeneratedColumn<bool>(
    'is_vip',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_vip" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    name,
    position,
    company,
    phoneNumber,
    email,
    isVip,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Contact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('is_vip')) {
      context.handle(
        _isVipMeta,
        isVip.isAcceptableOrUnknown(data['is_vip']!, _isVipMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      ),
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      isVip: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_vip'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;

  /// Full name
  final String name;

  /// Position or job title
  final String? position;

  /// Company or organization
  final String? company;

  /// Primary phone number
  final String? phoneNumber;

  /// Email address
  final String? email;

  /// Is this a VIP contact?
  final bool isVip;

  /// Notes about the contact
  final String? notes;
  const Contact({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.name,
    this.position,
    this.company,
    this.phoneNumber,
    this.email,
    required this.isVip,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<String>(position);
    }
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['is_vip'] = Variable<bool>(isVip);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      name: Value(name),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      isVip: Value(isVip),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Contact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<String?>(json['position']),
      company: serializer.fromJson<String?>(json['company']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      email: serializer.fromJson<String?>(json['email']),
      isVip: serializer.fromJson<bool>(json['isVip']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<String?>(position),
      'company': serializer.toJson<String?>(company),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'email': serializer.toJson<String?>(email),
      'isVip': serializer.toJson<bool>(isVip),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Contact copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    String? name,
    Value<String?> position = const Value.absent(),
    Value<String?> company = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
    Value<String?> email = const Value.absent(),
    bool? isVip,
    Value<String?> notes = const Value.absent(),
  }) => Contact(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    name: name ?? this.name,
    position: position.present ? position.value : this.position,
    company: company.present ? company.value : this.company,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    email: email.present ? email.value : this.email,
    isVip: isVip ?? this.isVip,
    notes: notes.present ? notes.value : this.notes,
  );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
      company: data.company.present ? data.company.value : this.company,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      email: data.email.present ? data.email.value : this.email,
      isVip: data.isVip.present ? data.isVip.value : this.isVip,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('company: $company, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('email: $email, ')
          ..write('isVip: $isVip, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    name,
    position,
    company,
    phoneNumber,
    email,
    isVip,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.name == this.name &&
          other.position == this.position &&
          other.company == this.company &&
          other.phoneNumber == this.phoneNumber &&
          other.email == this.email &&
          other.isVip == this.isVip &&
          other.notes == this.notes);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> name;
  final Value<String?> position;
  final Value<String?> company;
  final Value<String?> phoneNumber;
  final Value<String?> email;
  final Value<bool> isVip;
  final Value<String?> notes;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.company = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.email = const Value.absent(),
    this.isVip = const Value.absent(),
    this.notes = const Value.absent(),
  });
  ContactsCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String name,
    this.position = const Value.absent(),
    this.company = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.email = const Value.absent(),
    this.isVip = const Value.absent(),
    this.notes = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<Contact> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<String>? name,
    Expression<String>? position,
    Expression<String>? company,
    Expression<String>? phoneNumber,
    Expression<String>? email,
    Expression<bool>? isVip,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (company != null) 'company': company,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (email != null) 'email': email,
      if (isVip != null) 'is_vip': isVip,
      if (notes != null) 'notes': notes,
    });
  }

  ContactsCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<String>? name,
    Value<String?>? position,
    Value<String?>? company,
    Value<String?>? phoneNumber,
    Value<String?>? email,
    Value<bool>? isVip,
    Value<String?>? notes,
  }) {
    return ContactsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      position: position ?? this.position,
      company: company ?? this.company,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isVip: isVip ?? this.isVip,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (isVip.present) {
      map['is_vip'] = Variable<bool>(isVip.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('company: $company, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('email: $email, ')
          ..write('isVip: $isVip, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $AppointmentsTable extends Appointments
    with TableInfo<$AppointmentsTable, Appointment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
    'contact_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    contactId,
    date,
    time,
    durationMinutes,
    location,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Appointment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Appointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appointment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }
}

class Appointment extends DataClass implements Insertable<Appointment> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;

  /// Appointment title
  final String title;

  /// Optional link to a contact
  final int? contactId;

  /// Date of the appointment (ISO 8601)
  final String date;

  /// Time of the appointment
  final String time;

  /// Expected duration in minutes
  final int durationMinutes;

  /// Location
  final String? location;

  /// Status using UnifiedStatus
  final int status;
  const Appointment({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.title,
    this.contactId,
    required this.date,
    required this.time,
    required this.durationMinutes,
    this.location,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<int>(contactId);
    }
    map['date'] = Variable<String>(date);
    map['time'] = Variable<String>(time);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['status'] = Variable<int>(status);
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      title: Value(title),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
      date: Value(date),
      time: Value(time),
      durationMinutes: Value(durationMinutes),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      status: Value(status),
    );
  }

  factory Appointment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appointment(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      title: serializer.fromJson<String>(json['title']),
      contactId: serializer.fromJson<int?>(json['contactId']),
      date: serializer.fromJson<String>(json['date']),
      time: serializer.fromJson<String>(json['time']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      location: serializer.fromJson<String?>(json['location']),
      status: serializer.fromJson<int>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'title': serializer.toJson<String>(title),
      'contactId': serializer.toJson<int?>(contactId),
      'date': serializer.toJson<String>(date),
      'time': serializer.toJson<String>(time),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'location': serializer.toJson<String?>(location),
      'status': serializer.toJson<int>(status),
    };
  }

  Appointment copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    String? title,
    Value<int?> contactId = const Value.absent(),
    String? date,
    String? time,
    int? durationMinutes,
    Value<String?> location = const Value.absent(),
    int? status,
  }) => Appointment(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    title: title ?? this.title,
    contactId: contactId.present ? contactId.value : this.contactId,
    date: date ?? this.date,
    time: time ?? this.time,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    location: location.present ? location.value : this.location,
    status: status ?? this.status,
  );
  Appointment copyWithCompanion(AppointmentsCompanion data) {
    return Appointment(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      title: data.title.present ? data.title.value : this.title,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      date: data.date.present ? data.date.value : this.date,
      time: data.time.present ? data.time.value : this.time,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      location: data.location.present ? data.location.value : this.location,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appointment(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('contactId: $contactId, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('location: $location, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    contactId,
    date,
    time,
    durationMinutes,
    location,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appointment &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.title == this.title &&
          other.contactId == this.contactId &&
          other.date == this.date &&
          other.time == this.time &&
          other.durationMinutes == this.durationMinutes &&
          other.location == this.location &&
          other.status == this.status);
}

class AppointmentsCompanion extends UpdateCompanion<Appointment> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> title;
  final Value<int?> contactId;
  final Value<String> date;
  final Value<String> time;
  final Value<int> durationMinutes;
  final Value<String?> location;
  final Value<int> status;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.title = const Value.absent(),
    this.contactId = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.location = const Value.absent(),
    this.status = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String title,
    this.contactId = const Value.absent(),
    required String date,
    required String time,
    this.durationMinutes = const Value.absent(),
    this.location = const Value.absent(),
    this.status = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title),
       date = Value(date),
       time = Value(time);
  static Insertable<Appointment> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<String>? title,
    Expression<int>? contactId,
    Expression<String>? date,
    Expression<String>? time,
    Expression<int>? durationMinutes,
    Expression<String>? location,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (title != null) 'title': title,
      if (contactId != null) 'contact_id': contactId,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (location != null) 'location': location,
      if (status != null) 'status': status,
    });
  }

  AppointmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<String>? title,
    Value<int?>? contactId,
    Value<String>? date,
    Value<String>? time,
    Value<int>? durationMinutes,
    Value<String?>? location,
    Value<int>? status,
  }) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      contactId: contactId ?? this.contactId,
      date: date ?? this.date,
      time: time ?? this.time,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      location: location ?? this.location,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('contactId: $contactId, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('location: $location, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $ArchiveTable extends Archive with TableInfo<$ArchiveTable, ArchiveData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArchiveTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hijriDateMeta = const VerificationMeta(
    'hijriDate',
  );
  @override
  late final GeneratedColumn<String> hijriDate = GeneratedColumn<String>(
    'hijri_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentDateMeta = const VerificationMeta(
    'documentDate',
  );
  @override
  late final GeneratedColumn<String> documentDate = GeneratedColumn<String>(
    'document_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _directedEntityMeta = const VerificationMeta(
    'directedEntity',
  );
  @override
  late final GeneratedColumn<String> directedEntity = GeneratedColumn<String>(
    'directed_entity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isConfidentialMeta = const VerificationMeta(
    'isConfidential',
  );
  @override
  late final GeneratedColumn<bool> isConfidential = GeneratedColumn<bool>(
    'is_confidential',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_confidential" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    referenceNumber,
    hijriDate,
    documentDate,
    directedEntity,
    category,
    localFilePath,
    tags,
    notes,
    isConfidential,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'archive';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArchiveData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('hijri_date')) {
      context.handle(
        _hijriDateMeta,
        hijriDate.isAcceptableOrUnknown(data['hijri_date']!, _hijriDateMeta),
      );
    }
    if (data.containsKey('document_date')) {
      context.handle(
        _documentDateMeta,
        documentDate.isAcceptableOrUnknown(
          data['document_date']!,
          _documentDateMeta,
        ),
      );
    }
    if (data.containsKey('directed_entity')) {
      context.handle(
        _directedEntityMeta,
        directedEntity.isAcceptableOrUnknown(
          data['directed_entity']!,
          _directedEntityMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_confidential')) {
      context.handle(
        _isConfidentialMeta,
        isConfidential.isAcceptableOrUnknown(
          data['is_confidential']!,
          _isConfidentialMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArchiveData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArchiveData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      ),
      hijriDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hijri_date'],
      ),
      documentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_date'],
      ),
      directedEntity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}directed_entity'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isConfidential: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_confidential'],
      )!,
    );
  }

  @override
  $ArchiveTable createAlias(String alias) {
    return $ArchiveTable(attachedDatabase, alias);
  }
}

class ArchiveData extends DataClass implements Insertable<ArchiveData> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;

  /// Document title
  final String title;

  /// Reference or document number (صادر / وارد)
  final String? referenceNumber;

  /// Date of the document in Hijri calendar
  final String? hijriDate;

  /// Date of the document in Gregorian calendar
  final String? documentDate;

  /// Directed entity / Destination
  final String? directedEntity;

  /// Category (e.g., Financial, Administrative, Secret / Memo Type)
  final String? category;

  /// Local file path for offline access
  final String? localFilePath;

  /// Comma-separated tags for fast search
  final String? tags;

  /// General memo notes
  final String? notes;

  /// Is highly confidential?
  final bool isConfidential;
  const ArchiveData({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.title,
    this.referenceNumber,
    this.hijriDate,
    this.documentDate,
    this.directedEntity,
    this.category,
    this.localFilePath,
    this.tags,
    this.notes,
    required this.isConfidential,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    if (!nullToAbsent || hijriDate != null) {
      map['hijri_date'] = Variable<String>(hijriDate);
    }
    if (!nullToAbsent || documentDate != null) {
      map['document_date'] = Variable<String>(documentDate);
    }
    if (!nullToAbsent || directedEntity != null) {
      map['directed_entity'] = Variable<String>(directedEntity);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || localFilePath != null) {
      map['local_file_path'] = Variable<String>(localFilePath);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_confidential'] = Variable<bool>(isConfidential);
    return map;
  }

  ArchiveCompanion toCompanion(bool nullToAbsent) {
    return ArchiveCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      title: Value(title),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      hijriDate: hijriDate == null && nullToAbsent
          ? const Value.absent()
          : Value(hijriDate),
      documentDate: documentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(documentDate),
      directedEntity: directedEntity == null && nullToAbsent
          ? const Value.absent()
          : Value(directedEntity),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      localFilePath: localFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localFilePath),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isConfidential: Value(isConfidential),
    );
  }

  factory ArchiveData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArchiveData(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      title: serializer.fromJson<String>(json['title']),
      referenceNumber: serializer.fromJson<String?>(json['referenceNumber']),
      hijriDate: serializer.fromJson<String?>(json['hijriDate']),
      documentDate: serializer.fromJson<String?>(json['documentDate']),
      directedEntity: serializer.fromJson<String?>(json['directedEntity']),
      category: serializer.fromJson<String?>(json['category']),
      localFilePath: serializer.fromJson<String?>(json['localFilePath']),
      tags: serializer.fromJson<String?>(json['tags']),
      notes: serializer.fromJson<String?>(json['notes']),
      isConfidential: serializer.fromJson<bool>(json['isConfidential']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'title': serializer.toJson<String>(title),
      'referenceNumber': serializer.toJson<String?>(referenceNumber),
      'hijriDate': serializer.toJson<String?>(hijriDate),
      'documentDate': serializer.toJson<String?>(documentDate),
      'directedEntity': serializer.toJson<String?>(directedEntity),
      'category': serializer.toJson<String?>(category),
      'localFilePath': serializer.toJson<String?>(localFilePath),
      'tags': serializer.toJson<String?>(tags),
      'notes': serializer.toJson<String?>(notes),
      'isConfidential': serializer.toJson<bool>(isConfidential),
    };
  }

  ArchiveData copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    String? title,
    Value<String?> referenceNumber = const Value.absent(),
    Value<String?> hijriDate = const Value.absent(),
    Value<String?> documentDate = const Value.absent(),
    Value<String?> directedEntity = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> localFilePath = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isConfidential,
  }) => ArchiveData(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    title: title ?? this.title,
    referenceNumber: referenceNumber.present
        ? referenceNumber.value
        : this.referenceNumber,
    hijriDate: hijriDate.present ? hijriDate.value : this.hijriDate,
    documentDate: documentDate.present ? documentDate.value : this.documentDate,
    directedEntity: directedEntity.present
        ? directedEntity.value
        : this.directedEntity,
    category: category.present ? category.value : this.category,
    localFilePath: localFilePath.present
        ? localFilePath.value
        : this.localFilePath,
    tags: tags.present ? tags.value : this.tags,
    notes: notes.present ? notes.value : this.notes,
    isConfidential: isConfidential ?? this.isConfidential,
  );
  ArchiveData copyWithCompanion(ArchiveCompanion data) {
    return ArchiveData(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      title: data.title.present ? data.title.value : this.title,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      hijriDate: data.hijriDate.present ? data.hijriDate.value : this.hijriDate,
      documentDate: data.documentDate.present
          ? data.documentDate.value
          : this.documentDate,
      directedEntity: data.directedEntity.present
          ? data.directedEntity.value
          : this.directedEntity,
      category: data.category.present ? data.category.value : this.category,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      tags: data.tags.present ? data.tags.value : this.tags,
      notes: data.notes.present ? data.notes.value : this.notes,
      isConfidential: data.isConfidential.present
          ? data.isConfidential.value
          : this.isConfidential,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArchiveData(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('hijriDate: $hijriDate, ')
          ..write('documentDate: $documentDate, ')
          ..write('directedEntity: $directedEntity, ')
          ..write('category: $category, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('tags: $tags, ')
          ..write('notes: $notes, ')
          ..write('isConfidential: $isConfidential')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    referenceNumber,
    hijriDate,
    documentDate,
    directedEntity,
    category,
    localFilePath,
    tags,
    notes,
    isConfidential,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArchiveData &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.title == this.title &&
          other.referenceNumber == this.referenceNumber &&
          other.hijriDate == this.hijriDate &&
          other.documentDate == this.documentDate &&
          other.directedEntity == this.directedEntity &&
          other.category == this.category &&
          other.localFilePath == this.localFilePath &&
          other.tags == this.tags &&
          other.notes == this.notes &&
          other.isConfidential == this.isConfidential);
}

class ArchiveCompanion extends UpdateCompanion<ArchiveData> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> title;
  final Value<String?> referenceNumber;
  final Value<String?> hijriDate;
  final Value<String?> documentDate;
  final Value<String?> directedEntity;
  final Value<String?> category;
  final Value<String?> localFilePath;
  final Value<String?> tags;
  final Value<String?> notes;
  final Value<bool> isConfidential;
  const ArchiveCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.title = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.hijriDate = const Value.absent(),
    this.documentDate = const Value.absent(),
    this.directedEntity = const Value.absent(),
    this.category = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.tags = const Value.absent(),
    this.notes = const Value.absent(),
    this.isConfidential = const Value.absent(),
  });
  ArchiveCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String title,
    this.referenceNumber = const Value.absent(),
    this.hijriDate = const Value.absent(),
    this.documentDate = const Value.absent(),
    this.directedEntity = const Value.absent(),
    this.category = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.tags = const Value.absent(),
    this.notes = const Value.absent(),
    this.isConfidential = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title);
  static Insertable<ArchiveData> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<String>? title,
    Expression<String>? referenceNumber,
    Expression<String>? hijriDate,
    Expression<String>? documentDate,
    Expression<String>? directedEntity,
    Expression<String>? category,
    Expression<String>? localFilePath,
    Expression<String>? tags,
    Expression<String>? notes,
    Expression<bool>? isConfidential,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (title != null) 'title': title,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (hijriDate != null) 'hijri_date': hijriDate,
      if (documentDate != null) 'document_date': documentDate,
      if (directedEntity != null) 'directed_entity': directedEntity,
      if (category != null) 'category': category,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (tags != null) 'tags': tags,
      if (notes != null) 'notes': notes,
      if (isConfidential != null) 'is_confidential': isConfidential,
    });
  }

  ArchiveCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<String>? title,
    Value<String?>? referenceNumber,
    Value<String?>? hijriDate,
    Value<String?>? documentDate,
    Value<String?>? directedEntity,
    Value<String?>? category,
    Value<String?>? localFilePath,
    Value<String?>? tags,
    Value<String?>? notes,
    Value<bool>? isConfidential,
  }) {
    return ArchiveCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      hijriDate: hijriDate ?? this.hijriDate,
      documentDate: documentDate ?? this.documentDate,
      directedEntity: directedEntity ?? this.directedEntity,
      category: category ?? this.category,
      localFilePath: localFilePath ?? this.localFilePath,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isConfidential: isConfidential ?? this.isConfidential,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (hijriDate.present) {
      map['hijri_date'] = Variable<String>(hijriDate.value);
    }
    if (documentDate.present) {
      map['document_date'] = Variable<String>(documentDate.value);
    }
    if (directedEntity.present) {
      map['directed_entity'] = Variable<String>(directedEntity.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isConfidential.present) {
      map['is_confidential'] = Variable<bool>(isConfidential.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArchiveCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('hijriDate: $hijriDate, ')
          ..write('documentDate: $documentDate, ')
          ..write('directedEntity: $directedEntity, ')
          ..write('category: $category, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('tags: $tags, ')
          ..write('notes: $notes, ')
          ..write('isConfidential: $isConfidential')
          ..write(')'))
        .toString();
  }
}

class $SecurityLogsTable extends SecurityLogs
    with TableInfo<$SecurityLogsTable, SecurityLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SecurityLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<int> action = GeneratedColumn<int>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceInfoMeta = const VerificationMeta(
    'deviceInfo',
  );
  @override
  late final GeneratedColumn<String> deviceInfo = GeneratedColumn<String>(
    'device_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ipAddressMeta = const VerificationMeta(
    'ipAddress',
  );
  @override
  late final GeneratedColumn<String> ipAddress = GeneratedColumn<String>(
    'ip_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    action,
    details,
    deviceInfo,
    ipAddress,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'security_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SecurityLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('device_info')) {
      context.handle(
        _deviceInfoMeta,
        deviceInfo.isAcceptableOrUnknown(data['device_info']!, _deviceInfoMeta),
      );
    }
    if (data.containsKey('ip_address')) {
      context.handle(
        _ipAddressMeta,
        ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SecurityLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SecurityLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}action'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      deviceInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_info'],
      ),
      ipAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ip_address'],
      ),
    );
  }

  @override
  $SecurityLogsTable createAlias(String alias) {
    return $SecurityLogsTable(attachedDatabase, alias);
  }
}

class SecurityLog extends DataClass implements Insertable<SecurityLog> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;

  /// Action type (login=0, failedLogin=1, exportData=7, etc.)
  final int action;

  /// Action details (human-readable description)
  final String? details;

  /// Device information (model, OS version)
  final String? deviceInfo;

  /// IP address (for future sync scenarios)
  final String? ipAddress;
  const SecurityLog({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.action,
    this.details,
    this.deviceInfo,
    this.ipAddress,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['action'] = Variable<int>(action);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    if (!nullToAbsent || deviceInfo != null) {
      map['device_info'] = Variable<String>(deviceInfo);
    }
    if (!nullToAbsent || ipAddress != null) {
      map['ip_address'] = Variable<String>(ipAddress);
    }
    return map;
  }

  SecurityLogsCompanion toCompanion(bool nullToAbsent) {
    return SecurityLogsCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      action: Value(action),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      deviceInfo: deviceInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceInfo),
      ipAddress: ipAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(ipAddress),
    );
  }

  factory SecurityLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SecurityLog(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      action: serializer.fromJson<int>(json['action']),
      details: serializer.fromJson<String?>(json['details']),
      deviceInfo: serializer.fromJson<String?>(json['deviceInfo']),
      ipAddress: serializer.fromJson<String?>(json['ipAddress']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'action': serializer.toJson<int>(action),
      'details': serializer.toJson<String?>(details),
      'deviceInfo': serializer.toJson<String?>(deviceInfo),
      'ipAddress': serializer.toJson<String?>(ipAddress),
    };
  }

  SecurityLog copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    int? action,
    Value<String?> details = const Value.absent(),
    Value<String?> deviceInfo = const Value.absent(),
    Value<String?> ipAddress = const Value.absent(),
  }) => SecurityLog(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    action: action ?? this.action,
    details: details.present ? details.value : this.details,
    deviceInfo: deviceInfo.present ? deviceInfo.value : this.deviceInfo,
    ipAddress: ipAddress.present ? ipAddress.value : this.ipAddress,
  );
  SecurityLog copyWithCompanion(SecurityLogsCompanion data) {
    return SecurityLog(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      action: data.action.present ? data.action.value : this.action,
      details: data.details.present ? data.details.value : this.details,
      deviceInfo: data.deviceInfo.present
          ? data.deviceInfo.value
          : this.deviceInfo,
      ipAddress: data.ipAddress.present ? data.ipAddress.value : this.ipAddress,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SecurityLog(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('action: $action, ')
          ..write('details: $details, ')
          ..write('deviceInfo: $deviceInfo, ')
          ..write('ipAddress: $ipAddress')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    action,
    details,
    deviceInfo,
    ipAddress,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SecurityLog &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.action == this.action &&
          other.details == this.details &&
          other.deviceInfo == this.deviceInfo &&
          other.ipAddress == this.ipAddress);
}

class SecurityLogsCompanion extends UpdateCompanion<SecurityLog> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<int> action;
  final Value<String?> details;
  final Value<String?> deviceInfo;
  final Value<String?> ipAddress;
  const SecurityLogsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.action = const Value.absent(),
    this.details = const Value.absent(),
    this.deviceInfo = const Value.absent(),
    this.ipAddress = const Value.absent(),
  });
  SecurityLogsCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required int action,
    this.details = const Value.absent(),
    this.deviceInfo = const Value.absent(),
    this.ipAddress = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       action = Value(action);
  static Insertable<SecurityLog> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<int>? action,
    Expression<String>? details,
    Expression<String>? deviceInfo,
    Expression<String>? ipAddress,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (action != null) 'action': action,
      if (details != null) 'details': details,
      if (deviceInfo != null) 'device_info': deviceInfo,
      if (ipAddress != null) 'ip_address': ipAddress,
    });
  }

  SecurityLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<int>? action,
    Value<String?>? details,
    Value<String?>? deviceInfo,
    Value<String?>? ipAddress,
  }) {
    return SecurityLogsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      action: action ?? this.action,
      details: details ?? this.details,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (action.present) {
      map['action'] = Variable<int>(action.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (deviceInfo.present) {
      map['device_info'] = Variable<String>(deviceInfo.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SecurityLogsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('action: $action, ')
          ..write('details: $details, ')
          ..write('deviceInfo: $deviceInfo, ')
          ..write('ipAddress: $ipAddress')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    key,
    value,
    category,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {key},
  ];
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;

  /// Setting key (unique identifier)
  final String key;

  /// Setting value (stored as string, parsed by consumer)
  final String value;

  /// Setting category for grouping
  final String? category;
  const AppSetting({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.key,
    required this.value,
    this.category,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      key: Value(key),
      value: Value(value),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      category: serializer.fromJson<String?>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'category': serializer.toJson<String?>(category),
    };
  }

  AppSetting copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    String? key,
    String? value,
    Value<String?> category = const Value.absent(),
  }) => AppSetting(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    key: key ?? this.key,
    value: value ?? this.value,
    category: category.present ? category.value : this.category,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    key,
    value,
    category,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.key == this.key &&
          other.value == this.value &&
          other.category == this.category);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> key;
  final Value<String> value;
  final Value<String?> category;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.category = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String key,
    required String value,
    this.category = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? category,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (category != null) 'category': category,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<String>? key,
    Value<String>? value,
    Value<String?>? category,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      key: key ?? this.key,
      value: value ?? this.value,
      category: category ?? this.category,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }
}

class $CallsTable extends Calls with TableInfo<$CallsTable, CallItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CallsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _callerNameMeta = const VerificationMeta(
    'callerName',
  );
  @override
  late final GeneratedColumn<String> callerName = GeneratedColumn<String>(
    'caller_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _callTypeMeta = const VerificationMeta(
    'callType',
  );
  @override
  late final GeneratedColumn<int> callType = GeneratedColumn<int>(
    'call_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isImportantMeta = const VerificationMeta(
    'isImportant',
  );
  @override
  late final GeneratedColumn<bool> isImportant = GeneratedColumn<bool>(
    'is_important',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_important" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    callerName,
    phoneNumber,
    callType,
    date,
    time,
    summary,
    isImportant,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calls';
  @override
  VerificationContext validateIntegrity(
    Insertable<CallItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('caller_name')) {
      context.handle(
        _callerNameMeta,
        callerName.isAcceptableOrUnknown(data['caller_name']!, _callerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_callerNameMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('call_type')) {
      context.handle(
        _callTypeMeta,
        callType.isAcceptableOrUnknown(data['call_type']!, _callTypeMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('is_important')) {
      context.handle(
        _isImportantMeta,
        isImportant.isAcceptableOrUnknown(
          data['is_important']!,
          _isImportantMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CallItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CallItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      callerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caller_name'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      callType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}call_type'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      isImportant: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_important'],
      )!,
    );
  }

  @override
  $CallsTable createAlias(String alias) {
    return $CallsTable(attachedDatabase, alias);
  }
}

class CallItem extends DataClass implements Insertable<CallItem> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;
  final String callerName;
  final String? phoneNumber;

  /// 0: Incoming, 1: Outgoing, 2: Missed
  final int callType;
  final String date;
  final String time;
  final String? summary;
  final bool isImportant;
  const CallItem({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.callerName,
    this.phoneNumber,
    required this.callType,
    required this.date,
    required this.time,
    this.summary,
    required this.isImportant,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['caller_name'] = Variable<String>(callerName);
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    map['call_type'] = Variable<int>(callType);
    map['date'] = Variable<String>(date);
    map['time'] = Variable<String>(time);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    map['is_important'] = Variable<bool>(isImportant);
    return map;
  }

  CallsCompanion toCompanion(bool nullToAbsent) {
    return CallsCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      callerName: Value(callerName),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      callType: Value(callType),
      date: Value(date),
      time: Value(time),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      isImportant: Value(isImportant),
    );
  }

  factory CallItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CallItem(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      callerName: serializer.fromJson<String>(json['callerName']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      callType: serializer.fromJson<int>(json['callType']),
      date: serializer.fromJson<String>(json['date']),
      time: serializer.fromJson<String>(json['time']),
      summary: serializer.fromJson<String?>(json['summary']),
      isImportant: serializer.fromJson<bool>(json['isImportant']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'callerName': serializer.toJson<String>(callerName),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'callType': serializer.toJson<int>(callType),
      'date': serializer.toJson<String>(date),
      'time': serializer.toJson<String>(time),
      'summary': serializer.toJson<String?>(summary),
      'isImportant': serializer.toJson<bool>(isImportant),
    };
  }

  CallItem copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    String? callerName,
    Value<String?> phoneNumber = const Value.absent(),
    int? callType,
    String? date,
    String? time,
    Value<String?> summary = const Value.absent(),
    bool? isImportant,
  }) => CallItem(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    callerName: callerName ?? this.callerName,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    callType: callType ?? this.callType,
    date: date ?? this.date,
    time: time ?? this.time,
    summary: summary.present ? summary.value : this.summary,
    isImportant: isImportant ?? this.isImportant,
  );
  CallItem copyWithCompanion(CallsCompanion data) {
    return CallItem(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      callerName: data.callerName.present
          ? data.callerName.value
          : this.callerName,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      callType: data.callType.present ? data.callType.value : this.callType,
      date: data.date.present ? data.date.value : this.date,
      time: data.time.present ? data.time.value : this.time,
      summary: data.summary.present ? data.summary.value : this.summary,
      isImportant: data.isImportant.present
          ? data.isImportant.value
          : this.isImportant,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CallItem(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('callerName: $callerName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('callType: $callType, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('summary: $summary, ')
          ..write('isImportant: $isImportant')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    callerName,
    phoneNumber,
    callType,
    date,
    time,
    summary,
    isImportant,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallItem &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.callerName == this.callerName &&
          other.phoneNumber == this.phoneNumber &&
          other.callType == this.callType &&
          other.date == this.date &&
          other.time == this.time &&
          other.summary == this.summary &&
          other.isImportant == this.isImportant);
}

class CallsCompanion extends UpdateCompanion<CallItem> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> callerName;
  final Value<String?> phoneNumber;
  final Value<int> callType;
  final Value<String> date;
  final Value<String> time;
  final Value<String?> summary;
  final Value<bool> isImportant;
  const CallsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.callerName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.callType = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.summary = const Value.absent(),
    this.isImportant = const Value.absent(),
  });
  CallsCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String callerName,
    this.phoneNumber = const Value.absent(),
    this.callType = const Value.absent(),
    required String date,
    required String time,
    this.summary = const Value.absent(),
    this.isImportant = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       callerName = Value(callerName),
       date = Value(date),
       time = Value(time);
  static Insertable<CallItem> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<String>? callerName,
    Expression<String>? phoneNumber,
    Expression<int>? callType,
    Expression<String>? date,
    Expression<String>? time,
    Expression<String>? summary,
    Expression<bool>? isImportant,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (callerName != null) 'caller_name': callerName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (callType != null) 'call_type': callType,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (summary != null) 'summary': summary,
      if (isImportant != null) 'is_important': isImportant,
    });
  }

  CallsCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<String>? callerName,
    Value<String?>? phoneNumber,
    Value<int>? callType,
    Value<String>? date,
    Value<String>? time,
    Value<String?>? summary,
    Value<bool>? isImportant,
  }) {
    return CallsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      callerName: callerName ?? this.callerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      callType: callType ?? this.callType,
      date: date ?? this.date,
      time: time ?? this.time,
      summary: summary ?? this.summary,
      isImportant: isImportant ?? this.isImportant,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (callerName.present) {
      map['caller_name'] = Variable<String>(callerName.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (callType.present) {
      map['call_type'] = Variable<int>(callType.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (isImportant.present) {
      map['is_important'] = Variable<bool>(isImportant.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CallsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('callerName: $callerName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('callType: $callType, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('summary: $summary, ')
          ..write('isImportant: $isImportant')
          ..write(')'))
        .toString();
  }
}

class $VisitorsTable extends Visitors
    with TableInfo<$VisitorsTable, VisitorItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visitorNameMeta = const VerificationMeta(
    'visitorName',
  );
  @override
  late final GeneratedColumn<String> visitorName = GeneratedColumn<String>(
    'visitor_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appointmentIdMeta = const VerificationMeta(
    'appointmentId',
  );
  @override
  late final GeneratedColumn<String> appointmentId = GeneratedColumn<String>(
    'appointment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryTimeMeta = const VerificationMeta(
    'entryTime',
  );
  @override
  late final GeneratedColumn<String> entryTime = GeneratedColumn<String>(
    'entry_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exitTimeMeta = const VerificationMeta(
    'exitTime',
  );
  @override
  late final GeneratedColumn<String> exitTime = GeneratedColumn<String>(
    'exit_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    visitorName,
    company,
    purpose,
    appointmentId,
    entryTime,
    exitTime,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visitors';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitorItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('visitor_name')) {
      context.handle(
        _visitorNameMeta,
        visitorName.isAcceptableOrUnknown(
          data['visitor_name']!,
          _visitorNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_visitorNameMeta);
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    if (data.containsKey('appointment_id')) {
      context.handle(
        _appointmentIdMeta,
        appointmentId.isAcceptableOrUnknown(
          data['appointment_id']!,
          _appointmentIdMeta,
        ),
      );
    }
    if (data.containsKey('entry_time')) {
      context.handle(
        _entryTimeMeta,
        entryTime.isAcceptableOrUnknown(data['entry_time']!, _entryTimeMeta),
      );
    }
    if (data.containsKey('exit_time')) {
      context.handle(
        _exitTimeMeta,
        exitTime.isAcceptableOrUnknown(data['exit_time']!, _exitTimeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VisitorItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitorItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      visitorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visitor_name'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      ),
      appointmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appointment_id'],
      ),
      entryTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_time'],
      ),
      exitTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exit_time'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $VisitorsTable createAlias(String alias) {
    return $VisitorsTable(attachedDatabase, alias);
  }
}

class VisitorItem extends DataClass implements Insertable<VisitorItem> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;
  final String visitorName;
  final String? company;
  final String? purpose;
  final String? appointmentId;
  final String? entryTime;
  final String? exitTime;

  /// 0: Waiting, 1: Inside, 2: Left
  final int status;
  const VisitorItem({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.visitorName,
    this.company,
    this.purpose,
    this.appointmentId,
    this.entryTime,
    this.exitTime,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['visitor_name'] = Variable<String>(visitorName);
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    if (!nullToAbsent || appointmentId != null) {
      map['appointment_id'] = Variable<String>(appointmentId);
    }
    if (!nullToAbsent || entryTime != null) {
      map['entry_time'] = Variable<String>(entryTime);
    }
    if (!nullToAbsent || exitTime != null) {
      map['exit_time'] = Variable<String>(exitTime);
    }
    map['status'] = Variable<int>(status);
    return map;
  }

  VisitorsCompanion toCompanion(bool nullToAbsent) {
    return VisitorsCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      visitorName: Value(visitorName),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      appointmentId: appointmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(appointmentId),
      entryTime: entryTime == null && nullToAbsent
          ? const Value.absent()
          : Value(entryTime),
      exitTime: exitTime == null && nullToAbsent
          ? const Value.absent()
          : Value(exitTime),
      status: Value(status),
    );
  }

  factory VisitorItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitorItem(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      visitorName: serializer.fromJson<String>(json['visitorName']),
      company: serializer.fromJson<String?>(json['company']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      appointmentId: serializer.fromJson<String?>(json['appointmentId']),
      entryTime: serializer.fromJson<String?>(json['entryTime']),
      exitTime: serializer.fromJson<String?>(json['exitTime']),
      status: serializer.fromJson<int>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'visitorName': serializer.toJson<String>(visitorName),
      'company': serializer.toJson<String?>(company),
      'purpose': serializer.toJson<String?>(purpose),
      'appointmentId': serializer.toJson<String?>(appointmentId),
      'entryTime': serializer.toJson<String?>(entryTime),
      'exitTime': serializer.toJson<String?>(exitTime),
      'status': serializer.toJson<int>(status),
    };
  }

  VisitorItem copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    String? visitorName,
    Value<String?> company = const Value.absent(),
    Value<String?> purpose = const Value.absent(),
    Value<String?> appointmentId = const Value.absent(),
    Value<String?> entryTime = const Value.absent(),
    Value<String?> exitTime = const Value.absent(),
    int? status,
  }) => VisitorItem(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    visitorName: visitorName ?? this.visitorName,
    company: company.present ? company.value : this.company,
    purpose: purpose.present ? purpose.value : this.purpose,
    appointmentId: appointmentId.present
        ? appointmentId.value
        : this.appointmentId,
    entryTime: entryTime.present ? entryTime.value : this.entryTime,
    exitTime: exitTime.present ? exitTime.value : this.exitTime,
    status: status ?? this.status,
  );
  VisitorItem copyWithCompanion(VisitorsCompanion data) {
    return VisitorItem(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      visitorName: data.visitorName.present
          ? data.visitorName.value
          : this.visitorName,
      company: data.company.present ? data.company.value : this.company,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      appointmentId: data.appointmentId.present
          ? data.appointmentId.value
          : this.appointmentId,
      entryTime: data.entryTime.present ? data.entryTime.value : this.entryTime,
      exitTime: data.exitTime.present ? data.exitTime.value : this.exitTime,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitorItem(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('visitorName: $visitorName, ')
          ..write('company: $company, ')
          ..write('purpose: $purpose, ')
          ..write('appointmentId: $appointmentId, ')
          ..write('entryTime: $entryTime, ')
          ..write('exitTime: $exitTime, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    visitorName,
    company,
    purpose,
    appointmentId,
    entryTime,
    exitTime,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitorItem &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.visitorName == this.visitorName &&
          other.company == this.company &&
          other.purpose == this.purpose &&
          other.appointmentId == this.appointmentId &&
          other.entryTime == this.entryTime &&
          other.exitTime == this.exitTime &&
          other.status == this.status);
}

class VisitorsCompanion extends UpdateCompanion<VisitorItem> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> visitorName;
  final Value<String?> company;
  final Value<String?> purpose;
  final Value<String?> appointmentId;
  final Value<String?> entryTime;
  final Value<String?> exitTime;
  final Value<int> status;
  const VisitorsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.visitorName = const Value.absent(),
    this.company = const Value.absent(),
    this.purpose = const Value.absent(),
    this.appointmentId = const Value.absent(),
    this.entryTime = const Value.absent(),
    this.exitTime = const Value.absent(),
    this.status = const Value.absent(),
  });
  VisitorsCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String visitorName,
    this.company = const Value.absent(),
    this.purpose = const Value.absent(),
    this.appointmentId = const Value.absent(),
    this.entryTime = const Value.absent(),
    this.exitTime = const Value.absent(),
    this.status = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       visitorName = Value(visitorName);
  static Insertable<VisitorItem> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<String>? visitorName,
    Expression<String>? company,
    Expression<String>? purpose,
    Expression<String>? appointmentId,
    Expression<String>? entryTime,
    Expression<String>? exitTime,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (visitorName != null) 'visitor_name': visitorName,
      if (company != null) 'company': company,
      if (purpose != null) 'purpose': purpose,
      if (appointmentId != null) 'appointment_id': appointmentId,
      if (entryTime != null) 'entry_time': entryTime,
      if (exitTime != null) 'exit_time': exitTime,
      if (status != null) 'status': status,
    });
  }

  VisitorsCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<String>? visitorName,
    Value<String?>? company,
    Value<String?>? purpose,
    Value<String?>? appointmentId,
    Value<String?>? entryTime,
    Value<String?>? exitTime,
    Value<int>? status,
  }) {
    return VisitorsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      visitorName: visitorName ?? this.visitorName,
      company: company ?? this.company,
      purpose: purpose ?? this.purpose,
      appointmentId: appointmentId ?? this.appointmentId,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (visitorName.present) {
      map['visitor_name'] = Variable<String>(visitorName.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (appointmentId.present) {
      map['appointment_id'] = Variable<String>(appointmentId.value);
    }
    if (entryTime.present) {
      map['entry_time'] = Variable<String>(entryTime.value);
    }
    if (exitTime.present) {
      map['exit_time'] = Variable<String>(exitTime.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitorsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('visitorName: $visitorName, ')
          ..write('company: $company, ')
          ..write('purpose: $purpose, ')
          ..write('appointmentId: $appointmentId, ')
          ..write('entryTime: $entryTime, ')
          ..write('exitTime: $exitTime, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorCodeMeta = const VerificationMeta(
    'colorCode',
  );
  @override
  late final GeneratedColumn<String> colorCode = GeneratedColumn<String>(
    'color_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    content,
    colorCode,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('color_code')) {
      context.handle(
        _colorCodeMeta,
        colorCode.isAcceptableOrUnknown(data['color_code']!, _colorCodeMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      colorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_code'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteItem extends DataClass implements Insertable<NoteItem> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;
  final String? title;
  final String content;
  final String? colorCode;
  final String? tags;
  const NoteItem({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    this.title,
    required this.content,
    this.colorCode,
    this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || colorCode != null) {
      map['color_code'] = Variable<String>(colorCode);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      content: Value(content),
      colorCode: colorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(colorCode),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
    );
  }

  factory NoteItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteItem(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      title: serializer.fromJson<String?>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      colorCode: serializer.fromJson<String?>(json['colorCode']),
      tags: serializer.fromJson<String?>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'title': serializer.toJson<String?>(title),
      'content': serializer.toJson<String>(content),
      'colorCode': serializer.toJson<String?>(colorCode),
      'tags': serializer.toJson<String?>(tags),
    };
  }

  NoteItem copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    Value<String?> title = const Value.absent(),
    String? content,
    Value<String?> colorCode = const Value.absent(),
    Value<String?> tags = const Value.absent(),
  }) => NoteItem(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    title: title.present ? title.value : this.title,
    content: content ?? this.content,
    colorCode: colorCode.present ? colorCode.value : this.colorCode,
    tags: tags.present ? tags.value : this.tags,
  );
  NoteItem copyWithCompanion(NotesCompanion data) {
    return NoteItem(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      colorCode: data.colorCode.present ? data.colorCode.value : this.colorCode,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteItem(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('colorCode: $colorCode, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    title,
    content,
    colorCode,
    tags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteItem &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.title == this.title &&
          other.content == this.content &&
          other.colorCode == this.colorCode &&
          other.tags == this.tags);
}

class NotesCompanion extends UpdateCompanion<NoteItem> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String?> title;
  final Value<String> content;
  final Value<String?> colorCode;
  final Value<String?> tags;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.colorCode = const Value.absent(),
    this.tags = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.title = const Value.absent(),
    required String content,
    this.colorCode = const Value.absent(),
    this.tags = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       content = Value(content);
  static Insertable<NoteItem> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? colorCode,
    Expression<String>? tags,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (colorCode != null) 'color_code': colorCode,
      if (tags != null) 'tags': tags,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<String?>? title,
    Value<String>? content,
    Value<String?>? colorCode,
    Value<String?>? tags,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      content: content ?? this.content,
      colorCode: colorCode ?? this.colorCode,
      tags: tags ?? this.tags,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (colorCode.present) {
      map['color_code'] = Variable<String>(colorCode.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('colorCode: $colorCode, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }
}

class $MovementsTable extends Movements
    with TableInfo<$MovementsTable, Movement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _destinationMeta = const VerificationMeta(
    'destination',
  );
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    destination,
    purpose,
    date,
    time,
    type,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Movement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('destination')) {
      context.handle(
        _destinationMeta,
        destination.isAcceptableOrUnknown(
          data['destination']!,
          _destinationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Movement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Movement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      destination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $MovementsTable createAlias(String alias) {
    return $MovementsTable(attachedDatabase, alias);
  }
}

class Movement extends DataClass implements Insertable<Movement> {
  /// Auto-increment primary key
  final int id;

  /// UUID for future cloud sync
  final String syncId;

  /// Unix timestamp (milliseconds) of creation
  final int createdAt;

  /// Unix timestamp (milliseconds) of last update
  final int updatedAt;

  /// Soft delete flag — records are never hard-deleted
  final bool isDeleted;

  /// Creator identifier (for multi-user support in the future)
  final String? createdBy;

  /// Destination or location
  final String destination;

  /// Purpose of the movement
  final String? purpose;

  /// Date string (YYYY-MM-DD)
  final String date;

  /// Time string (HH:MM)
  final String time;

  /// Movement type: 0 = خروج, 1 = عودة, 2 = مهمة خارجية
  final int type;

  /// Additional notes
  final String? notes;
  const Movement({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.destination,
    this.purpose,
    required this.date,
    required this.time,
    required this.type,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['destination'] = Variable<String>(destination);
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    map['date'] = Variable<String>(date);
    map['time'] = Variable<String>(time);
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  MovementsCompanion toCompanion(bool nullToAbsent) {
    return MovementsCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      destination: Value(destination),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      date: Value(date),
      time: Value(time),
      type: Value(type),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Movement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Movement(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      destination: serializer.fromJson<String>(json['destination']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      date: serializer.fromJson<String>(json['date']),
      time: serializer.fromJson<String>(json['time']),
      type: serializer.fromJson<int>(json['type']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'destination': serializer.toJson<String>(destination),
      'purpose': serializer.toJson<String?>(purpose),
      'date': serializer.toJson<String>(date),
      'time': serializer.toJson<String>(time),
      'type': serializer.toJson<int>(type),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Movement copyWith({
    int? id,
    String? syncId,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    Value<String?> createdBy = const Value.absent(),
    String? destination,
    Value<String?> purpose = const Value.absent(),
    String? date,
    String? time,
    int? type,
    Value<String?> notes = const Value.absent(),
  }) => Movement(
    id: id ?? this.id,
    syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    destination: destination ?? this.destination,
    purpose: purpose.present ? purpose.value : this.purpose,
    date: date ?? this.date,
    time: time ?? this.time,
    type: type ?? this.type,
    notes: notes.present ? notes.value : this.notes,
  );
  Movement copyWithCompanion(MovementsCompanion data) {
    return Movement(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      destination: data.destination.present
          ? data.destination.value
          : this.destination,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      date: data.date.present ? data.date.value : this.date,
      time: data.time.present ? data.time.value : this.time,
      type: data.type.present ? data.type.value : this.type,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Movement(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('destination: $destination, ')
          ..write('purpose: $purpose, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('type: $type, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    updatedAt,
    isDeleted,
    createdBy,
    destination,
    purpose,
    date,
    time,
    type,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Movement &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.createdBy == this.createdBy &&
          other.destination == this.destination &&
          other.purpose == this.purpose &&
          other.date == this.date &&
          other.time == this.time &&
          other.type == this.type &&
          other.notes == this.notes);
}

class MovementsCompanion extends UpdateCompanion<Movement> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> destination;
  final Value<String?> purpose;
  final Value<String> date;
  final Value<String> time;
  final Value<int> type;
  final Value<String?> notes;
  const MovementsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.destination = const Value.absent(),
    this.purpose = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.type = const Value.absent(),
    this.notes = const Value.absent(),
  });
  MovementsCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String destination,
    this.purpose = const Value.absent(),
    required String date,
    required String time,
    this.type = const Value.absent(),
    this.notes = const Value.absent(),
  }) : syncId = Value(syncId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       destination = Value(destination),
       date = Value(date),
       time = Value(time);
  static Insertable<Movement> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<String>? createdBy,
    Expression<String>? destination,
    Expression<String>? purpose,
    Expression<String>? date,
    Expression<String>? time,
    Expression<int>? type,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdBy != null) 'created_by': createdBy,
      if (destination != null) 'destination': destination,
      if (purpose != null) 'purpose': purpose,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (type != null) 'type': type,
      if (notes != null) 'notes': notes,
    });
  }

  MovementsCompanion copyWith({
    Value<int>? id,
    Value<String>? syncId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<String?>? createdBy,
    Value<String>? destination,
    Value<String?>? purpose,
    Value<String>? date,
    Value<String>? time,
    Value<int>? type,
    Value<String?>? notes,
  }) {
    return MovementsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      destination: destination ?? this.destination,
      purpose: purpose ?? this.purpose,
      date: date ?? this.date,
      time: time ?? this.time,
      type: type ?? this.type,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovementsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdBy: $createdBy, ')
          ..write('destination: $destination, ')
          ..write('purpose: $purpose, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('type: $type, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $MeetingsTable meetings = $MeetingsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $FollowUpsTable followUps = $FollowUpsTable(this);
  late final $DirectivesTable directives = $DirectivesTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  late final $ArchiveTable archive = $ArchiveTable(this);
  late final $SecurityLogsTable securityLogs = $SecurityLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $CallsTable calls = $CallsTable(this);
  late final $VisitorsTable visitors = $VisitorsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $MovementsTable movements = $MovementsTable(this);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final MeetingsDao meetingsDao = MeetingsDao(this as AppDatabase);
  late final TasksDao tasksDao = TasksDao(this as AppDatabase);
  late final FollowUpsDao followUpsDao = FollowUpsDao(this as AppDatabase);
  late final DirectivesDao directivesDao = DirectivesDao(this as AppDatabase);
  late final ContactsDao contactsDao = ContactsDao(this as AppDatabase);
  late final AppointmentsDao appointmentsDao = AppointmentsDao(
    this as AppDatabase,
  );
  late final ArchiveDao archiveDao = ArchiveDao(this as AppDatabase);
  late final SecurityLogsDao securityLogsDao = SecurityLogsDao(
    this as AppDatabase,
  );
  late final AppSettingsDao appSettingsDao = AppSettingsDao(
    this as AppDatabase,
  );
  late final CallsDao callsDao = CallsDao(this as AppDatabase);
  late final VisitorsDao visitorsDao = VisitorsDao(this as AppDatabase);
  late final NotesDao notesDao = NotesDao(this as AppDatabase);
  late final MovementsDao movementsDao = MovementsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    meetings,
    tasks,
    followUps,
    directives,
    contacts,
    appointments,
    archive,
    securityLogs,
    appSettings,
    calls,
    visitors,
    notes,
    movements,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      required String displayName,
      Value<String?> pinHash,
      Value<int> authMethod,
      Value<bool> isBiometricEnabled,
      Value<int> role,
      Value<String?> avatarPath,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String> displayName,
      Value<String?> pinHash,
      Value<int> authMethod,
      Value<bool> isBiometricEnabled,
      Value<int> role,
      Value<String?> avatarPath,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get authMethod => $composableBuilder(
    column: $table.authMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBiometricEnabled => $composableBuilder(
    column: $table.isBiometricEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get authMethod => $composableBuilder(
    column: $table.authMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBiometricEnabled => $composableBuilder(
    column: $table.isBiometricEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<int> get authMethod => $composableBuilder(
    column: $table.authMethod,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBiometricEnabled => $composableBuilder(
    column: $table.isBiometricEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<int> authMethod = const Value.absent(),
                Value<bool> isBiometricEnabled = const Value.absent(),
                Value<int> role = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                displayName: displayName,
                pinHash: pinHash,
                authMethod: authMethod,
                isBiometricEnabled: isBiometricEnabled,
                role: role,
                avatarPath: avatarPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String displayName,
                Value<String?> pinHash = const Value.absent(),
                Value<int> authMethod = const Value.absent(),
                Value<bool> isBiometricEnabled = const Value.absent(),
                Value<int> role = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                displayName: displayName,
                pinHash: pinHash,
                authMethod: authMethod,
                isBiometricEnabled: isBiometricEnabled,
                role: role,
                avatarPath: avatarPath,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$MeetingsTableCreateCompanionBuilder =
    MeetingsCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      required String title,
      Value<int> meetingType,
      required String date,
      required String time,
      Value<String?> endTime,
      Value<String?> location,
      Value<String?> objective,
      Value<String?> agenda,
      Value<String?> decisions,
      Value<String?> outcomes,
      Value<String?> attendees,
      Value<String?> attachments,
      Value<int> status,
      Value<int> priority,
      Value<String?> notes,
      Value<String?> minutes,
      Value<String?> recurrenceRule,
      Value<String?> customMeetingType,
    });
typedef $$MeetingsTableUpdateCompanionBuilder =
    MeetingsCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String> title,
      Value<int> meetingType,
      Value<String> date,
      Value<String> time,
      Value<String?> endTime,
      Value<String?> location,
      Value<String?> objective,
      Value<String?> agenda,
      Value<String?> decisions,
      Value<String?> outcomes,
      Value<String?> attendees,
      Value<String?> attachments,
      Value<int> status,
      Value<int> priority,
      Value<String?> notes,
      Value<String?> minutes,
      Value<String?> recurrenceRule,
      Value<String?> customMeetingType,
    });

class $$MeetingsTableFilterComposer
    extends Composer<_$AppDatabase, $MeetingsTable> {
  $$MeetingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get meetingType => $composableBuilder(
    column: $table.meetingType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objective => $composableBuilder(
    column: $table.objective,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agenda => $composableBuilder(
    column: $table.agenda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisions => $composableBuilder(
    column: $table.decisions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcomes => $composableBuilder(
    column: $table.outcomes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attendees => $composableBuilder(
    column: $table.attendees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customMeetingType => $composableBuilder(
    column: $table.customMeetingType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MeetingsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeetingsTable> {
  $$MeetingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get meetingType => $composableBuilder(
    column: $table.meetingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objective => $composableBuilder(
    column: $table.objective,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agenda => $composableBuilder(
    column: $table.agenda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisions => $composableBuilder(
    column: $table.decisions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcomes => $composableBuilder(
    column: $table.outcomes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attendees => $composableBuilder(
    column: $table.attendees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customMeetingType => $composableBuilder(
    column: $table.customMeetingType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeetingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeetingsTable> {
  $$MeetingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get meetingType => $composableBuilder(
    column: $table.meetingType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get objective =>
      $composableBuilder(column: $table.objective, builder: (column) => column);

  GeneratedColumn<String> get agenda =>
      $composableBuilder(column: $table.agenda, builder: (column) => column);

  GeneratedColumn<String> get decisions =>
      $composableBuilder(column: $table.decisions, builder: (column) => column);

  GeneratedColumn<String> get outcomes =>
      $composableBuilder(column: $table.outcomes, builder: (column) => column);

  GeneratedColumn<String> get attendees =>
      $composableBuilder(column: $table.attendees, builder: (column) => column);

  GeneratedColumn<String> get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customMeetingType => $composableBuilder(
    column: $table.customMeetingType,
    builder: (column) => column,
  );
}

class $$MeetingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeetingsTable,
          Meeting,
          $$MeetingsTableFilterComposer,
          $$MeetingsTableOrderingComposer,
          $$MeetingsTableAnnotationComposer,
          $$MeetingsTableCreateCompanionBuilder,
          $$MeetingsTableUpdateCompanionBuilder,
          (Meeting, BaseReferences<_$AppDatabase, $MeetingsTable, Meeting>),
          Meeting,
          PrefetchHooks Function()
        > {
  $$MeetingsTableTableManager(_$AppDatabase db, $MeetingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeetingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeetingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeetingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> meetingType = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> time = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> objective = const Value.absent(),
                Value<String?> agenda = const Value.absent(),
                Value<String?> decisions = const Value.absent(),
                Value<String?> outcomes = const Value.absent(),
                Value<String?> attendees = const Value.absent(),
                Value<String?> attachments = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> minutes = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<String?> customMeetingType = const Value.absent(),
              }) => MeetingsCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                meetingType: meetingType,
                date: date,
                time: time,
                endTime: endTime,
                location: location,
                objective: objective,
                agenda: agenda,
                decisions: decisions,
                outcomes: outcomes,
                attendees: attendees,
                attachments: attachments,
                status: status,
                priority: priority,
                notes: notes,
                minutes: minutes,
                recurrenceRule: recurrenceRule,
                customMeetingType: customMeetingType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String title,
                Value<int> meetingType = const Value.absent(),
                required String date,
                required String time,
                Value<String?> endTime = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> objective = const Value.absent(),
                Value<String?> agenda = const Value.absent(),
                Value<String?> decisions = const Value.absent(),
                Value<String?> outcomes = const Value.absent(),
                Value<String?> attendees = const Value.absent(),
                Value<String?> attachments = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> minutes = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<String?> customMeetingType = const Value.absent(),
              }) => MeetingsCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                meetingType: meetingType,
                date: date,
                time: time,
                endTime: endTime,
                location: location,
                objective: objective,
                agenda: agenda,
                decisions: decisions,
                outcomes: outcomes,
                attendees: attendees,
                attachments: attachments,
                status: status,
                priority: priority,
                notes: notes,
                minutes: minutes,
                recurrenceRule: recurrenceRule,
                customMeetingType: customMeetingType,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MeetingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeetingsTable,
      Meeting,
      $$MeetingsTableFilterComposer,
      $$MeetingsTableOrderingComposer,
      $$MeetingsTableAnnotationComposer,
      $$MeetingsTableCreateCompanionBuilder,
      $$MeetingsTableUpdateCompanionBuilder,
      (Meeting, BaseReferences<_$AppDatabase, $MeetingsTable, Meeting>),
      Meeting,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      required String title,
      Value<String?> description,
      Value<String?> dueDate,
      Value<String?> assignedTo,
      Value<int> priority,
      Value<int> status,
      Value<int?> linkedMeetingId,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String> title,
      Value<String?> description,
      Value<String?> dueDate,
      Value<String?> assignedTo,
      Value<int> priority,
      Value<int> status,
      Value<int?> linkedMeetingId,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedMeetingId => $composableBuilder(
    column: $table.linkedMeetingId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedMeetingId => $composableBuilder(
    column: $table.linkedMeetingId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get linkedMeetingId => $composableBuilder(
    column: $table.linkedMeetingId,
    builder: (column) => column,
  );
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int?> linkedMeetingId = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                description: description,
                dueDate: dueDate,
                assignedTo: assignedTo,
                priority: priority,
                status: status,
                linkedMeetingId: linkedMeetingId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int?> linkedMeetingId = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                description: description,
                dueDate: dueDate,
                assignedTo: assignedTo,
                priority: priority,
                status: status,
                linkedMeetingId: linkedMeetingId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$FollowUpsTableCreateCompanionBuilder =
    FollowUpsCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      required String title,
      Value<String?> notes,
      Value<String?> targetDate,
      Value<int> entityType,
      Value<int?> entityId,
      Value<int> priority,
      Value<int> status,
      Value<String?> assignedTo,
    });
typedef $$FollowUpsTableUpdateCompanionBuilder =
    FollowUpsCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String> title,
      Value<String?> notes,
      Value<String?> targetDate,
      Value<int> entityType,
      Value<int?> entityId,
      Value<int> priority,
      Value<int> status,
      Value<String?> assignedTo,
    });

class $$FollowUpsTableFilterComposer
    extends Composer<_$AppDatabase, $FollowUpsTable> {
  $$FollowUpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FollowUpsTableOrderingComposer
    extends Composer<_$AppDatabase, $FollowUpsTable> {
  $$FollowUpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FollowUpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FollowUpsTable> {
  $$FollowUpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => column,
  );
}

class $$FollowUpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FollowUpsTable,
          FollowUp,
          $$FollowUpsTableFilterComposer,
          $$FollowUpsTableOrderingComposer,
          $$FollowUpsTableAnnotationComposer,
          $$FollowUpsTableCreateCompanionBuilder,
          $$FollowUpsTableUpdateCompanionBuilder,
          (FollowUp, BaseReferences<_$AppDatabase, $FollowUpsTable, FollowUp>),
          FollowUp,
          PrefetchHooks Function()
        > {
  $$FollowUpsTableTableManager(_$AppDatabase db, $FollowUpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FollowUpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FollowUpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FollowUpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> targetDate = const Value.absent(),
                Value<int> entityType = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
              }) => FollowUpsCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                notes: notes,
                targetDate: targetDate,
                entityType: entityType,
                entityId: entityId,
                priority: priority,
                status: status,
                assignedTo: assignedTo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String title,
                Value<String?> notes = const Value.absent(),
                Value<String?> targetDate = const Value.absent(),
                Value<int> entityType = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
              }) => FollowUpsCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                notes: notes,
                targetDate: targetDate,
                entityType: entityType,
                entityId: entityId,
                priority: priority,
                status: status,
                assignedTo: assignedTo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FollowUpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FollowUpsTable,
      FollowUp,
      $$FollowUpsTableFilterComposer,
      $$FollowUpsTableOrderingComposer,
      $$FollowUpsTableAnnotationComposer,
      $$FollowUpsTableCreateCompanionBuilder,
      $$FollowUpsTableUpdateCompanionBuilder,
      (FollowUp, BaseReferences<_$AppDatabase, $FollowUpsTable, FollowUp>),
      FollowUp,
      PrefetchHooks Function()
    >;
typedef $$DirectivesTableCreateCompanionBuilder =
    DirectivesCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      required String title,
      Value<String?> details,
      Value<String?> source,
      Value<String?> assignedTo,
      Value<String?> deadline,
      Value<int> priority,
      Value<int> status,
    });
typedef $$DirectivesTableUpdateCompanionBuilder =
    DirectivesCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String> title,
      Value<String?> details,
      Value<String?> source,
      Value<String?> assignedTo,
      Value<String?> deadline,
      Value<int> priority,
      Value<int> status,
    });

class $$DirectivesTableFilterComposer
    extends Composer<_$AppDatabase, $DirectivesTable> {
  $$DirectivesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DirectivesTableOrderingComposer
    extends Composer<_$AppDatabase, $DirectivesTable> {
  $$DirectivesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DirectivesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DirectivesTable> {
  $$DirectivesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$DirectivesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DirectivesTable,
          Directive,
          $$DirectivesTableFilterComposer,
          $$DirectivesTableOrderingComposer,
          $$DirectivesTableAnnotationComposer,
          $$DirectivesTableCreateCompanionBuilder,
          $$DirectivesTableUpdateCompanionBuilder,
          (
            Directive,
            BaseReferences<_$AppDatabase, $DirectivesTable, Directive>,
          ),
          Directive,
          PrefetchHooks Function()
        > {
  $$DirectivesTableTableManager(_$AppDatabase db, $DirectivesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DirectivesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DirectivesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DirectivesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<String?> deadline = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> status = const Value.absent(),
              }) => DirectivesCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                details: details,
                source: source,
                assignedTo: assignedTo,
                deadline: deadline,
                priority: priority,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String title,
                Value<String?> details = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<String?> deadline = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> status = const Value.absent(),
              }) => DirectivesCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                details: details,
                source: source,
                assignedTo: assignedTo,
                deadline: deadline,
                priority: priority,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DirectivesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DirectivesTable,
      Directive,
      $$DirectivesTableFilterComposer,
      $$DirectivesTableOrderingComposer,
      $$DirectivesTableAnnotationComposer,
      $$DirectivesTableCreateCompanionBuilder,
      $$DirectivesTableUpdateCompanionBuilder,
      (Directive, BaseReferences<_$AppDatabase, $DirectivesTable, Directive>),
      Directive,
      PrefetchHooks Function()
    >;
typedef $$ContactsTableCreateCompanionBuilder =
    ContactsCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      required String name,
      Value<String?> position,
      Value<String?> company,
      Value<String?> phoneNumber,
      Value<String?> email,
      Value<bool> isVip,
      Value<String?> notes,
    });
typedef $$ContactsTableUpdateCompanionBuilder =
    ContactsCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String> name,
      Value<String?> position,
      Value<String?> company,
      Value<String?> phoneNumber,
      Value<String?> email,
      Value<bool> isVip,
      Value<String?> notes,
    });

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVip => $composableBuilder(
    column: $table.isVip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVip => $composableBuilder(
    column: $table.isVip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<bool> get isVip =>
      $composableBuilder(column: $table.isVip, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsTable,
          Contact,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (Contact, BaseReferences<_$AppDatabase, $ContactsTable, Contact>),
          Contact,
          PrefetchHooks Function()
        > {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<bool> isVip = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ContactsCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                name: name,
                position: position,
                company: company,
                phoneNumber: phoneNumber,
                email: email,
                isVip: isVip,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String name,
                Value<String?> position = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<bool> isVip = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ContactsCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                name: name,
                position: position,
                company: company,
                phoneNumber: phoneNumber,
                email: email,
                isVip: isVip,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsTable,
      Contact,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (Contact, BaseReferences<_$AppDatabase, $ContactsTable, Contact>),
      Contact,
      PrefetchHooks Function()
    >;
typedef $$AppointmentsTableCreateCompanionBuilder =
    AppointmentsCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      required String title,
      Value<int?> contactId,
      required String date,
      required String time,
      Value<int> durationMinutes,
      Value<String?> location,
      Value<int> status,
    });
typedef $$AppointmentsTableUpdateCompanionBuilder =
    AppointmentsCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String> title,
      Value<int?> contactId,
      Value<String> date,
      Value<String> time,
      Value<int> durationMinutes,
      Value<String?> location,
      Value<int> status,
    });

class $$AppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contactId => $composableBuilder(
    column: $table.contactId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get contactId =>
      $composableBuilder(column: $table.contactId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$AppointmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppointmentsTable,
          Appointment,
          $$AppointmentsTableFilterComposer,
          $$AppointmentsTableOrderingComposer,
          $$AppointmentsTableAnnotationComposer,
          $$AppointmentsTableCreateCompanionBuilder,
          $$AppointmentsTableUpdateCompanionBuilder,
          (
            Appointment,
            BaseReferences<_$AppDatabase, $AppointmentsTable, Appointment>,
          ),
          Appointment,
          PrefetchHooks Function()
        > {
  $$AppointmentsTableTableManager(_$AppDatabase db, $AppointmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> time = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int> status = const Value.absent(),
              }) => AppointmentsCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                contactId: contactId,
                date: date,
                time: time,
                durationMinutes: durationMinutes,
                location: location,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String title,
                Value<int?> contactId = const Value.absent(),
                required String date,
                required String time,
                Value<int> durationMinutes = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int> status = const Value.absent(),
              }) => AppointmentsCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                contactId: contactId,
                date: date,
                time: time,
                durationMinutes: durationMinutes,
                location: location,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppointmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppointmentsTable,
      Appointment,
      $$AppointmentsTableFilterComposer,
      $$AppointmentsTableOrderingComposer,
      $$AppointmentsTableAnnotationComposer,
      $$AppointmentsTableCreateCompanionBuilder,
      $$AppointmentsTableUpdateCompanionBuilder,
      (
        Appointment,
        BaseReferences<_$AppDatabase, $AppointmentsTable, Appointment>,
      ),
      Appointment,
      PrefetchHooks Function()
    >;
typedef $$ArchiveTableCreateCompanionBuilder =
    ArchiveCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      required String title,
      Value<String?> referenceNumber,
      Value<String?> hijriDate,
      Value<String?> documentDate,
      Value<String?> directedEntity,
      Value<String?> category,
      Value<String?> localFilePath,
      Value<String?> tags,
      Value<String?> notes,
      Value<bool> isConfidential,
    });
typedef $$ArchiveTableUpdateCompanionBuilder =
    ArchiveCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String> title,
      Value<String?> referenceNumber,
      Value<String?> hijriDate,
      Value<String?> documentDate,
      Value<String?> directedEntity,
      Value<String?> category,
      Value<String?> localFilePath,
      Value<String?> tags,
      Value<String?> notes,
      Value<bool> isConfidential,
    });

class $$ArchiveTableFilterComposer
    extends Composer<_$AppDatabase, $ArchiveTable> {
  $$ArchiveTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hijriDate => $composableBuilder(
    column: $table.hijriDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentDate => $composableBuilder(
    column: $table.documentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get directedEntity => $composableBuilder(
    column: $table.directedEntity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isConfidential => $composableBuilder(
    column: $table.isConfidential,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArchiveTableOrderingComposer
    extends Composer<_$AppDatabase, $ArchiveTable> {
  $$ArchiveTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hijriDate => $composableBuilder(
    column: $table.hijriDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentDate => $composableBuilder(
    column: $table.documentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get directedEntity => $composableBuilder(
    column: $table.directedEntity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isConfidential => $composableBuilder(
    column: $table.isConfidential,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArchiveTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArchiveTable> {
  $$ArchiveTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hijriDate =>
      $composableBuilder(column: $table.hijriDate, builder: (column) => column);

  GeneratedColumn<String> get documentDate => $composableBuilder(
    column: $table.documentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get directedEntity => $composableBuilder(
    column: $table.directedEntity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isConfidential => $composableBuilder(
    column: $table.isConfidential,
    builder: (column) => column,
  );
}

class $$ArchiveTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArchiveTable,
          ArchiveData,
          $$ArchiveTableFilterComposer,
          $$ArchiveTableOrderingComposer,
          $$ArchiveTableAnnotationComposer,
          $$ArchiveTableCreateCompanionBuilder,
          $$ArchiveTableUpdateCompanionBuilder,
          (
            ArchiveData,
            BaseReferences<_$AppDatabase, $ArchiveTable, ArchiveData>,
          ),
          ArchiveData,
          PrefetchHooks Function()
        > {
  $$ArchiveTableTableManager(_$AppDatabase db, $ArchiveTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArchiveTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArchiveTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArchiveTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<String?> hijriDate = const Value.absent(),
                Value<String?> documentDate = const Value.absent(),
                Value<String?> directedEntity = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isConfidential = const Value.absent(),
              }) => ArchiveCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                referenceNumber: referenceNumber,
                hijriDate: hijriDate,
                documentDate: documentDate,
                directedEntity: directedEntity,
                category: category,
                localFilePath: localFilePath,
                tags: tags,
                notes: notes,
                isConfidential: isConfidential,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String title,
                Value<String?> referenceNumber = const Value.absent(),
                Value<String?> hijriDate = const Value.absent(),
                Value<String?> documentDate = const Value.absent(),
                Value<String?> directedEntity = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isConfidential = const Value.absent(),
              }) => ArchiveCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                referenceNumber: referenceNumber,
                hijriDate: hijriDate,
                documentDate: documentDate,
                directedEntity: directedEntity,
                category: category,
                localFilePath: localFilePath,
                tags: tags,
                notes: notes,
                isConfidential: isConfidential,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArchiveTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArchiveTable,
      ArchiveData,
      $$ArchiveTableFilterComposer,
      $$ArchiveTableOrderingComposer,
      $$ArchiveTableAnnotationComposer,
      $$ArchiveTableCreateCompanionBuilder,
      $$ArchiveTableUpdateCompanionBuilder,
      (ArchiveData, BaseReferences<_$AppDatabase, $ArchiveTable, ArchiveData>),
      ArchiveData,
      PrefetchHooks Function()
    >;
typedef $$SecurityLogsTableCreateCompanionBuilder =
    SecurityLogsCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      required int action,
      Value<String?> details,
      Value<String?> deviceInfo,
      Value<String?> ipAddress,
    });
typedef $$SecurityLogsTableUpdateCompanionBuilder =
    SecurityLogsCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<int> action,
      Value<String?> details,
      Value<String?> deviceInfo,
      Value<String?> ipAddress,
    });

class $$SecurityLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SecurityLogsTable> {
  $$SecurityLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceInfo => $composableBuilder(
    column: $table.deviceInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SecurityLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SecurityLogsTable> {
  $$SecurityLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceInfo => $composableBuilder(
    column: $table.deviceInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SecurityLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SecurityLogsTable> {
  $$SecurityLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<int> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get deviceInfo => $composableBuilder(
    column: $table.deviceInfo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ipAddress =>
      $composableBuilder(column: $table.ipAddress, builder: (column) => column);
}

class $$SecurityLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SecurityLogsTable,
          SecurityLog,
          $$SecurityLogsTableFilterComposer,
          $$SecurityLogsTableOrderingComposer,
          $$SecurityLogsTableAnnotationComposer,
          $$SecurityLogsTableCreateCompanionBuilder,
          $$SecurityLogsTableUpdateCompanionBuilder,
          (
            SecurityLog,
            BaseReferences<_$AppDatabase, $SecurityLogsTable, SecurityLog>,
          ),
          SecurityLog,
          PrefetchHooks Function()
        > {
  $$SecurityLogsTableTableManager(_$AppDatabase db, $SecurityLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SecurityLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SecurityLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SecurityLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<int> action = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<String?> deviceInfo = const Value.absent(),
                Value<String?> ipAddress = const Value.absent(),
              }) => SecurityLogsCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                action: action,
                details: details,
                deviceInfo: deviceInfo,
                ipAddress: ipAddress,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required int action,
                Value<String?> details = const Value.absent(),
                Value<String?> deviceInfo = const Value.absent(),
                Value<String?> ipAddress = const Value.absent(),
              }) => SecurityLogsCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                action: action,
                details: details,
                deviceInfo: deviceInfo,
                ipAddress: ipAddress,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SecurityLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SecurityLogsTable,
      SecurityLog,
      $$SecurityLogsTableFilterComposer,
      $$SecurityLogsTableOrderingComposer,
      $$SecurityLogsTableAnnotationComposer,
      $$SecurityLogsTableCreateCompanionBuilder,
      $$SecurityLogsTableUpdateCompanionBuilder,
      (
        SecurityLog,
        BaseReferences<_$AppDatabase, $SecurityLogsTable, SecurityLog>,
      ),
      SecurityLog,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      required String key,
      required String value,
      Value<String?> category,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String> key,
      Value<String> value,
      Value<String?> category,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String?> category = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                key: key,
                value: value,
                category: category,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String key,
                required String value,
                Value<String?> category = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                key: key,
                value: value,
                category: category,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$CallsTableCreateCompanionBuilder =
    CallsCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      required String callerName,
      Value<String?> phoneNumber,
      Value<int> callType,
      required String date,
      required String time,
      Value<String?> summary,
      Value<bool> isImportant,
    });
typedef $$CallsTableUpdateCompanionBuilder =
    CallsCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String> callerName,
      Value<String?> phoneNumber,
      Value<int> callType,
      Value<String> date,
      Value<String> time,
      Value<String?> summary,
      Value<bool> isImportant,
    });

class $$CallsTableFilterComposer extends Composer<_$AppDatabase, $CallsTable> {
  $$CallsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callerName => $composableBuilder(
    column: $table.callerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get callType => $composableBuilder(
    column: $table.callType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isImportant => $composableBuilder(
    column: $table.isImportant,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CallsTableOrderingComposer
    extends Composer<_$AppDatabase, $CallsTable> {
  $$CallsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callerName => $composableBuilder(
    column: $table.callerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get callType => $composableBuilder(
    column: $table.callType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isImportant => $composableBuilder(
    column: $table.isImportant,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CallsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CallsTable> {
  $$CallsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get callerName => $composableBuilder(
    column: $table.callerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get callType =>
      $composableBuilder(column: $table.callType, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<bool> get isImportant => $composableBuilder(
    column: $table.isImportant,
    builder: (column) => column,
  );
}

class $$CallsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CallsTable,
          CallItem,
          $$CallsTableFilterComposer,
          $$CallsTableOrderingComposer,
          $$CallsTableAnnotationComposer,
          $$CallsTableCreateCompanionBuilder,
          $$CallsTableUpdateCompanionBuilder,
          (CallItem, BaseReferences<_$AppDatabase, $CallsTable, CallItem>),
          CallItem,
          PrefetchHooks Function()
        > {
  $$CallsTableTableManager(_$AppDatabase db, $CallsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CallsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CallsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CallsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> callerName = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<int> callType = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> time = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<bool> isImportant = const Value.absent(),
              }) => CallsCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                callerName: callerName,
                phoneNumber: phoneNumber,
                callType: callType,
                date: date,
                time: time,
                summary: summary,
                isImportant: isImportant,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String callerName,
                Value<String?> phoneNumber = const Value.absent(),
                Value<int> callType = const Value.absent(),
                required String date,
                required String time,
                Value<String?> summary = const Value.absent(),
                Value<bool> isImportant = const Value.absent(),
              }) => CallsCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                callerName: callerName,
                phoneNumber: phoneNumber,
                callType: callType,
                date: date,
                time: time,
                summary: summary,
                isImportant: isImportant,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CallsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CallsTable,
      CallItem,
      $$CallsTableFilterComposer,
      $$CallsTableOrderingComposer,
      $$CallsTableAnnotationComposer,
      $$CallsTableCreateCompanionBuilder,
      $$CallsTableUpdateCompanionBuilder,
      (CallItem, BaseReferences<_$AppDatabase, $CallsTable, CallItem>),
      CallItem,
      PrefetchHooks Function()
    >;
typedef $$VisitorsTableCreateCompanionBuilder =
    VisitorsCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      required String visitorName,
      Value<String?> company,
      Value<String?> purpose,
      Value<String?> appointmentId,
      Value<String?> entryTime,
      Value<String?> exitTime,
      Value<int> status,
    });
typedef $$VisitorsTableUpdateCompanionBuilder =
    VisitorsCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String> visitorName,
      Value<String?> company,
      Value<String?> purpose,
      Value<String?> appointmentId,
      Value<String?> entryTime,
      Value<String?> exitTime,
      Value<int> status,
    });

class $$VisitorsTableFilterComposer
    extends Composer<_$AppDatabase, $VisitorsTable> {
  $$VisitorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitorName => $composableBuilder(
    column: $table.visitorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appointmentId => $composableBuilder(
    column: $table.appointmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryTime => $composableBuilder(
    column: $table.entryTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exitTime => $composableBuilder(
    column: $table.exitTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitorsTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitorsTable> {
  $$VisitorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitorName => $composableBuilder(
    column: $table.visitorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appointmentId => $composableBuilder(
    column: $table.appointmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryTime => $composableBuilder(
    column: $table.entryTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exitTime => $composableBuilder(
    column: $table.exitTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitorsTable> {
  $$VisitorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get visitorName => $composableBuilder(
    column: $table.visitorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get appointmentId => $composableBuilder(
    column: $table.appointmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryTime =>
      $composableBuilder(column: $table.entryTime, builder: (column) => column);

  GeneratedColumn<String> get exitTime =>
      $composableBuilder(column: $table.exitTime, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$VisitorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitorsTable,
          VisitorItem,
          $$VisitorsTableFilterComposer,
          $$VisitorsTableOrderingComposer,
          $$VisitorsTableAnnotationComposer,
          $$VisitorsTableCreateCompanionBuilder,
          $$VisitorsTableUpdateCompanionBuilder,
          (
            VisitorItem,
            BaseReferences<_$AppDatabase, $VisitorsTable, VisitorItem>,
          ),
          VisitorItem,
          PrefetchHooks Function()
        > {
  $$VisitorsTableTableManager(_$AppDatabase db, $VisitorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> visitorName = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                Value<String?> appointmentId = const Value.absent(),
                Value<String?> entryTime = const Value.absent(),
                Value<String?> exitTime = const Value.absent(),
                Value<int> status = const Value.absent(),
              }) => VisitorsCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                visitorName: visitorName,
                company: company,
                purpose: purpose,
                appointmentId: appointmentId,
                entryTime: entryTime,
                exitTime: exitTime,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String visitorName,
                Value<String?> company = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                Value<String?> appointmentId = const Value.absent(),
                Value<String?> entryTime = const Value.absent(),
                Value<String?> exitTime = const Value.absent(),
                Value<int> status = const Value.absent(),
              }) => VisitorsCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                visitorName: visitorName,
                company: company,
                purpose: purpose,
                appointmentId: appointmentId,
                entryTime: entryTime,
                exitTime: exitTime,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitorsTable,
      VisitorItem,
      $$VisitorsTableFilterComposer,
      $$VisitorsTableOrderingComposer,
      $$VisitorsTableAnnotationComposer,
      $$VisitorsTableCreateCompanionBuilder,
      $$VisitorsTableUpdateCompanionBuilder,
      (VisitorItem, BaseReferences<_$AppDatabase, $VisitorsTable, VisitorItem>),
      VisitorItem,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String?> title,
      required String content,
      Value<String?> colorCode,
      Value<String?> tags,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String?> title,
      Value<String> content,
      Value<String?> colorCode,
      Value<String?> tags,
    });

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorCode => $composableBuilder(
    column: $table.colorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorCode => $composableBuilder(
    column: $table.colorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get colorCode =>
      $composableBuilder(column: $table.colorCode, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          NoteItem,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteItem, BaseReferences<_$AppDatabase, $NotesTable, NoteItem>),
          NoteItem,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> colorCode = const Value.absent(),
                Value<String?> tags = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                content: content,
                colorCode: colorCode,
                tags: tags,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> title = const Value.absent(),
                required String content,
                Value<String?> colorCode = const Value.absent(),
                Value<String?> tags = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                title: title,
                content: content,
                colorCode: colorCode,
                tags: tags,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      NoteItem,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteItem, BaseReferences<_$AppDatabase, $NotesTable, NoteItem>),
      NoteItem,
      PrefetchHooks Function()
    >;
typedef $$MovementsTableCreateCompanionBuilder =
    MovementsCompanion Function({
      Value<int> id,
      required String syncId,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      required String destination,
      Value<String?> purpose,
      required String date,
      required String time,
      Value<int> type,
      Value<String?> notes,
    });
typedef $$MovementsTableUpdateCompanionBuilder =
    MovementsCompanion Function({
      Value<int> id,
      Value<String> syncId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<String?> createdBy,
      Value<String> destination,
      Value<String?> purpose,
      Value<String> date,
      Value<String> time,
      Value<int> type,
      Value<String?> notes,
    });

class $$MovementsTableFilterComposer
    extends Composer<_$AppDatabase, $MovementsTable> {
  $$MovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $MovementsTable> {
  $$MovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovementsTable> {
  $$MovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$MovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovementsTable,
          Movement,
          $$MovementsTableFilterComposer,
          $$MovementsTableOrderingComposer,
          $$MovementsTableAnnotationComposer,
          $$MovementsTableCreateCompanionBuilder,
          $$MovementsTableUpdateCompanionBuilder,
          (Movement, BaseReferences<_$AppDatabase, $MovementsTable, Movement>),
          Movement,
          PrefetchHooks Function()
        > {
  $$MovementsTableTableManager(_$AppDatabase db, $MovementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> destination = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> time = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => MovementsCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                destination: destination,
                purpose: purpose,
                date: date,
                time: time,
                type: type,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncId,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String destination,
                Value<String?> purpose = const Value.absent(),
                required String date,
                required String time,
                Value<int> type = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => MovementsCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                createdBy: createdBy,
                destination: destination,
                purpose: purpose,
                date: date,
                time: time,
                type: type,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovementsTable,
      Movement,
      $$MovementsTableFilterComposer,
      $$MovementsTableOrderingComposer,
      $$MovementsTableAnnotationComposer,
      $$MovementsTableCreateCompanionBuilder,
      $$MovementsTableUpdateCompanionBuilder,
      (Movement, BaseReferences<_$AppDatabase, $MovementsTable, Movement>),
      Movement,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$MeetingsTableTableManager get meetings =>
      $$MeetingsTableTableManager(_db, _db.meetings);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$FollowUpsTableTableManager get followUps =>
      $$FollowUpsTableTableManager(_db, _db.followUps);
  $$DirectivesTableTableManager get directives =>
      $$DirectivesTableTableManager(_db, _db.directives);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db, _db.appointments);
  $$ArchiveTableTableManager get archive =>
      $$ArchiveTableTableManager(_db, _db.archive);
  $$SecurityLogsTableTableManager get securityLogs =>
      $$SecurityLogsTableTableManager(_db, _db.securityLogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$CallsTableTableManager get calls =>
      $$CallsTableTableManager(_db, _db.calls);
  $$VisitorsTableTableManager get visitors =>
      $$VisitorsTableTableManager(_db, _db.visitors);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$MovementsTableTableManager get movements =>
      $$MovementsTableTableManager(_db, _db.movements);
}

// ─────────────────────────────────────────────────────────────────
// RoutineTasks — hand-written stub (replace with build_runner output)
// ─────────────────────────────────────────────────────────────────

class $RoutineTasksTable extends RoutineTasks
    with TableInfo<$RoutineTasksTable, RoutineTaskData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineTasksTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id', aliasedName, false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints:
        GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );

  static const VerificationMeta _syncIdMeta =
      const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id', aliasedName, false,
    additionalChecks:
        GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at', aliasedName, false,
    type: DriftSqlType.int, requiredDuringInsert: true,
  );

  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at', aliasedName, false,
    type: DriftSqlType.int, requiredDuringInsert: true,
  );

  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted', aliasedName, false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints:
        GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );

  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by', aliasedName, true,
    type: DriftSqlType.string, requiredDuringInsert: false,
  );

  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title', aliasedName, false,
    additionalChecks:
        GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
    type: DriftSqlType.string, requiredDuringInsert: true,
  );

  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description', aliasedName, true,
    type: DriftSqlType.string, requiredDuringInsert: false,
  );

  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category', aliasedName, false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('personal'),
  );

  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority', aliasedName, false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );

  static const VerificationMeta _repeatMeta =
      const VerificationMeta('repeat');
  @override
  late final GeneratedColumn<String> repeat = GeneratedColumn<String>(
    'repeat', aliasedName, false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('daily'),
  );

  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
    'time', aliasedName, true,
    type: DriftSqlType.string, requiredDuringInsert: false,
  );

  static const VerificationMeta _daysOfWeekMeta =
      const VerificationMeta('daysOfWeek');
  @override
  late final GeneratedColumn<String> daysOfWeek = GeneratedColumn<String>(
    'days_of_week', aliasedName, false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );

  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active', aliasedName, false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints:
        GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
    defaultValue: const Constant(true),
  );

  @override
  List<GeneratedColumn> get $columns => [
        id, syncId, createdAt, updatedAt, isDeleted, createdBy,
        title, description, category, priority, repeat, time,
        daysOfWeek, isActive,
      ];

  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_tasks';

  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineTaskData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};

  @override
  RoutineTaskData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineTaskData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      repeat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repeat'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time']),
      daysOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}days_of_week'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $RoutineTasksTable createAlias(String alias) =>
      $RoutineTasksTable(attachedDatabase, alias);
}

class RoutineTaskData extends DataClass
    implements Insertable<RoutineTaskData> {
  final int id;
  final String syncId;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;
  final String? createdBy;
  final String title;
  final String? description;
  final String category;
  final int priority;
  final String repeat;
  final String? time;
  final String daysOfWeek;
  final bool isActive;

  const RoutineTaskData({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.repeat,
    this.time,
    required this.daysOfWeek,
    required this.isActive,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['category'] = Variable<String>(category);
    map['priority'] = Variable<int>(priority);
    map['repeat'] = Variable<String>(repeat);
    if (!nullToAbsent || time != null) {
      map['time'] = Variable<String>(time);
    }
    map['days_of_week'] = Variable<String>(daysOfWeek);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  RoutineTasksCompanion toCompanion(bool nullToAbsent) {
    return RoutineTasksCompanion(
      id: Value(id),
      syncId: Value(syncId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: Value(category),
      priority: Value(priority),
      repeat: Value(repeat),
      time: time == null && nullToAbsent ? const Value.absent() : Value(time),
      daysOfWeek: Value(daysOfWeek),
      isActive: Value(isActive),
    );
  }

  factory RoutineTaskData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineTaskData(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      priority: serializer.fromJson<int>(json['priority']),
      repeat: serializer.fromJson<String>(json['repeat']),
      time: serializer.fromJson<String?>(json['time']),
      daysOfWeek: serializer.fromJson<String>(json['daysOfWeek']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String>(category),
      'priority': serializer.toJson<int>(priority),
      'repeat': serializer.toJson<String>(repeat),
      'time': serializer.toJson<String?>(time),
      'daysOfWeek': serializer.toJson<String>(daysOfWeek),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  RoutineTaskData copyWith({
    int? id, String? syncId, int? createdAt, int? updatedAt,
    bool? isDeleted, Value<String?> createdBy = const Value.absent(),
    String? title, Value<String?> description = const Value.absent(),
    String? category, int? priority, String? repeat,
    Value<String?> time = const Value.absent(),
    String? daysOfWeek, bool? isActive,
  }) => RoutineTaskData(
    id: id ?? this.id, syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    category: category ?? this.category, priority: priority ?? this.priority,
    repeat: repeat ?? this.repeat,
    time: time.present ? time.value : this.time,
    daysOfWeek: daysOfWeek ?? this.daysOfWeek, isActive: isActive ?? this.isActive,
  );

  @override
  String toString() => 'RoutineTaskData(id: $id, title: $title)';

  @override
  int get hashCode => Object.hash(id, syncId, title, priority);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineTaskData && other.id == id && other.syncId == syncId);
}

class RoutineTasksCompanion extends UpdateCompanion<RoutineTaskData> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> category;
  final Value<int> priority;
  final Value<String> repeat;
  final Value<String?> time;
  final Value<String> daysOfWeek;
  final Value<bool> isActive;

  const RoutineTasksCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
    this.repeat = const Value.absent(),
    this.time = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.isActive = const Value.absent(),
  });

  RoutineTasksCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
    this.repeat = const Value.absent(),
    this.time = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.isActive = const Value.absent(),
  })  : syncId = Value(syncId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        title = Value(title);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) map['id'] = Variable<int>(id.value);
    if (syncId.present) map['sync_id'] = Variable<String>(syncId.value);
    if (createdAt.present) map['created_at'] = Variable<int>(createdAt.value);
    if (updatedAt.present) map['updated_at'] = Variable<int>(updatedAt.value);
    if (isDeleted.present) map['is_deleted'] = Variable<bool>(isDeleted.value);
    if (createdBy.present) map['created_by'] = Variable<String>(createdBy.value);
    if (title.present) map['title'] = Variable<String>(title.value);
    if (description.present) map['description'] = Variable<String>(description.value);
    if (category.present) map['category'] = Variable<String>(category.value);
    if (priority.present) map['priority'] = Variable<int>(priority.value);
    if (repeat.present) map['repeat'] = Variable<String>(repeat.value);
    if (time.present) map['time'] = Variable<String>(time.value);
    if (daysOfWeek.present) map['days_of_week'] = Variable<String>(daysOfWeek.value);
    if (isActive.present) map['is_active'] = Variable<bool>(isActive.value);
    return map;
  }

  @override
  String toString() => 'RoutineTasksCompanion(title: $title)';
}

// ─────────────────────────────────────────────────────────────────
// RoutineCompletions
// ─────────────────────────────────────────────────────────────────

class $RoutineCompletionsTable extends RoutineCompletions
    with TableInfo<$RoutineCompletionsTable, RoutineCompletionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineCompletionsTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id', aliasedName, false,
    hasAutoIncrement: true, type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints:
        GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );

  static const VerificationMeta _syncIdMeta =
      const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id', aliasedName, false,
    additionalChecks:
        GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
    type: DriftSqlType.string, requiredDuringInsert: true,
  );

  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at', aliasedName, false,
    type: DriftSqlType.int, requiredDuringInsert: true,
  );

  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at', aliasedName, false,
    type: DriftSqlType.int, requiredDuringInsert: true,
  );

  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted', aliasedName, false,
    type: DriftSqlType.bool, requiredDuringInsert: false,
    defaultConstraints:
        GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );

  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by', aliasedName, true,
    type: DriftSqlType.string, requiredDuringInsert: false,
  );

  static const VerificationMeta _routineTaskSyncIdMeta =
      const VerificationMeta('routineTaskSyncId');
  @override
  late final GeneratedColumn<String> routineTaskSyncId =
      GeneratedColumn<String>(
    'routine_task_sync_id', aliasedName, false,
    additionalChecks:
        GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
    type: DriftSqlType.string, requiredDuringInsert: true,
  );

  static const VerificationMeta _dateKeyMeta =
      const VerificationMeta('dateKey');
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key', aliasedName, false,
    additionalChecks:
        GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 10),
    type: DriftSqlType.string, requiredDuringInsert: true,
  );

  @override
  List<GeneratedColumn> get $columns =>
      [id, syncId, createdAt, updatedAt, isDeleted, createdBy,
       routineTaskSyncId, dateKey];

  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_completions';

  @override
  VerificationContext validateIntegrity(
      Insertable<RoutineCompletionData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(_syncIdMeta,
          syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta));
    } else if (isInserting) {
      context.missing(_syncIdMeta);
    }
    if (data.containsKey('routine_task_sync_id')) {
      context.handle(
          _routineTaskSyncIdMeta,
          routineTaskSyncId.isAcceptableOrUnknown(
              data['routine_task_sync_id']!, _routineTaskSyncIdMeta));
    } else if (isInserting) {
      context.missing(_routineTaskSyncIdMeta);
    }
    if (data.containsKey('date_key')) {
      context.handle(_dateKeyMeta,
          dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta));
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};

  @override
  RoutineCompletionData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineCompletionData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      syncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      routineTaskSyncId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}routine_task_sync_id'])!,
      dateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_key'])!,
    );
  }

  @override
  $RoutineCompletionsTable createAlias(String alias) =>
      $RoutineCompletionsTable(attachedDatabase, alias);
}

class RoutineCompletionData extends DataClass
    implements Insertable<RoutineCompletionData> {
  final int id;
  final String syncId;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;
  final String? createdBy;
  final String routineTaskSyncId;
  final String dateKey;

  const RoutineCompletionData({
    required this.id,
    required this.syncId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.createdBy,
    required this.routineTaskSyncId,
    required this.dateKey,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_id'] = Variable<String>(syncId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['routine_task_sync_id'] = Variable<String>(routineTaskSyncId);
    map['date_key'] = Variable<String>(dateKey);
    return map;
  }

  RoutineCompletionsCompanion toCompanion(bool nullToAbsent) {
    return RoutineCompletionsCompanion(
      id: Value(id), syncId: Value(syncId),
      createdAt: Value(createdAt), updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent() : Value(createdBy),
      routineTaskSyncId: Value(routineTaskSyncId),
      dateKey: Value(dateKey),
    );
  }

  factory RoutineCompletionData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineCompletionData(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String>(json['syncId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      routineTaskSyncId: serializer.fromJson<String>(json['routineTaskSyncId']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String>(syncId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdBy': serializer.toJson<String?>(createdBy),
      'routineTaskSyncId': serializer.toJson<String>(routineTaskSyncId),
      'dateKey': serializer.toJson<String>(dateKey),
    };
  }

  RoutineCompletionData copyWith({
    int? id, String? syncId, int? createdAt, int? updatedAt,
    bool? isDeleted, Value<String?> createdBy = const Value.absent(),
    String? routineTaskSyncId, String? dateKey,
  }) => RoutineCompletionData(
    id: id ?? this.id, syncId: syncId ?? this.syncId,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    routineTaskSyncId: routineTaskSyncId ?? this.routineTaskSyncId,
    dateKey: dateKey ?? this.dateKey,
  );

  @override
  String toString() =>
      'RoutineCompletionData(taskId: $routineTaskSyncId, date: $dateKey)';

  @override
  int get hashCode => Object.hash(id, routineTaskSyncId, dateKey);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineCompletionData &&
          other.routineTaskSyncId == routineTaskSyncId &&
          other.dateKey == dateKey);
}

class RoutineCompletionsCompanion
    extends UpdateCompanion<RoutineCompletionData> {
  final Value<int> id;
  final Value<String> syncId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<String?> createdBy;
  final Value<String> routineTaskSyncId;
  final Value<String> dateKey;

  const RoutineCompletionsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.routineTaskSyncId = const Value.absent(),
    this.dateKey = const Value.absent(),
  });

  RoutineCompletionsCompanion.insert({
    this.id = const Value.absent(),
    required String syncId,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String routineTaskSyncId,
    required String dateKey,
  })  : syncId = Value(syncId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        routineTaskSyncId = Value(routineTaskSyncId),
        dateKey = Value(dateKey);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) map['id'] = Variable<int>(id.value);
    if (syncId.present) map['sync_id'] = Variable<String>(syncId.value);
    if (createdAt.present) map['created_at'] = Variable<int>(createdAt.value);
    if (updatedAt.present) map['updated_at'] = Variable<int>(updatedAt.value);
    if (isDeleted.present) map['is_deleted'] = Variable<bool>(isDeleted.value);
    if (createdBy.present) map['created_by'] = Variable<String>(createdBy.value);
    if (routineTaskSyncId.present)
      map['routine_task_sync_id'] = Variable<String>(routineTaskSyncId.value);
    if (dateKey.present) map['date_key'] = Variable<String>(dateKey.value);
    return map;
  }

  @override
  String toString() =>
      'RoutineCompletionsCompanion(taskId: $routineTaskSyncId, date: $dateKey)';
}

// ─────────────────────────────────────────────────────────────────
// _$AppDatabase mixin additions for new tables
// ─────────────────────────────────────────────────────────────────
// NOTE: The _$AppDatabase abstract class is auto-generated above.
// The routineTasks and routineCompletions getters below are appended
// as an extension to avoid modifying the generated mixin.
// Run `dart run build_runner build --delete-conflicting-outputs`
// to regenerate the full file cleanly.
