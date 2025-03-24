import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:next_movie/task/task_queue.dart';
import 'package:next_movie/ui/page/home_page.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'app_path.dart';
import 'provider/objectbox_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 设置根日志器的级别为ALL，表示记录所有级别的日志
  Logger.root.level = Level.ALL;
  await AppPaths.instance.initialize(); // 初始化路径
  // 监听日志记录事件，并通过print函数输出日志信息
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
// 获取应用文档目录路径
  Directory appDocDir = Directory(AppPaths.instance.appDocumentsDir);
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
      home: const HomePage(),
    );
  }
}

