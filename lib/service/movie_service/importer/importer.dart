abstract class Importer {
  int prepareData();
  Future<void> getVideos();
  Future<void> makeMeta();
  void setExtraData(
      List<String> tags, int? rate, String? source, List<String> comments);
  int storeMovie();
  void show();
}
