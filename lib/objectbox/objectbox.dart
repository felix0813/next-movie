import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:next_movie/app_path.dart';
import 'objectbox.g.dart';

class ObjectBox {
  late final Store store;
  static ObjectBox? _instance; // ✅ 正确声明静态实例变量
   final _initCompleter = Completer<void>();

  // 私有构造函数
  ObjectBox._internal(this.store) {
    _initCompleter.complete();
  }

  /// 初始化ObjectBox（单例模式）
  static Future<ObjectBox> initialize() async {
    await _ensureInitialization();
    return _instance!;
  }

  /// 确保初始化完成（线程安全）
  static Future<void> _ensureInitialization() async {
      if (_instance == null) { // 双重检查防止重复初始化
        final dir = await _createDirectory();
        final store = await openStore(directory: dir.path);
        _instance = ObjectBox._internal(store); // ✅ 正确赋值静态实例
      }
  }

  /// 创建存储目录（如果不存在）
   static Future<Directory> _createDirectory() async {
    final docsDir = AppPaths.instance.appDocumentsDir;
    final fullPath = p.join(docsDir, 'next_movie', 'obx-next-movie');
    final dir = Directory(fullPath);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 获取全局实例（初始化后访问）
  static ObjectBox get instance => _instance!;

  /// 类型安全的Box获取
  static Box<T> getBox<T>() => _instance!.store.box<T>();
}