import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../utils/storage_util.dart';
import '../utils/toast_util.dart';
import 'auth_screen.dart';
import 'my_follows_page.dart';

/// 个人中心页面
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _userInfo;
  bool _isLoading = true;
  int _followedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadFollowedCount();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await StorageUtil.getUserInfo();
      if (mounted) {
        setState(() {
          _userInfo = userInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('加载用户信息失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 加载关注数量
  Future<void> _loadFollowedCount() async {
    try {
      final count = await StorageUtil.getFollowedUsersCount();
      if (mounted) {
        setState(() {
          _followedCount = count;
        });
      }
    } catch (e) {
      print('加载关注数量失败: $e');
    }
  }

  /// 检查会员是否有效
  bool _isMemberValid() {
    if (_userInfo == null) return false;
    try {
      final memberExpiry = DateTime.parse(_userInfo!.memberExpiry);
      return DateTime.now().isBefore(memberExpiry);
    } catch (e) {
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我的',
          style: TextStyle(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              ),
            )
          : _userInfo == null
              ? const Center(
                  child: Text(
                    '加载用户信息失败',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                )
              : Column(
                  children: [
                    // 用户信息卡片
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 头像
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppConstants.primaryColor,
                            child: Text(
                              _userInfo!.avatar,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // 姓名
                          Text(
                            _userInfo!.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // 用户ID
                          Text(
                            'ID: ${_userInfo!.id}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppConstants.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // 性别
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _userInfo!.gender == '男' 
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.pink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _userInfo!.gender,
                              style: TextStyle(
                                fontSize: 12,
                                color: _userInfo!.gender == '男' 
                                    ? Colors.blue
                                    : Colors.pink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // 金币和会员信息
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.monetization_on,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_userInfo!.coins}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.diamond,
                                      size: 16,
                                      color: AppConstants.primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isMemberValid() ? 'VIP' : '普通',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppConstants.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // 个性签名
                          Text(
                            _userInfo!.signature,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppConstants.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    // 功能列表
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildMenuItem(
                            Icons.favorite,
                            '我的关注',
                            () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyFollowsPage(),
                                ),
                              );
                              // 返回时重新加载关注数量
                              _loadFollowedCount();
                            },
                            subtitle: '$_followedCount 人',
                          ),
                          _buildMenuItem(Icons.person, '个人资料', () {}),
                          _buildMenuItem(Icons.settings, '设置', () {}),
                          _buildMenuItem(Icons.help, '帮助与反馈', () {}),
                          _buildMenuItem(Icons.info, '关于我们', () {}),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppConstants.textSecondary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: AppConstants.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.textTertiary,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppConstants.textTertiary,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: Colors.white,
      ),
    );
  }
} 