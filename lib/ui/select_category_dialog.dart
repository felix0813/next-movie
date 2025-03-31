import 'package:flutter/material.dart';
import 'package:next_movie/model/category.dart';

class SelectCategoryDialog extends StatefulWidget {
  final int? initValue;
  final Function(int?) onConfirm;
  final List<Category> options;

  const SelectCategoryDialog({
    super.key,
    required this.initValue,
    required this.onConfirm,
    required this.options,
  });

  @override
  SelectCategoryDialogState createState() => SelectCategoryDialogState();
}

class SelectCategoryDialogState extends State<SelectCategoryDialog> {
  int? categoryId;
  @override
  void initState() {
    setState(() {
      categoryId = widget.initValue;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Category"),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.6, // 总高度60%
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton(
              menuMaxHeight: 400, // 同时限制下拉菜单高度
              alignment: AlignmentDirectional.center,
              value: categoryId,
              items: [
                DropdownMenuItem(value: null, child: Text("unselected")),
                ...widget.options.map((value) => DropdownMenuItem(
                    value: value.id,
                    child: Text(value.name)
                )),
              ],
              onChanged: (id) => setState(() => categoryId = id),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Confirm'),
          onPressed: () {
            if (categoryId != null) {
              widget.onConfirm(categoryId);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
