import 'package:flutter/material.dart';
import 'package:next_movie/service/category_service/category_service.dart';
import 'package:next_movie/service/movie_service/movie_service.dart';
import 'package:next_movie/ui/input_dialog.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:next_movie/task/task_queue.dart';
import 'movie_extra_meta_form.dart';

class GlobalNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Function? onMovieUpdate;
  final Function? onCategoryUpdate;
  const GlobalNavigationBar({super.key, required this.title, this.onMovieUpdate, this.onCategoryUpdate});
  Future<MovieExtraMeta?> getExtraMeta(BuildContext context) {
    return showModalBottomSheet<MovieExtraMeta>(
      context: context,
      builder: (context) {
        return MovieExtraMetaForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(TDIcons.file_import),
          tooltip: 'import video',
          onPressed: () {
            final movieService = MovieService(
                taskQueue: Provider.of<TaskQueue>(context, listen: false));
            movieService.importMovie(getExtraMeta, context).then((_) {
              if (onMovieUpdate != null) {
                onMovieUpdate!();
              }
            });
          },
        ),
        IconButton(
          icon: Icon(TDIcons.folder_import),
          tooltip: 'add category',
          onPressed: () {
            DoubleInputDialog.show(
                    context: context, maxLength2: 100, title: 'Add Category', maxLength1: 20,hintText1: "category name",hintText2: "category description")
                .then((pair) {
              if (pair != null&&pair.first!=null&&pair.first!.trim().isNotEmpty) {
                final service = CategoryService();
                if(service.create(pair.first!, pair.second)&&onCategoryUpdate!=null){
                  onCategoryUpdate!();
                }
              }
            });
          },
        ),
        buildTaskWarning(),
      ],
    );
  }

  Consumer<TaskQueue> buildTaskWarning() {
    return Consumer<TaskQueue>(
      builder: (context, taskQueue, child) {
        final errorCount = taskQueue.errorCount;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              tooltip: 'show task status',
              onPressed: () {
                if (errorCount > 0) {
                  _showErrorDialog(context, taskQueue);
                } else {
                  _showTaskStatusDialog(context, taskQueue);
                }
              },
            ),
            if (errorCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: TDBadge(
                  TDBadgeType.redPoint,
                  count: errorCount.toString(),
                ),
              ),
          ],
        );
      },
    );
  }

  // 显示任务状态对话框
  Future<void> _showTaskStatusDialog(
      BuildContext context, TaskQueue taskQueue) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Task Status'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(TDIcons.loading),
                title: Text('Running Task: ${taskQueue.runningTasks}'),
              ),
              ListTile(
                leading: const Icon(Icons.queue),
                title: Text('Waiting Task: ${taskQueue.queueLength}'),
              ),
              if (taskQueue.queueLength > 0)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: taskQueue.queueLength,
                  itemBuilder: (context, index) {
                    final task = taskQueue.tasks.elementAt(index);
                    return ListTile(
                      title: Text('Task ${index + 1} (ID: ${task.id})'),
                      subtitle: task.task is Future<void>
                          ? null
                          : Text(
                              'Detail: ${task.task.toString()}'), // 根据需要显示更多任务信息
                    );
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // 显示错误详情对话框并清除错误
  Future<void> _showErrorDialog(
      BuildContext context, TaskQueue taskQueue) async {
    final errors = taskQueue.errors;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errors.isEmpty)
                const Text('No error')
              else
                Column(
                  children:
                      errors.map((e) => _buildErrorItem(context, e)).toList(),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              taskQueue.clearErrors();
              Navigator.of(ctx).pop(); // 关闭对话框
            },
            child: const Text('清除所有错误'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // 仅关闭对话框
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 构建单个错误项
  Widget _buildErrorItem(BuildContext context, TaskError error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.red),
        title: Text('Task ${error.task.id} fail'),
        subtitle: Text(error.error),
        trailing: IconButton(
          icon: const Icon(Icons.refresh, color: Colors.blue),
          onPressed: () async {
            try {
              await error.retry();
              // 重试成功后，可以选择不立即清除，但通常需要重新检查任务状态
              // 这里可以选择不自动清除，而是让用户再次查看状态
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Task ${error.task.id} succeed by retrying')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Retry ${error.task.id} fail: $e')),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
