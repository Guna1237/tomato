import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

Future<double> detectFaceConfidence(String imagePath) async {
  final detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  try {
    final inputImage = InputImage.fromFilePath(imagePath);
    final faces = await detector.processImage(inputImage);
    if (faces.isEmpty) return 0.0;
    final face = faces.first;
    final leftEye = face.leftEyeOpenProbability ?? 0.5;
    final rightEye = face.rightEyeOpenProbability ?? 0.5;
    final box = face.boundingBox;
    // Weight: eye classification 70%, bounding box area ratio 30%
    final areaRatio = ((box.width * box.height) / (300.0 * 300.0)).clamp(0.0, 1.0);
    return ((leftEye + rightEye) / 2) * 0.7 + areaRatio * 0.3;
  } finally {
    await detector.close();
  }
}
