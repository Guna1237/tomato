// Uses stub on web (no dart:io), real ML Kit on mobile/desktop.
export 'face_detection_service_stub.dart'
    if (dart.library.io) 'face_detection_service_native.dart';
