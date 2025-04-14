import 'dart:io';

import 'package:path/path.dart';

class LogManager {
  late final String logPath;
  Future<void> logToFile(String logId, String message) async {
    final fileName =
        "${logId.replaceAll(" ", "-").replaceAll(":", "-").split(".")[0]}.log";
    final filePath = join(logPath, fileName);
    final file = File(filePath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    // 使用追加模式写入日志（参考[3](@ref)）
    await file.writeAsString('${DateTime.now()} - $message\n',
        mode: FileMode.append);
  }

  LogManager(this.logPath);
}
