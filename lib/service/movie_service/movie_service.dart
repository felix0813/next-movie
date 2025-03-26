import 'package:flutter/cupertino.dart';

import 'package:next_movie/model/movie.dart';
import 'package:next_movie/service/movie_service/error_task.dart';
import 'package:next_movie/service/movie_service/thumbnail_task.dart';
import 'package:next_movie/task/task_queue.dart';

import 'package:next_movie/repository/movie_repository.dart';
import 'importer/local_importer_impl.dart';

class MovieService {
  final _repository = MovieRepository();

  final TaskQueue? _taskQueue;

  MovieService({TaskQueue? taskQueue}) : _taskQueue = taskQueue;

  void deleteMovieAndThumbnail(List<int> ids) {
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
    for (var id in ids) {
      DeleteThumbnailTask(movieId: id, taskQueue: _taskQueue).run();
    }
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
    LocalImporterImpl importer = LocalImporterImpl(taskQueue: _taskQueue);
    final result = await importer.getVideos();
    if (result.isEmpty) {
      return;
    }
    await importer.makeMeta();
    if (!context.mounted) {
      return;
    }
    final meta = await getExtraMeta(context);
    if (meta == null) {
      return;
    }
    importer.setExtraData(meta.tags, meta.rate, meta.source, meta.comments);
    importer.storeMovie();
  }

  List<Movie> getRecentAddMovie() => _repository.getRecentAddMovie();

  List<Movie> getFavoriteMovie() => _repository.getFavoriteMovie();

  List<Movie> getToWatchMovie() => _repository.getToWatchMovie();

  List<Movie> getRecentWatchMovie() {
    return [];
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
