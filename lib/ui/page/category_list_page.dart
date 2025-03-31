import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/service/category_service/category_service.dart';
import 'package:next_movie/ui/category_card.dart';
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
  initState() {
    setState(() {
      ids =
          _categoryService.getOnePageCategories(page, "created", "descending");
    });
    super.initState();
  }

  double get itemWidth {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = max(2, screenWidth / 300);
    return (screenWidth - 15) / columns;
  }

  @override
  Widget build(BuildContext context) {
    int count = _categoryService.getTotalCategories();
    return Scaffold(
      appBar: GlobalNavigationBar(
        title: "Category",
        onCategoryUpdate: () {
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
            buildGridView(context),
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

  GridView buildGridView(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // 禁止 GridView 自滚动
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            ((MediaQuery.of(context).size.width - 15) / (itemWidth + 10))
                .round(), // 动态列数
        childAspectRatio: 4 / 3,
      ),
      itemCount: ids.length,
      itemBuilder: (context, index) {
        return CategoryCard(
          key: Key(ids[index].toString()),
          itemWidth: itemWidth + 10,
          itemHeight: itemWidth * 9 / 16 + 30,
          categoryId: ids[index],
          onUpdateUI: () => setState(() {
            ids = _categoryService.getOnePageCategories(
                page, "created", "descending");
          }),
        );
      },
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
