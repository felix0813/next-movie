import 'dart:io';

import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:logging/logging.dart';
import 'package:next_movie/model/movie.dart';
import 'package:next_movie/objectbox/objectbox.dart';
import 'package:next_movie/task/task_queue.dart';
import 'package:next_movie/utils/app_path.dart';
import 'package:path/path.dart';

class AddThumbnailTask {
  late final int _movieId;
  late final String _moviePath;
  late final TaskQueue _taskQueue;
  AddThumbnailTask({
    required int movieId,
    required String moviePath,
    required TaskQueue taskQueue,
  })  : _moviePath = moviePath,
        _movieId = movieId,
        _taskQueue = taskQueue;
  static final _logger = Logger('AddThumbnailTask');
  void run() {
    _taskQueue.addTask(TaskItem(
      () async {
        if (_movieId == 0) {
          if (_moviePath == '') {
            throw Exception(
                "A movie path is invalid. Please check your final result.");
          }
          throw Exception(
              "Movie title is duplicated, please check the movie with path: $_moviePath");
        }
        final plugin = FcNativeVideoThumbnail();
        try {
          String path = join(AppPaths.instance.appDocumentsDir, "next_movie",
              "poster", "$_movieId.jpg");
          final thumbnailGenerated = await plugin.getVideoThumbnail(
              srcFile: _moviePath,
              destFile: path,
              width: 300,
              height: 300,
              format: 'jpeg',
              quality: 90);
          if (thumbnailGenerated) {
            _logger.info('Thumbnail for $_movieId generated');
            final box = ObjectBox.getBox<Movie>();
            final movie = box.get(_movieId);
            if (movie == null) {
              _logger.warning('Movie $_movieId not found');
              return;
            }
            movie.cover = [path];
            box.put(movie);
          } else {
            _logger.warning('Thumbnail for $_movieId not generated');
          }
        } catch (err) {
          throw (Exception('Thumbnail for $_movieId Error: $err'));
        }
      },
      id: 'generate thumbnail for $_movieId ',
    ));
  }
}

class DeleteThumbnailTask {
  late final int _movieId;
  late final TaskQueue _taskQueue;
  DeleteThumbnailTask({
    required int movieId,
    required TaskQueue taskQueue,
  })  : _movieId = movieId,
        _taskQueue = taskQueue;
  static final _logger = Logger('DeleteThumbnailTask');
  void run() {
    _taskQueue.addTask(TaskItem(
      () async {
        if (_movieId == 0) {
          throw Exception("Delete movie error: Database fail to remove movie");
        }
        try {
          String filePath = join(AppPaths.instance.appDocumentsDir,
              "next_movie", "poster", "$_movieId.jpg");
          File file = File(filePath);
          // 检查文件是否存在
          if (file.existsSync()) {
            // 删除文件
            file.deleteSync();
            _logger.info('Thumbnail is deleted: $_movieId');
          } else {
            _logger.info('Thumbnail does not exist: $_movieId');
          }
        } catch (err) {
          throw (Exception('Remove thumbnail for $_movieId Error: $err'));
        }
      },
      id: 'remove thumbnail for $_movieId ',
    ));
  }
}
