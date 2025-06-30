import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/travel_data_service.dart';
import '../models/travel_blogger.dart';
import '../utils/follow_service.dart';
import '../utils/blacklist_service.dart';
import 'travel_post_detail_page.dart';
import 'post_travel_page.dart';
import 'user_detail_page.dart';

/// 动态页面
class DynamicPage extends StatefulWidget {
  const DynamicPage({super.key});

  @override
  State<DynamicPage> createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<TravelBlogger> _allBloggers = [];
  List<Map<String, dynamic>> _allPosts = [];
  List<Map<String, dynamic>> _followedPosts = [];
  List<TravelBlogger> _suggestedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    // 监听关注状态变化
    FollowService.instance.addListener(_onFollowStatusChanged);
    // 监听黑名单变化
    BlacklistService.instance.addListener(_onBlacklistChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // 移除监听器
    FollowService.instance.removeListener(_onFollowStatusChanged);
    BlacklistService.instance.removeListener(_onBlacklistChanged);
    super.dispose();
  }

  /// 关注状态变化回调
  void _onFollowStatusChanged() {
    if (mounted) {
      // 重新加载关注列表数据
      _loadFollowedPosts();
    }
  }

  /// 黑名单变化回调
  void _onBlacklistChanged() {
    if (mounted) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取所有博主数据
      final allBloggers = await TravelDataService.getAllBloggers();
      
      // 过滤被拉黑的用户
      _allBloggers = BlacklistService.instance.filterBlackedUsers(allBloggers);
      
      // 构建所有帖子数据（包含博主信息）
      _allPosts.clear();
      for (final blogger in _allBloggers) {
        for (final post in blogger.posts) {
          _allPosts.add({
            'blogger': blogger,
            'post': post,
          });
        }
      }
      
      // 按时间排序
      _allPosts.sort((a, b) => 
        (b['post'] as TravelPost).publishTime.compareTo((a['post'] as TravelPost).publishTime)
      );
      
      // 获取关注的帖子
      await _loadFollowedPosts();
      
      // 获取推荐用户
      final suggestedUsers = await TravelDataService.getTodayRecommendedBloggers();
      // 过滤被拉黑的推荐用户
      _suggestedUsers = BlacklistService.instance.filterBlackedUsers(suggestedUsers).take(3).toList();
      
    } catch (e) {
      print('加载数据失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFollowedPosts() async {
    final newFollowedPosts = <Map<String, dynamic>>[];
    
    for (final postData in _allPosts) {
      final blogger = postData['blogger'] as TravelBlogger;
      final isFollowed = await FollowService.instance.isUserFollowed(blogger.id);
      if (isFollowed) {
        newFollowedPosts.add(postData);
      }
    }
    
    // 按时间排序
    newFollowedPosts.sort((a, b) => 
      (b['post'] as TravelPost).publishTime.compareTo((a['post'] as TravelPost).publishTime)
    );
    
    if (mounted) {
      setState(() {
        _followedPosts = newFollowedPosts;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Tab栏 - 居左对齐，无横线
          Container(
            color: Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20), // 增加顶部间距
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: const [
                        Tab(text: '推荐'),
                        Tab(text: '关注'),
                      ],
                      labelColor: AppConstants.primaryColor,
                      unselectedLabelColor: AppConstants.textSecondary,
                      indicator: const BoxDecoration(), // 彻底移除指示器
                      indicatorColor: Colors.transparent, // 移除横线颜色
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 0, // 设置指示器粗细为0
                      dividerColor: Colors.transparent, // 移除分割线
                      labelStyle: const TextStyle(
                        fontSize: 18, // 选中状态字号更大
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 16, // 未选中状态字号较小
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          
          // 内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 推荐Tab
                _buildRecommendTab(),
                // 关注Tab
                _buildFollowTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          // 分享入口
          Container(
            margin: const EdgeInsets.all(16),
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFD3FFB2), Color(0xFFE0FFF8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PostTravelPage(),
                  ),
                );
              },
              child: Row(
                children: [
                  // 左边图片
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/images/post/image.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // 中间文案
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '永远在路上',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D5016),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '来分享下你的旅游生活吧～',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A7C59),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 右边按钮
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D5016),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '我要分享',
          style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
          ),
        ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 游记列表
          ..._allPosts.map((postData) => _buildPostCard(postData)),
        ],
      ),
    );
  }

  Widget _buildFollowTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_followedPosts.isEmpty) {
      return _buildEmptyFollowState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._followedPosts.map((postData) => _buildPostCard(postData)),
        ],
      ),
    );
  }

  Widget _buildEmptyFollowState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const SizedBox(height: 80),
          // 空状态图片
          Image.asset(
            'assets/images/bg_empty.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            '还没有关注任何人',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '关注感兴趣的博主，获取最新动态',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            '推荐关注',
              style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
                color: AppConstants.textPrimary,
              ),
            ),
          const SizedBox(height: 20),
          // 推荐用户列表
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _suggestedUsers.map((blogger) => _buildSuggestedUser(blogger)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedUser(TravelBlogger blogger) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头像 - 点击进入用户主页
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailPage(blogger: blogger),
                ),
              );
            },
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(blogger.avatar),
            ),
          ),
          const SizedBox(height: 8),
          // 用户名 - 点击进入用户主页
          GestureDetector(
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
            Text(
            '${blogger.fansDisplay}粉丝',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          // 关注按钮 - 只有这里可以关注
          GestureDetector(
            onTap: () async {
              try {
                await FollowService.instance.followUser(blogger.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('已关注 ${blogger.name}'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('关注失败，请重试'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '关注',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> postData) {
    final blogger = postData['blogger'] as TravelBlogger;
    final post = postData['post'] as TravelPost;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TravelPostDetailPage(
              blogger: blogger,
              post: post,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息行
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 头像 - 点击进入用户主页
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailPage(blogger: blogger),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(blogger.avatar),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blogger.name,
                            style: const TextStyle(
                  fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatDate(post.publishTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder<bool>(
                    future: FollowService.instance.isUserFollowed(blogger.id),
                    builder: (context, snapshot) {
                      final isFollowed = snapshot.data ?? false;
                      return GestureDetector(
                        onTap: () async {
                          // 显示加载状态
                          final currentState = isFollowed;
                          
                          try {
                            // 执行关注/取消关注操作
                            await FollowService.instance.toggleFollow(blogger.id);
                            
                            // 显示操作结果提示
                            if (mounted) {
                              final newState = !currentState;
                              final message = newState ? '已关注 ${blogger.name}' : '已取消关注 ${blogger.name}';
                              final backgroundColor = newState ? Colors.green : Colors.orange;
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor: backgroundColor,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('操作失败，请重试'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isFollowed ? Colors.grey[300] : AppConstants.primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isFollowed) ...[
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '已关注',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ] else ...[
                                const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '关注',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // 游记标题
            if (post.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimary,
                    height: 1.4,
              ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            
            const SizedBox(height: 12),
            
            // 图片展示
            if (post.images.isNotEmpty) _buildImageLayout(post.images),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  Widget _buildImageLayout(List<String> images) {
    final imageCount = images.length;
    
    if (imageCount == 1) {
      // 单张大图
      return _buildSingleImage(images[0]);
    } else if (imageCount == 2) {
      // 左右布局
      return _buildTwoImages(images);
    } else if (imageCount == 3) {
      // 1左2右布局
      return _buildThreeImages(images);
    } else if (imageCount == 4) {
      // 4宫格布局
      return _buildFourImages(images);
    } else if (imageCount == 5) {
      // 1中间4四周布局
      return _buildFiveImages(images);
    } else {
      // 2行3列布局
      return _buildSixOrMoreImages(images);
    }
  }

  Widget _buildSingleImage(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTwoImages(List<String> images) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 120,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                images[0],
                fit: BoxFit.cover,
                height: 120,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                images[1],
                fit: BoxFit.cover,
                height: 120,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeImages(List<String> images) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 120,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                images[0],
                fit: BoxFit.cover,
                height: 120,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      images[1],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      images[2],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourImages(List<String> images) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 计算正方形边长，考虑间距
          final imageSize = (constraints.maxWidth - 4) / 2;
          return SizedBox(
            height: imageSize * 2 + 4, // 两行图片加间距
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: imageSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            images[0],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: imageSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            images[1],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: imageSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            images[2],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: imageSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            images[3],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiveImages(List<String> images) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 160,
      child: Row(
        children: [
          // 左侧4个小图
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            images[0],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            images[1],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            images[2],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            images[3],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // 右侧1个大图
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                images[4],
                fit: BoxFit.cover,
                height: 160,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSixOrMoreImages(List<String> images) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 计算正方形边长，考虑间距
          final imageSize = (constraints.maxWidth - 8) / 3; // 3列，2个间距
          return SizedBox(
            height: imageSize * 2 + 4, // 两行图片加间距
            child: Column(
              children: [
                // 第一行 3个图
                SizedBox(
                  height: imageSize,
                  child: Row(
                    children: [
                      for (int i = 0; i < 3 && i < images.length; i++) ...[
                        if (i > 0) const SizedBox(width: 4),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              images[i],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // 第二行 3个图
                SizedBox(
                  height: imageSize,
                  child: Row(
                    children: [
                      for (int i = 3; i < 6 && i < images.length; i++) ...[
                        if (i > 3) const SizedBox(width: 4),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Image.asset(
                                  images[i],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                if (i == 5 && images.length > 6)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+${images.length - 6}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 