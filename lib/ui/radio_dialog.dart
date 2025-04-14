import 'package:flutter/material.dart';
import 'package:next_movie/model/sort_by.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class SortMovieRadioDialog extends StatefulWidget {
  final String initValue;
  final String order;
  final Function(String?, String?) onConfirm;
  final List<String> options;
  const SortMovieRadioDialog(
      {super.key,
      required this.initValue,
      required this.onConfirm,
      required this.options,
      required this.order});

  @override
  SortMovieRadioDialogState createState() => SortMovieRadioDialogState();
}

class SortMovieRadioDialogState extends State<SortMovieRadioDialog> {
  String? sortBy;
  String? order;
  @override
  void initState() {
    setState(() {
      sortBy = widget.initValue;
      order = widget.order;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sort'),
      content: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sort by"),
              Column(
                  children: List.generate(widget.options.length, (index) {
                return RadioListTile<String>(
                  title: Text(widget.options[index]),
                  value: widget.options[index],
                  groupValue: sortBy,
                  onChanged: (value) {
                    setState(() {
                      sortBy = value;
                    });
                  },
                );
              })),
              Text("Order"),
              Column(
                children: [
                  RadioListTile<String>(
                    title: Text(SortOrder.descending),
                    value: SortOrder.descending,
                    groupValue: order,
                    onChanged: (value) {
                      setState(() {
                        order = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(SortOrder.ascending),
                    value: SortOrder.ascending,
                    groupValue: order,
                    onChanged: (value) {
                      setState(() {
                        order = value;
                      });
                    },
                  )
                ],
              )
            ]),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Confirm'),
          onPressed: () {
            if (sortBy != null && order != null) {
              widget.onConfirm(sortBy, order);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class CheckMovieRadioDialog extends StatefulWidget {
  final Function(Set<String>) onConfirm;
  final List<String> options;
  const CheckMovieRadioDialog({
    super.key,
    required this.onConfirm,
    required this.options,
  });

  @override
  CheckMovieRadioDialogState createState() => CheckMovieRadioDialogState();
}

class CheckMovieRadioDialogState extends State<CheckMovieRadioDialog> {
  Set<String> checked = {};

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("Check movies"),
        content: SizedBox(
          height: 300,
          child: SingleChildScrollView(
              child: Column(
            children: [
              Text(
                  "Scan movies in database to check whether they are still in file system.\nChoose how to deal with the invalid movies."),
              SizedBox(height: 10),
              Column(
                  children: List.generate(widget.options.length, (index) {
                return CheckboxListTile(
                  title: Text(widget.options[index]),
                  value: checked.contains(widget.options[index]),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      if (value) {
                        checked.add(widget.options[index]);
                      } else {
                        checked.remove(widget.options[index]);
                      }
                    });
                  },
                );
              }))
            ],
          )),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (checked.isEmpty) {
                TDToast.showText("You must choose one at least",
                    constraints: BoxConstraints(maxWidth: 300),
                    context: context);
              } else {
                widget.onConfirm(checked);
                Navigator.pop(context);
              }
            },
            child: Text("Check"),
          )
        ]);
  }
}
