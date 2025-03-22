// task_queue.dart
import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';

class TaskQueue with ChangeNotifier {
  static final TaskQueue _instance = TaskQueue._internal();

  factory TaskQueue() {
    return _instance;
  }

  TaskQueue._internal();

  final Queue<TaskItem> _tasks = Queue();
  int _runningTasks = 0;
  final int maxConcurrentTasks = 2; // 最大并发任务数

  /// 添加任务到队列
  void addTask(TaskItem task) {
    _tasks.add(task);
    _processNextTask();
    notifyListeners();
  }

  /// 处理下一个任务
  Future<void> _processNextTask() async {
    if (_runningTasks >= maxConcurrentTasks) {
      return;
    }
    if (_tasks.isEmpty) {
      return;
    }

    _runningTasks++;
    final task = _tasks.removeFirst();
    try {
      await task.task();
    } catch (e) {
      print('任务执行失败: $e');
    } finally {
      _runningTasks--;
      _processNextTask();
      notifyListeners();
    }
  }

  /// 获取当前正在运行的任务数量
  int get runningTasks => _runningTasks;

  /// 获取队列中的任务数量
  int get queueLength => _tasks.length;
}

class TaskItem {
  final Future<void> Function() task;
  final String id;

  TaskItem(this.task, {this.id = ''});
}