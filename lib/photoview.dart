import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPage extends StatelessWidget {
  final String photopathSmall;
  final String photopath;
  const PhotoPage({this.photopathSmall,this.photopath});
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("放大浏览 ${widget.photopath}");
    print("缩略图 ${widget.photopathSmall}");
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
              margin: const EdgeInsets.symmetric(vertical: 0.0),
              height: (windowHeight - kBottomNavigationBarHeight - 5.0),
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
      case 1: //复位
        break;
      case 2: //保存
        break;
      case 3: //分享
        break;
      case 4: //删除
        break;
      default:
    }
  }
}
