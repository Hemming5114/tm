import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:io';

/// iOS Photos框架服务类
class IOSPhotosService {
  static const MethodChannel _channel = MethodChannel('com.tm.photos');

  /// 请求iOS相册权限
  /// 使用原生Photos框架获取权限
  static Future<String> requestPhotosPermission() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('此方法仅支持iOS平台');
    }
    
    try {
      final String result = await _channel.invokeMethod('requestPhotosPermission');
      print('iOS相册权限申请结果: $result');
      return result;
    } on PlatformException catch (e) {
      print('请求iOS相册权限失败: ${e.message}');
      throw e;
    }
  }

  /// 保存图片到iOS相册
  /// 使用原生Photos框架保存图片
  static Future<Map<String, dynamic>> saveImageToPhotos(Uint8List imageData) async {
    if (!Platform.isIOS) {
      throw UnsupportedError('此方法仅支持iOS平台');
    }
    
    try {
      final result = await _channel.invokeMethod('saveImageToPhotos', {
        'imageData': imageData,
      });
      
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        return {'success': true, 'message': '保存成功'};
      }
    } on PlatformException catch (e) {
      print('保存图片到iOS相册失败: ${e.message}');
      throw e;
    }
  }

  /// 检查权限状态是否已授予
  static bool isPermissionGranted(String status) {
    return status == 'granted';
  }

  /// 检查权限状态是否被拒绝
  static bool isPermissionDenied(String status) {
    return status == 'denied';
  }

  /// 检查权限状态是否受限制
  static bool isPermissionRestricted(String status) {
    return status == 'restricted';
  }

  /// 获取权限状态的用户友好描述
  static String getPermissionStatusDescription(String status) {
    switch (status) {
      case 'granted':
        return '权限已授予';
      case 'denied':
        return '权限被拒绝';
      case 'restricted':
        return '权限受限制';
      case 'notDetermined':
        return '权限未确定';
      default:
        return '未知状态';
    }
  }
} 