import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class KioskService {
  static final KioskService _instance = KioskService._internal();
  factory KioskService() => _instance;
  KioskService._internal();

  static const MethodChannel _channel = MethodChannel('com.duniaanak.ceria/kiosk');

  /// Kunci layar ke aplikasi (Screen Pinning / Kiosk Lock Task)
  Future<bool> startKiosk() async {
    try {
      final res = await _channel.invokeMethod<bool>('startKiosk');
      return res ?? false;
    } catch (e) {
      debugPrint("KioskService startKiosk error: $e");
      return false;
    }
  }

  /// Lepaskan kunci layar
  Future<bool> stopKiosk() async {
    try {
      final res = await _channel.invokeMethod<bool>('stopKiosk');
      return res ?? false;
    } catch (e) {
      debugPrint("KioskService stopKiosk error: $e");
      return false;
    }
  }

  /// Cek apakah mode kiosk/pinning sedang aktif
  Future<bool> isKioskActive() async {
    try {
      final res = await _channel.invokeMethod<bool>('isKioskActive');
      return res ?? false;
    } catch (e) {
      debugPrint("KioskService isKioskActive error: $e");
      return false;
    }
  }

  /// Buka menu pengaturan Android untuk memilih Launcher Default (Home App)
  Future<bool> openHomeSettings() async {
    try {
      final res = await _channel.invokeMethod<bool>('openHomeSettings');
      return res ?? false;
    } catch (e) {
      debugPrint("KioskService openHomeSettings error: $e");
      return false;
    }
  }
}
