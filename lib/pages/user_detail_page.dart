import 'package:flutter/material.dart';

import '../models/travel_blogger.dart';
import '../utils/follow_service.dart';
import '../utils/message_service.dart';
import '../utils/blacklist_service.dart';
import '../utils/report_service.dart';
import '../constants/app_constants.dart';
import 'image_preview_page.dart';
import 'travel_post_detail_page.dart';
import 'chat_page.dart';
import 'video_call_page.dart';

/// 用户详情页面
class UserDetailPage extends StatefulWidget {
  final TravelBlogger blogger;

  const UserDetailPage({
    Key? key,
    required this.blogger,
  }) : super(key: key);

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool isFollowing = false;

  bool isLoadingFollow = false;
  
  // 标签背景颜色列表
  final List<Color> _tagColors = [
    Colors.pink.shade100,
    Colors.purple.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.red.shade100,
    Colors.teal.shade100,
    Colors.indigo.shade100,
    Colors.amber.shade100,
    Colors.cyan.shade100,
  ];
  
  // 为每个标签生成随机颜色
  Color _getTagColor(String tag) {
    final hash = tag.hashCode;
    return _tagColors[hash.abs() % _tagColors.length];
  }
  
  @override
  void initState() {
    super.initState();
    _loadFollowStatus();
    // 监听关注状态变化
    FollowService.instance.addListener(_onFollowStatusChanged);
  }

  @override
  void dispose() {
    // 移除监听器
    FollowService.instance.removeListener(_onFollowStatusChanged);
    super.dispose();
  }

  /// 加载关注状态
  Future<void> _loadFollowStatus() async {
    final followed = await FollowService.instance.isUserFollowed(widget.blogger.id);
    if (mounted) {
    setState(() {
      isFollowing = followed;
    });
    }
  }

  /// 监听关注状态变化
  void _onFollowStatusChanged() {
    if (mounted) {
      final newStatus = FollowService.instance.getFollowStatusSync(widget.blogger.id);
      if (newStatus != isFollowing) {
        setState(() {
          isFollowing = newStatus;
        });
      }
    }
  }

  /// 切换关注状态
  Future<void> _toggleFollow() async {
    if (isLoadingFollow) return;

    setState(() {
      isLoadingFollow = true;
    });

    try {
    bool success;
      String message;
      Color backgroundColor;

    if (isFollowing) {
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
          isLoadingFollow = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 主要内容
          CustomScrollView(
            slivers: [
              // 顶部大背景图和用户信息
              _buildHeaderSection(),
              // 游记动态
              _buildPostsSection(),
            ],
          ),
          // 底部固定按钮
          _buildBottomButtons(),
          // 顶部返回按钮和举报拉黑按钮
          _buildTopButtons(),
        ],
      ),
    );
  }

  Widget _buildTopButtons() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
          // 举报拉黑按钮
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              onSelected: (value) {
                _handleMenuAction(value);
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.report, color: Colors.red),
                      SizedBox(width: 8),
                      Text('举报'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.red),
                      SizedBox(width: 8),
                      Text('拉黑'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'report':
        _showReportDialog();
        break;
      case 'block':
        _showBlockDialog();
        break;
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('举报用户'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('垃圾信息'),
                onTap: () => _submitReport('垃圾信息'),
              ),
              ListTile(
                title: const Text('不当内容'),
                onTap: () => _submitReport('不当内容'),
              ),
              ListTile(
                title: const Text('虚假信息'),
                onTap: () => _submitReport('虚假信息'),
              ),
              ListTile(
                title: const Text('其他'),
                onTap: () => _submitReport('其他'),
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

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('拉黑用户'),
          content: Text('确定要拉黑 ${widget.blogger.name} 吗？拉黑后将不再看到该用户的内容。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _blockUser();
              },
              child: const Text('确定', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _submitReport(String reason) async {
    Navigator.pop(context);
    
    // 检查是否已经举报过该用户
    if (ReportService.instance.hasReportedUser(widget.blogger.id.toString())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('举报内容核实中，请耐心等待处理结果'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // 提交举报
    final success = await ReportService.instance.reportUser(
      userId: widget.blogger.id.toString(),
      userName: widget.blogger.name,
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

  Future<void> _blockUser() async {
    try {
      final success = await BlacklistService.instance.blockUser(widget.blogger);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已拉黑 ${widget.blogger.name}'),
              backgroundColor: Colors.red,
            ),
          );
          
          // 返回主页
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('拉黑失败，请重试'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('拉黑失败，请重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 520,
        child: Stack(
          children: [
            // 背景图片
            Container(
              height: 400,
              width: double.infinity,
              child: Image.asset(
                widget.blogger.posts.isNotEmpty && widget.blogger.posts[0].images.isNotEmpty
                    ? widget.blogger.posts[0].images[0]
                    : 'assets/images/home/user_content_111.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            // 渐变蒙层
            Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // 用户信息卡片
            Positioned(
              bottom: 0,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 用户头像
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              widget.blogger.avatar,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.person, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 用户信息
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.blogger.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '粉丝 ${_formatNumber(widget.blogger.fans)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '关注 ${_formatNumber(widget.blogger.follows)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 个人简介
                    Text(
                      widget.blogger.bio,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    // 标签和关注按钮
                    Row(
                      children: [
                        // 标签（使用随机背景颜色）
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: widget.blogger.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getTagColor(tag),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 关注按钮
                        Container(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: isLoadingFollow ? null : _toggleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing ? Colors.grey[300] : AppConstants.primaryColor,
                              foregroundColor: isFollowing ? Colors.grey.shade700 : Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: isLoadingFollow
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : Text(
                                    isFollowing ? '已关注' : '+关注',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 20, bottom: 80),
        child: Column(
          children: [
            // 游记动态标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    '游记动态',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.blogger.posts.length} 篇',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 游记列表（已按时间排序）
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.blogger.posts.length,
              separatorBuilder: (context, index) => Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 16),
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final post = widget.blogger.posts[index];
                return _buildPostCard(post, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(TravelPost post, int index) {
    return GestureDetector(
      onTap: () {
        // 点击跳转到游记详情页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TravelPostDetailPage(
              post: post,
              blogger: widget.blogger,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
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
            // 发布时间和标签
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatDate(post.publishTime),
                    style: TextStyle(
                      fontSize: 12,
                                              color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_getTimeAgo(post.publishTime)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 标题
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 8),
          // 图片展示
          if (post.images.isNotEmpty) _buildImageLayout(post.images),
          if (post.images.isNotEmpty) const SizedBox(height: 8),
        ],
      ),
    ),
    );
  }

  Widget _buildImageLayout(List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();
    
    if (images.length == 1) {
      // 单张大图
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImagePreviewPage(
                imageUrls: images,
                initialIndex: 0,
                heroTag: 'post_image',
              ),
            ),
          );
        },
        child: Hero(
          tag: 'post_image_0',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              images[0],
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 240,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
      );
    } else if (images.length == 2) {
      // 两张图 - 左右排列
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openImagePreview(images, 0),
              child: Hero(
                tag: 'post_image_0',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    images[0],
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image_not_supported)),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: () => _openImagePreview(images, 1),
              child: Hero(
                tag: 'post_image_1',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    images[1],
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image_not_supported)),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (images.length >= 3) {
      // 三张及以上 - 上1下2布局，或2x2网格
      if (images.length == 3) {
        return Column(
          children: [
            GestureDetector(
              onTap: () => _openImagePreview(images, 0),
              child: Hero(
                tag: 'post_image_0',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    images[0],
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image_not_supported)),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openImagePreview(images, 1),
                    child: Hero(
                      tag: 'post_image_1',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          images[1],
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.image_not_supported)),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openImagePreview(images, 2),
                    child: Hero(
                      tag: 'post_image_2',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          images[2],
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.image_not_supported)),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      } else {
        // 4张图 - 2x2网格
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1,
          ),
          itemCount: images.length > 4 ? 4 : images.length,
          itemBuilder: (context, index) {
            final isLastItem = index == 3 && images.length > 4;
            
            return GestureDetector(
              onTap: () => _openImagePreview(images, index),
              child: Hero(
                tag: 'post_image_$index',
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        images[index],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.image_not_supported)),
                          );
                        },
                      ),
                    ),
                    if (isLastItem)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '+${images.length - 3}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
    
    return const SizedBox.shrink();
  }

  void _openImagePreview(List<String> images, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewPage(
          imageUrls: images,
          initialIndex: index,
          heroTag: 'post_image',
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // 创建或获取会话
                      final conversation = await MessageService.instance.getOrCreateConversation(
                        userId: widget.blogger.id.toString(),
                        userName: widget.blogger.name,
                        userAvatar: widget.blogger.avatar,
                      );
                      
                      if (mounted) {
                        // 跳转到聊天页面
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(conversation: conversation),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('创建会话失败: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '私聊',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    // 启动视频通话
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallPage(blogger: widget.blogger),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '视频',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}w';
    }
    return number.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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
} 