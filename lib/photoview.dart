import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:choosephoto/saveimage.dart';
// import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/services.dart';

class PhotoPage extends StatelessWidget {
  final String photopathSmall;
  final String photopath;
  const PhotoPage({this.photopathSmall, this.photopath});
//child: Image.file(File(nowdata)),
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyHomePage(photopath: photopath),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.photopathSmall, this.photopath}) : super(key: key);
  final String photopathSmall;
  final String photopath;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final windowWidth = MediaQueryData.fromWindow(window).size.width;
  final windowHeight = MediaQueryData.fromWindow(window).size.height;
  final windowtopbar = MediaQueryData.fromWindow(window).padding.top;
  int navigationBarSelectedIndex = 0;

  bool isSuccess;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("放大浏览 ${widget.photopath}");
    print("缩略图 ${widget.photopathSmall}");
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
              margin: const EdgeInsets.symmetric(vertical: 0.0),
              height: (windowHeight - kBottomNavigationBarHeight - 6.0),
              child: PhotoView(
                imageProvider: AssetImage(widget.photopath),
              ))
          // Image.file(File(widget.photopath)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.keyboard_arrow_left,
                  color: Color.fromARGB(255, 0, 0, 0)),
              title: Text('返回',
                  style: new TextStyle(color: const Color(0xff000000)))),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.refresh, color: Color.fromARGB(255, 0, 0, 0)),
          //     title: Text('复位',
          //         style: new TextStyle(color: const Color(0xff000000)))),
          BottomNavigationBarItem(
              icon: Icon(Icons.save_alt, color: Color.fromARGB(255, 0, 0, 0)),
              title: Text('保存',
                  style: new TextStyle(color: const Color(0xff000000)))),
          BottomNavigationBarItem(
              icon: Icon(Icons.share, color: Color.fromARGB(255, 0, 0, 0)),
              title: Text('分享',
                  style: new TextStyle(color: const Color(0xff000000)))),
          BottomNavigationBarItem(
              icon: Icon(Icons.delete_forever,
                  color: Color.fromARGB(255, 0, 0, 0)),
              title: Text('删除',
                  style: new TextStyle(color: const Color(0xff000000)))),
        ],
        currentIndex: navigationBarSelectedIndex,
        fixedColor: Colors.deepPurple,
        onTap: navigationBarItemTapped,
      ),
    );
  }

  void navigationBarItemTapped(int index) {
    // setState(() {
    // navigationBarSelectedIndex = index;
    // });
    switch (index) {
      case 0: //返回
        Navigator.pop(context);
        break;
      // case 1: //复位
      //   break;
      case 1: //保存
        savepic();
        break;
      case 2: //分享
        break;
      case 3: //删除
        break;
      default:
    }
  }

  // getPermissionStatus() async {
  //   final res = await SimplePermissions.getPermissionStatus(Permission.values[3]);
  //   print("permission status is " + res.toString());
  // }

  static const platform = const MethodChannel("samples.flutter.io/battery");
  void savepic() {
    // getPermissionStatus();
    _getBatteryLevel();
  }

  Future<Null> _getBatteryLevel() async {
    String result;
    try {
      result =
          await platform.invokeMethod('saveToPhotosAlbum', <String, dynamic>{
        'file': widget.photopath,
      });
    } on PlatformException catch (e) {
      showInSnackBar("照片存储失败：${e.message}");
    }
    // if (result == "Y") {
    //   showInSnackBar("已将照片保存到您的手机相册");
    // } else {
    //   showInSnackBar("照片存储失败，请检查权限设置");
    // }
    print("原生返回结果：${result.toString()}");
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
        content: Text(message)));
  }
}
