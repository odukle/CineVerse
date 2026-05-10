// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WatchlistItemsTableTable extends WatchlistItemsTable
    with TableInfo<$WatchlistItemsTableTable, WatchlistItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchlistItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posterPathMeta = const VerificationMeta(
    'posterPath',
  );
  @override
  late final GeneratedColumn<String> posterPath = GeneratedColumn<String>(
    'poster_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseDateMeta = const VerificationMeta(
    'releaseDate',
  );
  @override
  late final GeneratedColumn<String> releaseDate = GeneratedColumn<String>(
    'release_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GlobalMediaType, int> mediaType =
      GeneratedColumn<int>(
        'media_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<GlobalMediaType>(
        $WatchlistItemsTableTable.$convertermediaType,
      );
  static const VerificationMeta _addedDateMeta = const VerificationMeta(
    'addedDate',
  );
  @override
  late final GeneratedColumn<DateTime> addedDate = GeneratedColumn<DateTime>(
    'added_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voteAverageMeta = const VerificationMeta(
    'voteAverage',
  );
  @override
  late final GeneratedColumn<double> voteAverage = GeneratedColumn<double>(
    'vote_average',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    posterPath,
    releaseDate,
    mediaType,
    addedDate,
    voteAverage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watchlist_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchlistItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('poster_path')) {
      context.handle(
        _posterPathMeta,
        posterPath.isAcceptableOrUnknown(data['poster_path']!, _posterPathMeta),
      );
    }
    if (data.containsKey('release_date')) {
      context.handle(
        _releaseDateMeta,
        releaseDate.isAcceptableOrUnknown(
          data['release_date']!,
          _releaseDateMeta,
        ),
      );
    }
    if (data.containsKey('added_date')) {
      context.handle(
        _addedDateMeta,
        addedDate.isAcceptableOrUnknown(data['added_date']!, _addedDateMeta),
      );
    } else if (isInserting) {
      context.missing(_addedDateMeta);
    }
    if (data.containsKey('vote_average')) {
      context.handle(
        _voteAverageMeta,
        voteAverage.isAcceptableOrUnknown(
          data['vote_average']!,
          _voteAverageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchlistItemsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchlistItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      posterPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_path'],
      ),
      releaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_date'],
      ),
      mediaType: $WatchlistItemsTableTable.$convertermediaType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}media_type'],
        )!,
      ),
      addedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_date'],
      )!,
      voteAverage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vote_average'],
      ),
    );
  }

  @override
  $WatchlistItemsTableTable createAlias(String alias) {
    return $WatchlistItemsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GlobalMediaType, int, int> $convertermediaType =
      const EnumIndexConverter<GlobalMediaType>(GlobalMediaType.values);
}

class WatchlistItemsTableData extends DataClass
    implements Insertable<WatchlistItemsTableData> {
  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final GlobalMediaType mediaType;
  final DateTime addedDate;
  final double? voteAverage;
  const WatchlistItemsTableData({
    required this.id,
    required this.title,
    this.posterPath,
    this.releaseDate,
    required this.mediaType,
    required this.addedDate,
    this.voteAverage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || posterPath != null) {
      map['poster_path'] = Variable<String>(posterPath);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<String>(releaseDate);
    }
    {
      map['media_type'] = Variable<int>(
        $WatchlistItemsTableTable.$convertermediaType.toSql(mediaType),
      );
    }
    map['added_date'] = Variable<DateTime>(addedDate);
    if (!nullToAbsent || voteAverage != null) {
      map['vote_average'] = Variable<double>(voteAverage);
    }
    return map;
  }

  WatchlistItemsTableCompanion toCompanion(bool nullToAbsent) {
    return WatchlistItemsTableCompanion(
      id: Value(id),
      title: Value(title),
      posterPath: posterPath == null && nullToAbsent
          ? const Value.absent()
          : Value(posterPath),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
      mediaType: Value(mediaType),
      addedDate: Value(addedDate),
      voteAverage: voteAverage == null && nullToAbsent
          ? const Value.absent()
          : Value(voteAverage),
    );
  }

  factory WatchlistItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchlistItemsTableData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      posterPath: serializer.fromJson<String?>(json['posterPath']),
      releaseDate: serializer.fromJson<String?>(json['releaseDate']),
      mediaType: $WatchlistItemsTableTable.$convertermediaType.fromJson(
        serializer.fromJson<int>(json['mediaType']),
      ),
      addedDate: serializer.fromJson<DateTime>(json['addedDate']),
      voteAverage: serializer.fromJson<double?>(json['voteAverage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'posterPath': serializer.toJson<String?>(posterPath),
      'releaseDate': serializer.toJson<String?>(releaseDate),
      'mediaType': serializer.toJson<int>(
        $WatchlistItemsTableTable.$convertermediaType.toJson(mediaType),
      ),
      'addedDate': serializer.toJson<DateTime>(addedDate),
      'voteAverage': serializer.toJson<double?>(voteAverage),
    };
  }

  WatchlistItemsTableData copyWith({
    int? id,
    String? title,
    Value<String?> posterPath = const Value.absent(),
    Value<String?> releaseDate = const Value.absent(),
    GlobalMediaType? mediaType,
    DateTime? addedDate,
    Value<double?> voteAverage = const Value.absent(),
  }) => WatchlistItemsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    posterPath: posterPath.present ? posterPath.value : this.posterPath,
    releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
    mediaType: mediaType ?? this.mediaType,
    addedDate: addedDate ?? this.addedDate,
    voteAverage: voteAverage.present ? voteAverage.value : this.voteAverage,
  );
  WatchlistItemsTableData copyWithCompanion(WatchlistItemsTableCompanion data) {
    return WatchlistItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      posterPath: data.posterPath.present
          ? data.posterPath.value
          : this.posterPath,
      releaseDate: data.releaseDate.present
          ? data.releaseDate.value
          : this.releaseDate,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      addedDate: data.addedDate.present ? data.addedDate.value : this.addedDate,
      voteAverage: data.voteAverage.present
          ? data.voteAverage.value
          : this.voteAverage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistItemsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('posterPath: $posterPath, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('mediaType: $mediaType, ')
          ..write('addedDate: $addedDate, ')
          ..write('voteAverage: $voteAverage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    posterPath,
    releaseDate,
    mediaType,
    addedDate,
    voteAverage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchlistItemsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.posterPath == this.posterPath &&
          other.releaseDate == this.releaseDate &&
          other.mediaType == this.mediaType &&
          other.addedDate == this.addedDate &&
          other.voteAverage == this.voteAverage);
}

class WatchlistItemsTableCompanion
    extends UpdateCompanion<WatchlistItemsTableData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> posterPath;
  final Value<String?> releaseDate;
  final Value<GlobalMediaType> mediaType;
  final Value<DateTime> addedDate;
  final Value<double?> voteAverage;
  const WatchlistItemsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.addedDate = const Value.absent(),
    this.voteAverage = const Value.absent(),
  });
  WatchlistItemsTableCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.posterPath = const Value.absent(),
    this.releaseDate = const Value.absent(),
    required GlobalMediaType mediaType,
    required DateTime addedDate,
    this.voteAverage = const Value.absent(),
  }) : title = Value(title),
       mediaType = Value(mediaType),
       addedDate = Value(addedDate);
  static Insertable<WatchlistItemsTableData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? posterPath,
    Expression<String>? releaseDate,
    Expression<int>? mediaType,
    Expression<DateTime>? addedDate,
    Expression<double>? voteAverage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (posterPath != null) 'poster_path': posterPath,
      if (releaseDate != null) 'release_date': releaseDate,
      if (mediaType != null) 'media_type': mediaType,
      if (addedDate != null) 'added_date': addedDate,
      if (voteAverage != null) 'vote_average': voteAverage,
    });
  }

  WatchlistItemsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? posterPath,
    Value<String?>? releaseDate,
    Value<GlobalMediaType>? mediaType,
    Value<DateTime>? addedDate,
    Value<double?>? voteAverage,
  }) {
    return WatchlistItemsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      releaseDate: releaseDate ?? this.releaseDate,
      mediaType: mediaType ?? this.mediaType,
      addedDate: addedDate ?? this.addedDate,
      voteAverage: voteAverage ?? this.voteAverage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (posterPath.present) {
      map['poster_path'] = Variable<String>(posterPath.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<String>(releaseDate.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<int>(
        $WatchlistItemsTableTable.$convertermediaType.toSql(mediaType.value),
      );
    }
    if (addedDate.present) {
      map['added_date'] = Variable<DateTime>(addedDate.value);
    }
    if (voteAverage.present) {
      map['vote_average'] = Variable<double>(voteAverage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('posterPath: $posterPath, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('mediaType: $mediaType, ')
          ..write('addedDate: $addedDate, ')
          ..write('voteAverage: $voteAverage')
          ..write(')'))
        .toString();
  }
}

class $WatchedItemsTableTable extends WatchedItemsTable
    with TableInfo<$WatchedItemsTableTable, WatchedItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchedItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posterPathMeta = const VerificationMeta(
    'posterPath',
  );
  @override
  late final GeneratedColumn<String> posterPath = GeneratedColumn<String>(
    'poster_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GlobalMediaType, int> mediaType =
      GeneratedColumn<int>(
        'media_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<GlobalMediaType>(
        $WatchedItemsTableTable.$convertermediaType,
      );
  static const VerificationMeta _watchDateMeta = const VerificationMeta(
    'watchDate',
  );
  @override
  late final GeneratedColumn<DateTime> watchDate = GeneratedColumn<DateTime>(
    'watch_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rewatchCountMeta = const VerificationMeta(
    'rewatchCount',
  );
  @override
  late final GeneratedColumn<int> rewatchCount = GeneratedColumn<int>(
    'rewatch_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _voteAverageMeta = const VerificationMeta(
    'voteAverage',
  );
  @override
  late final GeneratedColumn<double> voteAverage = GeneratedColumn<double>(
    'vote_average',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    posterPath,
    mediaType,
    watchDate,
    rating,
    rewatchCount,
    voteAverage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watched_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchedItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('poster_path')) {
      context.handle(
        _posterPathMeta,
        posterPath.isAcceptableOrUnknown(data['poster_path']!, _posterPathMeta),
      );
    }
    if (data.containsKey('watch_date')) {
      context.handle(
        _watchDateMeta,
        watchDate.isAcceptableOrUnknown(data['watch_date']!, _watchDateMeta),
      );
    } else if (isInserting) {
      context.missing(_watchDateMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('rewatch_count')) {
      context.handle(
        _rewatchCountMeta,
        rewatchCount.isAcceptableOrUnknown(
          data['rewatch_count']!,
          _rewatchCountMeta,
        ),
      );
    }
    if (data.containsKey('vote_average')) {
      context.handle(
        _voteAverageMeta,
        voteAverage.isAcceptableOrUnknown(
          data['vote_average']!,
          _voteAverageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchedItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchedItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      posterPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_path'],
      ),
      mediaType: $WatchedItemsTableTable.$convertermediaType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}media_type'],
        )!,
      ),
      watchDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}watch_date'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      rewatchCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rewatch_count'],
      )!,
      voteAverage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vote_average'],
      ),
    );
  }

  @override
  $WatchedItemsTableTable createAlias(String alias) {
    return $WatchedItemsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GlobalMediaType, int, int> $convertermediaType =
      const EnumIndexConverter<GlobalMediaType>(GlobalMediaType.values);
}

class WatchedItemsTableData extends DataClass
    implements Insertable<WatchedItemsTableData> {
  final int id;
  final String title;
  final String? posterPath;
  final GlobalMediaType mediaType;
  final DateTime watchDate;
  final int rating;
  final int rewatchCount;
  final double? voteAverage;
  const WatchedItemsTableData({
    required this.id,
    required this.title,
    this.posterPath,
    required this.mediaType,
    required this.watchDate,
    required this.rating,
    required this.rewatchCount,
    this.voteAverage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || posterPath != null) {
      map['poster_path'] = Variable<String>(posterPath);
    }
    {
      map['media_type'] = Variable<int>(
        $WatchedItemsTableTable.$convertermediaType.toSql(mediaType),
      );
    }
    map['watch_date'] = Variable<DateTime>(watchDate);
    map['rating'] = Variable<int>(rating);
    map['rewatch_count'] = Variable<int>(rewatchCount);
    if (!nullToAbsent || voteAverage != null) {
      map['vote_average'] = Variable<double>(voteAverage);
    }
    return map;
  }

  WatchedItemsTableCompanion toCompanion(bool nullToAbsent) {
    return WatchedItemsTableCompanion(
      id: Value(id),
      title: Value(title),
      posterPath: posterPath == null && nullToAbsent
          ? const Value.absent()
          : Value(posterPath),
      mediaType: Value(mediaType),
      watchDate: Value(watchDate),
      rating: Value(rating),
      rewatchCount: Value(rewatchCount),
      voteAverage: voteAverage == null && nullToAbsent
          ? const Value.absent()
          : Value(voteAverage),
    );
  }

  factory WatchedItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchedItemsTableData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      posterPath: serializer.fromJson<String?>(json['posterPath']),
      mediaType: $WatchedItemsTableTable.$convertermediaType.fromJson(
        serializer.fromJson<int>(json['mediaType']),
      ),
      watchDate: serializer.fromJson<DateTime>(json['watchDate']),
      rating: serializer.fromJson<int>(json['rating']),
      rewatchCount: serializer.fromJson<int>(json['rewatchCount']),
      voteAverage: serializer.fromJson<double?>(json['voteAverage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'posterPath': serializer.toJson<String?>(posterPath),
      'mediaType': serializer.toJson<int>(
        $WatchedItemsTableTable.$convertermediaType.toJson(mediaType),
      ),
      'watchDate': serializer.toJson<DateTime>(watchDate),
      'rating': serializer.toJson<int>(rating),
      'rewatchCount': serializer.toJson<int>(rewatchCount),
      'voteAverage': serializer.toJson<double?>(voteAverage),
    };
  }

  WatchedItemsTableData copyWith({
    int? id,
    String? title,
    Value<String?> posterPath = const Value.absent(),
    GlobalMediaType? mediaType,
    DateTime? watchDate,
    int? rating,
    int? rewatchCount,
    Value<double?> voteAverage = const Value.absent(),
  }) => WatchedItemsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    posterPath: posterPath.present ? posterPath.value : this.posterPath,
    mediaType: mediaType ?? this.mediaType,
    watchDate: watchDate ?? this.watchDate,
    rating: rating ?? this.rating,
    rewatchCount: rewatchCount ?? this.rewatchCount,
    voteAverage: voteAverage.present ? voteAverage.value : this.voteAverage,
  );
  WatchedItemsTableData copyWithCompanion(WatchedItemsTableCompanion data) {
    return WatchedItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      posterPath: data.posterPath.present
          ? data.posterPath.value
          : this.posterPath,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      watchDate: data.watchDate.present ? data.watchDate.value : this.watchDate,
      rating: data.rating.present ? data.rating.value : this.rating,
      rewatchCount: data.rewatchCount.present
          ? data.rewatchCount.value
          : this.rewatchCount,
      voteAverage: data.voteAverage.present
          ? data.voteAverage.value
          : this.voteAverage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchedItemsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('posterPath: $posterPath, ')
          ..write('mediaType: $mediaType, ')
          ..write('watchDate: $watchDate, ')
          ..write('rating: $rating, ')
          ..write('rewatchCount: $rewatchCount, ')
          ..write('voteAverage: $voteAverage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    posterPath,
    mediaType,
    watchDate,
    rating,
    rewatchCount,
    voteAverage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchedItemsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.posterPath == this.posterPath &&
          other.mediaType == this.mediaType &&
          other.watchDate == this.watchDate &&
          other.rating == this.rating &&
          other.rewatchCount == this.rewatchCount &&
          other.voteAverage == this.voteAverage);
}

class WatchedItemsTableCompanion
    extends UpdateCompanion<WatchedItemsTableData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> posterPath;
  final Value<GlobalMediaType> mediaType;
  final Value<DateTime> watchDate;
  final Value<int> rating;
  final Value<int> rewatchCount;
  final Value<double?> voteAverage;
  const WatchedItemsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.watchDate = const Value.absent(),
    this.rating = const Value.absent(),
    this.rewatchCount = const Value.absent(),
    this.voteAverage = const Value.absent(),
  });
  WatchedItemsTableCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.posterPath = const Value.absent(),
    required GlobalMediaType mediaType,
    required DateTime watchDate,
    required int rating,
    this.rewatchCount = const Value.absent(),
    this.voteAverage = const Value.absent(),
  }) : title = Value(title),
       mediaType = Value(mediaType),
       watchDate = Value(watchDate),
       rating = Value(rating);
  static Insertable<WatchedItemsTableData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? posterPath,
    Expression<int>? mediaType,
    Expression<DateTime>? watchDate,
    Expression<int>? rating,
    Expression<int>? rewatchCount,
    Expression<double>? voteAverage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (posterPath != null) 'poster_path': posterPath,
      if (mediaType != null) 'media_type': mediaType,
      if (watchDate != null) 'watch_date': watchDate,
      if (rating != null) 'rating': rating,
      if (rewatchCount != null) 'rewatch_count': rewatchCount,
      if (voteAverage != null) 'vote_average': voteAverage,
    });
  }

  WatchedItemsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? posterPath,
    Value<GlobalMediaType>? mediaType,
    Value<DateTime>? watchDate,
    Value<int>? rating,
    Value<int>? rewatchCount,
    Value<double?>? voteAverage,
  }) {
    return WatchedItemsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      mediaType: mediaType ?? this.mediaType,
      watchDate: watchDate ?? this.watchDate,
      rating: rating ?? this.rating,
      rewatchCount: rewatchCount ?? this.rewatchCount,
      voteAverage: voteAverage ?? this.voteAverage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (posterPath.present) {
      map['poster_path'] = Variable<String>(posterPath.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<int>(
        $WatchedItemsTableTable.$convertermediaType.toSql(mediaType.value),
      );
    }
    if (watchDate.present) {
      map['watch_date'] = Variable<DateTime>(watchDate.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (rewatchCount.present) {
      map['rewatch_count'] = Variable<int>(rewatchCount.value);
    }
    if (voteAverage.present) {
      map['vote_average'] = Variable<double>(voteAverage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchedItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('posterPath: $posterPath, ')
          ..write('mediaType: $mediaType, ')
          ..write('watchDate: $watchDate, ')
          ..write('rating: $rating, ')
          ..write('rewatchCount: $rewatchCount, ')
          ..write('voteAverage: $voteAverage')
          ..write(')'))
        .toString();
  }
}

class $MovieNotesTableTable extends MovieNotesTable
    with TableInfo<$MovieNotesTableTable, MovieNotesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovieNotesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _movieIdMeta = const VerificationMeta(
    'movieId',
  );
  @override
  late final GeneratedColumn<int> movieId = GeneratedColumn<int>(
    'movie_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GlobalMediaType, int> mediaType =
      GeneratedColumn<int>(
        'media_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<GlobalMediaType>(
        $MovieNotesTableTable.$convertermediaType,
      );
  static const VerificationMeta _noteTextMeta = const VerificationMeta(
    'noteText',
  );
  @override
  late final GeneratedColumn<String> noteText = GeneratedColumn<String>(
    'note_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    movieId,
    mediaType,
    noteText,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movie_notes_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovieNotesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('movie_id')) {
      context.handle(
        _movieIdMeta,
        movieId.isAcceptableOrUnknown(data['movie_id']!, _movieIdMeta),
      );
    } else if (isInserting) {
      context.missing(_movieIdMeta);
    }
    if (data.containsKey('note_text')) {
      context.handle(
        _noteTextMeta,
        noteText.isAcceptableOrUnknown(data['note_text']!, _noteTextMeta),
      );
    } else if (isInserting) {
      context.missing(_noteTextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovieNotesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovieNotesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      movieId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}movie_id'],
      )!,
      mediaType: $MovieNotesTableTable.$convertermediaType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}media_type'],
        )!,
      ),
      noteText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_text'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MovieNotesTableTable createAlias(String alias) {
    return $MovieNotesTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GlobalMediaType, int, int> $convertermediaType =
      const EnumIndexConverter<GlobalMediaType>(GlobalMediaType.values);
}

class MovieNotesTableData extends DataClass
    implements Insertable<MovieNotesTableData> {
  final int id;
  final int movieId;
  final GlobalMediaType mediaType;
  final String noteText;
  final DateTime createdAt;
  const MovieNotesTableData({
    required this.id,
    required this.movieId,
    required this.mediaType,
    required this.noteText,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['movie_id'] = Variable<int>(movieId);
    {
      map['media_type'] = Variable<int>(
        $MovieNotesTableTable.$convertermediaType.toSql(mediaType),
      );
    }
    map['note_text'] = Variable<String>(noteText);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MovieNotesTableCompanion toCompanion(bool nullToAbsent) {
    return MovieNotesTableCompanion(
      id: Value(id),
      movieId: Value(movieId),
      mediaType: Value(mediaType),
      noteText: Value(noteText),
      createdAt: Value(createdAt),
    );
  }

  factory MovieNotesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovieNotesTableData(
      id: serializer.fromJson<int>(json['id']),
      movieId: serializer.fromJson<int>(json['movieId']),
      mediaType: $MovieNotesTableTable.$convertermediaType.fromJson(
        serializer.fromJson<int>(json['mediaType']),
      ),
      noteText: serializer.fromJson<String>(json['noteText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'movieId': serializer.toJson<int>(movieId),
      'mediaType': serializer.toJson<int>(
        $MovieNotesTableTable.$convertermediaType.toJson(mediaType),
      ),
      'noteText': serializer.toJson<String>(noteText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MovieNotesTableData copyWith({
    int? id,
    int? movieId,
    GlobalMediaType? mediaType,
    String? noteText,
    DateTime? createdAt,
  }) => MovieNotesTableData(
    id: id ?? this.id,
    movieId: movieId ?? this.movieId,
    mediaType: mediaType ?? this.mediaType,
    noteText: noteText ?? this.noteText,
    createdAt: createdAt ?? this.createdAt,
  );
  MovieNotesTableData copyWithCompanion(MovieNotesTableCompanion data) {
    return MovieNotesTableData(
      id: data.id.present ? data.id.value : this.id,
      movieId: data.movieId.present ? data.movieId.value : this.movieId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      noteText: data.noteText.present ? data.noteText.value : this.noteText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovieNotesTableData(')
          ..write('id: $id, ')
          ..write('movieId: $movieId, ')
          ..write('mediaType: $mediaType, ')
          ..write('noteText: $noteText, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, movieId, mediaType, noteText, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovieNotesTableData &&
          other.id == this.id &&
          other.movieId == this.movieId &&
          other.mediaType == this.mediaType &&
          other.noteText == this.noteText &&
          other.createdAt == this.createdAt);
}

class MovieNotesTableCompanion extends UpdateCompanion<MovieNotesTableData> {
  final Value<int> id;
  final Value<int> movieId;
  final Value<GlobalMediaType> mediaType;
  final Value<String> noteText;
  final Value<DateTime> createdAt;
  const MovieNotesTableCompanion({
    this.id = const Value.absent(),
    this.movieId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.noteText = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MovieNotesTableCompanion.insert({
    this.id = const Value.absent(),
    required int movieId,
    this.mediaType = const Value.absent(),
    required String noteText,
    required DateTime createdAt,
  }) : movieId = Value(movieId),
       noteText = Value(noteText),
       createdAt = Value(createdAt);
  static Insertable<MovieNotesTableData> custom({
    Expression<int>? id,
    Expression<int>? movieId,
    Expression<int>? mediaType,
    Expression<String>? noteText,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (movieId != null) 'movie_id': movieId,
      if (mediaType != null) 'media_type': mediaType,
      if (noteText != null) 'note_text': noteText,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MovieNotesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? movieId,
    Value<GlobalMediaType>? mediaType,
    Value<String>? noteText,
    Value<DateTime>? createdAt,
  }) {
    return MovieNotesTableCompanion(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      mediaType: mediaType ?? this.mediaType,
      noteText: noteText ?? this.noteText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (movieId.present) {
      map['movie_id'] = Variable<int>(movieId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<int>(
        $MovieNotesTableTable.$convertermediaType.toSql(mediaType.value),
      );
    }
    if (noteText.present) {
      map['note_text'] = Variable<String>(noteText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovieNotesTableCompanion(')
          ..write('id: $id, ')
          ..write('movieId: $movieId, ')
          ..write('mediaType: $mediaType, ')
          ..write('noteText: $noteText, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WatchlistItemsTableTable watchlistItemsTable =
      $WatchlistItemsTableTable(this);
  late final $WatchedItemsTableTable watchedItemsTable =
      $WatchedItemsTableTable(this);
  late final $MovieNotesTableTable movieNotesTable = $MovieNotesTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    watchlistItemsTable,
    watchedItemsTable,
    movieNotesTable,
  ];
}

typedef $$WatchlistItemsTableTableCreateCompanionBuilder =
    WatchlistItemsTableCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> posterPath,
      Value<String?> releaseDate,
      required GlobalMediaType mediaType,
      required DateTime addedDate,
      Value<double?> voteAverage,
    });
typedef $$WatchlistItemsTableTableUpdateCompanionBuilder =
    WatchlistItemsTableCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> posterPath,
      Value<String?> releaseDate,
      Value<GlobalMediaType> mediaType,
      Value<DateTime> addedDate,
      Value<double?> voteAverage,
    });

class $$WatchlistItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $WatchlistItemsTableTable> {
  $$WatchlistItemsTableTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GlobalMediaType, GlobalMediaType, int>
  get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WatchlistItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchlistItemsTableTable> {
  $$WatchlistItemsTableTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WatchlistItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchlistItemsTableTable> {
  $$WatchlistItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GlobalMediaType, int> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<DateTime> get addedDate =>
      $composableBuilder(column: $table.addedDate, builder: (column) => column);

  GeneratedColumn<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => column,
  );
}

class $$WatchlistItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchlistItemsTableTable,
          WatchlistItemsTableData,
          $$WatchlistItemsTableTableFilterComposer,
          $$WatchlistItemsTableTableOrderingComposer,
          $$WatchlistItemsTableTableAnnotationComposer,
          $$WatchlistItemsTableTableCreateCompanionBuilder,
          $$WatchlistItemsTableTableUpdateCompanionBuilder,
          (
            WatchlistItemsTableData,
            BaseReferences<
              _$AppDatabase,
              $WatchlistItemsTableTable,
              WatchlistItemsTableData
            >,
          ),
          WatchlistItemsTableData,
          PrefetchHooks Function()
        > {
  $$WatchlistItemsTableTableTableManager(
    _$AppDatabase db,
    $WatchlistItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchlistItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchlistItemsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WatchlistItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                Value<GlobalMediaType> mediaType = const Value.absent(),
                Value<DateTime> addedDate = const Value.absent(),
                Value<double?> voteAverage = const Value.absent(),
              }) => WatchlistItemsTableCompanion(
                id: id,
                title: title,
                posterPath: posterPath,
                releaseDate: releaseDate,
                mediaType: mediaType,
                addedDate: addedDate,
                voteAverage: voteAverage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> posterPath = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                required GlobalMediaType mediaType,
                required DateTime addedDate,
                Value<double?> voteAverage = const Value.absent(),
              }) => WatchlistItemsTableCompanion.insert(
                id: id,
                title: title,
                posterPath: posterPath,
                releaseDate: releaseDate,
                mediaType: mediaType,
                addedDate: addedDate,
                voteAverage: voteAverage,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WatchlistItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchlistItemsTableTable,
      WatchlistItemsTableData,
      $$WatchlistItemsTableTableFilterComposer,
      $$WatchlistItemsTableTableOrderingComposer,
      $$WatchlistItemsTableTableAnnotationComposer,
      $$WatchlistItemsTableTableCreateCompanionBuilder,
      $$WatchlistItemsTableTableUpdateCompanionBuilder,
      (
        WatchlistItemsTableData,
        BaseReferences<
          _$AppDatabase,
          $WatchlistItemsTableTable,
          WatchlistItemsTableData
        >,
      ),
      WatchlistItemsTableData,
      PrefetchHooks Function()
    >;
typedef $$WatchedItemsTableTableCreateCompanionBuilder =
    WatchedItemsTableCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> posterPath,
      required GlobalMediaType mediaType,
      required DateTime watchDate,
      required int rating,
      Value<int> rewatchCount,
      Value<double?> voteAverage,
    });
typedef $$WatchedItemsTableTableUpdateCompanionBuilder =
    WatchedItemsTableCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> posterPath,
      Value<GlobalMediaType> mediaType,
      Value<DateTime> watchDate,
      Value<int> rating,
      Value<int> rewatchCount,
      Value<double?> voteAverage,
    });

class $$WatchedItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $WatchedItemsTableTable> {
  $$WatchedItemsTableTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GlobalMediaType, GlobalMediaType, int>
  get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get watchDate => $composableBuilder(
    column: $table.watchDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rewatchCount => $composableBuilder(
    column: $table.rewatchCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WatchedItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchedItemsTableTable> {
  $$WatchedItemsTableTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get watchDate => $composableBuilder(
    column: $table.watchDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rewatchCount => $composableBuilder(
    column: $table.rewatchCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WatchedItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchedItemsTableTable> {
  $$WatchedItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GlobalMediaType, int> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<DateTime> get watchDate =>
      $composableBuilder(column: $table.watchDate, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get rewatchCount => $composableBuilder(
    column: $table.rewatchCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => column,
  );
}

class $$WatchedItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchedItemsTableTable,
          WatchedItemsTableData,
          $$WatchedItemsTableTableFilterComposer,
          $$WatchedItemsTableTableOrderingComposer,
          $$WatchedItemsTableTableAnnotationComposer,
          $$WatchedItemsTableTableCreateCompanionBuilder,
          $$WatchedItemsTableTableUpdateCompanionBuilder,
          (
            WatchedItemsTableData,
            BaseReferences<
              _$AppDatabase,
              $WatchedItemsTableTable,
              WatchedItemsTableData
            >,
          ),
          WatchedItemsTableData,
          PrefetchHooks Function()
        > {
  $$WatchedItemsTableTableTableManager(
    _$AppDatabase db,
    $WatchedItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchedItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchedItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchedItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<GlobalMediaType> mediaType = const Value.absent(),
                Value<DateTime> watchDate = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<int> rewatchCount = const Value.absent(),
                Value<double?> voteAverage = const Value.absent(),
              }) => WatchedItemsTableCompanion(
                id: id,
                title: title,
                posterPath: posterPath,
                mediaType: mediaType,
                watchDate: watchDate,
                rating: rating,
                rewatchCount: rewatchCount,
                voteAverage: voteAverage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> posterPath = const Value.absent(),
                required GlobalMediaType mediaType,
                required DateTime watchDate,
                required int rating,
                Value<int> rewatchCount = const Value.absent(),
                Value<double?> voteAverage = const Value.absent(),
              }) => WatchedItemsTableCompanion.insert(
                id: id,
                title: title,
                posterPath: posterPath,
                mediaType: mediaType,
                watchDate: watchDate,
                rating: rating,
                rewatchCount: rewatchCount,
                voteAverage: voteAverage,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WatchedItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchedItemsTableTable,
      WatchedItemsTableData,
      $$WatchedItemsTableTableFilterComposer,
      $$WatchedItemsTableTableOrderingComposer,
      $$WatchedItemsTableTableAnnotationComposer,
      $$WatchedItemsTableTableCreateCompanionBuilder,
      $$WatchedItemsTableTableUpdateCompanionBuilder,
      (
        WatchedItemsTableData,
        BaseReferences<
          _$AppDatabase,
          $WatchedItemsTableTable,
          WatchedItemsTableData
        >,
      ),
      WatchedItemsTableData,
      PrefetchHooks Function()
    >;
typedef $$MovieNotesTableTableCreateCompanionBuilder =
    MovieNotesTableCompanion Function({
      Value<int> id,
      required int movieId,
      Value<GlobalMediaType> mediaType,
      required String noteText,
      required DateTime createdAt,
    });
typedef $$MovieNotesTableTableUpdateCompanionBuilder =
    MovieNotesTableCompanion Function({
      Value<int> id,
      Value<int> movieId,
      Value<GlobalMediaType> mediaType,
      Value<String> noteText,
      Value<DateTime> createdAt,
    });

class $$MovieNotesTableTableFilterComposer
    extends Composer<_$AppDatabase, $MovieNotesTableTable> {
  $$MovieNotesTableTableFilterComposer({
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

  ColumnFilters<int> get movieId => $composableBuilder(
    column: $table.movieId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GlobalMediaType, GlobalMediaType, int>
  get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MovieNotesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MovieNotesTableTable> {
  $$MovieNotesTableTableOrderingComposer({
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

  ColumnOrderings<int> get movieId => $composableBuilder(
    column: $table.movieId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovieNotesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovieNotesTableTable> {
  $$MovieNotesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get movieId =>
      $composableBuilder(column: $table.movieId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GlobalMediaType, int> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get noteText =>
      $composableBuilder(column: $table.noteText, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MovieNotesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovieNotesTableTable,
          MovieNotesTableData,
          $$MovieNotesTableTableFilterComposer,
          $$MovieNotesTableTableOrderingComposer,
          $$MovieNotesTableTableAnnotationComposer,
          $$MovieNotesTableTableCreateCompanionBuilder,
          $$MovieNotesTableTableUpdateCompanionBuilder,
          (
            MovieNotesTableData,
            BaseReferences<
              _$AppDatabase,
              $MovieNotesTableTable,
              MovieNotesTableData
            >,
          ),
          MovieNotesTableData,
          PrefetchHooks Function()
        > {
  $$MovieNotesTableTableTableManager(
    _$AppDatabase db,
    $MovieNotesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovieNotesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovieNotesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovieNotesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> movieId = const Value.absent(),
                Value<GlobalMediaType> mediaType = const Value.absent(),
                Value<String> noteText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MovieNotesTableCompanion(
                id: id,
                movieId: movieId,
                mediaType: mediaType,
                noteText: noteText,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int movieId,
                Value<GlobalMediaType> mediaType = const Value.absent(),
                required String noteText,
                required DateTime createdAt,
              }) => MovieNotesTableCompanion.insert(
                id: id,
                movieId: movieId,
                mediaType: mediaType,
                noteText: noteText,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MovieNotesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovieNotesTableTable,
      MovieNotesTableData,
      $$MovieNotesTableTableFilterComposer,
      $$MovieNotesTableTableOrderingComposer,
      $$MovieNotesTableTableAnnotationComposer,
      $$MovieNotesTableTableCreateCompanionBuilder,
      $$MovieNotesTableTableUpdateCompanionBuilder,
      (
        MovieNotesTableData,
        BaseReferences<
          _$AppDatabase,
          $MovieNotesTableTable,
          MovieNotesTableData
        >,
      ),
      MovieNotesTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WatchlistItemsTableTableTableManager get watchlistItemsTable =>
      $$WatchlistItemsTableTableTableManager(_db, _db.watchlistItemsTable);
  $$WatchedItemsTableTableTableManager get watchedItemsTable =>
      $$WatchedItemsTableTableTableManager(_db, _db.watchedItemsTable);
  $$MovieNotesTableTableTableManager get movieNotesTable =>
      $$MovieNotesTableTableTableManager(_db, _db.movieNotesTable);
}
