// input_dialog.dart
import 'package:flutter/material.dart';

class StringPair {
  String? first;
  String? second;
  StringPair({this.first, this.second});
}

class DoubleInputDialog {
  // 显示对话框的静态方法
  static Future<StringPair?> show({
    required BuildContext context,
    required String title,
    String hintText1 = 'input here',
    String hintText2 = 'input here',
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool autoFocus = true,
    TextInputType keyboardType = TextInputType.text,
    required int maxLength1,
    required int maxLength2,
    FormFieldValidator<String>? validator1,
    FormFieldValidator<String>? validator2,
  }) async {
    final firstController = TextEditingController();
    final secondController = TextEditingController();

    return await showDialog<StringPair>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: firstController,
                  autofocus: autoFocus,
                  decoration: InputDecoration(
                    hintText: hintText1,
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  keyboardType: keyboardType,
                  maxLength: maxLength1,
                ),
                TextField(
                  controller: secondController,
                  autofocus: autoFocus,
                  decoration: InputDecoration(
                    hintText: hintText2,
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  keyboardType: keyboardType,
                  maxLength: maxLength2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              if (validator1 == null ||
                  validator1(firstController.text)!.isEmpty) {
                Navigator.pop(
                    context,
                    StringPair(
                        first: firstController.text,
                        second: secondController.text));
              }
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

class SingleInputDialog {
  // 显示对话框的静态方法
  static Future<String?> show({
    required BuildContext context,
    required String title,
    String hintText = 'input here',
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool autoFocus = true,
    bool allowBlank = false,
    TextInputType keyboardType = TextInputType.text,
    required int maxLength,
    FormFieldValidator<String>? validator,
  }) async {
    final firstController = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: firstController,
                  autofocus: autoFocus,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  keyboardType: keyboardType,
                  maxLength: maxLength,
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              if(allowBlank){
                Navigator.pop(context, firstController.text);
              }
              else if (validator == null ||
                  validator(firstController.text)!.isEmpty) {
                Navigator.pop(context, firstController.text);
              }
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
