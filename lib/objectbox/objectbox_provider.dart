// lib/object_box_provider.dart
import 'package:flutter/material.dart';
import 'objectbox.dart';
import 'objectbox.g.dart'; // 根据需要引入实体类

class ObjectBoxProvider with ChangeNotifier {
  ObjectBox? _objectBox;

  /// Initialize the ObjectBox instance asynchronously.
  Future<void> init() async {
    if (_objectBox == null) {
      _objectBox = await ObjectBox.getInstance();
      notifyListeners();
    }
  }

  /// Get the ObjectBox instance.
  ObjectBox get objectBox => _objectBox!;

  /// Get a Box for a specific entity type.
  Box<T> getBox<T>()  {
  return objectBox.store.box<T>();
  }
}

/// A mixin to identify ObjectBox entities.
mixin ObjectBoxEntity {}