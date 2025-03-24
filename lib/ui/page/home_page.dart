import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../../provider/objectbox_provider.dart';
import '../../service/movie_service/importer/local_importer_impl.dart';
import '../../service/movie_service/movie_service.dart';
import '../../task/task_queue.dart';
import '../global_navigation_bar.dart';
import '../movie_extra_meta_form.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final _logger = Logger('_MyHomePageState');
  late LocalImporterImpl importer;

  Future<MovieExtraMeta?> getExtraMetaForm(BuildContext context) {
    return showModalBottomSheet<MovieExtraMeta>(
      context: context,
      builder: (context) {
        return MovieExtraMetaForm();
      },
    );
  }
  // all videos,all categories ,like
  // recent add,
  // recent watch
  // to watch
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalNavigationBar(
        title: "首页",
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final movieService = MovieService(
                objectBoxProvider:
                Provider.of<ObjectBoxProvider>(context, listen: false),
                taskQueue: Provider.of<TaskQueue>(context, listen: false));
            movieService.importMovie(getExtraMetaForm, context);
          },
          child: Text("选择视频文件"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
