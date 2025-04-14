import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:next_movie/model/movie.dart';
import 'package:next_movie/model/sort_by.dart';
import 'package:next_movie/repository/category_repository.dart';
import 'package:next_movie/repository/movie_repository.dart';
import 'package:next_movie/service/movie_service/error_task.dart';
import 'package:next_movie/service/movie_service/thumbnail_task.dart';
import 'package:next_movie/task/task_queue.dart';
import 'package:path/path.dart';

import '../../utils/app_path.dart';
import '../log_manager.dart';
import 'importer/local_importer_impl.dart';

class MovieService {
  final _repository = MovieRepository();

  final TaskQueue? _taskQueue;
  final Function()? updateUI;

  MovieService({
    TaskQueue? taskQueue,
    this.updateUI,
  }) : _taskQueue = taskQueue;

  List<int> deleteMovieAndThumbnail(List<int> ids) {
    if (_taskQueue == null) {
      throw Exception("Task queue is not initialized");
    }
    final fail = _repository.deleteMovie(ids);
    for (var id in fail) {
      ids.remove(id);
      Movie? movie = _repository.getMovieById(id);
      if (movie != null) {
        ErrorTask(
                message: "Fail to delete movie of path: ${movie.path}",
                taskQueue: _taskQueue,
                taskId: 'delete movie error: ${movie.path}')
            .run();
      }
    }
    final categoryRepository = CategoryRepository();
    categoryRepository.getAllCategories().forEach(
        (category) => categoryRepository.removeMovies(category.id, ids));
    for (var id in ids) {
      DeleteThumbnailTask(movieId: id, taskQueue: _taskQueue).run();
    }
    return ids;
  }

  bool like(int id, bool like) {
    Movie? movie = _repository.getMovieById(id);
    if (movie != null) {
      movie.likeDate = like ? DateTime.now().toLocal() : null;
      return _repository.storeMovie(movie) == id;
    }
    return false;
  }

  bool wish(int id, bool wish) {
    Movie? movie = _repository.getMovieById(id);
    if (movie != null) {
      movie.wishDate = wish ? DateTime.now().toLocal() : null;
      return _repository.storeMovie(movie) == id;
    }
    return false;
  }

  bool star(int id, int stars) {
    Movie? movie = _repository.getMovieById(id);
    if (movie != null) {
      movie.star = stars;
      return _repository.storeMovie(movie) == id;
    }
    return false;
  }

  bool addSource(int id, String source) {
    Movie? movie = _repository.getMovieById(id);
    if (movie != null) {
      movie.source = source;
      return _repository.storeMovie(movie) == id;
    }
    return false;
  }

  bool updateTags(int id, List<String> tags) {
    Movie? movie = _repository.getMovieById(id);
    if (movie != null) {
      movie.tags = tags;
      return _repository.storeMovie(movie) == id;
    }
    return false;
  }

  bool updateComments(int id, List<String> comments) {
    Movie? movie = _repository.getMovieById(id);
    if (movie != null) {
      movie.comment = comments;
      return _repository.storeMovie(movie) == id;
    }
    return false;
  }

  Future<void> importMovie(
      Future<MovieExtraMeta?> Function(BuildContext) getExtraMeta,
      BuildContext context) async {
    if (_taskQueue == null) {
      throw Exception("Task queue is not initialized");
    }
    LocalImporterImpl importer =
        LocalImporterImpl(taskQueue: _taskQueue, updateUI: updateUI);
    final result = await importer.getVideos();
    if (result.isEmpty) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final meta = await getExtraMeta(context);
    if (meta == null) {
      return;
    }
    importer.setExtraData(meta.tags, meta.rate, meta.source, meta.comments);
    await importer.makeMeta();
  }

  List<Movie> getRecentAddMovie() => _repository.getRecentAddMovie();

  List<Movie> getFavoriteMovie() => _repository.getFavoriteMovie();

  List<int> getRecentAddMovieInHome() => _repository.getRecentIds();

  List<int> getFavoriteMovieInHome() => _repository.getFavouriteIds();

  List<int> getToWatchMovieInHome() => _repository.getToWatchMovieIds();

  void generateThumbnail(int id) {
    final movie = _repository.getMovieById(id);
    if (movie == null || movie.path.isEmpty || _taskQueue == null) {
      return;
    }
    AddThumbnailTask(movieId: id, moviePath: movie.path, taskQueue: _taskQueue)
        .run();
  }

  Movie? getMovieById(int id) => _repository.getMovieById(id);

  List<int> getRecentWatchMovie() {
    return [];
  }

  List<int> getOnePageMovies(
          {int page = 0,
          String orderBy = SortBy.recorded,
          String order = SortOrder.descending}) =>
      _repository.getOnePageVideos(page, orderBy, order);

  int? getLatestMovieId() => _repository.getLatestMovie()?.id;

  int getTotalMovies() => _repository.getTotalCount();

  bool renameMovie(int id, String title) {
    if (!_repository.checkMovieNameValid(title)) {
      return false;
    }
    Movie? movie = _repository.getMovieById(id);
    if (movie == null) {
      return false;
    }
    File oldFile = File(movie.path);
    Directory d = oldFile.parent;
    File newFile = File(join(d.path, title));
    if (newFile.existsSync()) {
      return false;
    }
    if (oldFile.renameSync(newFile.path).existsSync()) {
      movie.path = newFile.path;
      movie.title = title;
      _repository.storeMovie(movie);
      return true;
    }
    return false;
  }

  checkFilesValid(bool delete, bool log) async {
    final movies = _repository.getAllMovie();
    List<String> paths = movies.map((movie) => movie.path).toList();
    List<int> ids = movies.map((movie) => movie.id).toList();
    await _performFileCheckInBackground(paths, ids, delete, log,
        join(AppPaths.instance.appDocumentsDir, "next_movie", "log"));
  }

  // 2. 文件检查与处理逻辑
  static Future<List<int>> _checkAndProcessFiles(HashMap params) async {
    List<int> invalid = List.empty(growable: true);
    final filePaths = params['filePaths'] as List<String>;
    final delete = params['delete'] as bool;
    final needLog = params['log'] as bool;
    final logPath = params['logPath'] as String;
    final logManager = LogManager(logPath);
    final ids = params['ids'];
    var taskId = 'check-${DateTime.now().toLocal()}';
    for (int i = 0; i < filePaths.length; i++) {
      final filePath = filePaths[i];
      try {
        final file = File(filePath);
        // 检查文件是否存在（参考[6](@ref)）
        final valid = await file.exists();

        if (!valid) {
          if (delete) {
            invalid.add(ids[i]);
          }
          if (needLog) {
            logManager.logToFile(taskId, '不可用路径：$filePath');
          }
        }
      } catch (e) {
        logManager.logToFile(taskId, '处理文件时出错：$filePath，错误：$e');
      }
    }
    return invalid;
  }

  Future<void> _performFileCheckInBackground(List<String> filePaths,
      List<int> ids, bool delete, bool log, logPath) async {
    HashMap map = HashMap();
    map['filePaths'] = filePaths;
    map['delete'] = delete;
    map['log'] = log;
    map['ids'] = ids;
    map['logPath'] = logPath;
    List<int> result =
        await compute<HashMap, List<int>>(_checkAndProcessFiles, map);
    if (delete) {
      deleteMovieAndThumbnail(result);
    }
  }
}

class MovieExtraMeta {
  late List<String> tags;
  late List<String> comments;
  int? rate;
  String? source;
  MovieExtraMeta(
      {this.tags = const [], this.comments = const [], this.rate, this.source});

  @override
  String toString() {
    return "tags:$tags comments:$comments rate:$rate source:$source";
  }
}
