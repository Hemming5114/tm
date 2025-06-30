import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/travel_blogger.dart';
import '../utils/toast_util.dart';
import '../utils/blacklist_service.dart';

/// 黑名单页面
class BlacklistPage extends StatefulWidget {
  const BlacklistPage({Key? key}) : super(key: key);

  @override
  State<BlacklistPage> createState() => _BlacklistPageState();
}

class _BlacklistPageState extends State<BlacklistPage> {
  List<TravelBlogger> _blacklist = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlacklist();
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
      _loadBlacklist();
    }
  }

  /// 加载黑名单
  Future<void> _loadBlacklist() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // 从黑名单服务获取数据
      final blacklistedUsers = BlacklistService.instance.getBlacklistedUsers();
      
      if (mounted) {
        setState(() {
          _blacklist = blacklistedUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('加载黑名单失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 移除黑名单
  Future<void> _removeFromBlacklist(TravelBlogger user) async {
    // 显示确认对话框
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('取消拉黑'),
          content: Text('确定要取消拉黑 ${user.name} 吗？取消后将重新看到该用户的内容。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确定', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final success = await BlacklistService.instance.unblockUser(user.id);
        
        if (success) {
          if (mounted) {
            ToastUtil.showInfo(context, '已取消拉黑 ${user.name}');
          }
        } else {
          if (mounted) {
            ToastUtil.showError(context, '取消拉黑失败，请重试');
          }
        }
      } catch (e) {
        if (mounted) {
          ToastUtil.showError(context, '取消拉黑失败，请重试');
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
          '黑名单',
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
          : _blacklist.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // 说明信息
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '黑名单中的用户将无法与您互动，您也不会看到他们的内容',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange.shade700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 黑名单列表
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _blacklist.length,
                        itemBuilder: (context, index) {
                          return _buildBlacklistCard(_blacklist[index]);
                        },
                      ),
                    ),
                  ],
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
            Icons.block,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '黑名单为空',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '暂时没有拉黑任何用户',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建黑名单卡片
  Widget _buildBlacklistCard(TravelBlogger user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 头像
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: ClipOval(
                child: Image.asset(
                  user.avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.bio,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // 标签
                  if (user.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      children: user.tags.take(2).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            
            // 操作按钮
            Column(
              children: [
                // 移出黑名单按钮
                TextButton(
                  onPressed: () => _showRemoveDialog(user),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    foregroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(60, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '解除',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 显示移出黑名单确认对话框
  void _showRemoveDialog(TravelBlogger user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移出黑名单'),
        content: Text('确定要将 ${user.name} 移出黑名单吗？移出后，该用户可以正常与您互动。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFromBlacklist(user);
            },
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
} 