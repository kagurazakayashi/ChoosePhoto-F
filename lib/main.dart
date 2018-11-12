import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:choosephoto/settings.dart';
import 'package:choosephoto/photoview.dart';
import 'package:choosephoto/thumbnail.dart';
import 'package:simple_permissions/simple_permissions.dart';
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
  var imagedata = ["（没有缓存的照片）"];
  var imgdir = "";
  int navigationBarSelectedIndex = 0;
  var nowcamera;
  var allcamera;
  var oldcamera = 0;
  var waitcamera = '等待摄像头启动';

  double windowWidth = 0.0;
  double windowHeight = 0.0;
  double windowtopbar = 0.0;
  var isBrowserMode = false;
  var cameraHeight = 0.0;
  var photolistHeight = 0.0;
  var cameraBorder = 1.0;

  //controller?.description 当前摄像头
  //cameras 摄像头列表
  // var test = window.physicalSize.height / window.devicePixelRatio;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    print("isAndroid = ${Platform.isAndroid}");
    // getPermissionStatus();
    listfiles(false);
    navigationBarSelectedIndex = 2;
    allcamera = cameras.length;
    //检测摄像头
    requestPermission(2);

    super.initState();
  }

  void startcamera() {
    setState(() {
      waitcamera = "等待摄像头启动";
    });
    print("启动摄像头 ${oldcamera.toString()}");
    onNewCameraSelected(cameras[oldcamera]);
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQueryData.fromWindow(window).size.width;
    windowHeight = MediaQueryData.fromWindow(window).size.height;
    windowtopbar = MediaQueryData.fromWindow(window).padding.top;
    if (!isBrowserMode) cameraHeight = (windowHeight - windowtopbar - kToolbarHeight) * 0.5;
    photolistHeight =
        windowHeight - windowtopbar - kToolbarHeight - cameraHeight - 6.0;
    return Scaffold(
      key: _scaffoldKey,
      // body: Container(
      //   color: Colors.red,
      //   child: Column(
      //     children: <Widget>[
      //       Container(
      //         color: Colors.black,
      //         height: windowtopbar,
      //       ),
      //       Text(windowtopbar.toString()),
      //     ],
      //   ),
      // ),
      body: Container(
        child: Column(
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
        onTap: (index) {
          navigationBarItemTapped(index, context);
        },
      ),
    );
  }

  /*
   * @msg: navigationBar 中的按钮被点击
   * @param {int} 按钮序号
   * @return: void
   */
  void navigationBarItemTapped(int index, BuildContext context) {
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
        toolbtnClear(context);
        break;
      case 4: //设置
        // showInSnackBar(test.toString());
        toolbtnSetting();
        break;
      default:
    }
  }

  //获取文件读写权限
  requestPermissionall() async {
    final camera =
        await SimplePermissions.requestPermission(Permission.values[2]);
    print("2相机访问权限：${camera.toString()}");
    final photolibrary =
        await SimplePermissions.requestPermission(Permission.values[3]);
    print("3相册访问权限：${photolibrary.toString()}");
    final write =
        await SimplePermissions.requestPermission(Permission.values[4]);
    print("4文件写入权限：${write.toString()}");
    final read =
        await SimplePermissions.requestPermission(Permission.values[5]);
    print("5文件读取权限：${read.toString()}");
  }

  requestPermission(int valid) async {
    final nowper =
        await SimplePermissions.requestPermission(Permission.values[valid]);
    print("设置 ${valid.toString()} 的访问权限：${nowper.toString()}");
    checkPermission(valid);
  }

  checkPermission(int valid) async {
    bool nowper =
        await SimplePermissions.checkPermission(Permission.values[valid]);
    print("检查 ${valid.toString()} 的访问权限：${nowper.toString()}");
    if (valid == 2) {
      if (nowper) {
        startcamera();
      } else {
        setState(() {
          waitcamera = "未获得摄像头权限";
        });
      }
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
      requestPermission(2);
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
      showInSnackBar("摄像头已暂停。");
      setState(() {
        cameraBorder = 0.0;
        cameraHeight = 0.0;
      });
      navigationBarSelectedIndex = 1;
    }
  }

  void toolbtnTakePhoto() {
    if (waitcamera != '等待摄像头启动') {
      requestPermission(2);
    } else {
      isBrowserMode = false;
      toolbtnBrowser();
      if (!isCameraInited) {
        showInSnackBar("启动摄像头 ${oldcamera.toString()}");
        initcamera();
      } else {
        if (controller.description.name == "10") {
          onNewCameraSelected(cameras[oldcamera]);
        } else {
          onTakePictureButtonPressed();
        }
        print(controller?.description);
      }
    }
    navigationBarSelectedIndex = 2;
  }

  void toolbtnClear(BuildContext context) {
    List<Widget> actions = [
      FlatButton(
        onPressed: () {
          deletefile();
          Navigator.pop(context); //关闭提示框
        },
        child: new Text("立即删除", style: TextStyle(color: Colors.red)),
      ),
      FlatButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: new Text("取消"),
      )
    ];

    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text("清空确认"),
            actions: actions,
            content: Text("将会永久删除缓存相册中的所有照片，确定吗？"),
          );
        });
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
        return nowdata != "（没有缓存的照片）"
            ? Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push<String>(context,
                        new MaterialPageRoute(builder: (BuildContext context) {
                      return new PhotoPage(
                          photopath: [nowdata, thumbnailtoimagepath(nowdata)]);
                    })).then((String presult) {
                      if (presult == "d") {
                        listfiles(true);
                      }
                    });
                  },
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.file(
                      File(nowdata),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              )
            : Text(nowdata);
      }).toList(),
    );
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return Text(
        waitcamera,
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

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message, [Color barcolor = Colors.blue]) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: barcolor,
        duration: Duration(seconds: 1),
        content: Text(message)));
  }

  initcamera() async {
    try {
      isCameraInited = true;
      requestPermission(2);
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
          showInSnackBar("拍摄完成"); //，正在后台处理照片……
          // savethumbnail(filePath, thumbnailpath, ts).then((String ret) {
          //   print("重新载入缩略图列表……");
          //   listfiles(true);
            // if (imagedata[0] == "（没有缓存的照片）") {
            //   imagedata[0] = thumbnailpath;
            // } else {
            //   imagedata.add(thumbnailpath);
            // }
          //   showInSnackBar("照片已保存到缓存图片库。", Colors.green);
          // });
            if (imagedata[0] == "（没有缓存的照片）") {
              imagedata[0] = filePath;
            } else {
              imagedata.add(filePath);
            }
        });
        // if (thumbnailpath == null) {
        //   showInSnackBar('拍摄失败 $thumbnailpath');
        // } else {
        //   showInSnackBar('拍摄成功 $thumbnailpath');
        // }
      }
    });
  }

  /*
  * @msg: 取得临时文件夹中的照片
  * @return: void (保存至属性 imagedata )
  */
  listfiles(bool isreload) async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/images';
    final String dirPaththumbnail = '${extDir.path}/Pictures/thumbnail';
    await Directory(dirPath).create(recursive: true);
    await Directory(dirPaththumbnail).create(recursive: true);
    //dirPaththumbnail:缩略图
    var dirthumbnail = Directory(dirPaththumbnail); 
    var dirthumbnailList = dirthumbnail.list();
    //dirPath:大图
    var dirimage = Directory(dirPath);
    var dirimageList = dirimage.list();
    if (isreload) {
      setState(() {
        imagedata.clear();
        imagedata.add("（没有缓存的照片）");
      });
    }
    try {
      await for (FileSystemEntity f in dirimageList/* 缩略图：dirthumbnailList */) {
        if (f is File) {
          if (imagedata[0] == "（没有缓存的照片）") {
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
      print("imagedata = ${imagedata.toString()}");
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
      showInSnackBar('错误：摄像头目前不可用。', Colors.red);
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/images';
    final String dirPaththumbnail = '${extDir.path}/Pictures/thumbnail';
    await Directory(dirPath).create(recursive: true);
    await Directory(dirPaththumbnail).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
      return filePath;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('错误： ${e.code}\n${e.description}', Colors.red);
  }

  deletefile() async {
    for (String f in imagedata) {
      File file = new File(f);
      // File filei = new File(thumbnailtoimagepath(f)); //缩略图
      await file.delete();
      // await filei.delete();
    }
    setState(() {
      imagedata = ["（没有缓存的照片）"];
    });
    showInSnackBar("缓存照片库已清空", Colors.green);
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
bool rp = false;
String mas = "";

class CameraApp extends StatelessWidget {
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraHome(),
    );
  }
}
