import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';

import '../../task/task_queue.dart';

class ScanFolderTask {
  late final String path;
  late final String taskId;
  late final TaskQueue taskQueue;
  ScanFolderTask(
      {required this.path, required this.taskQueue, required this.taskId});
  static List<String> _scanDirectoryWithDepth(ScanParams params) {
    return _scanDirectory(Directory(params.path), 1, params.maxDepth);
  }

  /// 递归扫描目录
  static List<String> _scanDirectory(
      Directory dir, int currentDepth, int maxDepth) {
    if (currentDepth > maxDepth) {
      return [];
    }

    List<String> videoFiles = [];

    try {
      // 获取目录下的所有文件和子目录
      final List<FileSystemEntity> entities = dir.listSync();

      for (final entity in entities) {
        if (entity is File) {
          if (isVideo(entity.path)) {
            videoFiles.add(entity.path);
          }
        } else if (entity is Directory) {
          // 递归扫描子目录
          videoFiles.addAll(_scanDirectory(entity, currentDepth + 1, maxDepth));
        }
      }
    } catch (e) {
      // 处理单个目录访问错误
      print('Error scanning directory ${dir.path}: $e');
    }

    return videoFiles;
  }

  /// 扫描完成回调
  void _onScanComplete(List<String> videoFiles) {
    // 这里可以处理扫描结果，比如发送到主线程更新UI
    print('Found ${videoFiles.length} video files');
    //todo
    // 实际项目中应该通过某种方式将结果传回主线程
  }

  /// 扫描错误回调
  void _onScanError(dynamic error) {
    print('Scan error: $error');
    //todo
    // 处理错误情况
  }

  void run() {
    taskQueue.addTask(TaskItem(
      () async {
        try {
          // 使用compute在后台线程执行扫描
          final videoFiles = await compute(
            _scanDirectoryWithDepth,
            ScanParams(path: path, maxDepth: 5),
          );

          // 处理扫描结果
          _onScanComplete(videoFiles);
        } catch (e) {
          // 处理异常
          _onScanError(e);
        }
      },
      id: taskId,
    ));
  }

  static bool isVideo(String path) =>
      lookupMimeType(path)?.startsWith("video") ?? false;
}

class ScanParams {
  final String path;
  final int maxDepth;

  ScanParams({required this.path, required this.maxDepth});
}
