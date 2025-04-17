import 'package:flutter/material.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/ui/radio_dialog.dart';
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
        child: Column(
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
            )
          ],
        ),
      ),
    );
  }
}
