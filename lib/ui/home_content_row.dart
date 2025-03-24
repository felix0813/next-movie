import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/ui/video_card.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class HomeContentRow extends StatefulWidget {
  final String title;
  final int itemCount;
  const HomeContentRow({super.key,required this.title,required this.itemCount});

  @override
  HomeContentRowState createState() => HomeContentRowState();
}

class HomeContentRowState extends State<HomeContentRow> {
  late ScrollController _scrollController;
  bool _showLeftButton = false;
  bool _showRightButton = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  void _handleScroll() {
    final offset = _scrollController.offset;
    final maxOffset = _scrollController.position.maxScrollExtent;

    setState(() {
      _showLeftButton = offset > 0;
      _showRightButton = offset < maxOffset;
    });
  }

  void _scrollLeft(itemWidth) {
    double multi = 5;
    if (Platform.isAndroid || Platform.isIOS) {
      multi = 1.5;
    }
    _scrollController
        .animateTo(
      _scrollController.offset - itemWidth * multi,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      // 移除错误的 completion 参数
    )
        .then((_) {
      // 动画完成后更新按钮状态
      setState(() {
        _showLeftButton = _scrollController.offset > 0;
        _showRightButton = _scrollController.offset <
            _scrollController.position.maxScrollExtent;
      });
    });
  }

  void _scrollRight(itemWidth) {
    double multi = 5;
    if (Platform.isAndroid || Platform.isIOS) {
      multi = 1.5;
    }
    _scrollController
        .animateTo(
      _scrollController.offset + itemWidth * multi,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    )
        .then((_) {
      setState(() {
        _showLeftButton = _scrollController.offset > 0;
        _showRightButton = _scrollController.offset <
            _scrollController.position.maxScrollExtent;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    double itemWidth =
    max((MediaQuery.of(context).size.width - 20) / 5 - 20, 80);
    double itemHeight = itemWidth / 16 * 9;
    return Column(
      children: [

        // 标题栏容器（改为Row布局）
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // 关键：设置主轴对齐方式
          children: [
            // 行首组件（左侧按钮）
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
            ),

            // 行尾组件（右侧按钮组）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(TDIcons.arrow_left),
                    onPressed: _showLeftButton
                        ? () {
                      _scrollLeft(itemWidth);
                    }
                        : null,
                    tooltip: '向左滚动',
                  ),
                  IconButton(
                    icon: const Icon(TDIcons.arrow_right),
                    onPressed: _showRightButton
                        ? () {
                      _scrollRight(itemWidth);
                    }
                        : null,
                    tooltip: '向右滚动',
                  ),
                ],
              ),
            ),
          ],
        ),
        // 内容容器
        SizedBox(
          height: itemHeight * 2 / 3, // 包含间距
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.itemCount, // 确保足够多的item
                  itemBuilder: (context, index) => VideoCard(
                    itemWidth: itemWidth * 2 / 3,
                    itemHeight: itemHeight * 2 / 3,
                    index: index,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}