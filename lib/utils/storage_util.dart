import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

/// 本地存储工具类
class StorageUtil {
  static SharedPreferences? _prefs;
  static const String _followedUsersKey = 'followed_users';

  /// 初始化SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 检查用户是否已登录
  static Future<bool> isLoggedIn() async {
    await init();
    return _prefs!.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  /// 保存用户登录状态
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    await init();
    await _prefs!.setBool(AppConstants.keyIsLoggedIn, isLoggedIn);
  }

  /// 保存用户信息
  static Future<void> saveUserInfo(UserModel user) async {
    await init();
    await _prefs!.setBool(AppConstants.keyIsLoggedIn, true);
    await _prefs!.setString('userData', json.encode(user.toMap()));
  }

  /// 获取用户信息
  static Future<UserModel?> getUserInfo() async {
    await init();
    
    final isLoggedIn = _prefs!.getBool(AppConstants.keyIsLoggedIn) ?? false;
    if (!isLoggedIn) {
      return null;
    }

    final userDataJson = _prefs!.getString('userData');
    if (userDataJson == null) {
      return null;
    }

    try {
      final userData = json.decode(userDataJson);
      return UserModel.fromMap(userData);
    } catch (e) {
      print('解析用户数据失败: $e');
      return null;
    }
  }

  /// 清除用户信息
  static Future<void> clearUserInfo() async {
    await init();
    await _prefs!.remove(AppConstants.keyIsLoggedIn);
    await _prefs!.remove('userData');
  }

  /// 通用的存储方法
  static Future<void> setString(String key, String value) async {
    await init();
    await _prefs!.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    await init();
    return _prefs!.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await init();
    await _prefs!.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    await init();
    return _prefs!.getBool(key);
  }

  static Future<void> setInt(String key, int value) async {
    await init();
    await _prefs!.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    await init();
    return _prefs!.getInt(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await init();
    await _prefs!.setStringList(key, value);
  }

  static Future<List<String>?> getStringList(String key) async {
    await init();
    return _prefs!.getStringList(key);
  }

  static Future<void> remove(String key) async {
    await init();
    await _prefs!.remove(key);
  }

  static Future<void> clear() async {
    await init();
    await _prefs!.clear();
  }

  // ==================== 关注功能相关方法 ====================
  
  /// 获取已关注的用户ID列表
  static Future<List<int>> getFollowedUsers() async {
    try {
      await init();
      final String? followedUsersJson = _prefs!.getString(_followedUsersKey);
      
      if (followedUsersJson != null) {
        final List<dynamic> followedUsersList = json.decode(followedUsersJson);
        return followedUsersList.cast<int>();
      }
      
      return [];
    } catch (e) {
      print('获取关注用户列表失败: $e');
      return [];
    }
  }
  
  /// 保存已关注的用户ID列表
  static Future<bool> saveFollowedUsers(List<int> userIds) async {
    try {
      await init();
      final String followedUsersJson = json.encode(userIds);
      return await _prefs!.setString(_followedUsersKey, followedUsersJson);
    } catch (e) {
      print('保存关注用户列表失败: $e');
      return false;
    }
  }
  
  /// 关注用户
  static Future<bool> followUser(int userId) async {
    try {
      final followedUsers = await getFollowedUsers();
      if (!followedUsers.contains(userId)) {
        followedUsers.add(userId);
        return await saveFollowedUsers(followedUsers);
      }
      return true; // 已经关注过了
    } catch (e) {
      print('关注用户失败: $e');
      return false;
    }
  }
  
  /// 取消关注用户
  static Future<bool> unfollowUser(int userId) async {
    try {
      final followedUsers = await getFollowedUsers();
      followedUsers.remove(userId);
      return await saveFollowedUsers(followedUsers);
    } catch (e) {
      print('取消关注用户失败: $e');
      return false;
    }
  }
  
  /// 检查是否已关注用户
  static Future<bool> isUserFollowed(int userId) async {
    try {
      final followedUsers = await getFollowedUsers();
      return followedUsers.contains(userId);
    } catch (e) {
      print('检查用户关注状态失败: $e');
      return false;
    }
  }
  
  /// 清除所有关注数据
  static Future<bool> clearFollowedUsers() async {
    try {
      await init();
      return await _prefs!.remove(_followedUsersKey);
    } catch (e) {
      print('清除关注数据失败: $e');
      return false;
    }
  }
  
  /// 获取关注用户数量
  static Future<int> getFollowedUsersCount() async {
    try {
      final followedUsers = await getFollowedUsers();
      return followedUsers.length;
    } catch (e) {
      print('获取关注用户数量失败: $e');
      return 0;
    }
  }
} 