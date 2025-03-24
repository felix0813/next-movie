import 'package:flutter/material.dart';

class VideoCard extends StatelessWidget {

  const VideoCard({
    super.key,
    required this.index,
    required this.itemWidth,
    required this.itemHeight,
  });

  final int index;
  final double itemWidth;
  final double itemHeight;
  void onTap(){
    //todo
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: itemWidth,
      height: itemHeight,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque, // 确保点击区域覆盖整个卡片
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://picsum.photos/300/150?random=$index',
              fit: BoxFit.cover,
              errorBuilder: (context, widget, error) {
                return const Icon(Icons.error, color: Colors.red);
              },
            ),
          ),
        ),
      ),
    );
  }
}