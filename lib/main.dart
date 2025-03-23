import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:next_movie/service/movie_service/movie_service.dart';
import 'package:next_movie/task/task_queue.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/ui/movie_extra_meta_form.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:next_movie/service/movie_service/importer/local_importer_impl.dart';
import 'provider/objectbox_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 设置根日志器的级别为ALL，表示记录所有级别的日志
  Logger.root.level = Level.ALL;

  // 监听日志记录事件，并通过print函数输出日志信息
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
// 获取应用文档目录路径
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  var logger = Logger('main');

  // 创建文件夹
  Directory posterFolder = Directory(join(appDocPath, "next_movie", "poster"));
  if (!await posterFolder.exists()) {
    await posterFolder.create(recursive: true);
    logger.info('文件夹创建成功: ${posterFolder.path}');
    await posterFolder.create();
  } else {
    logger.info('文件夹已存在: ${posterFolder.path}');
  }
  // 初始化 ObjectBoxProvider
  final objectBoxProvider = ObjectBoxProvider();
  await objectBoxProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: objectBoxProvider),
        ChangeNotifierProvider(create: (_) => TaskQueue()),
        // 如果有其他 providers，可以在这里添加
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: GlobalNavigationBar(
        title: "首页",
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
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
