import 'package:flutter/services.dart';
import 'dart:io';

/// 设备服务类
class DeviceService {
  static const MethodChannel _channel = MethodChannel('com.example.tm/device');

  /// 获取设备标识符
  /// 在iOS上返回IDFA，在其他平台返回空字符串
  static Future<String> getDeviceIdentifier() async {
    try {
      if (Platform.isIOS) {
        final String deviceId = await _channel.invokeMethod('getDeviceIdentifier');
        print('获取到设备标识符: $deviceId');
        return deviceId;
      } else {
        print('当前平台不支持获取设备标识符');
        return '';
      }
    } on PlatformException catch (e) {
      print('获取设备标识符失败: ${e.message}');
      return '';
    } catch (e) {
      print('获取设备标识符异常: $e');
      return '';
    }
  }
} 