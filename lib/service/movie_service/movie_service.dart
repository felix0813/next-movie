import 'package:next_movie/provider/objectbox_provider.dart';

import 'package:next_movie/model/movie.dart';
import 'package:next_movie/objectbox/objectbox.g.dart';
import 'package:next_movie/service/movie_service/thumbnail_task.dart';
import 'package:next_movie/task/task_queue.dart';

class MovieService {
  late ObjectBoxProvider _objectBoxProvider;
  TaskQueue? _taskQueue;
  void deleteMovie(List<int> ids) {
    if (_taskQueue == null) {
      throw Exception("Task queue is not initialized");
    }
    //删除电影
    Box<Movie> box = _objectBoxProvider.getBox<Movie>();
    for (int id in ids) {
      int tmp = box.remove(id) ? id : 0;
      DeleteThumbnailTask(movieId: tmp, taskQueue: _taskQueue!).run();
    }
  }
}
