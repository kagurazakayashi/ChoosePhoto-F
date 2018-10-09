import 'dart:io' as Io;
import 'package:image/image.dart';

thumbnail(String imagepath,String thumbnailpath,int size) {
  Image image = decodeImage(new Io.File(imagepath).readAsBytesSync());
  Image thumbnail = copyResize(image, size);
  new Io.File(thumbnailpath)
        ..writeAsBytesSync(encodeJpg(thumbnail));
}

copypicture(String imagepath,String thumbnailpath) {
  Image image = decodeImage(new Io.File(imagepath).readAsBytesSync());
  new Io.File(thumbnailpath)
        ..writeAsBytesSync(encodeJpg(image));
}
