import 'dart:io';

import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_media_info/flutter_media_info.dart';
import 'package:next_movie/model/movie.dart';
import 'package:next_movie/utils/time.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';

import '../objectbox/objectbox_provider.dart';
import '../task/task_queue.dart';
import 'importer.dart';

class LocalImporterImpl extends Importer {
  late List<Movie> videos;

  @override
  int prepareData() {
    return 0;
  }

  @override
  Future<List<Movie>> getVideos() async {
    var result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.video);
    if (result != null) {
      videos = result.files
          .map((e) => Movie(title: e.name, path: e.path ?? '', size: e.size))
          .toList();
    }
    return videos;
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
      print("获取文件创建时间失败：$e");
    }
  }

  @override
  Future<void> makeMeta() async {
    for (var video in videos) {
      video.duration = getVideoDuration(video.path);
      await getVideoCreatedTime(video);
    }
  }

  @override
  Future<void> setExtraData(
      List<String> tags, int rate, String source, List<String> comments) async {
    for (var video in videos) {
      video.tags = tags;
      video.star = rate;
      video.source = source;
      video.comment = comments;
    }
  }

  @override
  int storeMovie(BuildContext context) {
    // 获取 ObjectBoxProvider
    final objectBoxProvider = Provider.of<ObjectBoxProvider>(context,listen: false);
    final taskQueue = Provider.of<TaskQueue>(context,listen: false);
    final box = objectBoxProvider.getBox<Movie>();
    int count = 0;
    for (var video in videos) {
      int id=box.put(video);
      count++;
      taskQueue.addTask(TaskItem(
        () async {
          final plugin = FcNativeVideoThumbnail();
          try {
            String path=join((await getApplicationDocumentsDirectory()).path,"next_movie","poster","$id.jpg");
            print(path);
            final thumbnailGenerated = await plugin.getVideoThumbnail(
                srcFile: video.path,
                destFile: path,
                width: 300,
                height: 300,
                format: 'jpeg',
                quality: 90);
            print('Thumbnail for ${video.title} generated');
          } catch (err) {
            // Handle platform errors.
            print('Thumbnail for ${video.title} Error: $err');
          }
        },
        id: 'thumbnail for $id: ${video.title}',
      ));
    }
    return count;
  }

  @override
  void show() {
    // TODO: implement show
  }

  LocalImporterImpl({this.videos = const []});
}
