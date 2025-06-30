import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/travel_blogger.dart';
import '../utils/toast_util.dart';
import '../utils/favorite_service.dart';
import 'travel_post_detail_page.dart';
import 'image_preview_page.dart';

/// 我的收藏页面
class MyFavoritesPage extends StatefulWidget {
  const MyFavoritesPage({Key? key}) : super(key: key);

  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage> {
  List<FavoritePost> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    // 监听收藏状态变化
    FavoriteService.instance.addListener(_onFavoriteChanged);
  }

  @override
  void dispose() {
    FavoriteService.instance.removeListener(_onFavoriteChanged);
    super.dispose();
  }

  /// 监听收藏变化
  void _onFavoriteChanged() {
    if (mounted) {
      _loadFavorites();
    }
  }

  /// 加载收藏列表
  Future<void> _loadFavorites() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // 从收藏服务获取数据
      final favorites = FavoriteService.instance.getFavorites();
      
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('加载收藏失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 取消收藏
  Future<void> _removeFavorite(FavoritePost favoritePost) async {
    // 显示确认对话框
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('取消收藏'),
          content: Text('确定要取消收藏《${favoritePost.post.title}》吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确定', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final success = await FavoriteService.instance.removeFavorite(favoritePost.postId);
        
        if (success) {
          if (mounted) {
            ToastUtil.showInfo(context, '已取消收藏');
          }
        } else {
          if (mounted) {
            ToastUtil.showError(context, '取消收藏失败，请重试');
          }
        }
      } catch (e) {
        if (mounted) {
          ToastUtil.showError(context, '取消收藏失败，请重试');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '我的收藏',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              ),
            )
          : _favorites.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    return _buildFavoriteCard(_favorites[index]);
                  },
                ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '还没有收藏任何内容',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '去发现更多精彩内容吧',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建收藏卡片
  Widget _buildFavoriteCard(FavoritePost favoritePost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // 创建博主对象用于详情页
          final blogger = TravelBlogger(
            id: favoritePost.bloggerId,
            name: favoritePost.bloggerName,
            avatar: favoritePost.bloggerAvatar,
            fans: 0,
            follows: 0,
            bio: '',
            tags: [],
            gender: '',
            posts: [favoritePost.post],
          );
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TravelPostDetailPage(
                post: favoritePost.post,
                blogger: blogger,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和操作按钮
              Row(
                children: [
                  Expanded(
                    child: Text(
                      favoritePost.post.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'remove') {
                        _removeFavorite(favoritePost);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.favorite_border, size: 18),
                            SizedBox(width: 8),
                            Text('取消收藏'),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 内容预览
              Text(
                favoritePost.post.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // 图片预览
              if (favoritePost.post.images.isNotEmpty) ...[
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: favoritePost.post.images.length > 3 ? 3 : favoritePost.post.images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImagePreviewPage(
                                      imageUrls: favoritePost.post.images,
                                      initialIndex: index,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  favoritePost.post.images[index],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image, color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (index == 2 && favoritePost.post.images.length > 3)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+${favoritePost.post.images.length - 3}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // 统计信息和时间
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 16,
                    color: Colors.red[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                                            '收藏',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  const Spacer(),
                  Text(
                    _formatTime(favoritePost.post.publishTime),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }





  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

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