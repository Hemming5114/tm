import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../utils/storage_util.dart';
import '../utils/toast_util.dart';
import 'auth_screen.dart';
import 'my_follows_page.dart';
import 'my_profile_page.dart';
import 'my_favorites_page.dart';
import 'blacklist_page.dart';
import 'report_history_page.dart';
import 'about_us_page.dart';
import 'help_feedback_page.dart';

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
      print('用户信息: ${userInfo?.toString()}');
      print('用户头像: ${userInfo?.avatar}');
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

  /// 获取有效的头像路径
  String _getValidAvatarPath() {
    if (_userInfo == null) return 'assets/images/head/user_head_1.jpg';
    
    String avatar = _userInfo!.avatar;
    
    // 如果是旧格式的头像名（user_head_icon），转换为新格式
    if (avatar.startsWith('user_head_icon')) {
      // 提取数字部分
      final match = RegExp(r'user_head_icon(\d+)\.jpg').firstMatch(avatar);
      if (match != null) {
        final number = int.tryParse(match.group(1) ?? '1') ?? 1;
        // 将1-10映射到11-20的范围
        final newNumber = (number % 10) + 11;
        avatar = 'user_head_$newNumber.jpg';
        print('转换头像: ${_userInfo!.avatar} -> $avatar');
      }
    }
    
    return 'assets/images/head/$avatar';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
          ),
        ),
      );
    }

    if (_userInfo == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            '加载用户信息失败',
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textSecondary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 背景图片（用户头像）
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // 头像背景
                Image.asset(
                  _getValidAvatarPath(),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('背景头像加载失败: ${_getValidAvatarPath()}, 错误: $error');
                    // 如果头像加载失败，使用默认背景
                    return Image.asset(
                      'assets/images/baner/banner_icon.png',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
                // 60%不透明度遮罩
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.4),
                ),
              ],
            ),
          ),
          
          // 内容区域
          Column(
            children: [
              // 顶部用户信息区域
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),
                child: Column(
                  children: [
                    // 用户头像
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          _getValidAvatarPath(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('头像加载失败: ${_getValidAvatarPath()}, 错误: $error');
                            return Container(
                              color: AppConstants.primaryColor,
                              child: Text(
                                _userInfo!.name.isNotEmpty ? _userInfo!.name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 用户名和标签在同一行
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 用户名
                        Text(
                          _userInfo!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 标签
                        _buildTag('旅行博主'),
                        const SizedBox(width: 8),
                        _buildTag('诗人'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 个人简介
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _userInfo!.signature.isNotEmpty 
                            ? _userInfo!.signature 
                            : '去过森林和草原，大海和高山，田野和湖泊。分享最真实的旅行体验。',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.4,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              
              // 底部功能区域
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 10),
                      
                      // 我的资料
                      _buildMenuItem(
                        Icons.person,
                        '我的资料',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyProfilePage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // 我的关注
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
                      const SizedBox(height: 12),
                      
                      // 我的收藏
                      _buildMenuItem(
                        Icons.bookmark,
                        '我的收藏',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyFavoritesPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // 黑名单
                      _buildMenuItem(
                        Icons.block,
                        '黑名单',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BlacklistPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // 举报历史
                      _buildMenuItem(
                        Icons.report,
                        '举报历史',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReportHistoryPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // 意见反馈
                      _buildMenuItem(
                        Icons.help_outline,
                        '意见反馈',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpFeedbackPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // 关于我们
                      _buildMenuItem(
                        Icons.info,
                        '关于我们',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutUsPage(),
                            ),
                          );
                        },
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

  /// 构建标签
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建菜单项
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {String? subtitle}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.grey[600],
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }
} 