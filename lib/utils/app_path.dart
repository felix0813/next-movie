import 'dart:async';

import 'package:path_provider/path_provider.dart';

class AppPaths {
  // 单例实例
  static final _instance = AppPaths._internal();

  // 私有构造函数
  AppPaths._internal();

  // 获取单例实例
  static AppPaths get instance => _instance;

  // 应用文档目录路径（初始化后不可变）
  late String _appDocumentsDir;

  // 异步初始化路径
  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    _appDocumentsDir = directory.path;
  }

  // 获取全局路径
  String get appDocumentsDir => _appDocumentsDir;
}