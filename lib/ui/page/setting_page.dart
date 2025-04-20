import 'dart:io';

import 'package:flutter/material.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/ui/radio_dialog.dart';
import 'package:next_movie/utils/app_path.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../service/movie_service/movie_service.dart';
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
          children: [
            Wrap(
              runSpacing: 10,
              children: [
                TDButton(
                  text: "Check movies",
                  icon: TDIcons.scan,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return CheckMovieRadioDialog(
                              onConfirm: (checked) {
                                final movieService = MovieService(
                                  taskQueue: Provider.of<TaskQueue>(context,
                                      listen: false),
                                );
                                movieService.checkFilesValid(
                                    checked.contains("Remove invalid movies"),
                                    checked.contains("Generate a report"));
                              },
                              options: [
                                "Generate a report",
                                "Remove invalid movies"
                              ]);
                        });
                  },
                ),
                SizedBox(width: 10),
                TDButton(
                  text: "Check log",
                  icon: TDIcons.system_log,
                  onTap: () {
                    try {
                      // 获取应用文档目录
                      final logDirPath =
                          join(AppPaths.instance.appDocumentsDir,"next_movie", "log");
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
                            content: const Text(
                                'No log files available in the log directory.'),
                          ),
                        );
                      } else {
                        final latestFile = logFiles.first;
                        final content =
                            File(latestFile.path).readAsStringSync();
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
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
