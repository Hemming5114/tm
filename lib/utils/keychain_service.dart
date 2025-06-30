import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

/// Keychain 安全存储服务
/// 在iOS设备上使用Keychain存储用户敏感信息，确保卸载重装后数据不丢失
class KeychainService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // 存储键名
  static const String _userInfoKey = 'user_info';
  static const String _userIdKey = 'user_id';
  static const String _isLoggedInKey = 'is_logged_in';

  /// 保存用户信息到Keychain
  static Future<bool> saveUserInfo(UserModel user) async {
    try {
      final userJson = json.encode(user.toMap());
      await _secureStorage.write(key: _userInfoKey, value: userJson);
      await _secureStorage.write(key: _userIdKey, value: user.id);
      await _secureStorage.write(key: _isLoggedInKey, value: 'true');
      print('用户信息已保存到Keychain');
      return true;
    } catch (e) {
      print('保存用户信息到Keychain失败: $e');
      return false;
    }
  }

  /// 从Keychain获取用户信息
  static Future<UserModel?> getUserInfo() async {
    try {
      final userJson = await _secureStorage.read(key: _userInfoKey);
      if (userJson == null) {
        print('Keychain中未找到用户信息');
        return null;
      }

      final userData = json.decode(userJson);
      final user = UserModel.fromMap(userData);
      print('从Keychain成功加载用户信息: ${user.name}');
      return user;
    } catch (e) {
      print('从Keychain读取用户信息失败: $e');
      return null;
    }
  }

  /// 检查用户是否已登录
  static Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = await _secureStorage.read(key: _isLoggedInKey);
      return isLoggedIn == 'true';
    } catch (e) {
      print('检查登录状态失败: $e');
      return false;
    }
  }

  /// 获取用户ID
  static Future<String?> getUserId() async {
    try {
      return await _secureStorage.read(key: _userIdKey);
    } catch (e) {
      print('获取用户ID失败: $e');
      return null;
    }
  }

  /// 更新用户信息
  static Future<bool> updateUserInfo(UserModel user) async {
    return await saveUserInfo(user);
  }

  /// 更新用户硬币数量
  static Future<bool> updateUserCoins(int coins) async {
    try {
      final user = await getUserInfo();
      if (user != null) {
        final updatedUser = user.copyWith(coins: coins);
        return await saveUserInfo(updatedUser);
      }
      return false;
    } catch (e) {
      print('更新用户硬币数量失败: $e');
      return false;
    }
  }

  /// 更新用户会员到期时间
  static Future<bool> updateMemberExpiry(String memberExpiry) async {
    try {
      final user = await getUserInfo();
      if (user != null) {
        final updatedUser = user.copyWith(memberExpiry: memberExpiry);
        return await saveUserInfo(updatedUser);
      }
      return false;
    } catch (e) {
      print('更新用户会员信息失败: $e');
      return false;
    }
  }

  /// 更新用户签名
  static Future<bool> updateUserSignature(String signature) async {
    try {
      final user = await getUserInfo();
      if (user != null) {
        final updatedUser = user.copyWith(signature: signature);
        return await saveUserInfo(updatedUser);
      }
      return false;
    } catch (e) {
      print('更新用户签名失败: $e');
      return false;
    }
  }

  /// 更新用户头像
  static Future<bool> updateUserAvatar(String avatar) async {
    try {
      final user = await getUserInfo();
      if (user != null) {
        final updatedUser = user.copyWith(avatar: avatar);
        return await saveUserInfo(updatedUser);
      }
      return false;
    } catch (e) {
      print('更新用户头像失败: $e');
      return false;
    }
  }

  /// 清除用户信息
  static Future<bool> clearUserInfo() async {
    try {
      await _secureStorage.delete(key: _userInfoKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _isLoggedInKey);
      print('用户信息已从Keychain清除');
      return true;
    } catch (e) {
      print('清除Keychain用户信息失败: $e');
      return false;
    }
  }

  /// 检查是否支持Keychain（主要用于iOS）
  static bool get isKeychainSupported => Platform.isIOS;

  /// 清除所有Keychain数据（仅用于测试）
  static Future<bool> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      print('所有Keychain数据已清除');
      return true;
    } catch (e) {
      print('清除所有Keychain数据失败: $e');
      return false;
    }
  }

  /// 迁移SharedPreferences数据到Keychain
  static Future<bool> migrateFromSharedPreferences() async {
    try {
      // 这里可以添加从SharedPreferences迁移数据的逻辑
      // 但由于项目中已经有用户数据，我们暂时不实现自动迁移
      print('可以在这里实现从SharedPreferences到Keychain的数据迁移');
      return true;
    } catch (e) {
      print('数据迁移失败: $e');
      return false;
    }
  }
} 