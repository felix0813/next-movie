import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/service/category_service/category_service.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  CategoryListPageState createState() => CategoryListPageState();
}

class CategoryListPageState extends State<CategoryListPage> {
  List<int> ids = [];
  int page = 0;
  final _categoryService = CategoryService();
  @override
  Widget build(BuildContext context) {
    int count = _categoryService.getTotalCategories();
    return Scaffold(
      appBar: GlobalNavigationBar(
        title: "Category",
        updateUI: () {
          setState(() {
            ids = _categoryService.getOnePageCategories(
                page, "created", "descending");
          });
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${page * 100 + 1}-${min(count, page * 100 + 100)} of $count",
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                    onPressed: page == 0 ? null : lastPage,
                    icon: Icon(TDIcons.arrow_left)),
                IconButton(
                    onPressed: page * 100 + 100 >= count ? null : nextPage,
                    icon: Icon(TDIcons.arrow_right)),
                IconButton(
                    tooltip: "sort",
                    icon: Icon(Icons.sort),
                    onPressed: () {
                      //todo
                    })
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${page * 100 + 1}-${min(count, page * 100 + 100)} of $count",
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                    onPressed: page == 0 ? null : lastPage,
                    icon: Icon(TDIcons.arrow_left)),
                IconButton(
                    onPressed: page * 100 + 100 >= count ? null : nextPage,
                    icon: Icon(TDIcons.arrow_right)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  nextPage() {
    final tmp = page;
    setState(() {
      page = page + 1;
      ids = _categoryService.getOnePageCategories(
          tmp + 1, "created", "descending");
    });
  }

  lastPage() {
    final tmp = page;
    setState(() {
      page = page - 1;
      ids = _categoryService.getOnePageCategories(
          tmp - 1, "created", "descending");
    });
  }
}
