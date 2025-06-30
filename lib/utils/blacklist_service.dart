import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/travel_blogger.dart';

/// 黑名单服务
class BlacklistService {
  static const String _blacklistKey = 'blacklist_users';
  static BlacklistService? _instance;
  static BlacklistService get instance => _instance ??= BlacklistService._();
  
  BlacklistService._();

  Set<int> _blacklistedUserIds = {};
  List<TravelBlogger> _blacklistedUsers = [];
  final List<Function()> _listeners = [];

  /// 初始化黑名单数据
  Future<void> initialize() async {
    await _loadBlacklist();
  }

  /// 添加监听器
  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  /// 移除监听器
  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  /// 通知监听器
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// 从本地存储加载黑名单
  Future<void> _loadBlacklist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blacklistData = prefs.getString(_blacklistKey);
      
      if (blacklistData != null) {
        final List<dynamic> jsonList = json.decode(blacklistData);
        _blacklistedUsers = jsonList.map((json) => TravelBlogger.fromFolderData(json)).toList();
        _blacklistedUserIds = _blacklistedUsers.map((user) => user.id).toSet();
      }
    } catch (e) {
      print('加载黑名单失败: $e');
    }
  }

  /// 保存黑名单到本地存储
  Future<void> _saveBlacklist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _blacklistedUsers.map((user) => user.toMap()).toList();
      await prefs.setString(_blacklistKey, json.encode(jsonList));
    } catch (e) {
      print('保存黑名单失败: $e');
    }
  }

  /// 拉黑用户
  Future<bool> blockUser(TravelBlogger user) async {
    try {
      if (_blacklistedUserIds.contains(user.id)) {
        return true; // 已经拉黑
      }

      _blacklistedUserIds.add(user.id);
      _blacklistedUsers.add(user);
      
      await _saveBlacklist();
      _notifyListeners();
      
      return true;
    } catch (e) {
      print('拉黑用户失败: $e');
      return false;
    }
  }

  /// 取消拉黑用户
  Future<bool> unblockUser(int userId) async {
    try {
      if (!_blacklistedUserIds.contains(userId)) {
        return true; // 没有拉黑
      }

      _blacklistedUserIds.remove(userId);
      _blacklistedUsers.removeWhere((user) => user.id == userId);
      
      await _saveBlacklist();
      _notifyListeners();
      
      return true;
    } catch (e) {
      print('取消拉黑失败: $e');
      return false;
    }
  }

  /// 检查用户是否被拉黑
  bool isUserBlocked(int userId) {
    return _blacklistedUserIds.contains(userId);
  }

  /// 获取黑名单用户列表
  List<TravelBlogger> getBlacklistedUsers() {
    return List.from(_blacklistedUsers);
  }

  /// 过滤被拉黑的用户
  List<TravelBlogger> filterBlackedUsers(List<TravelBlogger> users) {
    return users.where((user) => !_blacklistedUserIds.contains(user.id)).toList();
  }

  /// 过滤被拉黑用户的帖子
  List<TravelPost> filterBlackedPosts(List<TravelPost> posts, List<TravelBlogger> allBloggers) {
    final blockedBloggerIds = <int>{};
    
    // 找出被拉黑用户的帖子
    for (final blogger in allBloggers) {
      if (_blacklistedUserIds.contains(blogger.id)) {
        blockedBloggerIds.add(blogger.id);
      }
    }
    
    // 这里需要根据实际的帖子-用户关联逻辑来过滤
    // 暂时返回所有帖子，实际使用时需要根据帖子的作者ID来过滤
    return posts;
  }

  /// 清空黑名单（用于测试）
  Future<void> clearBlacklist() async {
    _blacklistedUserIds.clear();
    _blacklistedUsers.clear();
    await _saveBlacklist();
    _notifyListeners();
  }
} 