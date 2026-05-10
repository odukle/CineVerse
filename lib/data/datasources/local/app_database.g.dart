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

class $SearchHistoryTableTable extends SearchHistoryTable
    with TableInfo<$SearchHistoryTableTable, SearchHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
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
  List<GeneratedColumn> get $columns => [id, query, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchHistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
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
  SearchHistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SearchHistoryTableTable createAlias(String alias) {
    return $SearchHistoryTableTable(attachedDatabase, alias);
  }
}

class SearchHistoryTableData extends DataClass
    implements Insertable<SearchHistoryTableData> {
  final int id;
  final String query;
  final DateTime createdAt;
  const SearchHistoryTableData({
    required this.id,
    required this.query,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SearchHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryTableCompanion(
      id: Value(id),
      query: Value(query),
      createdAt: Value(createdAt),
    );
  }

  factory SearchHistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SearchHistoryTableData copyWith({
    int? id,
    String? query,
    DateTime? createdAt,
  }) => SearchHistoryTableData(
    id: id ?? this.id,
    query: query ?? this.query,
    createdAt: createdAt ?? this.createdAt,
  );
  SearchHistoryTableData copyWithCompanion(SearchHistoryTableCompanion data) {
    return SearchHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryTableData(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryTableData &&
          other.id == this.id &&
          other.query == this.query &&
          other.createdAt == this.createdAt);
}

class SearchHistoryTableCompanion
    extends UpdateCompanion<SearchHistoryTableData> {
  final Value<int> id;
  final Value<String> query;
  final Value<DateTime> createdAt;
  const SearchHistoryTableCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SearchHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required String query,
    required DateTime createdAt,
  }) : query = Value(query),
       createdAt = Value(createdAt);
  static Insertable<SearchHistoryTableData> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SearchHistoryTableCompanion copyWith({
    Value<int>? id,
    Value<String>? query,
    Value<DateTime>? createdAt,
  }) {
    return SearchHistoryTableCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FavouritesTableTable extends FavouritesTable
    with TableInfo<$FavouritesTableTable, FavouritesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavouritesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
        $FavouritesTableTable.$convertermediaType,
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
  static const String $name = 'favourites_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavouritesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id, mediaType};
  @override
  FavouritesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavouritesTableData(
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
      mediaType: $FavouritesTableTable.$convertermediaType.fromSql(
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
  $FavouritesTableTable createAlias(String alias) {
    return $FavouritesTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GlobalMediaType, int, int> $convertermediaType =
      const EnumIndexConverter<GlobalMediaType>(GlobalMediaType.values);
}

class FavouritesTableData extends DataClass
    implements Insertable<FavouritesTableData> {
  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final GlobalMediaType mediaType;
  final DateTime addedDate;
  final double? voteAverage;
  const FavouritesTableData({
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
        $FavouritesTableTable.$convertermediaType.toSql(mediaType),
      );
    }
    map['added_date'] = Variable<DateTime>(addedDate);
    if (!nullToAbsent || voteAverage != null) {
      map['vote_average'] = Variable<double>(voteAverage);
    }
    return map;
  }

  FavouritesTableCompanion toCompanion(bool nullToAbsent) {
    return FavouritesTableCompanion(
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

  factory FavouritesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavouritesTableData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      posterPath: serializer.fromJson<String?>(json['posterPath']),
      releaseDate: serializer.fromJson<String?>(json['releaseDate']),
      mediaType: $FavouritesTableTable.$convertermediaType.fromJson(
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
        $FavouritesTableTable.$convertermediaType.toJson(mediaType),
      ),
      'addedDate': serializer.toJson<DateTime>(addedDate),
      'voteAverage': serializer.toJson<double?>(voteAverage),
    };
  }

  FavouritesTableData copyWith({
    int? id,
    String? title,
    Value<String?> posterPath = const Value.absent(),
    Value<String?> releaseDate = const Value.absent(),
    GlobalMediaType? mediaType,
    DateTime? addedDate,
    Value<double?> voteAverage = const Value.absent(),
  }) => FavouritesTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    posterPath: posterPath.present ? posterPath.value : this.posterPath,
    releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
    mediaType: mediaType ?? this.mediaType,
    addedDate: addedDate ?? this.addedDate,
    voteAverage: voteAverage.present ? voteAverage.value : this.voteAverage,
  );
  FavouritesTableData copyWithCompanion(FavouritesTableCompanion data) {
    return FavouritesTableData(
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
    return (StringBuffer('FavouritesTableData(')
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
      (other is FavouritesTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.posterPath == this.posterPath &&
          other.releaseDate == this.releaseDate &&
          other.mediaType == this.mediaType &&
          other.addedDate == this.addedDate &&
          other.voteAverage == this.voteAverage);
}

class FavouritesTableCompanion extends UpdateCompanion<FavouritesTableData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> posterPath;
  final Value<String?> releaseDate;
  final Value<GlobalMediaType> mediaType;
  final Value<DateTime> addedDate;
  final Value<double?> voteAverage;
  final Value<int> rowid;
  const FavouritesTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.addedDate = const Value.absent(),
    this.voteAverage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavouritesTableCompanion.insert({
    required int id,
    required String title,
    this.posterPath = const Value.absent(),
    this.releaseDate = const Value.absent(),
    required GlobalMediaType mediaType,
    required DateTime addedDate,
    this.voteAverage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       mediaType = Value(mediaType),
       addedDate = Value(addedDate);
  static Insertable<FavouritesTableData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? posterPath,
    Expression<String>? releaseDate,
    Expression<int>? mediaType,
    Expression<DateTime>? addedDate,
    Expression<double>? voteAverage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (posterPath != null) 'poster_path': posterPath,
      if (releaseDate != null) 'release_date': releaseDate,
      if (mediaType != null) 'media_type': mediaType,
      if (addedDate != null) 'added_date': addedDate,
      if (voteAverage != null) 'vote_average': voteAverage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavouritesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? posterPath,
    Value<String?>? releaseDate,
    Value<GlobalMediaType>? mediaType,
    Value<DateTime>? addedDate,
    Value<double?>? voteAverage,
    Value<int>? rowid,
  }) {
    return FavouritesTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      releaseDate: releaseDate ?? this.releaseDate,
      mediaType: mediaType ?? this.mediaType,
      addedDate: addedDate ?? this.addedDate,
      voteAverage: voteAverage ?? this.voteAverage,
      rowid: rowid ?? this.rowid,
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
        $FavouritesTableTable.$convertermediaType.toSql(mediaType.value),
      );
    }
    if (addedDate.present) {
      map['added_date'] = Variable<DateTime>(addedDate.value);
    }
    if (voteAverage.present) {
      map['vote_average'] = Variable<double>(voteAverage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavouritesTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('posterPath: $posterPath, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('mediaType: $mediaType, ')
          ..write('addedDate: $addedDate, ')
          ..write('voteAverage: $voteAverage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NamedListsTableTable extends NamedListsTable
    with TableInfo<$NamedListsTableTable, NamedListsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NamedListsTableTable(this.attachedDatabase, [this._alias]);
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
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'named_lists_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<NamedListsTableData> instance, {
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
  NamedListsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NamedListsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NamedListsTableTable createAlias(String alias) {
    return $NamedListsTableTable(attachedDatabase, alias);
  }
}

class NamedListsTableData extends DataClass
    implements Insertable<NamedListsTableData> {
  final int id;
  final String name;
  final DateTime createdAt;
  const NamedListsTableData({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NamedListsTableCompanion toCompanion(bool nullToAbsent) {
    return NamedListsTableCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory NamedListsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NamedListsTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NamedListsTableData copyWith({int? id, String? name, DateTime? createdAt}) =>
      NamedListsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  NamedListsTableData copyWithCompanion(NamedListsTableCompanion data) {
    return NamedListsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NamedListsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NamedListsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class NamedListsTableCompanion extends UpdateCompanion<NamedListsTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const NamedListsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NamedListsTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<NamedListsTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NamedListsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return NamedListsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NamedListsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NamedListItemsTableTable extends NamedListItemsTable
    with TableInfo<$NamedListItemsTableTable, NamedListItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NamedListItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES named_lists_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
        $NamedListItemsTableTable.$convertermediaType,
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
  @override
  List<GeneratedColumn> get $columns => [
    listId,
    mediaId,
    title,
    posterPath,
    releaseDate,
    mediaType,
    voteAverage,
    addedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'named_list_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<NamedListItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
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
    if (data.containsKey('vote_average')) {
      context.handle(
        _voteAverageMeta,
        voteAverage.isAcceptableOrUnknown(
          data['vote_average']!,
          _voteAverageMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {listId, mediaId, mediaType};
  @override
  NamedListItemsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NamedListItemsTableData(
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media_id'],
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
      mediaType: $NamedListItemsTableTable.$convertermediaType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}media_type'],
        )!,
      ),
      voteAverage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vote_average'],
      ),
      addedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_date'],
      )!,
    );
  }

  @override
  $NamedListItemsTableTable createAlias(String alias) {
    return $NamedListItemsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GlobalMediaType, int, int> $convertermediaType =
      const EnumIndexConverter<GlobalMediaType>(GlobalMediaType.values);
}

class NamedListItemsTableData extends DataClass
    implements Insertable<NamedListItemsTableData> {
  final int listId;
  final int mediaId;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final GlobalMediaType mediaType;
  final double? voteAverage;
  final DateTime addedDate;
  const NamedListItemsTableData({
    required this.listId,
    required this.mediaId,
    required this.title,
    this.posterPath,
    this.releaseDate,
    required this.mediaType,
    this.voteAverage,
    required this.addedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['list_id'] = Variable<int>(listId);
    map['media_id'] = Variable<int>(mediaId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || posterPath != null) {
      map['poster_path'] = Variable<String>(posterPath);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<String>(releaseDate);
    }
    {
      map['media_type'] = Variable<int>(
        $NamedListItemsTableTable.$convertermediaType.toSql(mediaType),
      );
    }
    if (!nullToAbsent || voteAverage != null) {
      map['vote_average'] = Variable<double>(voteAverage);
    }
    map['added_date'] = Variable<DateTime>(addedDate);
    return map;
  }

  NamedListItemsTableCompanion toCompanion(bool nullToAbsent) {
    return NamedListItemsTableCompanion(
      listId: Value(listId),
      mediaId: Value(mediaId),
      title: Value(title),
      posterPath: posterPath == null && nullToAbsent
          ? const Value.absent()
          : Value(posterPath),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
      mediaType: Value(mediaType),
      voteAverage: voteAverage == null && nullToAbsent
          ? const Value.absent()
          : Value(voteAverage),
      addedDate: Value(addedDate),
    );
  }

  factory NamedListItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NamedListItemsTableData(
      listId: serializer.fromJson<int>(json['listId']),
      mediaId: serializer.fromJson<int>(json['mediaId']),
      title: serializer.fromJson<String>(json['title']),
      posterPath: serializer.fromJson<String?>(json['posterPath']),
      releaseDate: serializer.fromJson<String?>(json['releaseDate']),
      mediaType: $NamedListItemsTableTable.$convertermediaType.fromJson(
        serializer.fromJson<int>(json['mediaType']),
      ),
      voteAverage: serializer.fromJson<double?>(json['voteAverage']),
      addedDate: serializer.fromJson<DateTime>(json['addedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'listId': serializer.toJson<int>(listId),
      'mediaId': serializer.toJson<int>(mediaId),
      'title': serializer.toJson<String>(title),
      'posterPath': serializer.toJson<String?>(posterPath),
      'releaseDate': serializer.toJson<String?>(releaseDate),
      'mediaType': serializer.toJson<int>(
        $NamedListItemsTableTable.$convertermediaType.toJson(mediaType),
      ),
      'voteAverage': serializer.toJson<double?>(voteAverage),
      'addedDate': serializer.toJson<DateTime>(addedDate),
    };
  }

  NamedListItemsTableData copyWith({
    int? listId,
    int? mediaId,
    String? title,
    Value<String?> posterPath = const Value.absent(),
    Value<String?> releaseDate = const Value.absent(),
    GlobalMediaType? mediaType,
    Value<double?> voteAverage = const Value.absent(),
    DateTime? addedDate,
  }) => NamedListItemsTableData(
    listId: listId ?? this.listId,
    mediaId: mediaId ?? this.mediaId,
    title: title ?? this.title,
    posterPath: posterPath.present ? posterPath.value : this.posterPath,
    releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
    mediaType: mediaType ?? this.mediaType,
    voteAverage: voteAverage.present ? voteAverage.value : this.voteAverage,
    addedDate: addedDate ?? this.addedDate,
  );
  NamedListItemsTableData copyWithCompanion(NamedListItemsTableCompanion data) {
    return NamedListItemsTableData(
      listId: data.listId.present ? data.listId.value : this.listId,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      title: data.title.present ? data.title.value : this.title,
      posterPath: data.posterPath.present
          ? data.posterPath.value
          : this.posterPath,
      releaseDate: data.releaseDate.present
          ? data.releaseDate.value
          : this.releaseDate,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      voteAverage: data.voteAverage.present
          ? data.voteAverage.value
          : this.voteAverage,
      addedDate: data.addedDate.present ? data.addedDate.value : this.addedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NamedListItemsTableData(')
          ..write('listId: $listId, ')
          ..write('mediaId: $mediaId, ')
          ..write('title: $title, ')
          ..write('posterPath: $posterPath, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('mediaType: $mediaType, ')
          ..write('voteAverage: $voteAverage, ')
          ..write('addedDate: $addedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    listId,
    mediaId,
    title,
    posterPath,
    releaseDate,
    mediaType,
    voteAverage,
    addedDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NamedListItemsTableData &&
          other.listId == this.listId &&
          other.mediaId == this.mediaId &&
          other.title == this.title &&
          other.posterPath == this.posterPath &&
          other.releaseDate == this.releaseDate &&
          other.mediaType == this.mediaType &&
          other.voteAverage == this.voteAverage &&
          other.addedDate == this.addedDate);
}

class NamedListItemsTableCompanion
    extends UpdateCompanion<NamedListItemsTableData> {
  final Value<int> listId;
  final Value<int> mediaId;
  final Value<String> title;
  final Value<String?> posterPath;
  final Value<String?> releaseDate;
  final Value<GlobalMediaType> mediaType;
  final Value<double?> voteAverage;
  final Value<DateTime> addedDate;
  final Value<int> rowid;
  const NamedListItemsTableCompanion({
    this.listId = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.title = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.voteAverage = const Value.absent(),
    this.addedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NamedListItemsTableCompanion.insert({
    required int listId,
    required int mediaId,
    required String title,
    this.posterPath = const Value.absent(),
    this.releaseDate = const Value.absent(),
    required GlobalMediaType mediaType,
    this.voteAverage = const Value.absent(),
    required DateTime addedDate,
    this.rowid = const Value.absent(),
  }) : listId = Value(listId),
       mediaId = Value(mediaId),
       title = Value(title),
       mediaType = Value(mediaType),
       addedDate = Value(addedDate);
  static Insertable<NamedListItemsTableData> custom({
    Expression<int>? listId,
    Expression<int>? mediaId,
    Expression<String>? title,
    Expression<String>? posterPath,
    Expression<String>? releaseDate,
    Expression<int>? mediaType,
    Expression<double>? voteAverage,
    Expression<DateTime>? addedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (listId != null) 'list_id': listId,
      if (mediaId != null) 'media_id': mediaId,
      if (title != null) 'title': title,
      if (posterPath != null) 'poster_path': posterPath,
      if (releaseDate != null) 'release_date': releaseDate,
      if (mediaType != null) 'media_type': mediaType,
      if (voteAverage != null) 'vote_average': voteAverage,
      if (addedDate != null) 'added_date': addedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NamedListItemsTableCompanion copyWith({
    Value<int>? listId,
    Value<int>? mediaId,
    Value<String>? title,
    Value<String?>? posterPath,
    Value<String?>? releaseDate,
    Value<GlobalMediaType>? mediaType,
    Value<double?>? voteAverage,
    Value<DateTime>? addedDate,
    Value<int>? rowid,
  }) {
    return NamedListItemsTableCompanion(
      listId: listId ?? this.listId,
      mediaId: mediaId ?? this.mediaId,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      releaseDate: releaseDate ?? this.releaseDate,
      mediaType: mediaType ?? this.mediaType,
      voteAverage: voteAverage ?? this.voteAverage,
      addedDate: addedDate ?? this.addedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<int>(mediaId.value);
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
        $NamedListItemsTableTable.$convertermediaType.toSql(mediaType.value),
      );
    }
    if (voteAverage.present) {
      map['vote_average'] = Variable<double>(voteAverage.value);
    }
    if (addedDate.present) {
      map['added_date'] = Variable<DateTime>(addedDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NamedListItemsTableCompanion(')
          ..write('listId: $listId, ')
          ..write('mediaId: $mediaId, ')
          ..write('title: $title, ')
          ..write('posterPath: $posterPath, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('mediaType: $mediaType, ')
          ..write('voteAverage: $voteAverage, ')
          ..write('addedDate: $addedDate, ')
          ..write('rowid: $rowid')
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
  late final $SearchHistoryTableTable searchHistoryTable =
      $SearchHistoryTableTable(this);
  late final $FavouritesTableTable favouritesTable = $FavouritesTableTable(
    this,
  );
  late final $NamedListsTableTable namedListsTable = $NamedListsTableTable(
    this,
  );
  late final $NamedListItemsTableTable namedListItemsTable =
      $NamedListItemsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    watchlistItemsTable,
    watchedItemsTable,
    movieNotesTable,
    searchHistoryTable,
    favouritesTable,
    namedListsTable,
    namedListItemsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'named_lists_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('named_list_items_table', kind: UpdateKind.delete)],
    ),
  ]);
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
typedef $$SearchHistoryTableTableCreateCompanionBuilder =
    SearchHistoryTableCompanion Function({
      Value<int> id,
      required String query,
      required DateTime createdAt,
    });
typedef $$SearchHistoryTableTableUpdateCompanionBuilder =
    SearchHistoryTableCompanion Function({
      Value<int> id,
      Value<String> query,
      Value<DateTime> createdAt,
    });

class $$SearchHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoryTableTable> {
  $$SearchHistoryTableTableFilterComposer({
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

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoryTableTable> {
  $$SearchHistoryTableTableOrderingComposer({
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

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoryTableTable> {
  $$SearchHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SearchHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchHistoryTableTable,
          SearchHistoryTableData,
          $$SearchHistoryTableTableFilterComposer,
          $$SearchHistoryTableTableOrderingComposer,
          $$SearchHistoryTableTableAnnotationComposer,
          $$SearchHistoryTableTableCreateCompanionBuilder,
          $$SearchHistoryTableTableUpdateCompanionBuilder,
          (
            SearchHistoryTableData,
            BaseReferences<
              _$AppDatabase,
              $SearchHistoryTableTable,
              SearchHistoryTableData
            >,
          ),
          SearchHistoryTableData,
          PrefetchHooks Function()
        > {
  $$SearchHistoryTableTableTableManager(
    _$AppDatabase db,
    $SearchHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SearchHistoryTableCompanion(
                id: id,
                query: query,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String query,
                required DateTime createdAt,
              }) => SearchHistoryTableCompanion.insert(
                id: id,
                query: query,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchHistoryTableTable,
      SearchHistoryTableData,
      $$SearchHistoryTableTableFilterComposer,
      $$SearchHistoryTableTableOrderingComposer,
      $$SearchHistoryTableTableAnnotationComposer,
      $$SearchHistoryTableTableCreateCompanionBuilder,
      $$SearchHistoryTableTableUpdateCompanionBuilder,
      (
        SearchHistoryTableData,
        BaseReferences<
          _$AppDatabase,
          $SearchHistoryTableTable,
          SearchHistoryTableData
        >,
      ),
      SearchHistoryTableData,
      PrefetchHooks Function()
    >;
typedef $$FavouritesTableTableCreateCompanionBuilder =
    FavouritesTableCompanion Function({
      required int id,
      required String title,
      Value<String?> posterPath,
      Value<String?> releaseDate,
      required GlobalMediaType mediaType,
      required DateTime addedDate,
      Value<double?> voteAverage,
      Value<int> rowid,
    });
typedef $$FavouritesTableTableUpdateCompanionBuilder =
    FavouritesTableCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> posterPath,
      Value<String?> releaseDate,
      Value<GlobalMediaType> mediaType,
      Value<DateTime> addedDate,
      Value<double?> voteAverage,
      Value<int> rowid,
    });

class $$FavouritesTableTableFilterComposer
    extends Composer<_$AppDatabase, $FavouritesTableTable> {
  $$FavouritesTableTableFilterComposer({
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

class $$FavouritesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FavouritesTableTable> {
  $$FavouritesTableTableOrderingComposer({
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

class $$FavouritesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavouritesTableTable> {
  $$FavouritesTableTableAnnotationComposer({
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

class $$FavouritesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavouritesTableTable,
          FavouritesTableData,
          $$FavouritesTableTableFilterComposer,
          $$FavouritesTableTableOrderingComposer,
          $$FavouritesTableTableAnnotationComposer,
          $$FavouritesTableTableCreateCompanionBuilder,
          $$FavouritesTableTableUpdateCompanionBuilder,
          (
            FavouritesTableData,
            BaseReferences<
              _$AppDatabase,
              $FavouritesTableTable,
              FavouritesTableData
            >,
          ),
          FavouritesTableData,
          PrefetchHooks Function()
        > {
  $$FavouritesTableTableTableManager(
    _$AppDatabase db,
    $FavouritesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavouritesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavouritesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavouritesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                Value<GlobalMediaType> mediaType = const Value.absent(),
                Value<DateTime> addedDate = const Value.absent(),
                Value<double?> voteAverage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavouritesTableCompanion(
                id: id,
                title: title,
                posterPath: posterPath,
                releaseDate: releaseDate,
                mediaType: mediaType,
                addedDate: addedDate,
                voteAverage: voteAverage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String title,
                Value<String?> posterPath = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                required GlobalMediaType mediaType,
                required DateTime addedDate,
                Value<double?> voteAverage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavouritesTableCompanion.insert(
                id: id,
                title: title,
                posterPath: posterPath,
                releaseDate: releaseDate,
                mediaType: mediaType,
                addedDate: addedDate,
                voteAverage: voteAverage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavouritesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavouritesTableTable,
      FavouritesTableData,
      $$FavouritesTableTableFilterComposer,
      $$FavouritesTableTableOrderingComposer,
      $$FavouritesTableTableAnnotationComposer,
      $$FavouritesTableTableCreateCompanionBuilder,
      $$FavouritesTableTableUpdateCompanionBuilder,
      (
        FavouritesTableData,
        BaseReferences<
          _$AppDatabase,
          $FavouritesTableTable,
          FavouritesTableData
        >,
      ),
      FavouritesTableData,
      PrefetchHooks Function()
    >;
typedef $$NamedListsTableTableCreateCompanionBuilder =
    NamedListsTableCompanion Function({
      Value<int> id,
      required String name,
      required DateTime createdAt,
    });
typedef $$NamedListsTableTableUpdateCompanionBuilder =
    NamedListsTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
    });

final class $$NamedListsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NamedListsTableTable,
          NamedListsTableData
        > {
  $$NamedListsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $NamedListItemsTableTable,
    List<NamedListItemsTableData>
  >
  _namedListItemsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.namedListItemsTable,
        aliasName: $_aliasNameGenerator(
          db.namedListsTable.id,
          db.namedListItemsTable.listId,
        ),
      );

  $$NamedListItemsTableTableProcessedTableManager get namedListItemsTableRefs {
    final manager = $$NamedListItemsTableTableTableManager(
      $_db,
      $_db.namedListItemsTable,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _namedListItemsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NamedListsTableTableFilterComposer
    extends Composer<_$AppDatabase, $NamedListsTableTable> {
  $$NamedListsTableTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> namedListItemsTableRefs(
    Expression<bool> Function($$NamedListItemsTableTableFilterComposer f) f,
  ) {
    final $$NamedListItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.namedListItemsTable,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NamedListItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.namedListItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NamedListsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NamedListsTableTable> {
  $$NamedListsTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NamedListsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NamedListsTableTable> {
  $$NamedListsTableTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> namedListItemsTableRefs<T extends Object>(
    Expression<T> Function($$NamedListItemsTableTableAnnotationComposer a) f,
  ) {
    final $$NamedListItemsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.namedListItemsTable,
          getReferencedColumn: (t) => t.listId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NamedListItemsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.namedListItemsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$NamedListsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NamedListsTableTable,
          NamedListsTableData,
          $$NamedListsTableTableFilterComposer,
          $$NamedListsTableTableOrderingComposer,
          $$NamedListsTableTableAnnotationComposer,
          $$NamedListsTableTableCreateCompanionBuilder,
          $$NamedListsTableTableUpdateCompanionBuilder,
          (NamedListsTableData, $$NamedListsTableTableReferences),
          NamedListsTableData,
          PrefetchHooks Function({bool namedListItemsTableRefs})
        > {
  $$NamedListsTableTableTableManager(
    _$AppDatabase db,
    $NamedListsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NamedListsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NamedListsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NamedListsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NamedListsTableCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime createdAt,
              }) => NamedListsTableCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NamedListsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({namedListItemsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (namedListItemsTableRefs) db.namedListItemsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (namedListItemsTableRefs)
                    await $_getPrefetchedData<
                      NamedListsTableData,
                      $NamedListsTableTable,
                      NamedListItemsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$NamedListsTableTableReferences
                          ._namedListItemsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$NamedListsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).namedListItemsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.listId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NamedListsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NamedListsTableTable,
      NamedListsTableData,
      $$NamedListsTableTableFilterComposer,
      $$NamedListsTableTableOrderingComposer,
      $$NamedListsTableTableAnnotationComposer,
      $$NamedListsTableTableCreateCompanionBuilder,
      $$NamedListsTableTableUpdateCompanionBuilder,
      (NamedListsTableData, $$NamedListsTableTableReferences),
      NamedListsTableData,
      PrefetchHooks Function({bool namedListItemsTableRefs})
    >;
typedef $$NamedListItemsTableTableCreateCompanionBuilder =
    NamedListItemsTableCompanion Function({
      required int listId,
      required int mediaId,
      required String title,
      Value<String?> posterPath,
      Value<String?> releaseDate,
      required GlobalMediaType mediaType,
      Value<double?> voteAverage,
      required DateTime addedDate,
      Value<int> rowid,
    });
typedef $$NamedListItemsTableTableUpdateCompanionBuilder =
    NamedListItemsTableCompanion Function({
      Value<int> listId,
      Value<int> mediaId,
      Value<String> title,
      Value<String?> posterPath,
      Value<String?> releaseDate,
      Value<GlobalMediaType> mediaType,
      Value<double?> voteAverage,
      Value<DateTime> addedDate,
      Value<int> rowid,
    });

final class $$NamedListItemsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NamedListItemsTableTable,
          NamedListItemsTableData
        > {
  $$NamedListItemsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NamedListsTableTable _listIdTable(_$AppDatabase db) =>
      db.namedListsTable.createAlias(
        $_aliasNameGenerator(
          db.namedListItemsTable.listId,
          db.namedListsTable.id,
        ),
      );

  $$NamedListsTableTableProcessedTableManager get listId {
    final $_column = $_itemColumn<int>('list_id')!;

    final manager = $$NamedListsTableTableTableManager(
      $_db,
      $_db.namedListsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NamedListItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $NamedListItemsTableTable> {
  $$NamedListItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get mediaId => $composableBuilder(
    column: $table.mediaId,
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

  ColumnFilters<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnFilters(column),
  );

  $$NamedListsTableTableFilterComposer get listId {
    final $$NamedListsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.namedListsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NamedListsTableTableFilterComposer(
            $db: $db,
            $table: $db.namedListsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NamedListItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NamedListItemsTableTable> {
  $$NamedListItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get mediaId => $composableBuilder(
    column: $table.mediaId,
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

  ColumnOrderings<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$NamedListsTableTableOrderingComposer get listId {
    final $$NamedListsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.namedListsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NamedListsTableTableOrderingComposer(
            $db: $db,
            $table: $db.namedListsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NamedListItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NamedListItemsTableTable> {
  $$NamedListItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

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

  GeneratedColumn<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedDate =>
      $composableBuilder(column: $table.addedDate, builder: (column) => column);

  $$NamedListsTableTableAnnotationComposer get listId {
    final $$NamedListsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.namedListsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NamedListsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.namedListsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NamedListItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NamedListItemsTableTable,
          NamedListItemsTableData,
          $$NamedListItemsTableTableFilterComposer,
          $$NamedListItemsTableTableOrderingComposer,
          $$NamedListItemsTableTableAnnotationComposer,
          $$NamedListItemsTableTableCreateCompanionBuilder,
          $$NamedListItemsTableTableUpdateCompanionBuilder,
          (NamedListItemsTableData, $$NamedListItemsTableTableReferences),
          NamedListItemsTableData,
          PrefetchHooks Function({bool listId})
        > {
  $$NamedListItemsTableTableTableManager(
    _$AppDatabase db,
    $NamedListItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NamedListItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NamedListItemsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NamedListItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> listId = const Value.absent(),
                Value<int> mediaId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                Value<GlobalMediaType> mediaType = const Value.absent(),
                Value<double?> voteAverage = const Value.absent(),
                Value<DateTime> addedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NamedListItemsTableCompanion(
                listId: listId,
                mediaId: mediaId,
                title: title,
                posterPath: posterPath,
                releaseDate: releaseDate,
                mediaType: mediaType,
                voteAverage: voteAverage,
                addedDate: addedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int listId,
                required int mediaId,
                required String title,
                Value<String?> posterPath = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                required GlobalMediaType mediaType,
                Value<double?> voteAverage = const Value.absent(),
                required DateTime addedDate,
                Value<int> rowid = const Value.absent(),
              }) => NamedListItemsTableCompanion.insert(
                listId: listId,
                mediaId: mediaId,
                title: title,
                posterPath: posterPath,
                releaseDate: releaseDate,
                mediaType: mediaType,
                voteAverage: voteAverage,
                addedDate: addedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NamedListItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listId = false}) {
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
                    if (listId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.listId,
                                referencedTable:
                                    $$NamedListItemsTableTableReferences
                                        ._listIdTable(db),
                                referencedColumn:
                                    $$NamedListItemsTableTableReferences
                                        ._listIdTable(db)
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

typedef $$NamedListItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NamedListItemsTableTable,
      NamedListItemsTableData,
      $$NamedListItemsTableTableFilterComposer,
      $$NamedListItemsTableTableOrderingComposer,
      $$NamedListItemsTableTableAnnotationComposer,
      $$NamedListItemsTableTableCreateCompanionBuilder,
      $$NamedListItemsTableTableUpdateCompanionBuilder,
      (NamedListItemsTableData, $$NamedListItemsTableTableReferences),
      NamedListItemsTableData,
      PrefetchHooks Function({bool listId})
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
  $$SearchHistoryTableTableTableManager get searchHistoryTable =>
      $$SearchHistoryTableTableTableManager(_db, _db.searchHistoryTable);
  $$FavouritesTableTableTableManager get favouritesTable =>
      $$FavouritesTableTableTableManager(_db, _db.favouritesTable);
  $$NamedListsTableTableTableManager get namedListsTable =>
      $$NamedListsTableTableTableManager(_db, _db.namedListsTable);
  $$NamedListItemsTableTableTableManager get namedListItemsTable =>
      $$NamedListItemsTableTableTableManager(_db, _db.namedListItemsTable);
}
