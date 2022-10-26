import 'dart:developer';
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:video_compress/video_compress.dart';

class FileProcessor {
  generateImageInfo(File thisFile) async {
    try {
      bool specialIMG = false;
      String orientation = 'portrait';
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(0);

      Future<Map<String, IfdTag>> data =
          readExifFromBytes(await thisFile.readAsBytes());

      await data.then((data) async {
        if (data.isNotEmpty) {
          if (data['Image Orientation'] != null) {
            if (data['Image Orientation']
                .toString()
                .toLowerCase()
                .contains('horizontal')) {
              orientation = 'landscape';
            } else if (data['Image Orientation']
                .toString()
                .toLowerCase()
                .contains('vertical')) {
              orientation = 'portrait';
            } else {
              String getNumbersFromString = data['Image Orientation']
                  .toString()
                  .replaceAll(RegExp(r'[^0-9]'), '');
              orientation =
                  _getFileOrientation(int.parse(getNumbersFromString));
            }
          }

          if (data['Image ImageWidth'] != null) {
            int width = int.parse(data['Image ImageWidth'].toString());
            int height = int.parse(data['Image ImageLength'].toString());

            /// Panoramic and 360 images have the double width compared of it's height
            if ((width / 2) >= height) {
              specialIMG = true;
            }
          }

          for (var value in data.entries) {
            if (value.key == 'Image DateTime') {
              int year = int.parse(value.value.printable.substring(0, 4));
              int month = int.parse(value.value.printable.substring(5, 7));
              int day = int.parse(value.value.printable.substring(8, 11));
              int hour = int.parse(value.value.printable.substring(11, 13));
              int minute = int.parse(value.value.printable.substring(14, 16));
              int second = int.parse(value.value.printable.substring(17, 19));

              dateTime = DateTime(year, month, day, hour, minute, second);
            }
          }
        } else {
          ImageProperties properties =
              await FlutterNativeImage.getImageProperties(thisFile.path);

          if ((properties.width! / 2) >= properties.height!) {
            specialIMG = true;
          } else if (properties.width! > properties.height!) {
            orientation = 'landscape';
          }

          dateTime = thisFile.lastModifiedSync();
        }
      });

      String fileName =
          (thisFile.path.substring(thisFile.path.lastIndexOf('/') + 1));
      Map result = {
        "fileName": fileName,
        "specialIMG": specialIMG,
        "orientation": orientation,
        "dateTime": dateTime,
      };

      return result;
    } catch (e) {
      log(e.toString());
    }

    return true;
  }

  generateLocalVideoInfo(File thisFile) async {
    Duration duration = const Duration(milliseconds: 500);

    try {
      debugPrint('Generating video info for video: ${thisFile.path}');

      final videoInfo = FlutterVideoInfo();
      String videoLength = '';
      String fileOrientation;

      await Future.delayed(duration);
      var info = await videoInfo.getVideoInfo(thisFile.path);

      int videoAux = info!.duration.toString().indexOf('.');
      videoLength = info.duration.toString().substring(0, videoAux);

      fileOrientation = _getFileOrientation(info.orientation);

      await Future.delayed(duration);

      DateTime date = DateTime.parse(info.date!);

      /// Generates Thumbnail for videos
      final thumbnailFile = await VideoCompress.getFileThumbnail(thisFile.path,
          quality: 20, // default(100)
          position: 0 // default(-1)
          );

      await Future.delayed(duration);

      log('Info generated for video: ${thisFile.path}');
      Map result = {
        "fileName": info.title,
        "videoLength": videoLength,
        "orientation": fileOrientation,
        "dateTime": date,
        "thumbnail": thumbnailFile
      };

      return result;
    } catch (e) {
      log(e.toString());
    }
    return true;
  }

  _getFileOrientation(int? orientation) {
    if (orientation == 90 || orientation == 270) {
      return 'portrait';
    } else {
      return 'landscape';
    }
  }
}
