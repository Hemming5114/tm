import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/travel_blogger.dart';

/// 旅行数据服务类
class TravelDataService {
  static List<TravelBlogger>? _cachedBloggers;
  
  /// 从JSON文件加载数据
  static Future<List<Map<String, dynamic>>> _loadJsonData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/app_content.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('加载JSON数据失败: $e');
      return [];
    }
  }
  
  /// 获取所有旅行博主
  static Future<List<TravelBlogger>> getAllBloggers() async {
    if (_cachedBloggers != null) {
      return _cachedBloggers!;
    }
    
    final jsonData = await _loadJsonData();
    final bloggers = <TravelBlogger>[];
    
    for (final userData in jsonData) {
      try {
        final blogger = TravelBlogger(
          id: userData['id'] ?? 0,
          name: userData['name'] ?? '未知用户',
          avatar: 'assets/images/home/${userData['head'] ?? 'user_head_1.jpg'}',
          fans: Random().nextInt(10000) + 500, // 随机粉丝数
          follows: Random().nextInt(100) + 10, // 随机关注数
          bio: userData['sign'] ?? '这个人很懒，什么都没写',
          tags: List<String>.from(userData['tags'] ?? ['旅行博主']), // 从JSON读取标签
          gender: userData['sex'] ?? '未知',
          posts: _convertToPosts(userData['list'] ?? []),
        );
        bloggers.add(blogger);
      } catch (e) {
        print('解析用户数据失败: $e');
        continue;
      }
    }
    
    _cachedBloggers = bloggers;
    return bloggers;
  }
  
  /// 将JSON中的list数据转换为TravelPost对象
  static List<TravelPost> _convertToPosts(List<dynamic> postList) {
    final posts = <TravelPost>[];
    
    for (final postData in postList) {
      try {
        final content = postData['content'] ?? '';
        final images = (postData['images'] as List<dynamic>?)
            ?.map((img) => 'assets/images/home/$img')
            .toList() ?? [];
        
        // 从内容中提取标题（取第一行或前20个字符）
        String title = content.split('\n').first;
        if (title.length > 20) {
          title = title.substring(0, 20) + '...';
        }
        if (title.isEmpty) {
          title = '精彩游记分享';
        }
        
        // 解析时间字段
        DateTime publishTime;
        if (postData['time'] != null) {
          try {
            publishTime = DateTime.parse(postData['time']);
          } catch (e) {
            publishTime = DateTime.now().subtract(Duration(days: Random().nextInt(30)));
          }
        } else {
          publishTime = DateTime.now().subtract(Duration(days: Random().nextInt(30)));
        }
        
        final post = TravelPost(
          title: title,
          content: content,
          images: images,
          likes: Random().nextInt(5000) + 100, // 随机点赞数
          comments: Random().nextInt(500) + 10, // 随机评论数
          publishTime: publishTime,
        );
        
        posts.add(post);
      } catch (e) {
        print('解析帖子数据失败: $e');
        continue;
      }
    }
    
    // 按时间由近到远排序
    posts.sort((a, b) => b.publishTime.compareTo(a.publishTime));
    
    return posts;
  }
  
  /// 获取今日推荐博主（随机4个）
  static Future<List<TravelBlogger>> getTodayRecommendedBloggers() async {
    final allBloggers = await getAllBloggers();
    final shuffled = List<TravelBlogger>.from(allBloggers);
    shuffled.shuffle(Random());
    return shuffled.take(4).toList();
  }
  
  /// 获取优选游记
  static Future<List<TravelPost>> getFeaturedPosts() async {
    final allBloggers = await getAllBloggers();
    final allPosts = <TravelPost>[];
    
    for (final blogger in allBloggers) {
      allPosts.addAll(blogger.posts);
    }
    
    // 按点赞数排序并随机打乱一些
    allPosts.shuffle(Random());
    allPosts.sort((a, b) => b.likes.compareTo(a.likes));
    
    return allPosts;
  }
  
  /// 根据帖子获取对应的博主
  static Future<TravelBlogger?> getBloggerByPost(TravelPost post) async {
    final allBloggers = await getAllBloggers();
    
    for (final blogger in allBloggers) {
      if (blogger.posts.contains(post)) {
        return blogger;
      }
    }
    
    return null;
  }
} 