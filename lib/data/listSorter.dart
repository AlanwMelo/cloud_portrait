import 'package:cloud_portrait/presentation/listViewer.dart';

class ListSorter {
  sortAlphabetically(
      {required List<ListItem> list, bool separatedByType = false}) {
    if (separatedByType) {
      List<ListItem> result = [];

      List<ListItem> folders = [];
      List<ListItem> images = [];
      List<ListItem> videos = [];

      for (var item in list) {
        if (item.type == 'folder') {
          folders.add(item);
        } else if (item.subtype == 'image') {
          images.add(item);
        } else {
          videos.add(item);
        }
      }
      folders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      images.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      videos.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      result.addAll(folders);
      result.addAll(images);
      result.addAll(videos);

      list = result;
    } else {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return list;
  }

  /// Recent first
  sortByCreatedDate(
      {required List<ListItem> list, bool separatedByType = false}) {
    if (separatedByType) {
      List<ListItem> result = [];

      List<ListItem> folders = [];
      List<ListItem> images = [];
      List<ListItem> videos = [];

      for (var item in list) {
        if (item.type == 'folder') {
          folders.add(item);
        } else if (item.subtype == 'image') {
          images.add(item);
        } else {
          videos.add(item);
        }
      }
      folders.sort((a, b) => a.created.compareTo(b.created));
      images.sort((a, b) => a.created.compareTo(b.created));
      videos.sort((a, b) => a.created.compareTo(b.created));

      result.addAll(folders);
      result.addAll(images);
      result.addAll(videos);

      list = result;
    } else {
      list.sort((a, b) => a.created.compareTo(b.created));
    }

    return list;
  }
}
