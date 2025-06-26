import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';
import '../constants/app_constants.dart';
import '../models/travel_blogger.dart';
import '../utils/travel_data_service.dart';
import 'banner_detail_page.dart';
import 'user_detail_page.dart';

/// 首页
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TravelBlogger> _todayRecommended = [];
  List<MapEntry<TravelPost, TravelBlogger>> _featuredPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 加载数据
  Future<void> _loadData() async {
    try {
      // 获取所有博主
      final allBloggers = await TravelDataService.getAllBloggers();
      
      if (allBloggers.isEmpty) {
        print('没有获取到博主数据');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
      
      // 随机选择4位用户作为今日推荐
      final shuffled = List<TravelBlogger>.from(allBloggers);
      shuffled.shuffle(Random());
      final todayRecommended = shuffled.take(4).toList();
      
      // 从这4位用户中，每位用户的游记列表中各选择一篇
      final featuredPosts = <MapEntry<TravelPost, TravelBlogger>>[];
      
      for (final blogger in todayRecommended) {
        // 检查该用户是否有游记
        if (blogger.posts.isNotEmpty) {
          // 随机选择该用户的一篇游记
          final randomIndex = Random().nextInt(blogger.posts.length);
          final selectedPost = blogger.posts[randomIndex];
          featuredPosts.add(MapEntry(selectedPost, blogger));
        } else {
          print('用户 ${blogger.name} 没有游记');
        }
      }

      if (mounted) {
        setState(() {
          _todayRecommended = todayRecommended;
          _featuredPosts = featuredPosts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('加载数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              ),
            )
          : RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppConstants.primaryColor,
              child: CustomScrollView(
                slivers: [
                  // 顶部横幅 - 左右铺满屏幕，纯图片，点击进入详情页
                  SliverToBoxAdapter(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BannerDetailPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AppConstants.bannerImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // 右下角提示文字
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '点击查看更多',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // 今日推荐标题
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        '今日推荐',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // 今日推荐博主 - 随机4位，只显示头像和昵称
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _todayRecommended.map((blogger) => _buildRecommendedBlogger(blogger)).toList(),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 30)),

                  // 优选游记标题
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        '优选游记',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // 优选游记网格 - 从推荐用户中各选一篇，总共4篇
                  if (_featuredPosts.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemBuilder: (context, index) {
                          if (index >= _featuredPosts.length) return const SizedBox.shrink();
                          final postEntry = _featuredPosts[index];
                          return _buildPostCard(postEntry.key, postEntry.value);
                        },
                        childCount: _featuredPosts.length,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
    );
  }

  /// 构建推荐博主卡片 - 简化版：只显示头像和昵称
  Widget _buildRecommendedBlogger(TravelBlogger blogger) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailPage(blogger: blogger),
          ),
        );
      },
      child: Column(
        children: [
          // 头像
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppConstants.primaryColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                blogger.avatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      color: AppConstants.primaryColor,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 昵称
          SizedBox(
            width: 70,
            child: Text(
              blogger.name,
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建游记卡片
  Widget _buildPostCard(TravelPost post, TravelBlogger blogger) {
    return GestureDetector(
      onTap: () {
        // TODO: 跳转到游记详情页
        print('点击游记: ${post.title} - ${blogger.name}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片 - 只显示第一张
            if (post.images.isNotEmpty)
              Container(
                height: (post.title.length % 3 + 1) * 80.0 + 120, // 动态高度
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    post.images.first,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            
            // 内容
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // 博主信息
                  Row(
                    children: [
                      // 博主头像
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailPage(blogger: blogger),
                            ),
                          );
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              blogger.avatar,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppConstants.primaryColor.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppConstants.primaryColor,
                                    size: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // 博主姓名
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserDetailPage(blogger: blogger),
                              ),
                            );
                          },
                          child: Text(
                            blogger.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppConstants.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      // 点赞数
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            size: 14,
                            color: AppConstants.textTertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            post.likesDisplay,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppConstants.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 