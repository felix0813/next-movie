import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_media_info/flutter_media_info.dart';
import 'package:logging/logging.dart';
import 'package:next_movie/model/movie.dart';
import 'package:next_movie/service/movie_service/thumbnail_task.dart';
import 'package:next_movie/utils/time.dart';

import 'package:next_movie/provider/objectbox_provider.dart';
import 'package:next_movie/task/task_queue.dart';
import 'package:next_movie/objectbox/objectbox.g.dart';
import 'importer.dart';

class LocalImporterImpl extends Importer {
  static final _logger = Logger('LocalImporterImpl');
  late List<Movie> _videos;
  ObjectBoxProvider objectBoxProvider;
  TaskQueue? taskQueue;

  @override
  int prepareData() {
    return 0;
  }

  @override
  Future<List<Movie>> getVideos() async {
    var result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.video);
    if (result != null) {
      _videos = result.files
          .map((e) => Movie(title: e.name, path: e.path ?? '', size: e.size))
          .toList();
    }
    return _videos;
  }

  int getVideoDuration(String path) {
    if (Platform.isIOS || Platform.isAndroid) {
      return 0;
    } else {
      final mi = Mediainfo();
      mi.quickLoad(path);
      final movieDuration = mi.getInfo(
          MediaInfoStreamType.mediaInfoStreamVideo, 0, "Duration/String2");
      mi.close();
      return durationStringToSeconds(movieDuration);
    }
  }

  Future<void> getVideoCreatedTime(Movie movie) async {
    try {
      File file = File(movie.path);
      // 获取文件的FileStat信息
      FileStat fileStat = await file.stat();

      // 格式化并打印创建(最后修改)时间
      DateTime creationTime = DateTime.fromMillisecondsSinceEpoch(
          fileStat.modified.millisecondsSinceEpoch);
      movie.created = creationTime.toString();
    } catch (e) {
      _logger.severe("获取文件创建时间失败：$e");
    }
  }

  @override
  Future<void> makeMeta() async {
    for (var video in _videos) {
      if (video.path == '') {
        continue;
      }
      Box box = objectBoxProvider.getBox<Movie>();
      if (box.query(Movie_.title.equals(video.title)).build().count() > 0) {
        video.title = '';
        continue;
      }
      video.duration = getVideoDuration(video.path);
      video.recorded = DateTime.now().toLocal().toString().split(".")[0];
      await getVideoCreatedTime(video);
    }
  }

  @override
  Future<void> setExtraData(
      List<String> tags, int rate, String source, List<String> comments) async {
    for (var video in _videos) {
      video.tags = tags;
      video.star = rate;
      video.source = source;
      video.comment = comments;
    }
  }

  @override
  int storeMovie() {
    if (taskQueue == null) {
      return 0;
    }
    final box = objectBoxProvider.getBox<Movie>();
    int count = 0;
    for (var video in _videos) {
      var id = 0;
      if (video.path != '' && video.title != '') {
        id = box.put(video);
        count++;
      }
      ThumbnailTask task = ThumbnailTask(
          movieId: id,
          moviePath: video.path,
          taskQueue: taskQueue!,
          objectBoxProvider: objectBoxProvider);
      task.run();
    }
    return count;
  }

  @override
  void show() {
    // TODO: implement show
  }

  LocalImporterImpl(
      {List<Movie> videos = const [],
      required this.objectBoxProvider,
      this.taskQueue})
      : _videos = videos;
}
