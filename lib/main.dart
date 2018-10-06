import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:choosephoto/settings.dart';
import 'package:choosephoto/thumbnail.dart';
import 'dart:async';
import 'dart:io';

List<CameraDescription> cameras;
bool isCameraInited = false;

Future<void> main() async {
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  isCameraInited = true;
  runApp(CameraApp());
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

/*
 * @msg: 摄像头状态类
 */
class CameraHome extends StatefulWidget {
  @override
  _CameraHomeState createState() {
    return _CameraHomeState();
  }
}

class _CameraHomeState extends State<CameraHome> {
  CameraController controller;
  String imagePath;
  String videoPath;
  VoidCallback videoPlayerListener;

  var widthcount = 2;
  var imagedata = ["没有照片"];
  var imgdir = "";
  int navigationBarSelectedIndex = 0;
  var nowcamera;
  var allcamera;
  var oldcamera = 0;

  final windowWidth = MediaQueryData.fromWindow(window).size.width;
  final windowHeight = MediaQueryData.fromWindow(window).size.height;
  final windowtopbar = MediaQueryData.fromWindow(window).padding.top;
  var isBrowserMode = false;
  var cameraHeight = 0.0;
  var photolistHeight = 0.0;
  var cameraBorder = 1.0;

  //controller?.description 当前摄像头
  //cameras 摄像头列表

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    cameraHeight = (windowHeight - windowtopbar - kToolbarHeight) * 0.5;
    listfiles();
    navigationBarSelectedIndex = 2;
    allcamera = cameras.length;
    print("启动摄像头 ${oldcamera.toString()}");
    onNewCameraSelected(cameras[oldcamera]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    photolistHeight =
        windowHeight - windowtopbar - kToolbarHeight - cameraHeight - 5.0;
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.black,
            height: windowtopbar,
          ),
          Container(
            height: cameraHeight,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Center(
                      child: _cameraPreviewWidget(),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      // border: Border.all(
                      //   color: controller != null &&
                      //           controller.value.isRecordingVideo
                      //       ? Colors.redAccent
                      //       : Colors.blue,
                      //   width: cameraBorder,
                      // ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: photolistHeight,
            child: createPhotosList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.switch_camera,
                  color: Color.fromARGB(255, 0, 0, 0)),
              title: Text('切换',
                  style: new TextStyle(color: const Color(0xff000000)))),
          BottomNavigationBarItem(
              icon: Icon(Icons.photo_library,
                  color: Color.fromARGB(255, 0, 0, 0)),
              title: Text('浏览',
                  style: new TextStyle(color: const Color(0xff000000)))),
          BottomNavigationBarItem(
              icon:
                  Icon(Icons.photo_camera, color: Color.fromARGB(255, 0, 0, 0)),
              title: Text('拍摄',
                  style: new TextStyle(color: const Color(0xff000000)))),
          BottomNavigationBarItem(
              icon: Icon(Icons.delete_forever,
                  color: Color.fromARGB(255, 0, 0, 0)),
              title: Text('清空',
                  style: new TextStyle(color: const Color(0xff000000)))),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings, color: Color.fromARGB(255, 0, 0, 0)),
              title: Text('设置',
                  style: new TextStyle(color: const Color(0xff000000)))),
        ],
        currentIndex: navigationBarSelectedIndex,
        fixedColor: Colors.deepPurple,
        onTap: navigationBarItemTapped,
      ),
    );
  }

  /*
   * @msg: navigationBar 中的按钮被点击
   * @param {int} 按钮序号
   * @return: void
   */
  void navigationBarItemTapped(int index) {
    // setState(() {
    // navigationBarSelectedIndex = index;
    // });
    switch (index) {
      case 0: //切换
        toolbtnChangeCamera();
        break;
      case 1: //浏览
        isBrowserMode = true;
        toolbtnBrowser();
        break;
      case 2: //拍摄
        toolbtnTakePhoto();
        break;
      case 3: //清空
        deletefile();
        break;
      case 4: //设置
        toolbtnSetting();
        break;
      default:
    }
  }

  void toolbtnChangeCamera() {
    // print(controller.value.isInitialized);
    // nowcamera = new CameraDescription();
    //controller?.description 当前摄像头
    //cameras 摄像头列表
    // print(controller);
    if (isCameraInited) {
      oldcamera++;
      if (oldcamera >= allcamera) oldcamera = 0;
      // if (controller.description == cameras[0]) {
      //   onNewCameraSelected(cameras[1]);
      // } else {
      //   onNewCameraSelected(cameras[0]);
      // }
      print("启动摄像头 ${oldcamera.toString()}");
      onNewCameraSelected(cameras[oldcamera]);
    } else {
      toolbtnTakePhoto();
    }
    navigationBarSelectedIndex = 2;
  }

  void toolbtnBrowser() {
    if (!isBrowserMode) {
      setState(() {
        cameraHeight = (windowHeight - windowtopbar - kToolbarHeight) * 0.5;
        cameraBorder = 1.0;
      });
    } else {
      if (isCameraInited) {
        nowcamera = new CameraDescription(name: "10");
        isCameraInited = false;
        controller.dispose();
      }
      print("摄像头关闭");
      setState(() {
        cameraBorder = 0.0;
        cameraHeight = 0.0;
      });
      navigationBarSelectedIndex = 1;
    }
  }

  void toolbtnTakePhoto() {
    isBrowserMode = false;
    toolbtnBrowser();
    if (!isCameraInited) {
      initcamera();
    } else {
      if (controller.description.name == "10") {
        print("启动摄像头 ${oldcamera.toString()}");
        onNewCameraSelected(cameras[oldcamera]);
      } else {
        onTakePictureButtonPressed();
      }
      print(controller?.description);
    }
    navigationBarSelectedIndex = 2;
  }

  void toolbtnSetting() {
    Navigator.push(context,
        new MaterialPageRoute(builder: (BuildContext context) {
      return new SettingPage();
    }));
  }

  /*
   * @msg: 创建图片列表
   * @return: Widget
   */
  Widget createPhotosList() {
    return new GridView.count(
      padding: const EdgeInsets.all(5.0),
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      childAspectRatio: 1.0,
      crossAxisCount: widthcount,
      children: imagedata.map((var nowdata) {
        return nowdata != "没有照片"
            ? GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (BuildContext context) {
                    return Scaffold(

                    );
                  }));
                },
                child: Image.file(File(nowdata)),
              )
            : Text(nowdata);
      }).toList(),
    );
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        '等待摄像头启动',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  Widget _thumbnailWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: imagePath == null
            ? null
            : SizedBox(
                child: Image.file(File(imagePath)),
                width: 64.0,
                height: 64.0,
              ),
      ),
    );
  }

  Widget _thumbnailWidgetBig(String picpush, double size) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: imagePath == null
            ? null
            : SizedBox(
                child: Image.file(File(picpush)),
                width: size,
                height: size,
              ),
      ),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  initcamera() async {
    try {
      isCameraInited = true;
      onNewCameraSelected(cameras[0]);
      cameras = await availableCameras();
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }
  }

  /*
   * @msg: 切换摄像头
   * @param {CameraDescription} 摄像头名称
   * @return: void
   */
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('错误：摄像头发生问题，${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  /*
   * @msg: 拍照按钮被按下
   * @return: void
   */
  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      String thumbnailpath;
      if (mounted) {
        setState(() {
          imagePath = filePath;
          thumbnailpath = imagepathtothumbnail(filePath);
          int ts =
              int.parse((windowWidth / widthcount - 10).toStringAsFixed(0));
          print("********************");
          print(ts);
          print("********************");
          thumbnail(filePath, thumbnailpath, ts);
          if (imagedata[0] == "没有照片") {
            imagedata[0] = thumbnailpath;
          } else {
            imagedata.add(thumbnailpath);
          }
        });
        if (thumbnailpath != null)
          showInSnackBar('Picture saved to $thumbnailpath');
      }
    });
  }

  /*
  * @msg: 取得临时文件夹中的照片
  * @return: void (保存至属性 imagedata )
  */
  listfiles() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/images';
    final String dirPaththumbnail = '${extDir.path}/Pictures/thumbnail';
    await Directory(dirPath).create(recursive: true);
    await Directory(dirPaththumbnail).create(recursive: true);
    var dirthumbnail = Directory(dirPaththumbnail);
    var dirthumbnailList = dirthumbnail.list();
    try {
      await for (FileSystemEntity f in dirthumbnailList) {
        if (f is File) {
          if (imagedata[0] == "没有照片") {
            setState(() {
              imagedata[0] = f.path.toString();
            });
          } else {
            setState(() {
              imagedata.add(f.path.toString());
            });
          }
          print('文件image: ${f.path}');
        } else if (f is Directory) {
          print('文件夹 ${f.path}');
        }
      }
    } catch (e) {
      print("错误：取得临时文件夹中的照片没有成功。");
      print(e.toString());
    }
  }

  /*
   * @msg: 拍摄照片并保存到文件
   * @return: Future<String> (文件路径)
   */
  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/images';
    final String dirPaththumbnail = '${extDir.path}/Pictures/thumbnail';
    await Directory(dirPath).create(recursive: true);
    await Directory(dirPaththumbnail).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.png';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  deletefile() async {
    for (String f in imagedata) {
      File file = new File(f);
      File filei = new File(thumbnailtoimagepath(f));
      await file.delete();
      await filei.delete();
    }
    setState(() {
      imagedata = ["没有照片"];
    });
  }

  String imagepathtothumbnail(String imagePath) {
    List thumbnailpatharr = imagePath.split('/');
    thumbnailpatharr.insert(thumbnailpatharr.length - 2, "thumbnail");
    thumbnailpatharr.removeAt(thumbnailpatharr.length - 2);
    String thumbnailpath = thumbnailpatharr.join("/");
    return thumbnailpath;
  }

  String thumbnailtoimagepath(String thumbnailpath) {
    List imagePatharr = thumbnailpath.split('/');
    imagePatharr.insert(imagePatharr.length - 2, "images");
    imagePatharr.removeAt(imagePatharr.length - 2);
    String imagePath = imagePatharr.join("/");
    return imagePath;
  }
}

/*
 * @msg: 初始化
 */
class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraHome(),
    );
  }
}
