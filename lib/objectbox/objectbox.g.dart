// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again
// with `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart' as obx;
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import '../model/movie.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(1, 8529174496884316865),
      name: 'Movie',
      lastPropertyId: const obx_int.IdUid(13, 6168224067297831111),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 1439809891253493469),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 5596860716277786079),
            name: 'title',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 8229445164523938569),
            name: 'created',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 1004171901424612766),
            name: 'recorded',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 6547540029359791828),
            name: 'path',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 840761274945939046),
            name: 'tags',
            type: 30,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 2531575147060015655),
            name: 'cover',
            type: 30,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(8, 1141510409712744169),
            name: 'star',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(9, 8222304670557168778),
            name: 'source',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(10, 6111530157541794721),
            name: 'comment',
            type: 30,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(11, 4811719168997105434),
            name: 'duration',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(12, 1649974688060034162),
            name: 'like',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(13, 6168224067297831111),
            name: 'size',
            type: 6,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[])
];

/// Shortcut for [obx.Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [obx.Store.new] for an explanation of all parameters.
///
/// For Flutter apps, also calls `loadObjectBoxLibraryAndroidCompat()` from
/// the ObjectBox Flutter library to fix loading the native ObjectBox library
/// on Android 6 and older.
Future<obx.Store> openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) async {
  await loadObjectBoxLibraryAndroidCompat();
  return obx.Store(getObjectBoxModel(),
      directory: directory ?? (await defaultStoreDirectory()).path,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// Returns the ObjectBox model definition for this project for use with
/// [obx.Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(1, 8529174496884316865),
      lastIndexId: const obx_int.IdUid(0, 0),
      lastRelationId: const obx_int.IdUid(0, 0),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    Movie: obx_int.EntityDefinition<Movie>(
        model: _entities[0],
        toOneRelations: (Movie object) => [],
        toManyRelations: (Movie object) => {},
        getId: (Movie object) => object.id,
        setId: (Movie object, int id) {
          object.id = id;
        },
        objectToFB: (Movie object, fb.Builder fbb) {
          final titleOffset = fbb.writeString(object.title);
          final createdOffset =
              object.created == null ? null : fbb.writeString(object.created!);
          final recordedOffset = object.recorded == null
              ? null
              : fbb.writeString(object.recorded!);
          final pathOffset = fbb.writeString(object.path);
          final tagsOffset = fbb.writeList(
              object.tags.map(fbb.writeString).toList(growable: false));
          final coverOffset = fbb.writeList(
              object.cover.map(fbb.writeString).toList(growable: false));
          final sourceOffset =
              object.source == null ? null : fbb.writeString(object.source!);
          final commentOffset = fbb.writeList(
              object.comment.map(fbb.writeString).toList(growable: false));
          fbb.startTable(14);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, titleOffset);
          fbb.addOffset(2, createdOffset);
          fbb.addOffset(3, recordedOffset);
          fbb.addOffset(4, pathOffset);
          fbb.addOffset(5, tagsOffset);
          fbb.addOffset(6, coverOffset);
          fbb.addInt64(7, object.star);
          fbb.addOffset(8, sourceOffset);
          fbb.addOffset(9, commentOffset);
          fbb.addInt64(10, object.duration);
          fbb.addBool(11, object.like);
          fbb.addInt64(12, object.size);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final titleParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final pathParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 12, '');
          final tagsParam = const fb.ListReader<String>(
                  fb.StringReader(asciiOptimization: true),
                  lazy: false)
              .vTableGet(buffer, rootOffset, 14, []);
          final coverParam = const fb.ListReader<String>(
                  fb.StringReader(asciiOptimization: true),
                  lazy: false)
              .vTableGet(buffer, rootOffset, 16, []);
          final commentParam = const fb.ListReader<String>(
                  fb.StringReader(asciiOptimization: true),
                  lazy: false)
              .vTableGet(buffer, rootOffset, 22, []);
          final durationParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 24, 0);
          final likeParam =
              const fb.BoolReader().vTableGet(buffer, rootOffset, 26, false);
          final sizeParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 28, 0);
          final object = Movie(
              id: idParam,
              title: titleParam,
              path: pathParam,
              tags: tagsParam,
              cover: coverParam,
              comment: commentParam,
              duration: durationParam,
              like: likeParam,
              size: sizeParam)
            ..created = const fb.StringReader(asciiOptimization: true)
                .vTableGetNullable(buffer, rootOffset, 8)
            ..recorded = const fb.StringReader(asciiOptimization: true)
                .vTableGetNullable(buffer, rootOffset, 10)
            ..star =
                const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 18)
            ..source = const fb.StringReader(asciiOptimization: true)
                .vTableGetNullable(buffer, rootOffset, 20);

          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [Movie] entity fields to define ObjectBox queries.
class Movie_ {
  /// See [Movie.id].
  static final id = obx.QueryIntegerProperty<Movie>(_entities[0].properties[0]);

  /// See [Movie.title].
  static final title =
      obx.QueryStringProperty<Movie>(_entities[0].properties[1]);

  /// See [Movie.created].
  static final created =
      obx.QueryStringProperty<Movie>(_entities[0].properties[2]);

  /// See [Movie.recorded].
  static final recorded =
      obx.QueryStringProperty<Movie>(_entities[0].properties[3]);

  /// See [Movie.path].
  static final path =
      obx.QueryStringProperty<Movie>(_entities[0].properties[4]);

  /// See [Movie.tags].
  static final tags =
      obx.QueryStringVectorProperty<Movie>(_entities[0].properties[5]);

  /// See [Movie.cover].
  static final cover =
      obx.QueryStringVectorProperty<Movie>(_entities[0].properties[6]);

  /// See [Movie.star].
  static final star =
      obx.QueryIntegerProperty<Movie>(_entities[0].properties[7]);

  /// See [Movie.source].
  static final source =
      obx.QueryStringProperty<Movie>(_entities[0].properties[8]);

  /// See [Movie.comment].
  static final comment =
      obx.QueryStringVectorProperty<Movie>(_entities[0].properties[9]);

  /// See [Movie.duration].
  static final duration =
      obx.QueryIntegerProperty<Movie>(_entities[0].properties[10]);

  /// See [Movie.like].
  static final like =
      obx.QueryBooleanProperty<Movie>(_entities[0].properties[11]);

  /// See [Movie.size].
  static final size =
      obx.QueryIntegerProperty<Movie>(_entities[0].properties[12]);
}
