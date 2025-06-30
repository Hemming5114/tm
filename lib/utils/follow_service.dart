import 'package:flutter/foundation.dart';
import 'storage_util.dart';

/// 关注状态管理服务
class FollowService extends ChangeNotifier {
  static FollowService? _instance;
  static FollowService get instance => _instance ??= FollowService._();
  
  FollowService._();

  // 缓存关注状态，避免频繁读取存储
  final Map<int, bool> _followStatusCache = {};

  /// 获取用户关注状态
  Future<bool> isUserFollowed(int userId) async {
    // 先从缓存中获取
    if (_followStatusCache.containsKey(userId)) {
      return _followStatusCache[userId]!;
    }
    
    // 从存储中获取
    final isFollowed = await StorageUtil.isUserFollowed(userId);
    _followStatusCache[userId] = isFollowed;
    return isFollowed;
  }

  /// 关注用户
  Future<bool> followUser(int userId) async {
    try {
      final success = await StorageUtil.followUser(userId);
      if (success) {
        _followStatusCache[userId] = true;
        notifyListeners(); // 通知所有监听器状态已改变
      }
      return success;
    } catch (e) {
      print('关注用户失败: $e');
      return false;
    }
  }

  /// 取消关注用户
  Future<bool> unfollowUser(int userId) async {
    try {
      final success = await StorageUtil.unfollowUser(userId);
      if (success) {
        _followStatusCache[userId] = false;
        notifyListeners(); // 通知所有监听器状态已改变
      }
      return success;
    } catch (e) {
      print('取消关注用户失败: $e');
      return false;
    }
  }

  /// 切换关注状态
  Future<bool> toggleFollow(int userId) async {
    final isCurrentlyFollowed = await isUserFollowed(userId);
    if (isCurrentlyFollowed) {
      return await unfollowUser(userId);
    } else {
      return await followUser(userId);
    }
  }

  /// 获取关注状态（同步方法，从缓存中获取）
  bool getFollowStatusSync(int userId) {
    return _followStatusCache[userId] ?? false;
  }

  /// 清除缓存
  void clearCache() {
    _followStatusCache.clear();
  }

  /// 预加载用户关注状态
  Future<void> preloadFollowStatus(List<int> userIds) async {
    for (final userId in userIds) {
      if (!_followStatusCache.containsKey(userId)) {
        final isFollowed = await StorageUtil.isUserFollowed(userId);
        _followStatusCache[userId] = isFollowed;
      }
    }
  }
} 