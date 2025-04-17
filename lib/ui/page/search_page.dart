import 'package:flutter/material.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/ui/radio_dialog.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../service/movie_service/movie_service.dart';
import '../../task/task_queue.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
  });

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalNavigationBar(
        title: "Search",
        showSetting: true,
        showSearch: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
