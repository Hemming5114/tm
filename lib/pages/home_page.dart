import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';
import '../constants/app_constants.dart';
import '../models/travel_blogger.dart';
import '../utils/travel_data_service.dart';
import '../utils/blacklist_service.dart';
import '../utils/storage_util.dart';
import 'banner_detail_page.dart';
import 'user_detail_page.dart';
import 'travel_post_detail_page.dart';
import 'post_travel_page.dart';

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
    _checkAndShowWelcomeDialog();
    // 监听黑名单变化
    BlacklistService.instance.addListener(_onBlacklistChanged);
  }

  @override
  void dispose() {
    BlacklistService.instance.removeListener(_onBlacklistChanged);
    super.dispose();
  }

  /// 监听黑名单变化
  void _onBlacklistChanged() {
    if (mounted) {
      _loadData();
    }
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
      
      // 过滤被拉黑的用户
      final filteredBloggers = BlacklistService.instance.filterBlackedUsers(allBloggers);
      
      if (filteredBloggers.isEmpty) {
        print('过滤后没有可显示的博主数据');
        if (mounted) {
          setState(() {
            _todayRecommended = [];
            _featuredPosts = [];
            _isLoading = false;
          });
        }
        return;
      }
      
      // 随机选择4位用户作为今日推荐
      final shuffled = List<TravelBlogger>.from(filteredBloggers);
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

  /// 检查并显示欢迎弹框
  Future<void> _checkAndShowWelcomeDialog() async {
    try {
      final hasShownDialog = await StorageUtil.getBool('has_shown_welcome_dialog') ?? false;
      if (!hasShownDialog && mounted) {
        // 延迟一下，确保页面已经构建完成
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showWelcomeDialog();
          }
        });
      }
    } catch (e) {
      print('检查欢迎弹框状态失败: $e');
    }
  }

  /// 显示欢迎弹框
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Material(
          color: const Color(0xB3000000), // #000000 0.7 全屏背景
          child: SizedBox.expand( // 确保完全覆盖屏幕
            child: Center(
              child: Stack(
                clipBehavior: Clip.none, // 不剪裁超出边界的内容
                children: [
                  // 白色View - 297 x 444
                  Container(
                    width: 297,
                    height: 444,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // 背景图 pop_shadow.png - 铺满白色View
                        Container(
                          width: 297,
                          height: 444,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/pop/pop_shadow.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        
                        // 主要内容
                        Column(
                          children: [
                            const SizedBox(height: 37), // 距离白色View顶部37
                            
                            // 图片 pop_image2.png - 距离顶部37，左右各15，宽高267、290
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              width: 267,
                              height: 290,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/pop/pop_image2.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // 文案"来分享下你的旅行生活吧~"
                            const Text(
                              '来分享下你的旅行生活吧~',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 按钮区域
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  // 取消按钮
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        await StorageUtil.setBool('has_shown_welcome_dialog', true);
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F5F5),
                                          borderRadius: BorderRadius.circular(22),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '取消',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF666666),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 16),
                                  
                                  // 分享按钮
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        await StorageUtil.setBool('has_shown_welcome_dialog', true);
                                        Navigator.of(context).pop();
                                        // 进入游记分享页面
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const PostTravelPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFF9FB50), Color(0xFF90FAD8)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(22),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '分享',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // pop_image1.png - 小蜜蜂图标，与白色View同级但显示在上层
                  Positioned(
                    left: 15, // 距离白色View左边15px
                    top: -44, // 距离白色View顶部-44px（向上突出）
                    child: Image.asset(
                      'assets/images/pop/pop_image1.png',
                      width: 210,
                      height: 63,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TravelPostDetailPage(
              post: post,
              blogger: blogger,
            ),
          ),
        );
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
                    post.title.length > 20 ? '${post.title.substring(0, 20)}...' : post.title,
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