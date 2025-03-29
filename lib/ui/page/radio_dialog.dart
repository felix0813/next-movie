import 'package:flutter/material.dart';
import 'package:next_movie/model/sort_by.dart';

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
