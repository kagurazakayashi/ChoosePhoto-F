import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("设置"),
      ),
      body: Column(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
