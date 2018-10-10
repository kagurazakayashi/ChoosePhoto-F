import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_share/image_share.dart';
import 'package:choosephoto/thumbnail.dart';
import 'package:flutter/services.dart';
import 'package:simple_permissions/simple_permissions.dart';

class PhotoPage extends StatelessWidget {
  final List<String> photopath;
  const PhotoPage({this.photopath});
//child: Image.file(File(nowdata)),
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyHomePage(photopath: photopath),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.photopath}) : super(key: key);
  final List<String> photopath;

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
    print("放大浏览 ${widget.photopath[1]}");
    print("缩略图 ${widget.photopath[0]}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
              margin: const EdgeInsets.symmetric(vertical: 0.0),
              height: (windowHeight - kBottomNavigationBarHeight - 6.0),
              child: PhotoView(
                imageProvider: AssetImage(widget.photopath[1]),
              ))
          // Image.file(File(widget.photopath[1])),
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
        shareImage(widget.photopath[1]);
        break;
      case 3: //删除
        toolbtnDelete(context);
        break;
      default:
    }
  }

  static const platform = const MethodChannel("samples.flutter.io/battery");
  void savepic() {
    // getPermissionStatus();
    if (Platform.isAndroid) {
      requestPermission(4);
    } else if (Platform.isIOS) {
      requestPermission(3);
    } else {
      showInSnackBar("暂不支持当前操作系统保存图片");
    }
  }

  void toolbtnDelete(BuildContext context) {
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
            content: Text("将会永久删除此照片，确定吗？"),
          );
        });
  }

  deletefile() async {
    File file = new File(widget.photopath[1]);
    await file.delete();
    File filei = new File(widget.photopath[0]);
    await filei.delete();
    Navigator.pop(context,"d");
  }

  Future savepictoandroid() async {
    final Directory extDir3 = await getExternalStorageDirectory();
    final String dirPath = '${extDir3.path}/DCIM/choosephoto';
    await Directory(dirPath).create(recursive: true);
    final picname = dirPath +
        "/" +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".jpg";
    savepicture(widget.photopath[1], picname);
  }

  Future<Null> savepictoios() async {
    String result;
    try {
      result =
          await platform.invokeMethod('saveToPhotosAlbum', <String, dynamic>{
        'file': widget.photopath[1],
      });
    } on PlatformException catch (e) {
      showInSnackBar("照片存储失败：${e.message}");
    }
    print("原生返回结果：${result.toString()}");
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
    if (valid == 4) {
      if (nowper) {
        savepictoandroid();
      } else {
        showInSnackBar("未获得照片文件写入权限");
      }
    } else if (valid == 3) {
      if (nowper) {
        savepictoios();
      } else {
        showInSnackBar("未获得系统相册写入权限");
      }
    }
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
        content: Text(message)));
  }

  Future<void> shareImage(String imagepath) async {
    await ImageShare.shareImage(filePath: imagepath);
  }
}
