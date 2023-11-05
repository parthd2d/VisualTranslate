import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class RecognitionApi {
  static Future<String?> recognizeText(
      InputImage inputImage, TextRecognitionScript script) async {
    try {
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();
      return recognizedText.text;
    } catch (c) {
      return null;
    }
  }
}
