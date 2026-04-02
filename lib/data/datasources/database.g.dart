// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DownloadQueuesTable extends DownloadQueues
    with TableInfo<$DownloadQueuesTable, DownloadQueue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadQueuesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxConcurrentMeta = const VerificationMeta(
    'maxConcurrent',
  );
  @override
  late final GeneratedColumn<int> maxConcurrent = GeneratedColumn<int>(
    'max_concurrent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _scheduleConfigMeta = const VerificationMeta(
    'scheduleConfig',
  );
  @override
  late final GeneratedColumn<String> scheduleConfig = GeneratedColumn<String>(
    'schedule_config',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postActionMeta = const VerificationMeta(
    'postAction',
  );
  @override
  late final GeneratedColumn<String> postAction = GeneratedColumn<String>(
    'post_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('nothing'),
  );
  static const VerificationMeta _postActionProgramMeta = const VerificationMeta(
    'postActionProgram',
  );
  @override
  late final GeneratedColumn<String> postActionProgram =
      GeneratedColumn<String>(
        'post_action_program',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    maxConcurrent,
    scheduleConfig,
    postAction,
    postActionProgram,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_queues';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadQueue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('max_concurrent')) {
      context.handle(
        _maxConcurrentMeta,
        maxConcurrent.isAcceptableOrUnknown(
          data['max_concurrent']!,
          _maxConcurrentMeta,
        ),
      );
    }
    if (data.containsKey('schedule_config')) {
      context.handle(
        _scheduleConfigMeta,
        scheduleConfig.isAcceptableOrUnknown(
          data['schedule_config']!,
          _scheduleConfigMeta,
        ),
      );
    }
    if (data.containsKey('post_action')) {
      context.handle(
        _postActionMeta,
        postAction.isAcceptableOrUnknown(data['post_action']!, _postActionMeta),
      );
    }
    if (data.containsKey('post_action_program')) {
      context.handle(
        _postActionProgramMeta,
        postActionProgram.isAcceptableOrUnknown(
          data['post_action_program']!,
          _postActionProgramMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadQueue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadQueue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      maxConcurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_concurrent'],
      )!,
      scheduleConfig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_config'],
      ),
      postAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_action'],
      )!,
      postActionProgram: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_action_program'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $DownloadQueuesTable createAlias(String alias) {
    return $DownloadQueuesTable(attachedDatabase, alias);
  }
}

class DownloadQueue extends DataClass implements Insertable<DownloadQueue> {
  final int id;
  final String name;
  final int maxConcurrent;
  final String? scheduleConfig;
  final String postAction;
  final String? postActionProgram;
  final bool isActive;
  const DownloadQueue({
    required this.id,
    required this.name,
    required this.maxConcurrent,
    this.scheduleConfig,
    required this.postAction,
    this.postActionProgram,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['max_concurrent'] = Variable<int>(maxConcurrent);
    if (!nullToAbsent || scheduleConfig != null) {
      map['schedule_config'] = Variable<String>(scheduleConfig);
    }
    map['post_action'] = Variable<String>(postAction);
    if (!nullToAbsent || postActionProgram != null) {
      map['post_action_program'] = Variable<String>(postActionProgram);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  DownloadQueuesCompanion toCompanion(bool nullToAbsent) {
    return DownloadQueuesCompanion(
      id: Value(id),
      name: Value(name),
      maxConcurrent: Value(maxConcurrent),
      scheduleConfig: scheduleConfig == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleConfig),
      postAction: Value(postAction),
      postActionProgram: postActionProgram == null && nullToAbsent
          ? const Value.absent()
          : Value(postActionProgram),
      isActive: Value(isActive),
    );
  }

  factory DownloadQueue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadQueue(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      maxConcurrent: serializer.fromJson<int>(json['maxConcurrent']),
      scheduleConfig: serializer.fromJson<String?>(json['scheduleConfig']),
      postAction: serializer.fromJson<String>(json['postAction']),
      postActionProgram: serializer.fromJson<String?>(
        json['postActionProgram'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'maxConcurrent': serializer.toJson<int>(maxConcurrent),
      'scheduleConfig': serializer.toJson<String?>(scheduleConfig),
      'postAction': serializer.toJson<String>(postAction),
      'postActionProgram': serializer.toJson<String?>(postActionProgram),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  DownloadQueue copyWith({
    int? id,
    String? name,
    int? maxConcurrent,
    Value<String?> scheduleConfig = const Value.absent(),
    String? postAction,
    Value<String?> postActionProgram = const Value.absent(),
    bool? isActive,
  }) => DownloadQueue(
    id: id ?? this.id,
    name: name ?? this.name,
    maxConcurrent: maxConcurrent ?? this.maxConcurrent,
    scheduleConfig: scheduleConfig.present
        ? scheduleConfig.value
        : this.scheduleConfig,
    postAction: postAction ?? this.postAction,
    postActionProgram: postActionProgram.present
        ? postActionProgram.value
        : this.postActionProgram,
    isActive: isActive ?? this.isActive,
  );
  DownloadQueue copyWithCompanion(DownloadQueuesCompanion data) {
    return DownloadQueue(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      maxConcurrent: data.maxConcurrent.present
          ? data.maxConcurrent.value
          : this.maxConcurrent,
      scheduleConfig: data.scheduleConfig.present
          ? data.scheduleConfig.value
          : this.scheduleConfig,
      postAction: data.postAction.present
          ? data.postAction.value
          : this.postAction,
      postActionProgram: data.postActionProgram.present
          ? data.postActionProgram.value
          : this.postActionProgram,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadQueue(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('maxConcurrent: $maxConcurrent, ')
          ..write('scheduleConfig: $scheduleConfig, ')
          ..write('postAction: $postAction, ')
          ..write('postActionProgram: $postActionProgram, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    maxConcurrent,
    scheduleConfig,
    postAction,
    postActionProgram,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadQueue &&
          other.id == this.id &&
          other.name == this.name &&
          other.maxConcurrent == this.maxConcurrent &&
          other.scheduleConfig == this.scheduleConfig &&
          other.postAction == this.postAction &&
          other.postActionProgram == this.postActionProgram &&
          other.isActive == this.isActive);
}

class DownloadQueuesCompanion extends UpdateCompanion<DownloadQueue> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> maxConcurrent;
  final Value<String?> scheduleConfig;
  final Value<String> postAction;
  final Value<String?> postActionProgram;
  final Value<bool> isActive;
  const DownloadQueuesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.maxConcurrent = const Value.absent(),
    this.scheduleConfig = const Value.absent(),
    this.postAction = const Value.absent(),
    this.postActionProgram = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  DownloadQueuesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.maxConcurrent = const Value.absent(),
    this.scheduleConfig = const Value.absent(),
    this.postAction = const Value.absent(),
    this.postActionProgram = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : name = Value(name);
  static Insertable<DownloadQueue> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? maxConcurrent,
    Expression<String>? scheduleConfig,
    Expression<String>? postAction,
    Expression<String>? postActionProgram,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (maxConcurrent != null) 'max_concurrent': maxConcurrent,
      if (scheduleConfig != null) 'schedule_config': scheduleConfig,
      if (postAction != null) 'post_action': postAction,
      if (postActionProgram != null) 'post_action_program': postActionProgram,
      if (isActive != null) 'is_active': isActive,
    });
  }

  DownloadQueuesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? maxConcurrent,
    Value<String?>? scheduleConfig,
    Value<String>? postAction,
    Value<String?>? postActionProgram,
    Value<bool>? isActive,
  }) {
    return DownloadQueuesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      maxConcurrent: maxConcurrent ?? this.maxConcurrent,
      scheduleConfig: scheduleConfig ?? this.scheduleConfig,
      postAction: postAction ?? this.postAction,
      postActionProgram: postActionProgram ?? this.postActionProgram,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (maxConcurrent.present) {
      map['max_concurrent'] = Variable<int>(maxConcurrent.value);
    }
    if (scheduleConfig.present) {
      map['schedule_config'] = Variable<String>(scheduleConfig.value);
    }
    if (postAction.present) {
      map['post_action'] = Variable<String>(postAction.value);
    }
    if (postActionProgram.present) {
      map['post_action_program'] = Variable<String>(postActionProgram.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadQueuesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('maxConcurrent: $maxConcurrent, ')
          ..write('scheduleConfig: $scheduleConfig, ')
          ..write('postAction: $postAction, ')
          ..write('postActionProgram: $postActionProgram, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $DownloadItemsTable extends DownloadItems
    with TableInfo<$DownloadItemsTable, DownloadItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savePathMeta = const VerificationMeta(
    'savePath',
  );
  @override
  late final GeneratedColumn<String> savePath = GeneratedColumn<String>(
    'save_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalSizeMeta = const VerificationMeta(
    'totalSize',
  );
  @override
  late final GeneratedColumn<int> totalSize = GeneratedColumn<int>(
    'total_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(-1),
  );
  static const VerificationMeta _downloadedSizeMeta = const VerificationMeta(
    'downloadedSize',
  );
  @override
  late final GeneratedColumn<int> downloadedSize = GeneratedColumn<int>(
    'downloaded_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _threadCountMeta = const VerificationMeta(
    'threadCount',
  );
  @override
  late final GeneratedColumn<int> threadCount = GeneratedColumn<int>(
    'thread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCompletedMeta = const VerificationMeta(
    'dateCompleted',
  );
  @override
  late final GeneratedColumn<DateTime> dateCompleted =
      GeneratedColumn<DateTime>(
        'date_completed',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
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
  static const VerificationMeta _queueIdMeta = const VerificationMeta(
    'queueId',
  );
  @override
  late final GeneratedColumn<int> queueId = GeneratedColumn<int>(
    'queue_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES download_queues (id)',
    ),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _customHeadersMeta = const VerificationMeta(
    'customHeaders',
  );
  @override
  late final GeneratedColumn<String> customHeaders = GeneratedColumn<String>(
    'custom_headers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _proxyConfigMeta = const VerificationMeta(
    'proxyConfig',
  );
  @override
  late final GeneratedColumn<String> proxyConfig = GeneratedColumn<String>(
    'proxy_config',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedLimitMeta = const VerificationMeta(
    'speedLimit',
  );
  @override
  late final GeneratedColumn<int> speedLimit = GeneratedColumn<int>(
    'speed_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    fileName,
    savePath,
    totalSize,
    downloadedSize,
    status,
    threadCount,
    speed,
    dateAdded,
    dateCompleted,
    category,
    queueId,
    errorMessage,
    retryCount,
    customHeaders,
    proxyConfig,
    speedLimit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('save_path')) {
      context.handle(
        _savePathMeta,
        savePath.isAcceptableOrUnknown(data['save_path']!, _savePathMeta),
      );
    } else if (isInserting) {
      context.missing(_savePathMeta);
    }
    if (data.containsKey('total_size')) {
      context.handle(
        _totalSizeMeta,
        totalSize.isAcceptableOrUnknown(data['total_size']!, _totalSizeMeta),
      );
    }
    if (data.containsKey('downloaded_size')) {
      context.handle(
        _downloadedSizeMeta,
        downloadedSize.isAcceptableOrUnknown(
          data['downloaded_size']!,
          _downloadedSizeMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('thread_count')) {
      context.handle(
        _threadCountMeta,
        threadCount.isAcceptableOrUnknown(
          data['thread_count']!,
          _threadCountMeta,
        ),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    if (data.containsKey('date_completed')) {
      context.handle(
        _dateCompletedMeta,
        dateCompleted.isAcceptableOrUnknown(
          data['date_completed']!,
          _dateCompletedMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('queue_id')) {
      context.handle(
        _queueIdMeta,
        queueId.isAcceptableOrUnknown(data['queue_id']!, _queueIdMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('custom_headers')) {
      context.handle(
        _customHeadersMeta,
        customHeaders.isAcceptableOrUnknown(
          data['custom_headers']!,
          _customHeadersMeta,
        ),
      );
    }
    if (data.containsKey('proxy_config')) {
      context.handle(
        _proxyConfigMeta,
        proxyConfig.isAcceptableOrUnknown(
          data['proxy_config']!,
          _proxyConfigMeta,
        ),
      );
    }
    if (data.containsKey('speed_limit')) {
      context.handle(
        _speedLimitMeta,
        speedLimit.isAcceptableOrUnknown(data['speed_limit']!, _speedLimitMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      savePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_path'],
      )!,
      totalSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_size'],
      )!,
      downloadedSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_size'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      threadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}thread_count'],
      )!,
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
      dateCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_completed'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      queueId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queue_id'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      customHeaders: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_headers'],
      )!,
      proxyConfig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proxy_config'],
      ),
      speedLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speed_limit'],
      )!,
    );
  }

  @override
  $DownloadItemsTable createAlias(String alias) {
    return $DownloadItemsTable(attachedDatabase, alias);
  }
}

class DownloadItem extends DataClass implements Insertable<DownloadItem> {
  final int id;
  final String url;
  final String fileName;
  final String savePath;
  final int totalSize;
  final int downloadedSize;
  final String status;
  final int threadCount;
  final double speed;
  final DateTime dateAdded;
  final DateTime? dateCompleted;
  final String? category;
  final int? queueId;
  final String? errorMessage;
  final int retryCount;
  final String customHeaders;
  final String? proxyConfig;
  final int speedLimit;
  const DownloadItem({
    required this.id,
    required this.url,
    required this.fileName,
    required this.savePath,
    required this.totalSize,
    required this.downloadedSize,
    required this.status,
    required this.threadCount,
    required this.speed,
    required this.dateAdded,
    this.dateCompleted,
    this.category,
    this.queueId,
    this.errorMessage,
    required this.retryCount,
    required this.customHeaders,
    this.proxyConfig,
    required this.speedLimit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    map['file_name'] = Variable<String>(fileName);
    map['save_path'] = Variable<String>(savePath);
    map['total_size'] = Variable<int>(totalSize);
    map['downloaded_size'] = Variable<int>(downloadedSize);
    map['status'] = Variable<String>(status);
    map['thread_count'] = Variable<int>(threadCount);
    map['speed'] = Variable<double>(speed);
    map['date_added'] = Variable<DateTime>(dateAdded);
    if (!nullToAbsent || dateCompleted != null) {
      map['date_completed'] = Variable<DateTime>(dateCompleted);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || queueId != null) {
      map['queue_id'] = Variable<int>(queueId);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['retry_count'] = Variable<int>(retryCount);
    map['custom_headers'] = Variable<String>(customHeaders);
    if (!nullToAbsent || proxyConfig != null) {
      map['proxy_config'] = Variable<String>(proxyConfig);
    }
    map['speed_limit'] = Variable<int>(speedLimit);
    return map;
  }

  DownloadItemsCompanion toCompanion(bool nullToAbsent) {
    return DownloadItemsCompanion(
      id: Value(id),
      url: Value(url),
      fileName: Value(fileName),
      savePath: Value(savePath),
      totalSize: Value(totalSize),
      downloadedSize: Value(downloadedSize),
      status: Value(status),
      threadCount: Value(threadCount),
      speed: Value(speed),
      dateAdded: Value(dateAdded),
      dateCompleted: dateCompleted == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCompleted),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      queueId: queueId == null && nullToAbsent
          ? const Value.absent()
          : Value(queueId),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      retryCount: Value(retryCount),
      customHeaders: Value(customHeaders),
      proxyConfig: proxyConfig == null && nullToAbsent
          ? const Value.absent()
          : Value(proxyConfig),
      speedLimit: Value(speedLimit),
    );
  }

  factory DownloadItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadItem(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      fileName: serializer.fromJson<String>(json['fileName']),
      savePath: serializer.fromJson<String>(json['savePath']),
      totalSize: serializer.fromJson<int>(json['totalSize']),
      downloadedSize: serializer.fromJson<int>(json['downloadedSize']),
      status: serializer.fromJson<String>(json['status']),
      threadCount: serializer.fromJson<int>(json['threadCount']),
      speed: serializer.fromJson<double>(json['speed']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      dateCompleted: serializer.fromJson<DateTime?>(json['dateCompleted']),
      category: serializer.fromJson<String?>(json['category']),
      queueId: serializer.fromJson<int?>(json['queueId']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      customHeaders: serializer.fromJson<String>(json['customHeaders']),
      proxyConfig: serializer.fromJson<String?>(json['proxyConfig']),
      speedLimit: serializer.fromJson<int>(json['speedLimit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'fileName': serializer.toJson<String>(fileName),
      'savePath': serializer.toJson<String>(savePath),
      'totalSize': serializer.toJson<int>(totalSize),
      'downloadedSize': serializer.toJson<int>(downloadedSize),
      'status': serializer.toJson<String>(status),
      'threadCount': serializer.toJson<int>(threadCount),
      'speed': serializer.toJson<double>(speed),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'dateCompleted': serializer.toJson<DateTime?>(dateCompleted),
      'category': serializer.toJson<String?>(category),
      'queueId': serializer.toJson<int?>(queueId),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'retryCount': serializer.toJson<int>(retryCount),
      'customHeaders': serializer.toJson<String>(customHeaders),
      'proxyConfig': serializer.toJson<String?>(proxyConfig),
      'speedLimit': serializer.toJson<int>(speedLimit),
    };
  }

  DownloadItem copyWith({
    int? id,
    String? url,
    String? fileName,
    String? savePath,
    int? totalSize,
    int? downloadedSize,
    String? status,
    int? threadCount,
    double? speed,
    DateTime? dateAdded,
    Value<DateTime?> dateCompleted = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<int?> queueId = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    int? retryCount,
    String? customHeaders,
    Value<String?> proxyConfig = const Value.absent(),
    int? speedLimit,
  }) => DownloadItem(
    id: id ?? this.id,
    url: url ?? this.url,
    fileName: fileName ?? this.fileName,
    savePath: savePath ?? this.savePath,
    totalSize: totalSize ?? this.totalSize,
    downloadedSize: downloadedSize ?? this.downloadedSize,
    status: status ?? this.status,
    threadCount: threadCount ?? this.threadCount,
    speed: speed ?? this.speed,
    dateAdded: dateAdded ?? this.dateAdded,
    dateCompleted: dateCompleted.present
        ? dateCompleted.value
        : this.dateCompleted,
    category: category.present ? category.value : this.category,
    queueId: queueId.present ? queueId.value : this.queueId,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    retryCount: retryCount ?? this.retryCount,
    customHeaders: customHeaders ?? this.customHeaders,
    proxyConfig: proxyConfig.present ? proxyConfig.value : this.proxyConfig,
    speedLimit: speedLimit ?? this.speedLimit,
  );
  DownloadItem copyWithCompanion(DownloadItemsCompanion data) {
    return DownloadItem(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      savePath: data.savePath.present ? data.savePath.value : this.savePath,
      totalSize: data.totalSize.present ? data.totalSize.value : this.totalSize,
      downloadedSize: data.downloadedSize.present
          ? data.downloadedSize.value
          : this.downloadedSize,
      status: data.status.present ? data.status.value : this.status,
      threadCount: data.threadCount.present
          ? data.threadCount.value
          : this.threadCount,
      speed: data.speed.present ? data.speed.value : this.speed,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      dateCompleted: data.dateCompleted.present
          ? data.dateCompleted.value
          : this.dateCompleted,
      category: data.category.present ? data.category.value : this.category,
      queueId: data.queueId.present ? data.queueId.value : this.queueId,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      customHeaders: data.customHeaders.present
          ? data.customHeaders.value
          : this.customHeaders,
      proxyConfig: data.proxyConfig.present
          ? data.proxyConfig.value
          : this.proxyConfig,
      speedLimit: data.speedLimit.present
          ? data.speedLimit.value
          : this.speedLimit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadItem(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('fileName: $fileName, ')
          ..write('savePath: $savePath, ')
          ..write('totalSize: $totalSize, ')
          ..write('downloadedSize: $downloadedSize, ')
          ..write('status: $status, ')
          ..write('threadCount: $threadCount, ')
          ..write('speed: $speed, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateCompleted: $dateCompleted, ')
          ..write('category: $category, ')
          ..write('queueId: $queueId, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('retryCount: $retryCount, ')
          ..write('customHeaders: $customHeaders, ')
          ..write('proxyConfig: $proxyConfig, ')
          ..write('speedLimit: $speedLimit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    fileName,
    savePath,
    totalSize,
    downloadedSize,
    status,
    threadCount,
    speed,
    dateAdded,
    dateCompleted,
    category,
    queueId,
    errorMessage,
    retryCount,
    customHeaders,
    proxyConfig,
    speedLimit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadItem &&
          other.id == this.id &&
          other.url == this.url &&
          other.fileName == this.fileName &&
          other.savePath == this.savePath &&
          other.totalSize == this.totalSize &&
          other.downloadedSize == this.downloadedSize &&
          other.status == this.status &&
          other.threadCount == this.threadCount &&
          other.speed == this.speed &&
          other.dateAdded == this.dateAdded &&
          other.dateCompleted == this.dateCompleted &&
          other.category == this.category &&
          other.queueId == this.queueId &&
          other.errorMessage == this.errorMessage &&
          other.retryCount == this.retryCount &&
          other.customHeaders == this.customHeaders &&
          other.proxyConfig == this.proxyConfig &&
          other.speedLimit == this.speedLimit);
}

class DownloadItemsCompanion extends UpdateCompanion<DownloadItem> {
  final Value<int> id;
  final Value<String> url;
  final Value<String> fileName;
  final Value<String> savePath;
  final Value<int> totalSize;
  final Value<int> downloadedSize;
  final Value<String> status;
  final Value<int> threadCount;
  final Value<double> speed;
  final Value<DateTime> dateAdded;
  final Value<DateTime?> dateCompleted;
  final Value<String?> category;
  final Value<int?> queueId;
  final Value<String?> errorMessage;
  final Value<int> retryCount;
  final Value<String> customHeaders;
  final Value<String?> proxyConfig;
  final Value<int> speedLimit;
  const DownloadItemsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.fileName = const Value.absent(),
    this.savePath = const Value.absent(),
    this.totalSize = const Value.absent(),
    this.downloadedSize = const Value.absent(),
    this.status = const Value.absent(),
    this.threadCount = const Value.absent(),
    this.speed = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.dateCompleted = const Value.absent(),
    this.category = const Value.absent(),
    this.queueId = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.customHeaders = const Value.absent(),
    this.proxyConfig = const Value.absent(),
    this.speedLimit = const Value.absent(),
  });
  DownloadItemsCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    required String fileName,
    required String savePath,
    this.totalSize = const Value.absent(),
    this.downloadedSize = const Value.absent(),
    this.status = const Value.absent(),
    this.threadCount = const Value.absent(),
    this.speed = const Value.absent(),
    required DateTime dateAdded,
    this.dateCompleted = const Value.absent(),
    this.category = const Value.absent(),
    this.queueId = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.customHeaders = const Value.absent(),
    this.proxyConfig = const Value.absent(),
    this.speedLimit = const Value.absent(),
  }) : url = Value(url),
       fileName = Value(fileName),
       savePath = Value(savePath),
       dateAdded = Value(dateAdded);
  static Insertable<DownloadItem> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? fileName,
    Expression<String>? savePath,
    Expression<int>? totalSize,
    Expression<int>? downloadedSize,
    Expression<String>? status,
    Expression<int>? threadCount,
    Expression<double>? speed,
    Expression<DateTime>? dateAdded,
    Expression<DateTime>? dateCompleted,
    Expression<String>? category,
    Expression<int>? queueId,
    Expression<String>? errorMessage,
    Expression<int>? retryCount,
    Expression<String>? customHeaders,
    Expression<String>? proxyConfig,
    Expression<int>? speedLimit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (fileName != null) 'file_name': fileName,
      if (savePath != null) 'save_path': savePath,
      if (totalSize != null) 'total_size': totalSize,
      if (downloadedSize != null) 'downloaded_size': downloadedSize,
      if (status != null) 'status': status,
      if (threadCount != null) 'thread_count': threadCount,
      if (speed != null) 'speed': speed,
      if (dateAdded != null) 'date_added': dateAdded,
      if (dateCompleted != null) 'date_completed': dateCompleted,
      if (category != null) 'category': category,
      if (queueId != null) 'queue_id': queueId,
      if (errorMessage != null) 'error_message': errorMessage,
      if (retryCount != null) 'retry_count': retryCount,
      if (customHeaders != null) 'custom_headers': customHeaders,
      if (proxyConfig != null) 'proxy_config': proxyConfig,
      if (speedLimit != null) 'speed_limit': speedLimit,
    });
  }

  DownloadItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? url,
    Value<String>? fileName,
    Value<String>? savePath,
    Value<int>? totalSize,
    Value<int>? downloadedSize,
    Value<String>? status,
    Value<int>? threadCount,
    Value<double>? speed,
    Value<DateTime>? dateAdded,
    Value<DateTime?>? dateCompleted,
    Value<String?>? category,
    Value<int?>? queueId,
    Value<String?>? errorMessage,
    Value<int>? retryCount,
    Value<String>? customHeaders,
    Value<String?>? proxyConfig,
    Value<int>? speedLimit,
  }) {
    return DownloadItemsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      savePath: savePath ?? this.savePath,
      totalSize: totalSize ?? this.totalSize,
      downloadedSize: downloadedSize ?? this.downloadedSize,
      status: status ?? this.status,
      threadCount: threadCount ?? this.threadCount,
      speed: speed ?? this.speed,
      dateAdded: dateAdded ?? this.dateAdded,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      category: category ?? this.category,
      queueId: queueId ?? this.queueId,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      customHeaders: customHeaders ?? this.customHeaders,
      proxyConfig: proxyConfig ?? this.proxyConfig,
      speedLimit: speedLimit ?? this.speedLimit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (savePath.present) {
      map['save_path'] = Variable<String>(savePath.value);
    }
    if (totalSize.present) {
      map['total_size'] = Variable<int>(totalSize.value);
    }
    if (downloadedSize.present) {
      map['downloaded_size'] = Variable<int>(downloadedSize.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (threadCount.present) {
      map['thread_count'] = Variable<int>(threadCount.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (dateCompleted.present) {
      map['date_completed'] = Variable<DateTime>(dateCompleted.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (queueId.present) {
      map['queue_id'] = Variable<int>(queueId.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (customHeaders.present) {
      map['custom_headers'] = Variable<String>(customHeaders.value);
    }
    if (proxyConfig.present) {
      map['proxy_config'] = Variable<String>(proxyConfig.value);
    }
    if (speedLimit.present) {
      map['speed_limit'] = Variable<int>(speedLimit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadItemsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('fileName: $fileName, ')
          ..write('savePath: $savePath, ')
          ..write('totalSize: $totalSize, ')
          ..write('downloadedSize: $downloadedSize, ')
          ..write('status: $status, ')
          ..write('threadCount: $threadCount, ')
          ..write('speed: $speed, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('dateCompleted: $dateCompleted, ')
          ..write('category: $category, ')
          ..write('queueId: $queueId, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('retryCount: $retryCount, ')
          ..write('customHeaders: $customHeaders, ')
          ..write('proxyConfig: $proxyConfig, ')
          ..write('speedLimit: $speedLimit')
          ..write(')'))
        .toString();
  }
}

class $DownloadSegmentsTable extends DownloadSegments
    with TableInfo<$DownloadSegmentsTable, DownloadSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadSegmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _downloadItemIdMeta = const VerificationMeta(
    'downloadItemId',
  );
  @override
  late final GeneratedColumn<int> downloadItemId = GeneratedColumn<int>(
    'download_item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES download_items (id)',
    ),
  );
  static const VerificationMeta _startByteMeta = const VerificationMeta(
    'startByte',
  );
  @override
  late final GeneratedColumn<int> startByte = GeneratedColumn<int>(
    'start_byte',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endByteMeta = const VerificationMeta(
    'endByte',
  );
  @override
  late final GeneratedColumn<int> endByte = GeneratedColumn<int>(
    'end_byte',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedBytesMeta = const VerificationMeta(
    'downloadedBytes',
  );
  @override
  late final GeneratedColumn<int> downloadedBytes = GeneratedColumn<int>(
    'downloaded_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _tempFilePathMeta = const VerificationMeta(
    'tempFilePath',
  );
  @override
  late final GeneratedColumn<String> tempFilePath = GeneratedColumn<String>(
    'temp_file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    downloadItemId,
    startByte,
    endByte,
    downloadedBytes,
    status,
    tempFilePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadSegment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('download_item_id')) {
      context.handle(
        _downloadItemIdMeta,
        downloadItemId.isAcceptableOrUnknown(
          data['download_item_id']!,
          _downloadItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadItemIdMeta);
    }
    if (data.containsKey('start_byte')) {
      context.handle(
        _startByteMeta,
        startByte.isAcceptableOrUnknown(data['start_byte']!, _startByteMeta),
      );
    } else if (isInserting) {
      context.missing(_startByteMeta);
    }
    if (data.containsKey('end_byte')) {
      context.handle(
        _endByteMeta,
        endByte.isAcceptableOrUnknown(data['end_byte']!, _endByteMeta),
      );
    } else if (isInserting) {
      context.missing(_endByteMeta);
    }
    if (data.containsKey('downloaded_bytes')) {
      context.handle(
        _downloadedBytesMeta,
        downloadedBytes.isAcceptableOrUnknown(
          data['downloaded_bytes']!,
          _downloadedBytesMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('temp_file_path')) {
      context.handle(
        _tempFilePathMeta,
        tempFilePath.isAcceptableOrUnknown(
          data['temp_file_path']!,
          _tempFilePathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadSegment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      downloadItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}download_item_id'],
      )!,
      startByte: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_byte'],
      )!,
      endByte: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_byte'],
      )!,
      downloadedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_bytes'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      tempFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}temp_file_path'],
      )!,
    );
  }

  @override
  $DownloadSegmentsTable createAlias(String alias) {
    return $DownloadSegmentsTable(attachedDatabase, alias);
  }
}

class DownloadSegment extends DataClass implements Insertable<DownloadSegment> {
  final int id;
  final int downloadItemId;
  final int startByte;
  final int endByte;
  final int downloadedBytes;
  final String status;
  final String tempFilePath;
  const DownloadSegment({
    required this.id,
    required this.downloadItemId,
    required this.startByte,
    required this.endByte,
    required this.downloadedBytes,
    required this.status,
    required this.tempFilePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['download_item_id'] = Variable<int>(downloadItemId);
    map['start_byte'] = Variable<int>(startByte);
    map['end_byte'] = Variable<int>(endByte);
    map['downloaded_bytes'] = Variable<int>(downloadedBytes);
    map['status'] = Variable<String>(status);
    map['temp_file_path'] = Variable<String>(tempFilePath);
    return map;
  }

  DownloadSegmentsCompanion toCompanion(bool nullToAbsent) {
    return DownloadSegmentsCompanion(
      id: Value(id),
      downloadItemId: Value(downloadItemId),
      startByte: Value(startByte),
      endByte: Value(endByte),
      downloadedBytes: Value(downloadedBytes),
      status: Value(status),
      tempFilePath: Value(tempFilePath),
    );
  }

  factory DownloadSegment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadSegment(
      id: serializer.fromJson<int>(json['id']),
      downloadItemId: serializer.fromJson<int>(json['downloadItemId']),
      startByte: serializer.fromJson<int>(json['startByte']),
      endByte: serializer.fromJson<int>(json['endByte']),
      downloadedBytes: serializer.fromJson<int>(json['downloadedBytes']),
      status: serializer.fromJson<String>(json['status']),
      tempFilePath: serializer.fromJson<String>(json['tempFilePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'downloadItemId': serializer.toJson<int>(downloadItemId),
      'startByte': serializer.toJson<int>(startByte),
      'endByte': serializer.toJson<int>(endByte),
      'downloadedBytes': serializer.toJson<int>(downloadedBytes),
      'status': serializer.toJson<String>(status),
      'tempFilePath': serializer.toJson<String>(tempFilePath),
    };
  }

  DownloadSegment copyWith({
    int? id,
    int? downloadItemId,
    int? startByte,
    int? endByte,
    int? downloadedBytes,
    String? status,
    String? tempFilePath,
  }) => DownloadSegment(
    id: id ?? this.id,
    downloadItemId: downloadItemId ?? this.downloadItemId,
    startByte: startByte ?? this.startByte,
    endByte: endByte ?? this.endByte,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    status: status ?? this.status,
    tempFilePath: tempFilePath ?? this.tempFilePath,
  );
  DownloadSegment copyWithCompanion(DownloadSegmentsCompanion data) {
    return DownloadSegment(
      id: data.id.present ? data.id.value : this.id,
      downloadItemId: data.downloadItemId.present
          ? data.downloadItemId.value
          : this.downloadItemId,
      startByte: data.startByte.present ? data.startByte.value : this.startByte,
      endByte: data.endByte.present ? data.endByte.value : this.endByte,
      downloadedBytes: data.downloadedBytes.present
          ? data.downloadedBytes.value
          : this.downloadedBytes,
      status: data.status.present ? data.status.value : this.status,
      tempFilePath: data.tempFilePath.present
          ? data.tempFilePath.value
          : this.tempFilePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadSegment(')
          ..write('id: $id, ')
          ..write('downloadItemId: $downloadItemId, ')
          ..write('startByte: $startByte, ')
          ..write('endByte: $endByte, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('status: $status, ')
          ..write('tempFilePath: $tempFilePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    downloadItemId,
    startByte,
    endByte,
    downloadedBytes,
    status,
    tempFilePath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadSegment &&
          other.id == this.id &&
          other.downloadItemId == this.downloadItemId &&
          other.startByte == this.startByte &&
          other.endByte == this.endByte &&
          other.downloadedBytes == this.downloadedBytes &&
          other.status == this.status &&
          other.tempFilePath == this.tempFilePath);
}

class DownloadSegmentsCompanion extends UpdateCompanion<DownloadSegment> {
  final Value<int> id;
  final Value<int> downloadItemId;
  final Value<int> startByte;
  final Value<int> endByte;
  final Value<int> downloadedBytes;
  final Value<String> status;
  final Value<String> tempFilePath;
  const DownloadSegmentsCompanion({
    this.id = const Value.absent(),
    this.downloadItemId = const Value.absent(),
    this.startByte = const Value.absent(),
    this.endByte = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.status = const Value.absent(),
    this.tempFilePath = const Value.absent(),
  });
  DownloadSegmentsCompanion.insert({
    this.id = const Value.absent(),
    required int downloadItemId,
    required int startByte,
    required int endByte,
    this.downloadedBytes = const Value.absent(),
    this.status = const Value.absent(),
    this.tempFilePath = const Value.absent(),
  }) : downloadItemId = Value(downloadItemId),
       startByte = Value(startByte),
       endByte = Value(endByte);
  static Insertable<DownloadSegment> custom({
    Expression<int>? id,
    Expression<int>? downloadItemId,
    Expression<int>? startByte,
    Expression<int>? endByte,
    Expression<int>? downloadedBytes,
    Expression<String>? status,
    Expression<String>? tempFilePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (downloadItemId != null) 'download_item_id': downloadItemId,
      if (startByte != null) 'start_byte': startByte,
      if (endByte != null) 'end_byte': endByte,
      if (downloadedBytes != null) 'downloaded_bytes': downloadedBytes,
      if (status != null) 'status': status,
      if (tempFilePath != null) 'temp_file_path': tempFilePath,
    });
  }

  DownloadSegmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? downloadItemId,
    Value<int>? startByte,
    Value<int>? endByte,
    Value<int>? downloadedBytes,
    Value<String>? status,
    Value<String>? tempFilePath,
  }) {
    return DownloadSegmentsCompanion(
      id: id ?? this.id,
      downloadItemId: downloadItemId ?? this.downloadItemId,
      startByte: startByte ?? this.startByte,
      endByte: endByte ?? this.endByte,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      tempFilePath: tempFilePath ?? this.tempFilePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (downloadItemId.present) {
      map['download_item_id'] = Variable<int>(downloadItemId.value);
    }
    if (startByte.present) {
      map['start_byte'] = Variable<int>(startByte.value);
    }
    if (endByte.present) {
      map['end_byte'] = Variable<int>(endByte.value);
    }
    if (downloadedBytes.present) {
      map['downloaded_bytes'] = Variable<int>(downloadedBytes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (tempFilePath.present) {
      map['temp_file_path'] = Variable<String>(tempFilePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('downloadItemId: $downloadItemId, ')
          ..write('startByte: $startByte, ')
          ..write('endByte: $endByte, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('status: $status, ')
          ..write('tempFilePath: $tempFilePath')
          ..write(')'))
        .toString();
  }
}

class $DownloadCategoriesTable extends DownloadCategories
    with TableInfo<$DownloadCategoriesTable, DownloadCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadCategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileExtensionsMeta = const VerificationMeta(
    'fileExtensions',
  );
  @override
  late final GeneratedColumn<String> fileExtensions = GeneratedColumn<String>(
    'file_extensions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultSavePathMeta = const VerificationMeta(
    'defaultSavePath',
  );
  @override
  late final GeneratedColumn<String> defaultSavePath = GeneratedColumn<String>(
    'default_save_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('folder'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    fileExtensions,
    defaultSavePath,
    icon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('file_extensions')) {
      context.handle(
        _fileExtensionsMeta,
        fileExtensions.isAcceptableOrUnknown(
          data['file_extensions']!,
          _fileExtensionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileExtensionsMeta);
    }
    if (data.containsKey('default_save_path')) {
      context.handle(
        _defaultSavePathMeta,
        defaultSavePath.isAcceptableOrUnknown(
          data['default_save_path']!,
          _defaultSavePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultSavePathMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fileExtensions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_extensions'],
      )!,
      defaultSavePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_save_path'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
    );
  }

  @override
  $DownloadCategoriesTable createAlias(String alias) {
    return $DownloadCategoriesTable(attachedDatabase, alias);
  }
}

class DownloadCategory extends DataClass
    implements Insertable<DownloadCategory> {
  final int id;
  final String name;
  final String fileExtensions;
  final String defaultSavePath;
  final String icon;
  const DownloadCategory({
    required this.id,
    required this.name,
    required this.fileExtensions,
    required this.defaultSavePath,
    required this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['file_extensions'] = Variable<String>(fileExtensions);
    map['default_save_path'] = Variable<String>(defaultSavePath);
    map['icon'] = Variable<String>(icon);
    return map;
  }

  DownloadCategoriesCompanion toCompanion(bool nullToAbsent) {
    return DownloadCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      fileExtensions: Value(fileExtensions),
      defaultSavePath: Value(defaultSavePath),
      icon: Value(icon),
    );
  }

  factory DownloadCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fileExtensions: serializer.fromJson<String>(json['fileExtensions']),
      defaultSavePath: serializer.fromJson<String>(json['defaultSavePath']),
      icon: serializer.fromJson<String>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'fileExtensions': serializer.toJson<String>(fileExtensions),
      'defaultSavePath': serializer.toJson<String>(defaultSavePath),
      'icon': serializer.toJson<String>(icon),
    };
  }

  DownloadCategory copyWith({
    int? id,
    String? name,
    String? fileExtensions,
    String? defaultSavePath,
    String? icon,
  }) => DownloadCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    fileExtensions: fileExtensions ?? this.fileExtensions,
    defaultSavePath: defaultSavePath ?? this.defaultSavePath,
    icon: icon ?? this.icon,
  );
  DownloadCategory copyWithCompanion(DownloadCategoriesCompanion data) {
    return DownloadCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fileExtensions: data.fileExtensions.present
          ? data.fileExtensions.value
          : this.fileExtensions,
      defaultSavePath: data.defaultSavePath.present
          ? data.defaultSavePath.value
          : this.defaultSavePath,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fileExtensions: $fileExtensions, ')
          ..write('defaultSavePath: $defaultSavePath, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, fileExtensions, defaultSavePath, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.fileExtensions == this.fileExtensions &&
          other.defaultSavePath == this.defaultSavePath &&
          other.icon == this.icon);
}

class DownloadCategoriesCompanion extends UpdateCompanion<DownloadCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> fileExtensions;
  final Value<String> defaultSavePath;
  final Value<String> icon;
  const DownloadCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fileExtensions = const Value.absent(),
    this.defaultSavePath = const Value.absent(),
    this.icon = const Value.absent(),
  });
  DownloadCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String fileExtensions,
    required String defaultSavePath,
    this.icon = const Value.absent(),
  }) : name = Value(name),
       fileExtensions = Value(fileExtensions),
       defaultSavePath = Value(defaultSavePath);
  static Insertable<DownloadCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? fileExtensions,
    Expression<String>? defaultSavePath,
    Expression<String>? icon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fileExtensions != null) 'file_extensions': fileExtensions,
      if (defaultSavePath != null) 'default_save_path': defaultSavePath,
      if (icon != null) 'icon': icon,
    });
  }

  DownloadCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? fileExtensions,
    Value<String>? defaultSavePath,
    Value<String>? icon,
  }) {
    return DownloadCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fileExtensions: fileExtensions ?? this.fileExtensions,
      defaultSavePath: defaultSavePath ?? this.defaultSavePath,
      icon: icon ?? this.icon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fileExtensions.present) {
      map['file_extensions'] = Variable<String>(fileExtensions.value);
    }
    if (defaultSavePath.present) {
      map['default_save_path'] = Variable<String>(defaultSavePath.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fileExtensions: $fileExtensions, ')
          ..write('defaultSavePath: $defaultSavePath, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
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
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final String key;
  final String value;
  const AppSettingsTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingsTableData copyWith({String? key, String? value}) =>
      AppSettingsTableData(key: key ?? this.key, value: value ?? this.value);
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DownloadQueuesTable downloadQueues = $DownloadQueuesTable(this);
  late final $DownloadItemsTable downloadItems = $DownloadItemsTable(this);
  late final $DownloadSegmentsTable downloadSegments = $DownloadSegmentsTable(
    this,
  );
  late final $DownloadCategoriesTable downloadCategories =
      $DownloadCategoriesTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    downloadQueues,
    downloadItems,
    downloadSegments,
    downloadCategories,
    appSettingsTable,
  ];
}

typedef $$DownloadQueuesTableCreateCompanionBuilder =
    DownloadQueuesCompanion Function({
      Value<int> id,
      required String name,
      Value<int> maxConcurrent,
      Value<String?> scheduleConfig,
      Value<String> postAction,
      Value<String?> postActionProgram,
      Value<bool> isActive,
    });
typedef $$DownloadQueuesTableUpdateCompanionBuilder =
    DownloadQueuesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> maxConcurrent,
      Value<String?> scheduleConfig,
      Value<String> postAction,
      Value<String?> postActionProgram,
      Value<bool> isActive,
    });

final class $$DownloadQueuesTableReferences
    extends BaseReferences<_$AppDatabase, $DownloadQueuesTable, DownloadQueue> {
  $$DownloadQueuesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$DownloadItemsTable, List<DownloadItem>>
  _downloadItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.downloadItems,
    aliasName: $_aliasNameGenerator(
      db.downloadQueues.id,
      db.downloadItems.queueId,
    ),
  );

  $$DownloadItemsTableProcessedTableManager get downloadItemsRefs {
    final manager = $$DownloadItemsTableTableManager(
      $_db,
      $_db.downloadItems,
    ).filter((f) => f.queueId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_downloadItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DownloadQueuesTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadQueuesTable> {
  $$DownloadQueuesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxConcurrent => $composableBuilder(
    column: $table.maxConcurrent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleConfig => $composableBuilder(
    column: $table.scheduleConfig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postAction => $composableBuilder(
    column: $table.postAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postActionProgram => $composableBuilder(
    column: $table.postActionProgram,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> downloadItemsRefs(
    Expression<bool> Function($$DownloadItemsTableFilterComposer f) f,
  ) {
    final $$DownloadItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadItems,
      getReferencedColumn: (t) => t.queueId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadItemsTableFilterComposer(
            $db: $db,
            $table: $db.downloadItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DownloadQueuesTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadQueuesTable> {
  $$DownloadQueuesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxConcurrent => $composableBuilder(
    column: $table.maxConcurrent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleConfig => $composableBuilder(
    column: $table.scheduleConfig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postAction => $composableBuilder(
    column: $table.postAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postActionProgram => $composableBuilder(
    column: $table.postActionProgram,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadQueuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadQueuesTable> {
  $$DownloadQueuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get maxConcurrent => $composableBuilder(
    column: $table.maxConcurrent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleConfig => $composableBuilder(
    column: $table.scheduleConfig,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postAction => $composableBuilder(
    column: $table.postAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postActionProgram => $composableBuilder(
    column: $table.postActionProgram,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> downloadItemsRefs<T extends Object>(
    Expression<T> Function($$DownloadItemsTableAnnotationComposer a) f,
  ) {
    final $$DownloadItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadItems,
      getReferencedColumn: (t) => t.queueId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.downloadItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DownloadQueuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadQueuesTable,
          DownloadQueue,
          $$DownloadQueuesTableFilterComposer,
          $$DownloadQueuesTableOrderingComposer,
          $$DownloadQueuesTableAnnotationComposer,
          $$DownloadQueuesTableCreateCompanionBuilder,
          $$DownloadQueuesTableUpdateCompanionBuilder,
          (DownloadQueue, $$DownloadQueuesTableReferences),
          DownloadQueue,
          PrefetchHooks Function({bool downloadItemsRefs})
        > {
  $$DownloadQueuesTableTableManager(
    _$AppDatabase db,
    $DownloadQueuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadQueuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadQueuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadQueuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> maxConcurrent = const Value.absent(),
                Value<String?> scheduleConfig = const Value.absent(),
                Value<String> postAction = const Value.absent(),
                Value<String?> postActionProgram = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => DownloadQueuesCompanion(
                id: id,
                name: name,
                maxConcurrent: maxConcurrent,
                scheduleConfig: scheduleConfig,
                postAction: postAction,
                postActionProgram: postActionProgram,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> maxConcurrent = const Value.absent(),
                Value<String?> scheduleConfig = const Value.absent(),
                Value<String> postAction = const Value.absent(),
                Value<String?> postActionProgram = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => DownloadQueuesCompanion.insert(
                id: id,
                name: name,
                maxConcurrent: maxConcurrent,
                scheduleConfig: scheduleConfig,
                postAction: postAction,
                postActionProgram: postActionProgram,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DownloadQueuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({downloadItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (downloadItemsRefs) db.downloadItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (downloadItemsRefs)
                    await $_getPrefetchedData<
                      DownloadQueue,
                      $DownloadQueuesTable,
                      DownloadItem
                    >(
                      currentTable: table,
                      referencedTable: $$DownloadQueuesTableReferences
                          ._downloadItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DownloadQueuesTableReferences(
                            db,
                            table,
                            p0,
                          ).downloadItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.queueId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DownloadQueuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadQueuesTable,
      DownloadQueue,
      $$DownloadQueuesTableFilterComposer,
      $$DownloadQueuesTableOrderingComposer,
      $$DownloadQueuesTableAnnotationComposer,
      $$DownloadQueuesTableCreateCompanionBuilder,
      $$DownloadQueuesTableUpdateCompanionBuilder,
      (DownloadQueue, $$DownloadQueuesTableReferences),
      DownloadQueue,
      PrefetchHooks Function({bool downloadItemsRefs})
    >;
typedef $$DownloadItemsTableCreateCompanionBuilder =
    DownloadItemsCompanion Function({
      Value<int> id,
      required String url,
      required String fileName,
      required String savePath,
      Value<int> totalSize,
      Value<int> downloadedSize,
      Value<String> status,
      Value<int> threadCount,
      Value<double> speed,
      required DateTime dateAdded,
      Value<DateTime?> dateCompleted,
      Value<String?> category,
      Value<int?> queueId,
      Value<String?> errorMessage,
      Value<int> retryCount,
      Value<String> customHeaders,
      Value<String?> proxyConfig,
      Value<int> speedLimit,
    });
typedef $$DownloadItemsTableUpdateCompanionBuilder =
    DownloadItemsCompanion Function({
      Value<int> id,
      Value<String> url,
      Value<String> fileName,
      Value<String> savePath,
      Value<int> totalSize,
      Value<int> downloadedSize,
      Value<String> status,
      Value<int> threadCount,
      Value<double> speed,
      Value<DateTime> dateAdded,
      Value<DateTime?> dateCompleted,
      Value<String?> category,
      Value<int?> queueId,
      Value<String?> errorMessage,
      Value<int> retryCount,
      Value<String> customHeaders,
      Value<String?> proxyConfig,
      Value<int> speedLimit,
    });

final class $$DownloadItemsTableReferences
    extends BaseReferences<_$AppDatabase, $DownloadItemsTable, DownloadItem> {
  $$DownloadItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DownloadQueuesTable _queueIdTable(_$AppDatabase db) =>
      db.downloadQueues.createAlias(
        $_aliasNameGenerator(db.downloadItems.queueId, db.downloadQueues.id),
      );

  $$DownloadQueuesTableProcessedTableManager? get queueId {
    final $_column = $_itemColumn<int>('queue_id');
    if ($_column == null) return null;
    final manager = $$DownloadQueuesTableTableManager(
      $_db,
      $_db.downloadQueues,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_queueIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DownloadSegmentsTable, List<DownloadSegment>>
  _downloadSegmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.downloadSegments,
    aliasName: $_aliasNameGenerator(
      db.downloadItems.id,
      db.downloadSegments.downloadItemId,
    ),
  );

  $$DownloadSegmentsTableProcessedTableManager get downloadSegmentsRefs {
    final manager = $$DownloadSegmentsTableTableManager(
      $_db,
      $_db.downloadSegments,
    ).filter((f) => f.downloadItemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _downloadSegmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DownloadItemsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadItemsTable> {
  $$DownloadItemsTableFilterComposer({
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

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get savePath => $composableBuilder(
    column: $table.savePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSize => $composableBuilder(
    column: $table.totalSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedSize => $composableBuilder(
    column: $table.downloadedSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get threadCount => $composableBuilder(
    column: $table.threadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCompleted => $composableBuilder(
    column: $table.dateCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customHeaders => $composableBuilder(
    column: $table.customHeaders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proxyConfig => $composableBuilder(
    column: $table.proxyConfig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speedLimit => $composableBuilder(
    column: $table.speedLimit,
    builder: (column) => ColumnFilters(column),
  );

  $$DownloadQueuesTableFilterComposer get queueId {
    final $$DownloadQueuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.queueId,
      referencedTable: $db.downloadQueues,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadQueuesTableFilterComposer(
            $db: $db,
            $table: $db.downloadQueues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> downloadSegmentsRefs(
    Expression<bool> Function($$DownloadSegmentsTableFilterComposer f) f,
  ) {
    final $$DownloadSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadSegments,
      getReferencedColumn: (t) => t.downloadItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.downloadSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DownloadItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadItemsTable> {
  $$DownloadItemsTableOrderingComposer({
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

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get savePath => $composableBuilder(
    column: $table.savePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSize => $composableBuilder(
    column: $table.totalSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedSize => $composableBuilder(
    column: $table.downloadedSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get threadCount => $composableBuilder(
    column: $table.threadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCompleted => $composableBuilder(
    column: $table.dateCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customHeaders => $composableBuilder(
    column: $table.customHeaders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proxyConfig => $composableBuilder(
    column: $table.proxyConfig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speedLimit => $composableBuilder(
    column: $table.speedLimit,
    builder: (column) => ColumnOrderings(column),
  );

  $$DownloadQueuesTableOrderingComposer get queueId {
    final $$DownloadQueuesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.queueId,
      referencedTable: $db.downloadQueues,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadQueuesTableOrderingComposer(
            $db: $db,
            $table: $db.downloadQueues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadItemsTable> {
  $$DownloadItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get savePath =>
      $composableBuilder(column: $table.savePath, builder: (column) => column);

  GeneratedColumn<int> get totalSize =>
      $composableBuilder(column: $table.totalSize, builder: (column) => column);

  GeneratedColumn<int> get downloadedSize => $composableBuilder(
    column: $table.downloadedSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get threadCount => $composableBuilder(
    column: $table.threadCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCompleted => $composableBuilder(
    column: $table.dateCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customHeaders => $composableBuilder(
    column: $table.customHeaders,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proxyConfig => $composableBuilder(
    column: $table.proxyConfig,
    builder: (column) => column,
  );

  GeneratedColumn<int> get speedLimit => $composableBuilder(
    column: $table.speedLimit,
    builder: (column) => column,
  );

  $$DownloadQueuesTableAnnotationComposer get queueId {
    final $$DownloadQueuesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.queueId,
      referencedTable: $db.downloadQueues,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadQueuesTableAnnotationComposer(
            $db: $db,
            $table: $db.downloadQueues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> downloadSegmentsRefs<T extends Object>(
    Expression<T> Function($$DownloadSegmentsTableAnnotationComposer a) f,
  ) {
    final $$DownloadSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadSegments,
      getReferencedColumn: (t) => t.downloadItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.downloadSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DownloadItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadItemsTable,
          DownloadItem,
          $$DownloadItemsTableFilterComposer,
          $$DownloadItemsTableOrderingComposer,
          $$DownloadItemsTableAnnotationComposer,
          $$DownloadItemsTableCreateCompanionBuilder,
          $$DownloadItemsTableUpdateCompanionBuilder,
          (DownloadItem, $$DownloadItemsTableReferences),
          DownloadItem,
          PrefetchHooks Function({bool queueId, bool downloadSegmentsRefs})
        > {
  $$DownloadItemsTableTableManager(_$AppDatabase db, $DownloadItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> savePath = const Value.absent(),
                Value<int> totalSize = const Value.absent(),
                Value<int> downloadedSize = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> threadCount = const Value.absent(),
                Value<double> speed = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<DateTime?> dateCompleted = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int?> queueId = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String> customHeaders = const Value.absent(),
                Value<String?> proxyConfig = const Value.absent(),
                Value<int> speedLimit = const Value.absent(),
              }) => DownloadItemsCompanion(
                id: id,
                url: url,
                fileName: fileName,
                savePath: savePath,
                totalSize: totalSize,
                downloadedSize: downloadedSize,
                status: status,
                threadCount: threadCount,
                speed: speed,
                dateAdded: dateAdded,
                dateCompleted: dateCompleted,
                category: category,
                queueId: queueId,
                errorMessage: errorMessage,
                retryCount: retryCount,
                customHeaders: customHeaders,
                proxyConfig: proxyConfig,
                speedLimit: speedLimit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String url,
                required String fileName,
                required String savePath,
                Value<int> totalSize = const Value.absent(),
                Value<int> downloadedSize = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> threadCount = const Value.absent(),
                Value<double> speed = const Value.absent(),
                required DateTime dateAdded,
                Value<DateTime?> dateCompleted = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int?> queueId = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String> customHeaders = const Value.absent(),
                Value<String?> proxyConfig = const Value.absent(),
                Value<int> speedLimit = const Value.absent(),
              }) => DownloadItemsCompanion.insert(
                id: id,
                url: url,
                fileName: fileName,
                savePath: savePath,
                totalSize: totalSize,
                downloadedSize: downloadedSize,
                status: status,
                threadCount: threadCount,
                speed: speed,
                dateAdded: dateAdded,
                dateCompleted: dateCompleted,
                category: category,
                queueId: queueId,
                errorMessage: errorMessage,
                retryCount: retryCount,
                customHeaders: customHeaders,
                proxyConfig: proxyConfig,
                speedLimit: speedLimit,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DownloadItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({queueId = false, downloadSegmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (downloadSegmentsRefs) db.downloadSegments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (queueId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.queueId,
                                    referencedTable:
                                        $$DownloadItemsTableReferences
                                            ._queueIdTable(db),
                                    referencedColumn:
                                        $$DownloadItemsTableReferences
                                            ._queueIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (downloadSegmentsRefs)
                        await $_getPrefetchedData<
                          DownloadItem,
                          $DownloadItemsTable,
                          DownloadSegment
                        >(
                          currentTable: table,
                          referencedTable: $$DownloadItemsTableReferences
                              ._downloadSegmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DownloadItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).downloadSegmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.downloadItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DownloadItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadItemsTable,
      DownloadItem,
      $$DownloadItemsTableFilterComposer,
      $$DownloadItemsTableOrderingComposer,
      $$DownloadItemsTableAnnotationComposer,
      $$DownloadItemsTableCreateCompanionBuilder,
      $$DownloadItemsTableUpdateCompanionBuilder,
      (DownloadItem, $$DownloadItemsTableReferences),
      DownloadItem,
      PrefetchHooks Function({bool queueId, bool downloadSegmentsRefs})
    >;
typedef $$DownloadSegmentsTableCreateCompanionBuilder =
    DownloadSegmentsCompanion Function({
      Value<int> id,
      required int downloadItemId,
      required int startByte,
      required int endByte,
      Value<int> downloadedBytes,
      Value<String> status,
      Value<String> tempFilePath,
    });
typedef $$DownloadSegmentsTableUpdateCompanionBuilder =
    DownloadSegmentsCompanion Function({
      Value<int> id,
      Value<int> downloadItemId,
      Value<int> startByte,
      Value<int> endByte,
      Value<int> downloadedBytes,
      Value<String> status,
      Value<String> tempFilePath,
    });

final class $$DownloadSegmentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $DownloadSegmentsTable, DownloadSegment> {
  $$DownloadSegmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DownloadItemsTable _downloadItemIdTable(_$AppDatabase db) =>
      db.downloadItems.createAlias(
        $_aliasNameGenerator(
          db.downloadSegments.downloadItemId,
          db.downloadItems.id,
        ),
      );

  $$DownloadItemsTableProcessedTableManager get downloadItemId {
    final $_column = $_itemColumn<int>('download_item_id')!;

    final manager = $$DownloadItemsTableTableManager(
      $_db,
      $_db.downloadItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_downloadItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DownloadSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadSegmentsTable> {
  $$DownloadSegmentsTableFilterComposer({
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

  ColumnFilters<int> get startByte => $composableBuilder(
    column: $table.startByte,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endByte => $composableBuilder(
    column: $table.endByte,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tempFilePath => $composableBuilder(
    column: $table.tempFilePath,
    builder: (column) => ColumnFilters(column),
  );

  $$DownloadItemsTableFilterComposer get downloadItemId {
    final $$DownloadItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.downloadItemId,
      referencedTable: $db.downloadItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadItemsTableFilterComposer(
            $db: $db,
            $table: $db.downloadItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadSegmentsTable> {
  $$DownloadSegmentsTableOrderingComposer({
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

  ColumnOrderings<int> get startByte => $composableBuilder(
    column: $table.startByte,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endByte => $composableBuilder(
    column: $table.endByte,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tempFilePath => $composableBuilder(
    column: $table.tempFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  $$DownloadItemsTableOrderingComposer get downloadItemId {
    final $$DownloadItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.downloadItemId,
      referencedTable: $db.downloadItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadItemsTableOrderingComposer(
            $db: $db,
            $table: $db.downloadItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadSegmentsTable> {
  $$DownloadSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startByte =>
      $composableBuilder(column: $table.startByte, builder: (column) => column);

  GeneratedColumn<int> get endByte =>
      $composableBuilder(column: $table.endByte, builder: (column) => column);

  GeneratedColumn<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get tempFilePath => $composableBuilder(
    column: $table.tempFilePath,
    builder: (column) => column,
  );

  $$DownloadItemsTableAnnotationComposer get downloadItemId {
    final $$DownloadItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.downloadItemId,
      referencedTable: $db.downloadItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.downloadItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadSegmentsTable,
          DownloadSegment,
          $$DownloadSegmentsTableFilterComposer,
          $$DownloadSegmentsTableOrderingComposer,
          $$DownloadSegmentsTableAnnotationComposer,
          $$DownloadSegmentsTableCreateCompanionBuilder,
          $$DownloadSegmentsTableUpdateCompanionBuilder,
          (DownloadSegment, $$DownloadSegmentsTableReferences),
          DownloadSegment,
          PrefetchHooks Function({bool downloadItemId})
        > {
  $$DownloadSegmentsTableTableManager(
    _$AppDatabase db,
    $DownloadSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadSegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> downloadItemId = const Value.absent(),
                Value<int> startByte = const Value.absent(),
                Value<int> endByte = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> tempFilePath = const Value.absent(),
              }) => DownloadSegmentsCompanion(
                id: id,
                downloadItemId: downloadItemId,
                startByte: startByte,
                endByte: endByte,
                downloadedBytes: downloadedBytes,
                status: status,
                tempFilePath: tempFilePath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int downloadItemId,
                required int startByte,
                required int endByte,
                Value<int> downloadedBytes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> tempFilePath = const Value.absent(),
              }) => DownloadSegmentsCompanion.insert(
                id: id,
                downloadItemId: downloadItemId,
                startByte: startByte,
                endByte: endByte,
                downloadedBytes: downloadedBytes,
                status: status,
                tempFilePath: tempFilePath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DownloadSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({downloadItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (downloadItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.downloadItemId,
                                referencedTable:
                                    $$DownloadSegmentsTableReferences
                                        ._downloadItemIdTable(db),
                                referencedColumn:
                                    $$DownloadSegmentsTableReferences
                                        ._downloadItemIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DownloadSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadSegmentsTable,
      DownloadSegment,
      $$DownloadSegmentsTableFilterComposer,
      $$DownloadSegmentsTableOrderingComposer,
      $$DownloadSegmentsTableAnnotationComposer,
      $$DownloadSegmentsTableCreateCompanionBuilder,
      $$DownloadSegmentsTableUpdateCompanionBuilder,
      (DownloadSegment, $$DownloadSegmentsTableReferences),
      DownloadSegment,
      PrefetchHooks Function({bool downloadItemId})
    >;
typedef $$DownloadCategoriesTableCreateCompanionBuilder =
    DownloadCategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String fileExtensions,
      required String defaultSavePath,
      Value<String> icon,
    });
typedef $$DownloadCategoriesTableUpdateCompanionBuilder =
    DownloadCategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> fileExtensions,
      Value<String> defaultSavePath,
      Value<String> icon,
    });

class $$DownloadCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadCategoriesTable> {
  $$DownloadCategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileExtensions => $composableBuilder(
    column: $table.fileExtensions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultSavePath => $composableBuilder(
    column: $table.defaultSavePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadCategoriesTable> {
  $$DownloadCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileExtensions => $composableBuilder(
    column: $table.fileExtensions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultSavePath => $composableBuilder(
    column: $table.defaultSavePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadCategoriesTable> {
  $$DownloadCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fileExtensions => $composableBuilder(
    column: $table.fileExtensions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultSavePath => $composableBuilder(
    column: $table.defaultSavePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$DownloadCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadCategoriesTable,
          DownloadCategory,
          $$DownloadCategoriesTableFilterComposer,
          $$DownloadCategoriesTableOrderingComposer,
          $$DownloadCategoriesTableAnnotationComposer,
          $$DownloadCategoriesTableCreateCompanionBuilder,
          $$DownloadCategoriesTableUpdateCompanionBuilder,
          (
            DownloadCategory,
            BaseReferences<
              _$AppDatabase,
              $DownloadCategoriesTable,
              DownloadCategory
            >,
          ),
          DownloadCategory,
          PrefetchHooks Function()
        > {
  $$DownloadCategoriesTableTableManager(
    _$AppDatabase db,
    $DownloadCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> fileExtensions = const Value.absent(),
                Value<String> defaultSavePath = const Value.absent(),
                Value<String> icon = const Value.absent(),
              }) => DownloadCategoriesCompanion(
                id: id,
                name: name,
                fileExtensions: fileExtensions,
                defaultSavePath: defaultSavePath,
                icon: icon,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String fileExtensions,
                required String defaultSavePath,
                Value<String> icon = const Value.absent(),
              }) => DownloadCategoriesCompanion.insert(
                id: id,
                name: name,
                fileExtensions: fileExtensions,
                defaultSavePath: defaultSavePath,
                icon: icon,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadCategoriesTable,
      DownloadCategory,
      $$DownloadCategoriesTableFilterComposer,
      $$DownloadCategoriesTableOrderingComposer,
      $$DownloadCategoriesTableAnnotationComposer,
      $$DownloadCategoriesTableCreateCompanionBuilder,
      $$DownloadCategoriesTableUpdateCompanionBuilder,
      (
        DownloadCategory,
        BaseReferences<
          _$AppDatabase,
          $DownloadCategoriesTable,
          DownloadCategory
        >,
      ),
      DownloadCategory,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsTableTable,
              AppSettingsTableData
            >,
          ),
          AppSettingsTableData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSettingsTableData,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData
        >,
      ),
      AppSettingsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DownloadQueuesTableTableManager get downloadQueues =>
      $$DownloadQueuesTableTableManager(_db, _db.downloadQueues);
  $$DownloadItemsTableTableManager get downloadItems =>
      $$DownloadItemsTableTableManager(_db, _db.downloadItems);
  $$DownloadSegmentsTableTableManager get downloadSegments =>
      $$DownloadSegmentsTableTableManager(_db, _db.downloadSegments);
  $$DownloadCategoriesTableTableManager get downloadCategories =>
      $$DownloadCategoriesTableTableManager(_db, _db.downloadCategories);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
}
