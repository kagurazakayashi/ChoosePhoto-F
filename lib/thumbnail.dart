import 'dart:io' as Io;
import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart';

class DecodeParam {
  final File file;
  final SendPort sendPort;
  DecodeParam(this.file, this.sendPort);
}

int thumbnailwidth = 100;

void decodethumbnail(DecodeParam param) {
  Image image = decodeImage(param.file.readAsBytesSync());
  Image thumbnail = copyResize(image, thumbnailwidth);
  param.sendPort.send(thumbnail);
}

Future<String> savethumbnail(String imagepath, String thumbnailpath, int size) async {
  print("正在创建缩略图：");
  thumbnailwidth = size;
  print("压缩图像（${thumbnailwidth.toString()}）……");
  ReceivePort receivePort = new ReceivePort();
  await Isolate.spawn(
      decodethumbnail, new DecodeParam(new File(imagepath), receivePort.sendPort));
  print("获取压缩结果……");
  Image image = await receivePort.first;
  print("封装图片为JPG格式……");
  List<int> encimg = encodeJpg(image);
  print("正在写入文件……");
  new File(thumbnailpath)..writeAsBytesSync(encimg);
  print("创建缩略图完成。");
  return "OK";
}

// copypicture(String imagepath, String thumbnailpath) {
//   Image image = decodeImage(new Io.File(imagepath).readAsBytesSync());
//   new Io.File(thumbnailpath)..writeAsBytesSync(encodePng(image));
// }

void decodepicture(DecodeParam param) {
  Image image = decodeImage(param.file.readAsBytesSync());
  param.sendPort.send(image);
}

savepicture(String imagepath, String thumbnailpath) async {
  print("正在保存图像：");
  print("缓存图像……");
  ReceivePort receivePort = new ReceivePort();
  await Isolate.spawn(
      decodepicture, new DecodeParam(new File(imagepath), receivePort.sendPort));
  print("获取处理结果……");
  Image image = await receivePort.first;
  print("封装图片为JPG格式……");
  List<int> encimg = encodeJpg(image);
  print("正在写入文件……");
  new File(thumbnailpath)..writeAsBytesSync(encimg);
  print("存储完成。");
}