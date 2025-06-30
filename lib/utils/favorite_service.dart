import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/travel_blogger.dart';

/// 收藏的游记数据模型
class FavoritePost {
  final String postId; // 游记ID（用博主ID+游记索引组成）
  final int bloggerId;
  final String bloggerName;
  final String bloggerAvatar;
  final TravelPost post;
  final DateTime favoriteTime;

  FavoritePost({
    required this.postId,
    required this.bloggerId,
    required this.bloggerName,
    required this.bloggerAvatar,
    required this.post,
    DateTime? favoriteTime,
  }) : favoriteTime = favoriteTime ?? DateTime.now();

  factory FavoritePost.fromJson(Map<String, dynamic> json) {
    return FavoritePost(
      postId: json['postId'],
      bloggerId: json['bloggerId'],
      bloggerName: json['bloggerName'],
      bloggerAvatar: json['bloggerAvatar'],
      post: TravelPost.fromMap(json['post']),
      favoriteTime: DateTime.parse(json['favoriteTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'bloggerId': bloggerId,
      'bloggerName': bloggerName,
      'bloggerAvatar': bloggerAvatar,
      'post': post.toMap(),
      'favoriteTime': favoriteTime.toIso8601String(),
    };
  }
}

/// 收藏服务
class FavoriteService {
  static const String _favoritesKey = 'favorite_posts';
  static FavoriteService? _instance;
  static FavoriteService get instance => _instance ??= FavoriteService._();
  
  FavoriteService._();

  List<FavoritePost> _favoritePosts = [];
  final List<Function()> _listeners = [];

  /// 初始化收藏数据
  Future<void> initialize() async {
    await _loadFavorites();
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

  /// 从本地存储加载收藏数据
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesData = prefs.getString(_favoritesKey);
      
      if (favoritesData != null) {
        final List<dynamic> jsonList = json.decode(favoritesData);
        _favoritePosts = jsonList.map((json) => FavoritePost.fromJson(json)).toList();
        
        // 按收藏时间降序排列
        _favoritePosts.sort((a, b) => b.favoriteTime.compareTo(a.favoriteTime));
      }
    } catch (e) {
      print('加载收藏数据失败: $e');
    }
  }

  /// 保存收藏数据到本地存储
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _favoritePosts.map((favorite) => favorite.toJson()).toList();
      await prefs.setString(_favoritesKey, json.encode(jsonList));
    } catch (e) {
      print('保存收藏数据失败: $e');
    }
  }

  /// 生成游记ID
  String _generatePostId(int bloggerId, int postIndex) {
    return '${bloggerId}_$postIndex';
  }

  /// 添加收藏
  Future<bool> addFavorite(TravelBlogger blogger, TravelPost post) async {
    try {
      // 找到游记在博主帖子列表中的索引
      final postIndex = blogger.posts.indexOf(post);
      if (postIndex == -1) {
        return false;
      }

      final postId = _generatePostId(blogger.id, postIndex);
      
      // 检查是否已经收藏
      if (_favoritePosts.any((favorite) => favorite.postId == postId)) {
        return true; // 已经收藏
      }

      final favoritePost = FavoritePost(
        postId: postId,
        bloggerId: blogger.id,
        bloggerName: blogger.name,
        bloggerAvatar: blogger.avatar,
        post: post,
      );

      _favoritePosts.insert(0, favoritePost); // 插入到最前面
      await _saveFavorites();
      _notifyListeners();
      
      return true;
    } catch (e) {
      print('添加收藏失败: $e');
      return false;
    }
  }

  /// 取消收藏
  Future<bool> removeFavorite(String postId) async {
    try {
      final initialLength = _favoritePosts.length;
      _favoritePosts.removeWhere((favorite) => favorite.postId == postId);
      
      if (_favoritePosts.length < initialLength) {
        await _saveFavorites();
        _notifyListeners();
        return true;
      }
      
      return false; // 没有找到要删除的收藏
    } catch (e) {
      print('取消收藏失败: $e');
      return false;
    }
  }

  /// 通过博主和游记取消收藏
  Future<bool> removeFavoriteByPost(TravelBlogger blogger, TravelPost post) async {
    final postIndex = blogger.posts.indexOf(post);
    if (postIndex == -1) {
      return false;
    }
    
    final postId = _generatePostId(blogger.id, postIndex);
    return await removeFavorite(postId);
  }

  /// 检查游记是否已收藏
  bool isFavorited(TravelBlogger blogger, TravelPost post) {
    final postIndex = blogger.posts.indexOf(post);
    if (postIndex == -1) {
      return false;
    }
    
    final postId = _generatePostId(blogger.id, postIndex);
    return _favoritePosts.any((favorite) => favorite.postId == postId);
  }

  /// 通过postId检查是否已收藏
  bool isFavoritedById(String postId) {
    return _favoritePosts.any((favorite) => favorite.postId == postId);
  }

  /// 获取收藏列表
  List<FavoritePost> getFavorites() {
    return List.from(_favoritePosts);
  }

  /// 获取收藏数量
  int getFavoriteCount() {
    return _favoritePosts.length;
  }

  /// 清空收藏（用于测试）
  Future<void> clearFavorites() async {
    _favoritePosts.clear();
    await _saveFavorites();
    _notifyListeners();
  }
} 