import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/ui/radio_dialog.dart';
import 'package:next_movie/utils/app_path.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../service/movie_service/movie_service.dart';
import '../../service/movie_service/scan_folder_task.dart';
import '../../task/task_queue.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({
    super.key,
  });

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalNavigationBar(
        title: "Setting",
        showSetting: false,
        showSearch: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 10, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            buildCheckTools(context),
            Row(
              children: [
                Wrap(
                  runSpacing: 10,
                  children: [
                    TDButton(
                      text: "Movie folders",
                      icon: TDIcons.folder_add,
                      onTap: () => onCheckMovieFolder(context),
                    ),
                    SizedBox(width: 10),
                    TDButton(
                      text: "Scan folders",
                      icon: TDIcons.scan,
                      onTap: () => {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                title: Text('Scan Folders'),
                                content: SingleChildScrollView(
                                    child: Text(
                                        "This will scan videos and add them into database in the selected folders.\n Files nested in folders no more than five layers will be scanned.")),
                                actions: [
                                  TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                  TextButton(
                                      child: Text('Scan'),
                                      onPressed: () {
                                        for (var path in _readPaths()) {
                                          ScanFolderTask(
                                            path: path,
                                            taskQueue: Provider.of<TaskQueue>(
                                                context,
                                                listen: false),
                                            taskId: 'scan folder $path',
                                          ).run();
                                        }
                                      })
                                ]);
                          },
                        )
                      },
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Wrap buildCheckTools(BuildContext context) {
    return Wrap(
      runSpacing: 10,
      children: [
        TDButton(
          text: "Check movies",
          icon: TDIcons.data_checked,
          onTap: () => onCheckMovie(context),
        ),
        SizedBox(width: 10),
        TDButton(
          text: "Check log",
          icon: TDIcons.system_log,
          onTap: () => onCheckLog(context),
        )
      ],
    );
  }

  void onCheckLog(BuildContext context) {
    try {
      // 获取应用文档目录
      final logDirPath =
          join(AppPaths.instance.appDocumentsDir, "next_movie", "log");
      final logDir = Directory(logDirPath);
      // 获取符合命名格式的日志文件并按时间排序
      final logFiles = logDir.listSync().where((file) {
        final fileName = file.uri.pathSegments.last;
        return RegExp(
          r'^check-\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}\.log$',
        ).hasMatch(fileName);
      }).toList()
        ..sort((a, b) => b.path.compareTo(a.path));

      if (logFiles.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Logs Found'),
            content: const Text('No log files available in the log directory.'),
          ),
        );
      } else {
        final latestFile = logFiles.first;
        final content = File(latestFile.path).readAsStringSync();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Latest Log Content'),
            content: SingleChildScrollView(
              child: Text(
                content,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to read logs: $e'),
        ),
      );
    }
  }

  void onCheckMovie(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return CheckMovieRadioDialog(
              onConfirm: (checked) {
                final movieService = MovieService(
                  taskQueue: Provider.of<TaskQueue>(context, listen: false),
                );
                movieService.checkFilesValid(
                    checked.contains("Remove invalid movies"),
                    checked.contains("Generate a report"));
              },
              options: ["Generate a report", "Remove invalid movies"]);
        });
  }

  Future<void> onCheckMovieFolder(BuildContext context) async {
    final paths = _readPaths();
    final parent = context;
    if (parent.mounted) {
      showDialog(
        context: parent,
        builder: (context) {
          return AlertDialog(
            title: Text('Movie Folders'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: paths.isNotEmpty
                    ? paths.map((p) => ListTile(title: Text(p))).toList()
                    : [
                        Text('No movie folders found.'),
                      ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Add Folder'),
                onPressed: () async {
                  final path = await _addPath();
                  if (path != null) {
                    paths.add(path);
                    final file = File(join(AppPaths.instance.appDocumentsDir,
                        "next_movie", "setting", "folders.txt"));
                    file.writeAsStringSync(paths.join('\n'));
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  if (parent.mounted) {
                    onCheckMovieFolder(parent);
                  }
                },
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'))
            ],
          );
        },
      );
    }
  }

  List<String> _readPaths() {
    try {
      final file = File(join(AppPaths.instance.appDocumentsDir, "next_movie",
          "setting", "folders.txt"));
      if (file.existsSync()) {
        file.createSync(recursive: true);
      }
      final contents = file.readAsStringSync();
      return contents.split('\n').where((line) => line.isNotEmpty).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> _addPath() async => FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select Movie Folder", lockParentWindow: true);
}
