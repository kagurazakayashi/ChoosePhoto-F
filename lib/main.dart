import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
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

IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
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
  var dataarr = ["没有照片"];
  var imgdir = "";
  int navigationBarSelectedIndex = 0;
  var nowcamera;
  var allcamera;

  //controller?.description 当前摄像头
  //cameras 摄像头列表

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    listfiles();
    navigationBarSelectedIndex = 2;
    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
            height: 300,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Center(
                        child: _cameraPreviewWidget(),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        color: controller != null &&
                                controller.value.isRecordingVideo
                            ? Colors.redAccent
                            : Colors.grey,
                        width: 3.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            child: createGridView(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _captureControlRowWidget(),
              _cameraTogglesRowWidget(),
              // _thumbnailWidget(),
            ],
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
        // print(controller.value.isInitialized);
        // nowcamera = new CameraDescription();
        //controller?.description 当前摄像头
        //cameras 摄像头列表
        // print(controller);
        if (isCameraInited) {
          if (controller.description == cameras[0]) {
            onNewCameraSelected(cameras[1]);
          } else {
            onNewCameraSelected(cameras[0]);
          }
        }
        break;
      case 1: //浏览
        // controller.dispose();
        if (isCameraInited) {
          nowcamera = new CameraDescription(name: "10");
          isCameraInited = false;
          controller.dispose();
        }
        break;
      case 2: //拍摄
        print("1++++++++++++++++++++++++++++++++");
        print(cameras);
        print("1++++++++++++++++++++++++++++++++");
        if (!isCameraInited) {
          print("0000000000000000000");
          initcamera();
        } else {
          print("1010101010101010101");
          if (controller.description.name == "10") {
            onNewCameraSelected(cameras[0]);
          } else {
            onTakePictureButtonPressed();
          }
          print("2++++++++++++++++++++++++++++++++");
          print(controller?.description);
        }
        break;
      case 3: //清空

        break;
      case 4: //设置

        break;
      default:
    }
  }

  /*
   * @msg: 创建图片列表
   * @return: Widget
   */
  Widget createGridView() {
    return new GridView.count(
      padding: const EdgeInsets.all(5.0),
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      childAspectRatio: 1.0,
      crossAxisCount: widthcount,
      children: dataarr.map((var nowdata) {
        return nowdata != "没有照片" ? Image.file(File(nowdata)) : Text(nowdata);
      }).toList(),
    );
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
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

  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  !controller.value.isRecordingVideo
              ? onTakePictureButtonPressed
              : null,
        ),
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        print("++++++++++++++++++++++++++++++++");
        print(controller?.description);
        print(cameraDescription);
        print(controller);
        print("++++++++++++++++++++++++++++++++");
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: controller != null ? null : onNewCameraSelected,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  initcamera() async {
    print("0000000000000000000");
    try {
      print("1111111111111111111");
      print("2222222222222222222");
      isCameraInited = true;
      print("2222222222222222222");
      onNewCameraSelected(cameras[0]);
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print("EEEEEEEEEEEEEEEE");
      logError(e.code, e.description);
    }
  }

  /*
   * @msg: 切换摄像头
   * @param {CameraDescription} 摄像头名称
   * @return: void
   */
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    print("2222222222222222222");
    if (controller != null) {
      print("333333333333333333");
      await controller.dispose();
    }
    print("@@@@@@@@@@@@@@@@@");
    print(cameraDescription);
    print("@@@@@@@@@@@@@@@@@");
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
      if (mounted) {
        setState(() {
          imagePath = filePath;
          if (dataarr.length == 1 && dataarr[0] == "没有照片") {
            dataarr[0] = filePath;
          } else {
            dataarr.add(filePath);
          }
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  /*
  * @msg: 取得临时文件夹中的照片
  * @return: void (保存至属性 dataarr )
  */
  listfiles() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    var dir = Directory(dirPath);
    var dirList = dir.list();
    try {
      await for (FileSystemEntity f in dirList) {
        // i++;
        if (f is File) {
          if (dataarr[0] == "没有照片") {
            setState(() {
              dataarr[0] = f.path.toString();
            });
          } else {
            setState(() {
              dataarr.add(f.path.toString());
            });
          }
          print('已有文件 ${f.path}');
        } else if (f is Directory) {
          print('已有文件夹 ${f.path}');
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
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
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
