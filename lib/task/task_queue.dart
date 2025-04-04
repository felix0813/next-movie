import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:semaphore/lock.dart';
import 'package:semaphore/semaphore.dart';
import 'package:synchronized/extension.dart';

class TaskQueue with ChangeNotifier {
  static final TaskQueue _instance = TaskQueue._internal();
  static final Logger _logger = Logger('TaskQueue');

  factory TaskQueue() {
    return _instance;
  }

  TaskQueue._internal() {
    // 初始化时不启动 Timer，改为在任务完成时触发下一个批次
  }

  final Queue<TaskItem> tasks = Queue();
  final int maxConcurrentTasks = 2; // 每个批次允许的最大并发任务数
  final int batchSize = 4; // 每批次处理的任务数量
  final Duration batchInterval = Duration(milliseconds: 500); // 批次之间的间隔时间

  final Semaphore _semaphore = LocalSemaphore(2);
  final Lock _lock = Lock();

  int _runningTasks = 0;
  bool _isProcessing = false;

  final List<TaskError> _errors = [];
  int _errorCount = 0;

  /// 添加任务到队列，并尝试处理下一个批次
  void addTask(TaskItem task) {
    _lock.synchronized(() {
      tasks.add(task);
    });
    notifyListeners();
    _processNextBatch();
  }

  /// 处理下一个批次
  Future<void> _processNextBatch() async {
    await _lock.synchronized(() async {
      if (_isProcessing) return; // 如果正在处理，则跳过

      if (tasks.isEmpty) {
        _isProcessing = false;
        notifyListeners();
        return;
      }

      // 取出一个批次
      List<TaskItem> batch = [];
      for (int i = 0; i < batchSize && tasks.isNotEmpty; i++) {
        batch.add(tasks.removeFirst());
      }

      if (batch.isEmpty) {
        _isProcessing = false;
        notifyListeners();
        return;
      }

      _isProcessing = true;
      _runningTasks += batch.length;
      notifyListeners();

      // 处理批次中的任务
      await _executeBatch(batch);

      _runningTasks -= batch.length;
      _isProcessing = false;
      notifyListeners();

      // 添加间隔以保持 UI 响应
      await Future.delayed(batchInterval);

      // 继续处理下一个批次
      _processNextBatch();
    });
  }

  /// 执行单个批次中的所有任务
  Future<void> _executeBatch(List<TaskItem> batch) async {
    List<Future<void>> futures = [];

    for (final task in batch) {
      await _semaphore.acquire();
      // 使用 whenComplete 确保信号量被释放
      futures.add(
        _executeTask(task).whenComplete(() => _semaphore.release()),
      );
    }

    try {
      await Future.wait(futures);
    } catch (e) {
      _logger.severe('批次执行失败: $e');
    }
  }

  /// 执行单个任务
  Future<void> _executeTask(TaskItem task) async {
    try {
      await task.task();
      _logger.info('任务完成: ${task.id}');
    } catch (e) {
      _logger.severe('任务执行失败: $e');
      await _lock.synchronized(() {
        _errors.add(TaskError(task, e.toString()));
        _errorCount++;
      });
      notifyListeners();
    }
  }

  /// 获取当前正在运行的任务数量
  int get runningTasks => _runningTasks;

  /// 获取队列中的任务数量
  int get queueLength => tasks.length;

  /// 获取错误数量
  int get errorCount => _errorCount;

  /// 获取错误列表
  List<TaskError> get errors => List.unmodifiable(_errors);

  /// 清除所有错误记录
  void clearErrors() {
    _lock.synchronized(() {
      _errors.clear();
      _errorCount = 0;
    });
    notifyListeners();
  }
}

class TaskItem {
  final Future<void> Function() task;
  final String id;

  TaskItem(this.task, {this.id = ''});
}

/// 用于存储任务错误信息的类
class TaskError {
  final TaskItem task;
  final String error;
  static final Logger _logger = Logger('TaskError');

  TaskError(this.task, this.error);

  /// 重试任务
  Future<void> retry() async {
    try {
      await task.task();
      // 如果重试成功，可以选择不记录这个错误，或者标记为已解决
    } catch (e) {
      _logger.severe('重试任务失败: $e');
      rethrow; // 抛出异常，让上层处理
    }
  }
}
