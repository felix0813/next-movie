import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:logging/logging.dart';
import 'package:next_movie/model/movie.dart';
import 'package:next_movie/task/task_queue.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../objectbox/objectbox_provider.dart';

class ThumbnailTask {
  late final int _movieId;
  late final String _moviePath;
  late final TaskQueue _taskQueue;
  late final ObjectBoxProvider _objectBoxProvider;
  ThumbnailTask({
    required int movieId,
    required String moviePath,
    required TaskQueue taskQueue,
    required ObjectBoxProvider objectBoxProvider,
  })  : _objectBoxProvider = objectBoxProvider,
        _moviePath = moviePath,
        _movieId = movieId,
        _taskQueue = taskQueue;
  static final _logger = Logger('ThumbnailTask');
  void run() {
    _taskQueue.addTask(TaskItem(
      () async {
        final plugin = FcNativeVideoThumbnail();
        try {
          String path = join((await getApplicationDocumentsDirectory()).path,
              "next_movie", "poster", "$_movieId.jpg");
          final thumbnailGenerated = await plugin.getVideoThumbnail(
              srcFile: _moviePath,
              destFile: path,
              width: 300,
              height: 300,
              format: 'jpeg',
              quality: 90);
          if (thumbnailGenerated) {
            _logger.info('Thumbnail for $_movieId generated');
            final box = _objectBoxProvider.getBox<Movie>();
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
          // Handle platform errors.
          _logger.severe('Thumbnail for $_movieId Error: $err');
        }
      },
      id: 'thumbnail for $_movieId ',
    ));
  }
}
