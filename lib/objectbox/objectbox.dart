// object_box.dart
import 'dart:async';
import 'package:next_movie/app_path.dart';
import 'package:path/path.dart' as p;

import 'objectbox.g.dart';

/// ObjectBox instance singleton
class ObjectBox {
  /// The Store of this app.
  late final Store store;

  /// Private constructor to prevent direct instantiation.
  ObjectBox._internal(this.store);

  /// Singleton instance of ObjectBox.
  static Future<ObjectBox>? _futureInstance;
  static ObjectBox? _instance;

  /// Initialize the ObjectBox instance asynchronously.
  /// Call this in your `main()` function before running the app.
  static Future<void> init() async {
    _futureInstance ??= _create();
  }

  /// Lazily creates the ObjectBox instance.
  static Future<ObjectBox> _create() async {
    try {
      final docsDir = AppPaths.instance.appDocumentsDir;
      final storePath = p.join(docsDir,"next_movie", "obx-next-movie");
      final store = await openStore(directory: storePath);
      _instance = ObjectBox._internal(store);
      return _instance!;
    } catch (e) {
      // Log the error or handle it as needed
      throw Exception('Failed to initialize ObjectBox: $e');
    }
  }

  /// Provides a globally accessible getter for the Store.
  Store get storeInstance => store;

  /// Global accessor to the singleton instance.
  /// This will throw an error if called before `init()` has completed.
  static ObjectBox get instance {
    if (_instance == null) {
      throw Exception('ObjectBox has not been initialized. Call ObjectBox.init() first.');
    }
    return _instance!;
  }

  /// Asynchronously gets the singleton instance.
  /// This method ensures that the instance is initialized before returning it.
  static Future<ObjectBox> getInstance() async {
    if (_futureInstance == null) {
      await init();
    }
    return _futureInstance!;
  }
}