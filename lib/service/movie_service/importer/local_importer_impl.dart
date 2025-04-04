import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_media_info/flutter_media_info.dart';
import 'package:logging/logging.dart';
import 'package:media_info/media_info.dart' as m;
import 'package:next_movie/model/movie.dart';
import 'package:next_movie/objectbox/objectbox.dart';
import 'package:next_movie/objectbox/objectbox.g.dart';
import 'package:next_movie/service/movie_service/thumbnail_task.dart';
import 'package:next_movie/task/task_queue.dart';
import 'package:next_movie/utils/time.dart';

import 'importer.dart';

class LocalImporterImpl extends Importer {
  static final _logger = Logger('LocalImporterImpl');
  late List<Movie> _videos;
  final box = ObjectBox.getBox<Movie>();
  final Function()? updateUI;
  TaskQueue? taskQueue;

  @override
  int prepareData() {
    return 0;
  }

  @override
  Future<List<Movie>> getVideos() async {
    var result = await FilePicker.platform.pickFiles(
        allowMultiple: true, type: FileType.video, lockParentWindow: true);
    if (result != null) {
      _videos = result.files
          .map((e) => Movie(title: e.name, path: e.path ?? '', size: e.size))
          .toList();
    }
    return _videos;
  }

  Future<int> getVideoDuration(String path) async {
    if (Platform.isIOS || Platform.isAndroid) {
      try {
        final mf = m.MediaInfo();
        final result = await mf.getMediaInfo(path);
        int duration = result["durationMs"];
        return duration;
      } catch (e) {
        _logger.severe("Get duration of $path fail:$e");
        return 0;
      }
    } else {
      try {
        final mi = Mediainfo();
        mi.quickLoad(path);
        final movieDuration = mi.getInfo(
            MediaInfoStreamType.mediaInfoStreamVideo, 0, "Duration/String2");
        mi.close();
        return durationStringToSeconds(movieDuration);
      } catch (e) {
        _logger.severe("Get duration of $path fail:$e");
        return 0;
      }
    }
  }

  Future<void> getVideoCreatedTime(Movie movie) async {
    try {
      File file = File(movie.path);
      FileStat fileStat = await file.stat();
      DateTime creationTime = DateTime.fromMillisecondsSinceEpoch(
          fileStat.modified.millisecondsSinceEpoch);
      movie.created = creationTime.toString();
    } catch (e) {
      _logger.severe("获取文件创建时间失败：$e");
    }
  }

  @override
  Future<void> makeMeta() async {
    int count = 0;
    for (var video in _videos) {
      if (video.path == '') {
        continue;
      }
      if (box.query(Movie_.title.equals(video.title)).build().count() > 0) {
        video.title = '';
        continue;
      }
      video.recorded = DateTime.now().toLocal();
      video.duration = await getVideoDuration(video.path);
      await getVideoCreatedTime(video);
      storeMovie(video);
      count++;
      if (count % 10 == 0) {
        show();
      }
    }
    show();
  }

  @override
  void setExtraData(List<String> tags, int? rate, String? source,
      List<String> comments) async {
    for (var video in _videos) {
      video.tags = tags;
      video.star = rate;
      video.source = source;
      video.comment = comments;
    }
  }

  @override
  int storeMovie(Movie movie) {
    if (taskQueue == null) {
      return 0;
    }
    var id = 0;
    if (movie.path != '' && movie.title != '') {
      id = box.put(movie, mode: PutMode.insert);
    }
    AddThumbnailTask task = AddThumbnailTask(
      movieId: id,
      moviePath: movie.path,
      taskQueue: taskQueue!,
    );
    task.run();
    _logger.info("Add movie:${movie.title}");
    return id;
  }

  @override
  void show() {
    if (updateUI != null) {
      updateUI!();
    }
  }

  LocalImporterImpl(
      {List<Movie> videos = const [], this.taskQueue, this.updateUI})
      : _videos = videos;
}
