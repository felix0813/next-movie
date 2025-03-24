import 'package:flutter/cupertino.dart';
import 'package:next_movie/provider/objectbox_provider.dart';

import 'package:next_movie/model/movie.dart';
import 'package:next_movie/objectbox/objectbox.g.dart';
import 'package:next_movie/service/movie_service/thumbnail_task.dart';
import 'package:next_movie/task/task_queue.dart';

import 'importer/local_importer_impl.dart';

class MovieService {
  late final ObjectBoxProvider _objectBoxProvider;
  final TaskQueue? _taskQueue;
  MovieService(
      {required ObjectBoxProvider objectBoxProvider, TaskQueue? taskQueue})
      : _objectBoxProvider = objectBoxProvider,
        _taskQueue = taskQueue;
  void deleteMovie(List<int> ids) {
    if (_taskQueue == null) {
      throw Exception("Task queue is not initialized");
    }
    //删除电影
    Box<Movie> box = _objectBoxProvider.getBox<Movie>();
    for (int id in ids) {
      int tmp = box.remove(id) ? id : 0;
      DeleteThumbnailTask(movieId: tmp, taskQueue: _taskQueue).run();
    }
  }

  Future<void> importMovie(
      Future<MovieExtraMeta?> Function(BuildContext) getExtraMeta,
      BuildContext context) async {
    if (_taskQueue == null) {
      throw Exception("Task queue is not initialized");
    }
    LocalImporterImpl importer = LocalImporterImpl(
        objectBoxProvider: _objectBoxProvider, taskQueue: _taskQueue);
    final result=await importer.getVideos();
    if(result.isEmpty){
      return;
    }
    await importer.makeMeta();
    if(!context.mounted){
      return;
    }
    final meta = await getExtraMeta(context);
    if (meta == null) {
      return;
    }
    importer.setExtraData(meta.tags, meta.rate, meta.source, meta.comments);
    importer.storeMovie();
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
