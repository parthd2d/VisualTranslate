import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:txt_recog_translate/APIs/recognition_api.dart';
import 'package:txt_recog_translate/APIs/translation_api.dart';

class CameraWidget extends StatefulWidget {
  final CameraDescription camera;
  const CameraWidget({
    required this.camera,
    super.key,
  });

  @override
  State<CameraWidget> createState() {
    return _CameraWidgetState();
  }
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController cameraController;
  late Future<void> initCameraFn;
  String? shownText;
  TextRecognitionScript script = TextRecognitionScript.latin;

  @override
  void initState() {
    super.initState();
    cameraController = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );
    initCameraFn = cameraController.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        FutureBuilder(
          future: initCameraFn,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            return SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: CameraPreview(cameraController),
            );
          }),
        ),
        Positioned(
          bottom: 50,
          right: 50,
          child: FloatingActionButton(
            onPressed: () async {
              final image = await cameraController.takePicture();
              final recognizedText = await RecognitionApi.recognizeText(
                  InputImage.fromFile(
                    File(image.path),
                  ),
                  script);
              if (recognizedText == null) return;
              final translatedText =
                  await TranslationApi.translateText(recognizedText);
              setState(() {
                shownText = translatedText;
              });
            },
            child: const Icon(Icons.translate),
          ),
        ),
        if (shownText != null)
          Align(
            alignment: Alignment.center,
            child: Container(
              color: Colors.black45,
              child: Text(
                shownText!,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
