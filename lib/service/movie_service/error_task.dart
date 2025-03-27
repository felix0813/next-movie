import 'package:next_movie/task/task_queue.dart';

class ErrorTask {
  late final String _message;
  late final String _taskId;
  late final TaskQueue _taskQueue;
  ErrorTask(
      {required String message,
      required TaskQueue taskQueue,
      required String taskId})
      : _message = message,
        _taskQueue = taskQueue,
        _taskId = taskId;
  void run() {
    _taskQueue.addTask(TaskItem(
      () async {
        throw (Exception(_message));
      },
      id: _taskId,
    ));
  }
}
