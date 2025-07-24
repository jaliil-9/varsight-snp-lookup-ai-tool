import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class StorageService {
  static Future<bool> requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkVersion = androidInfo.version.sdkInt;

        if (sdkVersion >= 33) {
          // Android 13 or higher
          // Request both permissions at once
          final status = await [Permission.photos, Permission.videos].request();

          // Check if any permission was denied
          if (status.values.any((status) => status.isDenied)) {
            return false;
          }

          return status.values.every((status) => status.isGranted);
        } else {
          final status = await Permission.storage.request();
          if (status.isDenied) {
            return false;
          }
          return status.isGranted;
        }
      } else if (Platform.isIOS) {
        final status = await [Permission.photos, Permission.videos].request();

        if (status.values.any((status) => status.isDenied)) {
          return false;
        }

        return status.values.every((status) => status.isGranted);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
