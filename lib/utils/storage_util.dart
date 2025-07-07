import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';
import 'keychain_service.dart';

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
    // iOS设备优先使用Keychain
    if (Platform.isIOS) {
      return await KeychainService.isLoggedIn();
    }
    
    // 其他平台使用SharedPreferences
    await init();
    return _prefs!.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  /// 保存用户登录状态
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    await init();
    await _prefs!.setBool(AppConstants.keyIsLoggedIn, isLoggedIn);
  }

  /// 保存用户信息
  static Future<bool> saveUserInfo(UserModel user) async {
    // iOS设备优先使用Keychain
    if (Platform.isIOS) {
      final success = await KeychainService.saveUserInfo(user);
      if (success) {
        // 同时保存一份到SharedPreferences作为备份
        await init();
        await _prefs!.setBool(AppConstants.keyIsLoggedIn, true);
        await _prefs!.setString('userData', json.encode(user.toMap()));
      }
      return success;
    }
    
    // 其他平台使用SharedPreferences
    try {
      await init();
      await _prefs!.setBool(AppConstants.keyIsLoggedIn, true);
      await _prefs!.setString('userData', json.encode(user.toMap()));
      return true;
    } catch (e) {
      print('保存用户信息失败: $e');
      return false;
    }
  }

  /// 获取用户信息
  static Future<UserModel?> getUserInfo() async {
    // iOS设备优先从Keychain读取
    if (Platform.isIOS) {
      final user = await KeychainService.getUserInfo();
      if (user != null) {
        return user;
      }
      
      // 如果Keychain中没有数据，尝试从SharedPreferences读取并迁移
      print('Keychain中未找到用户数据，尝试从SharedPreferences迁移');
      final sharedPrefsUser = await _getUserInfoFromSharedPreferences();
      if (sharedPrefsUser != null) {
        // 将数据迁移到Keychain
        await KeychainService.saveUserInfo(sharedPrefsUser);
        print('用户数据已迁移到Keychain');
        return sharedPrefsUser;
      }
      return null;
    }
    
    // 其他平台从SharedPreferences读取
    return await _getUserInfoFromSharedPreferences();
  }

  /// 从SharedPreferences获取用户信息（内部方法）
  static Future<UserModel?> _getUserInfoFromSharedPreferences() async {
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
  static Future<bool> clearUserInfo() async {
    bool success = true;
    
    // iOS设备清除Keychain数据
    if (Platform.isIOS) {
      success = await KeychainService.clearUserInfo();
    }
    
    // 清除SharedPreferences数据
    try {
      await init();
      await _prefs!.remove(AppConstants.keyIsLoggedIn);
      await _prefs!.remove('userData');
    } catch (e) {
      print('清除SharedPreferences用户数据失败: $e');
      success = false;
    }
    
    return success;
  }

  /// 更新用户信息
  static Future<bool> updateUserInfo(UserModel user) async {
    return await saveUserInfo(user);
  }

  /// 更新用户硬币数量
  static Future<bool> updateUserCoins(int coins) async {
    if (Platform.isIOS) {
      return await KeychainService.updateUserCoins(coins);
    }
    
    final user = await getUserInfo();
    if (user != null) {
      final updatedUser = user.copyWith(coins: coins);
      return await saveUserInfo(updatedUser);
    }
    return false;
  }

  /// 更新用户头像
  static Future<bool> updateUserAvatar(String avatar) async {
    if (Platform.isIOS) {
      return await KeychainService.updateUserAvatar(avatar);
    }
    
    final user = await getUserInfo();
    if (user != null) {
      final updatedUser = user.copyWith(avatar: avatar);
      return await saveUserInfo(updatedUser);
    }
    return false;
  }

  /// 更新用户签名
  static Future<bool> updateUserSignature(String signature) async {
    if (Platform.isIOS) {
      return await KeychainService.updateUserSignature(signature);
    }
    
    final user = await getUserInfo();
    if (user != null) {
      final updatedUser = user.copyWith(signature: signature);
      return await saveUserInfo(updatedUser);
    }
    return false;
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

  // ==================== AI聊天历史功能相关方法 ====================
  
  static const String _aiChatHistoryKey = 'ai_chat_history';
  
  /// 保存AI聊天历史记录
  static Future<bool> saveAiChatHistory(List<Map<String, dynamic>> chatHistory) async {
    try {
      await init();
      final String chatHistoryJson = json.encode(chatHistory);
      return await _prefs!.setString(_aiChatHistoryKey, chatHistoryJson);
    } catch (e) {
      print('保存AI聊天历史失败: $e');
      return false;
    }
  }
  
  /// 获取AI聊天历史记录
  static Future<List<Map<String, dynamic>>> getAiChatHistory() async {
    try {
      await init();
      final String? chatHistoryJson = _prefs!.getString(_aiChatHistoryKey);
      
      if (chatHistoryJson != null) {
        final List<dynamic> chatHistoryList = json.decode(chatHistoryJson);
        return chatHistoryList.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      print('获取AI聊天历史失败: $e');
      return [];
    }
  }
  
  /// 清除AI聊天历史记录
  static Future<bool> clearAiChatHistory() async {
    try {
      await init();
      return await _prefs!.remove(_aiChatHistoryKey);
    } catch (e) {
      print('清除AI聊天历史失败: $e');
      return false;
    }
  }
  
  /// 获取AI聊天历史记录数量
  static Future<int> getAiChatHistoryCount() async {
    try {
      final chatHistory = await getAiChatHistory();
      return chatHistory.length;
    } catch (e) {
      print('获取AI聊天历史数量失败: $e');
      return 0;
    }
  }
  
  /// 添加单条AI聊天记录
  static Future<bool> addAiChatMessage(String type, String content) async {
    try {
      final chatHistory = await getAiChatHistory();
      chatHistory.add({
        'type': type,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return await saveAiChatHistory(chatHistory);
    } catch (e) {
      print('添加AI聊天记录失败: $e');
      return false;
    }
  }
} 