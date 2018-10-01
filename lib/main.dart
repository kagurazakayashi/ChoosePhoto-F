import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';

// void main() => runApp(MyApp());

List<CameraDescription> cameras;

Future<void> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(CameraApp());
}

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

class CameraExampleHome extends StatefulWidget {
  @override
  _CameraExampleHomeState createState() {
    return _CameraExampleHomeState();
  }
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

class _CameraExampleHomeState extends State<CameraExampleHome> {
  CameraController controller;
  String imagePath;
  String videoPath;
  // VideoPlayerController videoController;
  VoidCallback videoPlayerListener;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // @override
  // void initState() {
  //   main11();
  //   super.initState();
  // }
  // main11() async {
  //   // Fetch the available cameras before initializing the app.
  //   try {
  //     cameras = await availableCameras();
  //   } on CameraException catch (e) {
  //     logError(e.code, e.description);
  //   }
  //   // runApp(CameraApp());
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // appBar: AppBar(
      //   title: const Text('Camera example'),
      // ),
      body: Column(
        children: <Widget>[
          Container(
            height: 500,
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
                Row(
                  children: <Widget>[
                    _captureControlRowWidget(),
                    _cameraTogglesRowWidget(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // _cameraTogglesRowWidget(),
                      _thumbnailWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: _thumbnailWidgetBig(100.0),
          )
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
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

  /// Display the thumbnail of the captured image or video.
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

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidgetBig(double size) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: imagePath == null
            ? null
            : SizedBox(
                child: Image.file(File(imagePath)),
                width: size,
                height: size,
              ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
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
        // IconButton(
        //   icon: const Icon(Icons.videocam),
        //   color: Colors.blue,
        //   onPressed: controller != null &&
        //           controller.value.isInitialized &&
        //           !controller.value.isRecordingVideo
        //       ? onVideoRecordButtonPressed
        //       : null,
        // ),
        // IconButton(
        //   icon: const Icon(Icons.stop),
        //   color: Colors.red,
        //   onPressed: controller != null &&
        //           controller.value.isInitialized &&
        //           controller.value.isRecordingVideo
        //       ? onStopButtonPressed
        //       : null,
        // )
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
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: controller != null && controller.value.isRecordingVideo
                  ? null
                  : onNewCameraSelected,
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

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
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

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          // videoController?.dispose();
          // videoController = null;
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  // void onVideoRecordButtonPressed() {
  //   startVideoRecording().then((String filePath) {
  //     if (mounted) setState(() {});
  //     if (filePath != null) showInSnackBar('Saving video to $filePath');
  //   });
  // }

  // void onStopButtonPressed() {
  //   stopVideoRecording().then((_) {
  //     if (mounted) setState(() {});
  //     showInSnackBar('Video recorded to: $videoPath');
  //   });
  // }

  // Future<String> startVideoRecording() async {
  //   if (!controller.value.isInitialized) {
  //     showInSnackBar('Error: select a camera first.');
  //     return null;
  //   }

  //   final Directory extDir = await getApplicationDocumentsDirectory();
  //   final String dirPath = '${extDir.path}/Movies/flutter_test';
  //   await Directory(dirPath).create(recursive: true);
  //   final String filePath = '$dirPath/${timestamp()}.mp4';

  //   if (controller.value.isRecordingVideo) {
  //     // A recording is already started, do nothing.
  //     return null;
  //   }

  //   try {
  //     videoPath = filePath;
  //     await controller.startVideoRecording(filePath);
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     return null;
  //   }
  //   return filePath;
  // }

  // Future<void> stopVideoRecording() async {
  //   if (!controller.value.isRecordingVideo) {
  //     return null;
  //   }

  //   try {
  //     await controller.stopVideoRecording();
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     return null;
  //   }

  //   await _startVideoPlayer();
  // }

  // Future<void> _startVideoPlayer() async {
  //   final VideoPlayerController vcontroller =
  //       VideoPlayerController.file(File(videoPath));
  //   videoPlayerListener = () {
  //     if (videoController != null && videoController.value.size != null) {
  //       // Refreshing the state to update video player with the correct ratio.
  //       if (mounted) setState(() {});
  //       videoController.removeListener(videoPlayerListener);
  //     }
  //   };
  //   vcontroller.addListener(videoPlayerListener);
  //   await vcontroller.setLooping(true);
  //   await vcontroller.initialize();
  //   await videoController?.dispose();
  //   if (mounted) {
  //     setState(() {
  //       imagePath = null;
  //       videoController = vcontroller;
  //     });
  //   }
  //   await vcontroller.play();
  // }

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

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraExampleHome(),
    );
  }
}


