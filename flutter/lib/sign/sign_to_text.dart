import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:image/image.dart' as imagelib;

class SignToTextLanguage extends StatefulWidget {
  const SignToTextLanguage({super.key});
  @override
  State<SignToTextLanguage> createState() => _SignToTextLanguageState();
}

class _SignToTextLanguageState extends State<SignToTextLanguage> {
  String data = 'Press the button to fetch data';
  String textResult = '';
  late List<CameraDescription> cameras;
  late CameraController controller;
  bool isCameraInitialized = false;
  late WebSocketChannel _channel;
  List<Map<String, dynamic>> results = [];
  CameraImage? cameraImage;
  bool isDetecting = false;
  bool lock = false;
  late DateTime lastProcessedTime;
  @override
  void initState() {
    super.initState();
    initializeCamera();
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://127.0.0.1:8000/'),
    );
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    try {
      await controller.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        isCameraInitialized = true;
      });
    }
  }

  void fetchData(CameraImage image) async {
    compute((message) {
      final bytes = concatenatePlanes(message.planes);
      final byte = Uint8List.fromList(bytes);
      imagelib.Image? imageLis = imagelib.decodeImage(byte);
      imageLis = imagelib.copyRotate(imageLis!, angle: 90);

      final img = base64Encode(imagelib.encodeJpg(imageLis));
      return img;
    }, image)
        .then((value) {
      _channel.sink.add(value);
    });
  }

  static List<int> concatenatePlanes(List<Plane> planes) {
    List<int> allBytes = [];
    for (Plane plane in planes) {
      allBytes.addAll(plane.bytes);
    }
    return allBytes;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return StreamBuilder(
        stream: _channel.stream,
        builder: (context, snapshot) {
          if (!isCameraInitialized) {
            return const Scaffold(
              body: Center(
                child: Text("Camera not loaded, waiting for it"),
              ),
            );
          } else {
            if (snapshot.hasData) {
              results = [jsonDecode(snapshot.data.toString())];
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(
                    controller,
                  ),
                ),
                ...displayBoxesAroundRecognizedObjects(size),
                Positioned(
                  bottom: 75,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 5,
                          color: Colors.white,
                          style: BorderStyle.solid),
                    ),
                    child: isDetecting
                        ? IconButton(
                            onPressed: () async {
                              await stopDetection();
                            },
                            icon: const Icon(
                              Icons.stop,
                              color: Colors.red,
                            ),
                            iconSize: 50,
                          )
                        : IconButton(
                            onPressed: () async {
                              await startDetection();
                            },
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            iconSize: 50,
                          ),
                  ),
                ),
              ],
            );
          }
        });
  }

  Future<void> startDetection() async {
    setState(() {
      isDetecting = true;
      lastProcessedTime = DateTime.now();
    });
    if (controller.value.isStreamingImages) {
      return;
    }

    await controller.startImageStream((image) {
      final currentTime = DateTime.now();
      if (isDetecting &&
          currentTime.difference(lastProcessedTime).inSeconds >= 1) {
        cameraImage = image;
        fetchData(image);
        lastProcessedTime = currentTime;
      }
    });
  }

  Future<void> stopDetection() async {
    setState(() {
      isDetecting = false;
      textResult = '';
      results.clear();
    });
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (results.isEmpty || !isDetecting) return [];

    double factorX = screen.width / (cameraImage?.height ?? 1);
    double factorY = screen.height / (cameraImage?.width ?? 1);

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);
   
    return results.map((result) {
     
      try {
        return Positioned(
          left: result["bounding_box"]['x1'] * factorX,
          top: result["bounding_box"]['y1'] * factorY,
          width: (result["bounding_box"]['x2'] - result["bounding_box"]['x1']) *
              factorX,
          height:
              (result["bounding_box"]['y2'] - result["bounding_box"]['y1']) *
                  factorY,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(color: Colors.pink, width: 2.0),
            ),
            child: Text(
              //textResult.split("").join(),
              result['predicted_character'],
              textDirection: TextDirection.rtl,
              style: TextStyle(
                background: Paint()..color = colorPick,
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
          ),
        );
      } catch (e) {
        return const SizedBox();
      }
    }).toList();
  }
}
