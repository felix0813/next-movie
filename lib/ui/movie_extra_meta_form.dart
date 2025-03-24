import 'package:flutter/material.dart';

import '../service/movie_service/movie_service.dart';

class MovieExtraMetaForm extends StatefulWidget {
  const MovieExtraMetaForm({super.key});

  @override
  MovieExtraMetaFormState createState() => MovieExtraMetaFormState();
}

class MovieExtraMetaFormState extends State<MovieExtraMetaForm> {
  final _formKey = GlobalKey<FormState>();
  final _tagsController = TextEditingController();
  final _commentsController = TextEditingController();
  final _rateController = TextEditingController();
  final _sourceController = TextEditingController();

  List<String> _tags = [];
  List<String> _comments = [];

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Tag'),
          content: TextField(
            controller: _tagsController,
            decoration: InputDecoration(labelText: 'Enter a tag'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String newTag = _tagsController.text.trim();
                if (newTag.isNotEmpty && !_tags.contains(newTag)) {
                  setState(() {
                    _tags.add(newTag);
                  });
                }
                _tagsController.clear();
                Navigator.pop(context); // 关闭对话框
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 关闭对话框而不添加
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addComment() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Comment'),
          content: TextField(
            controller: _commentsController,
            decoration: InputDecoration(labelText: 'Enter a comment'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String newComment = _commentsController.text.trim();
                if (newComment.isNotEmpty && !_comments.contains(newComment)) {
                  setState(() {
                    _comments.add(newComment);
                  });
                }
                _commentsController.clear();
                Navigator.pop(context); // 关闭对话框
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 关闭对话框而不添加
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  MovieExtraMeta getMovieExtraMeta() {
    return MovieExtraMeta(
      tags: _tags,
      comments: _comments,
      rate: _rateController.text.isNotEmpty ? int.tryParse(_rateController.text) : null,
      source: _sourceController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(labelText: 'Tags (comma separated)'),
              onChanged: (value) {
                _tags = value.split(',').map((tag) => tag.trim()).toList();
              },
            ),
            ElevatedButton(
              onPressed: _addTag,
              child: Text('Add Tag'),
            ),
            ..._tags.map((tag) => ListTile(
              title: Text(tag),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
              ),
            )),
            TextFormField(
              controller: _commentsController,
              decoration: InputDecoration(labelText: 'Comments (comma separated)'),
              onChanged: (value) {
                _comments = value.split(',').map((comment) => comment.trim()).toList();
              },
            ),
            ElevatedButton(
              onPressed: _addComment,
              child: Text('Add Comment'),
            ),
            ..._comments.map((comment) => ListTile(
              title: Text(comment),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _comments.remove(comment);
                  });
                },
              ),
            )),
            TextFormField(
              controller: _rateController,
              decoration: InputDecoration(labelText: 'Rate'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _sourceController,
              decoration: InputDecoration(labelText: 'Source'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, getMovieExtraMeta());
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
