import 'dart:io' as Io;
import 'package:image/image.dart';

thumbnail(String imagepath,String thumbnailpath,int size) {
  Image image = decodeImage(new Io.File(imagepath).readAsBytesSync());
  Image thumbnail = copyResize(image, size);
  new Io.File(thumbnailpath)
        ..writeAsBytesSync(encodePng(thumbnail));
}