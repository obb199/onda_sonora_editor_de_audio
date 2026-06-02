import 'package:permission_handler/permission_handler.dart';

/// Handles runtime permission requests.
class PermissionsService {
  PermissionsService._();
  static final PermissionsService instance = PermissionsService._();

  Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> requestStorage() async {
    // Android 13+ uses granular media permissions
    final audio = await Permission.audio.request();
    if (audio.isGranted) return true;
    // Fallback for older Android
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }

  Future<bool> hasMicrophone() => Permission.microphone.isGranted;
  Future<bool> hasStorage() => Permission.storage.isGranted;

  Future<void> openSettings() => openAppSettings();
}
