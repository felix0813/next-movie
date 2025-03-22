
import 'package:flutter/cupertino.dart';

abstract class Importer {
  int prepareData();
  Future<void> getVideos();
  Future<void> makeMeta();
  Future<void> setExtraData(List<String> tags,int rate,String source,List<String> comments);
  int storeMovie(BuildContext context);
  void show();
}