import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/service/category_service/category_service.dart';
import 'package:next_movie/ui/category_card.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/ui/select_navigation_bar.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../model/sort_by.dart';
import '../radio_dialog.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  CategoryListPageState createState() => CategoryListPageState();
}

class CategoryListPageState extends State<CategoryListPage> {
  List<int> ids = [];
  int page = 0;
  final _categoryService = CategoryService();
  String orderBy = SortBy.created;
  String order = SortOrder.descending;
  bool selecting = false;
  Set<int> selectedCategory = {};

  @override
  initState() {
    setState(() {
      ids = _categoryService.getOnePageCategories(page, orderBy, order);
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
      appBar: selecting
          ? SelectCategoryNavigationBar(
              selectedCategory: selectedCategory,
              quitSelecting: () {
                setState(() {
                  selecting = false;
                  selectedCategory.clear();
                });
              },
              deleteCategory: (Set<int> categories) {
                for (int i in categories) {
                  _categoryService.removeCategory(i);
                }
                setState(() {
                  ids = _categoryService.getOnePageCategories(
                      page, orderBy, order);
                });
              })
          : GlobalNavigationBar(
              title: "Category",
              onCategoryUpdate: () {
                setState(() {
                  ids = _categoryService.getOnePageCategories(
                      page, orderBy, order);
                });
              },
            ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 10),
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
                    onPressed: onSortPressed)
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

  onSortPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SortMovieRadioDialog(
          options: [SortBy.created, SortBy.title],
          initValue: orderBy,
          order: order,
          onConfirm: (String? result, String? sortOrder) {
            if (result != null && sortOrder != null) {
              setState(() {
                orderBy = result;
                order = sortOrder;
                ids = _categoryService.getOnePageCategories(
                    page, result, sortOrder);
              });
            }
          },
        );
      },
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
        childAspectRatio: 5 / 4,
      ),
      itemCount: ids.length,
      itemBuilder: (context, index) {
        return CategoryCard(
          key: Key(ids[index].toString()),
          itemWidth: itemWidth + 10,
          itemHeight: itemWidth * 9 / 16 + 30,
          categoryId: ids[index],
          isSelected: selectedCategory.contains(ids[index]),
          selecting: selecting,
          onSelect: (bool isSelected){
            setState(() {
              selecting = true;
              if(isSelected) {
                selectedCategory.add(ids[index]);
              }
              else{
                selectedCategory.remove(ids[index]);
              }
            });
          },
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
