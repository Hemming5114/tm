import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

/// 图片本地存储服务
/// 使用SharedPreferences存储base64编码的图片数据
class ImageStorageService {
  static const String _avatarKey = 'user_custom_avatar';
  static const String _avatarTimestampKey = 'user_avatar_timestamp';

  /// 保存用户头像到本地
  static Future<bool> saveUserAvatar(File imageFile) async {
    try {
      // 读取图片文件
      final imageBytes = await imageFile.readAsBytes();
      
      // 转换为base64
      final base64String = base64Encode(imageBytes);
      
      // 保存到SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_avatarKey, base64String);
      await prefs.setInt(_avatarTimestampKey, DateTime.now().millisecondsSinceEpoch);
      
      print('头像已保存到本地存储');
      return true;
    } catch (e) {
      print('保存头像失败: $e');
      return false;
    }
  }

  /// 获取用户头像数据
  static Future<Uint8List?> getUserAvatarData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = prefs.getString(_avatarKey);
      
      if (base64String != null) {
        return base64Decode(base64String);
      }
      
      return null;
    } catch (e) {
      print('获取头像数据失败: $e');
      return null;
    }
  }

  /// 检查是否有自定义头像
  static Future<bool> hasCustomAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_avatarKey);
    } catch (e) {
      print('检查自定义头像失败: $e');
      return false;
    }
  }

  /// 删除用户头像
  static Future<bool> deleteUserAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_avatarKey);
      await prefs.remove(_avatarTimestampKey);
      print('头像已删除');
      return true;
    } catch (e) {
      print('删除头像失败: $e');
      return false;
    }
  }

  /// 获取头像保存时间
  static Future<DateTime?> getAvatarSaveTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_avatarTimestampKey);
      
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      
      return null;
    } catch (e) {
      print('获取头像保存时间失败: $e');
      return null;
    }
  }

  /// 获取头像数据大小（字节）
  static Future<int> getAvatarDataSize() async {
    try {
      final avatarData = await getUserAvatarData();
      return avatarData?.length ?? 0;
    } catch (e) {
      print('获取头像数据大小失败: $e');
      return 0;
    }
  }

  /// 清理所有头像数据
  static Future<bool> clearAllImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_avatarKey);
      await prefs.remove(_avatarTimestampKey);
      print('所有头像数据已清理');
      return true;
    } catch (e) {
      print('清理头像数据失败: $e');
      return false;
    }
  }
} 