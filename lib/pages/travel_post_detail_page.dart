import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/travel_blogger.dart';
import '../utils/follow_service.dart';
import '../utils/favorite_service.dart';
import '../utils/report_service.dart';
import 'user_detail_page.dart';
import 'image_preview_page.dart';

/// 游记详情页
class TravelPostDetailPage extends StatefulWidget {
  final TravelPost post;
  final TravelBlogger blogger;

  const TravelPostDetailPage({
    Key? key,
    required this.post,
    required this.blogger,
  }) : super(key: key);

  @override
  State<TravelPostDetailPage> createState() => _TravelPostDetailPageState();
}

class _TravelPostDetailPageState extends State<TravelPostDetailPage> with TickerProviderStateMixin {
  int _currentImageIndex = 0;
  bool _isFollowing = false;
  bool _isFavorited = false;
  bool _isLoadingFollow = false;
  
  // 动画控制器
  late AnimationController _favoriteAnimationController;
  late Animation<double> _favoriteScaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadFollowStatus();
    _loadFavoriteStatus();
    
    // 初始化动画控制器
    _favoriteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _favoriteScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _favoriteAnimationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));
    
    // 监听关注状态变化
    FollowService.instance.addListener(_onFollowStatusChanged);
    // 监听收藏状态变化
    FavoriteService.instance.addListener(_onFavoriteStatusChanged);
  }

  @override
  void dispose() {
    // 移除监听器
    FollowService.instance.removeListener(_onFollowStatusChanged);
    FavoriteService.instance.removeListener(_onFavoriteStatusChanged);
    // 释放动画控制器
    _favoriteAnimationController.dispose();
    super.dispose();
  }

  /// 加载关注状态
  Future<void> _loadFollowStatus() async {
    final isFollowed = await FollowService.instance.isUserFollowed(widget.blogger.id);
    if (mounted) {
      setState(() {
        _isFollowing = isFollowed;
      });
    }
  }

  /// 加载收藏状态
  void _loadFavoriteStatus() {
    final isFavorited = FavoriteService.instance.isFavorited(widget.blogger, widget.post);
    if (mounted) {
      setState(() {
        _isFavorited = isFavorited;
      });
    }
  }

  /// 监听关注状态变化
  void _onFollowStatusChanged() {
    if (mounted) {
      final newStatus = FollowService.instance.getFollowStatusSync(widget.blogger.id);
      if (newStatus != _isFollowing) {
        setState(() {
          _isFollowing = newStatus;
        });
      }
    }
  }

  /// 监听收藏状态变化
  void _onFavoriteStatusChanged() {
    if (mounted) {
      _loadFavoriteStatus();
    }
  }

  /// 切换关注状态
  Future<void> _toggleFollow() async {
    if (_isLoadingFollow) return;

    setState(() {
      _isLoadingFollow = true;
    });

    try {
      bool success;
      String message;
      Color backgroundColor;

      if (_isFollowing) {
        success = await FollowService.instance.unfollowUser(widget.blogger.id);
        message = success ? '已取消关注 ${widget.blogger.name}' : '取消关注失败，请重试';
        backgroundColor = success ? Colors.orange : Colors.red;
      } else {
        success = await FollowService.instance.followUser(widget.blogger.id);
        message = success ? '已关注 ${widget.blogger.name}' : '关注失败，请重试';
        backgroundColor = success ? Colors.green : Colors.red;
      }

      if (mounted) {
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFollow = false;
        });
      }
    }
  }

  /// 切换收藏状态
  Future<void> _toggleFavorite() async {
    try {
      bool success;
      String message;
      
      if (_isFavorited) {
        // 取消收藏
        success = await FavoriteService.instance.removeFavoriteByPost(widget.blogger, widget.post);
        message = success ? '已取消收藏' : '取消收藏失败，请重试';
        
        if (success) {
          // 播放取消收藏动画
          _playFavoriteAnimation(false);
        }
      } else {
        // 添加收藏
        success = await FavoriteService.instance.addFavorite(widget.blogger, widget.post);
        message = success ? '已收藏' : '收藏失败，请重试';
        
        if (success) {
          // 播放收藏动画
          _playFavoriteAnimation(true);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success ? Colors.green : Colors.red,
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
  }

  /// 播放收藏动画
  void _playFavoriteAnimation(bool isAdding) {
    _favoriteAnimationController.reset();
    _favoriteAnimationController.forward();
    
    // 显示浮动的+1或-1动画
    _showFloatingAnimation(isAdding);
  }

  /// 显示浮动的+1/-1动画
  void _showFloatingAnimation(bool isAdding) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.5,
        left: MediaQuery.of(context).size.width * 0.5 - 50,
        child: AnimatedBuilder(
          animation: _favoriteAnimationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_favoriteAnimationController.value * 100),
              child: Transform.scale(
                scale: _favoriteScaleAnimation.value,
                child: Opacity(
                  opacity: 1.0 - _favoriteAnimationController.value,
                  child: Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isAdding ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isAdding ? '+1' : '-1',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // 动画完成后移除overlay
    _favoriteAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        overlayEntry.remove();
      }
    });
  }

  /// 格式化日期显示
  String _formatDate(DateTime date) {
    return '${date.month}-${date.day}';
  }

  /// 处理菜单操作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'report':
        _showReportDialog();
        break;
    }
  }

  /// 显示举报对话框
  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('举报内容'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('内容违规'),
                onTap: () => _submitContentReport('内容违规'),
              ),
              ListTile(
                title: const Text('虚假信息'),
                onTap: () => _submitContentReport('虚假信息'),
              ),
              ListTile(
                title: const Text('垃圾内容'),
                onTap: () => _submitContentReport('垃圾内容'),
              ),
              ListTile(
                title: const Text('其他'),
                onTap: () => _submitContentReport('其他'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  /// 提交内容举报
  void _submitContentReport(String reason) async {
    Navigator.pop(context);
    
    // 生成内容ID（使用blogger id + post title的组合）
    final contentId = '${widget.blogger.id}_${widget.post.title}';
    
    // 检查是否已经举报过该内容
    if (ReportService.instance.hasReportedContent(contentId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('举报内容核实中，请耐心等待处理结果'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // 提交举报
    final success = await ReportService.instance.reportContent(
      contentId: contentId,
      contentTitle: widget.post.title.isNotEmpty ? widget.post.title : '游记内容',
      reason: reason,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('举报内容核实中，请耐心等待处理结果'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('举报提交失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 主要内容区域
          CustomScrollView(
            slivers: [
              // 全屏图片头部区域
              widget.post.images.isNotEmpty
                  ? SliverAppBar(
                      expandedHeight: MediaQuery.of(context).size.height * 0.6,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      leading: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      actions: [
                        // 用户信息和关注按钮
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 用户头像和姓名
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserDetailPage(blogger: widget.blogger),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipOval(
                                        child: Image.asset(
                                          widget.blogger.avatar,
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 24,
                                              height: 24,
                                              color: AppConstants.primaryColor.withOpacity(0.1),
                                              child: const Icon(
                                                Icons.person,
                                                color: AppConstants.primaryColor,
                                                size: 14,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.blogger.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 关注按钮
                              GestureDetector(
                                onTap: _isLoadingFollow ? null : _toggleFollow,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _isLoadingFollow 
                                        ? Colors.grey.withOpacity(0.5)
                                        : (_isFollowing ? Colors.grey.withOpacity(0.7) : AppConstants.primaryColor),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: _isLoadingFollow
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          _isFollowing ? '已关注' : '+关注',
                                          style: TextStyle(
                                            color: _isFollowing ? Colors.white : Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 举报按钮
                              Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onSelected: (value) {
                                    _handleMenuAction(value);
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem<String>(
                                      value: 'report',
                                      child: Row(
                                        children: [
                                          Icon(Icons.flag_outlined, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('举报内容'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          children: [
                            // 主图片
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImagePreviewPage(
                                      imageUrls: widget.post.images,
                                      initialIndex: _currentImageIndex,
                                      heroTag: 'travel_post',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                child: Image.asset(
                                  widget.post.images[_currentImageIndex],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                          size: 60,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // 渐变遮罩
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  stops: const [0.0, 0.3, 0.7, 1.0],
                                ),
                              ),
                            ),

                            // 底部缩略图列表（类似Banner详情）
                            if (widget.post.images.length > 1)
                              Positioned(
                                bottom: 20,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 60,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: widget.post.images.length,
                                    itemBuilder: (context, index) {
                                      final isSelected = index == _currentImageIndex;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _currentImageIndex = index;
                                          });
                                        },
                                        onLongPress: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ImagePreviewPage(
                                                imageUrls: widget.post.images,
                                                initialIndex: index,
                                                heroTag: 'travel_thumbnail',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          margin: const EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isSelected ? AppConstants.primaryColor : Colors.white.withOpacity(0.6),
                                              width: isSelected ? 3 : 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.asset(
                                              widget.post.images[index],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                    size: 30,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  : SliverAppBar(
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Colors.white,
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: AppConstants.textPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
              // 可滚动的内容区域
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      if (widget.post.title.isNotEmpty)
                        Text(
                          widget.post.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimary,
                          ),
                        ),

                      if (widget.post.title.isNotEmpty)
                        const SizedBox(height: 16),

                      // 内容文本
                      Text(
                        widget.post.content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppConstants.textPrimary,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 底部信息栏
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 发布日期
                          Text(
                            _formatDate(widget.post.publishTime),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppConstants.textSecondary,
                            ),
                          ),
                          // 操作按钮组
                          Row(
                            children: [
                              // 收藏按钮
                              GestureDetector(
                                onTap: _toggleFavorite,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _isFavorited ? Icons.bookmark : Icons.bookmark_border,
                                        color: _isFavorited ? AppConstants.primaryColor : AppConstants.textSecondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '收藏',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _isFavorited ? AppConstants.primaryColor : AppConstants.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 