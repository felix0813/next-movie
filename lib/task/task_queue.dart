// task_queue.dart
import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class TaskQueue with ChangeNotifier {
  static final TaskQueue _instance = TaskQueue._internal();
  static final Logger _logger = Logger('TaskQueue');

  factory TaskQueue() {
    return _instance;
  }

  TaskQueue._internal();

  final Queue<TaskItem> tasks = Queue();
  int _runningTasks = 0;
  final int maxConcurrentTasks = 2; // 最大并发任务数

  final List<TaskError> _errors = [];
  int _errorCount = 0;

  /// 添加任务到队列
  void addTask(TaskItem task) {
    tasks.add(task);
    _processNextTask();
    notifyListeners();
  }

  /// 处理下一个任务
  Future<void> _processNextTask() async {
    if (_runningTasks >= maxConcurrentTasks) {
      return;
    }
    if (tasks.isEmpty) {
      return;
    }

    _runningTasks++;
    final task = tasks.removeFirst();
    try {
      await task.task();
    } catch (e) {
      _logger.severe('任务执行失败: $e');
      // 记录错误信息
      _errors.add(TaskError(task, e.toString()));
      _errorCount++;
      notifyListeners(); // 通知UI更新错误状态
    } finally {
      _runningTasks--;
      _processNextTask();
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
    _errors.clear();
    _errorCount = 0;
    notifyListeners(); // 通知UI更新
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
