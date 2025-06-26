import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/travel_blogger.dart';
import '../utils/storage_util.dart';
import '../utils/travel_data_service.dart';

/// 我的关注列表页面
class MyFollowsPage extends StatefulWidget {
  const MyFollowsPage({Key? key}) : super(key: key);

  @override
  State<MyFollowsPage> createState() => _MyFollowsPageState();
}

class _MyFollowsPageState extends State<MyFollowsPage> {
  List<TravelBlogger> followedBloggers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowedBloggers();
  }

  /// 加载已关注的博主
  Future<void> _loadFollowedBloggers() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 获取已关注的用户ID列表
      final followedUserIds = await StorageUtil.getFollowedUsers();
      
      if (followedUserIds.isEmpty) {
        setState(() {
          followedBloggers = [];
          isLoading = false;
        });
        return;
      }

      // 获取所有博主数据
      final allBloggers = await TravelDataService.getAllBloggers();
      
      // 筛选出已关注的博主
      final followed = allBloggers.where((blogger) => 
          followedUserIds.contains(blogger.id)).toList();

      setState(() {
        followedBloggers = followed;
        isLoading = false;
      });
    } catch (e) {
      print('加载关注列表失败: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '我的关注',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : followedBloggers.isEmpty
              ? _buildEmptyState()
              : _buildFollowsList(),
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
            '还没有关注任何人',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建关注列表
  Widget _buildFollowsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: followedBloggers.length,
      itemBuilder: (context, index) {
        final blogger = followedBloggers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // 头像
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    blogger.avatar,
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
                      blogger.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      blogger.bio,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}